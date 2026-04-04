


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "public";






CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."create_assignment_with_questions"("p_teacher_id" "uuid", "p_payload" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_assignment        jsonb;
  v_questions         jsonb;
  v_assignment_id     uuid;
  v_question          jsonb;
  v_question_id       uuid;
  v_total_points      numeric(8,2);
  v_expected_points   numeric(8,2);
  v_count_questions   integer;
  v_base_content      jsonb;
  v_custom_content    jsonb;
  v_idx               integer;
  v_obj_id_text       text;
  v_order_idx         integer;
begin
  if p_payload is null then
    raise exception 'PAYLOAD_REQUIRED';
  end if;

  v_assignment := coalesce(p_payload->'assignment', '{}'::jsonb);

  if coalesce(v_assignment->>'title', '') = '' then
    raise exception 'ASSIGNMENT_TITLE_REQUIRED';
  end if;

  -- Bước 1: tạo bản ghi assignments (template, is_published = false)
  insert into public.assignments (
    class_id,
    teacher_id,
    title,
    description,
    is_published,
    total_points
  )
  values (
    nullif(v_assignment->>'class_id', '')::uuid,
    p_teacher_id,
    v_assignment->>'title',
    nullif(v_assignment->>'description', ''),
    false,
    case
      when v_assignment ? 'total_points'
        then (v_assignment->>'total_points')::numeric
      else null
    end
  )
  returning id into v_assignment_id;

  -- Bước 2: lặp mảng questions
  v_questions := coalesce(p_payload->'questions', '[]'::jsonb);

  if jsonb_typeof(v_questions) <> 'array' then
    raise exception 'QUESTIONS_MUST_BE_ARRAY';
  end if;

  for v_question in
    select value from jsonb_array_elements(v_questions)
  loop
    -- 2.1 Xác định question_id
    if coalesce(v_question->>'id', '') <> '' then
      -- Reuse câu hỏi có sẵn trong bank
      v_question_id := (v_question->>'id')::uuid;
    else
      -- Câu hỏi mới: insert vào questions (+ objectives, choices nếu có)
      if coalesce(v_question->>'type', '') = '' then
        raise exception 'QUESTION_TYPE_REQUIRED';
      end if;

      insert into public.questions (
        author_id,
        type,
        content,
        answer,
        default_points,
        difficulty,
        tags
      )
      values (
        p_teacher_id,
        v_question->>'type',
        coalesce(v_question->'content', '{}'::jsonb),
        v_question->'answer',
        coalesce((v_question->>'default_points')::numeric, 1),
        case
          when v_question ? 'difficulty'
            then (v_question->>'difficulty')::int
          else null
        end,
        case
          when v_question ? 'tags'
               and jsonb_typeof(v_question->'tags') = 'array'
            then array(
              select jsonb_array_elements_text(v_question->'tags')
            )
          else null
        end
      )
      returning id into v_question_id;

      -- Objectives (mảng uuid text)
      if v_question ? 'objectives'
         and jsonb_typeof(v_question->'objectives') = 'array' then
        for v_obj_id_text in
          select jsonb_array_elements_text(v_question->'objectives')
        loop
          insert into public.question_objectives (question_id, objective_id)
          values (v_question_id, v_obj_id_text::uuid);
        end loop;
      end if;

      -- Choices cho multiple_choice
      if (v_question->>'type') = 'multiple_choice'
         and v_question ? 'choices'
         and jsonb_typeof(v_question->'choices') = 'array' then
        v_idx := 0;
        -- choices là array các object JSON: {text, image_url?, is_correct?}
        for v_custom_content in
          select value from jsonb_array_elements(v_question->'choices')
        loop
          insert into public.question_choices (
            id,
            question_id,
            content,
            is_correct
          )
          values (
            v_idx,
            v_question_id,
            coalesce(v_custom_content->'content', v_custom_content),
            coalesce(
              (v_custom_content->>'is_correct')::boolean,
              (v_custom_content->>'isCorrect')::boolean,
              false
            )
          );
          v_idx := v_idx + 1;
        end loop;
      end if;
    end if;

    -- 2.2 Tính custom_content (override so với content gốc)
    select q.content
    into v_base_content
    from public.questions q
    where q.id = v_question_id;

    v_custom_content := v_question->'custom_content';

    if v_custom_content is null
       or v_custom_content = v_base_content then
      v_custom_content := null;
    end if;

    -- 2.3 Insert vào assignment_questions (the Bridge)
    if not (v_question ? 'order_idx') then
      raise exception 'ORDER_IDX_REQUIRED_FOR_EACH_QUESTION';
    end if;

    v_order_idx := (v_question->>'order_idx')::int;

    insert into public.assignment_questions (
      assignment_id,
      question_id,
      custom_content,
      points,
      rubric,
      order_idx
    )
    values (
      v_assignment_id,
      v_question_id,
      v_custom_content,
      coalesce(
        (v_question->>'points')::numeric,
        (v_question->>'default_points')::numeric,
        1
      ),
      v_question->'rubric',
      v_order_idx
    );
  end loop;

  -- Bước 3: validate assignment_questions & total_points
  select
    count(*)::int,
    coalesce(sum(points), 0)::numeric(8,2)
  into v_count_questions, v_total_points
  from public.assignment_questions
  where assignment_id = v_assignment_id;

  if v_count_questions = 0 then
    raise exception 'ASSIGNMENT_MUST_HAVE_QUESTION';
  end if;

  if v_assignment ? 'total_points' then
    v_expected_points := (v_assignment->>'total_points')::numeric;
    if v_expected_points <> v_total_points then
      raise exception 'TOTAL_POINTS_MISMATCH: expected %, got %',
        v_expected_points, v_total_points;
    end if;
  end if;

  update public.assignments
  set total_points = v_total_points
  where id = v_assignment_id;

  return v_assignment_id;

exception
  when others then
    -- Re-raise với message rõ ràng để client map sang lỗi tiếng Việt
    raise exception 'CREATE_ASSIGNMENT_FAILED: %', sqlerrm
      using errcode = 'P0001';
end;
$$;


ALTER FUNCTION "public"."create_assignment_with_questions"("p_teacher_id" "uuid", "p_payload" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_class_student_variants"("p_assignment_id" "uuid", "p_class_id" "uuid", "p_shuffle_questions" boolean DEFAULT true, "p_shuffle_choices" boolean DEFAULT true) RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_student RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR v_student IN
        SELECT cm.student_id
        FROM class_members cm
        WHERE cm.class_id = p_class_id
        AND cm.status = 'approved'
    LOOP
        PERFORM create_student_variant(
            p_assignment_id,
            v_student.student_id,
            p_shuffle_questions,
            p_shuffle_choices
        );
        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$;


ALTER FUNCTION "public"."create_class_student_variants"("p_assignment_id" "uuid", "p_class_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_group_variant"("p_assignment_id" "uuid", "p_group_id" "uuid", "p_shuffle_questions" boolean DEFAULT true, "p_shuffle_choices" boolean DEFAULT true) RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_variant_id UUID;
    v_questions JSONB;
    v_shuffled_questions JSONB := '[]'::JSONB;
    v_seed BIGINT;
BEGIN
    v_seed := (
        (('x' || substr(md5(p_group_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000) * 1000000000 +
        ('x' || substr(md5(p_assignment_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000
    );

    SELECT jsonb_agg(
        jsonb_build_object(
            'original_assignment_question_id', aq.id,
            'original_question_id', aq.question_id,
            'order_idx', aq.order_idx,
            'points', aq.points,
            'custom_content', aq.custom_content
        ) ORDER BY aq.order_idx
    ) INTO v_questions
    FROM assignment_questions aq
    WHERE aq.assignment_id = p_assignment_id;

    IF v_questions IS NULL THEN
        RAISE EXCEPTION 'No questions found';
    END IF;

    IF p_shuffle_questions AND jsonb_array_length(v_questions) > 1 THEN
        v_shuffled_questions := shuffle_with_seed(v_questions, v_seed);
    ELSE
        v_shuffled_questions := v_questions;
    END IF;

    IF p_shuffle_choices THEN
        v_shuffled_questions := (
            SELECT jsonb_agg(
                jsonb_set(
                    elem,
                    '{custom_content,choices}',
                    shuffle_with_seed(
                        COALESCE(elem->'custom_content'->'choices', '[]'::JSONB),
                        v_seed + (elem->>'order_idx')::BIGINT * 997
                    )
                )
            )
            FROM jsonb_array_elements(v_shuffled_questions) AS elem
        );
    END IF;

    INSERT INTO assignment_variants (
        id,
        assignment_id,
        variant_type,
        group_id,
        custom_questions,
        created_at
    ) VALUES (
        gen_random_uuid(),
        p_assignment_id,
        'group',
        p_group_id,
        jsonb_build_object(
            'questions', v_shuffled_questions,
            'seed', v_seed,
            'shuffle_questions', p_shuffle_questions,
            'shuffle_choices', p_shuffle_choices,
            'generated_at', NOW()::TEXT
        ),
        NOW()
    )
    RETURNING id INTO v_variant_id;

    RETURN v_variant_id;
END;
$$;


ALTER FUNCTION "public"."create_group_variant"("p_assignment_id" "uuid", "p_group_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_groups_variants"("p_assignment_id" "uuid", "p_group_ids" "uuid"[], "p_shuffle_questions" boolean DEFAULT true, "p_shuffle_choices" boolean DEFAULT true) RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_group_id UUID;
    v_count INTEGER := 0;
BEGIN
    FOREACH v_group_id IN ARRAY p_group_ids
    LOOP
        PERFORM create_group_variant(
            p_assignment_id,
            v_group_id,
            p_shuffle_questions,
            p_shuffle_choices
        );
        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$;


ALTER FUNCTION "public"."create_groups_variants"("p_assignment_id" "uuid", "p_group_ids" "uuid"[], "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_student_variant"("p_assignment_id" "uuid", "p_student_id" "uuid", "p_shuffle_questions" boolean DEFAULT true, "p_shuffle_choices" boolean DEFAULT true) RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_variant_id UUID;
    v_questions JSONB;
    v_shuffled_questions JSONB := '[]'::JSONB;
    v_seed BIGINT;
    v_question JSONB;
BEGIN
    v_seed := (
        (('x' || substr(md5(p_student_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000) * 1000000000 +
        ('x' || substr(md5(p_assignment_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000
    );

    SELECT jsonb_agg(
        jsonb_build_object(
            'original_assignment_question_id', aq.id,
            'original_question_id', aq.question_id,
            'order_idx', aq.order_idx,
            'points', aq.points,
            'custom_content', aq.custom_content
        ) ORDER BY aq.order_idx
    ) INTO v_questions
    FROM assignment_questions aq
    WHERE aq.assignment_id = p_assignment_id;

    IF v_questions IS NULL OR jsonb_array_length(v_questions) = 0 THEN
        RAISE EXCEPTION 'No questions found for assignment %', p_assignment_id;
    END IF;

    IF p_shuffle_questions AND jsonb_array_length(v_questions) > 1 THEN
        v_shuffled_questions := shuffle_with_seed(v_questions, v_seed);
    ELSE
        v_shuffled_questions := v_questions;
    END IF;

    v_shuffled_questions := (
        SELECT jsonb_agg(
            CASE
                WHEN p_shuffle_choices THEN
                    jsonb_set(
                        elem,
                        '{custom_content,choices}',
                        shuffle_with_seed(
                            COALESCE(elem->'custom_content'->'choices', '[]'::JSONB),
                            v_seed + (elem->>'order_idx')::BIGINT * 997
                        )
                    )
                ELSE
                    elem
            END
        )
        FROM jsonb_array_elements(v_shuffled_questions) AS elem
    );

    INSERT INTO assignment_variants (
        id,
        assignment_id,
        variant_type,
        student_id,
        custom_questions,
        created_at
    ) VALUES (
        gen_random_uuid(),
        p_assignment_id,
        'student',
        p_student_id,
        jsonb_build_object(
            'questions', v_shuffled_questions,
            'seed', v_seed,
            'shuffle_questions', p_shuffle_questions,
            'shuffle_choices', p_shuffle_choices,
            'generated_at', NOW()::TEXT
        ),
        NOW()
    )
    RETURNING id INTO v_variant_id;

    RETURN v_variant_id;
END;
$$;


ALTER FUNCTION "public"."create_student_variant"("p_assignment_id" "uuid", "p_student_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_students_variants"("p_assignment_id" "uuid", "p_student_ids" "uuid"[], "p_shuffle_questions" boolean DEFAULT true, "p_shuffle_choices" boolean DEFAULT true) RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_student_id UUID;
    v_count INTEGER := 0;
BEGIN
    FOREACH v_student_id IN ARRAY p_student_ids
    LOOP
        PERFORM create_student_variant(
            p_assignment_id,
            v_student_id,
            p_shuffle_questions,
            p_shuffle_choices
        );
        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$;


ALTER FUNCTION "public"."create_students_variants"("p_assignment_id" "uuid", "p_student_ids" "uuid"[], "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ensure_student_variant"("p_assignment_id" "uuid", "p_student_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_variant_id UUID;
    v_settings JSONB;
    v_shuffle_questions BOOLEAN := false;
    v_shuffle_choices BOOLEAN := false;
    v_existing UUID;
BEGIN
    SELECT id INTO v_existing
    FROM assignment_variants
    WHERE assignment_id = p_assignment_id
    AND (
        (variant_type = 'student' AND student_id = p_student_id)
        OR (variant_type = 'group' AND group_id IN (
            SELECT group_id FROM group_members WHERE student_id = p_student_id
        ))
    )
    LIMIT 1;

    IF v_existing IS NOT NULL THEN
        RETURN v_existing;
    END IF;

    SELECT ad.settings INTO v_settings
    FROM assignment_distributions ad
    WHERE ad.assignment_id = p_assignment_id
    AND (
        (ad.distribution_type = 'individual' AND p_student_id = ANY(ad.student_ids))
        OR
        (ad.distribution_type = 'group' AND EXISTS (
            SELECT 1 FROM group_members gm
            WHERE gm.group_id = ad.group_id
            AND gm.student_id = p_student_id
        ))
        OR
        (ad.distribution_type = 'class' AND EXISTS (
            SELECT 1 FROM class_members cm
            WHERE cm.class_id = ad.class_id
            AND cm.student_id = p_student_id
            AND cm.status = 'approved'
        ))
    )
    ORDER BY
        CASE ad.distribution_type
            WHEN 'individual' THEN 1
            WHEN 'group' THEN 2
            WHEN 'class' THEN 3
        END
    LIMIT 1;

    IF v_settings IS NOT NULL THEN
        v_shuffle_questions := COALESCE((v_settings->>'shuffle_questions')::BOOLEAN, false);
        v_shuffle_choices := COALESCE((v_settings->>'shuffle_choices')::BOOLEAN, false);
    END IF;

    v_variant_id := create_student_variant(
        p_assignment_id,
        p_student_id,
        v_shuffle_questions,
        v_shuffle_choices
    );

    RETURN v_variant_id;
END;
$$;


ALTER FUNCTION "public"."ensure_student_variant"("p_assignment_id" "uuid", "p_student_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_role_safe"("user_id" "uuid" DEFAULT "auth"."uid"()) RETURNS "text"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  user_role TEXT;
BEGIN
  -- Tắt RLS trong function để bypass hoàn toàn
  PERFORM set_config('row_security', 'off', false);
  
  -- Query profiles mà không bị ảnh hưởng bởi RLS
  SELECT role INTO user_role
  FROM profiles
  WHERE id = user_id
  LIMIT 1;
  
  RETURN user_role;
END;
$$;


ALTER FUNCTION "public"."get_user_role_safe"("user_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_role_safe"("user_id" "uuid") IS 'Get user role bypassing RLS completely. Uses set_config to disable RLS in function context.';



CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into public.profiles (id, full_name, role, phone, gender)
  values (
    new.id, 
    new.raw_user_meta_data->>'full_name', 
    coalesce(new.raw_user_meta_data->>'role', 'student'),
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'gender'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin"("user_id" "uuid" DEFAULT "auth"."uid"()) RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN public.get_user_role_safe(user_id) = 'admin';
END;
$$;


ALTER FUNCTION "public"."is_admin"("user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_assignment_distributed_to_student"("assignment_id_param" "uuid", "student_id_param" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  result BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM assignment_distributions ad
    JOIN assignments a ON a.id = ad.assignment_id
    WHERE ad.assignment_id = assignment_id_param
      AND a.is_published = true
      AND (
        (ad.distribution_type = 'class' 
          AND ad.class_id IS NOT NULL
          AND public.is_student_in_class(student_id_param, ad.class_id))
        OR
        (ad.distribution_type = 'group'
          AND ad.group_id IS NOT NULL
          AND public.is_student_in_group(student_id_param, ad.group_id))
        OR
        (ad.distribution_type = 'individual'
          AND student_id_param = ANY(ad.student_ids))
      )
      AND (ad.available_from IS NULL OR ad.available_from <= now())
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;


ALTER FUNCTION "public"."is_assignment_distributed_to_student"("assignment_id_param" "uuid", "student_id_param" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_student_in_class"("student_id" "uuid", "class_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM class_members cm
    WHERE cm.student_id = is_student_in_class.student_id
      AND cm.class_id = is_student_in_class.class_id
      AND cm.status = 'approved'
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;


ALTER FUNCTION "public"."is_student_in_class"("student_id" "uuid", "class_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_student_in_class"("student_id" "uuid", "class_id" "uuid") IS 'Check if a student is an approved member of a class. Bypasses RLS to prevent infinite recursion.';



CREATE OR REPLACE FUNCTION "public"."is_student_in_class_any_status"("student_id" "uuid", "class_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM class_members cm
    WHERE cm.student_id = is_student_in_class_any_status.student_id
      AND cm.class_id = is_student_in_class_any_status.class_id
      AND cm.status IN ('approved', 'pending')
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;


ALTER FUNCTION "public"."is_student_in_class_any_status"("student_id" "uuid", "class_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_student_in_class_any_status"("student_id" "uuid", "class_id" "uuid") IS 'Check if a student is a member of a class (pending or approved). Bypasses RLS to prevent infinite recursion.';



CREATE OR REPLACE FUNCTION "public"."is_student_in_group"("student_id" "uuid", "group_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM group_members gm
    WHERE gm.student_id = is_student_in_group.student_id
      AND gm.group_id = is_student_in_group.group_id
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;


ALTER FUNCTION "public"."is_student_in_group"("student_id" "uuid", "group_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_student_in_group"("student_id" "uuid", "group_id" "uuid") IS 'Check if a student is a member of a group. Bypasses RLS to prevent infinite recursion.';



CREATE OR REPLACE FUNCTION "public"."is_teacher"("user_id" "uuid" DEFAULT "auth"."uid"()) RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN public.get_user_role_safe(user_id) = 'teacher';
END;
$$;


ALTER FUNCTION "public"."is_teacher"("user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_teacher_of_student_class"("teacher_id" "uuid", "student_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  -- Kiểm tra xem teacher có dạy class nào mà student là member không
  SELECT EXISTS (
    SELECT 1
    FROM class_members cm
    JOIN classes c ON c.id = cm.class_id
    WHERE cm.student_id = is_teacher_of_student_class.student_id
      AND c.teacher_id = is_teacher_of_student_class.teacher_id
      AND cm.status = 'approved'
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;


ALTER FUNCTION "public"."is_teacher_of_student_class"("teacher_id" "uuid", "student_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_teacher_of_student_class"("teacher_id" "uuid", "student_id" "uuid") IS 'Check if a teacher teaches a class where a student is a member. Bypasses RLS to prevent infinite recursion in policies.';



CREATE OR REPLACE FUNCTION "public"."is_teacher_owner_of_class"("teacher_id" "uuid", "class_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM classes c
    WHERE c.id = is_teacher_owner_of_class.class_id
      AND c.teacher_id = is_teacher_owner_of_class.teacher_id
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$$;


ALTER FUNCTION "public"."is_teacher_owner_of_class"("teacher_id" "uuid", "class_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_teacher_owner_of_class"("teacher_id" "uuid", "class_id" "uuid") IS 'Check if a teacher owns a class. Bypasses RLS to prevent infinite recursion.';



CREATE OR REPLACE FUNCTION "public"."publish_assignment"("p_assignment" "jsonb", "p_questions" "jsonb" DEFAULT '[]'::"jsonb", "p_distributions" "jsonb" DEFAULT '[]'::"jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_is_admin boolean := false;
  v_teacher_id uuid;
  v_assignment_id uuid;
  v_assignment_row public.assignments%rowtype;
  v_class_id uuid;
BEGIN
  -- Auth
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT EXISTS(
    SELECT 1 FROM public.profiles
    WHERE id = v_uid AND role = 'admin'
  ) INTO v_is_admin;

  IF v_is_admin THEN
    v_teacher_id := COALESCE((p_assignment->>'teacher_id')::uuid, v_uid);
  ELSE
    IF NOT EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = v_uid AND role = 'teacher'
    ) THEN
      RAISE EXCEPTION 'Forbidden: only teachers can publish assignments';
    END IF;
    v_teacher_id := v_uid;
  END IF;

  v_class_id := (p_assignment->>'class_id')::uuid;
  IF v_class_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1
      FROM public.classes c
      WHERE c.id = v_class_id
        AND (v_is_admin OR c.teacher_id = v_teacher_id)
    ) THEN
      RAISE EXCEPTION 'Forbidden: class not owned by teacher';
    END IF;
  END IF;

  -- Upsert assignment (meta only, thời gian & allow_late được lưu ở assignment_distributions)
  v_assignment_id := (p_assignment->>'id')::uuid;
  IF v_assignment_id IS NOT NULL THEN
    IF NOT v_is_admin AND NOT EXISTS (
      SELECT 1 FROM public.assignments a
      WHERE a.id = v_assignment_id AND a.teacher_id = v_teacher_id
    ) THEN
      RAISE EXCEPTION 'Forbidden: assignment not owned by teacher';
    END IF;

    UPDATE public.assignments
    SET
      class_id = v_class_id,
      title = COALESCE(p_assignment->>'title', title),
      description = p_assignment->>'description',
      total_points = (p_assignment->>'total_points')::numeric,
      is_published = TRUE,
      published_at = now()
    WHERE id = v_assignment_id
    RETURNING * INTO v_assignment_row;
  ELSE
    INSERT INTO public.assignments (
      class_id,
      teacher_id,
      title,
      description,
      is_published,
      published_at,
      total_points
    ) VALUES (
      v_class_id,
      v_teacher_id,
      COALESCE(p_assignment->>'title', 'Bài tập mới'),
      p_assignment->>'description',
      TRUE,
      now(),
      (p_assignment->>'total_points')::numeric
    )
    RETURNING * INTO v_assignment_row;

    v_assignment_id := v_assignment_row.id;
  END IF;

  -- Replace assignment_questions
  DELETE FROM public.assignment_questions WHERE assignment_id = v_assignment_id;
  IF jsonb_typeof(p_questions) = 'array' AND jsonb_array_length(p_questions) > 0 THEN
    INSERT INTO public.assignment_questions (
      assignment_id,
      question_id,
      custom_content,
      points,
      rubric,
      order_idx
    )
    SELECT
      v_assignment_id,
      (q->>'question_id')::uuid,
      q->'custom_content',
      COALESCE((q->>'points')::numeric, 1),
      q->'rubric',
      (q->>'order_idx')::int
    FROM jsonb_array_elements(p_questions) AS q;
  END IF;

  -- Replace assignment_distributions (lưu thời gian, allow_late, late_policy)
  DELETE FROM public.assignment_distributions WHERE assignment_id = v_assignment_id;
  IF jsonb_typeof(p_distributions) = 'array' AND jsonb_array_length(p_distributions) > 0 THEN
    INSERT INTO public.assignment_distributions (
      assignment_id,
      distribution_type,
      class_id,
      group_id,
      student_ids,
      available_from,
      due_at,
      time_limit_minutes,
      allow_late,
      late_policy
    )
    SELECT
      v_assignment_id,
      (d->>'distribution_type')::text,
      (d->>'class_id')::uuid,
      (d->>'group_id')::uuid,
      CASE
        WHEN d ? 'student_ids' AND d->'student_ids' IS NOT NULL THEN
          ARRAY(
            SELECT jsonb_array_elements_text(d->'student_ids')::uuid
          )
        ELSE NULL
      END,
      (d->>'available_from')::timestamptz,
      (d->>'due_at')::timestamptz,
      (d->>'time_limit_minutes')::int,
      COALESCE((d->>'allow_late')::boolean, TRUE),
      d->'late_policy'
    FROM jsonb_array_elements(p_distributions) AS d;
  END IF;

  SELECT * INTO v_assignment_row FROM public.assignments WHERE id = v_assignment_id;
  RETURN to_jsonb(v_assignment_row);
END;
$$;


ALTER FUNCTION "public"."publish_assignment"("p_assignment" "jsonb", "p_questions" "jsonb", "p_distributions" "jsonb") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."publish_assignment"("p_assignment" "jsonb", "p_questions" "jsonb", "p_distributions" "jsonb") IS 'RPC: publish assignment in 1 transaction (upsert assignment + replace assignment_questions + replace assignment_distributions). SECURITY DEFINER with explicit auth checks.';



CREATE OR REPLACE FUNCTION "public"."shuffle_with_seed"("p_array" "jsonb", "p_seed" bigint) RETURNS "jsonb"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
    v_result JSONB;
    v_length INTEGER;
    v_i INTEGER;
    v_j INTEGER;
    v_temp JSONB;
BEGIN
    v_result := p_array;
    v_length := jsonb_array_length(v_result);

    IF v_length <= 1 THEN
        RETURN v_result;
    END IF;

    FOR v_i IN REVERSE v_length - 1 .. 1 LOOP
        v_j := floor(
            ((p_seed + v_i::BIGINT) * 1103515245 + 12345) % 2147483648
        ) % (v_i + 1);

        v_temp := v_result->v_i;
        v_result := jsonb_set(
            jsonb_set(v_result, ARRAY[v_i::TEXT], v_result->v_j),
            ARRAY[v_j::TEXT],
            v_temp
        );
    END LOOP;

    RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."shuffle_with_seed"("p_array" "jsonb", "p_seed" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."ai_evaluations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "submission_answer_id" "uuid",
    "model_name" "text",
    "model_version" "text",
    "ai_score" numeric(7,2),
    "ai_confidence" numeric(3,2),
    "feedback" "text",
    "rationale" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."ai_evaluations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ai_queue" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "submission_answer_id" "uuid",
    "request_type" "text" DEFAULT 'score'::"text",
    "status" "text" DEFAULT 'pending'::"text",
    "attempts" integer DEFAULT 0,
    "payload" "jsonb",
    "result" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "ai_queue_request_type_check" CHECK (("request_type" = ANY (ARRAY['score'::"text", 'feedback'::"text", 'analysis'::"text"])))
);


ALTER TABLE "public"."ai_queue" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ai_recommendations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "teacher_id" "uuid",
    "class_id" "uuid",
    "student_id" "uuid",
    "type" "text" DEFAULT 'individual'::"text",
    "priority" integer DEFAULT 3,
    "title" "text" NOT NULL,
    "description" "text",
    "resources" "jsonb",
    "dismissed" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "ai_recommendations_priority_check" CHECK ((("priority" >= 1) AND ("priority" <= 5))),
    CONSTRAINT "ai_recommendations_type_check" CHECK (("type" = ANY (ARRAY['individual'::"text", 'small_group'::"text", 'class'::"text"])))
);


ALTER TABLE "public"."ai_recommendations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."assignment_distributions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "assignment_id" "uuid" NOT NULL,
    "distribution_type" "text" NOT NULL,
    "class_id" "uuid",
    "group_id" "uuid",
    "student_ids" "uuid"[],
    "available_from" timestamp with time zone,
    "due_at" timestamp with time zone,
    "time_limit_minutes" integer,
    "allow_late" boolean DEFAULT true,
    "late_policy" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "settings" "jsonb" DEFAULT '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true}'::"jsonb",
    CONSTRAINT "assignment_distributions_distribution_type_check" CHECK (("distribution_type" = ANY (ARRAY['class'::"text", 'group'::"text", 'individual'::"text"]))),
    CONSTRAINT "assignment_distributions_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'scheduled'::"text", 'active'::"text", 'closed'::"text", 'archived'::"text"]))),
    CONSTRAINT "assignment_distributions_time_limit_minutes_check" CHECK ((("time_limit_minutes" IS NULL) OR ("time_limit_minutes" > 0))),
    CONSTRAINT "check_distribution_type_match" CHECK (((("distribution_type" = 'class'::"text") AND ("class_id" IS NOT NULL) AND ("group_id" IS NULL) AND ("student_ids" IS NULL)) OR (("distribution_type" = 'group'::"text") AND ("class_id" IS NOT NULL) AND ("group_id" IS NOT NULL) AND ("student_ids" IS NULL)) OR (("distribution_type" = 'individual'::"text") AND ("class_id" IS NOT NULL) AND ("student_ids" IS NOT NULL) AND ("array_length"("student_ids", 1) > 0) AND ("group_id" IS NULL))))
);


ALTER TABLE "public"."assignment_distributions" OWNER TO "postgres";


COMMENT ON TABLE "public"."assignment_distributions" IS 'Đợt phát hành bài tập đến lớp/nhóm/học sinh cụ thể, là nguồn sự thật duy nhất cho deadline, time_limit, late_policy và status';



COMMENT ON COLUMN "public"."assignment_distributions"."settings" IS 'Cấu hình bài tập: shuffle_questions, shuffle_choices (đảo đáp án), show_score_immediately (hiển thị điểm ngay)';



COMMENT ON CONSTRAINT "check_distribution_type_match" ON "public"."assignment_distributions" IS 'class_id luôn required (context). group_id chỉ cho type group. student_ids chỉ cho type individual.';



CREATE TABLE IF NOT EXISTS "public"."assignment_questions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "assignment_id" "uuid" NOT NULL,
    "question_id" "uuid",
    "custom_content" "jsonb",
    "points" numeric(7,2) DEFAULT 1 NOT NULL,
    "rubric" "jsonb",
    "order_idx" integer NOT NULL,
    CONSTRAINT "assignment_questions_points_check" CHECK (("points" > (0)::numeric))
);


ALTER TABLE "public"."assignment_questions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."assignment_variants" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "assignment_id" "uuid" NOT NULL,
    "variant_type" "text" DEFAULT 'student'::"text" NOT NULL,
    "student_id" "uuid",
    "group_id" "uuid",
    "due_at_override" timestamp with time zone,
    "custom_questions" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "assignment_variants_variant_type_check" CHECK (("variant_type" = ANY (ARRAY['student'::"text", 'group'::"text", 'global'::"text"]))),
    CONSTRAINT "check_variant_type_match" CHECK (((("variant_type" = 'student'::"text") AND ("student_id" IS NOT NULL) AND ("group_id" IS NULL)) OR (("variant_type" = 'group'::"text") AND ("group_id" IS NOT NULL) AND ("student_id" IS NULL)) OR (("variant_type" = 'global'::"text") AND ("student_id" IS NULL) AND ("group_id" IS NULL))))
);


ALTER TABLE "public"."assignment_variants" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."assignments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "class_id" "uuid",
    "teacher_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "is_published" boolean DEFAULT false,
    "published_at" timestamp with time zone,
    "total_points" numeric(8,2),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "default_shuffle_questions" boolean DEFAULT false,
    "default_shuffle_choices" boolean DEFAULT false,
    CONSTRAINT "assignments_total_points_check" CHECK ((("total_points" IS NULL) OR ("total_points" >= (0)::numeric)))
);


ALTER TABLE "public"."assignments" OWNER TO "postgres";


COMMENT ON TABLE "public"."assignments" IS 'Template bài tập chứa nội dung và câu hỏi, tách biệt hoàn toàn khỏi lịch phát hành & deadline';



COMMENT ON COLUMN "public"."assignments"."default_shuffle_questions" IS 'Cấu hình mặc định: có nên đảo câu hỏi khi phân phối không';



COMMENT ON COLUMN "public"."assignments"."default_shuffle_choices" IS 'Cấu hình mặc định: có nên đảo đáp án khi phân phối không';



CREATE TABLE IF NOT EXISTS "public"."autosave_answers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "session_id" "uuid",
    "assignment_question_id" "uuid",
    "answer_content" "jsonb",
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."autosave_answers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."class_members" (
    "class_id" "uuid" NOT NULL,
    "student_id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'student'::"text",
    "joined_at" timestamp with time zone DEFAULT "now"(),
    "status" "text" DEFAULT 'pending'::"text",
    CONSTRAINT "class_members_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'approved'::"text", 'rejected'::"text"])))
);


ALTER TABLE "public"."class_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."class_teachers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "class_id" "uuid",
    "teacher_id" "uuid",
    "role" "text" DEFAULT 'teacher'::"text"
);


ALTER TABLE "public"."class_teachers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."classes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "school_id" "uuid",
    "teacher_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "subject" "text",
    "academic_year" "text",
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "class_settings" "jsonb" DEFAULT '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'::"jsonb"
);


ALTER TABLE "public"."classes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."file_links" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "file_id" "uuid",
    "target_type" "text" NOT NULL,
    "target_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."file_links" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."files" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "storage_path" "text" NOT NULL,
    "url" "text",
    "filename" "text",
    "mime_type" "text",
    "size_bytes" bigint,
    "uploaded_by" "uuid",
    "metadata" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "is_deleted" boolean DEFAULT false
);


ALTER TABLE "public"."files" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."grade_overrides" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "submission_answer_id" "uuid" NOT NULL,
    "overridden_by" "uuid" NOT NULL,
    "old_score" numeric(7,2),
    "new_score" numeric(7,2) NOT NULL,
    "reason" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."grade_overrides" OWNER TO "postgres";


COMMENT ON TABLE "public"."grade_overrides" IS 'Audit trail for grade modifications by teachers';



CREATE TABLE IF NOT EXISTS "public"."group_members" (
    "group_id" "uuid" NOT NULL,
    "student_id" "uuid" NOT NULL,
    "joined_at" timestamp with time zone DEFAULT "now"(),
    "role" "text" DEFAULT 'member'::"text",
    "enrolled_by" "uuid"
);


ALTER TABLE "public"."group_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."groups" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "class_id" "uuid",
    "name" "text" NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "teacher_id" "uuid"
);


ALTER TABLE "public"."groups" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."learning_objectives" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "subject_code" "text" NOT NULL,
    "code" "text" NOT NULL,
    "description" "text" NOT NULL,
    "difficulty" integer,
    "parent_id" "uuid",
    "metadata" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "learning_objectives_difficulty_check" CHECK ((("difficulty" >= 1) AND ("difficulty" <= 5)))
);


ALTER TABLE "public"."learning_objectives" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "full_name" "text",
    "role" "text" DEFAULT 'student'::"text",
    "avatar_url" "text",
    "bio" "text",
    "metadata" "jsonb",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "phone" "text",
    "gender" "text",
    CONSTRAINT "profiles_gender_check" CHECK (("gender" = ANY (ARRAY['male'::"text", 'female'::"text", 'other'::"text"]))),
    CONSTRAINT "profiles_role_check" CHECK (("role" = ANY (ARRAY['teacher'::"text", 'student'::"text", 'admin'::"text"])))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."question_choices" (
    "id" integer NOT NULL,
    "question_id" "uuid" NOT NULL,
    "content" "jsonb" NOT NULL,
    "is_correct" boolean DEFAULT false,
    CONSTRAINT "question_choices_id_check" CHECK (("id" >= 0))
);


ALTER TABLE "public"."question_choices" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."question_objectives" (
    "question_id" "uuid" NOT NULL,
    "objective_id" "uuid" NOT NULL
);


ALTER TABLE "public"."question_objectives" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."question_stats" (
    "question_id" "uuid" NOT NULL,
    "total_attempts" integer DEFAULT 0,
    "correct_count" integer DEFAULT 0,
    "avg_score" numeric(7,4) DEFAULT 0,
    "last_attempted" timestamp with time zone
);


ALTER TABLE "public"."question_stats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."questions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "author_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "content" "jsonb" NOT NULL,
    "answer" "jsonb",
    "default_points" numeric(7,2) DEFAULT 1,
    "difficulty" integer,
    "tags" "text"[],
    "is_public" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "questions_default_points_check" CHECK (("default_points" > (0)::numeric)),
    CONSTRAINT "questions_difficulty_check" CHECK ((("difficulty" >= 1) AND ("difficulty" <= 5))),
    CONSTRAINT "questions_type_check" CHECK (("type" = ANY (ARRAY['multiple_choice'::"text", 'short_answer'::"text", 'essay'::"text", 'true_false'::"text", 'matching'::"text", 'problem_solving'::"text", 'file_upload'::"text", 'fill_in_blank'::"text"])))
);


ALTER TABLE "public"."questions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."schools" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "domain" "text",
    "metadata" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."schools" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."student_skill_mastery" (
    "student_id" "uuid" NOT NULL,
    "objective_id" "uuid" NOT NULL,
    "mastery_level" numeric(3,2) DEFAULT 0.0,
    "attempts" integer DEFAULT 0,
    "correct" integer DEFAULT 0,
    "last_updated" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "student_skill_mastery_mastery_level_check" CHECK ((("mastery_level" >= (0)::numeric) AND ("mastery_level" <= (1)::numeric)))
);


ALTER TABLE "public"."student_skill_mastery" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."submission_analytics" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "submission_id" "uuid",
    "metrics" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."submission_analytics" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."submission_answers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "session_id" "uuid",
    "assignment_question_id" "uuid" NOT NULL,
    "answer" "jsonb" NOT NULL,
    "files" "jsonb",
    "flagged" boolean DEFAULT false,
    "ai_score" numeric(7,2),
    "ai_confidence" numeric(3,2),
    "final_score" numeric(7,2),
    "ai_feedback" "jsonb",
    "teacher_feedback" "jsonb",
    "graded_by" "uuid",
    "graded_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."submission_answers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."submissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "assignment_id" "uuid",
    "student_id" "uuid" NOT NULL,
    "session_id" "uuid",
    "variant_id" "uuid",
    "started_at" timestamp with time zone,
    "submitted_at" timestamp with time zone,
    "is_late" boolean DEFAULT false,
    "total_score" numeric(8,2),
    "ai_graded" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_voided" boolean DEFAULT false,
    "assignment_distribution_id" "uuid"
);


ALTER TABLE "public"."submissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."teacher_notes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "teacher_id" "uuid",
    "student_id" "uuid",
    "content" "text" NOT NULL,
    "is_private" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."teacher_notes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."work_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "assignment_distribution_id" "uuid",
    "assignment_id" "uuid",
    "student_id" "uuid" NOT NULL,
    "started_at" timestamp with time zone,
    "submitted_at" timestamp with time zone,
    "attempt" integer DEFAULT 1,
    "status" "text" DEFAULT 'in_progress'::"text",
    "time_spent_seconds" bigint DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "work_sessions_status_check" CHECK (("status" = ANY (ARRAY['in_progress'::"text", 'submitted'::"text", 'graded'::"text"])))
);


ALTER TABLE "public"."work_sessions" OWNER TO "postgres";


ALTER TABLE ONLY "public"."ai_evaluations"
    ADD CONSTRAINT "ai_evaluations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ai_queue"
    ADD CONSTRAINT "ai_queue_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ai_recommendations"
    ADD CONSTRAINT "ai_recommendations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."assignment_distributions"
    ADD CONSTRAINT "assignment_distributions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."assignment_questions"
    ADD CONSTRAINT "assignment_questions_assignment_id_order_idx_key" UNIQUE ("assignment_id", "order_idx");



ALTER TABLE ONLY "public"."assignment_questions"
    ADD CONSTRAINT "assignment_questions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."assignment_variants"
    ADD CONSTRAINT "assignment_variants_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."assignments"
    ADD CONSTRAINT "assignments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."autosave_answers"
    ADD CONSTRAINT "autosave_answers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."class_members"
    ADD CONSTRAINT "class_members_pkey" PRIMARY KEY ("class_id", "student_id");



ALTER TABLE ONLY "public"."class_teachers"
    ADD CONSTRAINT "class_teachers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."classes"
    ADD CONSTRAINT "classes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."file_links"
    ADD CONSTRAINT "file_links_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."files"
    ADD CONSTRAINT "files_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."grade_overrides"
    ADD CONSTRAINT "grade_overrides_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_pkey" PRIMARY KEY ("group_id", "student_id");



ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."learning_objectives"
    ADD CONSTRAINT "learning_objectives_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."learning_objectives"
    ADD CONSTRAINT "learning_objectives_subject_code_code_key" UNIQUE ("subject_code", "code");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."question_choices"
    ADD CONSTRAINT "question_choices_pkey" PRIMARY KEY ("id", "question_id");



ALTER TABLE ONLY "public"."question_objectives"
    ADD CONSTRAINT "question_objectives_pkey" PRIMARY KEY ("question_id", "objective_id");



ALTER TABLE ONLY "public"."question_stats"
    ADD CONSTRAINT "question_stats_pkey" PRIMARY KEY ("question_id");



ALTER TABLE ONLY "public"."questions"
    ADD CONSTRAINT "questions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."schools"
    ADD CONSTRAINT "schools_domain_key" UNIQUE ("domain");



ALTER TABLE ONLY "public"."schools"
    ADD CONSTRAINT "schools_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student_skill_mastery"
    ADD CONSTRAINT "student_skill_mastery_pkey" PRIMARY KEY ("student_id", "objective_id");



ALTER TABLE ONLY "public"."submission_analytics"
    ADD CONSTRAINT "submission_analytics_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."submission_answers"
    ADD CONSTRAINT "submission_answers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."submissions"
    ADD CONSTRAINT "submissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."teacher_notes"
    ADD CONSTRAINT "teacher_notes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."work_sessions"
    ADD CONSTRAINT "work_sessions_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_ai_queue_status" ON "public"."ai_queue" USING "btree" ("status");



CREATE INDEX "idx_assignment_distributions_assignment" ON "public"."assignment_distributions" USING "btree" ("assignment_id");



CREATE INDEX "idx_assignment_distributions_available_from" ON "public"."assignment_distributions" USING "btree" ("available_from");



CREATE INDEX "idx_assignment_distributions_class" ON "public"."assignment_distributions" USING "btree" ("class_id");



CREATE INDEX "idx_assignment_distributions_due_at" ON "public"."assignment_distributions" USING "btree" ("due_at");



CREATE INDEX "idx_assignment_distributions_group" ON "public"."assignment_distributions" USING "btree" ("group_id");



CREATE INDEX "idx_assignment_distributions_student_ids" ON "public"."assignment_distributions" USING "gin" ("student_ids");



CREATE INDEX "idx_assignment_distributions_type" ON "public"."assignment_distributions" USING "btree" ("distribution_type");



CREATE INDEX "idx_assignment_questions_assignment" ON "public"."assignment_questions" USING "btree" ("assignment_id");



CREATE INDEX "idx_assignment_questions_order" ON "public"."assignment_questions" USING "btree" ("assignment_id", "order_idx");



CREATE INDEX "idx_assignment_questions_question" ON "public"."assignment_questions" USING "btree" ("question_id");



CREATE INDEX "idx_assignment_variants_assignment" ON "public"."assignment_variants" USING "btree" ("assignment_id");



CREATE INDEX "idx_assignment_variants_group" ON "public"."assignment_variants" USING "btree" ("group_id");



CREATE INDEX "idx_assignment_variants_student" ON "public"."assignment_variants" USING "btree" ("student_id");



CREATE INDEX "idx_assignment_variants_type" ON "public"."assignment_variants" USING "btree" ("variant_type");



CREATE INDEX "idx_assignments_class" ON "public"."assignments" USING "btree" ("class_id");



CREATE INDEX "idx_assignments_class_teacher_published" ON "public"."assignments" USING "btree" ("class_id", "teacher_id", "is_published");



CREATE INDEX "idx_assignments_created_at" ON "public"."assignments" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_assignments_is_published" ON "public"."assignments" USING "btree" ("is_published");



CREATE INDEX "idx_assignments_teacher" ON "public"."assignments" USING "btree" ("teacher_id");



CREATE INDEX "idx_class_members_student" ON "public"."class_members" USING "btree" ("student_id");



CREATE INDEX "idx_class_members_student_id" ON "public"."class_members" USING "btree" ("student_id");



CREATE INDEX "idx_class_teachers_class_id" ON "public"."class_teachers" USING "btree" ("class_id");



CREATE INDEX "idx_class_teachers_teacher_id" ON "public"."class_teachers" USING "btree" ("teacher_id");



CREATE INDEX "idx_classes_join_code" ON "public"."classes" USING "btree" ((((("class_settings" -> 'enrollment'::"text") -> 'qr_code'::"text") ->> 'join_code'::"text")));



CREATE INDEX "idx_classes_school_id" ON "public"."classes" USING "btree" ("school_id");



CREATE INDEX "idx_classes_teacher" ON "public"."classes" USING "btree" ("teacher_id");



CREATE INDEX "idx_classes_teacher_id" ON "public"."classes" USING "btree" ("teacher_id");



CREATE INDEX "idx_group_members_student_id" ON "public"."group_members" USING "btree" ("student_id");



CREATE INDEX "idx_groups_class_id" ON "public"."groups" USING "btree" ("class_id");



CREATE INDEX "idx_learning_objectives_parent" ON "public"."learning_objectives" USING "btree" ("parent_id");



CREATE INDEX "idx_learning_objectives_subject_code" ON "public"."learning_objectives" USING "btree" ("subject_code", "code");



CREATE INDEX "idx_question_choices_order" ON "public"."question_choices" USING "btree" ("question_id", "id");



CREATE INDEX "idx_question_choices_question" ON "public"."question_choices" USING "btree" ("question_id");



CREATE INDEX "idx_question_objectives_objective" ON "public"."question_objectives" USING "btree" ("objective_id");



CREATE INDEX "idx_question_objectives_question" ON "public"."question_objectives" USING "btree" ("question_id");



CREATE INDEX "idx_questions_author" ON "public"."questions" USING "btree" ("author_id");



CREATE INDEX "idx_questions_author_type_public" ON "public"."questions" USING "btree" ("author_id", "type", "is_public");



CREATE INDEX "idx_questions_created_at" ON "public"."questions" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_questions_difficulty" ON "public"."questions" USING "btree" ("difficulty");



CREATE INDEX "idx_questions_is_public" ON "public"."questions" USING "btree" ("is_public");



CREATE INDEX "idx_questions_tags" ON "public"."questions" USING "gin" ("tags");



CREATE INDEX "idx_questions_type" ON "public"."questions" USING "btree" ("type");



CREATE INDEX "idx_student_skill" ON "public"."student_skill_mastery" USING "btree" ("student_id");



CREATE INDEX "idx_submissions_distribution" ON "public"."submissions" USING "btree" ("assignment_distribution_id");



CREATE INDEX "idx_submissions_student" ON "public"."submissions" USING "btree" ("student_id");



CREATE INDEX "idx_work_sessions_student" ON "public"."work_sessions" USING "btree" ("student_id");



CREATE OR REPLACE TRIGGER "update_assignments_updated_at" BEFORE UPDATE ON "public"."assignments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_questions_updated_at" BEFORE UPDATE ON "public"."questions" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."ai_evaluations"
    ADD CONSTRAINT "ai_evaluations_submission_answer_id_fkey" FOREIGN KEY ("submission_answer_id") REFERENCES "public"."submission_answers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ai_queue"
    ADD CONSTRAINT "ai_queue_submission_answer_id_fkey" FOREIGN KEY ("submission_answer_id") REFERENCES "public"."submission_answers"("id");



ALTER TABLE ONLY "public"."ai_recommendations"
    ADD CONSTRAINT "ai_recommendations_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id");



ALTER TABLE ONLY "public"."ai_recommendations"
    ADD CONSTRAINT "ai_recommendations_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."ai_recommendations"
    ADD CONSTRAINT "ai_recommendations_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."assignment_distributions"
    ADD CONSTRAINT "assignment_distributions_assignment_id_fkey" FOREIGN KEY ("assignment_id") REFERENCES "public"."assignments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assignment_distributions"
    ADD CONSTRAINT "assignment_distributions_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assignment_distributions"
    ADD CONSTRAINT "assignment_distributions_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assignment_questions"
    ADD CONSTRAINT "assignment_questions_assignment_id_fkey" FOREIGN KEY ("assignment_id") REFERENCES "public"."assignments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assignment_questions"
    ADD CONSTRAINT "assignment_questions_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."questions"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."assignment_variants"
    ADD CONSTRAINT "assignment_variants_assignment_id_fkey" FOREIGN KEY ("assignment_id") REFERENCES "public"."assignments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assignment_variants"
    ADD CONSTRAINT "assignment_variants_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assignment_variants"
    ADD CONSTRAINT "assignment_variants_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assignments"
    ADD CONSTRAINT "assignments_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assignments"
    ADD CONSTRAINT "assignments_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."autosave_answers"
    ADD CONSTRAINT "autosave_answers_assignment_question_id_fkey" FOREIGN KEY ("assignment_question_id") REFERENCES "public"."assignment_questions"("id");



ALTER TABLE ONLY "public"."autosave_answers"
    ADD CONSTRAINT "autosave_answers_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "public"."work_sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."class_members"
    ADD CONSTRAINT "class_members_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."class_members"
    ADD CONSTRAINT "class_members_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."class_teachers"
    ADD CONSTRAINT "class_teachers_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."class_teachers"
    ADD CONSTRAINT "class_teachers_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."classes"
    ADD CONSTRAINT "classes_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id");



ALTER TABLE ONLY "public"."classes"
    ADD CONSTRAINT "classes_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."file_links"
    ADD CONSTRAINT "file_links_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."files"
    ADD CONSTRAINT "files_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."grade_overrides"
    ADD CONSTRAINT "grade_overrides_overridden_by_fkey" FOREIGN KEY ("overridden_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."grade_overrides"
    ADD CONSTRAINT "grade_overrides_submission_answer_id_fkey" FOREIGN KEY ("submission_answer_id") REFERENCES "public"."submission_answers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_enrolled_by_fkey" FOREIGN KEY ("enrolled_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."learning_objectives"
    ADD CONSTRAINT "learning_objectives_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."learning_objectives"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."question_choices"
    ADD CONSTRAINT "question_choices_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."questions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."question_objectives"
    ADD CONSTRAINT "question_objectives_objective_id_fkey" FOREIGN KEY ("objective_id") REFERENCES "public"."learning_objectives"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."question_objectives"
    ADD CONSTRAINT "question_objectives_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."questions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."question_stats"
    ADD CONSTRAINT "question_stats_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."questions"("id");



ALTER TABLE ONLY "public"."questions"
    ADD CONSTRAINT "questions_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."student_skill_mastery"
    ADD CONSTRAINT "student_skill_mastery_objective_id_fkey" FOREIGN KEY ("objective_id") REFERENCES "public"."learning_objectives"("id");



ALTER TABLE ONLY "public"."student_skill_mastery"
    ADD CONSTRAINT "student_skill_mastery_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."submission_analytics"
    ADD CONSTRAINT "submission_analytics_submission_id_fkey" FOREIGN KEY ("submission_id") REFERENCES "public"."submissions"("id");



ALTER TABLE ONLY "public"."submission_answers"
    ADD CONSTRAINT "submission_answers_assignment_question_id_fkey" FOREIGN KEY ("assignment_question_id") REFERENCES "public"."assignment_questions"("id");



ALTER TABLE ONLY "public"."submission_answers"
    ADD CONSTRAINT "submission_answers_graded_by_fkey" FOREIGN KEY ("graded_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."submission_answers"
    ADD CONSTRAINT "submission_answers_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "public"."work_sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."submissions"
    ADD CONSTRAINT "submissions_assignment_distribution_id_fkey" FOREIGN KEY ("assignment_distribution_id") REFERENCES "public"."assignment_distributions"("id");



ALTER TABLE ONLY "public"."submissions"
    ADD CONSTRAINT "submissions_assignment_id_fkey" FOREIGN KEY ("assignment_id") REFERENCES "public"."assignments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."submissions"
    ADD CONSTRAINT "submissions_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "public"."work_sessions"("id");



ALTER TABLE ONLY "public"."submissions"
    ADD CONSTRAINT "submissions_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."submissions"
    ADD CONSTRAINT "submissions_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "public"."assignment_variants"("id");



ALTER TABLE ONLY "public"."teacher_notes"
    ADD CONSTRAINT "teacher_notes_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."teacher_notes"
    ADD CONSTRAINT "teacher_notes_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."work_sessions"
    ADD CONSTRAINT "work_sessions_assignment_distribution_id_fkey" FOREIGN KEY ("assignment_distribution_id") REFERENCES "public"."assignment_distributions"("id");



ALTER TABLE ONLY "public"."work_sessions"
    ADD CONSTRAINT "work_sessions_assignment_id_fkey" FOREIGN KEY ("assignment_id") REFERENCES "public"."assignments"("id");



ALTER TABLE ONLY "public"."work_sessions"
    ADD CONSTRAINT "work_sessions_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."profiles"("id");



CREATE POLICY "Admins can create assignments" ON "public"."assignments" FOR INSERT WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can delete all assignments" ON "public"."assignments" FOR DELETE USING ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all assignment distributions" ON "public"."assignment_distributions" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all assignment questions" ON "public"."assignment_questions" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all assignment variants" ON "public"."assignment_variants" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all class members" ON "public"."class_members" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all class teachers" ON "public"."class_teachers" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all classes" ON "public"."classes" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all group members" ON "public"."group_members" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all groups" ON "public"."groups" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all question choices" ON "public"."question_choices" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all question objectives" ON "public"."question_objectives" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all questions" ON "public"."questions" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can manage all schools" ON "public"."schools" USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can read all profiles" ON "public"."profiles" FOR SELECT USING ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can update all assignments" ON "public"."assignments" FOR UPDATE USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can update all profiles" ON "public"."profiles" FOR UPDATE USING ("public"."is_admin"("auth"."uid"())) WITH CHECK ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can view all assignments" ON "public"."assignments" FOR SELECT USING ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can view all class members" ON "public"."class_members" FOR SELECT USING ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can view all classes" ON "public"."classes" FOR SELECT USING ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can view all group members" ON "public"."group_members" FOR SELECT USING ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can view all groups" ON "public"."groups" FOR SELECT USING ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can view all question choices" ON "public"."question_choices" FOR SELECT USING ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can view all questions" ON "public"."questions" FOR SELECT USING ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Admins can view all schools" ON "public"."schools" FOR SELECT USING ("public"."is_admin"("auth"."uid"()));



CREATE POLICY "Anyone can view choices of public questions" ON "public"."question_choices" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."questions" "q"
  WHERE (("q"."id" = "question_choices"."question_id") AND ("q"."is_public" = true)))));



CREATE POLICY "Anyone can view learning objectives" ON "public"."learning_objectives" FOR SELECT USING (true);



CREATE POLICY "Anyone can view objectives of public questions" ON "public"."question_objectives" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."questions" "q"
  WHERE (("q"."id" = "question_objectives"."question_id") AND ("q"."is_public" = true)))));



CREATE POLICY "Anyone can view public questions" ON "public"."questions" FOR SELECT USING (("is_public" = true));



CREATE POLICY "Authenticated users can insert file_links" ON "public"."file_links" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Authenticated users can read AI evaluations" ON "public"."ai_evaluations" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can read file_links" ON "public"."file_links" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can read files" ON "public"."files" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can read grade_overrides" ON "public"."grade_overrides" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can read question_stats" ON "public"."question_stats" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can read student_skill_mastery" ON "public"."student_skill_mastery" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Main teacher can manage class teachers" ON "public"."class_teachers" USING (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "class_id"))) WITH CHECK (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "class_id")));



CREATE POLICY "Students can view assigned assignments" ON "public"."assignments" FOR SELECT USING ("public"."is_assignment_distributed_to_student"("id", "auth"."uid"()));



CREATE POLICY "Students can view choices in assigned assignments" ON "public"."question_choices" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ((("public"."questions" "q"
     JOIN "public"."assignment_questions" "aq" ON (("aq"."question_id" = "q"."id")))
     JOIN "public"."assignments" "a" ON (("a"."id" = "aq"."assignment_id")))
     JOIN "public"."assignment_distributions" "ad" ON (("ad"."assignment_id" = "a"."id")))
  WHERE (("q"."id" = "question_choices"."question_id") AND ("a"."is_published" = true) AND ((("ad"."distribution_type" = 'class'::"text") AND ("ad"."class_id" IS NOT NULL) AND "public"."is_student_in_class"("auth"."uid"(), "ad"."class_id")) OR (("ad"."distribution_type" = 'group'::"text") AND ("ad"."group_id" IS NOT NULL) AND "public"."is_student_in_group"("auth"."uid"(), "ad"."group_id")) OR (("ad"."distribution_type" = 'individual'::"text") AND ("auth"."uid"() = ANY ("ad"."student_ids")))) AND (("ad"."available_from" IS NULL) OR ("ad"."available_from" <= "now"()))))));



CREATE POLICY "Students can view distributions for assigned assignments" ON "public"."assignment_distributions" FOR SELECT USING ("public"."is_assignment_distributed_to_student"("assignment_id", "auth"."uid"()));



CREATE POLICY "Students can view enrolled classes" ON "public"."classes" FOR SELECT USING ("public"."is_student_in_class_any_status"("auth"."uid"(), "id"));



CREATE POLICY "Students can view groups they belong to" ON "public"."groups" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "groups"."id") AND ("gm"."student_id" = "auth"."uid"())))));



CREATE POLICY "Students can view own group memberships" ON "public"."group_members" FOR SELECT USING (("student_id" = "auth"."uid"()));



CREATE POLICY "Students can view own memberships" ON "public"."class_members" FOR SELECT USING (("student_id" = "auth"."uid"()));



CREATE POLICY "Students can view own variants" ON "public"."assignment_variants" FOR SELECT USING (((("variant_type" = 'student'::"text") AND ("student_id" = "auth"."uid"())) OR (("variant_type" = 'group'::"text") AND "public"."is_student_in_group"("auth"."uid"(), "group_id")) OR (("variant_type" = 'global'::"text") AND (EXISTS ( SELECT 1
   FROM ("public"."assignment_distributions" "ad"
     JOIN "public"."assignments" "a" ON (("a"."id" = "ad"."assignment_id")))
  WHERE (("ad"."assignment_id" = "assignment_variants"."assignment_id") AND ("a"."is_published" = true) AND ((("ad"."distribution_type" = 'class'::"text") AND ("ad"."class_id" IS NOT NULL) AND "public"."is_student_in_class"("auth"."uid"(), "ad"."class_id")) OR (("ad"."distribution_type" = 'group'::"text") AND ("ad"."group_id" IS NOT NULL) AND "public"."is_student_in_group"("auth"."uid"(), "ad"."group_id")) OR (("ad"."distribution_type" = 'individual'::"text") AND ("auth"."uid"() = ANY ("ad"."student_ids"))))))))));



CREATE POLICY "Students can view questions in assigned assignments" ON "public"."assignment_questions" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."assignments" "a"
     JOIN "public"."assignment_distributions" "ad" ON (("ad"."assignment_id" = "a"."id")))
  WHERE (("a"."id" = "assignment_questions"."assignment_id") AND ("a"."is_published" = true) AND ((("ad"."distribution_type" = 'class'::"text") AND ("ad"."class_id" IS NOT NULL) AND "public"."is_student_in_class"("auth"."uid"(), "ad"."class_id")) OR (("ad"."distribution_type" = 'group'::"text") AND ("ad"."group_id" IS NOT NULL) AND "public"."is_student_in_group"("auth"."uid"(), "ad"."group_id")) OR (("ad"."distribution_type" = 'individual'::"text") AND ("auth"."uid"() = ANY ("ad"."student_ids")))) AND (("ad"."available_from" IS NULL) OR ("ad"."available_from" <= "now"()))))));



CREATE POLICY "Students can view questions in assigned assignments" ON "public"."questions" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (("public"."assignment_questions" "aq"
     JOIN "public"."assignments" "a" ON (("a"."id" = "aq"."assignment_id")))
     JOIN "public"."assignment_distributions" "ad" ON (("ad"."assignment_id" = "a"."id")))
  WHERE (("aq"."question_id" = "questions"."id") AND ("a"."is_published" = true) AND ((("ad"."distribution_type" = 'class'::"text") AND ("ad"."class_id" IS NOT NULL) AND "public"."is_student_in_class"("auth"."uid"(), "ad"."class_id")) OR (("ad"."distribution_type" = 'group'::"text") AND ("ad"."group_id" IS NOT NULL) AND "public"."is_student_in_group"("auth"."uid"(), "ad"."group_id")) OR (("ad"."distribution_type" = 'individual'::"text") AND ("auth"."uid"() = ANY ("ad"."student_ids")))) AND (("ad"."available_from" IS NULL) OR ("ad"."available_from" <= "now"()))))));



CREATE POLICY "System can manage question_stats" ON "public"."question_stats" TO "authenticated" USING (true);



CREATE POLICY "System can manage student_skill_mastery" ON "public"."student_skill_mastery" TO "authenticated" USING (true);



CREATE POLICY "System can manage submission_analytics" ON "public"."submission_analytics" TO "authenticated" USING (true);



CREATE POLICY "Teachers and admins can manage learning objectives" ON "public"."learning_objectives" USING (("public"."is_teacher"("auth"."uid"()) OR "public"."is_admin"("auth"."uid"()))) WITH CHECK (("public"."is_teacher"("auth"."uid"()) OR "public"."is_admin"("auth"."uid"())));



CREATE POLICY "Teachers can create assignments" ON "public"."assignments" FOR INSERT WITH CHECK ((("teacher_id" = "auth"."uid"()) AND (("class_id" IS NULL) OR "public"."is_teacher_owner_of_class"("auth"."uid"(), "class_id"))));



CREATE POLICY "Teachers can delete own unpublished assignments" ON "public"."assignments" FOR DELETE USING ((("teacher_id" = "auth"."uid"()) AND ("is_published" = false)));



CREATE POLICY "Teachers can manage AI evaluations" ON "public"."ai_evaluations" TO "authenticated" USING (true);



CREATE POLICY "Teachers can manage AI queue" ON "public"."ai_queue" TO "authenticated" USING (true);



CREATE POLICY "Teachers can manage choices of own questions" ON "public"."question_choices" USING ((EXISTS ( SELECT 1
   FROM "public"."questions" "q"
  WHERE (("q"."id" = "question_choices"."question_id") AND ("q"."author_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."questions" "q"
  WHERE (("q"."id" = "question_choices"."question_id") AND ("q"."author_id" = "auth"."uid"())))));



CREATE POLICY "Teachers can manage distributions for own assignments" ON "public"."assignment_distributions" USING ((EXISTS ( SELECT 1
   FROM "public"."assignments" "a"
  WHERE (("a"."id" = "assignment_distributions"."assignment_id") AND ("a"."teacher_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."assignments" "a"
  WHERE (("a"."id" = "assignment_distributions"."assignment_id") AND ("a"."teacher_id" = "auth"."uid"())))));



CREATE POLICY "Teachers can manage grade_overrides" ON "public"."grade_overrides" TO "authenticated" USING (true);



CREATE POLICY "Teachers can manage groups of own classes" ON "public"."groups" USING (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "class_id"))) WITH CHECK (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "class_id")));



CREATE POLICY "Teachers can manage members of groups in own classes" ON "public"."group_members" USING (("public"."is_teacher"("auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."groups" "g"
  WHERE (("g"."id" = "group_members"."group_id") AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "g"."class_id")))))) WITH CHECK (("public"."is_teacher"("auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."groups" "g"
  WHERE (("g"."id" = "group_members"."group_id") AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "g"."class_id"))))));



