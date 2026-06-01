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

/** Kết quả AI chấm điểm tự luận (Phase 3) — ghi vào submission_answers + ai_evaluations */
interface AiScoreResult {
  status: "completed" | "no_api_key" | "failed";
  provider: string;
  model: string;
  score: number;        // đã clamp [0, maxPoints]
  confidence: number;   // [0, 1]
  summary: string;
  explanation: string;
  strengths: string;
  improvements: string;
  criteria?: unknown[];  // mảng tiêu chí (giờ 1 phần tử "Nội dung chung"; mở để nâng cấp rubric)
  raw?: string;
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
      // Claim-row nguyên tử: chỉ xử lý nếu giành được transition pending→processing.
      // Tránh race khi 2 invocation (webhook + nút scan) cùng SELECT trúng 1 dòng pending.
      // Rẻ hơn pg_advisory_xact_lock và không ghim DB connection xuyên cuộc gọi AI ~30s.
      const { data: claimed } = await supabase
        .from("ai_queue")
        .update({ status: "processing", attempts: dispatchedAttempts, updated_at: new Date().toISOString() })
        .eq("id", item.id)
        .eq("status", "pending")
        .select("id");
      if (!claimed || claimed.length === 0) {
        // Invocation khác đã claim dòng này — bỏ qua, không xử lý trùng.
        continue;
      }

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
          // Phase 3: AI tự chấm điểm tự luận (essay/short_answer).
          // Trả về session_id để outer loop gọi maybeMarkSessionGraded; null = đã defer
          // (loại ngoài phạm vi như math/problem_solving) → không mark completed.
          const scoreSession = await handleScore(supabase, item);
          if (scoreSession === null) {
            markCompleted = false;
          } else {
            itemSessionId = scoreSession;
          }
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
  // Nguồn chân lý DUY NHẤT cho cú chuyển status nằm ở SQL RPC maybe_mark_session_graded
  // (migration 036) — dùng chung với đường GV duyệt phía Dart để logic không bị lệch.
  const { error } = await supabase.rpc("maybe_mark_session_graded", { p_session_id: sessionId });
  if (error) console.error(`[AI] maybe_mark_session_graded failed for ${sessionId}: ${error.message}`);
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

  // 5a-R1: resolve teacher_id + class_id để teacher đọc được recommendation
  //        (RLS qual teacher_id=auth.uid()). Mẫu giống handleFeedback.
  //        class_id nullable cho distribution_type='group' → chấp nhận null.
  const { data: dist } = await supabase
    .from("assignment_distributions")
    .select("class_id, assignments!inner(teacher_id)")
    .eq("id", session.assignment_distribution_id)
    .single();
  const teacherId =
    ((dist?.assignments as Record<string, unknown>)?.teacher_id as string | null) ?? null;
  const classId = (dist?.class_id as string | null) ?? null;

  // 5a-Q4: tên HS cho title REC-01 (teacher-facing). Fallback "Học sinh" nếu chưa có full_name.
  const { data: studentProfile } = await supabase
    .from("profiles")
    .select("full_name")
    .eq("id", session.student_id)
    .single();
  const studentName = (studentProfile?.full_name as string | null) ?? "Học sinh";

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

    const resources = {
      objective_id: m.objective_id,
      mastery_level: m.mastery_level,
      attempts: m.attempts,
      correct_count: m.correct,
      generated_at: now,
      source: "ai_queue_analysis",
    };

