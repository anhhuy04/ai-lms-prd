import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface AiQueueItem {
  id: string;
  submission_answer_id: string;
  request_type: "score" | "feedback" | "analysis";
  status: string;
  attempts: number;
  payload: Record<string, unknown> | null;
  result: Record<string, unknown> | null;
  created_at: string;
}

/** Structured feedback returned by AI and stored in submission_answers.ai_feedback */
interface AiFeedback {
  status: "completed" | "no_api_key" | "failed";
  provider: string;
  model: string;
  is_correct: boolean;
  summary: string;       // 1-câu kết luận ngắn
  explanation: string;   // Giải thích đáp án đúng (2-3 câu)
  misconception: string; // Lý do nhầm (nếu sai, ngắn)
  tip: string;           // Gợi ý học 1 câu hành động
  encouragement: string; // Lời động viên ngắn
  raw?: string;          // Raw AI response (debug)
}

Deno.serve(async (req: Request) => {
  try {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const supabase = createClient<any>(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")! // D-20: bypass RLS
    );

    let body: Record<string, unknown> = {};
    try { body = await req.json(); } catch { /* no body — process general queue */ }

    // C4 fix: accept session_id (Dart sends session_id, not submission_id)
    const sessionIdFilter = body.session_id as string | undefined;

    let query = supabase
      .from("ai_queue")
      .select("*")
      .eq("status", "pending")
      .order("created_at")
      .limit(10);

    if (sessionIdFilter) {
      const { data: answerIds } = await supabase
        .from("submission_answers")
        .select("id")
        .eq("session_id", sessionIdFilter);

      if (answerIds && answerIds.length > 0) {
        // Include: feedback/score items for this session's answers
        //          OR analysis items whose payload.session_id matches
        const idList = answerIds.map((a: { id: string }) => a.id).join(",");
        query = query.or(
          `submission_answer_id.in.(${idList}),and(request_type.eq.analysis,payload->>session_id.eq.${sessionIdFilter})`
        );
      } else {
        // No submission answers found — only look for analysis items
        query = query
          .eq("request_type", "analysis")
          .eq("payload->>session_id", sessionIdFilter);
      }
    }

    const { data: items, error: fetchError } = await query;
    if (fetchError) {
      console.error("Failed to fetch ai_queue:", fetchError);
      return new Response(JSON.stringify({ error: fetchError.message }), { status: 500 });
    }

    let processed = 0;
    for (const item of (items as AiQueueItem[]) ?? []) {
      const dispatchedAttempts = item.attempts + 1;
      await supabase
        .from("ai_queue")
        .update({ status: "processing", attempts: dispatchedAttempts, updated_at: new Date().toISOString() })
        .eq("id", item.id);

      // C1+L2 fix: track session_id here so maybeMarkSessionGraded runs AFTER
      // status='completed' is written — prevents race where current item is still
      // 'processing' when the pending check runs.
      let itemSessionId: string | null = null;
      let markCompleted = true;

      try {
        if (item.request_type === "feedback") {
          itemSessionId = await handleFeedback(supabase, item);
        } else if (item.request_type === "analysis") {
          await handleAnalysis(supabase, item);
        } else if (item.request_type === "score") {
          // L4 fix: mark 'deferred' so it can be reprocessed when Phase 3 re-enables
          console.log(`[STUB] Score request deferred: ${item.id}`);
          await supabase
            .from("ai_queue")
            .update({ status: "deferred", updated_at: new Date().toISOString() })
            .eq("id", item.id);
          markCompleted = false;
        }

        if (markCompleted) {
          await supabase
            .from("ai_queue")
            .update({ status: "completed", updated_at: new Date().toISOString() })
            .eq("id", item.id);

          // D-12: Call AFTER 'completed' write so current item is excluded from pending check
          if (itemSessionId) {
            await maybeMarkSessionGraded(supabase, itemSessionId);
          }
          processed++;
        }
      } catch (error) {
        const errMsg = error instanceof Error ? error.message : String(error);
        console.error(`[AI] Failed to process item ${item.id}: ${errMsg}`);
        // C2 fix: use dispatchedAttempts (already bumped) for failure check + update attempts column
        // Store error in result column for debugging
        await supabase
          .from("ai_queue")
          .update({
            status: dispatchedAttempts >= 3 ? "failed" : "pending",
            attempts: dispatchedAttempts,
            updated_at: new Date().toISOString(),
            result: { error: errMsg, failed_at: new Date().toISOString() },
          })
          .eq("id", item.id);
      }
    }

    return new Response(
      JSON.stringify({ processed, total: items?.length ?? 0 }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("[AI] Edge function error:", error);
    return new Response(JSON.stringify({ error: String(error) }), { status: 500 });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// FEEDBACK HANDLER: Explain MCQ correct/incorrect answer (D-05, D-19)
// ─────────────────────────────────────────────────────────────────────────────
// deno-lint-ignore no-explicit-any
async function handleFeedback(
  supabase: any,
  item: AiQueueItem
): Promise<string> {
  // D-21: Fetch submission_answer + question context
  // Use !left on questions join since question_id can be NULL for custom questions
  const { data: ctx, error } = await supabase
    .from("submission_answers")
    .select(`
      id, answer, final_score, session_id,
      assignment_question_id,
      assignment_questions!inner (
        points,
        custom_content,
        question_id,
        questions!left (
          content,
          question_choices ( id, content, is_correct )
        )
      )
    `)
    .eq("id", item.submission_answer_id)
    .single();

  if (error || !ctx) {
    console.error(`[AI] Answer query failed for ${item.submission_answer_id}:`, error?.message ?? "ctx is null");
    throw new Error(`Answer not found: ${item.submission_answer_id} — ${error?.message ?? "null ctx"}`);
  }

  // D-18: Get teacher API key from profiles.metadata
  const { data: session } = await supabase
    .from("work_sessions")
    .select("student_id, assignment_distribution_id")
    .eq("id", ctx.session_id)
    .single();

  const { data: dist } = await supabase
    .from("assignment_distributions")
    .select("assignments!inner(teacher_id)")
    .eq("id", session?.assignment_distribution_id)
    .single();

  const teacherId = (dist?.assignments as Record<string, unknown>)?.teacher_id as string;
  const { data: profile } = await supabase
    .from("profiles")
    .select("metadata")
    .eq("id", teacherId)
    .single();

  const meta       = profile?.metadata as Record<string, unknown> | null;
  const analytics  = meta?.analytics   as Record<string, string>  | null;
  const apiKeys    = meta?.api_keys    as Record<string, string>  | null;
  const provider   = analytics?.provider ?? "gemini";
  const model      = analytics?.model    ?? "gemini-2.0-flash";
  const apiKey     = apiKeys?.[provider];

  if (!apiKey) {
    console.warn(`[AI] No API key for provider "${provider}" — teacher ${teacherId}`);
    await supabase.from("submission_answers").update({
      ai_feedback: {
        status: "no_api_key",
        provider, model,
        summary: "Giáo viên chưa cấu hình API key cho AI phân tích.",
        explanation: "", misconception: "", tip: "", encouragement: "",
      } as AiFeedback,
    }).eq("id", item.submission_answer_id);
    // C1 fix: return session_id so outer loop can call maybeMarkSessionGraded
    return ctx.session_id as string;
  }

  // Build context for prompt
  const aq           = ctx.assignment_questions as Record<string, unknown>;
  const customContent = aq.custom_content as Record<string, unknown> | null;
  const linkedQ      = aq.questions as Record<string, unknown> | null;
  const maxPoints    = aq.points as number ?? 1;

  // questions.content is JSONB: { text: "...", ... }
  const linkedContent = linkedQ?.content as Record<string, unknown> | null;

  // Prefer custom_content.override_text, fallback to questions.content.text
  const questionText =
    (customContent?.override_text as string) ??
    (customContent?.text         as string) ??
    (linkedContent?.text         as string) ??
    "Câu hỏi không có nội dung";

  // Choices: prefer custom_content.choices, fallback to question_choices
  // question_choices schema: { id: integer, content: jsonb {text:...}, is_correct: boolean }
  type Choice = { id: number | string; text: string; isCorrect?: boolean; is_correct?: boolean };
  const customChoices = (customContent?.choices ?? customContent?.options) as Choice[] | null;
  type DbChoice = { id: number; content: Record<string, unknown>; is_correct: boolean };
  const linkedChoices = (linkedQ?.question_choices as DbChoice[]) ?? [];

  const choices: Choice[] = customChoices?.length ? customChoices : linkedChoices.map(c => ({
    id: c.id,
    text: (c.content?.text as string) ?? "",
    isCorrect: c.is_correct,
  }));

  const studentAnswer   = ctx.answer as Record<string, unknown> | null;
  const selectedIds     = (studentAnswer?.selected_choice_ids as (number | string)[]) ?? [];
  const correctChoices  = choices.filter(c => c.isCorrect === true || c.is_correct === true);
  // L6 fix: normalize to string to avoid type mismatch (number vs string IDs)
  const selectedStrIds  = selectedIds.map(String);
  const selectedChoices = choices.filter(c => selectedStrIds.includes(String(c.id)));
  // L1 fix: avoid maxPoints=0 making unanswered questions "correct" (0>=0)
  const isCorrect       = maxPoints > 0 && ((ctx.final_score as number) ?? 0) >= maxPoints;

  // Tags from custom_content for subject context
  const tags = (customContent?.tags as string[]) ?? [];
  const tagContext = tags.length ? `Chủ đề: ${tags.join(", ")}.` : "";

  // ─── UPGRADED PROMPT ────────────────────────────────────────────────────────
  const prompt = `Bạn là giáo viên AI đang đánh giá bài làm học sinh. Phân tích câu trả lời này và trả về JSON.

CÂU HỎI: ${questionText}
${tagContext}

CÁC LỰA CHỌN:
${choices.map(c => {
  const correct = c.isCorrect === true || c.is_correct === true;
  return `[${correct ? "ĐÚNG" : "SAI"}] ${c.text}`;
}).join("\n")}

HỌC SINH ĐÃ CHỌN: ${selectedChoices.length ? selectedChoices.map(c => c.text).join(", ") : "Không chọn gì"}
KẾT QUẢ: ${isCorrect ? "ĐÚNG ✓" : "SAI ✗"} (${ctx.final_score ?? 0}/${maxPoints} điểm)

Trả về JSON (không markdown, không giải thích thêm):
{
  "summary": "<1 câu kết luận: học sinh đúng/sai vì lý do cốt lõi>",
  "explanation": "<2-3 câu giải thích tại sao đáp án đúng là đúng, kèm ví dụ hoặc nguyên lý>",
  "misconception": "<Nếu sai: 1-2 câu phân tích lỗi tư duy học sinh có thể mắc phải. Nếu đúng: chuỗi rỗng>",
  "tip": "<1 câu gợi ý học tập hành động cụ thể để củng cố kiến thức này>",
  "encouragement": "<1 câu động viên phù hợp với kết quả: khích lệ nếu sai, khen ngợi nếu đúng>"
}`;

  const rawResponse = await callAiApi(provider, model, apiKey, prompt);

  // Parse JSON from AI response
  const feedback = parseAiFeedbackJson(rawResponse, isCorrect, provider, model);
  feedback.raw = rawResponse.slice(0, 500); // debug truncated

  // D-19: Write structured feedback to submission_answers.ai_feedback
  await supabase
    .from("submission_answers")
    .update({ ai_feedback: feedback })
    .eq("id", item.submission_answer_id);

  console.log(`[AI] Feedback written for answer ${item.submission_answer_id} — isCorrect=${isCorrect}`);

  // L2 fix: return session_id — outer loop calls maybeMarkSessionGraded AFTER
  // status='completed' is written, avoiding the race where current item is still 'processing'.
  return ctx.session_id as string;
}

// ─────────────────────────────────────────────────────────────────────────────
// D-12: Chuyển work_sessions.status → 'graded' khi tất cả feedback hoàn thành
// ─────────────────────────────────────────────────────────────────────────────
// deno-lint-ignore no-explicit-any
async function maybeMarkSessionGraded(supabase: any, sessionId: string) {
  // Lấy toàn bộ submission_answer ids của session
  const { data: answers } = await supabase
    .from("submission_answers")
    .select("id")
    .eq("session_id", sessionId);

  if (!answers || answers.length === 0) return;

  const answerIds = answers.map((a: { id: string }) => a.id);

  // Kiểm tra còn pending/processing feedback nào không
  const { data: stillPending } = await supabase
    .from("ai_queue")
    .select("id")
    .in("submission_answer_id", answerIds)
    .eq("request_type", "feedback")
    .in("status", ["pending", "processing"]);

  if (!stillPending || stillPending.length === 0) {
    // Tất cả feedback xong → chuyển session sang graded
    const { error } = await supabase
      .from("work_sessions")
      .update({ status: "graded", updated_at: new Date().toISOString() })
      .eq("id", sessionId)
      .eq("status", "ai_processing"); // chỉ update nếu đang ở ai_processing
    if (!error) {
      console.log(`[AI] Session ${sessionId}: all feedback complete → status=graded`);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANALYSIS HANDLER: Generate learning recommendations (D-15)
// ─────────────────────────────────────────────────────────────────────────────
// deno-lint-ignore no-explicit-any
async function handleAnalysis(
  supabase: any,
  item: AiQueueItem
) {
  // payload contains session_id set by submitAssignment()
  const sessionId = (item.payload as Record<string, unknown>)?.session_id as string;
  if (!sessionId) {
    console.warn(`[AI] Analysis item ${item.id} missing session_id in payload`);
    return;
  }

  // Get mastery data for this student's submission
  const { data: session, error: sessionError } = await supabase
    .from("work_sessions")
    .select("student_id, assignment_distribution_id")
    .eq("id", sessionId)
    .single();
  if (!session) {
    console.error(`[AI] Session not found: ${sessionId} — ${sessionError?.message}`);
    return;
  }

  // Step 1: Query mastery rows WITHOUT nested join to avoid PostgREST FK resolution issues
  const { data: masteryRows, error: masteryError } = await supabase
    .from("student_skill_mastery")
    .select("objective_id, mastery_level, attempts, correct")
    .eq("student_id", session.student_id)
    .lt("mastery_level", 0.6) // D-14: threshold < 60%
    .order("mastery_level", { ascending: true })
    .limit(5);

  if (masteryError) {
    console.error(`[AI] Mastery query failed for student ${session.student_id}: ${masteryError.message}`);
    throw new Error(`Mastery query failed: ${masteryError.message}`);
  }

  if (!masteryRows || masteryRows.length === 0) {
    console.log(`[AI] No weak skills found for student ${session.student_id} — skipping recommendations`);
    return;
  }

  // Step 2: Fetch learning_objectives separately for the objective_ids found
  const objectiveIds = masteryRows.map((m: Record<string, unknown>) => m.objective_id as string);
  const { data: loRows, error: loError } = await supabase
    .from("learning_objectives")
    .select("id, code, description")
    .in("id", objectiveIds);

  if (loError) {
    console.warn(`[AI] LO fetch failed (non-blocking): ${loError.message}`);
  }
  const loMap: Record<string, { code: string; description: string }> = {};
  for (const lo of loRows ?? []) {
    loMap[lo.id] = { code: lo.code, description: lo.description };
  }

  // Step 3: Insert ai_recommendations
  const now = new Date().toISOString();
  let insertedCount = 0;
  for (const m of masteryRows) {
    const lo = loMap[m.objective_id as string];
    const code = lo?.code ?? `OBJ-${(m.objective_id as string).slice(0, 8)}`;
    const desc = lo?.description ?? "Kỹ năng cần cải thiện";
    const masteryPct = Math.round((m.mastery_level as number) * 100);

    const { error: insertError } = await supabase.from("ai_recommendations").insert({
      student_id: session.student_id,
      type: "individual",
      priority: Math.min(5, Math.max(1, Math.round((1 - (m.mastery_level as number)) * 5))),
      title: `Ôn tập: ${code}`,
      description: `${desc} — tỷ lệ thành thạo ${masteryPct}%, cần cải thiện.`,
      resources: {
        objective_id: m.objective_id,
        mastery_level: m.mastery_level,
        attempts: m.attempts,
        correct_count: m.correct,
        generated_at: now,
        source: "ai_queue_analysis",
      },
      dismissed: false,
      created_at: now,
    });

    if (insertError) {
      console.error(`[AI] Insert recommendation failed for ${m.objective_id}: ${insertError.message}`);
    } else {
      insertedCount++;
    }
  }

  console.log(`[AI] Analysis complete for session ${sessionId} — ${insertedCount}/${masteryRows.length} recommendations inserted`);
}

// ─────────────────────────────────────────────────────────────────────────────
// AI API CALLER
// ─────────────────────────────────────────────────────────────────────────────
async function callAiApi(
  provider: string,
  model: string,
  apiKey: string,
  prompt: string
): Promise<string> {
  if (provider === "gemini") {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
    const resp = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-goog-api-key": apiKey },
      body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
      signal: AbortSignal.timeout(30_000), // P3 fix: prevent hanging AI calls
    });
    if (!resp.ok) throw new Error(`Gemini HTTP ${resp.status}: ${await resp.text()}`);
    const data = await resp.json();
    return data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
  }

  if (provider === "groq") {
    const resp = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: { "Content-Type": "application/json", "Authorization": `Bearer ${apiKey}` },
      body: JSON.stringify({ model, messages: [{ role: "user", content: prompt }], temperature: 0.3 }),
      signal: AbortSignal.timeout(30_000),
    });
    if (!resp.ok) throw new Error(`Groq HTTP ${resp.status}: ${await resp.text()}`);
    const data = await resp.json();
    return data?.choices?.[0]?.message?.content ?? "";
  }

  if (provider === "ollama") {
    const baseUrl = Deno.env.get("OLLAMA_URL") ?? "http://localhost:11434";
    const resp = await fetch(`${baseUrl}/api/generate`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ model, prompt, stream: false }),
      signal: AbortSignal.timeout(30_000),
    });
    if (!resp.ok) throw new Error(`Ollama HTTP ${resp.status}: ${await resp.text()}`);
    const data = await resp.json();
    return data?.response ?? "";
  }

  throw new Error(`Unknown provider: ${provider}`);
}

// ─────────────────────────────────────────────────────────────────────────────
// PARSE AI JSON RESPONSE
// ─────────────────────────────────────────────────────────────────────────────
function parseAiFeedbackJson(
  raw: string,
  isCorrect: boolean,
  provider: string,
  model: string
): AiFeedback {
  const base: AiFeedback = {
    status: "completed",
    provider,
    model,
    is_correct: isCorrect,
    summary: "",
    explanation: "",
    misconception: "",
    tip: "",
    encouragement: "",
  };

  try {
    // Strip markdown code fences if any
    const cleaned = raw.replace(/```json\s*/gi, "").replace(/```\s*/g, "").trim();
    const parsed  = JSON.parse(cleaned) as Partial<AiFeedback>;
    return {
      ...base,
      summary:       parsed.summary       ?? "",
      explanation:   parsed.explanation   ?? "",
      misconception: parsed.misconception ?? "",
      tip:           parsed.tip           ?? "",
      encouragement: parsed.encouragement ?? "",
    };
  } catch {
    // Fallback: store raw as summary if JSON parsing fails
    console.warn("[AI] Could not parse JSON response, storing raw as summary");
    return { ...base, summary: raw.slice(0, 800) };
  }
}