CREATE POLICY "Teachers can manage members of own classes" ON "public"."class_members" USING (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "class_id"))) WITH CHECK (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "class_id")));



CREATE POLICY "Teachers can manage objectives of own questions" ON "public"."question_objectives" USING ((EXISTS ( SELECT 1
   FROM "public"."questions" "q"
  WHERE (("q"."id" = "question_objectives"."question_id") AND ("q"."author_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."questions" "q"
  WHERE (("q"."id" = "question_objectives"."question_id") AND ("q"."author_id" = "auth"."uid"())))));



CREATE POLICY "Teachers can manage own classes" ON "public"."classes" USING (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "id"))) WITH CHECK (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "id")));



CREATE POLICY "Teachers can manage own questions" ON "public"."questions" USING (("author_id" = "auth"."uid"())) WITH CHECK (("author_id" = "auth"."uid"()));



CREATE POLICY "Teachers can manage questions in own assignments" ON "public"."assignment_questions" USING ((EXISTS ( SELECT 1
   FROM "public"."assignments" "a"
  WHERE (("a"."id" = "assignment_questions"."assignment_id") AND ("a"."teacher_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."assignments" "a"
  WHERE (("a"."id" = "assignment_questions"."assignment_id") AND ("a"."teacher_id" = "auth"."uid"())))));



CREATE POLICY "Teachers can manage their ai_recommendations" ON "public"."ai_recommendations" TO "authenticated" USING (("auth"."uid"() = "teacher_id"));



CREATE POLICY "Teachers can manage their teacher_notes" ON "public"."teacher_notes" TO "authenticated" USING (("auth"."uid"() = "teacher_id"));



CREATE POLICY "Teachers can manage variants in own assignments" ON "public"."assignment_variants" USING ((EXISTS ( SELECT 1
   FROM "public"."assignments" "a"
  WHERE (("a"."id" = "assignment_variants"."assignment_id") AND ("a"."teacher_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."assignments" "a"
  WHERE (("a"."id" = "assignment_variants"."assignment_id") AND ("a"."teacher_id" = "auth"."uid"())))));



CREATE POLICY "Teachers can read AI queue" ON "public"."ai_queue" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Teachers can read student profiles in their classes" ON "public"."profiles" FOR SELECT USING (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_of_student_class"("auth"."uid"(), "id")));



CREATE POLICY "Teachers can read submission_analytics" ON "public"."submission_analytics" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Teachers can update own assignments" ON "public"."assignments" FOR UPDATE USING (("teacher_id" = "auth"."uid"())) WITH CHECK (("teacher_id" = "auth"."uid"()));



CREATE POLICY "Teachers can update submission_answers" ON "public"."submission_answers" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM ("public"."work_sessions" "ws"
     JOIN "public"."assignments" "a" ON (("a"."id" = "ws"."assignment_id")))
  WHERE (("ws"."id" = "submission_answers"."session_id") AND ("a"."teacher_id" = "auth"."uid"())))));