    // 5a-R2 / REC-02 (HỌC SINH): gợi ý "Ôn tập" study_tip. student-only (KHÔNG set teacher_id)
    //   để tách audience (Q4). onConflict (student_id, objective_id). BỎ dismissed/created_at
    //   (ON CONFLICT DO UPDATE chỉ set cột gửi → rec đã ẩn không sống lại; default lo insert).
    const { error: studentErr } = await supabase.from("ai_recommendations").upsert(
      {
        student_id: session.student_id,
        objective_id: m.objective_id,
        type: "individual",
        category: "study_tip",
        priority: Math.min(5, Math.max(1, Math.round((1 - (m.mastery_level as number)) * 5))),
        title: `Ôn tập: ${code}`,
        description: `${desc} — tỷ lệ thành thạo ${masteryPct}%, cần cải thiện.`,
        resources,
      },
      { onConflict: "student_id,objective_id", ignoreDuplicates: false },
    );
    if (studentErr) {
      console.error(`[AI] Student rec upsert failed for ${m.objective_id}: ${studentErr.message}`);
    } else {
      insertedCount++;
    }

    // 5a-Q3/Q4 / REC-01 (GIÁO VIÊN): cảnh báo can thiệp. teacher-facing, student_id NULL +
    //   subject_student_id = HS (chống rò RLS: students_read = student_id=auth.uid() → HS không
    //   đọc được dòng student_id NULL). category at_risk_warning nếu mastery < 0.3, ngược lại
    //   intervention (rule-based, KHÔNG LLM). onConflict (teacher_id, subject_student_id, objective_id).
    if (teacherId) {
      const isAtRisk = (m.mastery_level as number) < 0.3;
      const { error: teacherErr } = await supabase.from("ai_recommendations").upsert(
        {
          teacher_id: teacherId,
          class_id: classId,
          subject_student_id: session.student_id,
          objective_id: m.objective_id,
          type: "individual",
          category: isAtRisk ? "at_risk_warning" : "intervention",
          priority: isAtRisk
            ? 1
            : Math.min(5, Math.max(2, Math.round((1 - (m.mastery_level as number)) * 5))),
          title: isAtRisk
            ? `Cảnh báo: ${studentName} — ${code}`
            : `Cần hỗ trợ: ${studentName} — ${code}`,
          description: `${studentName} đạt ${masteryPct}% ở "${desc}"${
            isAtRisk ? " — mức rủi ro, nên can thiệp sớm." : " — nên ôn thêm."
          }`,
          resources,
        },
        { onConflict: "teacher_id,subject_student_id,objective_id", ignoreDuplicates: false },
      );
      if (teacherErr) {
        console.error(`[AI] Teacher rec upsert failed for ${m.objective_id}: ${teacherErr.message}`);
      } else {
        insertedCount++;
      }
    }
  }

  console.log(`[AI] Analysis complete for session ${sessionId} — ${insertedCount}/${masteryRows.length} recommendations inserted`);
}

