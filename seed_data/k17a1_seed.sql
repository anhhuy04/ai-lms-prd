-- ============================================================
-- SEED: Lớp K17A1 - Lập trình Python & Web
-- Teacher: Phạm Thị Đào | Main student: Thái Anh Huy
-- Generated: 2026-03-31
-- ============================================================
BEGIN;
SET session_replication_role = replica;

-- ═══ 1. CLASS K17A1 ═══
INSERT INTO public.classes (id, school_id, teacher_id, name, subject, academic_year, description, class_settings, created_at)
VALUES ('aa010001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000001', '51e467a2-9033-5e85-b666-164ea075f6c9', 'K17A1', 'Lập trình Python & Web', '2025-2026',
  'Lớp K17 nhóm A1 - Chuyên ngành Công nghệ Thông tin. Học phần Lập trình Python ứng dụng Web.',
  '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": "K17A1-2026", "expires_at": null, "require_approval": false}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}', '2025-09-01T00:00:00+00:00') ON CONFLICT (id) DO NOTHING;

-- ═══ 2. CLASS_TEACHERS ═══
INSERT INTO public.class_teachers (id, class_id, teacher_id, role)
VALUES ('a0010001-0000-0000-0000-000000000001', 'aa010001-0000-0000-0000-000000000001', '51e467a2-9033-5e85-b666-164ea075f6c9', 'teacher') ON CONFLICT DO NOTHING;

-- ═══ 3. CLASS_MEMBERS (16 students) ═══
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', 'b3e27ac4-a528-5174-92f8-99a8f273eb84', 'student', '2026-01-11T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Thái Anh Huy
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', 'e274bfde-ca3f-56f8-a803-6008bbdbc1e5', 'student', '2026-01-11T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Bùi Đình Anh
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', '13d565a8-ccb5-56fe-a884-30df48099615', 'student', '2026-01-11T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Bùi Quang Linh
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', '2154f53c-8e69-551b-8c0d-5a2457b15fd8', 'student', '2026-01-11T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Bùi Quang Minh
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', '0009cad5-6c63-5cc3-9596-dd0ed89ac948', 'student', '2026-01-12T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Cao Cường
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', 'd0318e10-3203-5130-9992-fba4053f5edb', 'student', '2026-01-12T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Cao Đức Anh Quân
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', '5cbaae02-acd6-5121-83b2-f76819103ad2', 'student', '2026-01-12T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Cao Việt Hoàng
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', 'c8778c6b-7099-5c09-916c-6b0dabafde41', 'student', '2026-01-12T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Đặng Bảo Anh
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', 'f32ec038-e7de-5900-9f8e-399dcbc4a904', 'student', '2026-01-13T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Đặng Huỳnh Quang
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', '98f08d80-eff4-5335-a524-036c8f213890', 'student', '2026-01-13T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Đào Bình Phước
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', '24ed3ce4-4a9a-53d4-9b37-1606ac49dee4', 'student', '2026-01-13T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Đào Duy Phúc
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', 'c09e4f67-2386-5909-9adb-15bbbf6a191c', 'student', '2026-01-13T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Đinh Hải Siêu
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', '1b091e49-228a-5e43-99ed-47ce336fbdb8', 'student', '2026-01-14T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Đinh Lê Hoàng
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', '80cf60e4-7ba9-5658-9e3c-b232707d34b7', 'student', '2026-01-14T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Đoàn Thanh Quang
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', 'f6d81836-a646-586d-84fa-57cdbe0a6b16', 'student', '2026-01-14T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Đồng Nguyên Hiếu
INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)
VALUES ('aa010001-0000-0000-0000-000000000001', '192e7be4-9b8a-5a34-83a1-f04e6d292592', 'student', '2026-01-14T08:00:00+00:00', 'approved') ON CONFLICT DO NOTHING; -- Dương Công Quốc Anh

-- ═══ 4. ASSIGNMENTS ═══
INSERT INTO public.assignments (id, class_id, teacher_id, title, description, is_published, published_at, total_points, created_at, updated_at)
VALUES ('ab010001-0000-0000-0000-000000000001', 'aa010001-0000-0000-0000-000000000001', '51e467a2-9033-5e85-b666-164ea075f6c9',
  'Kiểm tra 15 phút - Cú pháp Python cơ bản',
  'Bài kiểm tra nhanh về cú pháp Python: kiểu dữ liệu, toán tử, hàm cơ bản.',
  true, '2026-02-07T08:00:00+00:00', 10,
  '2026-02-07T08:00:00+00:00', '2026-02-07T08:00:00+00:00') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.assignments (id, class_id, teacher_id, title, description, is_published, published_at, total_points, created_at, updated_at)
VALUES ('ab010002-0000-0000-0000-000000000002', 'aa010001-0000-0000-0000-000000000001', '51e467a2-9033-5e85-b666-164ea075f6c9',
  'Bài tập: Vòng lặp và Hàm trong Python',
  'Kiểm tra kiến thức về vòng lặp for/while, hàm, tham số và giá trị trả về.',
  true, '2026-02-21T08:00:00+00:00', 10,
  '2026-02-21T08:00:00+00:00', '2026-02-21T08:00:00+00:00') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.assignments (id, class_id, teacher_id, title, description, is_published, published_at, total_points, created_at, updated_at)
VALUES ('ab010003-0000-0000-0000-000000000003', 'aa010001-0000-0000-0000-000000000001', '51e467a2-9033-5e85-b666-164ea075f6c9',
  'Kiểm tra Giữa kỳ - Lập trình Hướng đối tượng Python',
  'Đánh giá toàn diện kiến thức OOP: class, object, inheritance, encapsulation, polymorphism.',
  true, '2026-03-07T08:00:00+00:00', 20,
  '2026-03-07T08:00:00+00:00', '2026-03-07T08:00:00+00:00') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.assignments (id, class_id, teacher_id, title, description, is_published, published_at, total_points, created_at, updated_at)
VALUES ('ab010004-0000-0000-0000-000000000004', 'aa010001-0000-0000-0000-000000000001', '51e467a2-9033-5e85-b666-164ea075f6c9',
  'Bài tập Web: HTML/CSS và Flask cơ bản',
  'Thực hành xây dựng web app đơn giản với Flask framework và HTML/CSS frontend.',
  true, '2026-03-23T08:00:00+00:00', 10,
  '2026-03-23T08:00:00+00:00', '2026-03-23T08:00:00+00:00') ON CONFLICT (id) DO NOTHING;

-- ═══ 5. ASSIGNMENT_QUESTIONS ═══
-- A1: Kiểm tra 15 phút - Cú pháp Python cơ bản
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0001000001', 'ab010001-0000-0000-0000-000000000001', NULL, '{"override_text": "Trong Python, kiểu dữ liệu nào dùng để lưu trữ chuỗi ký tự?", "type": "multiple_choice", "choices": [{"id": 0, "text": "int", "isCorrect": false}, {"id": 1, "text": "float", "isCorrect": false}, {"id": 2, "text": "str", "isCorrect": true}, {"id": 3, "text": "char", "isCorrect": false}], "difficulty": 2}', 1.0, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0001000002', 'ab010001-0000-0000-0000-000000000001', NULL, '{"override_text": "Lệnh nào dùng để in dữ liệu ra màn hình trong Python?", "type": "multiple_choice", "choices": [{"id": 0, "text": "echo", "isCorrect": false}, {"id": 1, "text": "print()", "isCorrect": true}, {"id": 2, "text": "console.log()", "isCorrect": false}, {"id": 3, "text": "write()", "isCorrect": false}], "difficulty": 3}', 1.0, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0001000003', 'ab010001-0000-0000-0000-000000000001', NULL, '{"override_text": "Biểu thức 10 // 3 trong Python trả về kết quả nào?", "type": "multiple_choice", "choices": [{"id": 0, "text": "3", "isCorrect": true}, {"id": 1, "text": "3.33", "isCorrect": false}, {"id": 2, "text": "1", "isCorrect": false}, {"id": 3, "text": "3.0", "isCorrect": false}], "difficulty": 4}', 1.0, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0001000004', 'ab010001-0000-0000-0000-000000000001', NULL, '{"override_text": "Từ khóa nào dùng để khai báo hàm trong Python?", "type": "multiple_choice", "choices": [{"id": 0, "text": "def", "isCorrect": true}, {"id": 1, "text": "function", "isCorrect": false}, {"id": 2, "text": "func", "isCorrect": false}, {"id": 3, "text": "void", "isCorrect": false}], "difficulty": 2}', 1.0, 4) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0001000005', 'ab010001-0000-0000-0000-000000000001', NULL, '{"override_text": "Kiểu dữ liệu nào KHÔNG tồn tại trong Python?", "type": "multiple_choice", "choices": [{"id": 0, "text": "list", "isCorrect": false}, {"id": 1, "text": "tuple", "isCorrect": false}, {"id": 2, "text": "char", "isCorrect": true}, {"id": 3, "text": "dict", "isCorrect": false}], "difficulty": 3}', 1.0, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0001000006', 'ab010001-0000-0000-0000-000000000001', NULL, '{"override_text": "[x**2 for x in range(5)] trả về danh sách nào?", "type": "multiple_choice", "choices": [{"id": 0, "text": "[1,4,9,16,25]", "isCorrect": false}, {"id": 1, "text": "[0,1,2,3,4]", "isCorrect": false}, {"id": 2, "text": "[0,1,4,9,16]", "isCorrect": true}, {"id": 3, "text": "[1,2,3,4,5]", "isCorrect": false}], "difficulty": 4}', 1.0, 6) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0001000007', 'ab010001-0000-0000-0000-000000000001', NULL, '{"override_text": "Toán tử nào tính phần dư của phép chia trong Python?", "type": "multiple_choice", "choices": [{"id": 0, "text": "//", "isCorrect": false}, {"id": 1, "text": "%", "isCorrect": true}, {"id": 2, "text": "**", "isCorrect": false}, {"id": 3, "text": "/", "isCorrect": false}], "difficulty": 2}', 1.0, 7) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0001000008', 'ab010001-0000-0000-0000-000000000001', NULL, '{"override_text": "x = [1,2,3,4,5]. Giá trị của x[-1] là bao nhiêu?", "type": "multiple_choice", "choices": [{"id": 0, "text": "5", "isCorrect": true}, {"id": 1, "text": "1", "isCorrect": false}, {"id": 2, "text": "-1", "isCorrect": false}, {"id": 3, "text": "4", "isCorrect": false}], "difficulty": 3}', 1.0, 8) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0001000009', 'ab010001-0000-0000-0000-000000000001', NULL, '{"override_text": "x=[1,2,3]; y=x; y.append(4). Giá trị của x sau đó là gì?", "type": "multiple_choice", "choices": [{"id": 0, "text": "[1,2,3]", "isCorrect": false}, {"id": 1, "text": "[4,1,2,3]", "isCorrect": false}, {"id": 2, "text": "[1,2,3,4]", "isCorrect": true}, {"id": 3, "text": "Error", "isCorrect": false}], "difficulty": 4}', 1.0, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0001000010', 'ab010001-0000-0000-0000-000000000001', NULL, '{"override_text": "Method nào dùng để thêm một phần tử vào cuối list trong Python?", "type": "multiple_choice", "choices": [{"id": 0, "text": "push()", "isCorrect": false}, {"id": 1, "text": "append()", "isCorrect": true}, {"id": 2, "text": "add()", "isCorrect": false}, {"id": 3, "text": "insert()", "isCorrect": false}], "difficulty": 2}', 1.0, 10) ON CONFLICT DO NOTHING;

-- A2: Bài tập: Vòng lặp và Hàm trong Python
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0002000001', 'ab010002-0000-0000-0000-000000000002', NULL, '{"override_text": "Vòng lặp nào trong Python dùng để lặp qua từng phần tử của iterable?", "type": "multiple_choice", "choices": [{"id": 0, "text": "while", "isCorrect": false}, {"id": 1, "text": "for", "isCorrect": true}, {"id": 2, "text": "loop", "isCorrect": false}, {"id": 3, "text": "foreach", "isCorrect": false}], "difficulty": 2}', 1.0, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0002000002', 'ab010002-0000-0000-0000-000000000002', NULL, '{"override_text": "Giá trị mặc định của tham số hàm được định nghĩa ở đâu trong Python?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Khi gọi hàm", "isCorrect": false}, {"id": 1, "text": "Trong khai báo hàm", "isCorrect": true}, {"id": 2, "text": "Trong thân hàm", "isCorrect": false}, {"id": 3, "text": "Ngoài hàm", "isCorrect": false}], "difficulty": 3}', 1.0, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0002000003', 'ab010002-0000-0000-0000-000000000002', NULL, '{"override_text": "Từ khóa nào dùng để trả về giá trị từ hàm Python?", "type": "multiple_choice", "choices": [{"id": 0, "text": "output", "isCorrect": false}, {"id": 1, "text": "return", "isCorrect": true}, {"id": 2, "text": "send", "isCorrect": false}, {"id": 3, "text": "result", "isCorrect": false}], "difficulty": 4}', 1.0, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0002000004', 'ab010002-0000-0000-0000-000000000002', NULL, '{"override_text": "Lệnh break trong vòng lặp Python có tác dụng gì?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Bỏ qua iteration hiện tại", "isCorrect": false}, {"id": 1, "text": "Dừng toàn bộ vòng lặp", "isCorrect": true}, {"id": 2, "text": "Tiếp tục iteration kế tiếp", "isCorrect": false}, {"id": 3, "text": "Khởi tạo lại vòng lặp", "isCorrect": false}], "difficulty": 2}', 1.0, 4) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0002000005', 'ab010002-0000-0000-0000-000000000002', NULL, '{"override_text": "Viết một hàm Python tên là sum_n(n) trả về tổng các số tự nhiên từ 1 đến n.", "type": "short_answer", "difficulty": 3, "ai_grading_keywords": [], "expected_answer": ""}', 2.0, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0002000006', 'ab010002-0000-0000-0000-000000000002', NULL, '{"override_text": "Viết chương trình Python in ra dãy Fibonacci đến n phần tử (nhập từ bàn phím). Giải thích rõ thuật toán, xử lý trường hợp đặc biệt n<=0 và trình bày code rõ ràng.", "type": "essay", "difficulty": 4, "ai_grading_keywords": [], "expected_answer": ""}', 4.0, 6) ON CONFLICT DO NOTHING;