CREATE POLICY "Teachers can update submissions" ON "public"."submissions" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."assignments" "a"
  WHERE (("a"."id" = "submissions"."assignment_id") AND ("a"."teacher_id" = "auth"."uid"())))));



CREATE POLICY "Teachers can view choices of own questions" ON "public"."question_choices" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."questions" "q"
  WHERE (("q"."id" = "question_choices"."question_id") AND ("q"."author_id" = "auth"."uid"())))));



CREATE POLICY "Teachers can view groups of own classes" ON "public"."groups" FOR SELECT USING (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "class_id")));



CREATE POLICY "Teachers can view members of groups in own classes" ON "public"."group_members" FOR SELECT USING (("public"."is_teacher"("auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."groups" "g"
  WHERE (("g"."id" = "group_members"."group_id") AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "g"."class_id"))))));



CREATE POLICY "Teachers can view members of own classes" ON "public"."class_members" FOR SELECT USING (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "class_id")));



CREATE POLICY "Teachers can view own assignments" ON "public"."assignments" FOR SELECT USING (("teacher_id" = "auth"."uid"()));



CREATE POLICY "Teachers can view own classes" ON "public"."classes" FOR SELECT USING (("public"."is_teacher"("auth"."uid"()) AND "public"."is_teacher_owner_of_class"("auth"."uid"(), "id")));