// ─────────────────────────────────────────────────────────────────────────────
// SCORE HANDLER (Phase 3): AI tự chấm điểm tự luận essay/short_answer
// ─────────────────────────────────────────────────────────────────────────────
// deno-lint-ignore no-explicit-any
async function handleScore(supabase: any, item: AiQueueItem): Promise<string | null> {
  // 1) Context: bài làm + câu hỏi (custom_content cho inline; questions cho bank-linked)
  const { data: ctx, error } = await supabase
    .from("submission_answers")
    .select(`
      id, answer, ai_score, session_id,
      assignment_questions!inner (
        points, custom_content, question_id, rubric,
        questions!left ( content, answer, type )
      )
    `)
    .eq("id", item.submission_answer_id)
    .single();

  if (error || !ctx) {
    throw new Error(`Answer not found for score: ${item.submission_answer_id} — ${error?.message ?? "null ctx"}`);
  }

  // 2) Idempotency: đã có ai_score → bỏ qua (không gọi AI lại, tiết kiệm token khi "Quét lại")
  if (ctx.ai_score !== null && ctx.ai_score !== undefined) {
    console.log(`[AI] Score already exists for ${item.submission_answer_id} — skip`);
    return ctx.session_id as string;
  }

  const aq            = ctx.assignment_questions as Record<string, unknown>;
  const customContent = (aq.custom_content as Record<string, unknown>) ?? {};
  const linkedQ       = (aq.questions as Record<string, unknown>) ?? {};
  const maxPoints     = (aq.points as number) ?? 1;

  // 3) Phase 3 chỉ chấm essay/short_answer. Loại khác (math/problem_solving) → defer cho phase sau.
  const qType = (customContent.type as string) ?? (linkedQ.type as string) ?? "essay";
  if (qType !== "essay" && qType !== "short_answer") {
    console.log(`[AI] Score type "${qType}" out of scope → deferred: ${item.id}`);
    await supabase
      .from("ai_queue")
      .update({ status: "deferred", updated_at: new Date().toISOString() })
      .eq("id", item.id);
    return null; // báo outer loop KHÔNG mark completed
  }

  // 4) Nội dung câu hỏi + đáp án mẫu + từ khoá (ưu tiên custom_content, fallback questions)
  const linkedContent = (linkedQ.content as Record<string, unknown>) ?? null;
  const linkedAnswer  = (linkedQ.answer as Record<string, unknown>) ?? null;
  const questionText =
    (customContent.override_text as string) ??
    (customContent.text as string) ??
    (linkedContent?.text as string) ??
    "Câu hỏi không có nội dung";
  const expectedAnswer =
    (customContent.expected_answer as string) ??
    (linkedAnswer?.expected_answer as string) ??
    (linkedAnswer?.sample_response as string) ??
    "";
  type Kw = { keyword?: string; weight?: number };
  const keywords =
    (customContent.ai_grading_keywords as Kw[]) ??
    (linkedAnswer?.ai_grading_keywords as Kw[]) ??
    [];

  // 5) Bài làm học sinh (text)
  const studentAns  = (ctx.answer as Record<string, unknown>) ?? {};
  const studentText = ((studentAns.text as string) ?? "").trim();

  // 6) Teacher API key + cờ ai_require_review
  const cfg = await resolveTeacherAiConfig(supabase, ctx.session_id as string);
  if (!cfg.apiKey) {
    console.warn(`[AI] No API key for score — session ${ctx.session_id}`);
    await supabase.from("submission_answers").update({
      ai_feedback: {
        status: "no_api_key", provider: cfg.provider, model: cfg.model,
        summary: "Giáo viên chưa cấu hình API key cho AI chấm điểm.",
        explanation: "", strengths: "", improvements: "",
      },
    }).eq("id", item.submission_answer_id);
    return ctx.session_id as string; // final_score để NULL → GV chấm tay
  }

  // 7) Bài làm rỗng → 0 điểm, không cần gọi AI
  if (!studentText) {
    await writeScore(supabase, item.submission_answer_id, ctx.session_id as string, {
      status: "completed", provider: cfg.provider, model: cfg.model,
      score: 0, confidence: 1,
      summary: "Học sinh không trả lời câu này.",
      explanation: "", strengths: "", improvements: "Cần trả lời câu hỏi.",
    }, maxPoints, cfg.requireReview);
    return ctx.session_id as string;
  }

  // 8) Prompt chấm công bằng — nạp rubric (tiêu chí GV thiết lập) + đáp án mẫu + từ khoá.
  //    Hard cap maxPoints vẫn được parseAiScoreJson clamp lại.
  const kwLines = keywords.length
    ? keywords.map((k) => `- "${k.keyword ?? ""}" (trọng số ${k.weight ?? 0})`).join("\n")
    : "(không có từ khoá)";

  // Rubric do GV thiết lập (cột assignment_questions.rubric). Trước đây KHÔNG được tiêu thụ →
  //   AI mất mốc chuẩn, sinh thói chấm chặt. Nay nhúng đầy đủ tiêu chí + mức điểm vào prompt.
  type RubricLevel = { points?: number; description?: string };
  type RubricCriterion = { name?: string; max_points?: number; levels?: RubricLevel[] };
  const rubric = (aq.rubric as { criteria?: RubricCriterion[] } | null) ?? null;
  const rubricBlock = (rubric?.criteria?.length ?? 0) > 0
    ? `TIÊU CHÍ CHẤM (RUBRIC do giáo viên thiết lập — chấm BÁM SÁT theo đây):\n${
        rubric!.criteria!.map((c) => {
          const levels = (c.levels ?? [])
            .map((l) => `    • ${l.points ?? 0}đ: ${l.description ?? ""}`)
            .join("\n");
          return `- ${c.name ?? "Tiêu chí"} (tối đa ${c.max_points ?? maxPoints}đ):\n${levels}`;
        }).join("\n")
      }`
    : "TIÊU CHÍ CHẤM: (giáo viên chưa thiết lập rubric — chấm theo đáp án mẫu/độ chính xác và đầy đủ).";

  const prompt = `Bạn là giáo viên chấm bài tự luận CÔNG BẰNG và nhất quán. Chấm câu trả lời của học sinh và trả về JSON.

THANG ĐIỂM: 0..${maxPoints} điểm (không vượt quá ${maxPoints}).

CÂU HỎI: ${questionText}

${rubricBlock}

ĐÁP ÁN MẪU: ${expectedAnswer || "(không có đáp án mẫu cố định — bám theo rubric/độ chính xác và đầy đủ)"}

TỪ KHOÁ TRỌNG TÂM (có trọng số):
${kwLines}

BÀI LÀM CỦA HỌC SINH:
${studentText}

NGUYÊN TẮC CHẤM (BẮT BUỘC tuân thủ):
1. Nếu bài làm ĐÁP ỨNG ĐẦY ĐỦ yêu cầu của rubric/đáp án mẫu thì PHẢI cho điểm TỐI ĐA ${maxPoints}. KHÔNG được trừ điểm chỉ vì "có thể chi tiết/hay hơn".
2. CHỈ trừ điểm khi chỉ ra được THIẾU SÓT CỤ THỂ: ý sai, hoặc thiếu một ý BẮT BUỘC theo rubric. Mỗi lần trừ điểm phải nêu rõ thiếu ý gì trong "improvements".
3. Ý mở rộng/nâng cao NẰM NGOÀI rubric thì KHÔNG dùng để trừ điểm (chỉ ghi như gợi ý tùy chọn).
4. Điểm số PHẢI nhất quán với nhận xét: nếu kết luận "chính xác và đầy đủ" thì điểm = ${maxPoints}; nếu cho điểm < ${maxPoints} thì "improvements" PHẢI nêu được lỗi/ý thiếu cụ thể.

Suy nghĩ theo các bước: (1) đối chiếu bài làm với từng tiêu chí rubric/đáp án mẫu; (2) liệt kê ý ĐẠT và ý BẮT BUỘC còn THIẾU (nếu có); (3) quyết định điểm — đủ ý bắt buộc → ${maxPoints}; chỉ trừ theo ý thiếu cụ thể.
Trả về JSON (không markdown, không chữ thừa):
{
  "score": <số điểm 0..${maxPoints}>,
  "confidence": <độ tin cậy 0..1>,
  "summary": "<1 câu kết luận điểm và lý do cốt lõi, nhất quán với điểm>",
  "explanation": "<2-3 câu giải thích vì sao điểm đó, đối chiếu rubric/đáp án mẫu>",
  "strengths": "<điểm tốt trong bài làm>",
  "improvements": "<nếu điểm < tối đa: nêu RÕ ý bắt buộc còn thiếu; nếu đạt tối đa: gợi ý mở rộng tùy chọn hoặc chuỗi rỗng>",
  "criteria": [ { "name": "Nội dung chung", "score": <0..${maxPoints}>, "max": ${maxPoints}, "comment": "<nhận xét>" } ]
}`;

  const raw    = await callAiApi(cfg.provider, cfg.model, cfg.apiKey, prompt, true);
  const parsed = parseAiScoreJson(raw, maxPoints, cfg.provider, cfg.model);
  parsed.raw   = raw.slice(0, 500);

  await writeScore(supabase, item.submission_answer_id, ctx.session_id as string, parsed, maxPoints, cfg.requireReview);
  console.log(`[AI] Scored answer ${item.submission_answer_id}: ${parsed.score}/${maxPoints} conf=${parsed.confidence} review=${cfg.requireReview}`);
  return ctx.session_id as string;
}