-- A3: Kiểm tra Giữa kỳ - Lập trình Hướng đối tượng Python
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000001', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Trong Python OOP, từ khóa nào dùng để tạo class?", "type": "multiple_choice", "choices": [{"id": 0, "text": "object", "isCorrect": false}, {"id": 1, "text": "class", "isCorrect": true}, {"id": 2, "text": "struct", "isCorrect": false}, {"id": 3, "text": "type", "isCorrect": false}], "difficulty": 2}', 1.0, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000002', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Phương thức __init__ trong Python class được gọi khi nào?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Khi xóa object", "isCorrect": false}, {"id": 1, "text": "Khi in object", "isCorrect": false}, {"id": 2, "text": "Khi tạo instance mới", "isCorrect": true}, {"id": 3, "text": "Khi so sánh object", "isCorrect": false}], "difficulty": 3}', 1.0, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000003', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "self trong Python method đại diện cho?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Class hiện tại", "isCorrect": false}, {"id": 1, "text": "Instance của class", "isCorrect": true}, {"id": 2, "text": "Parent class", "isCorrect": false}, {"id": 3, "text": "Module hiện tại", "isCorrect": false}], "difficulty": 4}', 1.0, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000004', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Kế thừa trong Python được định nghĩa như thế nào?", "type": "multiple_choice", "choices": [{"id": 0, "text": "class Child extends Parent", "isCorrect": false}, {"id": 1, "text": "class Child(Parent)", "isCorrect": true}, {"id": 2, "text": "class Child inherits Parent", "isCorrect": false}, {"id": 3, "text": "class Child <- Parent", "isCorrect": false}], "difficulty": 2}', 1.0, 4) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000005', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Để gọi method của class cha từ class con, ta dùng?", "type": "multiple_choice", "choices": [{"id": 0, "text": "parent.method()", "isCorrect": false}, {"id": 1, "text": "super().method()", "isCorrect": true}, {"id": 2, "text": "base.method()", "isCorrect": false}, {"id": 3, "text": "ancestor.method()", "isCorrect": false}], "difficulty": 3}', 1.0, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000006', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "__str__ method trong Python dùng để?", "type": "multiple_choice", "choices": [{"id": 0, "text": "So sánh 2 object", "isCorrect": false}, {"id": 1, "text": "Tính hash của object", "isCorrect": false}, {"id": 2, "text": "Định nghĩa biểu diễn string của object", "isCorrect": true}, {"id": 3, "text": "Copy object", "isCorrect": false}], "difficulty": 4}', 1.0, 6) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000007', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Encapsulation (đóng gói) trong OOP là gì?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Kế thừa thuộc tính", "isCorrect": false}, {"id": 1, "text": "Ẩn chi tiết nội bộ, chỉ expose interface", "isCorrect": true}, {"id": 2, "text": "Đa hình của method", "isCorrect": false}, {"id": 3, "text": "Tạo nhiều instance", "isCorrect": false}], "difficulty": 2}', 1.0, 7) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000008', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Thuộc tính có tiền tố __ (double underscore) trong Python là?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Public attribute", "isCorrect": false}, {"id": 1, "text": "Protected attribute", "isCorrect": false}, {"id": 2, "text": "Class attribute", "isCorrect": false}, {"id": 3, "text": "Private attribute (name mangling)", "isCorrect": true}], "difficulty": 3}', 1.0, 8) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000009', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Polymorphism (đa hình) trong Python thể hiện qua?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Class không thể có nhiều method", "isCorrect": false}, {"id": 1, "text": "Method override ở class con", "isCorrect": true}, {"id": 2, "text": "Chỉ có 1 cách gọi method", "isCorrect": false}, {"id": 3, "text": "Method không thể nhận tham số", "isCorrect": false}], "difficulty": 4}', 1.0, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000010', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "@property decorator trong Python dùng để?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Tạo static method", "isCorrect": false}, {"id": 1, "text": "Định nghĩa class method", "isCorrect": false}, {"id": 2, "text": "Biến method thành thuộc tính có thể đọc", "isCorrect": true}, {"id": 3, "text": "Xóa thuộc tính", "isCorrect": false}], "difficulty": 2}', 1.0, 10) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000011', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Class method trong Python được tạo bằng decorator nào?", "type": "multiple_choice", "choices": [{"id": 0, "text": "@staticmethod", "isCorrect": false}, {"id": 1, "text": "@classmethod", "isCorrect": true}, {"id": 2, "text": "@property", "isCorrect": false}, {"id": 3, "text": "@abstractmethod", "isCorrect": false}], "difficulty": 3}', 1.0, 11) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000012', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Abstract class trong Python được hỗ trợ bởi module nào?", "type": "multiple_choice", "choices": [{"id": 0, "text": "collections", "isCorrect": false}, {"id": 1, "text": "typing", "isCorrect": false}, {"id": 2, "text": "abc", "isCorrect": true}, {"id": 3, "text": "inspect", "isCorrect": false}], "difficulty": 4}', 1.0, 12) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000013', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Duck typing trong Python có nghĩa là?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Chỉ dùng class có từ \"duck\"", "isCorrect": false}, {"id": 1, "text": "Kiểm tra type nghiêm ngặt", "isCorrect": false}, {"id": 2, "text": "Quan tâm behavior hơn type", "isCorrect": true}, {"id": 3, "text": "Không dùng OOP", "isCorrect": false}], "difficulty": 2}', 1.0, 13) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000014', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Method __len__ trong Python được gọi khi?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Dùng hàm len() trên object", "isCorrect": true}, {"id": 1, "text": "In object", "isCorrect": false}, {"id": 2, "text": "So sánh object", "isCorrect": false}, {"id": 3, "text": "Xóa object", "isCorrect": false}], "difficulty": 3}', 1.0, 14) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000015', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Thiết kế class BankAccount với các thuộc tính: số tài khoản, chủ tài khoản, số dư. Cài đặt các method: nạp tiền, rút tiền (với validation), và in thông tin tài khoản. Áp dụng đúng nguyên tắc encapsulation.", "type": "essay", "difficulty": 3, "ai_grading_keywords": [], "expected_answer": ""}', 3.0, 15) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0003000016', 'ab010003-0000-0000-0000-000000000003', NULL, '{"override_text": "Giải thích sự khác biệt giữa @classmethod và @staticmethod trong Python với ví dụ cụ thể. Khi nào nên dùng mỗi loại? Viết code minh họa cho cả hai.", "type": "essay", "difficulty": 4, "ai_grading_keywords": [], "expected_answer": ""}', 3.0, 16) ON CONFLICT DO NOTHING;

-- A4: Bài tập Web: HTML/CSS và Flask cơ bản
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0004000001', 'ab010004-0000-0000-0000-000000000004', NULL, '{"override_text": "Tag HTML nào dùng để tạo hyperlink (liên kết)?", "type": "multiple_choice", "choices": [{"id": 0, "text": "<link>", "isCorrect": false}, {"id": 1, "text": "<a>", "isCorrect": true}, {"id": 2, "text": "<href>", "isCorrect": false}, {"id": 3, "text": "<url>", "isCorrect": false}], "difficulty": 2}', 1.0, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0004000002', 'ab010004-0000-0000-0000-000000000004', NULL, '{"override_text": "Trong CSS, property nào thay đổi màu nền của element?", "type": "multiple_choice", "choices": [{"id": 0, "text": "color", "isCorrect": false}, {"id": 1, "text": "font-color", "isCorrect": false}, {"id": 2, "text": "background-color", "isCorrect": true}, {"id": 3, "text": "bg-color", "isCorrect": false}], "difficulty": 3}', 1.0, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0004000003', 'ab010004-0000-0000-0000-000000000004', NULL, '{"override_text": "Flask là gì trong Python?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Thư viện xử lý database", "isCorrect": false}, {"id": 1, "text": "Micro web framework", "isCorrect": true}, {"id": 2, "text": "Testing framework", "isCorrect": false}, {"id": 3, "text": "Package manager", "isCorrect": false}], "difficulty": 4}', 1.0, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0004000004', 'ab010004-0000-0000-0000-000000000004', NULL, '{"override_text": "Decorator @app.route(\"/\") trong Flask dùng để làm gì?", "type": "multiple_choice", "choices": [{"id": 0, "text": "Import module", "isCorrect": false}, {"id": 1, "text": "Khai báo biến global", "isCorrect": false}, {"id": 2, "text": "Gắn URL path với hàm xử lý", "isCorrect": true}, {"id": 3, "text": "Kết nối database", "isCorrect": false}], "difficulty": 2}', 1.0, 4) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0004000005', 'ab010004-0000-0000-0000-000000000004', NULL, '{"override_text": "Viết route Flask đơn giản tại đường dẫn /hello trả về chuỗi \"Xin chào, Flask!\".", "type": "short_answer", "difficulty": 3, "ai_grading_keywords": [], "expected_answer": ""}', 2.0, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)
VALUES ('00000000-0000-0000-0000-aa0004000006', 'ab010004-0000-0000-0000-000000000004', NULL, '{"override_text": "Xây dựng một ứng dụng Flask nhỏ có 2 route: trang chủ \"/\" hiển thị danh sách sinh viên và route \"/student/<id>\" hiển thị thông tin 1 sinh viên. Viết đầy đủ code Python và template HTML cơ bản. Giải thích cấu trúc project và cách Flask xử lý request.", "type": "essay", "difficulty": 4, "ai_grading_keywords": [], "expected_answer": ""}', 4.0, 6) ON CONFLICT DO NOTHING;

-- ═══ 6. ASSIGNMENT_DISTRIBUTIONS ═══
INSERT INTO public.assignment_distributions (id, assignment_id, distribution_type, class_id, available_from, due_at, time_limit_minutes, allow_late, late_policy, status, settings, created_at)
VALUES ('ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', 'class', 'aa010001-0000-0000-0000-000000000001',
  '2026-02-08T08:00:00+00:00', '2026-02-09T23:59:00+00:00', 15, true,
  '{"policy_type": "daily_deduction", "deduction_value": 10, "unit": "percent", "max_days_allowed": 3, "lowest_possible_score": 0}', 'closed',
  '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true, "student_review_mode": "full_review", "ai_feedback_enabled": true}', '2026-02-08T08:00:00+00:00') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.assignment_distributions (id, assignment_id, distribution_type, class_id, available_from, due_at, time_limit_minutes, allow_late, late_policy, status, settings, created_at)
VALUES ('ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', 'class', 'aa010001-0000-0000-0000-000000000001',
  '2026-02-22T08:00:00+00:00', '2026-02-24T23:59:00+00:00', 45, true,
  '{"policy_type": "daily_deduction", "deduction_value": 10, "unit": "percent", "max_days_allowed": 3, "lowest_possible_score": 0}', 'closed',
  '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true, "student_review_mode": "full_review", "ai_feedback_enabled": true}', '2026-02-22T08:00:00+00:00') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.assignment_distributions (id, assignment_id, distribution_type, class_id, available_from, due_at, time_limit_minutes, allow_late, late_policy, status, settings, created_at)
VALUES ('ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', 'class', 'aa010001-0000-0000-0000-000000000001',
  '2026-03-08T08:00:00+00:00', '2026-03-10T23:59:00+00:00', 60, true,
  '{"policy_type": "daily_deduction", "deduction_value": 10, "unit": "percent", "max_days_allowed": 3, "lowest_possible_score": 0}', 'closed',
  '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true, "student_review_mode": "full_review", "ai_feedback_enabled": true}', '2026-03-08T08:00:00+00:00') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.assignment_distributions (id, assignment_id, distribution_type, class_id, available_from, due_at, time_limit_minutes, allow_late, late_policy, status, settings, created_at)
VALUES ('ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', 'class', 'aa010001-0000-0000-0000-000000000001',
  '2026-03-24T08:00:00+00:00', '2026-03-28T23:59:00+00:00', 60, true,
  '{"policy_type": "daily_deduction", "deduction_value": 10, "unit": "percent", "max_days_allowed": 3, "lowest_possible_score": 0}', 'active',
  '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true, "student_review_mode": "full_review", "ai_feedback_enabled": true}', '2026-03-24T08:00:00+00:00') ON CONFLICT (id) DO NOTHING;

-- ═══ 7. WORK_SESSIONS + SUBMISSIONS + SUBMISSION_ANSWERS ═══
-- Thái Anh Huy - A1 | score=8.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0000000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', 'b3e27ac4-a528-5174-92f8-99a8f273eb84',
  '2026-02-08T07:00:00+00:00', '2026-02-08T09:00:00+00:00', 1, 'submitted', 300,
  '2026-02-08T07:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0000000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', 'b3e27ac4-a528-5174-92f8-99a8f273eb84', '00000000-0000-0000-0000-bb0000000001',
  '2026-02-08T07:00:00+00:00', '2026-02-08T09:00:00+00:00', false, 8.0, true, false,
  '2026-02-08T07:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000010001', '00000000-0000-0000-0000-bb0000000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000010002', '00000000-0000-0000-0000-bb0000000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000010003', '00000000-0000-0000-0000-bb0000000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000010004', '00000000-0000-0000-0000-bb0000000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000010005', '00000000-0000-0000-0000-bb0000000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000010006', '00000000-0000-0000-0000-bb0000000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000010007', '00000000-0000-0000-0000-bb0000000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000010008', '00000000-0000-0000-0000-bb0000000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000010009', '00000000-0000-0000-0000-bb0000000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000010010', '00000000-0000-0000-0000-bb0000000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00', '2026-02-08T09:00:00+00:00') ON CONFLICT DO NOTHING;

-- Thái Anh Huy - A2 | score=7.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0000000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', 'b3e27ac4-a528-5174-92f8-99a8f273eb84',
  '2026-02-22T07:00:00+00:00', '2026-02-22T09:00:00+00:00', 1, 'submitted', 360,
  '2026-02-22T07:00:00+00:00', '2026-02-22T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0000000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', 'b3e27ac4-a528-5174-92f8-99a8f273eb84', '00000000-0000-0000-0000-bb0000000002',
  '2026-02-22T07:00:00+00:00', '2026-02-22T09:00:00+00:00', false, 7.5, true, false,
  '2026-02-22T07:00:00+00:00', '2026-02-22T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000020001', '00000000-0000-0000-0000-bb0000000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000020002', '00000000-0000-0000-0000-bb0000000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000020003', '00000000-0000-0000-0000-bb0000000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000020004', '00000000-0000-0000-0000-bb0000000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000020005', '00000000-0000-0000-0000-bb0000000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Thái Anh Huy cho câu 5"}',
  1.5, 0.75, 1.5,
  '{"comment": "AI chấm: 1.5/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000020006', '00000000-0000-0000-0000-bb0000000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Thái Anh Huy. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  2.5, 0.62, 3.0,
  '{"comment": "AI chấm: 2.5/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  '{"comment": "Ý tưởng đúng nhưng chưa xử lý edge case. Cộng thêm 0.5 điểm.", "rating": 4}', '51e467a2-9033-5e85-b666-164ea075f6c9',
  '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00', '2026-02-22T09:00:00+00:00') ON CONFLICT DO NOTHING;

-- Thái Anh Huy - A3 | score=11.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0000000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', 'b3e27ac4-a528-5174-92f8-99a8f273eb84',
  '2026-03-08T07:00:00+00:00', '2026-03-11T09:00:00+00:00', 1, 'submitted', 420,
  '2026-03-08T07:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0000000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', 'b3e27ac4-a528-5174-92f8-99a8f273eb84', '00000000-0000-0000-0000-bb0000000003',
  '2026-03-08T07:00:00+00:00', '2026-03-11T09:00:00+00:00', true, 11.0, true, false,
  '2026-03-08T07:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030001', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030002', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030003', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030004', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030005', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030006', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030007', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030008', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [3]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030009', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030010', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030011', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030012', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030013', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030014', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030015', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  1.5, 0.5, 1.5,
  '{"comment": "AI chấm: 1.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000030016', '00000000-0000-0000-0000-bb0000000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Thái Anh Huy. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  1.5, 0.5, 1.5,
  '{"comment": "AI chấm: 1.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00', '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;