CREATE POLICY "Teachers can view own questions" ON "public"."questions" FOR SELECT USING (("author_id" = "auth"."uid"()));



CREATE POLICY "Teachers can view submission_answers for their assignments" ON "public"."submission_answers" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."work_sessions" "ws"
     JOIN "public"."assignments" "a" ON (("a"."id" = "ws"."assignment_id")))
  WHERE (("ws"."id" = "submission_answers"."session_id") AND ("a"."teacher_id" = "auth"."uid"())))));



CREATE POLICY "Teachers can view submissions for their assignments" ON "public"."submissions" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."assignments" "a"
  WHERE (("a"."id" = "submissions"."assignment_id") AND ("a"."teacher_id" = "auth"."uid"())))));



CREATE POLICY "Teachers can view work_sessions for their assignments" ON "public"."work_sessions" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."assignments" "a"
  WHERE (("a"."id" = "work_sessions"."assignment_id") AND ("a"."teacher_id" = "auth"."uid"())))));



CREATE POLICY "Users can insert their own autosave_answers" ON "public"."autosave_answers" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."work_sessions" "ws"
  WHERE (("ws"."id" = "autosave_answers"."session_id") AND ("ws"."student_id" = "auth"."uid"())))));



CREATE POLICY "Users can insert their own files" ON "public"."files" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "uploaded_by"));



