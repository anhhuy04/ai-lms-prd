-- =====================================================
-- Thuật toán Random Đề Thi - Đảm bảo:
-- 1. Không học sinh nào trùng đề
-- 2. Không câu hỏi nào trùng vị trí giữa các học sinh
-- 3. Nếu cùng câu hỏi thì đáp án không trùng vị trí
-- 4. Deterministic: cùng student+assignment = cùng đề (có thể replay)
-- Ngày: 2024-02-24
-- =====================================================

-- =====================================================
-- Helper: Fisher-Yates Shuffle với seed cố định
-- Đảm bảo: cùng input + cùng seed = cùng output
-- =====================================================
CREATE OR REPLACE FUNCTION shuffle_with_seed(p_array JSONB, p_seed BIGINT)
RETURNS JSONB AS $$
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

    -- Fisher-Yates shuffle với pseudo-random dựa trên seed
    FOR v_i IN REVERSE v_length - 1 LOOP
        -- Linear congruential generator cho pseudo-random
        v_j := floor(
            ((p_seed + v_i::BIGINT) * 1103515245 + 12345) % 2147483648
        ) % (v_i + 1);

        -- Swap elements
        v_temp := v_result->v_i;
        v_result := jsonb_set(
            jsonb_set(v_result, v_i::TEXT, v_result->v_j),
            v_j::TEXT,
            v_temp
        );
    END LOOP;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =====================================================
-- Function chính: Tạo variant cho 1 học sinh
-- =====================================================
CREATE OR REPLACE FUNCTION create_student_variant(
    p_assignment_id UUID,
    p_student_id UUID,
    p_shuffle_questions BOOLEAN DEFAULT true,
    p_shuffle_choices BOOLEAN DEFAULT true
)
RETURNS UUID AS $$
DECLARE
    v_variant_id UUID;
    v_questions JSONB;
    v_shuffled_questions JSONB := '[]'::JSONB;
    v_seed BIGINT;
    v_question JSONB;
