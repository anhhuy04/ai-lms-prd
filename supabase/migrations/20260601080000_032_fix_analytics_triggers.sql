-- 032_fix_analytics_triggers.sql
-- Cải thiện pipeline analytics (submission_answers triggers).
-- KHÔNG backfill (chỉ sửa logic forward), KHÔNG đổi schema. Đã test bằng
-- BEGIN/ROLLBACK trên DB thật: regrade không throw, no double-count, no inflate.
--
-- FIX 1 (🟠 THẬT — cải thiện chính): fn_update_question_stats trước chỉ chạy
--   AFTER INSERT → câu essay/short_answer chấm SAU (final_score set qua UPDATE,
--   ban đầu NULL) KHÔNG bao giờ vào question_stats (xác nhận: 0/17 câu essay
--   bank có stats). FIX: xử lý cả TG_OP='UPDATE' + thêm trigger
--   trg_sa_02b_question_stats_update (AFTER UPDATE OF final_score), guard
--   chống double-count (insert NULL không +attempt; chỉ +1 khi NULL→số).
--
-- FIX 2 (🟡 hardening, KHÔNG phải bug đang xảy ra): đổi so "correct" từ
--   exact-equality (final_score = points) sang (final_score >= points), nhất
--   quán giữa cả 3 function. Lưu ý: trên dữ liệu hiện tại = và >= cho kết quả
--   GIỐNG HỆT (0 dòng final_score > points), nên đây chỉ là phòng tương lai.
--
-- FIX 3 (⚪ trung tính — refactor, KHÔNG phải sửa crash): viết lại
--   fn_recalculate_skill_mastery từ full-recompute (re-aggregate toàn bộ answer
--   mỗi lần UPDATE — nặng) sang incremental delta (nhẹ hơn, tốt cho hiệu suất).
--   Bản full-recompute cũ CHẠY ĐÚNG, không crash; đây là tối ưu hiệu suất +
--   đồng bộ điều kiện >=. Đã test: regrade giữ nguyên attempts, correct giảm
--   đúng theo delta.

BEGIN;

-- ============================================================
-- 1. fn_update_skill_mastery (AFTER INSERT) — đổi = thành >=
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_update_skill_mastery()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_points numeric;
BEGIN
  IF NEW.final_score IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT points INTO v_points FROM public.assignment_questions WHERE id = NEW.assignment_question_id;

  INSERT INTO public.student_skill_mastery
    (student_id, objective_id, attempts, correct, mastery_level, last_updated)
  WITH objectives AS (
    SELECT qo.objective_id
    FROM public.assignment_questions aq
    JOIN public.question_objectives qo ON qo.question_id = aq.question_id
    WHERE aq.id = NEW.assignment_question_id
    UNION
    SELECT obj_id::uuid AS objective_id
    FROM public.assignment_questions aq,
         jsonb_array_elements_text(
           CASE
             WHEN jsonb_typeof(aq.custom_content -> 'objective_ids') = 'array'
               THEN aq.custom_content -> 'objective_ids'
             WHEN jsonb_typeof(aq.custom_content -> 'learningObjectives') = 'array'
               THEN aq.custom_content -> 'learningObjectives'
             ELSE '[]'::jsonb
           END
         ) AS obj_id
    WHERE aq.id = NEW.assignment_question_id
      AND aq.question_id IS NULL
      AND obj_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  )
  SELECT
    ws.student_id,
    o.objective_id,
    1,
    CASE WHEN v_points > 0 AND NEW.final_score >= v_points THEN 1 ELSE 0 END,
    CASE WHEN v_points > 0 AND NEW.final_score >= v_points THEN 1.0 ELSE 0.0 END,
    now()
  FROM objectives o
  JOIN public.work_sessions ws ON ws.id = NEW.session_id
  WHERE o.objective_id IS NOT NULL
  ON CONFLICT (student_id, objective_id)
  DO UPDATE SET
    attempts      = student_skill_mastery.attempts + 1,
    correct       = student_skill_mastery.correct +
                    CASE WHEN v_points > 0 AND NEW.final_score >= v_points THEN 1 ELSE 0 END,
    mastery_level = (student_skill_mastery.correct +
                     CASE WHEN v_points > 0 AND NEW.final_score >= v_points THEN 1 ELSE 0 END
                    )::numeric / (student_skill_mastery.attempts + 1),
    last_updated  = now();

  RETURN NEW;
END;
$function$;