-- Thái Anh Huy - A4 | score=9.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0000000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', 'b3e27ac4-a528-5174-92f8-99a8f273eb84',
  '2026-03-24T07:00:00+00:00', '2026-03-24T09:00:00+00:00', 1, 'submitted', 480,
  '2026-03-24T07:00:00+00:00', '2026-03-24T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0000000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', 'b3e27ac4-a528-5174-92f8-99a8f273eb84', '00000000-0000-0000-0000-bb0000000004',
  '2026-03-24T07:00:00+00:00', '2026-03-24T09:00:00+00:00', false, 9.0, false, false,
  '2026-03-24T07:00:00+00:00', '2026-03-24T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000040001', '00000000-0000-0000-0000-bb0000000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000040002', '00000000-0000-0000-0000-bb0000000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000040003', '00000000-0000-0000-0000-bb0000000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000040004', '00000000-0000-0000-0000-bb0000000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000040005', '00000000-0000-0000-0000-bb0000000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Thái Anh Huy cho câu 5"}',
  2.0, 1.0, 2.0,
  '{"comment": "AI chấm: 2.0/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000040006', '00000000-0000-0000-0000-bb0000000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Thái Anh Huy. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  3.0, 0.75, 3.0,
  '{"comment": "AI chấm: 3.0/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00', '2026-03-24T09:00:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Đình Anh - A1 | score=9.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0001000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', 'e274bfde-ca3f-56f8-a803-6008bbdbc1e5',
  '2026-02-09T08:00:00+00:00', '2026-02-09T10:07:00+00:00', 1, 'submitted', 420,
  '2026-02-09T08:00:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0001000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', 'e274bfde-ca3f-56f8-a803-6008bbdbc1e5', '00000000-0000-0000-0000-bb0001000001',
  '2026-02-09T08:00:00+00:00', '2026-02-09T10:07:00+00:00', false, 9.0, true, false,
  '2026-02-09T08:00:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100010001', '00000000-0000-0000-0000-bb0001000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100010002', '00000000-0000-0000-0000-bb0001000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100010003', '00000000-0000-0000-0000-bb0001000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100010004', '00000000-0000-0000-0000-bb0001000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100010005', '00000000-0000-0000-0000-bb0001000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100010006', '00000000-0000-0000-0000-bb0001000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100010007', '00000000-0000-0000-0000-bb0001000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100010008', '00000000-0000-0000-0000-bb0001000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100010009', '00000000-0000-0000-0000-bb0001000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100010010', '00000000-0000-0000-0000-bb0001000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00', '2026-02-09T10:07:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Đình Anh - A2 | score=9.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0001000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', 'e274bfde-ca3f-56f8-a803-6008bbdbc1e5',
  '2026-02-23T08:00:00+00:00', '2026-02-23T10:07:00+00:00', 1, 'submitted', 480,
  '2026-02-23T08:00:00+00:00', '2026-02-23T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0001000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', 'e274bfde-ca3f-56f8-a803-6008bbdbc1e5', '00000000-0000-0000-0000-bb0001000002',
  '2026-02-23T08:00:00+00:00', '2026-02-23T10:07:00+00:00', false, 9.5, true, false,
  '2026-02-23T08:00:00+00:00', '2026-02-23T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100020001', '00000000-0000-0000-0000-bb0001000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100020002', '00000000-0000-0000-0000-bb0001000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100020003', '00000000-0000-0000-0000-bb0001000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100020004', '00000000-0000-0000-0000-bb0001000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100020005', '00000000-0000-0000-0000-bb0001000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Bùi Đình Anh cho câu 5"}',
  2.0, 1.0, 2.0,
  '{"comment": "AI chấm: 2.0/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100020006', '00000000-0000-0000-0000-bb0001000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Bùi Đình Anh. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  3.5, 0.88, 3.5,
  '{"comment": "AI chấm: 3.5/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00', '2026-02-23T10:07:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Đình Anh - A3 | score=18.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0001000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', 'e274bfde-ca3f-56f8-a803-6008bbdbc1e5',
  '2026-03-09T08:00:00+00:00', '2026-03-09T10:07:00+00:00', 1, 'submitted', 540,
  '2026-03-09T08:00:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0001000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', 'e274bfde-ca3f-56f8-a803-6008bbdbc1e5', '00000000-0000-0000-0000-bb0001000003',
  '2026-03-09T08:00:00+00:00', '2026-03-09T10:07:00+00:00', false, 18.0, true, false,
  '2026-03-09T08:00:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030001', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030002', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030003', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030004', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030005', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030006', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030007', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030008', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [3]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030009', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030010', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030011', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030012', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030013', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030014', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030015', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  2.5, 0.83, 2.5,
  '{"comment": "AI chấm: 2.5/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100030016', '00000000-0000-0000-0000-bb0001000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Bùi Đình Anh. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  2.5, 0.83, 2.5,
  '{"comment": "AI chấm: 2.5/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00', '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Đình Anh - A4 | score=9.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0001000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', 'e274bfde-ca3f-56f8-a803-6008bbdbc1e5',
  '2026-03-25T08:00:00+00:00', '2026-03-25T10:07:00+00:00', 1, 'submitted', 600,
  '2026-03-25T08:00:00+00:00', '2026-03-25T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0001000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', 'e274bfde-ca3f-56f8-a803-6008bbdbc1e5', '00000000-0000-0000-0000-bb0001000004',
  '2026-03-25T08:00:00+00:00', '2026-03-25T10:07:00+00:00', false, 9.5, false, false,
  '2026-03-25T08:00:00+00:00', '2026-03-25T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100040001', '00000000-0000-0000-0000-bb0001000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100040002', '00000000-0000-0000-0000-bb0001000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100040003', '00000000-0000-0000-0000-bb0001000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100040004', '00000000-0000-0000-0000-bb0001000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100040005', '00000000-0000-0000-0000-bb0001000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Bùi Đình Anh cho câu 5"}',
  2.0, 1.0, 2.0,
  '{"comment": "AI chấm: 2.0/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000100040006', '00000000-0000-0000-0000-bb0001000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Bùi Đình Anh. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  3.5, 0.88, 3.5,
  '{"comment": "AI chấm: 3.5/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00', '2026-03-25T10:07:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Quang Linh - A1 | score=5.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0002000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', '13d565a8-ccb5-56fe-a884-30df48099615',
  '2026-02-10T09:00:00+00:00', '2026-02-08T11:14:00+00:00', 1, 'submitted', 540,
  '2026-02-10T09:00:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0002000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', '13d565a8-ccb5-56fe-a884-30df48099615', '00000000-0000-0000-0000-bb0002000001',
  '2026-02-10T09:00:00+00:00', '2026-02-08T11:14:00+00:00', false, 5.0, true, false,
  '2026-02-10T09:00:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200010001', '00000000-0000-0000-0000-bb0002000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200010002', '00000000-0000-0000-0000-bb0002000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200010003', '00000000-0000-0000-0000-bb0002000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200010004', '00000000-0000-0000-0000-bb0002000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200010005', '00000000-0000-0000-0000-bb0002000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200010006', '00000000-0000-0000-0000-bb0002000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200010007', '00000000-0000-0000-0000-bb0002000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200010008', '00000000-0000-0000-0000-bb0002000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200010009', '00000000-0000-0000-0000-bb0002000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200010010', '00000000-0000-0000-0000-bb0002000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00', '2026-02-08T11:14:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Quang Linh - A2 | score=4.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0002000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', '13d565a8-ccb5-56fe-a884-30df48099615',
  '2026-02-24T09:00:00+00:00', '2026-02-22T11:14:00+00:00', 1, 'submitted', 600,
  '2026-02-24T09:00:00+00:00', '2026-02-22T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0002000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', '13d565a8-ccb5-56fe-a884-30df48099615', '00000000-0000-0000-0000-bb0002000002',
  '2026-02-24T09:00:00+00:00', '2026-02-22T11:14:00+00:00', false, 4.0, true, false,
  '2026-02-24T09:00:00+00:00', '2026-02-22T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200020001', '00000000-0000-0000-0000-bb0002000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200020002', '00000000-0000-0000-0000-bb0002000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200020003', '00000000-0000-0000-0000-bb0002000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200020004', '00000000-0000-0000-0000-bb0002000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200020005', '00000000-0000-0000-0000-bb0002000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Bùi Quang Linh cho câu 5"}',
  1.0, 0.5, 1.0,
  '{"comment": "AI chấm: 1.0/2.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200020006', '00000000-0000-0000-0000-bb0002000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Bùi Quang Linh. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  1.0, 0.25, 1.0,
  '{"comment": "AI chấm: 1.0/4.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00', '2026-02-22T11:14:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Quang Linh - A3 | score=6.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0002000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', '13d565a8-ccb5-56fe-a884-30df48099615',
  '2026-03-10T09:00:00+00:00', '2026-03-08T11:14:00+00:00', 1, 'submitted', 660,
  '2026-03-10T09:00:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0002000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', '13d565a8-ccb5-56fe-a884-30df48099615', '00000000-0000-0000-0000-bb0002000003',
  '2026-03-10T09:00:00+00:00', '2026-03-08T11:14:00+00:00', false, 6.5, true, false,
  '2026-03-10T09:00:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030001', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030002', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030003', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030004', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030005', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030006', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030007', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030008', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [3]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030009', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030010', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030011', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030012', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030013', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030014', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030015', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  1.0, 0.33, 1.0,
  '{"comment": "AI chấm: 1.0/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200030016', '00000000-0000-0000-0000-bb0002000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Bùi Quang Linh. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  0.5, 0.17, 0.5,
  '{"comment": "AI chấm: 0.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00', '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Quang Linh - A4 | score=4.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0002000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', '13d565a8-ccb5-56fe-a884-30df48099615',
  '2026-03-26T09:00:00+00:00', '2026-03-24T11:14:00+00:00', 1, 'submitted', 720,
  '2026-03-26T09:00:00+00:00', '2026-03-24T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0002000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', '13d565a8-ccb5-56fe-a884-30df48099615', '00000000-0000-0000-0000-bb0002000004',
  '2026-03-26T09:00:00+00:00', '2026-03-24T11:14:00+00:00', false, 4.0, false, false,
  '2026-03-26T09:00:00+00:00', '2026-03-24T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200040001', '00000000-0000-0000-0000-bb0002000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200040002', '00000000-0000-0000-0000-bb0002000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200040003', '00000000-0000-0000-0000-bb0002000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200040004', '00000000-0000-0000-0000-bb0002000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200040005', '00000000-0000-0000-0000-bb0002000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Bùi Quang Linh cho câu 5"}',
  0.5, 0.25, 0.5,
  '{"comment": "AI chấm: 0.5/2.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000200040006', '00000000-0000-0000-0000-bb0002000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Bùi Quang Linh. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  1.5, 0.38, 1.5,
  '{"comment": "AI chấm: 1.5/4.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00', '2026-03-24T11:14:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Quang Minh - A1 | score=6.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0003000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', '2154f53c-8e69-551b-8c0d-5a2457b15fd8',
  '2026-02-08T07:00:00+00:00', '2026-02-09T12:21:00+00:00', 1, 'submitted', 660,
  '2026-02-08T07:00:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0003000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', '2154f53c-8e69-551b-8c0d-5a2457b15fd8', '00000000-0000-0000-0000-bb0003000001',
  '2026-02-08T07:00:00+00:00', '2026-02-09T12:21:00+00:00', false, 6.0, true, false,
  '2026-02-08T07:00:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300010001', '00000000-0000-0000-0000-bb0003000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300010002', '00000000-0000-0000-0000-bb0003000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300010003', '00000000-0000-0000-0000-bb0003000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300010004', '00000000-0000-0000-0000-bb0003000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300010005', '00000000-0000-0000-0000-bb0003000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300010006', '00000000-0000-0000-0000-bb0003000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300010007', '00000000-0000-0000-0000-bb0003000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300010008', '00000000-0000-0000-0000-bb0003000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300010009', '00000000-0000-0000-0000-bb0003000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300010010', '00000000-0000-0000-0000-bb0003000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00', '2026-02-09T12:21:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Quang Minh - A2 | score=6.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0003000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', '2154f53c-8e69-551b-8c0d-5a2457b15fd8',
  '2026-02-22T07:00:00+00:00', '2026-02-23T12:21:00+00:00', 1, 'submitted', 720,
  '2026-02-22T07:00:00+00:00', '2026-02-23T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0003000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', '2154f53c-8e69-551b-8c0d-5a2457b15fd8', '00000000-0000-0000-0000-bb0003000002',
  '2026-02-22T07:00:00+00:00', '2026-02-23T12:21:00+00:00', false, 6.5, true, false,
  '2026-02-22T07:00:00+00:00', '2026-02-23T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300020001', '00000000-0000-0000-0000-bb0003000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300020002', '00000000-0000-0000-0000-bb0003000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300020003', '00000000-0000-0000-0000-bb0003000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300020004', '00000000-0000-0000-0000-bb0003000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300020005', '00000000-0000-0000-0000-bb0003000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Bùi Quang Minh cho câu 5"}',
  1.5, 0.75, 1.5,
  '{"comment": "AI chấm: 1.5/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300020006', '00000000-0000-0000-0000-bb0003000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Bùi Quang Minh. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  2.0, 0.5, 2.0,
  '{"comment": "AI chấm: 2.0/4.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00', '2026-02-23T12:21:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Quang Minh - A3 | score=13.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0003000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', '2154f53c-8e69-551b-8c0d-5a2457b15fd8',
  '2026-03-08T07:00:00+00:00', '2026-03-09T12:21:00+00:00', 1, 'submitted', 780,
  '2026-03-08T07:00:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0003000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', '2154f53c-8e69-551b-8c0d-5a2457b15fd8', '00000000-0000-0000-0000-bb0003000003',
  '2026-03-08T07:00:00+00:00', '2026-03-09T12:21:00+00:00', false, 13.5, true, false,
  '2026-03-08T07:00:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030001', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030002', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030003', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030004', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030005', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030006', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030007', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030008', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [3]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030009', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030010', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030011', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030012', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030013', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030014', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030015', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  1.5, 0.5, 1.5,
  '{"comment": "AI chấm: 1.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300030016', '00000000-0000-0000-0000-bb0003000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Bùi Quang Minh. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  2.0, 0.67, 2.0,
  '{"comment": "AI chấm: 2.0/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00', '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;

