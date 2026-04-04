-- AUTO-GENERATED IMPORT SCRIPT
BEGIN;
INSERT INTO public.schools (id, name) VALUES ('38363e05-bdb0-c839-7dd2-b654a0c47c13', '14/04/1977') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('de985745-49d9-907f-df11-77b7da64aee3', '10/10/1981') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('8310ec0f-ccf0-f16d-3170-b6bc7488da87', '20/01/1982') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('980dbadd-ad01-f12f-a3e9-c6aa0d91b96f', '11/11/1982') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('ab1eedf8-40e6-f1fb-f541-768cea264e31', '31/05/1985') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('12f29b95-e5c9-82bf-6817-a7f4ea4ac769', '11/05/1978') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('01186974-0ab8-197a-d9d8-affcf9238bdf', '03/07/1979') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('85caadd6-1e8d-077e-e5b0-b3cff48683e4', '11/11/1977') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('29160ba4-0a3d-341b-ba34-279d4d7f4b5f', '31/03/1983') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('ee6df152-75b6-6c40-efab-e406328a8376', '12/09/1983') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('095a3fe2-a703-7b96-1f4c-ac09b2982494', '16/12/1980') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('4e3dc713-4728-3ea2-e01e-24db604d30eb', '01/01/1979') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('2b18fe76-f3f0-e667-3ff8-ff28376b0fb5', '09/04/1981') ON CONFLICT DO NOTHING;
INSERT INTO public.schools (id, name) VALUES ('cc860b3e-7740-eba4-fe9f-ac58af91fdf4', '26/07/1982') ON CONFLICT DO NOTHING;

INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '874e42a9-6ca4-d84a-524a-989a8fd8e5b7', 'authenticated', 'authenticated', 'gv_4638e7@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Th\u1ecb Lan Anh", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "Qu\u1ef3nh L\u01b0u, Ngh\u1ec7 An"}'::jsonb, role = 'teacher'
WHERE id = '874e42a9-6ca4-d84a-524a-989a8fd8e5b7';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '1576e82e-2dbf-efbb-3c51-cc9e24963c81', 'authenticated', 'authenticated', 'gv_f04d5f@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ph\u1ea1m Th\u1ecb Thanh B\u00ecnh", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "H\u01b0ng Nguy\u00ean, Ngh\u1ec7 An"}'::jsonb, role = 'teacher'
WHERE id = '1576e82e-2dbf-efbb-3c51-cc9e24963c81';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'a4d25ceb-0182-3a61-59ad-571884b706ec', 'authenticated', 'authenticated', 'gv_71942a@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ph\u1ea1m Th\u1ecb \u0110\u00e0o", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "Nghi L\u1ed9c, Ngh\u1ec7 An"}'::jsonb, role = 'teacher'
WHERE id = 'a4d25ceb-0182-3a61-59ad-571884b706ec';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'ef43cad4-935f-e6d2-6050-461fd675a617', 'authenticated', 'authenticated', 'gv_09ee39@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n Th\u1ecb Gia", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "Y\u00ean \u0110\u1ecbnh, Thanh H\u00f3a"}'::jsonb, role = 'teacher'
WHERE id = 'ef43cad4-935f-e6d2-6050-461fd675a617';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'e4e05fab-9c61-1884-62b3-06cd51cb01fe', 'authenticated', 'authenticated', 'gv_3f4792@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Phan Vi\u1ec7t \u0110\u1ee9c", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "\u0110\u1ee9c Th\u1ecd, H\u00e0 T\u0129nh"}'::jsonb, role = 'teacher'
WHERE id = 'e4e05fab-9c61-1884-62b3-06cd51cb01fe';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '5896901e-d9bf-713f-b2af-bbaa43549c49', 'authenticated', 'authenticated', 'gv_d27912@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n B\u00ecnh Giang", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "Qu\u1ef3nh L\u01b0u, Ngh\u1ec7 An"}'::jsonb, role = 'teacher'
WHERE id = '5896901e-d9bf-713f-b2af-bbaa43549c49';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '4d21e45a-9280-ee44-862a-94c5d3e4681a', 'authenticated', 'authenticated', 'gv_ae2fa8@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Qu\u1ed1c Kh\u00e1nh", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "Thanh Ch\u01b0\u01a1ng, Ngh\u1ec7 An"}'::jsonb, role = 'teacher'
WHERE id = '4d21e45a-9280-ee44-862a-94c5d3e4681a';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '5a2d8a1f-c889-d564-e014-a63fc8ae1dea', 'authenticated', 'authenticated', 'gv_31b9d9@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "V\u0169 Th\u1ecb Thu Hi\u1ec1n", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "Vinh, Ngh\u1ec7 An"}'::jsonb, role = 'teacher'
WHERE id = '5a2d8a1f-c889-d564-e014-a63fc8ae1dea';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9eaccce9-09b6-df7d-2301-cefef1a24b4f', 'authenticated', 'authenticated', 'gv_c1d516@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "V\u00f5 Th\u1ecb Kim Hoa", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "Nghi L\u1ed9c, Ngh\u1ec7 An"}'::jsonb, role = 'teacher'
WHERE id = '9eaccce9-09b6-df7d-2301-cefef1a24b4f';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'ecc9ad85-4f5c-fc3d-ede4-8c8d6f161c7a', 'authenticated', 'authenticated', 'gv_c402ec@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea Th\u1ecb \u00c1nh H\u1ed3ng", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "H\u01b0\u01a1ng Kh\u00ea, H\u00e0 T\u0129nh"}'::jsonb, role = 'teacher'
WHERE id = 'ecc9ad85-4f5c-fc3d-ede4-8c8d6f161c7a';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'bfa4322d-d6bb-7068-ab16-30fc7bf9d6ea', 'authenticated', 'authenticated', 'gv_553742@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Th\u1ecb Ph\u01b0\u01a1ng Th\u1ee7y", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "Anh S\u01a1n, Ngh\u1ec7 An"}'::jsonb, role = 'teacher'
WHERE id = 'bfa4322d-d6bb-7068-ab16-30fc7bf9d6ea';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'fcecf7b2-2d11-4bc8-89f6-21bdfd0b3834', 'authenticated', 'authenticated', 'gv_7da979@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 Ng\u1ecdc Vinh", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "Qu\u1ef3nh L\u01b0u, Ngh\u1ec7 An"}'::jsonb, role = 'teacher'
WHERE id = 'fcecf7b2-2d11-4bc8-89f6-21bdfd0b3834';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'e0fadd0d-a349-b1bc-6d3a-249ade2870ff', 'authenticated', 'authenticated', 'gv_07f8f7@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea Th\u1ecb Linh", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "Qu\u1ea3ng Ninh, Qu\u1ea3ng B\u00ecnh"}'::jsonb, role = 'teacher'
WHERE id = 'e0fadd0d-a349-b1bc-6d3a-249ade2870ff';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '238cbdda-57b0-5ed8-720e-8a6d9f93fc4e', 'authenticated', 'authenticated', 'gv_909123@school.edu.vn', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Th\u1ecb Qu\u1ef3nh Vinh", "role": "teacher"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"address": "Vinh, Ngh\u1ec7 An"}'::jsonb, role = 'teacher'
WHERE id = '238cbdda-57b0-5ed8-720e-8a6d9f93fc4e';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '5df61444-0c37-c729-e7cb-46b6a67b8aa3', 'authenticated', 'authenticated', 'anhhuy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Th\u00e1i Anh Huy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220057", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '5df61444-0c37-c729-e7cb-46b6a67b8aa3';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'a4eb94d0-4855-788f-82e3-85a5fbaf4c22', 'authenticated', 'authenticated', 'quangthai@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u1eef Quang Th\u00e1i", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220035", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'a4eb94d0-4855-788f-82e3-85a5fbaf4c22';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '95b3b872-0d12-347a-b8c0-161db7716ec6', 'authenticated', 'authenticated', 'huyde@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Phan Huy \u0110\u1ec7", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220544", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '95b3b872-0d12-347a-b8c0-161db7716ec6';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'c4fb5b18-2286-49a0-5c18-a01260a4991c', 'authenticated', 'authenticated', 'khanhtoan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Kh\u00e1nh To\u00e0n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220157", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'c4fb5b18-2286-49a0-5c18-a01260a4991c';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'baea83b6-816d-63f4-30c8-f73c88b72acb', 'authenticated', 'authenticated', 'xuantrung@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea Xu\u00e2n Trung", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220843", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'baea83b6-816d-63f4-30c8-f73c88b72acb';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '6103ca01-e1d1-ed60-6d3e-1540742979b4', 'authenticated', 'authenticated', 'anhquan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Cao \u0110\u1ee9c Anh Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1305180594", "enrollment_class": "DHCTTCK15A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '6103ca01-e1d1-ed60-6d3e-1540742979b4';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '7de01be3-beaa-4f97-9034-19d0b3dd1666', 'authenticated', 'authenticated', 'trungthanh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 Trung Th\u00e0nh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220749", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '7de01be3-beaa-4f97-9034-19d0b3dd1666';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9ddec3b0-adc4-85e4-384f-02d2c5969ede', 'authenticated', 'authenticated', 'tienhung@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "V\u00f5 Ti\u1ebfn H\u01b0ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220246", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '9ddec3b0-adc4-85e4-384f-02d2c5969ede';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '2655b566-85d7-3f1c-e85e-7e62e62c3ebf', 'authenticated', 'authenticated', 'dinhnam@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n \u0110\u00ecnh Nam", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220484", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '2655b566-85d7-3f1c-e85e-7e62e62c3ebf';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9334959f-7691-da0f-1c9c-7b7365148312', 'authenticated', 'authenticated', 'anhquyen@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u00e0 \u0110\u1eb7ng Anh Quy\u1ebfn", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220245", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '9334959f-7691-da0f-1c9c-7b7365148312';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '2ed1a643-6024-8e80-fdf0-53cce7bfba13', 'authenticated', 'authenticated', 'quoctrung@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n Qu\u1ed1c Trung", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220221", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '2ed1a643-6024-8e80-fdf0-53cce7bfba13';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'ae5d3f9f-2dd8-570a-6794-75827959d98f', 'authenticated', 'authenticated', 'vanhoan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea V\u0103n Ho\u00e0n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220994", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'ae5d3f9f-2dd8-570a-6794-75827959d98f';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'e9815471-73b8-458b-fd55-c04ecd68a172', 'authenticated', 'authenticated', 'manhtrinh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ki\u1ec1u M\u1ea1nh Trinh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220467", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'e9815471-73b8-458b-fd55-c04ecd68a172';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '701fecfe-d6dc-8ba7-f523-4b844e11e8f3', 'authenticated', 'authenticated', 'kimuc@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "D\u01b0\u01a1ng Kim \u00dac", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220247", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '701fecfe-d6dc-8ba7-f523-4b844e11e8f3';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'acad0f59-be70-e83b-073c-0ffd8b11377d', 'authenticated', 'authenticated', 'khotphouthonesoulima@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "KHOTPHOUTHONE Soulima", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221188", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'acad0f59-be70-e83b-073c-0ffd8b11377d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '02f91d7a-33d3-a167-412e-9773aa9a264d', 'authenticated', 'authenticated', 'vietmuoi@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Vi\u1ebft M\u01b0\u1eddi", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220451", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '02f91d7a-33d3-a167-412e-9773aa9a264d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '66702db1-1763-74df-1210-bfd30096a0a1', 'authenticated', 'authenticated', 'xamontyangoun@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "XAMONTY Angoun", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221201", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '66702db1-1763-74df-1210-bfd30096a0a1';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '1a5b8965-4714-d218-297c-7f7aae82592f', 'authenticated', 'authenticated', 'vantai@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Bi\u1ec7n V\u0103n T\u00e0i", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220002", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '1a5b8965-4714-d218-297c-7f7aae82592f';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '1bdb7562-2dbe-c86e-7f7a-b3555c4f2cd3', 'authenticated', 'authenticated', 'vanquang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u01b0\u01a1ng V\u0103n Quang", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220533", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '1bdb7562-2dbe-c86e-7f7a-b3555c4f2cd3';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '3db83fe6-5c38-bebf-bbc0-7359929770b3', 'authenticated', 'authenticated', 'dinhdat@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u00e0 \u0110\u00ecnh \u0110\u1ea1t", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220535", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '3db83fe6-5c38-bebf-bbc0-7359929770b3';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '44175a2f-1ba6-7890-514e-bbaa292641f6', 'authenticated', 'authenticated', 'vanthang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea V\u0103n Th\u1eafng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220454", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '44175a2f-1ba6-7890-514e-bbaa292641f6';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'f6dfb8e1-42d2-69a3-0de3-9735ea185de3', 'authenticated', 'authenticated', 'vannhat@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n V\u0103n Nh\u1eadt", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220441", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'f6dfb8e1-42d2-69a3-0de3-9735ea185de3';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '78a43dbb-d757-8fa7-f72a-898ffc737329', 'authenticated', 'authenticated', 'phetsalatemmy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "PHETSALAT Emmy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221190", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '78a43dbb-d757-8fa7-f72a-898ffc737329';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '7a13610a-22f7-c807-2c27-1032397405fa', 'authenticated', 'authenticated', 'trungkien@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ph\u1ea1m Trung Ki\u00ean", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221079", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '7a13610a-22f7-c807-2c27-1032397405fa';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '7ea8b8ea-abf6-cd1f-a18a-78ca1b491f67', 'authenticated', 'authenticated', 'truongphi@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u01b0\u01a1ng Tr\u01b0\u1eddng Phi", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221087", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '7ea8b8ea-abf6-cd1f-a18a-78ca1b491f67';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'd39fbaad-ef6c-fcb7-dda6-cce7be67122d', 'authenticated', 'authenticated', 'thehy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u01b0\u01a1ng Th\u00ea Hy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220081", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'd39fbaad-ef6c-fcb7-dda6-cce7be67122d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'a011be12-7ab2-dffe-ab2d-fbe020b0beee', 'authenticated', 'authenticated', 'khantivongbounthavy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "KHANTIVONG Bounthavy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221191", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'a011be12-7ab2-dffe-ab2d-fbe020b0beee';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '4cdc0f84-bef3-2a78-8594-3efedad2ae67', 'authenticated', 'authenticated', 'nhatlinh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00f4 Nh\u1ea5t Linh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221085", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '4cdc0f84-bef3-2a78-8594-3efedad2ae67';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '1032c381-db43-c5bd-2345-317e4b126f1c', 'authenticated', 'authenticated', 'vietgiap@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 Vi\u1ebft Gi\u00e1p", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220531", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '1032c381-db43-c5bd-2345-317e4b126f1c';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'fdfb7757-87d1-8320-feb4-e7d38e97734d', 'authenticated', 'authenticated', 'ngocthien@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Ng\u1ecdc Thi\u1ec7n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220220", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'fdfb7757-87d1-8320-feb4-e7d38e97734d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'af58a9d3-acb0-9412-13d0-bd235f76f712', 'authenticated', 'authenticated', 'huyquy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Mai Huy Qu\u00fd", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220785", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'af58a9d3-acb0-9412-13d0-bd235f76f712';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9272be2a-93cd-9199-d91d-7cbf6f4dbaaa', 'authenticated', 'authenticated', 'tanminh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Ph\u00fac T\u1ea5n Minh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220240", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '9272be2a-93cd-9199-d91d-7cbf6f4dbaaa';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'bbd3ec0d-e74c-51b3-381c-6c6e30021569', 'authenticated', 'authenticated', 'minhhuy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Minh Huy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220961", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'bbd3ec0d-e74c-51b3-381c-6c6e30021569';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '72ae1601-6302-044e-36ca-19e884119201', 'authenticated', 'authenticated', 'congsach@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 V\u0103n C\u00f4ng S\u00e1ch", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220446", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '72ae1601-6302-044e-36ca-19e884119201';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9b526cfb-4e8a-2d09-c1a2-393d6e159a35', 'authenticated', 'authenticated', 'congdoan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n C\u00f4ng \u0110o\u00e0n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220034", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '9b526cfb-4e8a-2d09-c1a2-393d6e159a35';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'ce0a885e-832b-cf45-2dfa-11bd6c99b33d', 'authenticated', 'authenticated', 'khounnolathanouphap@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "KHOUNNOLATH Anouphap", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221187", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'ce0a885e-832b-cf45-2dfa-11bd6c99b33d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '2168fb47-d853-85a7-395b-c20abeb66c53', 'authenticated', 'authenticated', 'huuhoat@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 H\u1eefu Ho\u1ea1t", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220112", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '2168fb47-d853-85a7-395b-c20abeb66c53';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'c7e7bbd9-3a00-6497-d212-1846af6c5669', 'authenticated', 'authenticated', 'vansang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u01b0\u01a1ng V\u0103n Sang", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220042", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'c7e7bbd9-3a00-6497-d212-1846af6c5669';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'c8c3e37f-6216-36b8-de38-6c8f69ca43cd', 'authenticated', 'authenticated', 'vanhoang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n V\u0103n Ho\u00e0ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220236", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'c8c3e37f-6216-36b8-de38-6c8f69ca43cd';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '682cd2d4-40f7-6b35-1c88-e186b989acb6', 'authenticated', 'authenticated', 'viettrung@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Vi\u1ebft Trung", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221109", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '682cd2d4-40f7-6b35-1c88-e186b989acb6';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '7c7c5976-0753-6cab-5996-8ddfc9ddf05b', 'authenticated', 'authenticated', 'dinhloc@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "B\u00f9i \u0110\u00ecnh L\u1ed9c", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220529", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '7c7c5976-0753-6cab-5996-8ddfc9ddf05b';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '2a8fded4-5f05-d0e0-b55a-ec38d354aee0', 'authenticated', 'authenticated', 'binhphuoc@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "\u0110\u00e0o B\u00ecnh Ph\u01b0\u1edbc", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220449", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '2a8fded4-5f05-d0e0-b55a-ec38d354aee0';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '98a7542d-bd96-a973-76ee-b2a157eee927', 'authenticated', 'authenticated', 'chanthathebpoumsavanh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "CHANTHATHEB Poumsavanh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221189", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '98a7542d-bd96-a973-76ee-b2a157eee927';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'f71adc29-2e8e-6462-9434-ff8794ccb713', 'authenticated', 'authenticated', 'phiquan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 Phi Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220789", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'f71adc29-2e8e-6462-9434-ff8794ccb713';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'b3545ea3-094d-97ce-d78c-dea3814efba0', 'authenticated', 'authenticated', 'vinhkien@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea Vinh Ki\u00ean", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220174", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'b3545ea3-094d-97ce-d78c-dea3814efba0';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '96e73d2a-6c41-18fa-6642-ef1518b6287c', 'authenticated', 'authenticated', 'tuankiet@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ecbnh Tu\u1ea5n Ki\u1ec7t", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220453", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '96e73d2a-6c41-18fa-6642-ef1518b6287c';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '406b48a3-92c9-43e5-adbe-08f4cf138b4e', 'authenticated', 'authenticated', 'quanghuy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n S\u1ef9 Quang Huy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220223", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '406b48a3-92c9-43e5-adbe-08f4cf138b4e';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '8614d864-ecca-978f-4957-b5fbd2db85d2', 'authenticated', 'authenticated', 'trungkien1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Trung Ki\u00ean", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220099", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '8614d864-ecca-978f-4957-b5fbd2db85d2';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'ff5670a9-9794-51ec-d00c-dd7e605b5e0d', 'authenticated', 'authenticated', 'thammavongsathotsaphone@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "THAMMAVONGSA Thotsaphone", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221192", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'ff5670a9-9794-51ec-d00c-dd7e605b5e0d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '09aaa7da-875e-18ee-7461-46c47116b8eb', 'authenticated', 'authenticated', 'trongquan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Tr\u1ecdng Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220455", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '09aaa7da-875e-18ee-7461-46c47116b8eb';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '4ad661f7-60da-b5d6-d2e0-03c5fcf40c2d', 'authenticated', 'authenticated', 'thanhdat@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "V\u00f5 Th\u00e0nh \u0110\u1ea1t", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220182", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '4ad661f7-60da-b5d6-d2e0-03c5fcf40c2d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '358d94bc-ff25-7559-c353-e92556384c36', 'authenticated', 'authenticated', 'vanan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n V\u0103n An", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220001", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '358d94bc-ff25-7559-c353-e92556384c36';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'a7cd71d2-7a33-72dc-639c-9177bc570144', 'authenticated', 'authenticated', 'duyquan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "V\u0169 Duy Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220466", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'a7cd71d2-7a33-72dc-639c-9177bc570144';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '0da442f6-76e8-6754-ecdd-34ee139ace02', 'authenticated', 'authenticated', 'huyhoang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ph\u1ea1m Huy Ho\u00e0ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220123", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '0da442f6-76e8-6754-ecdd-34ee139ace02';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '056a3f2f-ca2a-d7ce-87ea-bb7bd59b40d7', 'authenticated', 'authenticated', 'anhthe@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea V\u0103n Anh Th\u1ebf", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220243", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '056a3f2f-ca2a-d7ce-87ea-bb7bd59b40d7';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '66702db1-1763-74df-1210-bfd30096a0a1', 'authenticated', 'authenticated', 'xamontyangoun1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "XAMONTY Angoun", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221201", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '66702db1-1763-74df-1210-bfd30096a0a1';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9ad27030-a9b7-3569-8632-9bd1a5d685ec', 'authenticated', 'authenticated', 'tuananh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Tu\u1ea5n Anh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220492", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '9ad27030-a9b7-3569-8632-9bd1a5d685ec';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'ce0a885e-832b-cf45-2dfa-11bd6c99b33d', 'authenticated', 'authenticated', 'khounnolathanouphap1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "KHOUNNOLATH Anouphap", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221187", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'ce0a885e-832b-cf45-2dfa-11bd6c99b33d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'aa1114f5-ed09-9c42-0043-8bedf2bc81ea', 'authenticated', 'authenticated', 'thaibao@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Cao V\u00f5 Th\u00e1i B\u1ea3o", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220928", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'aa1114f5-ed09-9c42-0043-8bedf2bc81ea';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'fe92d7ce-9efb-5054-6718-b0a12bd734e1', 'authenticated', 'authenticated', 'thaibao1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n C\u00f4ng Th\u00e1i B\u1ea3o", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220543", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'fe92d7ce-9efb-5054-6718-b0a12bd734e1';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'a011be12-7ab2-dffe-ab2d-fbe020b0beee', 'authenticated', 'authenticated', 'khantivongbounthavy1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "KHANTIVONG Bounthavy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221191", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'a011be12-7ab2-dffe-ab2d-fbe020b0beee';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '2ee5cc7e-c67c-e8c8-4a57-844bcf2ece07', 'authenticated', 'authenticated', 'louangsitthidethchemin@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "LOUANGSITTHIDETH Chemin", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221180", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '2ee5cc7e-c67c-e8c8-4a57-844bcf2ece07';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '350bc9c2-757b-bab8-599b-44a6aeaf7613', 'authenticated', 'authenticated', 'huychien@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n Huy Chi\u1ebfn", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220957", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '350bc9c2-757b-bab8-599b-44a6aeaf7613';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'eace835b-d9e6-e996-c5d4-c61a9b3d2eda', 'authenticated', 'authenticated', 'vanchinh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "V\u00f5 V\u0103n Ch\u00ednh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221168", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'eace835b-d9e6-e996-c5d4-c61a9b3d2eda';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '22947550-a21a-1d31-3f8b-7e9ae953fbfe', 'authenticated', 'authenticated', 'dinhcong@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n \u0110\u00ecnh C\u00f4ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220487", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '22947550-a21a-1d31-3f8b-7e9ae953fbfe';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '84beea7a-cafe-538a-55e2-3a570f09fb8f', 'authenticated', 'authenticated', 'thedieu@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Th\u1ebf Di\u1ec7u", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220991", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '84beea7a-cafe-538a-55e2-3a570f09fb8f';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'eba9389c-69a4-4347-80f9-d794644b68c0', 'authenticated', 'authenticated', 'tiendung@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Ti\u1ebfn D\u0169ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220925", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'eba9389c-69a4-4347-80f9-d794644b68c0';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'aedd3650-5a04-5528-8c7d-e782f8a88b72', 'authenticated', 'authenticated', 'ducdung@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Phan \u0110\u1ee9c D\u0169ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220981", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'aedd3650-5a04-5528-8c7d-e782f8a88b72';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '43e130e4-d2d4-efbe-c5fc-6a95d6bf2861', 'authenticated', 'authenticated', 'lamdung@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "V\u00f5 L\u00e2m D\u0169ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220778", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '43e130e4-d2d4-efbe-c5fc-6a95d6bf2861';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'f26be4cd-28b7-dcaa-be85-f3c701e993c3', 'authenticated', 'authenticated', 'vuduy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea V\u0169 Duy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220550", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'f26be4cd-28b7-dcaa-be85-f3c701e993c3';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '435d9fad-e1b9-8e52-7f8e-274f25351ddc', 'authenticated', 'authenticated', 'dinhdat1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n \u0110\u00ecnh \u0110\u1ea1t", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220999", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '435d9fad-e1b9-8e52-7f8e-274f25351ddc';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '5032743c-c8e5-6869-7bb5-d635603aa014', 'authenticated', 'authenticated', 'quocdat@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ph\u1ea1m Qu\u1ed1c \u0110\u1ea1t", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220940", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '5032743c-c8e5-6869-7bb5-d635603aa014';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'eb48ff52-67c6-2de7-e08e-d5681d8412a8', 'authenticated', 'authenticated', 'quangdat@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u01b0\u01a1ng Quang \u0110\u1ea1t", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221042", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'eb48ff52-67c6-2de7-e08e-d5681d8412a8';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'e0638969-0bc9-46db-2da4-9e4861781acc', 'authenticated', 'authenticated', 'haidang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n H\u1ea3i \u0110\u0103ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221148", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'e0638969-0bc9-46db-2da4-9e4861781acc';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'b59fe534-ca45-1b6c-f6c7-9a6d9286bccc', 'authenticated', 'authenticated', 'vando@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n V\u0103n \u0110\u00f4", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221068", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'b59fe534-ca45-1b6c-f6c7-9a6d9286bccc';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '52a7d2c4-2c61-bd39-c0c8-0f474a64a05c', 'authenticated', 'authenticated', 'huuduc@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea H\u1eefu \u0110\u1ee9c", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220712", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '52a7d2c4-2c61-bd39-c0c8-0f474a64a05c';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'de73db09-6f51-b212-b8f1-0010016d121a', 'authenticated', 'authenticated', 'vanduc@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea V\u0103n \u0110\u1ee9c", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220975", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'de73db09-6f51-b212-b8f1-0010016d121a';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'f8502569-994b-5dd9-1aad-5bd39946e0e4', 'authenticated', 'authenticated', 'huuduc1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n H\u1eefu \u0110\u1ee9c", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220534", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'f8502569-994b-5dd9-1aad-5bd39946e0e4';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'b085baed-f7c3-fee8-90e9-02901d7df30a', 'authenticated', 'authenticated', 'minhduc@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Minh \u0110\u1ee9c", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220848", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'b085baed-f7c3-fee8-90e9-02901d7df30a';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'ecd0cbfc-1703-345f-6aa3-e7c01a5da786', 'authenticated', 'authenticated', 'tuanduc@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Tu\u1ea5n \u0110\u1ee9c", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220444", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'ecd0cbfc-1703-345f-6aa3-e7c01a5da786';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '24ad0d69-7575-7f1b-da5f-c3ec4774f27e', 'authenticated', 'authenticated', 'minhduc1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ecbnh Minh \u0110\u1ee9c", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220987", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '24ad0d69-7575-7f1b-da5f-c3ec4774f27e';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '78a43dbb-d757-8fa7-f72a-898ffc737329', 'authenticated', 'authenticated', 'phetsalatemmy1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "PHETSALAT Emmy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221190", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '78a43dbb-d757-8fa7-f72a-898ffc737329';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'cede4a45-433a-d7b4-2105-6e30c8bdc937', 'authenticated', 'authenticated', 'xuanhieu@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ho\u00e0ng Xu\u00e2n Hi\u1ebfu", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220959", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'cede4a45-433a-d7b4-2105-6e30c8bdc937';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '582b0404-048c-53a9-8be7-5512bc5005a5', 'authenticated', 'authenticated', 'syhieu@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 S\u1ef9 Hi\u1ebfu", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220856", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '582b0404-048c-53a9-8be7-5512bc5005a5';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '8248fb52-937d-2f6a-fd93-96e7ff9529e8', 'authenticated', 'authenticated', 'thihoai@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Phan Th\u1ecb Ho\u00e0i", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221077", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '8248fb52-937d-2f6a-fd93-96e7ff9529e8';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '081c8d93-6a97-d2a5-8ba3-87bc734a2dd9', 'authenticated', 'authenticated', 'viethoang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Cao Vi\u1ec7t Ho\u00e0ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220960", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '081c8d93-6a97-d2a5-8ba3-87bc734a2dd9';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'db92cc35-88ee-e1ed-48f5-eaccb16f8f63', 'authenticated', 'authenticated', 'baohoang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea B\u1ea3o Ho\u00e0ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220714", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'db92cc35-88ee-e1ed-48f5-eaccb16f8f63';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'c71f8ec4-d6c3-dbc3-d62a-1e040dd136ba', 'authenticated', 'authenticated', 'huyhoang1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n Huy Ho\u00e0ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221045", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'c71f8ec4-d6c3-dbc3-d62a-1e040dd136ba';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '82edc5df-7608-5800-5f0f-6f5101f0b016', 'authenticated', 'authenticated', 'vanhung@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 V\u0103n H\u00f9ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220926", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '82edc5df-7608-5800-5f0f-6f5101f0b016';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '4ab10f66-e633-b1d4-5cff-bd6d7760fd3c', 'authenticated', 'authenticated', 'khanhhung@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Vi Kh\u00e1nh H\u00f9ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220475", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '4ab10f66-e633-b1d4-5cff-bd6d7760fd3c';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'c6a813ef-7dfe-db6b-ba17-44bfd7995d89', 'authenticated', 'authenticated', 'quanghuy1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Quang Huy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220855", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'c6a813ef-7dfe-db6b-ba17-44bfd7995d89';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'abeb691f-a189-f7bb-3955-acead084f301', 'authenticated', 'authenticated', 'duchuy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ph\u1ea1m \u0110\u1ee9c Huy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220927", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'abeb691f-a189-f7bb-3955-acead084f301';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '211aa2a4-7d7c-c6dd-d2b9-f08ad2fd5b0b', 'authenticated', 'authenticated', 'somphonheuangjackkie@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "SOMPHONHEUANG Jackkie", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221184", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '211aa2a4-7d7c-c6dd-d2b9-f08ad2fd5b0b';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '78fbf508-2777-8e01-fd09-aaed531e10c8', 'authenticated', 'authenticated', 'xayyasithkeopaserd@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "XAYYASITH Keopaserd", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221183", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '78fbf508-2777-8e01-fd09-aaed531e10c8';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '4dcc9cc4-1925-7281-4421-20774c2366ce', 'authenticated', 'authenticated', 'dangkien@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n \u0110\u0103ng Ki\u00ean", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220974", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '4dcc9cc4-1925-7281-4421-20774c2366ce';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '155c2a91-c86c-a1f6-a751-070c5e8abc30', 'authenticated', 'authenticated', 'xuanlam@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea Xu\u00e2n L\u00e2m", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220186", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '155c2a91-c86c-a1f6-a751-070c5e8abc30';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'b34f08b8-2c50-82d6-3b81-327350c5e7d2', 'authenticated', 'authenticated', 'quanglinh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "B\u00f9i Quang Linh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220553", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'b34f08b8-2c50-82d6-3b81-327350c5e7d2';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '89a8279b-67bc-9168-6ad0-f0c034540f96', 'authenticated', 'authenticated', 'quyenlinh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "\u0110inh L\u00ea Quy\u1ec1n Linh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220547", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '89a8279b-67bc-9168-6ad0-f0c034540f96';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9799a13a-24c5-4f13-fea3-300120ffbc5d', 'authenticated', 'authenticated', 'tieulong@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "D\u01b0\u01a1ng Ti\u1ec3u Long", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221030", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '9799a13a-24c5-4f13-fea3-300120ffbc5d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'b4e0921b-0b3f-63e7-6aa7-e90543f475d3', 'authenticated', 'authenticated', 'dangluc@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n \u0110\u0103ng L\u1ef1c", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220642", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'b4e0921b-0b3f-63e7-6aa7-e90543f475d3';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '21c9d673-f2e7-cccf-6def-348878b9c65f', 'authenticated', 'authenticated', 'ducluong@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n \u0110\u1ee9c L\u01b0\u01a1ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220929", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '21c9d673-f2e7-cccf-6def-348878b9c65f';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '47396fbd-ffc9-d59d-d5d1-109c1ff6250c', 'authenticated', 'authenticated', 'vanmanh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n V\u0103n M\u1ea1nh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220924", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '47396fbd-ffc9-d59d-d5d1-109c1ff6250c';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '5ed189aa-bafe-f51c-90d3-459bfab06a0f', 'authenticated', 'authenticated', 'tainguyen@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n T\u00e0i Nguy\u00ean", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221070", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '5ed189aa-bafe-f51c-90d3-459bfab06a0f';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '539d42fb-f3d9-f3e9-75ab-29765ff6c57d', 'authenticated', 'authenticated', 'trongnhat@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Tr\u1ecdng Nh\u1eadt", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220503", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '539d42fb-f3d9-f3e9-75ab-29765ff6c57d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'a8677a50-f7ae-4f9c-8eb5-6ac1dc2670c2', 'authenticated', 'authenticated', 'dinhphat@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "V\u00f5 \u0110\u00ecnh Ph\u00e1t", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220985", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'a8677a50-f7ae-4f9c-8eb5-6ac1dc2670c2';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '5d31199d-aafb-80df-95b4-9ab025c8f04a', 'authenticated', 'authenticated', 'tanphong@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea V\u0103n T\u1ea5n Phong", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220472", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '5d31199d-aafb-80df-95b4-9ab025c8f04a';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '842a1b8d-4a18-213b-2adc-5e9df7e89add', 'authenticated', 'authenticated', 'quangphuc@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n Quang Ph\u00fac", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221021", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '842a1b8d-4a18-213b-2adc-5e9df7e89add';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '98a7542d-bd96-a973-76ee-b2a157eee927', 'authenticated', 'authenticated', 'chanthathebpoumsavanh1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "CHANTHATHEB Poumsavanh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221189", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '98a7542d-bd96-a973-76ee-b2a157eee927';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '46adbd52-c15e-7d5b-c713-ecef70105a88', 'authenticated', 'authenticated', 'huynhquang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "\u0110\u1eb7ng Hu\u1ef3nh Quang", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220936", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '46adbd52-c15e-7d5b-c713-ecef70105a88';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'b42928fd-86bc-a861-cb7a-2a24ddacec6c', 'authenticated', 'authenticated', 'hongquang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea H\u1ed3ng Quang", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221007", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'b42928fd-86bc-a861-cb7a-2a24ddacec6c';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '94f087ed-92e1-e760-f4d0-c81da50ef5bc', 'authenticated', 'authenticated', 'minhquan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Cao Minh Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220539", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '94f087ed-92e1-e760-f4d0-c81da50ef5bc';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '55688be9-6e57-4bf8-7c14-19bd2a572dda', 'authenticated', 'authenticated', 'vanquan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ho\u00e0ng V\u0103n Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221014", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '55688be9-6e57-4bf8-7c14-19bd2a572dda';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '7637b452-29ab-eba6-ae48-cf00fbab9c4c', 'authenticated', 'authenticated', 'minhquan1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 Minh Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220782", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '7637b452-29ab-eba6-ae48-cf00fbab9c4c';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'f7307866-fbda-784d-2174-7628baa59518', 'authenticated', 'authenticated', 'anhquan1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea Anh Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221162", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'f7307866-fbda-784d-2174-7628baa59518';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'b69b0d88-1684-b1bf-a6e1-821486c055f8', 'authenticated', 'authenticated', 'anhquan2@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Anh Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221067", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'b69b0d88-1684-b1bf-a6e1-821486c055f8';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '634713f3-fe53-e3dc-d423-8fbd8e7026e5', 'authenticated', 'authenticated', 'hongquan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n H\u1ed3ng Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220160", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '634713f3-fe53-e3dc-d423-8fbd8e7026e5';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '921f4c73-d7ad-86ea-620c-fab165ff98fd', 'authenticated', 'authenticated', 'huuquan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n H\u1eefu Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220690", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '921f4c73-d7ad-86ea-620c-fab165ff98fd';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '3c208675-93a6-edbc-bae7-60b601983360', 'authenticated', 'authenticated', 'quocquan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Qu\u1ed1c Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220983", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '3c208675-93a6-edbc-bae7-60b601983360';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '5a16d751-ae09-c854-dfad-9797b4d7eb1b', 'authenticated', 'authenticated', 'tienquan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Phan Ti\u1ebfn Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220933", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '5a16d751-ae09-c854-dfad-9797b4d7eb1b';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '99e72b51-26c2-e9b4-6952-1008cfad473f', 'authenticated', 'authenticated', 'anhquan3@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u01b0\u01a1ng Anh Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221094", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '99e72b51-26c2-e9b4-6952-1008cfad473f';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'e1627785-9c76-1555-7745-811e8cdb24ec', 'authenticated', 'authenticated', 'trongquoc@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Tr\u1ecdng Qu\u1ed1c", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221096", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'e1627785-9c76-1555-7745-811e8cdb24ec';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '26860392-76c6-115a-cc67-fb37d011c30f', 'authenticated', 'authenticated', 'vietquynh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Vi\u1ebft Qu\u1ef3nh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221099", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '26860392-76c6-115a-cc67-fb37d011c30f';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '5c48f012-eccc-632d-bcf8-bd5d345a1e1b', 'authenticated', 'authenticated', 'vansang1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n V\u0103n Sang", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221029", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '5c48f012-eccc-632d-bcf8-bd5d345a1e1b';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'acad0f59-be70-e83b-073c-0ffd8b11377d', 'authenticated', 'authenticated', 'khotphouthonesoulima1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "KHOTPHOUTHONE Soulima", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221188", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'acad0f59-be70-e83b-073c-0ffd8b11377d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '1fa9dbbf-cb03-b10e-f6cd-0f213aa690ca', 'authenticated', 'authenticated', 'chiasouatongkhasouthida@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "CHIASOUATONGKHA Southida", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221185", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '1fa9dbbf-cb03-b10e-f6cd-0f213aa690ca';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '6281463c-dc6b-3274-84af-c219594824b0', 'authenticated', 'authenticated', 'vantai1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n V\u0103n T\u00e0i", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221095", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '6281463c-dc6b-3274-84af-c219594824b0';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '8e152274-6cc0-e282-eea2-6365e2d26601', 'authenticated', 'authenticated', 'quocthanh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ph\u00f9ng Qu\u1ed1c Th\u00e0nh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220992", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '8e152274-6cc0-e282-eea2-6365e2d26601';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '4a8c8fd1-8073-48b8-6572-b2632161891c', 'authenticated', 'authenticated', 'xuanthao@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea Xu\u00e2n Thao", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220885", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '4a8c8fd1-8073-48b8-6572-b2632161891c';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '3f4d0db8-2d18-fc9d-f852-d7e04f0cb0c4', 'authenticated', 'authenticated', 'vanthang1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ho\u00e0ng V\u0103n Th\u1eafng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220982", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '3f4d0db8-2d18-fc9d-f852-d7e04f0cb0c4';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '63508d46-146c-a914-3fe0-5e754dc02fbb', 'authenticated', 'authenticated', 'vanthang2@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n V\u0103n Th\u1eafng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220949", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '63508d46-146c-a914-3fe0-5e754dc02fbb';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '90b5e5cc-7455-dc62-1121-dbb8ff51d75a', 'authenticated', 'authenticated', 'ducthinh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ng\u00f4 \u0110\u1ee9c Th\u1ecbnh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221155", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '90b5e5cc-7455-dc62-1121-dbb8ff51d75a';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9ad94881-d3e7-cc6a-59ea-f5926c0888c5', 'authenticated', 'authenticated', 'luangphithakthipkesone@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "LUANGPHITHAK Thipkesone", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221181", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '9ad94881-d3e7-cc6a-59ea-f5926c0888c5';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'ff5670a9-9794-51ec-d00c-dd7e605b5e0d', 'authenticated', 'authenticated', 'thammavongsathotsaphone1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "THAMMAVONGSA Thotsaphone", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221192", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'ff5670a9-9794-51ec-d00c-dd7e605b5e0d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '34a31935-37c7-900d-da57-b4602dfc8106', 'authenticated', 'authenticated', 'trongthong@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Tr\u1ecdng Th\u00f4ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220495", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '34a31935-37c7-900d-da57-b4602dfc8106';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9e27c777-127d-7db2-3b0d-cb3cfa546555', 'authenticated', 'authenticated', 'vanthuy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n V\u0103n Th\u1ee7y", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221151", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '9e27c777-127d-7db2-3b0d-cb3cfa546555';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '2fafce56-fee5-8d6f-7bf1-af78b66dbf8d', 'authenticated', 'authenticated', 'manhtien@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u00e0n M\u1ea1nh Ti\u1ebfn", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220986", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '2fafce56-fee5-8d6f-7bf1-af78b66dbf8d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'a3374a45-e734-f05f-86d0-22e5fa01eea4', 'authenticated', 'authenticated', 'quangtrung@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Th\u1ecbnh Quang Trung", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220771", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'a3374a45-e734-f05f-86d0-22e5fa01eea4';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '371a0aef-fda0-e11e-3ff5-607105625bb3', 'authenticated', 'authenticated', 'vantruong@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n V\u0103n Tr\u01b0\u1eddng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220930", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '371a0aef-fda0-e11e-3ff5-607105625bb3';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '7e792f06-22de-321a-042b-1aa3a80bb0a8', 'authenticated', 'authenticated', 'xuantruong@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Xu\u00e2n Tr\u01b0\u1eddng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220931", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '7e792f06-22de-321a-042b-1aa3a80bb0a8';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'c783b4c8-bc88-4ebb-da0f-0234abc7bf0c', 'authenticated', 'authenticated', 'minhtuan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Minh Tu\u1ea5n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221065", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'c783b4c8-bc88-4ebb-da0f-0234abc7bf0c';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'abe9b8ac-d0c1-4660-3f7b-8a6e766cb692', 'authenticated', 'authenticated', 'doanuy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Do\u00e3n Uy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220932", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'abe9b8ac-d0c1-4660-3f7b-8a6e766cb692';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '6bf3cfbe-f5d2-11c4-dfb7-2bbb7f72b992', 'authenticated', 'authenticated', 'vietviet@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea Vi\u1ebft Vi\u1ec7t", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220845", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '6bf3cfbe-f5d2-11c4-dfb7-2bbb7f72b992';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'c3307fec-e78b-a049-43f9-24e713fe1905', 'authenticated', 'authenticated', 'chanthavvongvilaphon@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "CHANTHAVVONG Vilaphon", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221182", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'c3307fec-e78b-a049-43f9-24e713fe1905';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '91c2d2aa-95a5-2b2d-c7d5-d4a4aab1171b', 'authenticated', 'authenticated', 'lengtuaporxengva@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "LENGTUAPOR Xengva", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221186", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '91c2d2aa-95a5-2b2d-c7d5-d4a4aab1171b';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'e29455fb-424c-4c9d-c165-a1f5f71d46c2', 'authenticated', 'authenticated', 'vuechayeryingyu@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "VUECHAYER Yingyu", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221179", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'e29455fb-424c-4c9d-c165-a1f5f71d46c2';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '02703574-353a-6c83-7076-c048072e2c6d', 'authenticated', 'authenticated', 'viettung@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n Vi\u1ec7t T\u00f9ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1505200664", "enrollment_class": "DHCTTCK15A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '02703574-353a-6c83-7076-c048072e2c6d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '6529fc07-16a2-96ff-5032-8a8fc1098296', 'authenticated', 'authenticated', 'synhan@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ho\u00e0ng S\u1ef9 Nh\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1505201214", "enrollment_class": "DHCTTCK15A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '6529fc07-16a2-96ff-5032-8a8fc1098296';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '8b05bf83-3dd4-922a-ca33-001964b4c2b4', 'authenticated', 'authenticated', 'tungduong@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n T\u00f9ng D\u01b0\u01a1ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1605211364", "enrollment_class": "DHKTMCK16A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '8b05bf83-3dd4-922a-ca33-001964b4c2b4';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '6eea0a23-5146-8324-b182-8ff05a56eb12', 'authenticated', 'authenticated', 'vanhai@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 V\u0103n H\u1ea3i", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1605211328", "enrollment_class": "DHCTTCK16A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '6eea0a23-5146-8324-b182-8ff05a56eb12';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'f9b8c295-cbf0-1458-2b4e-cbc9346accca', 'authenticated', 'authenticated', 'vannam@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n V\u0103n Nam", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1605211412", "enrollment_class": "DHCTTCK16A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'f9b8c295-cbf0-1458-2b4e-cbc9346accca';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'f0f2f525-59a7-9e5a-31a0-4343c39037d8', 'authenticated', 'authenticated', 'minhnhat@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Nh\u01b0 Minh Nh\u1eadt", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1605230050", "enrollment_class": "DHCTTLK16Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'f0f2f525-59a7-9e5a-31a0-4343c39037d8';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '1b0cc8b6-0dd9-3edd-8aa7-d417c708787e', 'authenticated', 'authenticated', 'ducdung2@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n \u0110\u1ee9c D\u0169ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805250021", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '1b0cc8b6-0dd9-3edd-8aa7-d417c708787e';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '7a9ab77d-aee2-29c0-9b1b-37010b883b49', 'authenticated', 'authenticated', 'trunghieu1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Trung Hi\u1ebfu", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805250054", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '7a9ab77d-aee2-29c0-9b1b-37010b883b49';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '97371109-89b8-22fb-cb69-0bde6221235d', 'authenticated', 'authenticated', 'thihoa@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 Th\u1ecb H\u00f2a", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805250033", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '97371109-89b8-22fb-cb69-0bde6221235d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '0b4c6961-171c-4e4e-f90c-e02237469a50', 'authenticated', 'authenticated', 'vinhkhiem@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n V\u0129nh Khi\u00eam", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805250057", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '0b4c6961-171c-4e4e-f90c-e02237469a50';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'd574e10f-8a92-fd9c-2cde-ccbf1dba6851', 'authenticated', 'authenticated', 'thanhquang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "\u0110o\u00e0n Thanh Quang", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805250076", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'd574e10f-8a92-fd9c-2cde-ccbf1dba6851';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9133c39b-c664-4008-9e62-754034dc8f35', 'authenticated', 'authenticated', 'hoangquan1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "D\u01b0\u01a1ng Nguy\u1ec5n Ho\u00e0ng Qu\u00e2n", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805250077", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '9133c39b-c664-4008-9e62-754034dc8f35';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '88d2366d-3cef-79f4-46c8-0b3917a90cec', 'authenticated', 'authenticated', 'minhduc2@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Minh \u0110\u1ee9c", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805250131", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '88d2366d-3cef-79f4-46c8-0b3917a90cec';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'f701cc13-e1c9-2e3a-8ac6-d26db84dbaf8', 'authenticated', 'authenticated', 'ngocanh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n Ng\u1ecdc Anh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805250901", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'f701cc13-e1c9-2e3a-8ac6-d26db84dbaf8';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'b2eda3a3-92f3-e95e-fac2-400148684377', 'authenticated', 'authenticated', 'tronghuy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u0103ng Tr\u1ecdng Huy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805230328", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'b2eda3a3-92f3-e95e-fac2-400148684377';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '601f7418-963e-3872-45e4-2983072eaa6e', 'authenticated', 'authenticated', 'vankien@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n V\u0103n Ki\u00ean", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805230568", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '601f7418-963e-3872-45e4-2983072eaa6e';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '3b9485f0-dc0c-4a9c-b87a-d8d54b629093', 'authenticated', 'authenticated', 'xuanquang@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Cao Xu\u00e2n Quang", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805230411", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '3b9485f0-dc0c-4a9c-b87a-d8d54b629093';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '29655fe0-2ad3-f704-bc76-5c5c48fde7a3', 'authenticated', 'authenticated', 'vantai3@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "\u0110\u1eb7ng V\u0103n T\u00e0i", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805230279", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '29655fe0-2ad3-f704-bc76-5c5c48fde7a3';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'bfe90927-b20b-ee45-7067-0035e38d09fa', 'authenticated', 'authenticated', 'viettruong@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "V\u01b0\u01a1ng Vi\u1ebft Tr\u01b0\u1eddng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1805230692", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'bfe90927-b20b-ee45-7067-0035e38d09fa';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'cbcf142a-a40b-c03d-a252-8fc979be5ea1', 'authenticated', 'authenticated', 'dinhhuy1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n \u0110\u00ecnh Huy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1905241313", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'cbcf142a-a40b-c03d-a252-8fc979be5ea1';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '3f8a56bb-824a-8009-6a4b-b42fcd974021', 'authenticated', 'authenticated', 'soulivonganon1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "SOULIVONG Anon", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1905241339", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '3f8a56bb-824a-8009-6a4b-b42fcd974021';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '133b4146-ead2-fc77-b27f-2c7e3d611d2d', 'authenticated', 'authenticated', 'phimmathatakkaxay@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "PHIMMATHAT Akkaxay", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220020", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '133b4146-ead2-fc77-b27f-2c7e3d611d2d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '260628da-2af1-64b9-3ac5-71756a6603b6', 'authenticated', 'authenticated', 'tuananh2@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ng\u00f4 C\u00f4ng Tu\u1ea5n Anh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221071", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '260628da-2af1-64b9-3ac5-71756a6603b6';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '93ca9b9b-3d39-6d3b-ec1d-4bc6e0791db3', 'authenticated', 'authenticated', 'inthavongchanthaphone@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "INTHAVONG Chanthaphone", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220021", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '93ca9b9b-3d39-6d3b-ec1d-4bc6e0791db3';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '1f659e09-3343-214e-566f-18e9b5ef6c90', 'authenticated', 'authenticated', 'tungduong1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 T\u00f9ng D\u01b0\u01a1ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220440", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '1f659e09-3343-214e-566f-18e9b5ef6c90';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '85b9fc47-5315-e74c-aae6-7e007e835213', 'authenticated', 'authenticated', 'thanhdat4@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n Th\u00e0nh \u0110\u1ea1t", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220950", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '85b9fc47-5315-e74c-aae6-7e007e835213';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '93449d8d-2973-db81-6a34-4a084747604d', 'authenticated', 'authenticated', 'vodong@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "H\u1ed3 V\u0103n V\u00f5 \u0110\u1ed3ng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220056", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '93449d8d-2973-db81-6a34-4a084747604d';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '72d054d4-0b8c-57ec-92cd-9fc97ab9bb08', 'authenticated', 'authenticated', 'xuanduc@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Tr\u1ea7n Xu\u00e2n \u0110\u1ee9c", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220537", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '72d054d4-0b8c-57ec-92cd-9fc97ab9bb08';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'da62b71a-20a2-a897-d233-29ca99a8eb34', 'authenticated', 'authenticated', 'vanhuy@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n V\u0103n Huy", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220526", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'da62b71a-20a2-a897-d233-29ca99a8eb34';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '1dc4a001-d616-e9df-6f1f-469dc58e430f', 'authenticated', 'authenticated', 'dangkhanh@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Nguy\u1ec5n \u0110\u0103ng Kh\u00e1nh", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220439", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '1dc4a001-d616-e9df-6f1f-469dc58e430f';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '79c27f66-46b5-c3a2-96be-8d753bcea103', 'authenticated', 'authenticated', 'vannam1@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "L\u00ea V\u0103n Nam", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705221006", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '79c27f66-46b5-c3a2-96be-8d753bcea103';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '2a9da6a8-147a-47f0-f200-01d01369a064', 'authenticated', 'authenticated', 'vannavongphoneseng@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "VANNAVONG Phoneseng", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220022", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '2a9da6a8-147a-47f0-f200-01d01369a064';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9788675a-af13-a3da-f564-4e2a4830b77a', 'authenticated', 'authenticated', 'itthavongsisawat@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "ITTHAVONG Sisawat", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220023", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '9788675a-af13-a3da-f564-4e2a4830b77a';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '2b1d60f4-1718-1f2a-ce3c-cbb892281cbc', 'authenticated', 'authenticated', 'paphatsalangsoukpaseuth@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "PAPHATSALANG Soukpaseuth", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220024", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '2b1d60f4-1718-1f2a-ce3c-cbb892281cbc';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', '9fe58cb0-ab84-9861-74a0-5570b5087cb7', 'authenticated', 'authenticated', 'caothem@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "\u0110\u1eadu Cao Th\u00eam", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220491", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = '9fe58cb0-ab84-9861-74a0-5570b5087cb7';


INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', 'a9aae2f1-489e-8ef3-7c51-6c167ed0bc2a', 'authenticated', 'authenticated', 'trungthu@gmail.com', crypt('12345678', gen_salt('bf')),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Ho\u00e0ng Trung Thu", "role": "student"}', now(), now()
) ON CONFLICT (id) DO NOTHING;


UPDATE public.profiles 
SET metadata = '{"student_code": "1705220784", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}'::jsonb, role = 'student'
WHERE id = 'a9aae2f1-489e-8ef3-7c51-6c167ed0bc2a';


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('2d7445b5-cfdd-9d7b-0334-842b114d5a18', 'MMT(224)_01/K18A1 - Mạng máy tính', 'Mạng máy tính', 'a4d25ceb-0182-3a61-59ad-571884b706ec', 'DHCTTCK18A1', 1)
ON CONFLICT DO NOTHING;


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('cc2bdad1-6c7a-681f-2039-ddf5f68ce4ef', 'MMT(225)_01/K19A1 - Mạng máy tính', 'Mạng máy tính', 'a4d25ceb-0182-3a61-59ad-571884b706ec', 'DHCTTCK19A1, DHKTMCK18A1', 1)
ON CONFLICT DO NOTHING;


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('c740bdaa-182d-c6c1-a7c0-c52d4df6eab7', 'MMT(225)_03/K19A2 - Mạng máy tính', 'Mạng máy tính', 'a4d25ceb-0182-3a61-59ad-571884b706ec', 'DHCTTCK19A2', 1)
ON CONFLICT DO NOTHING;


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('54ffdb9d-20e5-842b-2018-5948b6ccdfa1', 'TCB(125)_17/DTCNK20A1 - Tin học cơ bản', 'Tin học cơ bản', 'a4d25ceb-0182-3a61-59ad-571884b706ec', 'DHDTVCK20A1', 1)
ON CONFLICT DO NOTHING;


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('1f9269e7-9892-23ef-99a1-ba48414ba0b4', 'PTUDW1(123)_04_TH/K17A2 - Phát triển ứng dụng Web 1 TH', 'Phát triển ứng dụng Web 1 TH', 'a4d25ceb-0182-3a61-59ad-571884b706ec', 'DHCTTCK17A2', 1)
ON CONFLICT DO NOTHING;


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('414ce71c-3b36-f04f-dcc9-63a33402e971', 'SQLSERVER(123)_01_TH/K17A1 - Hệ quản trị CSDL SQL Server TH', 'Hệ quản trị CSDL SQL Server TH', 'a4d25ceb-0182-3a61-59ad-571884b706ec', 'DHCTTCK17A1', 1)
ON CONFLICT DO NOTHING;


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('f57e7528-1331-4290-9004-8ec2b09fab24', 'PTUDW1(125)_03_TH/K19A2 - Phát triển ứng dụng Web 1 TH', 'Phát triển ứng dụng Web 1 TH', '8cc7c854-2a65-a094-5ff5-619be6661e99', 'DHCTTCK19A2, DHCTTLK18Z', 1)
ON CONFLICT DO NOTHING;


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('27845762-c738-293e-223c-5094259927d5', 'SQLSERVER(125)_03_TH/K19A2_A - Hệ quản trị CSDL SQL Server TH (đợt 1)', 'Hệ quản trị CSDL SQL Server TH (đợt 1)', 'a4d25ceb-0182-3a61-59ad-571884b706ec', 'DHCTTCK19A2, DHCTTCK19A1, DHCTTLK18Z', 1)
ON CONFLICT DO NOTHING;


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('3184d458-d8d1-6aab-7f85-34779dd9ce8f', 'SQLSERVER(125)_03_TH/K19A2_B - Hệ quản trị CSDL SQL Server TH (đợt 2)', 'Hệ quản trị CSDL SQL Server TH (đợt 2)', 'a4d25ceb-0182-3a61-59ad-571884b706ec', 'DHCTTCK19A2, DHCTTCK19A1, DHCTTLK16Z', 1)
ON CONFLICT DO NOTHING;


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('d7cadd6b-8830-594e-69b1-c21d309b683f', 'TTTNN(225)_01/K17-K18 - Trí tuệ nhân tạo nâng cao', 'Trí tuệ nhân tạo nâng cao', 'a4d25ceb-0182-3a61-59ad-571884b706ec', 'DHCTTCK17A1, DHCTTCK17A2, DHCTTCK18A1, DHCTTCK18A2', 1)
ON CONFLICT DO NOTHING;


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('6a293e03-32a6-f008-1b3e-ff4109ea3117', 'CSLTWEB(225)_01/K20A1 - Cơ sở lập trình web', 'Cơ sở lập trình web', 'a4d25ceb-0182-3a61-59ad-571884b706ec', 'DHCTTCK20A1, DHCTTCK18A2, DHCTTLK18Z, DHCTTLK16Z', 1)
ON CONFLICT DO NOTHING;


INSERT INTO public.classes (id, name, description, teacher_id, academic_year, semester) 
VALUES ('137ca08b-ac26-426a-dcd3-fb5156bab983', 'TCB(225)_08 - Tin học cơ bản', 'Tin học cơ bản', 'e0fadd0d-a349-b1bc-6d3a-249ade2870ff', 'DHOTOCK20A5-A9, DHCTTLK18Z', 1)
ON CONFLICT DO NOTHING;

COMMIT;