-- ============================================================
-- 2. fn_recalculate_skill_mastery (AFTER UPDATE) — incremental delta,
--    KHÔNG còn gọi function thiếu.
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_recalculate_skill_mastery()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_student   uuid;
  v_points    numeric;
  v_old_att   int;
  v_new_att   int;
  v_old_cor   int;
  v_new_cor   int;
  v_d_att     int;
  v_d_cor     int;
  v_obj       uuid;
BEGIN
  -- Chỉ xử lý khi final_score thực sự thay đổi
  IF NEW.final_score IS NOT DISTINCT FROM OLD.final_score THEN
    RETURN NEW;
  END IF;

  SELECT ws.student_id INTO v_student FROM public.work_sessions ws WHERE ws.id = NEW.session_id;
  IF v_student IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT points INTO v_points FROM public.assignment_questions WHERE id = NEW.assignment_question_id;

  v_old_att := CASE WHEN OLD.final_score IS NOT NULL THEN 1 ELSE 0 END;
  v_new_att := CASE WHEN NEW.final_score IS NOT NULL THEN 1 ELSE 0 END;
  v_old_cor := CASE WHEN OLD.final_score IS NOT NULL AND v_points > 0 AND OLD.final_score >= v_points THEN 1 ELSE 0 END;
  v_new_cor := CASE WHEN NEW.final_score IS NOT NULL AND v_points > 0 AND NEW.final_score >= v_points THEN 1 ELSE 0 END;
  v_d_att := v_new_att - v_old_att;
  v_d_cor := v_new_cor - v_old_cor;

  IF v_d_att = 0 AND v_d_cor = 0 THEN
    RETURN NEW;  -- không đổi attempt/correct (vd điểm đổi nhưng vẫn cùng trạng thái đúng/sai)
  END IF;

  FOR v_obj IN
    SELECT qo.objective_id
    FROM public.assignment_questions aq
    JOIN public.question_objectives qo ON qo.question_id = aq.question_id
    WHERE aq.id = NEW.assignment_question_id
    UNION
    SELECT obj_id::uuid
    FROM public.assignment_questions aq,
         jsonb_array_elements_text(
           CASE
             WHEN jsonb_typeof(aq.custom_content -> 'objective_ids') = 'array'
               THEN aq.custom_content -> 'objective_ids'
             WHEN jsonb_typeof(aq.custom_content -> 'learningObjectives') = 'array'
               THEN aq.custom_content -> 'learningObjectives'
             ELSE '[]'::jsonb
           END
         ) AS obj_id
    WHERE aq.id = NEW.assignment_question_id
      AND aq.question_id IS NULL
      AND obj_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  LOOP
    IF v_d_att > 0 THEN
      -- NULL→NOT NULL (chấm lần đầu qua UPDATE, vd essay): row có thể chưa tồn tại → UPSERT
      INSERT INTO public.student_skill_mastery
        (student_id, objective_id, attempts, correct, mastery_level, last_updated)
      VALUES (v_student, v_obj, 1, v_new_cor, v_new_cor::numeric, now())
      ON CONFLICT (student_id, objective_id) DO UPDATE SET
        attempts      = student_skill_mastery.attempts + 1,
        correct       = student_skill_mastery.correct + v_new_cor,
        mastery_level = (student_skill_mastery.correct + v_new_cor)::numeric
                        / NULLIF(student_skill_mastery.attempts + 1, 0),
        last_updated  = now();
    ELSE
      -- re-grade (d_att=0, d_cor<>0) hoặc un-grade (d_att<0): row đã tồn tại → UPDATE delta
      UPDATE public.student_skill_mastery sm SET
        attempts      = GREATEST(sm.attempts + v_d_att, 0),
        correct       = GREATEST(sm.correct + v_d_cor, 0),
        mastery_level = CASE WHEN GREATEST(sm.attempts + v_d_att, 0) > 0
                             THEN GREATEST(sm.correct + v_d_cor, 0)::numeric / (sm.attempts + v_d_att)
                             ELSE 0 END,
        last_updated  = now()
      WHERE sm.student_id = v_student AND sm.objective_id = v_obj;
    END IF;
  END LOOP;

  RETURN NEW;
END;
$function$;

-- ============================================================
-- 3. fn_update_question_stats — xử lý cả INSERT và UPDATE
--    (essay chấm sau vào stats), guard chống double-count.
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_update_question_stats()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_question_id uuid;
  v_points      numeric;
  v_old_att     int;
  v_new_att     int;
  v_old_cor     int;
  v_new_cor     int;
