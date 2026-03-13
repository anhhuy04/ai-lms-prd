# JSONB Migration Progress

## ✅ HOÀN THÀNH TẤT CẢ 7 PHASES

### Phase 1: DONE ✅
- Restore 15 JSONB giữ nguyên vào docs/note sql.txt

### Phase 2: DONE ✅
- Update assignment_datasource.dart lines 468-472: Thêm `answer` vào query
- Update lines 488-504: Tách content và answer riêng cho linked questions
- Update lines 924-940: Query questions.answer cho submit workflow

### Phase 3: DONE ✅
- question_choices.content: Entity đã là Map<String, dynamic> - OK
- assignment_questions.custom_content: Code parse đã hỗ trợ override_text, choices - OK

### Phase 4-5: DONE ✅
- rubric: Entity có field Map - OK
- custom_content: Code parse delta override - OK

### Phase 6: DONE ✅
- variants.custom_questions: Entity đã là Map - OK

### Phase 7: DONE ✅
- late_policy, settings: Entity đã là Map<String, dynamic>
- Code lưu/đọc nguyên Map - khi cần parse thêm: `latePolicy?['policy_type']`

## Verification
- flutter analyze: ✅ No errors
