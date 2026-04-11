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

    const submissionId = body.submission_id as string | undefined;
    const retroactive  = body.retroactive  as boolean | undefined;

    let query = supabase
      .from("ai_queue")
      .select("*")
      .eq("status", "pending")
      .order("created_at")
      .limit(10);

    if (submissionId && retroactive) {
      const { data: answerIds } = await supabase
        .from("submission_answers")
        .select("id")
        .eq("session_id", submissionId);
      if (answerIds && answerIds.length > 0) {
        query = query.in("submission_answer_id", answerIds.map((a: { id: string }) => a.id));
      }
    }

    const { data: items, error: fetchError } = await query;
    if (fetchError) {
      console.error("Failed to fetch ai_queue:", fetchError);
      return new Response(JSON.stringify({ error: fetchError.message }), { status: 500 });
    }

    let processed = 0;
    for (const item of (items as AiQueueItem[]) ?? []) {
      await supabase
        .from("ai_queue")
        .update({ status: "processing", attempts: item.attempts + 1, updated_at: new Date().toISOString() })
        .eq("id", item.id);

      try {
        if (item.request_type === "feedback") {
          await handleFeedback(supabase, item);
        } else if (item.request_type === "analysis") {
          await handleAnalysis(supabase, item);
        } else if (item.request_type === "score") {
          // STUB: Essay scoring deferred until Phase 3 re-enable
          console.log(`[STUB] Score request deferred: ${item.id}`);
        }

        await supabase
          .from("ai_queue")
          .update({ status: "completed", updated_at: new Date().toISOString() })
          .eq("id", item.id);
        processed++;
      } catch (error) {
        console.error(`[AI] Failed to process item ${item.id}:`, error);
        const newAttempts = item.attempts + 1;
        await supabase
          .from("ai_queue")
          .update({
            status: newAttempts >= 3 ? "failed" : "pending",
            updated_at: new Date().toISOString(),
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
) {
  // D-21: Fetch submission_answer + question context
  const { data: ctx, error } = await supabase
    .from("submission_answers")
    .select(`
      id, answer, final_score, session_id,
      assignment_question_id,
      assignment_questions!inner (
        points,
        custom_content,
        question_id,
        questions (
          question_text,
          question_choices ( id, choice_text, is_correct )
        )
      )
    `)
    .eq("id", item.submission_answer_id)
    .single();

  if (error || !ctx) throw new Error(`Answer not found: ${item.submission_answer_id}`);

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
    return;
  }

  // Build context for prompt
  const aq           = ctx.assignment_questions as Record<string, unknown>;
  const customContent = aq.custom_content as Record<string, unknown> | null;
  const linkedQ      = aq.questions as Record<string, unknown> | null;
  const maxPoints    = aq.points as number ?? 1;

  // Prefer custom_content.override_text, fallback to questions.question_text
  const questionText =
    (customContent?.override_text as string) ??
    (customContent?.text         as string) ??
    (linkedQ?.question_text      as string) ??
    "Câu hỏi không có nội dung";

  // Choices: prefer custom_content.choices, fallback to question_choices
  type Choice = { id: number | string; text: string; isCorrect?: boolean; is_correct?: boolean };
  const customChoices = (customContent?.choices ?? customContent?.options) as Choice[] | null;
  const linkedChoices = (linkedQ?.question_choices as Choice[]) ?? [];

  const choices: Choice[] = customChoices?.length ? customChoices : linkedChoices.map(c => ({
    id: c.id,
    text: (c as Record<string, unknown>).choice_text as string,
    isCorrect: c.is_correct,
  }));

  const studentAnswer   = ctx.answer as Record<string, unknown> | null;
  const selectedIds     = (studentAnswer?.selected_choice_ids as (number | string)[]) ?? [];
  const correctChoices  = choices.filter(c => c.isCorrect === true || c.is_correct === true);
  const selectedChoices = choices.filter(c => selectedIds.includes(c.id as number));
  const isCorrect       = (ctx.final_score as number ?? 0) >= maxPoints;

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

  // D-12: Sau khi ghi feedback, check nếu tất cả feedback của session đã xong → graded
  await maybeMarkSessionGraded(supabase, ctx.session_id as string);
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
  const { data: session } = await supabase
    .from("work_sessions")
    .select("student_id, assignment_distribution_id")
    .eq("id", sessionId)
    .single();
  if (!session) return;

  const { data: masteryRows } = await supabase
    .from("student_skill_mastery")
    .select("learning_objective_id, mastery_level, attempts, correct_count")
    .eq("student_id", session.student_id)
    .lt("mastery_level", 0.6) // D-14: threshold
    .order("mastery_level", { ascending: true })
    .limit(5);

  if (!masteryRows || masteryRows.length === 0) return;

  // Insert ai_recommendations for student (D-14)
  const now = new Date().toISOString();
  for (const m of masteryRows) {
    await supabase.from("ai_recommendations").upsert({
      student_id: session.student_id,
      learning_objective_id: m.learning_objective_id,
      recommendation_type: "review",
      priority: Math.round((1 - (m.mastery_level as number)) * 10),
      metadata: {
        mastery_level: m.mastery_level,
        attempts: m.attempts,
        correct_count: m.correct_count,
        generated_at: now,
        source: "ai_queue_analysis",
      },
      created_at: now,
      updated_at: now,
    }, { onConflict: "student_id,learning_objective_id" });
  }

  console.log(`[AI] Analysis complete for session ${sessionId} — ${masteryRows.length} recommendations`);
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