CREATE POLICY "Users can insert their own submission_answers" ON "public"."submission_answers" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."work_sessions" "ws"
  WHERE (("ws"."id" = "submission_answers"."session_id") AND ("ws"."student_id" = "auth"."uid"())))));



CREATE POLICY "Users can insert their own submissions" ON "public"."submissions" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));



CREATE POLICY "Users can insert their own work_sessions" ON "public"."work_sessions" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));



CREATE POLICY "Users can read own profile" ON "public"."profiles" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can update own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can update their own autosave_answers" ON "public"."autosave_answers" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."work_sessions" "ws"
  WHERE (("ws"."id" = "autosave_answers"."session_id") AND ("ws"."student_id" = "auth"."uid"())))));



CREATE POLICY "Users can update their own work_sessions" ON "public"."work_sessions" FOR UPDATE USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Users can view schools they are related to" ON "public"."schools" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."classes" "c"
  WHERE (("c"."school_id" = "schools"."id") AND (("c"."teacher_id" = "auth"."uid"()) OR "public"."is_student_in_class_any_status"("auth"."uid"(), "c"."id"))))));



CREATE POLICY "Users can view their own autosave_answers" ON "public"."autosave_answers" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."work_sessions" "ws"
  WHERE (("ws"."id" = "autosave_answers"."session_id") AND ("ws"."student_id" = "auth"."uid"())))));