-- Bùi Quang Minh - A4 | score=9.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0003000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', '2154f53c-8e69-551b-8c0d-5a2457b15fd8',
  '2026-03-24T07:00:00+00:00', '2026-03-25T12:21:00+00:00', 1, 'submitted', 840,
  '2026-03-24T07:00:00+00:00', '2026-03-25T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0003000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', '2154f53c-8e69-551b-8c0d-5a2457b15fd8', '00000000-0000-0000-0000-bb0003000004',
  '2026-03-24T07:00:00+00:00', '2026-03-25T12:21:00+00:00', false, 9.0, false, false,
  '2026-03-24T07:00:00+00:00', '2026-03-25T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300040001', '00000000-0000-0000-0000-bb0003000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300040002', '00000000-0000-0000-0000-bb0003000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300040003', '00000000-0000-0000-0000-bb0003000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300040004', '00000000-0000-0000-0000-bb0003000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300040005', '00000000-0000-0000-0000-bb0003000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Bùi Quang Minh cho câu 5"}',
  2.0, 1.0, 2.0,
  '{"comment": "AI chấm: 2.0/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000300040006', '00000000-0000-0000-0000-bb0003000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Bùi Quang Minh. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  3.0, 0.75, 3.0,
  '{"comment": "AI chấm: 3.0/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00', '2026-03-25T12:21:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Cường - A1 | score=8.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0004000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', '0009cad5-6c63-5cc3-9596-dd0ed89ac948',
  '2026-02-09T08:00:00+00:00', '2026-02-08T09:28:00+00:00', 1, 'submitted', 780,
  '2026-02-09T08:00:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0004000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', '0009cad5-6c63-5cc3-9596-dd0ed89ac948', '00000000-0000-0000-0000-bb0004000001',
  '2026-02-09T08:00:00+00:00', '2026-02-08T09:28:00+00:00', false, 8.0, true, false,
  '2026-02-09T08:00:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400010001', '00000000-0000-0000-0000-bb0004000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400010002', '00000000-0000-0000-0000-bb0004000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400010003', '00000000-0000-0000-0000-bb0004000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400010004', '00000000-0000-0000-0000-bb0004000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400010005', '00000000-0000-0000-0000-bb0004000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400010006', '00000000-0000-0000-0000-bb0004000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400010007', '00000000-0000-0000-0000-bb0004000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400010008', '00000000-0000-0000-0000-bb0004000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400010009', '00000000-0000-0000-0000-bb0004000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400010010', '00000000-0000-0000-0000-bb0004000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00', '2026-02-08T09:28:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Cường - A2 | score=8.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0004000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', '0009cad5-6c63-5cc3-9596-dd0ed89ac948',
  '2026-02-23T08:00:00+00:00', '2026-02-22T09:28:00+00:00', 1, 'submitted', 840,
  '2026-02-23T08:00:00+00:00', '2026-02-22T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0004000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', '0009cad5-6c63-5cc3-9596-dd0ed89ac948', '00000000-0000-0000-0000-bb0004000002',
  '2026-02-23T08:00:00+00:00', '2026-02-22T09:28:00+00:00', false, 8.5, true, false,
  '2026-02-23T08:00:00+00:00', '2026-02-22T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400020001', '00000000-0000-0000-0000-bb0004000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400020002', '00000000-0000-0000-0000-bb0004000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400020003', '00000000-0000-0000-0000-bb0004000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400020004', '00000000-0000-0000-0000-bb0004000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400020005', '00000000-0000-0000-0000-bb0004000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Cao Cường cho câu 5"}',
  1.5, 0.75, 1.5,
  '{"comment": "AI chấm: 1.5/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400020006', '00000000-0000-0000-0000-bb0004000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Cao Cường. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  3.0, 0.75, 3.0,
  '{"comment": "AI chấm: 3.0/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00', '2026-02-22T09:28:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Cường - A3 | score=13.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0004000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', '0009cad5-6c63-5cc3-9596-dd0ed89ac948',
  '2026-03-09T08:00:00+00:00', '2026-03-08T09:28:00+00:00', 1, 'submitted', 900,
  '2026-03-09T08:00:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0004000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', '0009cad5-6c63-5cc3-9596-dd0ed89ac948', '00000000-0000-0000-0000-bb0004000003',
  '2026-03-09T08:00:00+00:00', '2026-03-08T09:28:00+00:00', false, 13.0, true, false,
  '2026-03-09T08:00:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030001', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030002', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030003', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030004', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030005', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030006', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030007', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030008', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030009', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030010', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030011', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030012', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030013', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030014', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030015', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  2.0, 0.67, 2.0,
  '{"comment": "AI chấm: 2.0/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400030016', '00000000-0000-0000-0000-bb0004000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Cao Cường. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  2.0, 0.67, 2.0,
  '{"comment": "AI chấm: 2.0/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00', '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Cường - A4 | score=6.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0004000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', '0009cad5-6c63-5cc3-9596-dd0ed89ac948',
  '2026-03-25T08:00:00+00:00', '2026-03-24T09:28:00+00:00', 1, 'submitted', 960,
  '2026-03-25T08:00:00+00:00', '2026-03-24T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0004000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', '0009cad5-6c63-5cc3-9596-dd0ed89ac948', '00000000-0000-0000-0000-bb0004000004',
  '2026-03-25T08:00:00+00:00', '2026-03-24T09:28:00+00:00', false, 6.5, false, false,
  '2026-03-25T08:00:00+00:00', '2026-03-24T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400040001', '00000000-0000-0000-0000-bb0004000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400040002', '00000000-0000-0000-0000-bb0004000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400040003', '00000000-0000-0000-0000-bb0004000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400040004', '00000000-0000-0000-0000-bb0004000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400040005', '00000000-0000-0000-0000-bb0004000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Cao Cường cho câu 5"}',
  1.0, 0.5, 1.0,
  '{"comment": "AI chấm: 1.0/2.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000400040006', '00000000-0000-0000-0000-bb0004000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Cao Cường. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  2.5, 0.62, 2.5,
  '{"comment": "AI chấm: 2.5/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00', '2026-03-24T09:28:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Đức Anh Quân - A1 | score=7.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0005000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', 'd0318e10-3203-5130-9992-fba4053f5edb',
  '2026-02-10T09:00:00+00:00', '2026-02-09T10:35:00+00:00', 1, 'submitted', 900,
  '2026-02-10T09:00:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0005000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', 'd0318e10-3203-5130-9992-fba4053f5edb', '00000000-0000-0000-0000-bb0005000001',
  '2026-02-10T09:00:00+00:00', '2026-02-09T10:35:00+00:00', false, 7.0, true, false,
  '2026-02-10T09:00:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500010001', '00000000-0000-0000-0000-bb0005000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500010002', '00000000-0000-0000-0000-bb0005000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500010003', '00000000-0000-0000-0000-bb0005000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500010004', '00000000-0000-0000-0000-bb0005000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500010005', '00000000-0000-0000-0000-bb0005000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500010006', '00000000-0000-0000-0000-bb0005000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500010007', '00000000-0000-0000-0000-bb0005000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500010008', '00000000-0000-0000-0000-bb0005000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500010009', '00000000-0000-0000-0000-bb0005000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500010010', '00000000-0000-0000-0000-bb0005000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00', '2026-02-09T10:35:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Đức Anh Quân - A2 | score=6.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0005000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', 'd0318e10-3203-5130-9992-fba4053f5edb',
  '2026-02-24T09:00:00+00:00', '2026-02-23T10:35:00+00:00', 1, 'submitted', 960,
  '2026-02-24T09:00:00+00:00', '2026-02-23T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0005000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', 'd0318e10-3203-5130-9992-fba4053f5edb', '00000000-0000-0000-0000-bb0005000002',
  '2026-02-24T09:00:00+00:00', '2026-02-23T10:35:00+00:00', false, 6.5, true, false,
  '2026-02-24T09:00:00+00:00', '2026-02-23T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500020001', '00000000-0000-0000-0000-bb0005000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500020002', '00000000-0000-0000-0000-bb0005000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500020003', '00000000-0000-0000-0000-bb0005000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500020004', '00000000-0000-0000-0000-bb0005000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500020005', '00000000-0000-0000-0000-bb0005000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Cao Đức Anh Quân cho câu 5"}',
  1.5, 0.75, 1.5,
  '{"comment": "AI chấm: 1.5/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500020006', '00000000-0000-0000-0000-bb0005000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Cao Đức Anh Quân. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  2.0, 0.5, 2.0,
  '{"comment": "AI chấm: 2.0/4.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00', '2026-02-23T10:35:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Đức Anh Quân - A3 | score=10.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0005000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', 'd0318e10-3203-5130-9992-fba4053f5edb',
  '2026-03-10T09:00:00+00:00', '2026-03-09T10:35:00+00:00', 1, 'submitted', 1020,
  '2026-03-10T09:00:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0005000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', 'd0318e10-3203-5130-9992-fba4053f5edb', '00000000-0000-0000-0000-bb0005000003',
  '2026-03-10T09:00:00+00:00', '2026-03-09T10:35:00+00:00', false, 10.5, true, false,
  '2026-03-10T09:00:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030001', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030002', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030003', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030004', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030005', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030006', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030007', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030008', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030009', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030010', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030011', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030012', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030013', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030014', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030015', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  1.5, 0.5, 1.5,
  '{"comment": "AI chấm: 1.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500030016', '00000000-0000-0000-0000-bb0005000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Cao Đức Anh Quân. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  1.0, 0.33, 1.0,
  '{"comment": "AI chấm: 1.0/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00', '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Đức Anh Quân - A4 | score=3.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0005000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', 'd0318e10-3203-5130-9992-fba4053f5edb',
  '2026-03-26T09:00:00+00:00', '2026-03-25T10:35:00+00:00', 1, 'submitted', 1080,
  '2026-03-26T09:00:00+00:00', '2026-03-25T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0005000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', 'd0318e10-3203-5130-9992-fba4053f5edb', '00000000-0000-0000-0000-bb0005000004',
  '2026-03-26T09:00:00+00:00', '2026-03-25T10:35:00+00:00', false, 3.0, false, false,
  '2026-03-26T09:00:00+00:00', '2026-03-25T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500040001', '00000000-0000-0000-0000-bb0005000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500040002', '00000000-0000-0000-0000-bb0005000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500040003', '00000000-0000-0000-0000-bb0005000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500040004', '00000000-0000-0000-0000-bb0005000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500040005', '00000000-0000-0000-0000-bb0005000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Cao Đức Anh Quân cho câu 5"}',
  0.5, 0.25, 0.5,
  '{"comment": "AI chấm: 0.5/2.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000500040006', '00000000-0000-0000-0000-bb0005000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Cao Đức Anh Quân. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  1.5, 0.38, 1.5,
  '{"comment": "AI chấm: 1.5/4.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00', '2026-03-25T10:35:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Việt Hoàng - A1 | score=4.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0006000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', '5cbaae02-acd6-5121-83b2-f76819103ad2',
  '2026-02-08T07:00:00+00:00', '2026-02-08T11:42:00+00:00', 1, 'submitted', 1020,
  '2026-02-08T07:00:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0006000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', '5cbaae02-acd6-5121-83b2-f76819103ad2', '00000000-0000-0000-0000-bb0006000001',
  '2026-02-08T07:00:00+00:00', '2026-02-08T11:42:00+00:00', false, 4.0, true, false,
  '2026-02-08T07:00:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600010001', '00000000-0000-0000-0000-bb0006000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600010002', '00000000-0000-0000-0000-bb0006000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600010003', '00000000-0000-0000-0000-bb0006000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600010004', '00000000-0000-0000-0000-bb0006000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600010005', '00000000-0000-0000-0000-bb0006000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600010006', '00000000-0000-0000-0000-bb0006000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600010007', '00000000-0000-0000-0000-bb0006000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600010008', '00000000-0000-0000-0000-bb0006000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600010009', '00000000-0000-0000-0000-bb0006000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600010010', '00000000-0000-0000-0000-bb0006000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00', '2026-02-08T11:42:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Việt Hoàng - A2 | score=3.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0006000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', '5cbaae02-acd6-5121-83b2-f76819103ad2',
  '2026-02-22T07:00:00+00:00', '2026-02-22T11:42:00+00:00', 1, 'submitted', 1080,
  '2026-02-22T07:00:00+00:00', '2026-02-22T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0006000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', '5cbaae02-acd6-5121-83b2-f76819103ad2', '00000000-0000-0000-0000-bb0006000002',
  '2026-02-22T07:00:00+00:00', '2026-02-22T11:42:00+00:00', false, 3.0, true, false,
  '2026-02-22T07:00:00+00:00', '2026-02-22T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600020001', '00000000-0000-0000-0000-bb0006000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600020002', '00000000-0000-0000-0000-bb0006000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600020003', '00000000-0000-0000-0000-bb0006000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600020004', '00000000-0000-0000-0000-bb0006000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600020005', '00000000-0000-0000-0000-bb0006000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Cao Việt Hoàng cho câu 5"}',
  1.0, 0.5, 1.0,
  '{"comment": "AI chấm: 1.0/2.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600020006', '00000000-0000-0000-0000-bb0006000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Cao Việt Hoàng. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  1.0, 0.25, 1.0,
  '{"comment": "AI chấm: 1.0/4.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00', '2026-02-22T11:42:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Việt Hoàng - A3 | score=4.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0006000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', '5cbaae02-acd6-5121-83b2-f76819103ad2',
  '2026-03-08T07:00:00+00:00', '2026-03-08T11:42:00+00:00', 1, 'submitted', 1140,
  '2026-03-08T07:00:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0006000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', '5cbaae02-acd6-5121-83b2-f76819103ad2', '00000000-0000-0000-0000-bb0006000003',
  '2026-03-08T07:00:00+00:00', '2026-03-08T11:42:00+00:00', false, 4.0, true, false,
  '2026-03-08T07:00:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030001', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030002', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030003', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030004', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030005', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030006', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030007', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030008', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030009', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030010', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030011', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030012', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030013', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030014', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030015', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  0.5, 0.17, 0.5,
  '{"comment": "AI chấm: 0.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000600030016', '00000000-0000-0000-0000-bb0006000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Cao Việt Hoàng. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  0.5, 0.17, 0.5,
  '{"comment": "AI chấm: 0.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00', '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;

-- Cao Việt Hoàng chưa nộp A4 (còn hạn)
-- Đặng Bảo Anh - A1 | score=10.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0007000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', 'c8778c6b-7099-5c09-916c-6b0dabafde41',
  '2026-02-09T08:00:00+00:00', '2026-02-09T12:49:00+00:00', 1, 'submitted', 1140,
  '2026-02-09T08:00:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0007000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', 'c8778c6b-7099-5c09-916c-6b0dabafde41', '00000000-0000-0000-0000-bb0007000001',
  '2026-02-09T08:00:00+00:00', '2026-02-09T12:49:00+00:00', false, 10.0, true, false,
  '2026-02-09T08:00:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700010001', '00000000-0000-0000-0000-bb0007000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700010002', '00000000-0000-0000-0000-bb0007000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700010003', '00000000-0000-0000-0000-bb0007000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700010004', '00000000-0000-0000-0000-bb0007000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700010005', '00000000-0000-0000-0000-bb0007000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700010006', '00000000-0000-0000-0000-bb0007000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700010007', '00000000-0000-0000-0000-bb0007000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700010008', '00000000-0000-0000-0000-bb0007000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700010009', '00000000-0000-0000-0000-bb0007000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700010010', '00000000-0000-0000-0000-bb0007000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00', '2026-02-09T12:49:00+00:00') ON CONFLICT DO NOTHING;

-- Đặng Bảo Anh - A2 | score=10.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0007000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', 'c8778c6b-7099-5c09-916c-6b0dabafde41',
  '2026-02-23T08:00:00+00:00', '2026-02-23T12:49:00+00:00', 1, 'submitted', 1200,
  '2026-02-23T08:00:00+00:00', '2026-02-23T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0007000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', 'c8778c6b-7099-5c09-916c-6b0dabafde41', '00000000-0000-0000-0000-bb0007000002',
  '2026-02-23T08:00:00+00:00', '2026-02-23T12:49:00+00:00', false, 10.0, true, false,
  '2026-02-23T08:00:00+00:00', '2026-02-23T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700020001', '00000000-0000-0000-0000-bb0007000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700020002', '00000000-0000-0000-0000-bb0007000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700020003', '00000000-0000-0000-0000-bb0007000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700020004', '00000000-0000-0000-0000-bb0007000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700020005', '00000000-0000-0000-0000-bb0007000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Đặng Bảo Anh cho câu 5"}',
  2.0, 1.0, 2.0,
  '{"comment": "AI chấm: 2.0/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700020006', '00000000-0000-0000-0000-bb0007000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Đặng Bảo Anh. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  4.0, 1.0, 4.0,
  '{"comment": "AI chấm: 4.0/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00', '2026-02-23T12:49:00+00:00') ON CONFLICT DO NOTHING;

-- Đặng Bảo Anh - A3 | score=20.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0007000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', 'c8778c6b-7099-5c09-916c-6b0dabafde41',
  '2026-03-09T08:00:00+00:00', '2026-03-09T12:49:00+00:00', 1, 'submitted', 1260,
  '2026-03-09T08:00:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0007000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', 'c8778c6b-7099-5c09-916c-6b0dabafde41', '00000000-0000-0000-0000-bb0007000003',
  '2026-03-09T08:00:00+00:00', '2026-03-09T12:49:00+00:00', false, 20.0, true, false,
  '2026-03-09T08:00:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030001', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030002', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030003', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030004', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030005', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030006', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030007', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030008', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [3]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030009', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030010', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030011', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030012', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030013', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030014', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030015', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  3.0, 1.0, 3.0,
  '{"comment": "AI chấm: 3.0/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700030016', '00000000-0000-0000-0000-bb0007000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Đặng Bảo Anh. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  3.0, 1.0, 3.0,
  '{"comment": "AI chấm: 3.0/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00', '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;

-- Đặng Bảo Anh - A4 | score=10.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0007000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', 'c8778c6b-7099-5c09-916c-6b0dabafde41',
  '2026-03-25T08:00:00+00:00', '2026-03-25T12:49:00+00:00', 1, 'submitted', 1320,
  '2026-03-25T08:00:00+00:00', '2026-03-25T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0007000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', 'c8778c6b-7099-5c09-916c-6b0dabafde41', '00000000-0000-0000-0000-bb0007000004',
  '2026-03-25T08:00:00+00:00', '2026-03-25T12:49:00+00:00', false, 10.0, false, false,
  '2026-03-25T08:00:00+00:00', '2026-03-25T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700040001', '00000000-0000-0000-0000-bb0007000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700040002', '00000000-0000-0000-0000-bb0007000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700040003', '00000000-0000-0000-0000-bb0007000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700040004', '00000000-0000-0000-0000-bb0007000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700040005', '00000000-0000-0000-0000-bb0007000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Đặng Bảo Anh cho câu 5"}',
  2.0, 1.0, 2.0,
  '{"comment": "AI chấm: 2.0/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000700040006', '00000000-0000-0000-0000-bb0007000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Đặng Bảo Anh. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  4.0, 1.0, 4.0,
  '{"comment": "AI chấm: 4.0/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00', '2026-03-25T12:49:00+00:00') ON CONFLICT DO NOTHING;

-- Đặng Huỳnh Quang - A1 | score=7.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0008000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', 'f32ec038-e7de-5900-9f8e-399dcbc4a904',
  '2026-02-10T09:00:00+00:00', '2026-02-08T09:56:00+00:00', 1, 'submitted', 1260,
  '2026-02-10T09:00:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0008000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', 'f32ec038-e7de-5900-9f8e-399dcbc4a904', '00000000-0000-0000-0000-bb0008000001',
  '2026-02-10T09:00:00+00:00', '2026-02-08T09:56:00+00:00', false, 7.0, true, false,
  '2026-02-10T09:00:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800010001', '00000000-0000-0000-0000-bb0008000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800010002', '00000000-0000-0000-0000-bb0008000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800010003', '00000000-0000-0000-0000-bb0008000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800010004', '00000000-0000-0000-0000-bb0008000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800010005', '00000000-0000-0000-0000-bb0008000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800010006', '00000000-0000-0000-0000-bb0008000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800010007', '00000000-0000-0000-0000-bb0008000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800010008', '00000000-0000-0000-0000-bb0008000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800010009', '00000000-0000-0000-0000-bb0008000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800010010', '00000000-0000-0000-0000-bb0008000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00', '2026-02-08T09:56:00+00:00') ON CONFLICT DO NOTHING;