/** Lấy provider/model/apiKey của giáo viên + cờ ai_require_review của distribution */
// deno-lint-ignore no-explicit-any
async function resolveTeacherAiConfig(
  supabase: any,
  sessionId: string,
): Promise<{ provider: string; model: string; apiKey?: string; requireReview: boolean }> {
  const { data: session } = await supabase
    .from("work_sessions")
    .select("assignment_distribution_id")
    .eq("id", sessionId)
    .single();

  const { data: dist } = await supabase
    .from("assignment_distributions")
    .select("settings, assignments!inner(teacher_id)")
    .eq("id", session?.assignment_distribution_id)
    .single();

  const settings = (dist?.settings as Record<string, unknown>) ?? {};
  // Default true = Human-in-the-loop (an toàn). Chỉ auto-publish khi GV chủ động tắt.
  const requireReview = settings.ai_require_review === false ? false : true;

  const teacherId = (dist?.assignments as Record<string, unknown>)?.teacher_id as string;
  const { data: profile } = await supabase.from("profiles").select("metadata").eq("id", teacherId).single();
  const meta      = profile?.metadata as Record<string, unknown> | null;
  const analytics = meta?.analytics   as Record<string, string>  | null;
  const apiKeys   = meta?.api_keys    as Record<string, string>  | null;
  const provider  = analytics?.provider ?? "gemini";
  const model     = analytics?.model    ?? "gemini-2.0-flash";
  return { provider, model, apiKey: apiKeys?.[provider], requireReview };
}

