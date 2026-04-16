-- =============================================================
-- Migration 008: Fix legacy choice IDs (UUID string → INT 0-based)
-- Áp dụng cho: assignment_questions.custom_content.choices[]
-- =============================================================

CREATE OR REPLACE FUNCTION fix_legacy_choice_ids_in_assignment_questions()
RETURNS void AS $$
DECLARE
  rec RECORD;
  old_choices JSONB;
  new_choices JSONB;
  new_choice JSONB;
  choice_elem JSONB;
  idx INTEGER;
BEGIN
  FOR rec IN
    SELECT id, custom_content
    FROM assignment_questions
    WHERE custom_content IS NOT NULL
      AND custom_content ? 'choices'
      AND jsonb_typeof(custom_content->'choices') = 'array'
  LOOP
    old_choices := rec.custom_content->'choices';
    new_choices := '[]'::JSONB;
    idx := 0;

    FOR choice_elem IN SELECT * FROM jsonb_array_elements(old_choices)
    LOOP
      -- Chỉ cần fix nếu ID là string (UUID), nếu đã là integer thì skip
      IF jsonb_typeof(choice_elem->'id') = 'string' THEN
        new_choice := jsonb_set(choice_elem, '{id}', to_jsonb(idx));
      ELSE
        new_choice := choice_elem;
      END IF;

      new_choices := new_choices || jsonb_build_array(new_choice);
      idx := idx + 1;
    END LOOP;

    UPDATE assignment_questions
    SET custom_content = jsonb_set(custom_content, '{choices}', new_choices)
    WHERE id = rec.id;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Chạy migration
SELECT fix_legacy_choice_ids_in_assignment_questions();

-- Cleanup function sau khi dùng
DROP FUNCTION fix_legacy_choice_ids_in_assignment_questions();