-- Đặng Huỳnh Quang - A2 | score=7.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0008000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', 'f32ec038-e7de-5900-9f8e-399dcbc4a904',
  '2026-02-24T09:00:00+00:00', '2026-02-22T09:56:00+00:00', 1, 'submitted', 1320,
  '2026-02-24T09:00:00+00:00', '2026-02-22T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0008000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', 'f32ec038-e7de-5900-9f8e-399dcbc4a904', '00000000-0000-0000-0000-bb0008000002',
  '2026-02-24T09:00:00+00:00', '2026-02-22T09:56:00+00:00', false, 7.0, true, false,
  '2026-02-24T09:00:00+00:00', '2026-02-22T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800020001', '00000000-0000-0000-0000-bb0008000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800020002', '00000000-0000-0000-0000-bb0008000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800020003', '00000000-0000-0000-0000-bb0008000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800020004', '00000000-0000-0000-0000-bb0008000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800020005', '00000000-0000-0000-0000-bb0008000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Đặng Huỳnh Quang cho câu 5"}',
  1.5, 0.75, 1.5,
  '{"comment": "AI chấm: 1.5/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800020006', '00000000-0000-0000-0000-bb0008000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Đặng Huỳnh Quang. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  2.5, 0.62, 2.5,
  '{"comment": "AI chấm: 2.5/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00', '2026-02-22T09:56:00+00:00') ON CONFLICT DO NOTHING;

-- Đặng Huỳnh Quang - A3 | score=11.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0008000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', 'f32ec038-e7de-5900-9f8e-399dcbc4a904',
  '2026-03-10T09:00:00+00:00', '2026-03-08T09:56:00+00:00', 1, 'submitted', 1380,
  '2026-03-10T09:00:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0008000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', 'f32ec038-e7de-5900-9f8e-399dcbc4a904', '00000000-0000-0000-0000-bb0008000003',
  '2026-03-10T09:00:00+00:00', '2026-03-08T09:56:00+00:00', false, 11.5, true, false,
  '2026-03-10T09:00:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030001', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030002', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030003', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030004', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030005', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030006', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030007', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030008', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [3]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030009', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030010', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030011', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030012', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030013', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030014', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030015', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  1.5, 0.5, 1.5,
  '{"comment": "AI chấm: 1.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800030016', '00000000-0000-0000-0000-bb0008000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Đặng Huỳnh Quang. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  2.0, 0.67, 2.0,
  '{"comment": "AI chấm: 2.0/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00', '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;

-- Đặng Huỳnh Quang - A4 | score=7.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0008000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', 'f32ec038-e7de-5900-9f8e-399dcbc4a904',
  '2026-03-26T09:00:00+00:00', '2026-03-24T09:56:00+00:00', 1, 'submitted', 1440,
  '2026-03-26T09:00:00+00:00', '2026-03-24T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0008000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', 'f32ec038-e7de-5900-9f8e-399dcbc4a904', '00000000-0000-0000-0000-bb0008000004',
  '2026-03-26T09:00:00+00:00', '2026-03-24T09:56:00+00:00', false, 7.0, false, false,
  '2026-03-26T09:00:00+00:00', '2026-03-24T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800040001', '00000000-0000-0000-0000-bb0008000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800040002', '00000000-0000-0000-0000-bb0008000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800040003', '00000000-0000-0000-0000-bb0008000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800040004', '00000000-0000-0000-0000-bb0008000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800040005', '00000000-0000-0000-0000-bb0008000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Đặng Huỳnh Quang cho câu 5"}',
  1.5, 0.75, 1.5,
  '{"comment": "AI chấm: 1.5/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000800040006', '00000000-0000-0000-0000-bb0008000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Đặng Huỳnh Quang. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  2.5, 0.62, 2.5,
  '{"comment": "AI chấm: 2.5/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00', '2026-03-24T09:56:00+00:00') ON CONFLICT DO NOTHING;

-- Đào Bình Phước - A1 | score=6.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0009000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', '98f08d80-eff4-5335-a524-036c8f213890',
  '2026-02-08T07:00:00+00:00', '2026-02-09T10:03:00+00:00', 1, 'submitted', 1380,
  '2026-02-08T07:00:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0009000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', '98f08d80-eff4-5335-a524-036c8f213890', '00000000-0000-0000-0000-bb0009000001',
  '2026-02-08T07:00:00+00:00', '2026-02-09T10:03:00+00:00', false, 6.0, true, false,
  '2026-02-08T07:00:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900010001', '00000000-0000-0000-0000-bb0009000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900010002', '00000000-0000-0000-0000-bb0009000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900010003', '00000000-0000-0000-0000-bb0009000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900010004', '00000000-0000-0000-0000-bb0009000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900010005', '00000000-0000-0000-0000-bb0009000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900010006', '00000000-0000-0000-0000-bb0009000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900010007', '00000000-0000-0000-0000-bb0009000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900010008', '00000000-0000-0000-0000-bb0009000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900010009', '00000000-0000-0000-0000-bb0009000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900010010', '00000000-0000-0000-0000-bb0009000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00', '2026-02-09T10:03:00+00:00') ON CONFLICT DO NOTHING;

-- Đào Bình Phước - A2 | score=5.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0009000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', '98f08d80-eff4-5335-a524-036c8f213890',
  '2026-02-22T07:00:00+00:00', '2026-02-23T10:03:00+00:00', 1, 'submitted', 1440,
  '2026-02-22T07:00:00+00:00', '2026-02-23T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0009000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', '98f08d80-eff4-5335-a524-036c8f213890', '00000000-0000-0000-0000-bb0009000002',
  '2026-02-22T07:00:00+00:00', '2026-02-23T10:03:00+00:00', false, 5.0, true, false,
  '2026-02-22T07:00:00+00:00', '2026-02-23T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900020001', '00000000-0000-0000-0000-bb0009000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900020002', '00000000-0000-0000-0000-bb0009000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900020003', '00000000-0000-0000-0000-bb0009000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900020004', '00000000-0000-0000-0000-bb0009000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900020005', '00000000-0000-0000-0000-bb0009000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Đào Bình Phước cho câu 5"}',
  1.0, 0.5, 1.0,
  '{"comment": "AI chấm: 1.0/2.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900020006', '00000000-0000-0000-0000-bb0009000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Đào Bình Phước. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  2.0, 0.5, 2.0,
  '{"comment": "AI chấm: 2.0/4.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00', '2026-02-23T10:03:00+00:00') ON CONFLICT DO NOTHING;

-- Đào Bình Phước - A3 | score=8.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0009000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', '98f08d80-eff4-5335-a524-036c8f213890',
  '2026-03-08T07:00:00+00:00', '2026-03-09T10:03:00+00:00', 1, 'submitted', 1500,
  '2026-03-08T07:00:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0009000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', '98f08d80-eff4-5335-a524-036c8f213890', '00000000-0000-0000-0000-bb0009000003',
  '2026-03-08T07:00:00+00:00', '2026-03-09T10:03:00+00:00', false, 8.5, true, false,
  '2026-03-08T07:00:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030001', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030002', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030003', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030004', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030005', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030006', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030007', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030008', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030009', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030010', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030011', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030012', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030013', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030014', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030015', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  1.0, 0.33, 1.0,
  '{"comment": "AI chấm: 1.0/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900030016', '00000000-0000-0000-0000-bb0009000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Đào Bình Phước. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  1.5, 0.5, 1.5,
  '{"comment": "AI chấm: 1.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00', '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;

-- Đào Bình Phước - A4 | score=5.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0009000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', '98f08d80-eff4-5335-a524-036c8f213890',
  '2026-03-24T07:00:00+00:00', '2026-03-25T10:03:00+00:00', 1, 'submitted', 1560,
  '2026-03-24T07:00:00+00:00', '2026-03-25T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0009000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', '98f08d80-eff4-5335-a524-036c8f213890', '00000000-0000-0000-0000-bb0009000004',
  '2026-03-24T07:00:00+00:00', '2026-03-25T10:03:00+00:00', false, 5.0, false, false,
  '2026-03-24T07:00:00+00:00', '2026-03-25T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900040001', '00000000-0000-0000-0000-bb0009000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900040002', '00000000-0000-0000-0000-bb0009000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900040003', '00000000-0000-0000-0000-bb0009000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900040004', '00000000-0000-0000-0000-bb0009000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900040005', '00000000-0000-0000-0000-bb0009000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Đào Bình Phước cho câu 5"}',
  1.0, 0.5, 1.0,
  '{"comment": "AI chấm: 1.0/2.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000900040006', '00000000-0000-0000-0000-bb0009000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Đào Bình Phước. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  2.0, 0.5, 2.0,
  '{"comment": "AI chấm: 2.0/4.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00', '2026-03-25T10:03:00+00:00') ON CONFLICT DO NOTHING;

-- Đào Duy Phúc - A1 | score=8.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0010000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', '24ed3ce4-4a9a-53d4-9b37-1606ac49dee4',
  '2026-02-09T08:00:00+00:00', '2026-02-08T11:10:00+00:00', 1, 'submitted', 1500,
  '2026-02-09T08:00:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0010000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', '24ed3ce4-4a9a-53d4-9b37-1606ac49dee4', '00000000-0000-0000-0000-bb0010000001',
  '2026-02-09T08:00:00+00:00', '2026-02-08T11:10:00+00:00', false, 8.0, true, false,
  '2026-02-09T08:00:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000010001', '00000000-0000-0000-0000-bb0010000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000010002', '00000000-0000-0000-0000-bb0010000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000010003', '00000000-0000-0000-0000-bb0010000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000010004', '00000000-0000-0000-0000-bb0010000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000010005', '00000000-0000-0000-0000-bb0010000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000010006', '00000000-0000-0000-0000-bb0010000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000010007', '00000000-0000-0000-0000-bb0010000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000010008', '00000000-0000-0000-0000-bb0010000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000010009', '00000000-0000-0000-0000-bb0010000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000010010', '00000000-0000-0000-0000-bb0010000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00', '2026-02-08T11:10:00+00:00') ON CONFLICT DO NOTHING;

-- Đào Duy Phúc - A2 | score=9.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0010000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', '24ed3ce4-4a9a-53d4-9b37-1606ac49dee4',
  '2026-02-23T08:00:00+00:00', '2026-02-22T11:10:00+00:00', 1, 'submitted', 1560,
  '2026-02-23T08:00:00+00:00', '2026-02-22T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0010000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', '24ed3ce4-4a9a-53d4-9b37-1606ac49dee4', '00000000-0000-0000-0000-bb0010000002',
  '2026-02-23T08:00:00+00:00', '2026-02-22T11:10:00+00:00', false, 9.0, true, false,
  '2026-02-23T08:00:00+00:00', '2026-02-22T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000020001', '00000000-0000-0000-0000-bb0010000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000020002', '00000000-0000-0000-0000-bb0010000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000020003', '00000000-0000-0000-0000-bb0010000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000020004', '00000000-0000-0000-0000-bb0010000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000020005', '00000000-0000-0000-0000-bb0010000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Đào Duy Phúc cho câu 5"}',
  2.0, 1.0, 2.0,
  '{"comment": "AI chấm: 2.0/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000020006', '00000000-0000-0000-0000-bb0010000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Đào Duy Phúc. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  3.0, 0.75, 3.0,
  '{"comment": "AI chấm: 3.0/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00', '2026-02-22T11:10:00+00:00') ON CONFLICT DO NOTHING;

-- Đào Duy Phúc - A3 | score=15.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0010000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', '24ed3ce4-4a9a-53d4-9b37-1606ac49dee4',
  '2026-03-09T08:00:00+00:00', '2026-03-08T11:10:00+00:00', 1, 'submitted', 1620,
  '2026-03-09T08:00:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0010000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', '24ed3ce4-4a9a-53d4-9b37-1606ac49dee4', '00000000-0000-0000-0000-bb0010000003',
  '2026-03-09T08:00:00+00:00', '2026-03-08T11:10:00+00:00', false, 15.5, true, false,
  '2026-03-09T08:00:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030001', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030002', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030003', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030004', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030005', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030006', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030007', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030008', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [3]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030009', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030010', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030011', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030012', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030013', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030014', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030015', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  2.0, 0.67, 2.0,
  '{"comment": "AI chấm: 2.0/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000030016', '00000000-0000-0000-0000-bb0010000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Đào Duy Phúc. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  2.5, 0.83, 2.5,
  '{"comment": "AI chấm: 2.5/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00', '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;

-- Đào Duy Phúc - A4 | score=9.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0010000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', '24ed3ce4-4a9a-53d4-9b37-1606ac49dee4',
  '2026-03-25T08:00:00+00:00', '2026-03-24T11:10:00+00:00', 1, 'submitted', 1680,
  '2026-03-25T08:00:00+00:00', '2026-03-24T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0010000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', '24ed3ce4-4a9a-53d4-9b37-1606ac49dee4', '00000000-0000-0000-0000-bb0010000004',
  '2026-03-25T08:00:00+00:00', '2026-03-24T11:10:00+00:00', false, 9.0, false, false,
  '2026-03-25T08:00:00+00:00', '2026-03-24T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000040001', '00000000-0000-0000-0000-bb0010000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000040002', '00000000-0000-0000-0000-bb0010000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000040003', '00000000-0000-0000-0000-bb0010000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000040004', '00000000-0000-0000-0000-bb0010000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000040005', '00000000-0000-0000-0000-bb0010000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Đào Duy Phúc cho câu 5"}',
  2.0, 1.0, 2.0,
  '{"comment": "AI chấm: 2.0/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001000040006', '00000000-0000-0000-0000-bb0010000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Đào Duy Phúc. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  3.0, 0.75, 3.0,
  '{"comment": "AI chấm: 3.0/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00', '2026-03-24T11:10:00+00:00') ON CONFLICT DO NOTHING;

-- Đinh Hải Siêu - A1 | score=5.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0011000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', 'c09e4f67-2386-5909-9adb-15bbbf6a191c',
  '2026-02-10T09:00:00+00:00', '2026-02-09T12:17:00+00:00', 1, 'submitted', 1620,
  '2026-02-10T09:00:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0011000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', 'c09e4f67-2386-5909-9adb-15bbbf6a191c', '00000000-0000-0000-0000-bb0011000001',
  '2026-02-10T09:00:00+00:00', '2026-02-09T12:17:00+00:00', false, 5.0, true, false,
  '2026-02-10T09:00:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100010001', '00000000-0000-0000-0000-bb0011000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100010002', '00000000-0000-0000-0000-bb0011000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100010003', '00000000-0000-0000-0000-bb0011000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100010004', '00000000-0000-0000-0000-bb0011000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100010005', '00000000-0000-0000-0000-bb0011000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100010006', '00000000-0000-0000-0000-bb0011000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100010007', '00000000-0000-0000-0000-bb0011000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100010008', '00000000-0000-0000-0000-bb0011000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100010009', '00000000-0000-0000-0000-bb0011000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100010010', '00000000-0000-0000-0000-bb0011000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00', '2026-02-09T12:17:00+00:00') ON CONFLICT DO NOTHING;

-- Đinh Hải Siêu - A2 | score=6.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0011000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', 'c09e4f67-2386-5909-9adb-15bbbf6a191c',
  '2026-02-24T09:00:00+00:00', '2026-02-23T12:17:00+00:00', 1, 'submitted', 1680,
  '2026-02-24T09:00:00+00:00', '2026-02-23T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0011000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', 'c09e4f67-2386-5909-9adb-15bbbf6a191c', '00000000-0000-0000-0000-bb0011000002',
  '2026-02-24T09:00:00+00:00', '2026-02-23T12:17:00+00:00', false, 6.0, true, false,
  '2026-02-24T09:00:00+00:00', '2026-02-23T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100020001', '00000000-0000-0000-0000-bb0011000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100020002', '00000000-0000-0000-0000-bb0011000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100020003', '00000000-0000-0000-0000-bb0011000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100020004', '00000000-0000-0000-0000-bb0011000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100020005', '00000000-0000-0000-0000-bb0011000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Đinh Hải Siêu cho câu 5"}',
  1.0, 0.5, 1.0,
  '{"comment": "AI chấm: 1.0/2.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100020006', '00000000-0000-0000-0000-bb0011000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Đinh Hải Siêu. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  2.0, 0.5, 2.0,
  '{"comment": "AI chấm: 2.0/4.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00', '2026-02-23T12:17:00+00:00') ON CONFLICT DO NOTHING;