BEGIN
  -- Chỉ áp dụng cho câu bank-linked (question_id NOT NULL); câu inline bỏ qua.
  SELECT question_id, points INTO v_question_id, v_points
  FROM public.assignment_questions
  WHERE id = NEW.assignment_question_id AND question_id IS NOT NULL;

  IF v_question_id IS NULL THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    IF NEW.final_score IS NULL THEN
      RETURN NEW;  -- chưa chấm → chờ UPDATE
    END IF;

    INSERT INTO public.question_stats (question_id, total_attempts, correct_count, avg_score, last_attempted)
    VALUES (
      v_question_id, 1,
      CASE WHEN v_points > 0 AND NEW.final_score >= v_points THEN 1 ELSE 0 END,
      NEW.final_score, now()
    )
    ON CONFLICT (question_id) DO UPDATE SET
      total_attempts = question_stats.total_attempts + 1,
      correct_count  = question_stats.correct_count +
                       CASE WHEN v_points > 0 AND NEW.final_score >= v_points THEN 1 ELSE 0 END,
      avg_score      = (question_stats.avg_score * question_stats.total_attempts + NEW.final_score)
                       / (question_stats.total_attempts + 1),
      last_attempted = now();
    RETURN NEW;
  END IF;

  -- TG_OP = 'UPDATE'
  IF NEW.final_score IS NOT DISTINCT FROM OLD.final_score THEN
    RETURN NEW;
  END IF;

  v_old_att := CASE WHEN OLD.final_score IS NOT NULL THEN 1 ELSE 0 END;
  v_new_att := CASE WHEN NEW.final_score IS NOT NULL THEN 1 ELSE 0 END;
  v_old_cor := CASE WHEN OLD.final_score IS NOT NULL AND v_points > 0 AND OLD.final_score >= v_points THEN 1 ELSE 0 END;
  v_new_cor := CASE WHEN NEW.final_score IS NOT NULL AND v_points > 0 AND NEW.final_score >= v_points THEN 1 ELSE 0 END;

  IF v_new_att - v_old_att > 0 THEN
    -- chấm lần đầu qua UPDATE (essay/short_answer): +1 attempt
    INSERT INTO public.question_stats (question_id, total_attempts, correct_count, avg_score, last_attempted)
    VALUES (v_question_id, 1, v_new_cor, NEW.final_score, now())
    ON CONFLICT (question_id) DO UPDATE SET
      total_attempts = question_stats.total_attempts + 1,
      correct_count  = question_stats.correct_count + v_new_cor,
      avg_score      = (question_stats.avg_score * question_stats.total_attempts + NEW.final_score)
                       / (question_stats.total_attempts + 1),
      last_attempted = now();
  ELSIF v_new_att - v_old_att = 0 AND v_new_att = 1 THEN
    -- re-grade: attempt giữ nguyên, điều chỉnh correct + avg theo delta điểm
    UPDATE public.question_stats qs SET
      correct_count  = GREATEST(qs.correct_count + (v_new_cor - v_old_cor), 0),
      avg_score      = CASE WHEN qs.total_attempts > 0
                            THEN (qs.avg_score * qs.total_attempts - OLD.final_score + NEW.final_score) / qs.total_attempts
                            ELSE NEW.final_score END,
      last_attempted = now()
    WHERE qs.question_id = v_question_id;
  ELSE
    -- un-grade (NOT NULL → NULL): -1 attempt
    UPDATE public.question_stats qs SET
      total_attempts = GREATEST(qs.total_attempts - 1, 0),
      correct_count  = GREATEST(qs.correct_count - v_old_cor, 0),
      avg_score      = CASE WHEN qs.total_attempts - 1 > 0
                            THEN (qs.avg_score * qs.total_attempts - OLD.final_score) / (qs.total_attempts - 1)
                            ELSE 0 END,
      last_attempted = now()
    WHERE qs.question_id = v_question_id;
  END IF;

  RETURN NEW;
END;
$function$;

-- Thêm trigger AFTER UPDATE OF final_score cho question_stats (trước chỉ có INSERT)
DROP TRIGGER IF EXISTS trg_sa_02b_question_stats_update ON public.submission_answers;
CREATE TRIGGER trg_sa_02b_question_stats_update
  AFTER UPDATE OF final_score ON public.submission_answers
  FOR EACH ROW EXECUTE FUNCTION public.fn_update_question_stats();

COMMIT;