/** Ghi điểm AI vào submission_answers + ai_evaluations; auto-publish nếu !requireReview */
// deno-lint-ignore no-explicit-any
async function writeScore(
  supabase: any,
  answerId: string,
  sessionId: string,
  r: AiScoreResult,
  maxPoints: number,
  requireReview: boolean,
): Promise<void> {
  const now = new Date().toISOString();

  const update: Record<string, unknown> = {
    ai_score: r.score,
    ai_confidence: r.confidence,
    ai_feedback: {
      status: r.status, provider: r.provider, model: r.model,
      summary: r.summary, explanation: r.explanation,
      strengths: r.strengths, improvements: r.improvements,
    },
    updated_at: now,
  };
  // Auto-publish CHỈ khi GV tắt review VÀ AI đủ tự tin (>=0.7). Confidence thấp / parse-fail
  // (fallback conf 0.2) → giữ final_score NULL → maybe_mark đẩy pending_review để GV duyệt,
  // tránh công bố điểm oan (vd model yếu trả prose → score=0). graded_by để NULL = AI chấm.
  const autoPublish = !requireReview && r.status === "completed" && r.confidence >= 0.7;
  if (autoPublish) {
    update.final_score = r.score;
    update.graded_at   = now;
  }
  await supabase.from("submission_answers").update(update).eq("id", answerId);

  // Lịch sử chấm AI (hồi sinh ai_evaluations). rationale đóng khung dạng mảng criteria.
  await supabase.from("ai_evaluations").insert({
    submission_answer_id: answerId,
    model_name: r.provider,
    model_version: r.model,
    ai_score: r.score,
    ai_confidence: r.confidence,
    feedback: r.summary,
    rationale: {
      criteria: (Array.isArray(r.criteria) && r.criteria.length)
        ? r.criteria
        : [{ name: "Nội dung chung", score: r.score, max: maxPoints, comment: r.explanation }],
    },
  });

  if (autoPublish) {
    // Auto-publish → tính lại tổng điểm submission để chảy vào sổ điểm.
    await supabase.rpc("recompute_submission_total", { p_session_id: sessionId });
  }
}

