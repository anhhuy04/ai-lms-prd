-- Migration: RPC create_assignment_with_questions
-- Mục tiêu: Tạo bài tập (assignments) + gắn câu hỏi (assignment_questions) + (tùy chọn) tạo mới câu hỏi bank
-- trong một transaction duy nhất, tuân thủ luồng Question Bank.

create or replace function public.create_assignment_with_questions(
  p_teacher_id uuid,
  p_payload jsonb
)
returns uuid
language plpgsql
as $$
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