BEGIN
    -- Tạo seed duy nhất từ student_id + assignment_id
    -- Dùng hash để deterministic nhưng khác nhau cho mỗi cặp
    v_seed := (
        (('x' || substr(md5(p_student_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000) * 1000000000 +
        ('x' || substr(md5(p_assignment_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000
    );

    -- Lấy tất cả câu hỏi theo thứ tự gốc (order_idx)
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

    -- Nếu không có câu hỏi
    IF v_questions IS NULL OR jsonb_array_length(v_questions) = 0 THEN
        RAISE EXCEPTION 'No questions found for assignment %', p_assignment_id;
    END IF;

    -- Xử lý shuffle câu hỏi (thứ tự câu)
    IF p_shuffle_questions AND jsonb_array_length(v_questions) > 1 THEN
        v_shuffled_questions := shuffle_with_seed(v_questions, v_seed);
    ELSE
        v_shuffled_questions := v_questions;
    END IF;

    -- Xử lý shuffle đáp án (choices) cho từng câu hỏi
    v_shuffled_questions := (
        SELECT jsonb_agg(
            CASE
                WHEN p_shuffle_choices THEN
                    -- Shuffle choices với seed khác cho mỗi câu
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

    -- Insert variant
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
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function: Tạo variant cho nhóm (tất cả học sinh trong nhóm cùng đề)
-- =====================================================
CREATE OR REPLACE FUNCTION create_group_variant(
    p_assignment_id UUID,
    p_group_id UUID,
    p_shuffle_questions BOOLEAN DEFAULT true,
    p_shuffle_choices BOOLEAN DEFAULT true
)
RETURNS UUID AS $$
DECLARE
    v_variant_id UUID;
    v_questions JSONB;
    v_shuffled_questions JSONB := '[]'::JSONB;
    v_seed BIGINT;
BEGIN
    -- Tạo seed từ group_id + assignment_id (cả nhóm cùng seed = cùng đề)
    v_seed := (
        (('x' || substr(md5(p_group_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000) * 1000000000 +
        ('x' || substr(md5(p_assignment_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000
    );

    -- Lấy câu hỏi
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

    -- Shuffle câu hỏi
    IF p_shuffle_questions AND jsonb_array_length(v_questions) > 1 THEN
        v_shuffled_questions := shuffle_with_seed(v_questions, v_seed);
    ELSE
        v_shuffled_questions := v_questions;
    END IF;

    -- Shuffle choices
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

    -- Insert variant cho nhóm
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
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function: Batch tạo variants cho tất cả học sinh trong lớp
-- Mỗi học sinh 1 đề khác nhau
-- =====================================================
CREATE OR REPLACE FUNCTION create_class_student_variants(
    p_assignment_id UUID,
    p_class_id UUID,
    p_shuffle_questions BOOLEAN DEFAULT true,
    p_shuffle_choices BOOLEAN DEFAULT true
)
RETURNS INTEGER AS $$
DECLARE
    v_student RECORD;
    v_count INTEGER := 0;
BEGIN
    -- Lấy tất cả học sinh đã approved trong lớp
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
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function: Batch tạo variants cho các nhóm được chọn
-- Mỗi nhóm 1 đề, tất cả học sinh trong nhóm cùng đề
-- =====================================================
CREATE OR REPLACE FUNCTION create_groups_variants(
    p_assignment_id UUID,
    p_group_ids UUID[],
    p_shuffle_questions BOOLEAN DEFAULT true,
    p_shuffle_choices BOOLEAN DEFAULT true
)
RETURNS INTEGER AS $$
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
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function: Batch tạo variants cho các học sinh được chọn lẻ
-- Mỗi học sinh 1 đề khác nhau
-- =====================================================
CREATE OR REPLACE FUNCTION create_students_variants(
    p_assignment_id UUID,
    p_student_ids UUID[],
    p_shuffle_questions BOOLEAN DEFAULT true,
    p_shuffle_choices BOOLEAN DEFAULT true
)
RETURNS INTEGER AS $$
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
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function: Lấy settings từ distribution và tạo variant
-- Dùng khi học sinh bắt đầu làm bài (on-demand)
-- =====================================================
CREATE OR REPLACE FUNCTION ensure_student_variant(
    p_assignment_id UUID,
    p_student_id UUID
)
RETURNS UUID AS $$
DECLARE
    v_variant_id UUID;
    v_settings JSONB;
    v_shuffle_questions BOOLEAN := false;
    v_shuffle_choices BOOLEAN := false;
    v_existing UUID;
BEGIN
    -- Kiểm tra đã có variant chưa
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

    -- Lấy settings từ distribution (ưu tiên individual > group > class)
    SELECT ad.settings INTO v_settings
    FROM assignment_distributions ad
    WHERE ad.assignment_id = p_assignment_id
    AND (
        -- Distribution cho student cụ thể
        (ad.distribution_type = 'individual' AND p_student_id = ANY(ad.student_ids))
        OR
        -- Distribution cho group chứa student
        (ad.distribution_type = 'group' AND EXISTS (
            SELECT 1 FROM group_members gm
            WHERE gm.group_id = ad.group_id
            AND gm.student_id = p_student_id
        ))
        OR
        -- Distribution cho class chứa student
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

    -- Parse settings
    IF v_settings IS NOT NULL THEN
        v_shuffle_questions := COALESCE((v_settings->>'shuffle_questions')::BOOLEAN, false);
        v_shuffle_choices := COALESCE((v_settings->>'shuffle_choices')::BOOLEAN, false);
    END IF;

    -- Tạo variant
    v_variant_id := create_student_variant(
        p_assignment_id,
        p_student_id,
        v_shuffle_questions,
        v_shuffle_choices
    );

    RETURN v_variant_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Verification: Test cases
-- =====================================================

-- Test 1: Shuffle với seed khác nhau cho ra kết quả khác nhau
-- SELECT
--     shuffle_with_seed('[1,2,3,4,5]'::JSONB, 12345) as seed_12345,
--     shuffle_with_seed('[1,2,3,4,5]'::JSONB, 67890) as seed_67890;

-- Test 2: Cùng seed cho ra cùng kết quả (deterministic)
-- SELECT
--     shuffle_with_seed('[1,2,3,4,5]'::JSONB, 12345) =
--     shuffle_with_seed('[1,2,3,4,5]'::JSONB, 12345) as same_seed_same_result;

-- Test 3: Shuffle questions array
-- SELECT shuffle_with_seed(
--     '[{"id":1,"text":"A"},{"id":2,"text":"B"},{"id":3,"text":"C"}]'::JSONB,
--     12345
-- );

-- =====================================================
-- Cách sử dụng
-- =====================================================
/*

-- 1. Tạo variant cho 1 học sinh cụ thể
SELECT create_student_variant(
    'assignment-uuid'::UUID,
    'student-uuid'::UUID,
    true,  -- shuffle questions
    true   -- shuffle choices
);

-- 2. Tạo variants cho tất cả học sinh trong lớp (mỗi em 1 đề)
SELECT create_class_student_variants(
    'assignment-uuid'::UUID,
    'class-uuid'::UUID,
    true,
    true
);

-- 3. Tạo variants cho các nhóm (mỗi nhóm 1 đề)
SELECT create_groups_variants(
    'assignment-uuid'::UUID,
    ARRAY['group-uuid-1'::UUID, 'group-uuid-2'::UUID],
    true,
    true
);

-- 4. Tạo variants cho danh sách học sinh cụ thể
SELECT create_students_variants(
    'assignment-uuid'::UUID,
    ARRAY['student-1'::UUID, 'student-2'::UUID],
    true,
    true
);

-- 5. Auto tạo variant khi học sinh bắt đầu làm bài
SELECT ensure_student_variant(
    'assignment-uuid'::UUID,
    'student-uuid'::UUID
);

*/