-- Đinh Hải Siêu - A3 | score=12.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0011000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', 'c09e4f67-2386-5909-9adb-15bbbf6a191c',
  '2026-03-10T09:00:00+00:00', '2026-03-09T12:17:00+00:00', 1, 'submitted', 1740,
  '2026-03-10T09:00:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0011000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', 'c09e4f67-2386-5909-9adb-15bbbf6a191c', '00000000-0000-0000-0000-bb0011000003',
  '2026-03-10T09:00:00+00:00', '2026-03-09T12:17:00+00:00', false, 12.5, true, false,
  '2026-03-10T09:00:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030001', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030002', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030003', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030004', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030005', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030006', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030007', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030008', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [3]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030009', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030010', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030011', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030012', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030013', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030014', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030015', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  1.5, 0.5, 1.5,
  '{"comment": "AI chấm: 1.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100030016', '00000000-0000-0000-0000-bb0011000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Đinh Hải Siêu. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  2.0, 0.67, 2.0,
  '{"comment": "AI chấm: 2.0/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00', '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;

-- Đinh Hải Siêu - A4 | score=9.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0011000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', 'c09e4f67-2386-5909-9adb-15bbbf6a191c',
  '2026-03-26T09:00:00+00:00', '2026-03-25T12:17:00+00:00', 1, 'submitted', 1800,
  '2026-03-26T09:00:00+00:00', '2026-03-25T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0011000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', 'c09e4f67-2386-5909-9adb-15bbbf6a191c', '00000000-0000-0000-0000-bb0011000004',
  '2026-03-26T09:00:00+00:00', '2026-03-25T12:17:00+00:00', false, 9.5, false, false,
  '2026-03-26T09:00:00+00:00', '2026-03-25T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100040001', '00000000-0000-0000-0000-bb0011000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100040002', '00000000-0000-0000-0000-bb0011000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100040003', '00000000-0000-0000-0000-bb0011000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100040004', '00000000-0000-0000-0000-bb0011000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100040005', '00000000-0000-0000-0000-bb0011000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Đinh Hải Siêu cho câu 5"}',
  2.0, 1.0, 2.0,
  '{"comment": "AI chấm: 2.0/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001100040006', '00000000-0000-0000-0000-bb0011000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Đinh Hải Siêu. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  3.5, 0.88, 3.5,
  '{"comment": "AI chấm: 3.5/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00', '2026-03-25T12:17:00+00:00') ON CONFLICT DO NOTHING;

-- Đinh Lê Hoàng - A1 | score=4.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0012000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', '1b091e49-228a-5e43-99ed-47ce336fbdb8',
  '2026-02-08T07:00:00+00:00', '2026-02-08T09:24:00+00:00', 1, 'submitted', 1740,
  '2026-02-08T07:00:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0012000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', '1b091e49-228a-5e43-99ed-47ce336fbdb8', '00000000-0000-0000-0000-bb0012000001',
  '2026-02-08T07:00:00+00:00', '2026-02-08T09:24:00+00:00', false, 4.0, true, false,
  '2026-02-08T07:00:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200010001', '00000000-0000-0000-0000-bb0012000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200010002', '00000000-0000-0000-0000-bb0012000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200010003', '00000000-0000-0000-0000-bb0012000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200010004', '00000000-0000-0000-0000-bb0012000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200010005', '00000000-0000-0000-0000-bb0012000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200010006', '00000000-0000-0000-0000-bb0012000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200010007', '00000000-0000-0000-0000-bb0012000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200010008', '00000000-0000-0000-0000-bb0012000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200010009', '00000000-0000-0000-0000-bb0012000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200010010', '00000000-0000-0000-0000-bb0012000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00', '2026-02-08T09:24:00+00:00') ON CONFLICT DO NOTHING;

-- Đinh Lê Hoàng - A2 | score=1.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0012000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', '1b091e49-228a-5e43-99ed-47ce336fbdb8',
  '2026-02-22T07:00:00+00:00', '2026-02-22T09:24:00+00:00', 1, 'submitted', 1800,
  '2026-02-22T07:00:00+00:00', '2026-02-22T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0012000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', '1b091e49-228a-5e43-99ed-47ce336fbdb8', '00000000-0000-0000-0000-bb0012000002',
  '2026-02-22T07:00:00+00:00', '2026-02-22T09:24:00+00:00', false, 1.0, true, false,
  '2026-02-22T07:00:00+00:00', '2026-02-22T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200020001', '00000000-0000-0000-0000-bb0012000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200020002', '00000000-0000-0000-0000-bb0012000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200020003', '00000000-0000-0000-0000-bb0012000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200020004', '00000000-0000-0000-0000-bb0012000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200020005', '00000000-0000-0000-0000-bb0012000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Đinh Lê Hoàng cho câu 5"}',
  0.5, 0.25, 0.5,
  '{"comment": "AI chấm: 0.5/2.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200020006', '00000000-0000-0000-0000-bb0012000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Đinh Lê Hoàng. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  0.5, 0.12, 0.5,
  '{"comment": "AI chấm: 0.5/4.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00', '2026-02-22T09:24:00+00:00') ON CONFLICT DO NOTHING;

-- Đinh Lê Hoàng - A3 | score=2.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0012000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', '1b091e49-228a-5e43-99ed-47ce336fbdb8',
  '2026-03-08T07:00:00+00:00', '2026-03-08T09:24:00+00:00', 1, 'submitted', 1860,
  '2026-03-08T07:00:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0012000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', '1b091e49-228a-5e43-99ed-47ce336fbdb8', '00000000-0000-0000-0000-bb0012000003',
  '2026-03-08T07:00:00+00:00', '2026-03-08T09:24:00+00:00', false, 2.0, true, false,
  '2026-03-08T07:00:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030001', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030002', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030003', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030004', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030005', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030006', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030007', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030008', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030009', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030010', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030011', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030012', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030013', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030014', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030015', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  0.5, 0.17, 0.5,
  '{"comment": "AI chấm: 0.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001200030016', '00000000-0000-0000-0000-bb0012000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Đinh Lê Hoàng. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  0.5, 0.17, 0.5,
  '{"comment": "AI chấm: 0.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00', '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;

-- Đinh Lê Hoàng chưa nộp A4 (còn hạn)
-- Đoàn Thanh Quang - A1 | score=8.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0013000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', '80cf60e4-7ba9-5658-9e3c-b232707d34b7',
  '2026-02-09T08:00:00+00:00', '2026-02-09T10:31:00+00:00', 1, 'submitted', 1860,
  '2026-02-09T08:00:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0013000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', '80cf60e4-7ba9-5658-9e3c-b232707d34b7', '00000000-0000-0000-0000-bb0013000001',
  '2026-02-09T08:00:00+00:00', '2026-02-09T10:31:00+00:00', false, 8.0, true, false,
  '2026-02-09T08:00:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300010001', '00000000-0000-0000-0000-bb0013000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300010002', '00000000-0000-0000-0000-bb0013000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300010003', '00000000-0000-0000-0000-bb0013000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300010004', '00000000-0000-0000-0000-bb0013000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300010005', '00000000-0000-0000-0000-bb0013000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300010006', '00000000-0000-0000-0000-bb0013000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300010007', '00000000-0000-0000-0000-bb0013000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300010008', '00000000-0000-0000-0000-bb0013000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300010009', '00000000-0000-0000-0000-bb0013000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300010010', '00000000-0000-0000-0000-bb0013000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00', '2026-02-09T10:31:00+00:00') ON CONFLICT DO NOTHING;

-- Đoàn Thanh Quang - A2 | score=8.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0013000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', '80cf60e4-7ba9-5658-9e3c-b232707d34b7',
  '2026-02-23T08:00:00+00:00', '2026-02-23T10:31:00+00:00', 1, 'submitted', 1920,
  '2026-02-23T08:00:00+00:00', '2026-02-23T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0013000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', '80cf60e4-7ba9-5658-9e3c-b232707d34b7', '00000000-0000-0000-0000-bb0013000002',
  '2026-02-23T08:00:00+00:00', '2026-02-23T10:31:00+00:00', false, 8.5, true, false,
  '2026-02-23T08:00:00+00:00', '2026-02-23T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300020001', '00000000-0000-0000-0000-bb0013000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300020002', '00000000-0000-0000-0000-bb0013000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300020003', '00000000-0000-0000-0000-bb0013000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300020004', '00000000-0000-0000-0000-bb0013000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300020005', '00000000-0000-0000-0000-bb0013000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Đoàn Thanh Quang cho câu 5"}',
  1.5, 0.75, 1.5,
  '{"comment": "AI chấm: 1.5/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300020006', '00000000-0000-0000-0000-bb0013000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Đoàn Thanh Quang. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  3.0, 0.75, 3.0,
  '{"comment": "AI chấm: 3.0/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00', '2026-02-23T10:31:00+00:00') ON CONFLICT DO NOTHING;

-- Đoàn Thanh Quang - A3 | score=13.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0013000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', '80cf60e4-7ba9-5658-9e3c-b232707d34b7',
  '2026-03-09T08:00:00+00:00', '2026-03-09T10:31:00+00:00', 1, 'submitted', 1980,
  '2026-03-09T08:00:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0013000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', '80cf60e4-7ba9-5658-9e3c-b232707d34b7', '00000000-0000-0000-0000-bb0013000003',
  '2026-03-09T08:00:00+00:00', '2026-03-09T10:31:00+00:00', false, 13.0, true, false,
  '2026-03-09T08:00:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030001', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030002', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030003', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030004', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030005', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030006', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030007', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030008', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [3]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030009', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030010', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030011', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030012', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030013', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030014', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030015', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  2.0, 0.67, 2.0,
  '{"comment": "AI chấm: 2.0/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300030016', '00000000-0000-0000-0000-bb0013000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Đoàn Thanh Quang. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  2.0, 0.67, 2.0,
  '{"comment": "AI chấm: 2.0/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00', '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;

-- Đoàn Thanh Quang - A4 | score=8.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0013000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', '80cf60e4-7ba9-5658-9e3c-b232707d34b7',
  '2026-03-25T08:00:00+00:00', '2026-03-25T10:31:00+00:00', 1, 'submitted', 2040,
  '2026-03-25T08:00:00+00:00', '2026-03-25T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0013000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', '80cf60e4-7ba9-5658-9e3c-b232707d34b7', '00000000-0000-0000-0000-bb0013000004',
  '2026-03-25T08:00:00+00:00', '2026-03-25T10:31:00+00:00', false, 8.5, false, false,
  '2026-03-25T08:00:00+00:00', '2026-03-25T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300040001', '00000000-0000-0000-0000-bb0013000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300040002', '00000000-0000-0000-0000-bb0013000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300040003', '00000000-0000-0000-0000-bb0013000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300040004', '00000000-0000-0000-0000-bb0013000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300040005', '00000000-0000-0000-0000-bb0013000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Đoàn Thanh Quang cho câu 5"}',
  1.5, 0.75, 1.5,
  '{"comment": "AI chấm: 1.5/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001300040006', '00000000-0000-0000-0000-bb0013000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Đoàn Thanh Quang. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  3.0, 0.75, 3.0,
  '{"comment": "AI chấm: 3.0/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00', '2026-03-25T10:31:00+00:00') ON CONFLICT DO NOTHING;

-- Đồng Nguyên Hiếu - A1 | score=9.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0014000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', 'f6d81836-a646-586d-84fa-57cdbe0a6b16',
  '2026-02-10T09:00:00+00:00', '2026-02-08T11:38:00+00:00', 1, 'submitted', 1980,
  '2026-02-10T09:00:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0014000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', 'f6d81836-a646-586d-84fa-57cdbe0a6b16', '00000000-0000-0000-0000-bb0014000001',
  '2026-02-10T09:00:00+00:00', '2026-02-08T11:38:00+00:00', false, 9.0, true, false,
  '2026-02-10T09:00:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400010001', '00000000-0000-0000-0000-bb0014000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400010002', '00000000-0000-0000-0000-bb0014000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400010003', '00000000-0000-0000-0000-bb0014000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400010004', '00000000-0000-0000-0000-bb0014000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400010005', '00000000-0000-0000-0000-bb0014000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400010006', '00000000-0000-0000-0000-bb0014000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400010007', '00000000-0000-0000-0000-bb0014000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400010008', '00000000-0000-0000-0000-bb0014000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400010009', '00000000-0000-0000-0000-bb0014000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400010010', '00000000-0000-0000-0000-bb0014000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00', '2026-02-08T11:38:00+00:00') ON CONFLICT DO NOTHING;

-- Đồng Nguyên Hiếu - A2 | score=9.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0014000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', 'f6d81836-a646-586d-84fa-57cdbe0a6b16',
  '2026-02-24T09:00:00+00:00', '2026-02-22T11:38:00+00:00', 1, 'submitted', 2040,
  '2026-02-24T09:00:00+00:00', '2026-02-22T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0014000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', 'f6d81836-a646-586d-84fa-57cdbe0a6b16', '00000000-0000-0000-0000-bb0014000002',
  '2026-02-24T09:00:00+00:00', '2026-02-22T11:38:00+00:00', false, 9.5, true, false,
  '2026-02-24T09:00:00+00:00', '2026-02-22T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400020001', '00000000-0000-0000-0000-bb0014000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400020002', '00000000-0000-0000-0000-bb0014000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400020003', '00000000-0000-0000-0000-bb0014000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400020004', '00000000-0000-0000-0000-bb0014000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400020005', '00000000-0000-0000-0000-bb0014000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Đồng Nguyên Hiếu cho câu 5"}',
  2.0, 1.0, 2.0,
  '{"comment": "AI chấm: 2.0/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400020006', '00000000-0000-0000-0000-bb0014000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Đồng Nguyên Hiếu. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  3.5, 0.88, 3.5,
  '{"comment": "AI chấm: 3.5/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00', '2026-02-22T11:38:00+00:00') ON CONFLICT DO NOTHING;

-- Đồng Nguyên Hiếu - A3 | score=18.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0014000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', 'f6d81836-a646-586d-84fa-57cdbe0a6b16',
  '2026-03-10T09:00:00+00:00', '2026-03-08T11:38:00+00:00', 1, 'submitted', 2100,
  '2026-03-10T09:00:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0014000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', 'f6d81836-a646-586d-84fa-57cdbe0a6b16', '00000000-0000-0000-0000-bb0014000003',
  '2026-03-10T09:00:00+00:00', '2026-03-08T11:38:00+00:00', false, 18.5, true, false,
  '2026-03-10T09:00:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030001', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030002', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030003', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030004', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030005', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030006', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030007', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030008', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [3]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030009', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030010', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030011', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030012', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030013', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030014', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030015', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  2.5, 0.83, 2.5,
  '{"comment": "AI chấm: 2.5/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400030016', '00000000-0000-0000-0000-bb0014000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Đồng Nguyên Hiếu. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  3.0, 1.0, 3.0,
  '{"comment": "AI chấm: 3.0/3.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00', '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;

-- Đồng Nguyên Hiếu - A4 | score=9.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0014000004', 'ac010004-0000-0000-0000-000000000004', 'ab010004-0000-0000-0000-000000000004', 'f6d81836-a646-586d-84fa-57cdbe0a6b16',
  '2026-03-26T09:00:00+00:00', '2026-03-24T11:38:00+00:00', 1, 'submitted', 2160,
  '2026-03-26T09:00:00+00:00', '2026-03-24T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0014000004', 'ab010004-0000-0000-0000-000000000004', 'ac010004-0000-0000-0000-000000000004', 'f6d81836-a646-586d-84fa-57cdbe0a6b16', '00000000-0000-0000-0000-bb0014000004',
  '2026-03-26T09:00:00+00:00', '2026-03-24T11:38:00+00:00', false, 9.5, false, false,
  '2026-03-26T09:00:00+00:00', '2026-03-24T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400040001', '00000000-0000-0000-0000-bb0014000004', '00000000-0000-0000-0000-aa0004000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400040002', '00000000-0000-0000-0000-bb0014000004', '00000000-0000-0000-0000-aa0004000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400040003', '00000000-0000-0000-0000-bb0014000004', '00000000-0000-0000-0000-aa0004000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400040004', '00000000-0000-0000-0000-bb0014000004', '00000000-0000-0000-0000-aa0004000004', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400040005', '00000000-0000-0000-0000-bb0014000004', '00000000-0000-0000-0000-aa0004000005', '{"text": "Câu trả lời của Đồng Nguyên Hiếu cho câu 5"}',
  2.0, 1.0, 2.0,
  '{"comment": "AI chấm: 2.0/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": [], "suggestions": []}',
  NULL, NULL,
  '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001400040006', '00000000-0000-0000-0000-bb0014000004', '00000000-0000-0000-0000-aa0004000006', '{"text": "Bài làm tự luận của Đồng Nguyên Hiếu. Đây là nội dung câu trả lời cho câu 6 của bài 4."}',
  3.5, 0.88, 3.5,
  '{"comment": "AI chấm: 3.5/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00', '2026-03-24T11:38:00+00:00') ON CONFLICT DO NOTHING;