CREATE POLICY "Users can view their own submission_answers" ON "public"."submission_answers" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."work_sessions" "ws"
  WHERE (("ws"."id" = "submission_answers"."session_id") AND ("ws"."student_id" = "auth"."uid"())))));



CREATE POLICY "Users can view their own submissions" ON "public"."submissions" FOR SELECT USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Users can view their own work_sessions" ON "public"."work_sessions" FOR SELECT USING (("auth"."uid"() = "student_id"));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."submissions";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."work_sessions";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";




























































































































































GRANT ALL ON FUNCTION "public"."create_assignment_with_questions"("p_teacher_id" "uuid", "p_payload" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_assignment_with_questions"("p_teacher_id" "uuid", "p_payload" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_assignment_with_questions"("p_teacher_id" "uuid", "p_payload" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_class_student_variants"("p_assignment_id" "uuid", "p_class_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."create_class_student_variants"("p_assignment_id" "uuid", "p_class_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_class_student_variants"("p_assignment_id" "uuid", "p_class_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_group_variant"("p_assignment_id" "uuid", "p_group_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."create_group_variant"("p_assignment_id" "uuid", "p_group_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_group_variant"("p_assignment_id" "uuid", "p_group_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_groups_variants"("p_assignment_id" "uuid", "p_group_ids" "uuid"[], "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."create_groups_variants"("p_assignment_id" "uuid", "p_group_ids" "uuid"[], "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_groups_variants"("p_assignment_id" "uuid", "p_group_ids" "uuid"[], "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_student_variant"("p_assignment_id" "uuid", "p_student_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."create_student_variant"("p_assignment_id" "uuid", "p_student_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_student_variant"("p_assignment_id" "uuid", "p_student_id" "uuid", "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_students_variants"("p_assignment_id" "uuid", "p_student_ids" "uuid"[], "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."create_students_variants"("p_assignment_id" "uuid", "p_student_ids" "uuid"[], "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_students_variants"("p_assignment_id" "uuid", "p_student_ids" "uuid"[], "p_shuffle_questions" boolean, "p_shuffle_choices" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."ensure_student_variant"("p_assignment_id" "uuid", "p_student_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."ensure_student_variant"("p_assignment_id" "uuid", "p_student_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ensure_student_variant"("p_assignment_id" "uuid", "p_student_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_role_safe"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_role_safe"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_role_safe"("user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin"("user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_assignment_distributed_to_student"("assignment_id_param" "uuid", "student_id_param" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_assignment_distributed_to_student"("assignment_id_param" "uuid", "student_id_param" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_assignment_distributed_to_student"("assignment_id_param" "uuid", "student_id_param" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_student_in_class"("student_id" "uuid", "class_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_student_in_class"("student_id" "uuid", "class_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_student_in_class"("student_id" "uuid", "class_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_student_in_class_any_status"("student_id" "uuid", "class_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_student_in_class_any_status"("student_id" "uuid", "class_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_student_in_class_any_status"("student_id" "uuid", "class_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_student_in_group"("student_id" "uuid", "group_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_student_in_group"("student_id" "uuid", "group_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_student_in_group"("student_id" "uuid", "group_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_teacher"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_teacher"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_teacher"("user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_teacher_of_student_class"("teacher_id" "uuid", "student_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_teacher_of_student_class"("teacher_id" "uuid", "student_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_teacher_of_student_class"("teacher_id" "uuid", "student_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_teacher_owner_of_class"("teacher_id" "uuid", "class_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_teacher_owner_of_class"("teacher_id" "uuid", "class_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_teacher_owner_of_class"("teacher_id" "uuid", "class_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."publish_assignment"("p_assignment" "jsonb", "p_questions" "jsonb", "p_distributions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."publish_assignment"("p_assignment" "jsonb", "p_questions" "jsonb", "p_distributions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."publish_assignment"("p_assignment" "jsonb", "p_questions" "jsonb", "p_distributions" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."shuffle_with_seed"("p_array" "jsonb", "p_seed" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."shuffle_with_seed"("p_array" "jsonb", "p_seed" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."shuffle_with_seed"("p_array" "jsonb", "p_seed" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";


















GRANT ALL ON TABLE "public"."ai_evaluations" TO "anon";
GRANT ALL ON TABLE "public"."ai_evaluations" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_evaluations" TO "service_role";



GRANT ALL ON TABLE "public"."ai_queue" TO "anon";
GRANT ALL ON TABLE "public"."ai_queue" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_queue" TO "service_role";



GRANT ALL ON TABLE "public"."ai_recommendations" TO "anon";
GRANT ALL ON TABLE "public"."ai_recommendations" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_recommendations" TO "service_role";



GRANT ALL ON TABLE "public"."assignment_distributions" TO "anon";
GRANT ALL ON TABLE "public"."assignment_distributions" TO "authenticated";
GRANT ALL ON TABLE "public"."assignment_distributions" TO "service_role";



GRANT ALL ON TABLE "public"."assignment_questions" TO "anon";
GRANT ALL ON TABLE "public"."assignment_questions" TO "authenticated";
GRANT ALL ON TABLE "public"."assignment_questions" TO "service_role";



GRANT ALL ON TABLE "public"."assignment_variants" TO "anon";
GRANT ALL ON TABLE "public"."assignment_variants" TO "authenticated";
GRANT ALL ON TABLE "public"."assignment_variants" TO "service_role";



GRANT ALL ON TABLE "public"."assignments" TO "anon";
GRANT ALL ON TABLE "public"."assignments" TO "authenticated";
GRANT ALL ON TABLE "public"."assignments" TO "service_role";



GRANT ALL ON TABLE "public"."autosave_answers" TO "anon";
GRANT ALL ON TABLE "public"."autosave_answers" TO "authenticated";
GRANT ALL ON TABLE "public"."autosave_answers" TO "service_role";



GRANT ALL ON TABLE "public"."class_members" TO "anon";
GRANT ALL ON TABLE "public"."class_members" TO "authenticated";
GRANT ALL ON TABLE "public"."class_members" TO "service_role";



GRANT ALL ON TABLE "public"."class_teachers" TO "anon";
GRANT ALL ON TABLE "public"."class_teachers" TO "authenticated";
GRANT ALL ON TABLE "public"."class_teachers" TO "service_role";



GRANT ALL ON TABLE "public"."classes" TO "anon";
GRANT ALL ON TABLE "public"."classes" TO "authenticated";
GRANT ALL ON TABLE "public"."classes" TO "service_role";



GRANT ALL ON TABLE "public"."file_links" TO "anon";
GRANT ALL ON TABLE "public"."file_links" TO "authenticated";
GRANT ALL ON TABLE "public"."file_links" TO "service_role";



GRANT ALL ON TABLE "public"."files" TO "anon";
GRANT ALL ON TABLE "public"."files" TO "authenticated";
GRANT ALL ON TABLE "public"."files" TO "service_role";



GRANT ALL ON TABLE "public"."grade_overrides" TO "anon";
GRANT ALL ON TABLE "public"."grade_overrides" TO "authenticated";
GRANT ALL ON TABLE "public"."grade_overrides" TO "service_role";



GRANT ALL ON TABLE "public"."group_members" TO "anon";
GRANT ALL ON TABLE "public"."group_members" TO "authenticated";
GRANT ALL ON TABLE "public"."group_members" TO "service_role";



GRANT ALL ON TABLE "public"."groups" TO "anon";
GRANT ALL ON TABLE "public"."groups" TO "authenticated";
GRANT ALL ON TABLE "public"."groups" TO "service_role";



GRANT ALL ON TABLE "public"."learning_objectives" TO "anon";
GRANT ALL ON TABLE "public"."learning_objectives" TO "authenticated";
GRANT ALL ON TABLE "public"."learning_objectives" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."question_choices" TO "anon";
GRANT ALL ON TABLE "public"."question_choices" TO "authenticated";
GRANT ALL ON TABLE "public"."question_choices" TO "service_role";



GRANT ALL ON TABLE "public"."question_objectives" TO "anon";
GRANT ALL ON TABLE "public"."question_objectives" TO "authenticated";
GRANT ALL ON TABLE "public"."question_objectives" TO "service_role";



GRANT ALL ON TABLE "public"."question_stats" TO "anon";
GRANT ALL ON TABLE "public"."question_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."question_stats" TO "service_role";



GRANT ALL ON TABLE "public"."questions" TO "anon";
GRANT ALL ON TABLE "public"."questions" TO "authenticated";
GRANT ALL ON TABLE "public"."questions" TO "service_role";



GRANT ALL ON TABLE "public"."schools" TO "anon";
GRANT ALL ON TABLE "public"."schools" TO "authenticated";
GRANT ALL ON TABLE "public"."schools" TO "service_role";



GRANT ALL ON TABLE "public"."student_skill_mastery" TO "anon";
GRANT ALL ON TABLE "public"."student_skill_mastery" TO "authenticated";
GRANT ALL ON TABLE "public"."student_skill_mastery" TO "service_role";



GRANT ALL ON TABLE "public"."submission_analytics" TO "anon";
GRANT ALL ON TABLE "public"."submission_analytics" TO "authenticated";
GRANT ALL ON TABLE "public"."submission_analytics" TO "service_role";



GRANT ALL ON TABLE "public"."submission_answers" TO "anon";
GRANT ALL ON TABLE "public"."submission_answers" TO "authenticated";
GRANT ALL ON TABLE "public"."submission_answers" TO "service_role";



GRANT ALL ON TABLE "public"."submissions" TO "anon";
GRANT ALL ON TABLE "public"."submissions" TO "authenticated";
GRANT ALL ON TABLE "public"."submissions" TO "service_role";



GRANT ALL ON TABLE "public"."teacher_notes" TO "anon";
GRANT ALL ON TABLE "public"."teacher_notes" TO "authenticated";
GRANT ALL ON TABLE "public"."teacher_notes" TO "service_role";



GRANT ALL ON TABLE "public"."work_sessions" TO "anon";
GRANT ALL ON TABLE "public"."work_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."work_sessions" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