/** Parse JSON điểm từ AI — clamp nghiêm, output rác → 0 điểm + confidence thấp (chờ duyệt) */
function parseAiScoreJson(raw: string, maxPoints: number, provider: string, model: string): AiScoreResult {
  const base: AiScoreResult = {
    status: "completed", provider, model,
    score: 0, confidence: 0.3,
    summary: "", explanation: "", strengths: "", improvements: "", criteria: [],
  };
  try {
    const cleaned = raw.replace(/```json\s*/gi, "").replace(/```\s*/g, "").trim();
    const p = JSON.parse(cleaned) as Record<string, unknown>;

    const rawScore = Number(p.score);
    const scoreValid = Number.isFinite(rawScore);
    const score = scoreValid ? Math.max(0, Math.min(maxPoints, rawScore)) : 0;

    let conf = Number(p.confidence);
    if (!Number.isFinite(conf)) conf = 0.3;
    conf = Math.max(0, Math.min(1, conf));
    // Score rác → ép confidence thấp để buộc GV duyệt
    if (!scoreValid) conf = Math.min(conf, 0.3);

    return {
      ...base,
      score,
      confidence: conf,
      summary:      (p.summary as string)      ?? "",
      explanation:  (p.explanation as string)  ?? "",
      strengths:    (p.strengths as string)    ?? "",
      improvements: (p.improvements as string) ?? "",
      criteria: Array.isArray(p.criteria)
        ? (p.criteria as unknown[])
        : [{ name: "Nội dung chung", score, max: maxPoints, comment: (p.explanation as string) ?? "" }],
    };
  } catch {
    console.warn("[AI] Could not parse score JSON — fallback score=0, low confidence (chờ GV duyệt)");
    return { ...base, summary: raw.slice(0, 300), confidence: 0.2 };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI API CALLER
// ─────────────────────────────────────────────────────────────────────────────
async function callAiApi(
  provider: string,
  model: string,
  apiKey: string,
  prompt: string,
  jsonMode = false, // Phase 3: ép model trả JSON thuần (chỉ handleScore bật; feedback giữ nguyên)
): Promise<string> {
  if (provider === "gemini") {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
    const reqBody: Record<string, unknown> = { contents: [{ parts: [{ text: prompt }] }] };
    if (jsonMode) reqBody.generationConfig = { responseMimeType: "application/json" };
    const resp = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-goog-api-key": apiKey },
      body: JSON.stringify(reqBody),
      signal: AbortSignal.timeout(30_000), // P3 fix: prevent hanging AI calls
    });
    if (!resp.ok) throw new Error(`Gemini HTTP ${resp.status}: ${await resp.text()}`);
    const data = await resp.json();
    return data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
  }

  if (provider === "groq") {
    const reqBody: Record<string, unknown> = { model, messages: [{ role: "user", content: prompt }], temperature: 0.3 };
    if (jsonMode) reqBody.response_format = { type: "json_object" };
    const resp = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: { "Content-Type": "application/json", "Authorization": `Bearer ${apiKey}` },
      body: JSON.stringify(reqBody),
      signal: AbortSignal.timeout(30_000),
    });
    if (!resp.ok) throw new Error(`Groq HTTP ${resp.status}: ${await resp.text()}`);
    const data = await resp.json();
    return data?.choices?.[0]?.message?.content ?? "";
  }

  if (provider === "ollama") {
    const baseUrl = Deno.env.get("OLLAMA_URL") ?? "http://localhost:11434";
    const reqBody: Record<string, unknown> = { model, prompt, stream: false };
    if (jsonMode) reqBody.format = "json";
    const resp = await fetch(`${baseUrl}/api/generate`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(reqBody),
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