-- Dương Công Quốc Anh - A1 | score=6.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0015000001', 'ac010001-0000-0000-0000-000000000001', 'ab010001-0000-0000-0000-000000000001', '192e7be4-9b8a-5a34-83a1-f04e6d292592',
  '2026-02-08T07:00:00+00:00', '2026-02-09T12:45:00+00:00', 1, 'submitted', 2100,
  '2026-02-08T07:00:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0015000001', 'ab010001-0000-0000-0000-000000000001', 'ac010001-0000-0000-0000-000000000001', '192e7be4-9b8a-5a34-83a1-f04e6d292592', '00000000-0000-0000-0000-bb0015000001',
  '2026-02-08T07:00:00+00:00', '2026-02-09T12:45:00+00:00', false, 6.0, true, false,
  '2026-02-08T07:00:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500010001', '00000000-0000-0000-0000-bb0015000001', '00000000-0000-0000-0000-aa0001000001', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500010002', '00000000-0000-0000-0000-bb0015000001', '00000000-0000-0000-0000-aa0001000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500010003', '00000000-0000-0000-0000-bb0015000001', '00000000-0000-0000-0000-aa0001000003', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500010004', '00000000-0000-0000-0000-bb0015000001', '00000000-0000-0000-0000-aa0001000004', '{"selected_choice_ids": [0]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500010005', '00000000-0000-0000-0000-bb0015000001', '00000000-0000-0000-0000-aa0001000005', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500010006', '00000000-0000-0000-0000-bb0015000001', '00000000-0000-0000-0000-aa0001000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500010007', '00000000-0000-0000-0000-bb0015000001', '00000000-0000-0000-0000-aa0001000007', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500010008', '00000000-0000-0000-0000-bb0015000001', '00000000-0000-0000-0000-aa0001000008', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500010009', '00000000-0000-0000-0000-bb0015000001', '00000000-0000-0000-0000-aa0001000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500010010', '00000000-0000-0000-0000-bb0015000001', '00000000-0000-0000-0000-aa0001000010', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00', '2026-02-09T12:45:00+00:00') ON CONFLICT DO NOTHING;

-- Dương Công Quốc Anh - A2 | score=6.0
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0015000002', 'ac010002-0000-0000-0000-000000000002', 'ab010002-0000-0000-0000-000000000002', '192e7be4-9b8a-5a34-83a1-f04e6d292592',
  '2026-02-22T07:00:00+00:00', '2026-02-23T12:45:00+00:00', 1, 'submitted', 2160,
  '2026-02-22T07:00:00+00:00', '2026-02-23T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0015000002', 'ab010002-0000-0000-0000-000000000002', 'ac010002-0000-0000-0000-000000000002', '192e7be4-9b8a-5a34-83a1-f04e6d292592', '00000000-0000-0000-0000-bb0015000002',
  '2026-02-22T07:00:00+00:00', '2026-02-23T12:45:00+00:00', false, 6.0, true, false,
  '2026-02-22T07:00:00+00:00', '2026-02-23T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500020001', '00000000-0000-0000-0000-bb0015000002', '00000000-0000-0000-0000-aa0002000001', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500020002', '00000000-0000-0000-0000-bb0015000002', '00000000-0000-0000-0000-aa0002000002', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500020003', '00000000-0000-0000-0000-bb0015000002', '00000000-0000-0000-0000-aa0002000003', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500020004', '00000000-0000-0000-0000-bb0015000002', '00000000-0000-0000-0000-aa0002000004', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500020005', '00000000-0000-0000-0000-bb0015000002', '00000000-0000-0000-0000-aa0002000005', '{"text": "Câu trả lời của Dương Công Quốc Anh cho câu 5"}',
  1.5, 0.75, 1.5,
  '{"comment": "AI chấm: 1.5/2.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": []}',
  NULL, NULL,
  '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500020006', '00000000-0000-0000-0000-bb0015000002', '00000000-0000-0000-0000-aa0002000006', '{"text": "Bài làm tự luận của Dương Công Quốc Anh. Đây là nội dung câu trả lời cho câu 6 của bài 2."}',
  2.5, 0.62, 2.5,
  '{"comment": "AI chấm: 2.5/4.0 điểm.", "strengths": ["Hiểu đúng yêu cầu bài"], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00', '2026-02-23T12:45:00+00:00') ON CONFLICT DO NOTHING;

-- Dương Công Quốc Anh - A3 | score=9.5
INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-bb0015000003', 'ac010003-0000-0000-0000-000000000003', 'ab010003-0000-0000-0000-000000000003', '192e7be4-9b8a-5a34-83a1-f04e6d292592',
  '2026-03-08T07:00:00+00:00', '2026-03-09T12:45:00+00:00', 1, 'submitted', 2220,
  '2026-03-08T07:00:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-cc0015000003', 'ab010003-0000-0000-0000-000000000003', 'ac010003-0000-0000-0000-000000000003', '192e7be4-9b8a-5a34-83a1-f04e6d292592', '00000000-0000-0000-0000-bb0015000003',
  '2026-03-08T07:00:00+00:00', '2026-03-09T12:45:00+00:00', false, 9.5, true, false,
  '2026-03-08T07:00:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030001', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000001', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030002', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000002', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030003', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000003', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030004', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000004', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030005', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000005', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030006', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000006', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030007', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000007', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030008', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000008', '{"selected_choice_ids": [3]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030009', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000009', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030010', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000010', '{"selected_choice_ids": [2]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030011', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000011', '{"selected_choice_ids": [1]}',
  1.0, 1.0, 1.0,
  '{"comment": "Câu trả lời trắc nghiệm đúng."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030012', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000012', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030013', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000013', '{"selected_choice_ids": [0]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030014', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000014', '{"selected_choice_ids": [1]}',
  0, 0.0, 0,
  '{"comment": "Câu trả lời trắc nghiệm sai."}',
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030015', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000015', '{"text": "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt."}',
  1.0, 0.33, 1.0,
  '{"comment": "AI chấm: 1.0/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-001500030016', '00000000-0000-0000-0000-bb0015000003', '00000000-0000-0000-0000-aa0003000016', '{"text": "Bài làm tự luận của Dương Công Quốc Anh. Đây là nội dung câu trả lời cho câu 16 của bài 3."}',
  1.5, 0.5, 1.5,
  '{"comment": "AI chấm: 1.5/3.0 điểm.", "strengths": [], "weaknesses": ["Cần bổ sung giải thích"], "suggestions": ["Xem lại lý thuyết"]}',
  NULL, NULL,
  '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00', '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;

-- Dương Công Quốc Anh chưa nộp A4 (còn hạn)
-- ═══ 8. GRADE_OVERRIDES ═══
INSERT INTO public.grade_overrides (id, submission_answer_id, overridden_by, old_score, new_score, reason, created_at)
VALUES ('00000000-0000-0000-0003-ee0000000001', '00000000-0000-0000-0000-000000020006', '51e467a2-9033-5e85-b666-164ea075f6c9', 2.5, 3.0,
  'Học sinh trình bày ý đúng nhưng code chưa hoàn chỉnh. Cộng 0.5 điểm khuyến khích.', '2026-02-22T09:00:00+00:00') ON CONFLICT DO NOTHING;

-- ═══ 9. AI_EVALUATIONS ═══
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000000020005', '00000000-0000-0000-0000-000000020005', 'gemini-pro', '1.5', 1.5, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/2.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-02-22T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000000020006', '00000000-0000-0000-0000-000000020006', 'gemini-pro', '1.5', 2.5, 0.62,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.5, "comment": "Điểm AI: 2.5/4.0"}], "overall_comment": "Bài làm đạt 62% yêu cầu."}',
  '2026-02-22T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000000030015', '00000000-0000-0000-0000-000000030015', 'gemini-pro', '1.5', 1.5, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/3.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000000030016', '00000000-0000-0000-0000-000000030016', 'gemini-pro', '1.5', 1.5, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/3.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-03-11T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000000040005', '00000000-0000-0000-0000-000000040005', 'gemini-pro', '1.5', 2.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/2.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-03-24T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000000040006', '00000000-0000-0000-0000-000000040006', 'gemini-pro', '1.5', 3.0, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.0, "comment": "Điểm AI: 3.0/4.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-03-24T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000100020005', '00000000-0000-0000-0000-000100020005', 'gemini-pro', '1.5', 2.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/2.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-02-23T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000100020006', '00000000-0000-0000-0000-000100020006', 'gemini-pro', '1.5', 3.5, 0.88,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.5, "comment": "Điểm AI: 3.5/4.0"}], "overall_comment": "Bài làm đạt 88% yêu cầu."}',
  '2026-02-23T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000100030015', '00000000-0000-0000-0000-000100030015', 'gemini-pro', '1.5', 2.5, 0.83,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.5, "comment": "Điểm AI: 2.5/3.0"}], "overall_comment": "Bài làm đạt 83% yêu cầu."}',
  '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000100030016', '00000000-0000-0000-0000-000100030016', 'gemini-pro', '1.5', 2.5, 0.83,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.5, "comment": "Điểm AI: 2.5/3.0"}], "overall_comment": "Bài làm đạt 83% yêu cầu."}',
  '2026-03-09T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000100040005', '00000000-0000-0000-0000-000100040005', 'gemini-pro', '1.5', 2.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/2.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-03-25T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000100040006', '00000000-0000-0000-0000-000100040006', 'gemini-pro', '1.5', 3.5, 0.88,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.5, "comment": "Điểm AI: 3.5/4.0"}], "overall_comment": "Bài làm đạt 88% yêu cầu."}',
  '2026-03-25T10:07:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000200020005', '00000000-0000-0000-0000-000200020005', 'gemini-pro', '1.5', 1.0, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/2.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-02-22T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000200020006', '00000000-0000-0000-0000-000200020006', 'gemini-pro', '1.5', 1.0, 0.25,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/4.0"}], "overall_comment": "Bài làm đạt 25% yêu cầu."}',
  '2026-02-22T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000200030015', '00000000-0000-0000-0000-000200030015', 'gemini-pro', '1.5', 1.0, 0.33,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/3.0"}], "overall_comment": "Bài làm đạt 33% yêu cầu."}',
  '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000200030016', '00000000-0000-0000-0000-000200030016', 'gemini-pro', '1.5', 0.5, 0.17,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 0.5, "comment": "Điểm AI: 0.5/3.0"}], "overall_comment": "Bài làm đạt 17% yêu cầu."}',
  '2026-03-08T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000200040005', '00000000-0000-0000-0000-000200040005', 'gemini-pro', '1.5', 0.5, 0.25,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 0.5, "comment": "Điểm AI: 0.5/2.0"}], "overall_comment": "Bài làm đạt 25% yêu cầu."}',
  '2026-03-24T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000200040006', '00000000-0000-0000-0000-000200040006', 'gemini-pro', '1.5', 1.5, 0.38,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/4.0"}], "overall_comment": "Bài làm đạt 38% yêu cầu."}',
  '2026-03-24T11:14:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000300020005', '00000000-0000-0000-0000-000300020005', 'gemini-pro', '1.5', 1.5, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/2.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-02-23T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000300020006', '00000000-0000-0000-0000-000300020006', 'gemini-pro', '1.5', 2.0, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/4.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-02-23T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000300030015', '00000000-0000-0000-0000-000300030015', 'gemini-pro', '1.5', 1.5, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/3.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000300030016', '00000000-0000-0000-0000-000300030016', 'gemini-pro', '1.5', 2.0, 0.67,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/3.0"}], "overall_comment": "Bài làm đạt 67% yêu cầu."}',
  '2026-03-09T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000300040005', '00000000-0000-0000-0000-000300040005', 'gemini-pro', '1.5', 2.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/2.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-03-25T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000300040006', '00000000-0000-0000-0000-000300040006', 'gemini-pro', '1.5', 3.0, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.0, "comment": "Điểm AI: 3.0/4.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-03-25T12:21:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000400020005', '00000000-0000-0000-0000-000400020005', 'gemini-pro', '1.5', 1.5, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/2.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-02-22T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000400020006', '00000000-0000-0000-0000-000400020006', 'gemini-pro', '1.5', 3.0, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.0, "comment": "Điểm AI: 3.0/4.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-02-22T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000400030015', '00000000-0000-0000-0000-000400030015', 'gemini-pro', '1.5', 2.0, 0.67,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/3.0"}], "overall_comment": "Bài làm đạt 67% yêu cầu."}',
  '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000400030016', '00000000-0000-0000-0000-000400030016', 'gemini-pro', '1.5', 2.0, 0.67,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/3.0"}], "overall_comment": "Bài làm đạt 67% yêu cầu."}',
  '2026-03-08T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000400040005', '00000000-0000-0000-0000-000400040005', 'gemini-pro', '1.5', 1.0, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/2.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-03-24T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000400040006', '00000000-0000-0000-0000-000400040006', 'gemini-pro', '1.5', 2.5, 0.62,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.5, "comment": "Điểm AI: 2.5/4.0"}], "overall_comment": "Bài làm đạt 62% yêu cầu."}',
  '2026-03-24T09:28:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000500020005', '00000000-0000-0000-0000-000500020005', 'gemini-pro', '1.5', 1.5, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/2.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-02-23T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000500020006', '00000000-0000-0000-0000-000500020006', 'gemini-pro', '1.5', 2.0, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/4.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-02-23T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000500030015', '00000000-0000-0000-0000-000500030015', 'gemini-pro', '1.5', 1.5, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/3.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000500030016', '00000000-0000-0000-0000-000500030016', 'gemini-pro', '1.5', 1.0, 0.33,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/3.0"}], "overall_comment": "Bài làm đạt 33% yêu cầu."}',
  '2026-03-09T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000500040005', '00000000-0000-0000-0000-000500040005', 'gemini-pro', '1.5', 0.5, 0.25,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 0.5, "comment": "Điểm AI: 0.5/2.0"}], "overall_comment": "Bài làm đạt 25% yêu cầu."}',
  '2026-03-25T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000500040006', '00000000-0000-0000-0000-000500040006', 'gemini-pro', '1.5', 1.5, 0.38,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/4.0"}], "overall_comment": "Bài làm đạt 38% yêu cầu."}',
  '2026-03-25T10:35:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000600020005', '00000000-0000-0000-0000-000600020005', 'gemini-pro', '1.5', 1.0, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/2.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-02-22T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000600020006', '00000000-0000-0000-0000-000600020006', 'gemini-pro', '1.5', 1.0, 0.25,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/4.0"}], "overall_comment": "Bài làm đạt 25% yêu cầu."}',
  '2026-02-22T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000600030015', '00000000-0000-0000-0000-000600030015', 'gemini-pro', '1.5', 0.5, 0.17,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 0.5, "comment": "Điểm AI: 0.5/3.0"}], "overall_comment": "Bài làm đạt 17% yêu cầu."}',
  '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000600030016', '00000000-0000-0000-0000-000600030016', 'gemini-pro', '1.5', 0.5, 0.17,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 0.5, "comment": "Điểm AI: 0.5/3.0"}], "overall_comment": "Bài làm đạt 17% yêu cầu."}',
  '2026-03-08T11:42:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000700020005', '00000000-0000-0000-0000-000700020005', 'gemini-pro', '1.5', 2.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/2.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-02-23T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000700020006', '00000000-0000-0000-0000-000700020006', 'gemini-pro', '1.5', 4.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 4.0, "comment": "Điểm AI: 4.0/4.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-02-23T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000700030015', '00000000-0000-0000-0000-000700030015', 'gemini-pro', '1.5', 3.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.0, "comment": "Điểm AI: 3.0/3.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000700030016', '00000000-0000-0000-0000-000700030016', 'gemini-pro', '1.5', 3.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.0, "comment": "Điểm AI: 3.0/3.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-03-09T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000700040005', '00000000-0000-0000-0000-000700040005', 'gemini-pro', '1.5', 2.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/2.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-03-25T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000700040006', '00000000-0000-0000-0000-000700040006', 'gemini-pro', '1.5', 4.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 4.0, "comment": "Điểm AI: 4.0/4.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-03-25T12:49:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000800020005', '00000000-0000-0000-0000-000800020005', 'gemini-pro', '1.5', 1.5, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/2.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-02-22T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000800020006', '00000000-0000-0000-0000-000800020006', 'gemini-pro', '1.5', 2.5, 0.62,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.5, "comment": "Điểm AI: 2.5/4.0"}], "overall_comment": "Bài làm đạt 62% yêu cầu."}',
  '2026-02-22T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000800030015', '00000000-0000-0000-0000-000800030015', 'gemini-pro', '1.5', 1.5, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/3.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000800030016', '00000000-0000-0000-0000-000800030016', 'gemini-pro', '1.5', 2.0, 0.67,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/3.0"}], "overall_comment": "Bài làm đạt 67% yêu cầu."}',
  '2026-03-08T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000800040005', '00000000-0000-0000-0000-000800040005', 'gemini-pro', '1.5', 1.5, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/2.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-03-24T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000800040006', '00000000-0000-0000-0000-000800040006', 'gemini-pro', '1.5', 2.5, 0.62,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.5, "comment": "Điểm AI: 2.5/4.0"}], "overall_comment": "Bài làm đạt 62% yêu cầu."}',
  '2026-03-24T09:56:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000900020005', '00000000-0000-0000-0000-000900020005', 'gemini-pro', '1.5', 1.0, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/2.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-02-23T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000900020006', '00000000-0000-0000-0000-000900020006', 'gemini-pro', '1.5', 2.0, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/4.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-02-23T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000900030015', '00000000-0000-0000-0000-000900030015', 'gemini-pro', '1.5', 1.0, 0.33,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/3.0"}], "overall_comment": "Bài làm đạt 33% yêu cầu."}',
  '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000900030016', '00000000-0000-0000-0000-000900030016', 'gemini-pro', '1.5', 1.5, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/3.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-03-09T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000900040005', '00000000-0000-0000-0000-000900040005', 'gemini-pro', '1.5', 1.0, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/2.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-03-25T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-000900040006', '00000000-0000-0000-0000-000900040006', 'gemini-pro', '1.5', 2.0, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/4.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-03-25T10:03:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001000020005', '00000000-0000-0000-0000-001000020005', 'gemini-pro', '1.5', 2.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/2.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-02-22T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001000020006', '00000000-0000-0000-0000-001000020006', 'gemini-pro', '1.5', 3.0, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.0, "comment": "Điểm AI: 3.0/4.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-02-22T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001000030015', '00000000-0000-0000-0000-001000030015', 'gemini-pro', '1.5', 2.0, 0.67,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/3.0"}], "overall_comment": "Bài làm đạt 67% yêu cầu."}',
  '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001000030016', '00000000-0000-0000-0000-001000030016', 'gemini-pro', '1.5', 2.5, 0.83,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.5, "comment": "Điểm AI: 2.5/3.0"}], "overall_comment": "Bài làm đạt 83% yêu cầu."}',
  '2026-03-08T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001000040005', '00000000-0000-0000-0000-001000040005', 'gemini-pro', '1.5', 2.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/2.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-03-24T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001000040006', '00000000-0000-0000-0000-001000040006', 'gemini-pro', '1.5', 3.0, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.0, "comment": "Điểm AI: 3.0/4.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-03-24T11:10:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001100020005', '00000000-0000-0000-0000-001100020005', 'gemini-pro', '1.5', 1.0, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/2.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-02-23T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001100020006', '00000000-0000-0000-0000-001100020006', 'gemini-pro', '1.5', 2.0, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/4.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-02-23T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001100030015', '00000000-0000-0000-0000-001100030015', 'gemini-pro', '1.5', 1.5, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/3.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001100030016', '00000000-0000-0000-0000-001100030016', 'gemini-pro', '1.5', 2.0, 0.67,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/3.0"}], "overall_comment": "Bài làm đạt 67% yêu cầu."}',
  '2026-03-09T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001100040005', '00000000-0000-0000-0000-001100040005', 'gemini-pro', '1.5', 2.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/2.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-03-25T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001100040006', '00000000-0000-0000-0000-001100040006', 'gemini-pro', '1.5', 3.5, 0.88,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.5, "comment": "Điểm AI: 3.5/4.0"}], "overall_comment": "Bài làm đạt 88% yêu cầu."}',
  '2026-03-25T12:17:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001200020005', '00000000-0000-0000-0000-001200020005', 'gemini-pro', '1.5', 0.5, 0.25,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 0.5, "comment": "Điểm AI: 0.5/2.0"}], "overall_comment": "Bài làm đạt 25% yêu cầu."}',
  '2026-02-22T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001200020006', '00000000-0000-0000-0000-001200020006', 'gemini-pro', '1.5', 0.5, 0.12,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 0.5, "comment": "Điểm AI: 0.5/4.0"}], "overall_comment": "Bài làm đạt 12% yêu cầu."}',
  '2026-02-22T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001200030015', '00000000-0000-0000-0000-001200030015', 'gemini-pro', '1.5', 0.5, 0.17,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 0.5, "comment": "Điểm AI: 0.5/3.0"}], "overall_comment": "Bài làm đạt 17% yêu cầu."}',
  '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001200030016', '00000000-0000-0000-0000-001200030016', 'gemini-pro', '1.5', 0.5, 0.17,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 0.5, "comment": "Điểm AI: 0.5/3.0"}], "overall_comment": "Bài làm đạt 17% yêu cầu."}',
  '2026-03-08T09:24:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001300020005', '00000000-0000-0000-0000-001300020005', 'gemini-pro', '1.5', 1.5, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/2.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-02-23T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001300020006', '00000000-0000-0000-0000-001300020006', 'gemini-pro', '1.5', 3.0, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.0, "comment": "Điểm AI: 3.0/4.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-02-23T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001300030015', '00000000-0000-0000-0000-001300030015', 'gemini-pro', '1.5', 2.0, 0.67,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/3.0"}], "overall_comment": "Bài làm đạt 67% yêu cầu."}',
  '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001300030016', '00000000-0000-0000-0000-001300030016', 'gemini-pro', '1.5', 2.0, 0.67,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/3.0"}], "overall_comment": "Bài làm đạt 67% yêu cầu."}',
  '2026-03-09T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001300040005', '00000000-0000-0000-0000-001300040005', 'gemini-pro', '1.5', 1.5, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/2.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-03-25T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001300040006', '00000000-0000-0000-0000-001300040006', 'gemini-pro', '1.5', 3.0, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.0, "comment": "Điểm AI: 3.0/4.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-03-25T10:31:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001400020005', '00000000-0000-0000-0000-001400020005', 'gemini-pro', '1.5', 2.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/2.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-02-22T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001400020006', '00000000-0000-0000-0000-001400020006', 'gemini-pro', '1.5', 3.5, 0.88,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.5, "comment": "Điểm AI: 3.5/4.0"}], "overall_comment": "Bài làm đạt 88% yêu cầu."}',
  '2026-02-22T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001400030015', '00000000-0000-0000-0000-001400030015', 'gemini-pro', '1.5', 2.5, 0.83,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.5, "comment": "Điểm AI: 2.5/3.0"}], "overall_comment": "Bài làm đạt 83% yêu cầu."}',
  '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001400030016', '00000000-0000-0000-0000-001400030016', 'gemini-pro', '1.5', 3.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.0, "comment": "Điểm AI: 3.0/3.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-03-08T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001400040005', '00000000-0000-0000-0000-001400040005', 'gemini-pro', '1.5', 2.0, 1.0,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.0, "comment": "Điểm AI: 2.0/2.0"}], "overall_comment": "Bài làm đạt 100% yêu cầu."}',
  '2026-03-24T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001400040006', '00000000-0000-0000-0000-001400040006', 'gemini-pro', '1.5', 3.5, 0.88,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 3.5, "comment": "Điểm AI: 3.5/4.0"}], "overall_comment": "Bài làm đạt 88% yêu cầu."}',
  '2026-03-24T11:38:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001500020005', '00000000-0000-0000-0000-001500020005', 'gemini-pro', '1.5', 1.5, 0.75,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/2.0"}], "overall_comment": "Bài làm đạt 75% yêu cầu."}',
  '2026-02-23T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001500020006', '00000000-0000-0000-0000-001500020006', 'gemini-pro', '1.5', 2.5, 0.62,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 2.5, "comment": "Điểm AI: 2.5/4.0"}], "overall_comment": "Bài làm đạt 62% yêu cầu."}',
  '2026-02-23T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001500030015', '00000000-0000-0000-0000-001500030015', 'gemini-pro', '1.5', 1.0, 0.33,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.0, "comment": "Điểm AI: 1.0/3.0"}], "overall_comment": "Bài làm đạt 33% yêu cầu."}',
  '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
VALUES ('00000000-0000-0000-0001-001500030016', '00000000-0000-0000-0000-001500030016', 'gemini-pro', '1.5', 1.5, 0.5,
  'AI đánh giá câu tự luận.', '{"criteria_scores": [{"criteria_id": "crit-1", "score": 1.5, "comment": "Điểm AI: 1.5/3.0"}], "overall_comment": "Bài làm đạt 50% yêu cầu."}',
  '2026-03-09T12:45:00+00:00') ON CONFLICT DO NOTHING;

-- ═══ 10. SUBMISSION_ANALYTICS (anhhuy) ═══
INSERT INTO public.submission_analytics (id, submission_id, metrics, created_at)
VALUES ('00000000-0000-0000-0002-ff0000000001', '00000000-0000-0000-0000-cc0000000001', '{"time_per_question": {"q1": 30, "q2": 45, "q3": 60, "q4": 75, "q5": 90, "q6": 105, "q7": 120, "q8": 135, "q9": 150, "q10": 165}, "accuracy_by_tag": {"python": 0.7, "oop": 0.6}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.9}, {"difficulty": 3, "score": 0.75}, {"difficulty": 4, "score": 0.6}]}', '2026-02-09T08:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_analytics (id, submission_id, metrics, created_at)
VALUES ('00000000-0000-0000-0002-ff0000000002', '00000000-0000-0000-0000-cc0000000002', '{"time_per_question": {"q1": 30, "q2": 45, "q3": 60, "q4": 75, "q5": 90, "q6": 105}, "accuracy_by_tag": {"python": 0.75, "oop": 0.6799999999999999}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.9}, {"difficulty": 3, "score": 0.75}, {"difficulty": 4, "score": 0.6}]}', '2026-02-24T08:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_analytics (id, submission_id, metrics, created_at)
VALUES ('00000000-0000-0000-0002-ff0000000003', '00000000-0000-0000-0000-cc0000000003', '{"time_per_question": {"q1": 30, "q2": 45, "q3": 60, "q4": 75, "q5": 90, "q6": 105, "q7": 120, "q8": 135, "q9": 150, "q10": 165, "q11": 180, "q12": 195, "q13": 210, "q14": 225, "q15": 240, "q16": 255}, "accuracy_by_tag": {"python": 0.7999999999999999, "oop": 0.76}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.9}, {"difficulty": 3, "score": 0.75}, {"difficulty": 4, "score": 0.6}]}', '2026-03-10T08:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.submission_analytics (id, submission_id, metrics, created_at)
VALUES ('00000000-0000-0000-0002-ff0000000004', '00000000-0000-0000-0000-cc0000000004', '{"time_per_question": {"q1": 30, "q2": 45, "q3": 60, "q4": 75, "q5": 90, "q6": 105}, "accuracy_by_tag": {"python": 0.85, "oop": 0.84}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.9}, {"difficulty": 3, "score": 0.75}, {"difficulty": 4, "score": 0.6}]}', '2026-03-28T08:00:00+00:00') ON CONFLICT DO NOTHING;

-- ═══ 11. AI_RECOMMENDATIONS (cho GV Phạm Thị Đào về lớp K17A1) ═══
INSERT INTO public.ai_recommendations (id, teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES ('a1000001-0000-0000-0000-000000000001', '51e467a2-9033-5e85-b666-164ea075f6c9', 'aa010001-0000-0000-0000-000000000001', 'b3e27ac4-a528-5174-92f8-99a8f273eb84', 'individual', 4,
  'Thái Anh Huy: Cần ôn lại Python list reference và mutation',
  'Học sinh liên tục sai câu về list mutation (y=x vs y=x.copy()). Khuyến nghị ôn lại bài "Biến và tham chiếu trong Python".',
  '{"exercises": ["ab010001-0000-0000-0000-000000000001"], "documents": ["https://docs.python.org/3/library/copy.html"]}', false, '2026-03-12T08:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_recommendations (id, teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES ('a1000002-0000-0000-0000-000000000002', '51e467a2-9033-5e85-b666-164ea075f6c9', 'aa010001-0000-0000-0000-000000000001', 'c8778c6b-7099-5c09-916c-6b0dabafde41', 'individual', 2,
  'Đặng Bảo Anh: Học sinh xuất sắc - nên giao bài nâng cao',
  'Học sinh đạt điểm tuyệt đối các bài kiểm tra. Đề xuất giao thêm bài tập nâng cao về Design Patterns và Web API.',
  '{"exercises": [], "documents": []}', false, '2026-03-12T08:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_recommendations (id, teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES ('a1000003-0000-0000-0000-000000000003', '51e467a2-9033-5e85-b666-164ea075f6c9', 'aa010001-0000-0000-0000-000000000001', NULL, 'class', 3,
  'Lớp K17A1: Kiến thức OOP còn yếu - cần ôn tập trước khi cuối kỳ',
  'Điểm trung bình giữa kỳ OOP là 11.5/20. Khuyến nghị tổ chức 1 buổi ôn tập về class, inheritance trước kỳ thi.',
  '{"exercises": ["ab010003-0000-0000-0000-000000000003"], "documents": []}', false, '2026-03-12T08:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.ai_recommendations (id, teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)
VALUES ('a1000004-0000-0000-0000-000000000004', '51e467a2-9033-5e85-b666-164ea075f6c9', 'aa010001-0000-0000-0000-000000000001', '1b091e49-228a-5e43-99ed-47ce336fbdb8', 'individual', 5,
  'Đinh Lê Hoàng: Nguy cơ không qua môn - cần can thiệp ngay',
  'Điểm các bài kiểm tra đều dưới 5/10. Khuyến nghị gặp gỡ học sinh để tìm hiểu nguyên nhân và có kế hoạch hỗ trợ.',
  '{"exercises": [], "documents": []}', false, '2026-03-12T08:00:00+00:00') ON CONFLICT DO NOTHING;

-- ═══ 12. TEACHER_NOTES ═══
INSERT INTO public.teacher_notes (id, teacher_id, student_id, content, is_private, created_at)
VALUES ('b1000001-0000-0000-0000-000000000001', '51e467a2-9033-5e85-b666-164ea075f6c9', 'b3e27ac4-a528-5174-92f8-99a8f273eb84',
  'Em Huy nắm vững cú pháp Python nhưng còn lúng túng với khái niệm tham chiếu biến. Cần chú ý câu hỏi liên quan đến mutable objects. Có tiến bộ rõ ở bài Flask.', true, '2026-03-14T08:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.teacher_notes (id, teacher_id, student_id, content, is_private, created_at)
VALUES ('b1000002-0000-0000-0000-000000000002', '51e467a2-9033-5e85-b666-164ea075f6c9', 'c8778c6b-7099-5c09-916c-6b0dabafde41',
  'Đặng Bảo Anh - học sinh tiêu biểu. Làm bài rất chắc chắn, code sạch sẽ, giải thích rõ ràng. Nên đề xuất tham gia cuộc thi lập trình.', true, '2026-03-14T08:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO public.teacher_notes (id, teacher_id, student_id, content, is_private, created_at)
VALUES ('b1000003-0000-0000-0000-000000000003', '51e467a2-9033-5e85-b666-164ea075f6c9', '1b091e49-228a-5e43-99ed-47ce336fbdb8',
  'Đinh Lê Hoàng - đã gặp riêng. Nói rằng đang gặp khó khăn gia đình. Cần quan tâm hỗ trợ thêm.', true, '2026-03-14T08:00:00+00:00') ON CONFLICT DO NOTHING;

SET session_replication_role = DEFAULT;
COMMIT;