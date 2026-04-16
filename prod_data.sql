SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict YvSPNIykVs35KVDs3N3P5K60kDcCauwG8L3ohAtwHgW0UqjQfScxfTfq913LKTU

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', 'd0fab6ce-74bf-4b57-8299-cd9a5bfdb480', 'authenticated', 'authenticated', '1234@gmail.com', '$2a$10$/cF6fYGljEoObbG0.2pypu8/XxVsZZkRe.4ddhFbXSqIN4n4zpJCe', '2026-02-04 09:08:42.36015+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-02-04 09:08:42.371507+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "d0fab6ce-74bf-4b57-8299-cd9a5bfdb480", "role": "student", "email": "1234@gmail.com", "phone": "0986658863", "gender": "male", "full_name": "Khánh Toàn", "email_verified": true, "phone_verified": false}', NULL, '2026-02-04 09:08:42.304824+00', '2026-02-04 09:08:42.374346+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '076de02d-75ba-4e79-898d-1b5e43141894', 'authenticated', 'authenticated', 'hs1@gmail.com', '$2a$10$L95.j1CL8But9TCiksdpNOsnJY7xJgN1N6BKGITjL.B/YxOWzzq8y', '2025-12-15 16:04:13.664444+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-25 15:15:25.144285+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2025-12-15 16:04:13.651391+00', '2026-03-31 04:51:23.476167+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '6c8533ea-659f-46f1-9c7d-59768ea871d2', 'authenticated', 'authenticated', 'giap@gmail.com', '$2a$10$tW7pM5vigSwXreJD3geFuepVb0yRibfcVfpZiLzzSJYFYCfo6UmXe', '2025-12-28 17:16:37.380778+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-12-28 17:16:37.385472+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "6c8533ea-659f-46f1-9c7d-59768ea871d2", "role": "student", "email": "giap@gmail.com", "phone": "07126348123", "full_name": "huhiadf", "email_verified": true, "phone_verified": false}', NULL, '2025-12-28 17:16:37.367609+00', '2025-12-28 17:16:37.389482+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'def12bef-7d75-48ac-a3f8-3427ede277ec', 'authenticated', 'authenticated', 'thai@gmail.com', '$2a$10$q5MkmfXXbEzNoHw/WdCQLOf8WgOmEGwxAjl0ZPnSpFkwyep437Nwm', '2025-12-28 16:35:02.677147+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-12-28 16:35:02.683257+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "def12bef-7d75-48ac-a3f8-3427ede277ec", "role": "student", "email": "thai@gmail.com", "full_name": "Lữ Quang Thái", "email_verified": true, "phone_verified": false}', NULL, '2025-12-28 16:35:02.653192+00', '2025-12-28 16:35:02.705496+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'authenticated', 'authenticated', 'ha@gmail.com', '$2a$10$CigXk5jZ4qFGAWtxXSAKAuv3ywwPxOE.hS5q4KqY45Jq0xC.HSnUG', '2026-01-13 07:19:50.400537+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-24 10:12:12.30111+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "d810df06-78c5-441c-8eaf-90e6e505adad", "role": "teacher", "email": "ha@gmail.com", "phone": "0123456987", "gender": "female", "full_name": "Hồ Ngọc Hà", "email_verified": true, "phone_verified": false}', NULL, '2026-01-13 07:19:50.370522+00', '2026-03-25 14:48:09.352368+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'f2e3f942-8f0e-464f-b386-7adcc8e90243', 'authenticated', 'authenticated', 'quyen@gmail.com', '$2a$10$dR7e73icH/zZr8.lf7LkieHjns/NBsUobOvSyjvXgIo2NImPqQrB6', '2025-12-28 17:13:38.734553+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-12-28 17:13:47.641871+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "f2e3f942-8f0e-464f-b386-7adcc8e90243", "role": "student", "email": "quyen@gmail.com", "phone": "012983490", "full_name": "djidađ", "email_verified": true, "phone_verified": false}', NULL, '2025-12-28 17:13:38.637509+00', '2025-12-28 17:13:47.648279+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '61d5066a-4827-44bd-a05c-43f2d62c3213', 'authenticated', 'authenticated', 'kmtrinh@gmail.com', '$2a$10$LyodSjri.0ZdYydsQtWZneTug6muXB5dBTQvBNkL9jcwW7/Fs4tlO', '2025-12-28 16:42:13.835434+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-12-28 16:42:13.839267+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "61d5066a-4827-44bd-a05c-43f2d62c3213", "role": "student", "email": "kmtrinh@gmail.com", "full_name": "kieu manh trinh", "email_verified": true, "phone_verified": false}', NULL, '2025-12-28 16:42:13.820841+00', '2025-12-28 16:42:13.842237+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '7d26a7e2-b16b-4c4e-93df-4061076f4786', 'authenticated', 'authenticated', 'kien@gmail.com', '$2a$10$C8ecIXtIGNCESr3IWBXTzOL0gLEvcVXXXxv79aj5NncFm1H6tgylS', '2025-12-28 17:53:24.722766+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-12-29 06:03:27.218024+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "7d26a7e2-b16b-4c4e-93df-4061076f4786", "role": "student", "email": "kien@gmail.com", "phone": "012312341", "gender": "male", "full_name": "kien", "email_verified": true, "phone_verified": false}', NULL, '2025-12-28 17:53:24.670115+00', '2025-12-29 06:03:27.283669+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', 'authenticated', 'authenticated', 'huythaianh73@gmail.com', '$2a$10$HhYn7ADM3tP5p5l8bhKDq.8BOdvncIKK9voztHfjRCvuKIzkjG9i2', '2025-12-15 13:41:32.500121+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-12-22 02:44:16.475346+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2025-12-15 13:41:32.454328+00', '2025-12-22 02:44:16.480506+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', 'authenticated', 'authenticated', 'giaovien@gmail.com', '$2a$10$pOXN0aYtaPqNYj.ow8v3dOM97127OPZkx4FlG/A6qS4lwpSxPl3jO', '2025-12-22 02:46:20.676049+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-01-16 09:25:23.823514+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2025-12-22 02:46:20.658473+00', '2026-01-16 09:25:23.855562+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '381068fc-5eef-4350-ae44-1e65dd28d02c', 'authenticated', 'authenticated', 'kkkkk@gmail.com', '$2a$10$MnES0Xk1aEfMel8VvkgWj.Sjxn.E0Q/eyVJP1sPs2P.uaXaK6MUfi', '2026-01-13 06:08:02.514222+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-01-13 06:08:02.533782+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "381068fc-5eef-4350-ae44-1e65dd28d02c", "role": "teacher", "email": "kkkkk@gmail.com", "phone": "012134", "gender": "female", "full_name": "kllllolkkk", "email_verified": true, "phone_verified": false}', NULL, '2026-01-13 06:08:02.411532+00', '2026-01-13 06:08:02.602022+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '91a6b04f-45ae-4038-9a43-7a0304d68552', 'authenticated', 'authenticated', 'trannam@gmail.com', '$2a$10$OylOoshdw9dtbQB1SpoqruUwhGx0gOfhMxmvAJi0z3h.HAwrsRb3G', '2026-01-13 06:56:23.56122+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-01-13 06:56:23.575602+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "91a6b04f-45ae-4038-9a43-7a0304d68552", "role": "student", "email": "trannam@gmail.com", "phone": "0123456789", "gender": "male", "full_name": "Trần Văn Nam", "email_verified": true, "phone_verified": false}', NULL, '2026-01-13 06:56:23.501737+00', '2026-01-13 06:56:23.613052+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'a874ce65-1214-42b0-86b6-20ed5a36a49f', 'authenticated', 'authenticated', 'a@gmail.com', '$2a$10$T45elln/I.X0NS0HxS1SMOv6FY4vy4k3x1vqw8onGrgKRVov/B8gm', '2026-02-04 09:13:56.45775+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-02-04 09:13:56.467277+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "a874ce65-1214-42b0-86b6-20ed5a36a49f", "role": "admin", "email": "a@gmail.com", "phone": "0900900990", "gender": "male", "full_name": "A", "email_verified": true, "phone_verified": false}', NULL, '2026-02-04 09:13:56.435399+00', '2026-02-04 09:13:56.474449+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '6af4527c-8caa-4903-bb50-dbadcf1778d4', 'authenticated', 'authenticated', 'b@gmail.com', '$2a$10$3kRHdZg4khU0ghLfHGofb.Pik.xT3uMKzvW8v1n2m/LeeKZ2RoaLK', '2026-02-04 09:14:49.822489+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-02-04 09:14:49.831506+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "6af4527c-8caa-4903-bb50-dbadcf1778d4", "role": "teacher", "email": "b@gmail.com", "phone": "0900900090", "gender": "male", "full_name": "B", "email_verified": true, "phone_verified": false}', NULL, '2026-02-04 09:14:49.750831+00', '2026-02-04 09:14:49.852938+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'dcb2cce8-f8d5-440f-ae53-1e39a260254b', 'authenticated', 'authenticated', 'tranthang592004@gmail.com', '$2a$10$npyn7JHJgbTzR1/DjPfMSeKpDMI2PuFmjTXaaB1NuPVKkr1MLOxUu', '2026-02-05 00:56:34.627904+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-02-05 00:56:34.654685+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "dcb2cce8-f8d5-440f-ae53-1e39a260254b", "role": "teacher", "email": "tranthang592004@gmail.com", "phone": "0855363050", "gender": "male", "full_name": "Trần Văn Thắng", "email_verified": true, "phone_verified": false}', NULL, '2026-02-05 00:56:34.508767+00', '2026-02-05 00:56:34.718189+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('af06a4fd-9e7f-411d-b801-4b6aca63fca1', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', '{"sub": "af06a4fd-9e7f-411d-b801-4b6aca63fca1", "email": "huythaianh73@gmail.com", "email_verified": false, "phone_verified": false}', 'email', '2025-12-15 13:41:32.484864+00', '2025-12-15 13:41:32.484925+00', '2025-12-15 13:41:32.484925+00', 'ef00f313-2412-4ad7-be09-73d0a5c37390'),
	('076de02d-75ba-4e79-898d-1b5e43141894', '076de02d-75ba-4e79-898d-1b5e43141894', '{"sub": "076de02d-75ba-4e79-898d-1b5e43141894", "email": "hs1@gmail.com", "email_verified": false, "phone_verified": false}', 'email', '2025-12-15 16:04:13.661242+00', '2025-12-15 16:04:13.661301+00', '2025-12-15 16:04:13.661301+00', 'bd3f51f6-f8f4-4de4-ae94-dd8d7e9f43ba'),
	('7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', '{"sub": "7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5", "email": "giaovien@gmail.com", "email_verified": false, "phone_verified": false}', 'email', '2025-12-22 02:46:20.668557+00', '2025-12-22 02:46:20.669266+00', '2025-12-22 02:46:20.669266+00', 'e8c80f47-eb7f-4a8e-962c-54fc1d2d1cf1'),
	('def12bef-7d75-48ac-a3f8-3427ede277ec', 'def12bef-7d75-48ac-a3f8-3427ede277ec', '{"sub": "def12bef-7d75-48ac-a3f8-3427ede277ec", "role": "student", "email": "thai@gmail.com", "full_name": "Lữ Quang Thái", "email_verified": false, "phone_verified": false}', 'email', '2025-12-28 16:35:02.674223+00', '2025-12-28 16:35:02.674276+00', '2025-12-28 16:35:02.674276+00', 'ff2eecbf-2285-4221-86e1-3ae384e8a5c0'),
	('61d5066a-4827-44bd-a05c-43f2d62c3213', '61d5066a-4827-44bd-a05c-43f2d62c3213', '{"sub": "61d5066a-4827-44bd-a05c-43f2d62c3213", "role": "student", "email": "kmtrinh@gmail.com", "full_name": "kieu manh trinh", "email_verified": false, "phone_verified": false}', 'email', '2025-12-28 16:42:13.831973+00', '2025-12-28 16:42:13.832032+00', '2025-12-28 16:42:13.832032+00', '25c508bc-ba1c-4027-976e-54893f1675c5'),
	('f2e3f942-8f0e-464f-b386-7adcc8e90243', 'f2e3f942-8f0e-464f-b386-7adcc8e90243', '{"sub": "f2e3f942-8f0e-464f-b386-7adcc8e90243", "role": "student", "email": "quyen@gmail.com", "phone": "012983490", "full_name": "djidađ", "email_verified": false, "phone_verified": false}', 'email', '2025-12-28 17:13:38.715685+00', '2025-12-28 17:13:38.716884+00', '2025-12-28 17:13:38.716884+00', '9ab9c713-0ed8-48bb-ab61-0ca06d7cae77'),
	('6c8533ea-659f-46f1-9c7d-59768ea871d2', '6c8533ea-659f-46f1-9c7d-59768ea871d2', '{"sub": "6c8533ea-659f-46f1-9c7d-59768ea871d2", "role": "student", "email": "giap@gmail.com", "phone": "07126348123", "full_name": "huhiadf", "email_verified": false, "phone_verified": false}', 'email', '2025-12-28 17:16:37.376276+00', '2025-12-28 17:16:37.376323+00', '2025-12-28 17:16:37.376323+00', '67b21cf7-4cce-4101-a7b7-9e7d9685f141'),
	('7d26a7e2-b16b-4c4e-93df-4061076f4786', '7d26a7e2-b16b-4c4e-93df-4061076f4786', '{"sub": "7d26a7e2-b16b-4c4e-93df-4061076f4786", "role": "student", "email": "kien@gmail.com", "phone": "012312341", "gender": "male", "full_name": "kien", "email_verified": false, "phone_verified": false}', 'email', '2025-12-28 17:53:24.715114+00', '2025-12-28 17:53:24.715188+00', '2025-12-28 17:53:24.715188+00', 'e66390ed-f7a3-462c-a6ac-a64d1e3ad332'),
	('381068fc-5eef-4350-ae44-1e65dd28d02c', '381068fc-5eef-4350-ae44-1e65dd28d02c', '{"sub": "381068fc-5eef-4350-ae44-1e65dd28d02c", "role": "teacher", "email": "kkkkk@gmail.com", "phone": "012134", "gender": "female", "full_name": "kllllolkkk", "email_verified": false, "phone_verified": false}', 'email', '2026-01-13 06:08:02.504525+00', '2026-01-13 06:08:02.504583+00', '2026-01-13 06:08:02.504583+00', '76b628a6-f27d-46fa-a36d-1591740c62ba'),
	('91a6b04f-45ae-4038-9a43-7a0304d68552', '91a6b04f-45ae-4038-9a43-7a0304d68552', '{"sub": "91a6b04f-45ae-4038-9a43-7a0304d68552", "role": "student", "email": "trannam@gmail.com", "phone": "0123456789", "gender": "male", "full_name": "Trần Văn Nam", "email_verified": false, "phone_verified": false}', 'email', '2026-01-13 06:56:23.553199+00', '2026-01-13 06:56:23.553251+00', '2026-01-13 06:56:23.553251+00', 'e06a7201-2467-4f43-b656-ad20714ba0db'),
	('d810df06-78c5-441c-8eaf-90e6e505adad', 'd810df06-78c5-441c-8eaf-90e6e505adad', '{"sub": "d810df06-78c5-441c-8eaf-90e6e505adad", "role": "teacher", "email": "ha@gmail.com", "phone": "0123456987", "gender": "female", "full_name": "Hồ Ngọc Hà", "email_verified": false, "phone_verified": false}', 'email', '2026-01-13 07:19:50.394401+00', '2026-01-13 07:19:50.394448+00', '2026-01-13 07:19:50.394448+00', 'b0045dbd-5125-485c-a11e-3a14c44d6c09'),
	('d0fab6ce-74bf-4b57-8299-cd9a5bfdb480', 'd0fab6ce-74bf-4b57-8299-cd9a5bfdb480', '{"sub": "d0fab6ce-74bf-4b57-8299-cd9a5bfdb480", "role": "student", "email": "1234@gmail.com", "phone": "0986658863", "gender": "male", "full_name": "Khánh Toàn", "email_verified": false, "phone_verified": false}', 'email', '2026-02-04 09:08:42.349542+00', '2026-02-04 09:08:42.349593+00', '2026-02-04 09:08:42.349593+00', 'db261ba9-6b9a-4cf8-8a7b-2a38413cc512'),
	('a874ce65-1214-42b0-86b6-20ed5a36a49f', 'a874ce65-1214-42b0-86b6-20ed5a36a49f', '{"sub": "a874ce65-1214-42b0-86b6-20ed5a36a49f", "role": "admin", "email": "a@gmail.com", "phone": "0900900990", "gender": "male", "full_name": "A", "email_verified": false, "phone_verified": false}', 'email', '2026-02-04 09:13:56.447605+00', '2026-02-04 09:13:56.447669+00', '2026-02-04 09:13:56.447669+00', '890a504e-53b7-4d48-8801-3fbb2df47ffe'),
	('6af4527c-8caa-4903-bb50-dbadcf1778d4', '6af4527c-8caa-4903-bb50-dbadcf1778d4', '{"sub": "6af4527c-8caa-4903-bb50-dbadcf1778d4", "role": "teacher", "email": "b@gmail.com", "phone": "0900900090", "gender": "male", "full_name": "B", "email_verified": false, "phone_verified": false}', 'email', '2026-02-04 09:14:49.812206+00', '2026-02-04 09:14:49.812266+00', '2026-02-04 09:14:49.812266+00', '71573e44-9a88-45c5-8ee0-264a3587fc7e'),
	('dcb2cce8-f8d5-440f-ae53-1e39a260254b', 'dcb2cce8-f8d5-440f-ae53-1e39a260254b', '{"sub": "dcb2cce8-f8d5-440f-ae53-1e39a260254b", "role": "teacher", "email": "tranthang592004@gmail.com", "phone": "0855363050", "gender": "male", "full_name": "Trần Văn Thắng", "email_verified": false, "phone_verified": false}', 'email', '2026-02-05 00:56:34.611909+00', '2026-02-05 00:56:34.611975+00', '2026-02-05 00:56:34.611975+00', 'b22d422d-8f09-496e-9657-953c807e954f');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag", "oauth_client_id", "refresh_token_hmac_key", "refresh_token_counter", "scopes") VALUES
	('68245cf2-cc66-4ac8-894d-a27306fa5df9', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', '2025-12-15 14:15:32.375783+00', '2025-12-15 14:15:32.375783+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.159.81', NULL, NULL, NULL, NULL, NULL),
	('6b5274c2-b2a8-4835-9307-a324a515ff15', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', '2025-12-15 14:15:57.476227+00', '2025-12-15 14:15:57.476227+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.159.81', NULL, NULL, NULL, NULL, NULL),
	('34ad029b-b729-474d-bf7a-bd0c1358b5b2', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', '2025-12-15 14:29:57.580651+00', '2025-12-15 14:29:57.580651+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.159.81', NULL, NULL, NULL, NULL, NULL),
	('ce5140bd-1874-41a0-9c46-fdee57da483d', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', '2025-12-15 15:20:21.016901+00', '2025-12-15 15:20:21.016901+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.159.81', NULL, NULL, NULL, NULL, NULL),
	('fe22d0e0-1677-4f1a-91b0-6ce0cd10411d', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', '2025-12-15 15:23:57.16153+00', '2025-12-15 15:23:57.16153+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.159.81', NULL, NULL, NULL, NULL, NULL),
	('fbf7b07d-5e4b-4add-92dd-14d2121af132', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', '2025-12-15 15:37:04.587383+00', '2025-12-15 15:37:04.587383+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.159.81', NULL, NULL, NULL, NULL, NULL),
	('85b7686e-1398-46fe-b57f-b5d9ec5997fe', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', '2025-12-15 15:47:04.420291+00', '2025-12-15 15:47:04.420291+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.159.81', NULL, NULL, NULL, NULL, NULL),
	('cc1849a6-fc4e-4b57-b45a-077d320f62da', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', '2025-12-15 15:52:17.969404+00', '2025-12-15 15:52:17.969404+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.159.81', NULL, NULL, NULL, NULL, NULL),
	('37944144-4453-42b8-8a90-e67cc419b165', '076de02d-75ba-4e79-898d-1b5e43141894', '2025-12-15 16:05:47.362463+00', '2025-12-15 16:05:47.362463+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.159.81', NULL, NULL, NULL, NULL, NULL),
	('838651a2-694e-4b47-a292-d7e576ecc189', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', '2025-12-15 17:33:32.614188+00', '2025-12-15 17:33:32.614188+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.159.81', NULL, NULL, NULL, NULL, NULL),
	('aec90884-b99f-4660-8358-71bccf493ab6', '076de02d-75ba-4e79-898d-1b5e43141894', '2025-12-15 17:34:11.802552+00', '2025-12-17 14:35:31.212523+00', NULL, 'aal1', NULL, '2025-12-17 14:35:31.212409', 'Dart/3.8 (dart:io)', '125.212.158.192', NULL, NULL, NULL, NULL, NULL),
	('a8662d24-c560-4f88-9d86-be6820d55fac', '61d5066a-4827-44bd-a05c-43f2d62c3213', '2025-12-28 16:42:13.839369+00', '2025-12-28 16:42:13.839369+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.204', NULL, NULL, NULL, NULL, NULL),
	('c2714536-48c2-4637-88fc-2f24832d39dd', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', '2025-12-28 16:43:33.775233+00', '2025-12-28 16:43:33.775233+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.204', NULL, NULL, NULL, NULL, NULL),
	('fbd7c042-92b9-4a91-808c-81ce290537ee', '076de02d-75ba-4e79-898d-1b5e43141894', '2025-12-17 14:35:51.040183+00', '2025-12-18 07:02:51.841593+00', NULL, 'aal1', NULL, '2025-12-18 07:02:51.841422', 'Dart/3.8 (dart:io)', '125.212.158.198', NULL, NULL, NULL, NULL, NULL),
	('434a7592-2913-4cca-8c5e-51bc409e3b49', 'd0fab6ce-74bf-4b57-8299-cd9a5bfdb480', '2026-02-04 09:08:42.371606+00', '2026-02-04 09:08:42.371606+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Linux; Android 13; SM-A226B Build/TP1A.220624.014; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.59 Mobile Safari/537.36 [FB_IAB/FB4A;FBAV/546.0.0.35.70;]', '113.175.214.185', NULL, NULL, NULL, NULL, NULL),
	('c626bdd8-5ef3-44ff-ae36-e14ac58da656', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-12 14:56:09.814473+00', '2026-03-14 06:44:44.985604+00', NULL, 'aal1', NULL, '2026-03-14 06:44:44.985494', 'Dart/3.10 (dart:io)', '125.212.159.254', NULL, NULL, NULL, NULL, NULL),
	('8d058ef8-f2b2-4afa-82c8-4f80559fa9fb', '076de02d-75ba-4e79-898d-1b5e43141894', '2025-12-18 07:47:24.472064+00', '2025-12-18 07:47:24.472064+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.198', NULL, NULL, NULL, NULL, NULL),
	('1993a72b-c161-4177-9b71-e4e048c81fab', '076de02d-75ba-4e79-898d-1b5e43141894', '2025-12-18 09:22:20.210653+00', '2025-12-18 09:22:20.210653+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.198', NULL, NULL, NULL, NULL, NULL),
	('6502c96f-b395-4461-be66-c476abb1c743', '076de02d-75ba-4e79-898d-1b5e43141894', '2025-12-28 16:56:34.744529+00', '2025-12-28 16:56:34.744529+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.204', NULL, NULL, NULL, NULL, NULL),
	('94c3fabe-be21-4e7f-8ba3-fd2538d9257e', 'f2e3f942-8f0e-464f-b386-7adcc8e90243', '2025-12-28 17:13:38.754704+00', '2025-12-28 17:13:38.754704+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.204', NULL, NULL, NULL, NULL, NULL),
	('4a78feee-66ff-462f-846b-3b0433b52683', '7d26a7e2-b16b-4c4e-93df-4061076f4786', '2025-12-28 17:53:24.735291+00', '2025-12-28 17:53:24.735291+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.204', NULL, NULL, NULL, NULL, NULL),
	('2973338f-6a4c-47aa-886b-db056b416af2', '076de02d-75ba-4e79-898d-1b5e43141894', '2025-12-18 10:24:32.382544+00', '2025-12-21 23:29:01.963932+00', NULL, 'aal1', NULL, '2025-12-21 23:29:01.963821', 'Dart/3.8 (dart:io)', '125.212.158.198', NULL, NULL, NULL, NULL, NULL),
	('615774c9-5ca1-4f78-b65e-e8e931911841', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-30 13:02:58.616835+00', '2026-01-31 06:39:50.06459+00', NULL, 'aal1', NULL, '2026-01-31 06:39:50.064483', 'Dart/3.10 (dart:io)', '125.212.159.109', NULL, NULL, NULL, NULL, NULL),
	('7401866a-b1d9-4ec5-874b-dcee0b89d60e', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', '2025-12-22 02:49:38.336194+00', '2025-12-22 02:49:38.336194+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.198', NULL, NULL, NULL, NULL, NULL),
	('d8ea0b85-c9c8-4875-ab54-a497a15c5c89', '076de02d-75ba-4e79-898d-1b5e43141894', '2026-01-15 17:31:16.092046+00', '2026-01-15 17:31:16.092046+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.193', NULL, NULL, NULL, NULL, NULL),
	('ee50e5fc-9df6-4e90-a559-97f8ef2f99b7', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-02-08 09:04:14.996763+00', '2026-02-08 09:04:14.996763+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', '125.212.159.109', NULL, NULL, NULL, NULL, NULL),
	('8f6e4989-33bd-4595-8d8f-7f9007edb539', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-30 06:03:51.417984+00', '2026-01-30 11:00:39.793955+00', NULL, 'aal1', NULL, '2026-01-30 11:00:39.793839', 'Dart/3.10 (dart:io)', '125.212.159.169', NULL, NULL, NULL, NULL, NULL),
	('72148ce7-a230-4c86-9925-f7ed5ce81071', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', '2026-01-08 08:37:25.34882+00', '2026-01-08 08:37:25.34882+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '1.53.36.109', NULL, NULL, NULL, NULL, NULL),
	('d72c1dc1-371b-4f12-b62d-4b1eef1a6990', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', '2026-01-09 06:39:52.282121+00', '2026-01-09 06:39:52.282121+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '1.53.36.109', NULL, NULL, NULL, NULL, NULL),
	('c1fa05fa-871f-4ce1-9abe-0e58ed77f977', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', '2026-01-09 08:33:22.32881+00', '2026-01-09 08:33:22.32881+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '1.53.36.109', NULL, NULL, NULL, NULL, NULL),
	('cbc1fef8-5ad0-409d-9f24-c76b44609570', '076de02d-75ba-4e79-898d-1b5e43141894', '2025-12-28 14:37:23.293623+00', '2025-12-28 14:37:23.293623+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.204', NULL, NULL, NULL, NULL, NULL),
	('13a92e41-3de3-45c4-ac1f-46ae6e857667', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-30 11:24:31.676441+00', '2026-01-30 11:24:31.676441+00', NULL, 'aal1', NULL, NULL, 'Dart/3.10 (dart:io)', '125.212.159.169', NULL, NULL, NULL, NULL, NULL),
	('25b28948-71f0-4eb8-942d-02dcac4b0bf4', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', '2025-12-28 14:38:26.131116+00', '2025-12-28 14:38:26.131116+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.204', NULL, NULL, NULL, NULL, NULL),
	('c114414c-7a46-448a-98b2-096679d80907', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-30 11:29:21.255716+00', '2026-01-30 12:28:40.735217+00', NULL, 'aal1', NULL, '2026-01-30 12:28:40.735089', 'Dart/3.10 (dart:io)', '125.212.159.169', NULL, NULL, NULL, NULL, NULL),
	('d01b60c9-5e37-4ebd-81fe-d65e01e309d7', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-30 12:55:40.163816+00', '2026-01-30 12:55:40.163816+00', NULL, 'aal1', NULL, NULL, 'Dart/3.10 (dart:io)', '125.212.159.169', NULL, NULL, NULL, NULL, NULL),
	('9d7e7170-093c-433a-91dc-eab046f73e9f', '076de02d-75ba-4e79-898d-1b5e43141894', '2026-01-16 02:43:58.052927+00', '2026-01-16 02:43:58.052927+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.193', NULL, NULL, NULL, NULL, NULL),
	('e1e0e9c2-68d8-4da6-a72c-cde4f04053e2', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-16 06:15:53.087646+00', '2026-01-16 06:15:53.087646+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '1.53.36.125', NULL, NULL, NULL, NULL, NULL),
	('97bbd1b5-9ff1-4528-90ac-d5bf401a9d1f', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-16 07:29:59.255108+00', '2026-01-16 07:29:59.255108+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '1.53.36.125', NULL, NULL, NULL, NULL, NULL),
	('1d201739-abfe-4fbb-bfce-532eef606a7c', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-31 06:40:28.763259+00', '2026-02-02 14:31:46.564583+00', NULL, 'aal1', NULL, '2026-02-02 14:31:46.564463', 'Dart/3.10 (dart:io)', '125.212.159.109', NULL, NULL, NULL, NULL, NULL),
	('3113ac6d-2eb5-4a65-bc92-6be9c1ad0ce3', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-16 09:25:43.617905+00', '2026-01-16 09:25:43.617905+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '1.53.36.125', NULL, NULL, NULL, NULL, NULL),
	('adc40db6-63ab-4a6f-b897-d1c87817fff8', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-16 10:57:51.375579+00', '2026-01-16 10:57:51.375579+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.193', NULL, NULL, NULL, NULL, NULL),
	('04fbc3bf-df11-4b86-a5b3-9106dd66f409', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', '2026-01-11 07:29:16.075059+00', '2026-01-12 06:17:01.950175+00', NULL, 'aal1', NULL, '2026-01-12 06:17:01.950051', 'Dart/3.8 (dart:io)', '1.53.36.113', NULL, NULL, NULL, NULL, NULL),
	('34006771-097e-4954-bf57-f9a347473ef8', '381068fc-5eef-4350-ae44-1e65dd28d02c', '2026-01-13 06:08:02.533887+00', '2026-01-13 06:08:02.533887+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '1.53.36.123', NULL, NULL, NULL, NULL, NULL),
	('48ab5eaa-2e02-4836-90ff-2018a658d7b2', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-02-04 09:19:00.285557+00', '2026-02-04 09:19:00.285557+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '1.55.112.71', NULL, NULL, NULL, NULL, NULL),
	('798b5d82-f635-4ce3-a0e5-b1daa4f4c4db', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-02-02 15:24:06.396809+00', '2026-02-02 17:23:07.113549+00', NULL, 'aal1', NULL, '2026-02-02 17:23:07.113432', 'Dart/3.10 (dart:io)', '125.212.159.109', NULL, NULL, NULL, NULL, NULL),
	('cfc421e4-ccda-4cfc-b278-1da792018a1f', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-13 07:19:50.408116+00', '2026-01-13 07:19:50.408116+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '1.53.36.123', NULL, NULL, NULL, NULL, NULL),
	('2f8e4efc-daec-48bc-892d-f8b486ed9e23', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-02-02 17:29:26.395618+00', '2026-02-02 17:29:26.395618+00', NULL, 'aal1', NULL, NULL, 'Dart/3.10 (dart:io)', '125.212.159.109', NULL, NULL, NULL, NULL, NULL),
	('1013ee32-6570-47a4-ac1a-546f9d37bb34', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-13 07:31:59.850761+00', '2026-01-13 07:31:59.850761+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '1.53.36.123', NULL, NULL, NULL, NULL, NULL),
	('dc48034c-30dd-4388-8ea1-1d310693b5ff', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-14 07:03:13.654325+00', '2026-01-14 07:03:13.654325+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '1.53.36.143', NULL, NULL, NULL, NULL, NULL),
	('979509e4-07c1-477f-9e2d-463514f5e4f1', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-16 12:19:39.0266+00', '2026-01-16 12:19:39.0266+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.193', NULL, NULL, NULL, NULL, NULL),
	('59a755d5-9be7-43ed-bfa1-d1622ffdf8c1', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-02-04 08:57:48.554931+00', '2026-02-04 08:57:48.554931+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', '125.212.159.109', NULL, NULL, NULL, NULL, NULL),
	('ba79e163-943b-4ca8-a731-42df88aea4d3', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-16 13:32:49.567268+00', '2026-01-16 13:32:49.567268+00', NULL, 'aal1', NULL, NULL, 'Dart/3.8 (dart:io)', '125.212.158.193', NULL, NULL, NULL, NULL, NULL),
	('1df9b35f-ad02-43e2-a2c9-1a555ddfd26f', '076de02d-75ba-4e79-898d-1b5e43141894', '2026-01-15 08:16:51.4674+00', '2026-01-15 13:33:08.738121+00', NULL, 'aal1', NULL, '2026-01-15 13:33:08.738014', 'Dart/3.8 (dart:io)', '125.212.158.193', NULL, NULL, NULL, NULL, NULL),
	('7fb0a314-67a7-4b0e-ad6c-cc9465919c27', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-02-04 09:07:33.256153+00', '2026-02-04 09:07:33.256153+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [FBAN/FBIOS;FBAV/544.0.0.20.406;FBBV/860355073;FBDV/iPhone14,5;FBMD/iPhone;FBSN/iOS;FBSV/26.2;FBSS/3;FBCR/;FBID/phone;FBLC/vi_VN;FBOP/80]', '125.212.159.109', NULL, NULL, NULL, NULL, NULL),
	('35bd30a4-6fdf-4de4-b553-1a14fb06f10b', '076de02d-75ba-4e79-898d-1b5e43141894', '2026-02-04 09:30:44.040085+00', '2026-02-04 09:30:44.040085+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '1.55.112.71', NULL, NULL, NULL, NULL, NULL),
	('de54dbc8-1999-46b5-bea2-cb97ee2fb3d2', 'dcb2cce8-f8d5-440f-ae53-1e39a260254b', '2026-02-05 00:56:34.656038+00', '2026-02-05 00:56:34.656038+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', '118.70.211.226', NULL, NULL, NULL, NULL, NULL),
	('ec726e01-c176-460e-8825-b59ebe67950b', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-01-17 17:39:17.571961+00', '2026-01-21 17:13:00.172475+00', NULL, 'aal1', NULL, '2026-01-21 17:13:00.172367', 'Dart/3.10 (dart:io)', '125.212.159.173', NULL, NULL, NULL, NULL, NULL),
	('f63f1a27-ca90-4019-8ae3-860bd443195d', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-02-04 09:28:25.66598+00', '2026-02-10 15:51:46.232494+00', NULL, 'aal1', NULL, '2026-02-10 15:51:46.232372', 'Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.85 Mobile/15E148 Safari/604.1', '125.212.159.109', NULL, NULL, NULL, NULL, NULL),
	('46dcac61-0e4f-45ec-9df8-4b0801258376', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-02-22 14:54:31.96755+00', '2026-02-22 14:54:31.96755+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '125.212.158.228', NULL, NULL, NULL, NULL, NULL),
	('d60cf930-359a-404b-9b4d-06af5d42df98', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-02-23 06:52:48.201808+00', '2026-02-23 08:51:29.082015+00', NULL, 'aal1', NULL, '2026-02-23 08:51:29.081903', 'Dart/3.10 (dart:io)', '125.212.158.228', NULL, NULL, NULL, NULL, NULL),
	('25bab203-e1fb-497d-a956-8804c90a9ed7', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 06:58:16.902013+00', '2026-03-24 06:58:16.902013+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('9f203448-7690-4996-95c2-beaa461f04fc', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-13 09:18:23.256109+00', '2026-03-13 09:18:23.256109+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36', '125.212.159.254', NULL, NULL, NULL, NULL, NULL),
	('822f63f4-2b88-401a-a7cd-344f5729a5f8', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-13 09:22:50.755217+00', '2026-03-13 09:22:50.755217+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '125.212.159.254', NULL, NULL, NULL, NULL, NULL),
	('0f9439d1-2ec4-493a-b8c1-0ae2fc9748ca', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-13 09:25:06.720479+00', '2026-03-13 09:25:06.720479+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '125.212.159.254', NULL, NULL, NULL, NULL, NULL),
	('ebf567f5-14af-4b48-bba5-6d62ea2b99b8', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-13 09:32:32.721499+00', '2026-03-13 09:32:32.721499+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '125.212.159.254', NULL, NULL, NULL, NULL, NULL),
	('770ed888-5428-49ea-94ce-0c4721e0d917', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-23 09:43:00.698753+00', '2026-03-23 10:42:15.439358+00', NULL, 'aal1', NULL, '2026-03-23 10:42:15.438356', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Mobile Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('e27ca323-e179-49cb-93ea-24a940e4c841', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 06:59:37.329773+00', '2026-03-24 08:57:51.367723+00', NULL, 'aal1', NULL, '2026-03-24 08:57:51.367617', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Mobile Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('7151f149-ccdc-4a7f-a48e-4d69b27749cc', '076de02d-75ba-4e79-898d-1b5e43141894', '2026-03-25 15:15:25.144962+00', '2026-03-31 04:51:23.488412+00', NULL, 'aal1', NULL, '2026-03-31 04:51:23.488302', 'Dart/3.10 (dart:io)', '125.212.158.166', NULL, NULL, NULL, NULL, NULL),
	('2b4696fe-ae55-4e9f-9aa9-8cd7ebed9e6f', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 09:21:28.14429+00', '2026-03-24 09:21:28.14429+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('bb32d1fe-95ad-422d-8db5-027f027127b7', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 09:22:14.97445+00', '2026-03-24 09:22:14.97445+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('64a3cea7-9bba-4219-9de4-41151c67a6bc', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 09:28:19.96358+00', '2026-03-24 09:28:19.96358+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('00a68c0c-f06e-43d1-82f0-32803d3b3865', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 10:12:12.301207+00', '2026-03-24 16:07:09.317924+00', NULL, 'aal1', NULL, '2026-03-24 16:07:09.317816', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Mobile Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('59c441e4-7d72-453a-9fb3-d551954a1ab9', '076de02d-75ba-4e79-898d-1b5e43141894', '2026-03-21 13:14:12.784252+00', '2026-03-22 06:36:33.372704+00', NULL, 'aal1', NULL, '2026-03-22 06:36:33.37259', 'Dart/3.10 (dart:io)', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('31614f50-2cf5-4736-9b35-ec3a30a265ef', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-23 09:44:02.283311+00', '2026-03-23 15:38:57.289718+00', NULL, 'aal1', NULL, '2026-03-23 15:38:57.289609', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('fb34b4f8-0ac5-4445-bbd5-b690c448278b', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 05:15:41.227174+00', '2026-03-24 05:15:41.227174+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('dabda595-bce4-451f-8f23-81da41c6bea5', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-22 13:00:59.03403+00', '2026-03-22 13:00:59.03403+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('c1d5bbf3-d4b5-4710-9975-1ef6684a47ed', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 09:29:51.373485+00', '2026-03-24 09:29:51.373485+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('af434ff6-3997-4264-a07b-1651f83b76fa', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-05 12:01:21.305463+00', '2026-03-05 12:01:21.305463+00', NULL, 'aal1', NULL, NULL, 'Dart/3.10 (dart:io)', '125.212.158.228', NULL, NULL, NULL, NULL, NULL),
	('43bbab87-fdf4-4e88-8c56-06759f0bf1a0', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 05:37:46.452987+00', '2026-03-24 05:37:46.452987+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Mobile Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('6ec5ae1c-a98e-4dd9-b9c3-85e1ed900592', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 09:34:12.94548+00', '2026-03-24 09:34:12.94548+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('e1b85708-b1d6-4e97-b0d8-05c4678b2ca8', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 06:37:11.128444+00', '2026-03-24 06:37:11.128444+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Mobile Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('a6d4c447-bcbc-4fc6-9b58-e665c5806aa5', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 06:45:31.734132+00', '2026-03-24 06:45:31.734132+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('e4094b32-9a10-432f-9298-86d584731aa0', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 09:34:52.554329+00', '2026-03-24 09:34:52.554329+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '125.212.158.167', NULL, NULL, NULL, NULL, NULL),
	('9b0309bb-833f-42e6-9310-f466b48b75c3', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-08 10:09:05.290508+00', '2026-03-25 04:55:18.145546+00', NULL, 'aal1', NULL, '2026-03-25 04:55:18.144811', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '125.212.158.167', NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('68245cf2-cc66-4ac8-894d-a27306fa5df9', '2025-12-15 14:15:32.432979+00', '2025-12-15 14:15:32.432979+00', 'password', '20b19f57-67c7-424d-80ff-73c4ad81d131'),
	('6b5274c2-b2a8-4835-9307-a324a515ff15', '2025-12-15 14:15:57.480432+00', '2025-12-15 14:15:57.480432+00', 'password', '36af4445-7e4f-4f54-a176-a20fd4e2c259'),
	('34ad029b-b729-474d-bf7a-bd0c1358b5b2', '2025-12-15 14:29:57.608063+00', '2025-12-15 14:29:57.608063+00', 'password', '58c9284e-5a98-44ad-b62f-9334f9752ac9'),
	('ce5140bd-1874-41a0-9c46-fdee57da483d', '2025-12-15 15:20:21.118869+00', '2025-12-15 15:20:21.118869+00', 'password', '766cca25-5611-4027-a52b-78a3d5d33ea1'),
	('fe22d0e0-1677-4f1a-91b0-6ce0cd10411d', '2025-12-15 15:23:57.21532+00', '2025-12-15 15:23:57.21532+00', 'password', '6e393d5d-75f0-4b0c-8f9e-937e16c6a6a4'),
	('fbf7b07d-5e4b-4add-92dd-14d2121af132', '2025-12-15 15:37:04.615355+00', '2025-12-15 15:37:04.615355+00', 'password', '7e3b122a-57c7-4823-a81f-ebbd24f938fb'),
	('85b7686e-1398-46fe-b57f-b5d9ec5997fe', '2025-12-15 15:47:04.455632+00', '2025-12-15 15:47:04.455632+00', 'password', 'd8fe4b79-62e9-4adf-b7aa-257c9c162bd4'),
	('cc1849a6-fc4e-4b57-b45a-077d320f62da', '2025-12-15 15:52:17.980125+00', '2025-12-15 15:52:17.980125+00', 'password', 'dce3cc25-1321-490c-8b81-b4ece7815075'),
	('37944144-4453-42b8-8a90-e67cc419b165', '2025-12-15 16:05:47.390549+00', '2025-12-15 16:05:47.390549+00', 'password', '7a488637-1293-4cf2-a8e7-28d8d5e02a6b'),
	('838651a2-694e-4b47-a292-d7e576ecc189', '2025-12-15 17:33:32.710281+00', '2025-12-15 17:33:32.710281+00', 'password', '47702da8-bbdb-4a8d-bdec-78e24fb70bcd'),
	('aec90884-b99f-4660-8358-71bccf493ab6', '2025-12-15 17:34:11.809968+00', '2025-12-15 17:34:11.809968+00', 'password', '4acf1c11-a629-4621-9174-9223f31ad997'),
	('fbd7c042-92b9-4a91-808c-81ce290537ee', '2025-12-17 14:35:51.055344+00', '2025-12-17 14:35:51.055344+00', 'password', '3d9bc756-ff19-4379-b0f3-8984e0e77eec'),
	('13a92e41-3de3-45c4-ac1f-46ae6e857667', '2026-01-30 11:24:31.739008+00', '2026-01-30 11:24:31.739008+00', 'password', 'aabf8aff-d15d-43c6-b3a8-98f9c4085ca6'),
	('c114414c-7a46-448a-98b2-096679d80907', '2026-01-30 11:29:21.265446+00', '2026-01-30 11:29:21.265446+00', 'password', '5ca52f23-8d7d-49fa-ae11-5a395e624ec6'),
	('d01b60c9-5e37-4ebd-81fe-d65e01e309d7', '2026-01-30 12:55:40.195032+00', '2026-01-30 12:55:40.195032+00', 'password', '2dd9bf3e-9ba7-4900-94db-f4cb9be34358'),
	('615774c9-5ca1-4f78-b65e-e8e931911841', '2026-01-30 13:02:58.689696+00', '2026-01-30 13:02:58.689696+00', 'password', '925d7199-c480-4b80-9abd-964cab9dad40'),
	('1d201739-abfe-4fbb-bfce-532eef606a7c', '2026-01-31 06:40:28.780196+00', '2026-01-31 06:40:28.780196+00', 'password', 'ecb9e9ed-9e6b-458a-b504-f385beddb112'),
	('798b5d82-f635-4ce3-a0e5-b1daa4f4c4db', '2026-02-02 15:24:06.478407+00', '2026-02-02 15:24:06.478407+00', 'password', '6951307c-063c-4019-aafb-691571cb268f'),
	('8d058ef8-f2b2-4afa-82c8-4f80559fa9fb', '2025-12-18 07:47:24.477509+00', '2025-12-18 07:47:24.477509+00', 'password', '486d8d22-ee70-49a4-b255-3eb4b50378d3'),
	('1993a72b-c161-4177-9b71-e4e048c81fab', '2025-12-18 09:22:20.275064+00', '2025-12-18 09:22:20.275064+00', 'password', '29793238-0ffa-48f1-a32a-98ca94dd601a'),
	('2973338f-6a4c-47aa-886b-db056b416af2', '2025-12-18 10:24:32.453311+00', '2025-12-18 10:24:32.453311+00', 'password', 'f448049b-1cfe-44e9-af62-756fb4a855fa'),
	('2f8e4efc-daec-48bc-892d-f8b486ed9e23', '2026-02-02 17:29:26.414448+00', '2026-02-02 17:29:26.414448+00', 'password', '64b5e95a-88d5-44ff-b0ef-46669b938904'),
	('59a755d5-9be7-43ed-bfa1-d1622ffdf8c1', '2026-02-04 08:57:48.663569+00', '2026-02-04 08:57:48.663569+00', 'password', 'cb9bb40d-e56c-44a6-a302-7729aa2aa806'),
	('7fb0a314-67a7-4b0e-ad6c-cc9465919c27', '2026-02-04 09:07:33.281532+00', '2026-02-04 09:07:33.281532+00', 'password', '42670e5b-43f7-42d8-b68a-0dadc50de81e'),
	('434a7592-2913-4cca-8c5e-51bc409e3b49', '2026-02-04 09:08:42.374836+00', '2026-02-04 09:08:42.374836+00', 'password', '48541681-f719-4d0f-bf42-70f4fa57d8f3'),
	('7401866a-b1d9-4ec5-874b-dcee0b89d60e', '2025-12-22 02:49:38.338444+00', '2025-12-22 02:49:38.338444+00', 'password', 'aca107ed-4e20-4df4-9de7-131df587d7bf'),
	('48ab5eaa-2e02-4836-90ff-2018a658d7b2', '2026-02-04 09:19:00.292935+00', '2026-02-04 09:19:00.292935+00', 'password', '5f8212d9-f047-4f41-a054-1e3fdcaff554'),
	('cbc1fef8-5ad0-409d-9f24-c76b44609570', '2025-12-28 14:37:23.353725+00', '2025-12-28 14:37:23.353725+00', 'password', '78e0c444-75eb-4b07-a7cc-dd4ae6871303'),
	('f63f1a27-ca90-4019-8ae3-860bd443195d', '2026-02-04 09:28:25.681934+00', '2026-02-04 09:28:25.681934+00', 'password', '63f61dd7-24d4-4631-a18a-5c077c093d10'),
	('25b28948-71f0-4eb8-942d-02dcac4b0bf4', '2025-12-28 14:38:26.133704+00', '2025-12-28 14:38:26.133704+00', 'password', 'd08d55c5-8da4-4fcb-88f1-99b6981eebc2'),
	('35bd30a4-6fdf-4de4-b553-1a14fb06f10b', '2026-02-04 09:30:44.044729+00', '2026-02-04 09:30:44.044729+00', 'password', '8168ab86-d8ca-4243-9e08-2793c7bd7bee'),
	('de54dbc8-1999-46b5-bea2-cb97ee2fb3d2', '2026-02-05 00:56:34.719392+00', '2026-02-05 00:56:34.719392+00', 'password', '4815138a-1967-4566-ada3-9c4f07e3d6ab'),
	('a8662d24-c560-4f88-9d86-be6820d55fac', '2025-12-28 16:42:13.842673+00', '2025-12-28 16:42:13.842673+00', 'password', '7df9ec44-282d-413f-b9c5-936212df4582'),
	('c2714536-48c2-4637-88fc-2f24832d39dd', '2025-12-28 16:43:33.77975+00', '2025-12-28 16:43:33.77975+00', 'password', 'f9328172-401a-47fe-943d-c967399c8ffa'),
	('ee50e5fc-9df6-4e90-a559-97f8ef2f99b7', '2026-02-08 09:04:15.103566+00', '2026-02-08 09:04:15.103566+00', 'password', '5ccf14ed-d247-4d63-b1ac-54d97e47fe03'),
	('6502c96f-b395-4461-be66-c476abb1c743', '2025-12-28 16:56:34.781028+00', '2025-12-28 16:56:34.781028+00', 'password', '4d67bb89-063b-4c98-af16-20bb422e8335'),
	('46dcac61-0e4f-45ec-9df8-4b0801258376', '2026-02-22 14:54:32.052604+00', '2026-02-22 14:54:32.052604+00', 'password', 'f1b8e889-8775-4fd9-bacc-14f7bd2de007'),
	('94c3fabe-be21-4e7f-8ba3-fd2538d9257e', '2025-12-28 17:13:38.793946+00', '2025-12-28 17:13:38.793946+00', 'password', '99bbec90-4ccd-46d7-b8bf-7eb34c586184'),
	('d60cf930-359a-404b-9b4d-06af5d42df98', '2026-02-23 06:52:48.299562+00', '2026-02-23 06:52:48.299562+00', 'password', '8a0e3da5-e592-45b0-9175-d86c2505b20d'),
	('4a78feee-66ff-462f-846b-3b0433b52683', '2025-12-28 17:53:24.767872+00', '2025-12-28 17:53:24.767872+00', 'password', '0273bb0e-4016-47fd-b0ad-9b5fa8701001'),
	('af434ff6-3997-4264-a07b-1651f83b76fa', '2026-03-05 12:01:21.325601+00', '2026-03-05 12:01:21.325601+00', 'password', '10077fdc-f9da-4da0-9e29-96fc6f552d60'),
	('72148ce7-a230-4c86-9925-f7ed5ce81071', '2026-01-08 08:37:25.379985+00', '2026-01-08 08:37:25.379985+00', 'password', '17d18df1-8b70-49c2-816a-82e6a4cb2e48'),
	('d72c1dc1-371b-4f12-b62d-4b1eef1a6990', '2026-01-09 06:39:52.390007+00', '2026-01-09 06:39:52.390007+00', 'password', 'ceba4d07-5a61-4757-ad9b-676025aab1df'),
	('c1fa05fa-871f-4ce1-9abe-0e58ed77f977', '2026-01-09 08:33:22.388895+00', '2026-01-09 08:33:22.388895+00', 'password', '9fdb6b9a-3464-414e-b9a0-9a166fd0697f'),
	('04fbc3bf-df11-4b86-a5b3-9106dd66f409', '2026-01-11 07:29:16.179476+00', '2026-01-11 07:29:16.179476+00', 'password', '32b819a0-4dbf-42d2-9ad7-4d955106fa4b'),
	('34006771-097e-4954-bf57-f9a347473ef8', '2026-01-13 06:08:02.602561+00', '2026-01-13 06:08:02.602561+00', 'password', 'd76f6354-38be-4972-9ea4-5ad835bcc3c6'),
	('cfc421e4-ccda-4cfc-b278-1da792018a1f', '2026-01-13 07:19:50.427847+00', '2026-01-13 07:19:50.427847+00', 'password', '8745cb64-8dcc-40e4-8682-7f0e274638ac'),
	('1013ee32-6570-47a4-ac1a-546f9d37bb34', '2026-01-13 07:31:59.894567+00', '2026-01-13 07:31:59.894567+00', 'password', '3909d939-68d3-419a-9c9c-94078ebe2770'),
	('dc48034c-30dd-4388-8ea1-1d310693b5ff', '2026-01-14 07:03:13.764397+00', '2026-01-14 07:03:13.764397+00', 'password', '6b8d3a86-937a-46bf-92ef-0928fb7a83c0'),
	('9b0309bb-833f-42e6-9310-f466b48b75c3', '2026-03-08 10:09:05.334783+00', '2026-03-08 10:09:05.334783+00', 'password', '6515e443-b133-44f6-bd41-2e830a644a9f'),
	('1df9b35f-ad02-43e2-a2c9-1a555ddfd26f', '2026-01-15 08:16:51.472824+00', '2026-01-15 08:16:51.472824+00', 'password', '0bf6ca95-59dc-445c-b1a6-43030e578cb9'),
	('d8ea0b85-c9c8-4875-ab54-a497a15c5c89', '2026-01-15 17:31:16.188725+00', '2026-01-15 17:31:16.188725+00', 'password', 'd66c3fed-2410-43b2-9037-b54bbe2da893'),
	('9d7e7170-093c-433a-91dc-eab046f73e9f', '2026-01-16 02:43:58.059245+00', '2026-01-16 02:43:58.059245+00', 'password', '2dde4791-3f9e-4fcb-a599-cc3ad662705e'),
	('e1e0e9c2-68d8-4da6-a72c-cde4f04053e2', '2026-01-16 06:15:53.155303+00', '2026-01-16 06:15:53.155303+00', 'password', '4f137e80-f13f-4af1-bc40-83ea6e951959'),
	('97bbd1b5-9ff1-4528-90ac-d5bf401a9d1f', '2026-01-16 07:29:59.316207+00', '2026-01-16 07:29:59.316207+00', 'password', '4f4b9394-3b72-4f49-b48e-690c7dddc10b'),
	('3113ac6d-2eb5-4a65-bc92-6be9c1ad0ce3', '2026-01-16 09:25:43.620982+00', '2026-01-16 09:25:43.620982+00', 'password', 'fd4b5f44-7d60-4ec9-aedf-0799aef0f737'),
	('adc40db6-63ab-4a6f-b897-d1c87817fff8', '2026-01-16 10:57:51.455564+00', '2026-01-16 10:57:51.455564+00', 'password', '4ba5d57f-ad9a-423e-aa31-d0f8f720d6a1'),
	('979509e4-07c1-477f-9e2d-463514f5e4f1', '2026-01-16 12:19:39.105493+00', '2026-01-16 12:19:39.105493+00', 'password', 'fb69b601-ff11-489a-b424-5606edf0ba9a'),
	('ba79e163-943b-4ca8-a731-42df88aea4d3', '2026-01-16 13:32:49.644635+00', '2026-01-16 13:32:49.644635+00', 'password', 'be2c8cb4-6488-42b7-aba9-e9e548a51001'),
	('ec726e01-c176-460e-8825-b59ebe67950b', '2026-01-17 17:39:17.66801+00', '2026-01-17 17:39:17.66801+00', 'password', 'ad0c4a79-26ed-4496-9d95-7c30429d27d4'),
	('c626bdd8-5ef3-44ff-ae36-e14ac58da656', '2026-03-12 14:56:09.829712+00', '2026-03-12 14:56:09.829712+00', 'password', 'fe9e6143-026c-4398-9dc5-ac44f31cf104'),
	('9f203448-7690-4996-95c2-beaa461f04fc', '2026-03-13 09:18:23.342072+00', '2026-03-13 09:18:23.342072+00', 'password', 'e87eb956-8e34-426d-90d4-2ddecae7712c'),
	('822f63f4-2b88-401a-a7cd-344f5729a5f8', '2026-03-13 09:22:50.785083+00', '2026-03-13 09:22:50.785083+00', 'password', 'd960202e-d5a0-435a-b8bc-d4c1442df3da'),
	('0f9439d1-2ec4-493a-b8c1-0ae2fc9748ca', '2026-03-13 09:25:06.726176+00', '2026-03-13 09:25:06.726176+00', 'password', '10a58606-ab87-4e58-baad-081ff94990cf'),
	('ebf567f5-14af-4b48-bba5-6d62ea2b99b8', '2026-03-13 09:32:32.776562+00', '2026-03-13 09:32:32.776562+00', 'password', '963a620d-86e6-4d56-994b-fd52c604a2b9'),
	('8f6e4989-33bd-4595-8d8f-7f9007edb539', '2026-01-30 06:03:51.436013+00', '2026-01-30 06:03:51.436013+00', 'password', '3394d6a7-73eb-4c01-ba15-7c4fc7d6d8f5'),
	('59c441e4-7d72-453a-9fb3-d551954a1ab9', '2026-03-21 13:14:12.799536+00', '2026-03-21 13:14:12.799536+00', 'password', '681ba9b5-7987-499f-8188-9890f3576232'),
	('dabda595-bce4-451f-8f23-81da41c6bea5', '2026-03-22 13:00:59.107633+00', '2026-03-22 13:00:59.107633+00', 'password', '4fe7a3ae-c658-4931-a17e-4f609005d445'),
	('770ed888-5428-49ea-94ce-0c4721e0d917', '2026-03-23 09:43:00.75943+00', '2026-03-23 09:43:00.75943+00', 'password', '82de82cf-8f75-4988-b25d-cb99b8a612f7'),
	('31614f50-2cf5-4736-9b35-ec3a30a265ef', '2026-03-23 09:44:02.288525+00', '2026-03-23 09:44:02.288525+00', 'password', '6085567e-d759-4e72-9dc5-3c9d8ac80de3'),
	('fb34b4f8-0ac5-4445-bbd5-b690c448278b', '2026-03-24 05:15:41.340293+00', '2026-03-24 05:15:41.340293+00', 'password', '767eb25f-463c-4bde-b040-32957e022d31'),
	('43bbab87-fdf4-4e88-8c56-06759f0bf1a0', '2026-03-24 05:37:46.472438+00', '2026-03-24 05:37:46.472438+00', 'password', 'b8432f4b-2fc2-4d99-8c01-6abb172e0dce'),
	('e1b85708-b1d6-4e97-b0d8-05c4678b2ca8', '2026-03-24 06:37:11.154252+00', '2026-03-24 06:37:11.154252+00', 'password', '98298885-f4a4-49bf-ba11-bf32f4681601'),
	('a6d4c447-bcbc-4fc6-9b58-e665c5806aa5', '2026-03-24 06:45:31.776754+00', '2026-03-24 06:45:31.776754+00', 'password', 'ee795bf7-f246-49c6-9289-b1e3af2ae861'),
	('25bab203-e1fb-497d-a956-8804c90a9ed7', '2026-03-24 06:58:16.940081+00', '2026-03-24 06:58:16.940081+00', 'password', 'eb589300-072d-4c1e-9da7-32e91c6dcbb8'),
	('e27ca323-e179-49cb-93ea-24a940e4c841', '2026-03-24 06:59:37.34288+00', '2026-03-24 06:59:37.34288+00', 'password', '9751d4b9-5d33-4342-b73c-0d40d2e9f54d'),
	('2b4696fe-ae55-4e9f-9aa9-8cd7ebed9e6f', '2026-03-24 09:21:28.1867+00', '2026-03-24 09:21:28.1867+00', 'password', 'b606dbff-146d-47d4-8476-ccadff13bc04'),
	('bb32d1fe-95ad-422d-8db5-027f027127b7', '2026-03-24 09:22:15.046605+00', '2026-03-24 09:22:15.046605+00', 'password', 'c098a534-413e-4467-baf4-cf152b3ed72c'),
	('64a3cea7-9bba-4219-9de4-41151c67a6bc', '2026-03-24 09:28:19.994909+00', '2026-03-24 09:28:19.994909+00', 'password', 'a44c73f2-7026-48a1-a6c6-86d000118d5c'),
	('c1d5bbf3-d4b5-4710-9975-1ef6684a47ed', '2026-03-24 09:29:51.385602+00', '2026-03-24 09:29:51.385602+00', 'password', 'cb75e12d-6b75-4f8d-bff8-1bf16efc5770'),
	('6ec5ae1c-a98e-4dd9-b9c3-85e1ed900592', '2026-03-24 09:34:12.984969+00', '2026-03-24 09:34:12.984969+00', 'password', '98afb729-d4b4-4a3b-b43e-fac7b74a204a'),
	('e4094b32-9a10-432f-9298-86d584731aa0', '2026-03-24 09:34:52.557677+00', '2026-03-24 09:34:52.557677+00', 'password', '7568a21e-01a6-4488-9684-400b203971fd'),
	('00a68c0c-f06e-43d1-82f0-32803d3b3865', '2026-03-24 10:12:12.366637+00', '2026-03-24 10:12:12.366637+00', 'password', 'f5ed0408-4507-4e97-a772-e7be4e47caed'),
	('7151f149-ccdc-4a7f-a48e-4d69b27749cc', '2026-03-25 15:15:25.188839+00', '2026-03-25 15:15:25.188839+00', 'password', 'a6fd1ec0-d00f-41b7-acb8-8f6e82c4d4d9');


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 1, 'zv7i5qc23hp3', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', false, '2025-12-15 14:15:32.408696+00', '2025-12-15 14:15:32.408696+00', NULL, '68245cf2-cc66-4ac8-894d-a27306fa5df9'),
	('00000000-0000-0000-0000-000000000000', 2, 'ce7vpyate36x', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', false, '2025-12-15 14:15:57.477924+00', '2025-12-15 14:15:57.477924+00', NULL, '6b5274c2-b2a8-4835-9307-a324a515ff15'),
	('00000000-0000-0000-0000-000000000000', 3, 'szehf6o42nxh', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', false, '2025-12-15 14:29:57.596507+00', '2025-12-15 14:29:57.596507+00', NULL, '34ad029b-b729-474d-bf7a-bd0c1358b5b2'),
	('00000000-0000-0000-0000-000000000000', 4, '3fjurepw63wf', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', false, '2025-12-15 15:20:21.076502+00', '2025-12-15 15:20:21.076502+00', NULL, 'ce5140bd-1874-41a0-9c46-fdee57da483d'),
	('00000000-0000-0000-0000-000000000000', 5, 'uejuawfdjgik', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', false, '2025-12-15 15:23:57.18962+00', '2025-12-15 15:23:57.18962+00', NULL, 'fe22d0e0-1677-4f1a-91b0-6ce0cd10411d'),
	('00000000-0000-0000-0000-000000000000', 6, '3ueaddftwjwa', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', false, '2025-12-15 15:37:04.607033+00', '2025-12-15 15:37:04.607033+00', NULL, 'fbf7b07d-5e4b-4add-92dd-14d2121af132'),
	('00000000-0000-0000-0000-000000000000', 7, 'e2hmfcbqfojv', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', false, '2025-12-15 15:47:04.437514+00', '2025-12-15 15:47:04.437514+00', NULL, '85b7686e-1398-46fe-b57f-b5d9ec5997fe'),
	('00000000-0000-0000-0000-000000000000', 8, 'qn7i6lyrzsof', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', false, '2025-12-15 15:52:17.977398+00', '2025-12-15 15:52:17.977398+00', NULL, 'cc1849a6-fc4e-4b57-b45a-077d320f62da'),
	('00000000-0000-0000-0000-000000000000', 9, '73jwiddgo6ij', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2025-12-15 16:05:47.377441+00', '2025-12-15 16:05:47.377441+00', NULL, '37944144-4453-42b8-8a90-e67cc419b165'),
	('00000000-0000-0000-0000-000000000000', 10, 'j7vo6kxq57ax', 'af06a4fd-9e7f-411d-b801-4b6aca63fca1', false, '2025-12-15 17:33:32.667602+00', '2025-12-15 17:33:32.667602+00', NULL, '838651a2-694e-4b47-a292-d7e576ecc189'),
	('00000000-0000-0000-0000-000000000000', 11, 'lzjxk2jkndex', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-15 17:34:11.806179+00', '2025-12-17 14:35:31.168885+00', NULL, 'aec90884-b99f-4660-8358-71bccf493ab6'),
	('00000000-0000-0000-0000-000000000000', 12, 'ncl7d6oprwny', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2025-12-17 14:35:31.192692+00', '2025-12-17 14:35:31.192692+00', 'lzjxk2jkndex', 'aec90884-b99f-4660-8358-71bccf493ab6'),
	('00000000-0000-0000-0000-000000000000', 13, 'iepdgoise5bq', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-17 14:35:51.053281+00', '2025-12-17 15:35:19.51886+00', NULL, 'fbd7c042-92b9-4a91-808c-81ce290537ee'),
	('00000000-0000-0000-0000-000000000000', 74, 'mskgf5fynssn', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', false, '2026-01-08 08:37:25.370145+00', '2026-01-08 08:37:25.370145+00', NULL, '72148ce7-a230-4c86-9925-f7ed5ce81071'),
	('00000000-0000-0000-0000-000000000000', 14, 'yu2yp4sge6u3', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-17 15:35:19.545309+00', '2025-12-17 16:34:49.516572+00', 'iepdgoise5bq', 'fbd7c042-92b9-4a91-808c-81ce290537ee'),
	('00000000-0000-0000-0000-000000000000', 75, 'znl42ihily25', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', false, '2026-01-09 06:39:52.337606+00', '2026-01-09 06:39:52.337606+00', NULL, 'd72c1dc1-371b-4f12-b62d-4b1eef1a6990'),
	('00000000-0000-0000-0000-000000000000', 15, 'knp6ga3xepqu', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-17 16:34:49.529585+00', '2025-12-18 07:02:51.795662+00', 'yu2yp4sge6u3', 'fbd7c042-92b9-4a91-808c-81ce290537ee'),
	('00000000-0000-0000-0000-000000000000', 16, 'iikeerawlvlz', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2025-12-18 07:02:51.817218+00', '2025-12-18 07:02:51.817218+00', 'knp6ga3xepqu', 'fbd7c042-92b9-4a91-808c-81ce290537ee'),
	('00000000-0000-0000-0000-000000000000', 76, 'fvmzxkst7gg4', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', false, '2026-01-09 08:33:22.36104+00', '2026-01-09 08:33:22.36104+00', NULL, 'c1fa05fa-871f-4ce1-9abe-0e58ed77f977'),
	('00000000-0000-0000-0000-000000000000', 77, '53xtq2lg3oxd', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', true, '2026-01-11 07:29:16.128424+00', '2026-01-11 08:28:42.584563+00', NULL, '04fbc3bf-df11-4b86-a5b3-9106dd66f409'),
	('00000000-0000-0000-0000-000000000000', 78, 'nduau6xaqmpp', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', true, '2026-01-11 08:28:42.603709+00', '2026-01-11 09:28:02.671715+00', '53xtq2lg3oxd', '04fbc3bf-df11-4b86-a5b3-9106dd66f409'),
	('00000000-0000-0000-0000-000000000000', 23, 'svotj6s6yunq', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2025-12-18 07:47:24.473749+00', '2025-12-18 07:47:24.473749+00', NULL, '8d058ef8-f2b2-4afa-82c8-4f80559fa9fb'),
	('00000000-0000-0000-0000-000000000000', 24, 'sj36iqdvuh4h', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2025-12-18 09:22:20.242107+00', '2025-12-18 09:22:20.242107+00', NULL, '1993a72b-c161-4177-9b71-e4e048c81fab'),
	('00000000-0000-0000-0000-000000000000', 79, '6amzbwohi2ai', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', true, '2026-01-11 09:28:02.681099+00', '2026-01-11 10:27:23.698239+00', 'nduau6xaqmpp', '04fbc3bf-df11-4b86-a5b3-9106dd66f409'),
	('00000000-0000-0000-0000-000000000000', 25, 'hpkrpva7rcv3', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-18 10:24:32.425793+00', '2025-12-18 11:55:45.85434+00', NULL, '2973338f-6a4c-47aa-886b-db056b416af2'),
	('00000000-0000-0000-0000-000000000000', 26, 'fnj7pq5akhdm', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-18 11:55:45.860643+00', '2025-12-20 08:54:13.567996+00', 'hpkrpva7rcv3', '2973338f-6a4c-47aa-886b-db056b416af2'),
	('00000000-0000-0000-0000-000000000000', 80, 'zersqzh7jn3z', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', true, '2026-01-11 10:27:23.726626+00', '2026-01-11 11:26:43.603817+00', '6amzbwohi2ai', '04fbc3bf-df11-4b86-a5b3-9106dd66f409'),
	('00000000-0000-0000-0000-000000000000', 81, 'ywsys7qez33k', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', true, '2026-01-11 11:26:43.618017+00', '2026-01-11 12:26:03.953298+00', 'zersqzh7jn3z', '04fbc3bf-df11-4b86-a5b3-9106dd66f409'),
	('00000000-0000-0000-0000-000000000000', 27, 'wxx47qlcyt3b', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-20 08:54:13.596989+00', '2025-12-20 09:53:34.276337+00', 'fnj7pq5akhdm', '2973338f-6a4c-47aa-886b-db056b416af2'),
	('00000000-0000-0000-0000-000000000000', 30, 'u3i2jvn2bg7j', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-20 09:53:34.29111+00', '2025-12-20 10:52:58.596765+00', 'wxx47qlcyt3b', '2973338f-6a4c-47aa-886b-db056b416af2'),
	('00000000-0000-0000-0000-000000000000', 82, 'nsmfb3xcjcso', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', true, '2026-01-11 12:26:03.972382+00', '2026-01-11 13:25:23.785699+00', 'ywsys7qez33k', '04fbc3bf-df11-4b86-a5b3-9106dd66f409'),
	('00000000-0000-0000-0000-000000000000', 31, 'vp72fzhvhtrb', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-20 10:52:58.622799+00', '2025-12-20 11:52:19.202994+00', 'u3i2jvn2bg7j', '2973338f-6a4c-47aa-886b-db056b416af2'),
	('00000000-0000-0000-0000-000000000000', 32, 'r4fsi7745eqo', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-20 11:52:19.210409+00', '2025-12-20 12:51:39.252416+00', 'vp72fzhvhtrb', '2973338f-6a4c-47aa-886b-db056b416af2'),
	('00000000-0000-0000-0000-000000000000', 83, 'rs2ohkj2qmls', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', true, '2026-01-11 13:25:23.797403+00', '2026-01-11 14:24:44.200539+00', 'nsmfb3xcjcso', '04fbc3bf-df11-4b86-a5b3-9106dd66f409'),
	('00000000-0000-0000-0000-000000000000', 33, '6j6b7xr5wud3', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-20 12:51:39.271524+00', '2025-12-20 13:51:06.524565+00', 'r4fsi7745eqo', '2973338f-6a4c-47aa-886b-db056b416af2'),
	('00000000-0000-0000-0000-000000000000', 34, 'udnpcac5wfid', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-20 13:51:06.548248+00', '2025-12-20 14:50:33.08825+00', '6j6b7xr5wud3', '2973338f-6a4c-47aa-886b-db056b416af2'),
	('00000000-0000-0000-0000-000000000000', 84, 'qvodph2fryl5', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', true, '2026-01-11 14:24:44.229548+00', '2026-01-11 15:24:04.789786+00', 'rs2ohkj2qmls', '04fbc3bf-df11-4b86-a5b3-9106dd66f409'),
	('00000000-0000-0000-0000-000000000000', 35, '5nvl6on3oyhh', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-20 14:50:33.106567+00', '2025-12-20 15:49:55.309439+00', 'udnpcac5wfid', '2973338f-6a4c-47aa-886b-db056b416af2'),
	('00000000-0000-0000-0000-000000000000', 36, '33euzqefdsjf', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2025-12-20 15:49:55.336358+00', '2025-12-21 23:29:01.91077+00', '5nvl6on3oyhh', '2973338f-6a4c-47aa-886b-db056b416af2'),
	('00000000-0000-0000-0000-000000000000', 37, 'uo7frcq4vecy', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2025-12-21 23:29:01.937197+00', '2025-12-21 23:29:01.937197+00', '33euzqefdsjf', '2973338f-6a4c-47aa-886b-db056b416af2'),
	('00000000-0000-0000-0000-000000000000', 85, 'ah2m3vbhhujd', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', true, '2026-01-11 15:24:04.81217+00', '2026-01-11 16:23:31.146796+00', 'qvodph2fryl5', '04fbc3bf-df11-4b86-a5b3-9106dd66f409'),
	('00000000-0000-0000-0000-000000000000', 86, 'thiv3x2zvkp7', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', true, '2026-01-11 16:23:31.164181+00', '2026-01-12 06:17:01.906927+00', 'ah2m3vbhhujd', '04fbc3bf-df11-4b86-a5b3-9106dd66f409'),
	('00000000-0000-0000-0000-000000000000', 41, 'b7dnyfbsizih', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', false, '2025-12-22 02:49:38.337176+00', '2025-12-22 02:49:38.337176+00', NULL, '7401866a-b1d9-4ec5-874b-dcee0b89d60e'),
	('00000000-0000-0000-0000-000000000000', 87, 'bwfy754274am', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', false, '2026-01-12 06:17:01.925379+00', '2026-01-12 06:17:01.925379+00', 'thiv3x2zvkp7', '04fbc3bf-df11-4b86-a5b3-9106dd66f409'),
	('00000000-0000-0000-0000-000000000000', 88, 'uxcvq4vdxa7j', '381068fc-5eef-4350-ae44-1e65dd28d02c', false, '2026-01-13 06:08:02.56547+00', '2026-01-13 06:08:02.56547+00', NULL, '34006771-097e-4954-bf57-f9a347473ef8'),
	('00000000-0000-0000-0000-000000000000', 54, 'usl4oxfpequk', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2025-12-28 14:37:23.33029+00', '2025-12-28 14:37:23.33029+00', NULL, 'cbc1fef8-5ad0-409d-9f24-c76b44609570'),
	('00000000-0000-0000-0000-000000000000', 56, '34umqj3afvbn', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', false, '2025-12-28 14:38:26.132303+00', '2025-12-28 14:38:26.132303+00', NULL, '25b28948-71f0-4eb8-942d-02dcac4b0bf4'),
	('00000000-0000-0000-0000-000000000000', 60, 'cn52kdkhpir4', '61d5066a-4827-44bd-a05c-43f2d62c3213', false, '2025-12-28 16:42:13.840444+00', '2025-12-28 16:42:13.840444+00', NULL, 'a8662d24-c560-4f88-9d86-be6820d55fac'),
	('00000000-0000-0000-0000-000000000000', 61, 'y3inxdlhxivn', '7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', false, '2025-12-28 16:43:33.776903+00', '2025-12-28 16:43:33.776903+00', NULL, 'c2714536-48c2-4637-88fc-2f24832d39dd'),
	('00000000-0000-0000-0000-000000000000', 63, 'vb47ksbljqq2', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2025-12-28 16:56:34.766373+00', '2025-12-28 16:56:34.766373+00', NULL, '6502c96f-b395-4461-be66-c476abb1c743'),
	('00000000-0000-0000-0000-000000000000', 65, 'rt4q24hgs4lu', 'f2e3f942-8f0e-464f-b386-7adcc8e90243', false, '2025-12-28 17:13:38.772231+00', '2025-12-28 17:13:38.772231+00', NULL, '94c3fabe-be21-4e7f-8ba3-fd2538d9257e'),
	('00000000-0000-0000-0000-000000000000', 68, 'ssxpse53paan', '7d26a7e2-b16b-4c4e-93df-4061076f4786', false, '2025-12-28 17:53:24.747798+00', '2025-12-28 17:53:24.747798+00', NULL, '4a78feee-66ff-462f-846b-3b0433b52683'),
	('00000000-0000-0000-0000-000000000000', 257, 'qxwdtq7mo6o3', 'dcb2cce8-f8d5-440f-ae53-1e39a260254b', false, '2026-02-05 00:56:34.686543+00', '2026-02-05 00:56:34.686543+00', NULL, 'de54dbc8-1999-46b5-bea2-cb97ee2fb3d2'),
	('00000000-0000-0000-0000-000000000000', 91, 'nzmfznebk4wg', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-13 07:19:50.416384+00', '2026-01-13 07:19:50.416384+00', NULL, 'cfc421e4-ccda-4cfc-b278-1da792018a1f'),
	('00000000-0000-0000-0000-000000000000', 93, '4m4riiflx5fn', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-13 07:31:59.871423+00', '2026-01-13 07:31:59.871423+00', NULL, '1013ee32-6570-47a4-ac1a-546f9d37bb34'),
	('00000000-0000-0000-0000-000000000000', 94, 'qze6neh2ottd', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-14 07:03:13.71167+00', '2026-01-14 07:03:13.71167+00', NULL, 'dc48034c-30dd-4388-8ea1-1d310693b5ff'),
	('00000000-0000-0000-0000-000000000000', 100, 'hcankpraolgi', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2026-01-15 08:16:51.46848+00', '2026-01-15 13:33:08.703085+00', NULL, '1df9b35f-ad02-43e2-a2c9-1a555ddfd26f'),
	('00000000-0000-0000-0000-000000000000', 101, 'umkzbe3mc4ox', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2026-01-15 13:33:08.720955+00', '2026-01-15 13:33:08.720955+00', 'hcankpraolgi', '1df9b35f-ad02-43e2-a2c9-1a555ddfd26f'),
	('00000000-0000-0000-0000-000000000000', 102, '46aejw2ie7ph', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2026-01-15 17:31:16.139863+00', '2026-01-15 17:31:16.139863+00', NULL, 'd8ea0b85-c9c8-4875-ab54-a497a15c5c89'),
	('00000000-0000-0000-0000-000000000000', 105, 'kldgw5p2vpfa', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2026-01-16 02:43:58.056087+00', '2026-01-16 02:43:58.056087+00', NULL, '9d7e7170-093c-433a-91dc-eab046f73e9f'),
	('00000000-0000-0000-0000-000000000000', 106, 're2gjxzpsn3z', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-16 06:15:53.128561+00', '2026-01-16 06:15:53.128561+00', NULL, 'e1e0e9c2-68d8-4da6-a72c-cde4f04053e2'),
	('00000000-0000-0000-0000-000000000000', 107, 'gdjphbvs3a4u', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-16 07:29:59.294271+00', '2026-01-16 07:29:59.294271+00', NULL, '97bbd1b5-9ff1-4528-90ac-d5bf401a9d1f'),
	('00000000-0000-0000-0000-000000000000', 110, '7kjws2bvxnks', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-16 09:25:43.619096+00', '2026-01-16 09:25:43.619096+00', NULL, '3113ac6d-2eb5-4a65-bc92-6be9c1ad0ce3'),
	('00000000-0000-0000-0000-000000000000', 111, 'iizk3htk67xj', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-16 10:57:51.419958+00', '2026-01-16 10:57:51.419958+00', NULL, 'adc40db6-63ab-4a6f-b897-d1c87817fff8'),
	('00000000-0000-0000-0000-000000000000', 112, 'm2nxgoo7dzlj', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-16 12:19:39.075212+00', '2026-01-16 12:19:39.075212+00', NULL, '979509e4-07c1-477f-9e2d-463514f5e4f1'),
	('00000000-0000-0000-0000-000000000000', 113, 'z2htgtszgbyh', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-16 13:32:49.613915+00', '2026-01-16 13:32:49.613915+00', NULL, 'ba79e163-943b-4ca8-a731-42df88aea4d3'),
	('00000000-0000-0000-0000-000000000000', 190, 'kg5av67s3zsu', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-30 06:03:51.434047+00', '2026-01-30 07:03:12.79046+00', NULL, '8f6e4989-33bd-4595-8d8f-7f9007edb539'),
	('00000000-0000-0000-0000-000000000000', 191, 'dm3ak4p7vj2c', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-30 07:03:12.816321+00', '2026-01-30 08:02:32.73675+00', 'kg5av67s3zsu', '8f6e4989-33bd-4595-8d8f-7f9007edb539'),
	('00000000-0000-0000-0000-000000000000', 192, '5rsqev5t6bvl', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-30 08:02:32.75692+00', '2026-01-30 09:01:52.851087+00', 'dm3ak4p7vj2c', '8f6e4989-33bd-4595-8d8f-7f9007edb539'),
	('00000000-0000-0000-0000-000000000000', 193, 'e3sdoi4keocw', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-30 09:01:52.862877+00', '2026-01-30 10:01:19.474393+00', '5rsqev5t6bvl', '8f6e4989-33bd-4595-8d8f-7f9007edb539'),
	('00000000-0000-0000-0000-000000000000', 194, 'cbmk44alskjt', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-30 10:01:19.497112+00', '2026-01-30 11:00:39.752742+00', 'e3sdoi4keocw', '8f6e4989-33bd-4595-8d8f-7f9007edb539'),
	('00000000-0000-0000-0000-000000000000', 195, 'qbepmrm2ukjf', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-30 11:00:39.773797+00', '2026-01-30 11:00:39.773797+00', 'cbmk44alskjt', '8f6e4989-33bd-4595-8d8f-7f9007edb539'),
	('00000000-0000-0000-0000-000000000000', 196, 'xupn4tuv3zyp', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-30 11:24:31.711698+00', '2026-01-30 11:24:31.711698+00', NULL, '13a92e41-3de3-45c4-ac1f-46ae6e857667'),
	('00000000-0000-0000-0000-000000000000', 197, 'zkdfqhhm44zt', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-30 11:29:21.260352+00', '2026-01-30 12:28:40.699224+00', NULL, 'c114414c-7a46-448a-98b2-096679d80907'),
	('00000000-0000-0000-0000-000000000000', 198, 'p7ckaaau7jcb', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-30 12:28:40.71555+00', '2026-01-30 12:28:40.71555+00', 'zkdfqhhm44zt', 'c114414c-7a46-448a-98b2-096679d80907'),
	('00000000-0000-0000-0000-000000000000', 199, 'xcnbekzyxjin', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-30 12:55:40.180515+00', '2026-01-30 12:55:40.180515+00', NULL, 'd01b60c9-5e37-4ebd-81fe-d65e01e309d7'),
	('00000000-0000-0000-0000-000000000000', 200, '56jhpzsejpwt', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-30 13:02:58.654505+00', '2026-01-30 14:02:17.491751+00', NULL, '615774c9-5ca1-4f78-b65e-e8e931911841'),
	('00000000-0000-0000-0000-000000000000', 201, 'tyxqcuwc6dhf', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-30 14:02:17.515905+00', '2026-01-30 15:01:38.542437+00', '56jhpzsejpwt', '615774c9-5ca1-4f78-b65e-e8e931911841'),
	('00000000-0000-0000-0000-000000000000', 202, 'tjiabihxou64', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-30 15:01:38.567819+00', '2026-01-30 16:01:04.13927+00', 'tyxqcuwc6dhf', '615774c9-5ca1-4f78-b65e-e8e931911841'),
	('00000000-0000-0000-0000-000000000000', 126, '5hwgrygc5gvf', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-17 17:39:17.621347+00', '2026-01-18 05:21:48.214491+00', NULL, 'ec726e01-c176-460e-8825-b59ebe67950b'),
	('00000000-0000-0000-0000-000000000000', 203, 'ebzetk432vma', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-30 16:01:04.159928+00', '2026-01-31 06:39:50.03903+00', 'tjiabihxou64', '615774c9-5ca1-4f78-b65e-e8e931911841'),
	('00000000-0000-0000-0000-000000000000', 127, 'j4n34lqbjn5g', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-18 05:21:48.237644+00', '2026-01-18 06:21:15.591436+00', '5hwgrygc5gvf', 'ec726e01-c176-460e-8825-b59ebe67950b'),
	('00000000-0000-0000-0000-000000000000', 204, 'v274s7fbwec3', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-31 06:39:50.051804+00', '2026-01-31 06:39:50.051804+00', 'ebzetk432vma', '615774c9-5ca1-4f78-b65e-e8e931911841'),
	('00000000-0000-0000-0000-000000000000', 128, '4dg7bliuwyb2', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-18 06:21:15.608411+00', '2026-01-18 07:20:39.118973+00', 'j4n34lqbjn5g', 'ec726e01-c176-460e-8825-b59ebe67950b'),
	('00000000-0000-0000-0000-000000000000', 129, 'ktpmdrkiq54i', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-18 07:20:39.139116+00', '2026-01-18 08:20:03.793691+00', '4dg7bliuwyb2', 'ec726e01-c176-460e-8825-b59ebe67950b'),
	('00000000-0000-0000-0000-000000000000', 205, 'aiy5kbefm53m', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-31 06:40:28.778742+00', '2026-01-31 07:39:55.069878+00', NULL, '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 130, 'lad33jbxmaso', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-18 08:20:03.807116+00', '2026-01-18 09:19:33.363689+00', 'ktpmdrkiq54i', 'ec726e01-c176-460e-8825-b59ebe67950b'),
	('00000000-0000-0000-0000-000000000000', 131, 'nwt4qaonviam', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-18 09:19:33.379273+00', '2026-01-18 10:19:03.554889+00', 'lad33jbxmaso', 'ec726e01-c176-460e-8825-b59ebe67950b'),
	('00000000-0000-0000-0000-000000000000', 206, 'i26vjuukkmsg', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-31 07:39:55.084443+00', '2026-01-31 08:39:21.11926+00', 'aiy5kbefm53m', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 132, 'l2f3bslqospb', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-18 10:19:03.569616+00', '2026-01-21 15:10:00.995571+00', 'nwt4qaonviam', 'ec726e01-c176-460e-8825-b59ebe67950b'),
	('00000000-0000-0000-0000-000000000000', 133, 'i4towqsmvq4r', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-21 15:10:01.026323+00', '2026-01-21 16:09:42.33937+00', 'l2f3bslqospb', 'ec726e01-c176-460e-8825-b59ebe67950b'),
	('00000000-0000-0000-0000-000000000000', 207, 'ruyixgvb4q7g', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-31 08:39:21.137239+00', '2026-01-31 09:38:51.118087+00', 'i26vjuukkmsg', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 134, 't5f2a342rwmn', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-21 16:09:42.363091+00', '2026-01-21 17:13:00.131975+00', 'i4towqsmvq4r', 'ec726e01-c176-460e-8825-b59ebe67950b'),
	('00000000-0000-0000-0000-000000000000', 135, 'gxdfivd7pdeo', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-01-21 17:13:00.153835+00', '2026-01-21 17:13:00.153835+00', 't5f2a342rwmn', 'ec726e01-c176-460e-8825-b59ebe67950b'),
	('00000000-0000-0000-0000-000000000000', 208, 'gttly5t3efpt', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-31 09:38:51.129307+00', '2026-01-31 10:38:21.267858+00', 'ruyixgvb4q7g', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 209, 'uihit5yusmos', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-31 10:38:21.275131+00', '2026-01-31 11:37:51.216906+00', 'gttly5t3efpt', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 210, '3jvethcjb2hu', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-31 11:37:51.224352+00', '2026-01-31 12:37:21.613386+00', 'uihit5yusmos', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 211, '3pniidd7i6tt', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-31 12:37:21.622979+00', '2026-01-31 13:36:51.58122+00', '3jvethcjb2hu', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 212, '2a3dypxbsyf5', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-31 13:36:51.595333+00', '2026-01-31 14:36:21.505221+00', '3pniidd7i6tt', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 213, '7owdpjjflvyd', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-31 14:36:21.523755+00', '2026-01-31 15:35:51.539273+00', '2a3dypxbsyf5', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 214, 'qjyxy7uhiz7m', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-01-31 15:35:51.545107+00', '2026-02-01 06:44:50.305875+00', '7owdpjjflvyd', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 215, '7ff7wup5lm5u', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-01 06:44:50.333181+00', '2026-02-01 07:44:17.729308+00', 'qjyxy7uhiz7m', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 216, 'zxvf4dl644rn', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-01 07:44:17.739655+00', '2026-02-01 08:43:45.6249+00', '7ff7wup5lm5u', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 217, 'gj5uzede4abt', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-01 08:43:45.634684+00', '2026-02-01 09:43:13.739637+00', 'zxvf4dl644rn', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 258, 'hn2vvn3gaah4', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-02-08 09:04:15.055448+00', '2026-02-08 09:04:15.055448+00', NULL, 'ee50e5fc-9df6-4e90-a559-97f8ef2f99b7'),
	('00000000-0000-0000-0000-000000000000', 218, 'lhfsvjicnt7g', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-01 09:43:13.757216+00', '2026-02-01 10:42:33.224981+00', 'gj5uzede4abt', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 255, '6btqofcpsyai', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-04 09:28:25.674694+00', '2026-02-10 15:51:46.172123+00', NULL, 'f63f1a27-ca90-4019-8ae3-860bd443195d'),
	('00000000-0000-0000-0000-000000000000', 219, 'h4x2uqowht7c', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-01 10:42:33.249187+00', '2026-02-01 11:41:53.231905+00', 'lhfsvjicnt7g', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 259, 'cs22dpogbdyv', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-02-10 15:51:46.200831+00', '2026-02-10 15:51:46.200831+00', '6btqofcpsyai', 'f63f1a27-ca90-4019-8ae3-860bd443195d'),
	('00000000-0000-0000-0000-000000000000', 220, '264r5qzivd5s', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-01 11:41:53.241982+00', '2026-02-01 12:41:16.011076+00', 'h4x2uqowht7c', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 260, 'sea7iwzxxcnz', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-02-22 14:54:32.019808+00', '2026-02-22 14:54:32.019808+00', NULL, '46dcac61-0e4f-45ec-9df8-4b0801258376'),
	('00000000-0000-0000-0000-000000000000', 221, 'vscpyookvpiz', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-01 12:41:16.026306+00', '2026-02-01 13:40:44.484103+00', '264r5qzivd5s', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 222, 'jhlavplcrh23', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-01 13:40:44.49269+00', '2026-02-02 05:36:32.1036+00', 'vscpyookvpiz', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 261, 'cvlu7qdt7uem', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-23 06:52:48.261275+00', '2026-02-23 07:52:08.700488+00', NULL, 'd60cf930-359a-404b-9b4d-06af5d42df98'),
	('00000000-0000-0000-0000-000000000000', 223, '5zr5vqflaj2q', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-02 05:36:32.133243+00', '2026-02-02 06:36:00.093214+00', 'jhlavplcrh23', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 224, '7uu52geewmht', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-02 06:36:00.104599+00', '2026-02-02 07:35:24.73886+00', '5zr5vqflaj2q', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 262, 'vryrctwbvkyh', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-23 07:52:08.725949+00', '2026-02-23 08:51:29.029476+00', 'cvlu7qdt7uem', 'd60cf930-359a-404b-9b4d-06af5d42df98'),
	('00000000-0000-0000-0000-000000000000', 225, 'uhlfmufdxxy2', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-02 07:35:24.757014+00', '2026-02-02 08:34:54.003139+00', '7uu52geewmht', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 263, '6ol5jrpsrrhi', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-02-23 08:51:29.052306+00', '2026-02-23 08:51:29.052306+00', 'vryrctwbvkyh', 'd60cf930-359a-404b-9b4d-06af5d42df98'),
	('00000000-0000-0000-0000-000000000000', 226, 'ofbsfntiy7yu', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-02 08:34:54.032627+00', '2026-02-02 09:34:21.997024+00', 'uhlfmufdxxy2', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 227, 'sqkvcq7hrbsv', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-02 09:34:22.019983+00', '2026-02-02 10:33:50.82387+00', 'ofbsfntiy7yu', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 228, 'zfkz6n77plut', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-02 10:33:50.843626+00', '2026-02-02 11:33:21.439147+00', 'sqkvcq7hrbsv', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 432, '5njhrsxtw2cb', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2026-03-22 06:36:33.337335+00', '2026-03-22 06:36:33.337335+00', 'h6lnnquuq4tc', '59c441e4-7d72-453a-9fb3-d551954a1ab9'),
	('00000000-0000-0000-0000-000000000000', 229, 'm553tfvekzwr', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-02 11:33:21.456679+00', '2026-02-02 12:32:51.598071+00', 'zfkz6n77plut', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 230, '4nqh3f5h3m5i', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-02 12:32:51.622432+00', '2026-02-02 13:32:17.41485+00', 'm553tfvekzwr', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 231, '3s4lcb3vgnfd', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-02 13:32:17.424319+00', '2026-02-02 14:31:46.547133+00', '4nqh3f5h3m5i', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 232, 'qjh6wnmdtkda', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-02-02 14:31:46.552941+00', '2026-02-02 14:31:46.552941+00', '3s4lcb3vgnfd', '1d201739-abfe-4fbb-bfce-532eef606a7c'),
	('00000000-0000-0000-0000-000000000000', 233, 'ujgmzlgpfala', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-02 15:24:06.436042+00', '2026-02-02 16:23:36.987084+00', NULL, '798b5d82-f635-4ce3-a0e5-b1daa4f4c4db'),
	('00000000-0000-0000-0000-000000000000', 234, 'iiejulf5iece', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-02-02 16:23:37.00451+00', '2026-02-02 17:23:07.076862+00', 'ujgmzlgpfala', '798b5d82-f635-4ce3-a0e5-b1daa4f4c4db'),
	('00000000-0000-0000-0000-000000000000', 235, '33ahcozpidqs', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-02-02 17:23:07.091256+00', '2026-02-02 17:23:07.091256+00', 'iiejulf5iece', '798b5d82-f635-4ce3-a0e5-b1daa4f4c4db'),
	('00000000-0000-0000-0000-000000000000', 236, 'sq6fqm6jp6sd', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-02-02 17:29:26.412253+00', '2026-02-02 17:29:26.412253+00', NULL, '2f8e4efc-daec-48bc-892d-f8b486ed9e23'),
	('00000000-0000-0000-0000-000000000000', 329, 'raa53qxf6cml', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-08 16:52:13.09264+00', '2026-03-10 07:24:29.343026+00', 'bj7lqhguasxl', '9b0309bb-833f-42e6-9310-f466b48b75c3'),
	('00000000-0000-0000-0000-000000000000', 246, 'cmrlgs3xfjt7', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-02-04 08:57:48.61604+00', '2026-02-04 08:57:48.61604+00', NULL, '59a755d5-9be7-43ed-bfa1-d1622ffdf8c1'),
	('00000000-0000-0000-0000-000000000000', 247, 'c3tjetftfjtb', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-02-04 09:07:33.270417+00', '2026-02-04 09:07:33.270417+00', NULL, '7fb0a314-67a7-4b0e-ad6c-cc9465919c27'),
	('00000000-0000-0000-0000-000000000000', 248, 'ztabx6oolwrj', 'd0fab6ce-74bf-4b57-8299-cd9a5bfdb480', false, '2026-02-04 09:08:42.372988+00', '2026-02-04 09:08:42.372988+00', NULL, '434a7592-2913-4cca-8c5e-51bc409e3b49'),
	('00000000-0000-0000-0000-000000000000', 464, '2dwcw4imy6lw', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 05:15:41.287133+00', '2026-03-24 05:15:41.287133+00', NULL, 'fb34b4f8-0ac5-4445-bbd5-b690c448278b'),
	('00000000-0000-0000-0000-000000000000', 254, '62xgdozb4gug', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-02-04 09:19:00.289692+00', '2026-02-04 09:19:00.289692+00', NULL, '48ab5eaa-2e02-4836-90ff-2018a658d7b2'),
	('00000000-0000-0000-0000-000000000000', 256, 'aniz3oupmumi', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2026-02-04 09:30:44.041784+00', '2026-02-04 09:30:44.041784+00', NULL, '35bd30a4-6fdf-4de4-b553-1a14fb06f10b'),
	('00000000-0000-0000-0000-000000000000', 356, '2pypslrmorkv', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-12 14:56:09.827696+00', '2026-03-12 16:03:41.37806+00', NULL, 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 358, 'kaamwandodtl', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-12 17:03:07.54874+00', '2026-03-13 06:48:32.541543+00', 'de2n6qbpfygu', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 360, 'c3c45u4mbrac', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-13 07:48:01.554397+00', '2026-03-13 08:47:31.643398+00', 'vzz5dyiq4e3i', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 362, 'q35cv7glbiw7', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-13 09:18:23.301424+00', '2026-03-13 09:18:23.301424+00', NULL, '9f203448-7690-4996-95c2-beaa461f04fc'),
	('00000000-0000-0000-0000-000000000000', 364, '4aoatbtoah5w', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-13 09:25:06.723408+00', '2026-03-13 09:25:06.723408+00', NULL, '0f9439d1-2ec4-493a-b8c1-0ae2fc9748ca'),
	('00000000-0000-0000-0000-000000000000', 472, 'cuwfaanh4s3s', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 06:45:31.76179+00', '2026-03-24 06:45:31.76179+00', NULL, 'a6d4c447-bcbc-4fc6-9b58-e665c5806aa5'),
	('00000000-0000-0000-0000-000000000000', 366, 'tsqbi5g66pn2', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-13 10:34:18.516189+00', '2026-03-13 11:33:48.08949+00', 'p3rw66632vph', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 368, 'paigw7wgjqmi', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-13 12:33:10.783364+00', '2026-03-13 13:32:33.460364+00', 'qp6h5kvivinp', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 331, 'lznfbrokycp2', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-10 07:24:29.364363+00', '2026-03-24 14:39:54.322643+00', 'raa53qxf6cml', '9b0309bb-833f-42e6-9310-f466b48b75c3'),
	('00000000-0000-0000-0000-000000000000', 370, 'ejfu3onlqvna', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-13 14:32:02.779504+00', '2026-03-13 15:31:25.4494+00', '4y3gm2kz5wvl', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 372, 'nvil5gr4wp4f', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-14 06:44:44.956632+00', '2026-03-14 06:44:44.956632+00', '434tqi7lkcve', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 318, 'h4ctlwmpod3e', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-08 10:09:05.31061+00', '2026-03-08 11:08:26.793777+00', NULL, '9b0309bb-833f-42e6-9310-f466b48b75c3'),
	('00000000-0000-0000-0000-000000000000', 320, 'zu2dmpazytwx', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-08 11:08:26.798631+00', '2026-03-08 12:13:49.434555+00', 'h4ctlwmpod3e', '9b0309bb-833f-42e6-9310-f466b48b75c3'),
	('00000000-0000-0000-0000-000000000000', 431, 'h6lnnquuq4tc', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2026-03-21 13:14:12.797501+00', '2026-03-22 06:36:33.306535+00', NULL, '59c441e4-7d72-453a-9fb3-d551954a1ab9'),
	('00000000-0000-0000-0000-000000000000', 322, 'bj7lqhguasxl', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-08 12:13:49.440657+00', '2026-03-08 16:52:13.073573+00', 'zu2dmpazytwx', '9b0309bb-833f-42e6-9310-f466b48b75c3'),
	('00000000-0000-0000-0000-000000000000', 441, 'rcw23obvoozb', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-22 13:00:59.081642+00', '2026-03-22 13:00:59.081642+00', NULL, 'dabda595-bce4-451f-8f23-81da41c6bea5'),
	('00000000-0000-0000-0000-000000000000', 447, '3pdwetsjwxxe', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-23 09:43:00.738862+00', '2026-03-23 10:42:15.38605+00', NULL, '770ed888-5428-49ea-94ce-0c4721e0d917'),
	('00000000-0000-0000-0000-000000000000', 452, 'jsqrgre5repc', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-23 10:42:15.406522+00', '2026-03-23 10:42:15.406522+00', '3pdwetsjwxxe', '770ed888-5428-49ea-94ce-0c4721e0d917'),
	('00000000-0000-0000-0000-000000000000', 449, 'bbfovwgmek7t', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-23 09:44:02.286735+00', '2026-03-23 10:43:12.725341+00', NULL, '31614f50-2cf5-4736-9b35-ec3a30a265ef'),
	('00000000-0000-0000-0000-000000000000', 453, 'xranye4xwi43', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-23 10:43:12.741282+00', '2026-03-23 11:42:23.666628+00', 'bbfovwgmek7t', '31614f50-2cf5-4736-9b35-ec3a30a265ef'),
	('00000000-0000-0000-0000-000000000000', 455, 'p23fhrstfzzk', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-23 11:42:23.6967+00', '2026-03-23 12:41:29.539354+00', 'xranye4xwi43', '31614f50-2cf5-4736-9b35-ec3a30a265ef'),
	('00000000-0000-0000-0000-000000000000', 457, 'lhuvts2eoezf', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-23 12:41:29.560266+00', '2026-03-23 13:40:39.119555+00', 'p23fhrstfzzk', '31614f50-2cf5-4736-9b35-ec3a30a265ef'),
	('00000000-0000-0000-0000-000000000000', 459, 'q2ejwqxbu53y', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-23 13:40:39.136782+00', '2026-03-23 14:39:47.285385+00', 'lhuvts2eoezf', '31614f50-2cf5-4736-9b35-ec3a30a265ef'),
	('00000000-0000-0000-0000-000000000000', 302, '3nuodqnyldxv', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-05 12:01:21.319819+00', '2026-03-05 12:01:21.319819+00', NULL, 'af434ff6-3997-4264-a07b-1651f83b76fa'),
	('00000000-0000-0000-0000-000000000000', 461, 'mhv4st4253lj', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-23 14:39:47.304251+00', '2026-03-23 15:38:57.252554+00', 'q2ejwqxbu53y', '31614f50-2cf5-4736-9b35-ec3a30a265ef'),
	('00000000-0000-0000-0000-000000000000', 463, 'fwv2timt5eca', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-23 15:38:57.269972+00', '2026-03-23 15:38:57.269972+00', 'mhv4st4253lj', '31614f50-2cf5-4736-9b35-ec3a30a265ef'),
	('00000000-0000-0000-0000-000000000000', 357, 'de2n6qbpfygu', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-12 16:03:41.393047+00', '2026-03-12 17:03:07.524514+00', '2pypslrmorkv', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 467, 'qwd6wyei7bzi', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 05:37:46.462387+00', '2026-03-24 05:37:46.462387+00', NULL, '43bbab87-fdf4-4e88-8c56-06759f0bf1a0'),
	('00000000-0000-0000-0000-000000000000', 359, 'vzz5dyiq4e3i', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-13 06:48:32.572167+00', '2026-03-13 07:48:01.540058+00', 'kaamwandodtl', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 363, 'x5lxambfsftg', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-13 09:22:50.774132+00', '2026-03-13 09:22:50.774132+00', NULL, '822f63f4-2b88-401a-a7cd-344f5729a5f8'),
	('00000000-0000-0000-0000-000000000000', 365, 'v4jb4cbxulcl', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-13 09:32:32.754118+00', '2026-03-13 09:32:32.754118+00', NULL, 'ebf567f5-14af-4b48-bba5-6d62ea2b99b8'),
	('00000000-0000-0000-0000-000000000000', 361, 'p3rw66632vph', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-13 08:47:31.653911+00', '2026-03-13 10:34:18.500116+00', 'c3c45u4mbrac', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 471, 'qasmehyxkuy4', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 06:37:11.144625+00', '2026-03-24 06:37:11.144625+00', NULL, 'e1b85708-b1d6-4e97-b0d8-05c4678b2ca8'),
	('00000000-0000-0000-0000-000000000000', 367, 'qp6h5kvivinp', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-13 11:33:48.102871+00', '2026-03-13 12:33:10.770398+00', 'tsqbi5g66pn2', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 473, 'xf4bays4eel6', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 06:58:16.927146+00', '2026-03-24 06:58:16.927146+00', NULL, '25bab203-e1fb-497d-a956-8804c90a9ed7'),
	('00000000-0000-0000-0000-000000000000', 369, '4y3gm2kz5wvl', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-13 13:32:33.477095+00', '2026-03-13 14:32:02.752355+00', 'paigw7wgjqmi', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 371, '434tqi7lkcve', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-13 15:31:25.471162+00', '2026-03-14 06:44:44.930681+00', 'ejfu3onlqvna', 'c626bdd8-5ef3-44ff-ae36-e14ac58da656'),
	('00000000-0000-0000-0000-000000000000', 474, 'dcki6bzszytm', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-24 06:59:37.336065+00', '2026-03-24 07:58:41.956776+00', NULL, 'e27ca323-e179-49cb-93ea-24a940e4c841'),
	('00000000-0000-0000-0000-000000000000', 476, '3nb2bry4ajp4', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-24 07:58:41.982549+00', '2026-03-24 08:57:51.331941+00', 'dcki6bzszytm', 'e27ca323-e179-49cb-93ea-24a940e4c841'),
	('00000000-0000-0000-0000-000000000000', 478, 'zttjqje2mwhn', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 08:57:51.345061+00', '2026-03-24 08:57:51.345061+00', '3nb2bry4ajp4', 'e27ca323-e179-49cb-93ea-24a940e4c841'),
	('00000000-0000-0000-0000-000000000000', 480, '5zzf5odxj76j', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 09:21:28.17367+00', '2026-03-24 09:21:28.17367+00', NULL, '2b4696fe-ae55-4e9f-9aa9-8cd7ebed9e6f'),
	('00000000-0000-0000-0000-000000000000', 481, 'hnjaa5arxbw2', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 09:22:15.015208+00', '2026-03-24 09:22:15.015208+00', NULL, 'bb32d1fe-95ad-422d-8db5-027f027127b7'),
	('00000000-0000-0000-0000-000000000000', 482, 'kafxadb552zd', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 09:28:19.983404+00', '2026-03-24 09:28:19.983404+00', NULL, '64a3cea7-9bba-4219-9de4-41151c67a6bc'),
	('00000000-0000-0000-0000-000000000000', 483, '2dxjoz74w74y', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 09:29:51.37761+00', '2026-03-24 09:29:51.37761+00', NULL, 'c1d5bbf3-d4b5-4710-9975-1ef6684a47ed'),
	('00000000-0000-0000-0000-000000000000', 484, 'lw6xn3eaodii', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 09:34:12.976575+00', '2026-03-24 09:34:12.976575+00', NULL, '6ec5ae1c-a98e-4dd9-b9c3-85e1ed900592'),
	('00000000-0000-0000-0000-000000000000', 485, 'g7fmonpfik7y', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 09:34:52.556401+00', '2026-03-24 09:34:52.556401+00', NULL, 'e4094b32-9a10-432f-9298-86d584731aa0'),
	('00000000-0000-0000-0000-000000000000', 486, 'warg5zaq4yjj', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-24 10:12:12.338384+00', '2026-03-24 11:11:22.604748+00', NULL, '00a68c0c-f06e-43d1-82f0-32803d3b3865'),
	('00000000-0000-0000-0000-000000000000', 487, 'nlreeobrb4tq', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-24 11:11:22.634612+00', '2026-03-24 12:10:32.696477+00', 'warg5zaq4yjj', '00a68c0c-f06e-43d1-82f0-32803d3b3865'),
	('00000000-0000-0000-0000-000000000000', 488, '3r3x46ii4gka', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-24 12:10:32.715162+00', '2026-03-24 13:09:42.744301+00', 'nlreeobrb4tq', '00a68c0c-f06e-43d1-82f0-32803d3b3865'),
	('00000000-0000-0000-0000-000000000000', 489, '6ody3po4rzso', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-24 13:09:42.75283+00', '2026-03-24 14:08:51.255682+00', '3r3x46ii4gka', '00a68c0c-f06e-43d1-82f0-32803d3b3865'),
	('00000000-0000-0000-0000-000000000000', 490, '4jeex6hwgpgd', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-24 14:08:51.281102+00', '2026-03-24 15:08:04.614053+00', '6ody3po4rzso', '00a68c0c-f06e-43d1-82f0-32803d3b3865'),
	('00000000-0000-0000-0000-000000000000', 491, 'e6p6yzqtaqjv', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-24 14:39:54.332371+00', '2026-03-24 15:39:57.139566+00', 'lznfbrokycp2', '9b0309bb-833f-42e6-9310-f466b48b75c3'),
	('00000000-0000-0000-0000-000000000000', 492, 'fks4ihjap7qj', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-24 15:08:04.629363+00', '2026-03-24 16:07:09.290768+00', '4jeex6hwgpgd', '00a68c0c-f06e-43d1-82f0-32803d3b3865'),
	('00000000-0000-0000-0000-000000000000', 494, 'n27gug4fwp3e', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-24 16:07:09.302139+00', '2026-03-24 16:07:09.302139+00', 'fks4ihjap7qj', '00a68c0c-f06e-43d1-82f0-32803d3b3865'),
	('00000000-0000-0000-0000-000000000000', 493, 'n445myrnpcni', 'd810df06-78c5-441c-8eaf-90e6e505adad', true, '2026-03-24 15:39:57.14826+00', '2026-03-25 04:55:18.082312+00', 'e6p6yzqtaqjv', '9b0309bb-833f-42e6-9310-f466b48b75c3'),
	('00000000-0000-0000-0000-000000000000', 495, 'lhoip44vh5i4', 'd810df06-78c5-441c-8eaf-90e6e505adad', false, '2026-03-25 04:55:18.113479+00', '2026-03-25 04:55:18.113479+00', 'n445myrnpcni', '9b0309bb-833f-42e6-9310-f466b48b75c3'),
	('00000000-0000-0000-0000-000000000000', 499, 'rtlw44bbfjyq', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2026-03-25 15:15:25.164306+00', '2026-03-25 16:14:49.597256+00', NULL, '7151f149-ccdc-4a7f-a48e-4d69b27749cc'),
	('00000000-0000-0000-0000-000000000000', 500, '4dejrlxyzrta', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2026-03-25 16:14:49.619514+00', '2026-03-30 16:09:20.156389+00', 'rtlw44bbfjyq', '7151f149-ccdc-4a7f-a48e-4d69b27749cc'),
	('00000000-0000-0000-0000-000000000000', 501, 'rgpqxroh4nyr', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2026-03-30 16:09:20.182031+00', '2026-03-31 02:09:17.539847+00', '4dejrlxyzrta', '7151f149-ccdc-4a7f-a48e-4d69b27749cc'),
	('00000000-0000-0000-0000-000000000000', 502, 'sqczni5lzqtw', '076de02d-75ba-4e79-898d-1b5e43141894', true, '2026-03-31 02:09:17.556635+00', '2026-03-31 04:51:23.458509+00', 'rgpqxroh4nyr', '7151f149-ccdc-4a7f-a48e-4d69b27749cc'),
	('00000000-0000-0000-0000-000000000000', 503, 'bgvoqo5tdpsl', '076de02d-75ba-4e79-898d-1b5e43141894', false, '2026-03-31 04:51:23.468989+00', '2026-03-31 04:51:23.468989+00', 'sqczni5lzqtw', '7151f149-ccdc-4a7f-a48e-4d69b27749cc');


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."classes" ("id", "school_id", "teacher_id", "name", "subject", "academic_year", "description", "created_at", "class_settings") VALUES
	('10e0f705-1154-4389-a1c1-8d13dc9e584e', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', '12a1', '213', '1234_1235_2', NULL, '2026-01-26 16:32:25.641129+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": true, "join_code": null, "expires_at": null, "logo_enabled": true, "require_approval": false}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('1872e253-05cd-4635-a4ec-cf8195fb3f0a', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', '4', '4', '1233_1234_3', NULL, '2026-01-27 14:19:59.379941+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": true, "join_code": "39X1OT", "expires_at": null, "logo_enabled": true, "require_approval": false}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('17657e87-bbd0-4b07-a4bb-9b03fe0f26bb', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Hệ quản trị cơ sở dữ liệu', '2102041', '4', 'Môn học về hệ quản trị cơ sở dữ liệu và SQL', '2026-01-17 13:54:37.225929+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": "FUKQCY", "expires_at": null, "logo_enabled": true, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('6cfee734-50a8-4061-8c5a-a12acee9bbf9', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'CSDL_MySQL', 'MySQL', '2024 - 2025', NULL, '2026-01-17 09:08:00.414897+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": true, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('67ca5a81-889a-4435-98c6-425ea7f44fd8', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Tin học đại cương', '2102033', '1', 'Môn học cơ bản về tin học và máy tính', '2026-01-17 13:53:58.624234+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('6f8023ab-a207-4639-9574-a554ded1dea0', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Tin học đại cương', '2102033', '1', 'Môn học cơ bản về tin học và máy tính', '2026-01-17 13:54:33.373809+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('6507042d-02d1-48cf-854b-a1aa483d344a', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Đồ họa máy tính', '2102008', '1', 'Môn học về đồ họa và xử lý hình ảnh trên máy tính', '2026-01-17 13:54:33.634186+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('480e452e-0a62-4c7b-b9ba-8b8d15ac75b4', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Ngôn ngữ lập trình C/C++', '2102034', '2', 'Môn học về lập trình cơ bản với ngôn ngữ C và C++', '2026-01-17 13:54:34.370527+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('37b94731-cf6f-4a1d-8ea2-cc31971a3e17', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Nhập môn Công nghệ thông tin', '2102035', '2', 'Môn học giới thiệu về công nghệ thông tin', '2026-01-17 13:54:34.602912+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('9d00706b-16eb-4609-a93a-7a42c0e98e9b', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Kiến trúc máy tính', '2102009', '3', 'Môn học về cấu trúc và kiến trúc của máy tính', '2026-01-17 13:54:34.850646+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('888559bf-fe5d-4122-bdab-2b21a46c60ae', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Cấu trúc dữ liệu và giải thuật', '2102036', '3', 'Môn học về cấu trúc dữ liệu và các thuật toán cơ bản', '2026-01-17 13:54:35.522752+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('e588c997-8d18-440e-b44b-77f2c49d78aa', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Lập trình hướng đối tượng', '2102038', '3', 'Môn học về lập trình hướng đối tượng (OOP)', '2026-01-17 13:54:35.770695+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('67dfe576-1fc1-4dda-bd91-f7e8025d472e', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Cơ sở dữ liệu', '2102039', '3', 'Môn học về cơ sở dữ liệu và hệ quản trị cơ sở dữ liệu', '2026-01-17 13:54:36.026339+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('04e2e922-82c9-4809-b90e-affffb4f286e', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Hệ điều hành', '2102010', '4', 'Môn học về hệ điều hành và quản lý tài nguyên hệ thống', '2026-01-17 13:54:36.673018+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('de01dd17-ef38-4adb-811d-7337739e53d7', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Mạng máy tính', '2102011', '4', 'Môn học về mạng máy tính và giao thức mạng', '2026-01-17 13:54:36.971491+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('0cb3c059-730f-484e-ad5f-34b85444d3e9', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Phân tích và thiết kế hệ thống thông tin', '2102043', '4', 'Môn học về phân tích và thiết kế hệ thống thông tin', '2026-01-17 13:54:37.48383+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('0b8ce710-5b4d-4e0f-ac68-10142c1d2cb5', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Lập trình Java', '2102045', '4', 'Môn học về lập trình Java và các framework', '2026-01-17 13:54:38.493588+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('05e9f237-66aa-4ebb-805c-eccb6a754484', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Thiết kế Web', '2102044', '5', 'Môn học về thiết kế và phát triển website', '2026-01-17 13:54:39.51834+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('1e44be2f-d912-41ec-8d33-d3d215e7489d', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Công nghệ phần mềm', '2102046', '5', 'Môn học về quy trình phát triển phần mềm', '2026-01-17 13:54:39.761192+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('7249dca8-2002-4806-8ae4-079356fc39d0', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Lập trình .NET', '2102048', '5', 'Môn học về lập trình với .NET framework', '2026-01-17 13:54:39.997946+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('2e322dc2-43a7-4b4e-86b2-a9323280cc10', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Trí tuệ nhân tạo', '2102050', '5', 'Môn học về trí tuệ nhân tạo và machine learning', '2026-01-17 13:54:40.246845+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('1372c233-baa8-49f1-8c73-3eded159a6af', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'An toàn và bảo mật thông tin', '2102052', '5', 'Môn học về an toàn và bảo mật thông tin', '2026-01-17 13:54:40.491114+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('e3b0ee75-c32e-45a4-aba9-c5f55a3df454', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Lập trình di động', '2102055', '6', 'Môn học về lập trình ứng dụng di động', '2026-01-17 13:54:41.722013+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('bc663357-ebae-419b-bf48-f172c1cf4659', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Quản trị dự án phần mềm', '2102059', '6', 'Môn học về quản trị và quản lý dự án phần mềm', '2026-01-17 13:54:43.733799+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('a49750ce-f35a-4fa7-a781-0bebca4ba351', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', '1', '1', '1222 - 1234', NULL, '2026-01-25 07:15:21.546186+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": true, "join_code": "4OGCVD", "expires_at": null, "logo_enabled": true, "require_approval": false}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('4ce2a638-ca83-454e-b4c6-707e8f6be991', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', '3', '3', '1233_1234_2', NULL, '2026-01-27 14:11:40.888242+00', '{"defaults": {"lock_class": true}, "enrollment": {"qr_code": {"is_active": true, "join_code": "24UXT1", "expires_at": null, "logo_enabled": true, "require_approval": true}, "manual_join_limit": 20}, "group_management": {"lock_groups": true, "allow_student_switch": true, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": true, "can_edit_profile_in_class": true}}'),
	('73ce450a-bfc5-4c26-a3ef-5c74957022a3', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Kiểm thử và đảm bảo chất lượng PM', '2102057', '6', 'Môn học về kiểm thử phần mềm và đảm bảo chất lượng', '2026-01-17 13:54:42.340659+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": "2SUYK8", "expires_at": null, "logo_enabled": true, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('7304b388-6696-41de-81dd-7f28257eb48f', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', '2', '2', '1234 - 1235', NULL, '2026-01-25 15:33:48.756356+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": true, "join_code": "C2AUE6", "expires_at": null, "logo_enabled": false, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": false}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": false}}'),
	('31b3a5c9-c5b5-4ba9-8766-1ee684129117', NULL, '6af4527c-8caa-4903-bb50-dbadcf1778d4', '5A1', 'Toan', '2025_2026_1', 'test', '2026-02-04 09:15:41.73628+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": true, "join_code": null, "expires_at": null, "logo_enabled": true, "require_approval": false}, "manual_join_limit": 100}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'),
	('d602cfa2-6af1-4d7b-a37f-49bb49563566', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'Lập trình Web nâng cao', '2102053', '6', 'Môn học về lập trình web nâng cao và các framework', '2026-01-17 13:54:40.729091+00', '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": true, "join_code": "4L0G32", "expires_at": null, "logo_enabled": true, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}');


--
-- Data for Name: assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."assignments" ("id", "class_id", "teacher_id", "title", "description", "is_published", "published_at", "total_points", "created_at", "updated_at", "default_shuffle_questions", "default_shuffle_choices") VALUES
	('d16fb952-7eb3-405d-9cd3-a1aa82362bae', NULL, '6af4527c-8caa-4903-bb50-dbadcf1778d4', 'bai tap 1', 'test', false, NULL, NULL, '2026-02-04 09:17:29.280383+00', '2026-02-04 09:18:05.654917+00', false, false),
	('7983b234-5899-42e9-92cf-1ddd65a52e91', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'supabase', 'db', true, '2026-02-04 09:43:00.486405+00', 10.00, '2026-02-04 09:40:31.398937+00', '2026-02-08 09:11:19.570842+00', false, false),
	('1a5970b0-a790-4ec3-b20f-6b07f8671d7c', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'tesst', '12313', true, '2026-03-08 09:21:11.567705+00', NULL, '2026-03-08 09:19:23.664794+00', '2026-03-08 09:21:11.567705+00', false, false),
	('53f905aa-0a05-47bc-bb19-c924865fc1d0', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', '123', '123', false, NULL, NULL, '2026-02-02 14:24:09.362647+00', '2026-02-02 14:24:09.362647+00', false, false),
	('ebd61f1b-a2f4-42ee-84b9-bba0fdc3d03d', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', '1234', '1234', false, NULL, NULL, '2026-02-02 14:25:43.032989+00', '2026-02-02 14:26:03.810173+00', false, false),
	('f9f717a1-d750-41b3-8c17-9a963b732a18', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'ai', 'ai test', true, '2026-03-12 08:54:36.554786+00', 10.00, '2026-02-02 15:24:40.224071+00', '2026-03-12 17:23:35.151265+00', false, false),
	('b7378904-1541-4504-912e-563e46c1950e', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'bt1', 'test', false, '2026-02-04 09:39:43.234613+00', 2.02, '2026-02-04 09:22:25.030854+00', '2026-03-12 17:31:21.754071+00', false, false),
	('d8d32c65-8bf2-4809-8d2f-858fd5fdab34', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'flutter về biến kiểu dữ liệu', NULL, true, '2026-02-03 09:55:54.533584+00', 10.00, '2026-02-02 17:19:06.966089+00', '2026-02-03 09:55:54.533584+00', false, false),
	('e0ff7227-ed43-409f-a405-87bf2cf698ee', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', 'web', 'we', false, NULL, NULL, '2026-03-21 10:44:28.525801+00', '2026-03-21 10:47:03.160783+00', false, false),
	('88c80f63-d70b-4e77-b89e-9c71ba0a8b3f', NULL, 'd810df06-78c5-441c-8eaf-90e6e505adad', '1234', '1232', false, NULL, 2.00, '2026-02-02 15:00:06.54679+00', '2026-03-21 10:47:41.404061+00', false, false);


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."groups" ("id", "class_id", "name", "description", "created_at", "teacher_id") VALUES
	('b71afb03-621a-4d9d-9798-6b0ed8c0440c', NULL, 'Nhóm Liên Lớp (TEST)', 'Nhóm này được tạo để test tính năng nhóm liên lớp thông qua MCP', '2026-02-24 10:41:32.853102+00', 'd0fab6ce-74bf-4b57-8299-cd9a5bfdb480');


--
-- Data for Name: assignment_distributions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."assignment_distributions" ("id", "assignment_id", "distribution_type", "class_id", "group_id", "student_ids", "available_from", "due_at", "time_limit_minutes", "allow_late", "late_policy", "created_at", "status", "settings") VALUES
	('0f323291-838b-4779-b75b-6910cbcf45b7', '7983b234-5899-42e9-92cf-1ddd65a52e91', 'class', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', NULL, NULL, NULL, '2026-02-26 00:00:00+00', 120, true, '{"penalty_per_day_percent": 10}', '2026-02-25 05:50:00.448158+00', 'active', '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true}'),
	('b9dcbc49-98d5-4924-b9bc-9727ae196564', '7983b234-5899-42e9-92cf-1ddd65a52e91', 'class', 'a49750ce-f35a-4fa7-a781-0bebca4ba351', NULL, NULL, NULL, '2026-02-26 00:00:00+00', 120, true, '{"penalty_per_day_percent": 10}', '2026-02-25 05:50:00.768967+00', 'active', '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true}'),
	('8a277cc5-0a2d-472e-8318-9d660a2bc748', 'b7378904-1541-4504-912e-563e46c1950e', 'class', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', NULL, NULL, NULL, NULL, NULL, true, '{"penalty_per_day_percent": 10}', '2026-02-25 08:16:40.334602+00', 'active', '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true}'),
	('f761378d-b9b9-427d-b50f-60a644d3fa09', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', 'class', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', NULL, NULL, NULL, NULL, NULL, true, '{"penalty_per_day_percent": 10}', '2026-02-25 09:50:35.612988+00', 'active', '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true}'),
	('53e37693-058b-4e43-9bdf-5ce1b917781b', '1a5970b0-a790-4ec3-b20f-6b07f8671d7c', 'class', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', NULL, NULL, NULL, '2026-03-09 00:00:00+00', 45, true, '{"penalty_per_day_percent": 10}', '2026-03-08 09:21:52.672289+00', 'active', '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true}'),
	('5df28496-4898-4142-998c-3defa720c3d7', 'f9f717a1-d750-41b3-8c17-9a963b732a18', 'class', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', NULL, NULL, NULL, NULL, NULL, true, '{"penalty_per_day_percent": 10}', '2026-03-12 08:54:59.808337+00', 'active', '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true}');


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."questions" ("id", "author_id", "type", "content", "answer", "default_points", "difficulty", "tags", "is_public", "created_at", "updated_at") VALUES
	('8362d950-e419-42a4-ab36-38176fcbd763', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "234", "explanation": "1234"}', '{"correct_choice_ids": [1]}', 1.00, 5, '{13}', false, '2026-02-02 14:24:23.796533+00', '2026-02-02 14:24:23.796533+00'),
	('727ca4e2-237d-48fe-8b13-1bba7cd71d9a', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "21341235", "explanation": "14314"}', '{"correct_choice_ids": [1]}', 1.00, NULL, '{}', false, '2026-02-02 14:24:35.404716+00', '2026-02-02 14:24:35.404716+00'),
	('1a842e4c-138e-4dc5-914d-d75750f6b3fd', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "1341234", "explanation": "1234143"}', '{"correct_choice_ids": [1]}', 1.00, 5, '{}', false, '2026-02-02 14:24:47.284352+00', '2026-02-02 14:24:47.284352+00'),
	('3583e43c-8080-4089-9379-e92007760f39', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "1234"}', '{"correct_choice_ids": [1]}', 1.00, NULL, '{}', false, '2026-02-02 14:25:49.044024+00', '2026-02-02 14:25:49.044024+00'),
	('a42cc9fe-fbac-4412-9a39-fbc377492f27', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "241"}', '{"correct_choice_ids": [1]}', 1.00, NULL, '{}', false, '2026-02-02 14:25:57.254361+00', '2026-02-02 14:25:57.254361+00'),
	('443a2292-f4c8-46b3-8532-75ebba81fb30', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "1234", "explanation": "1234"}', '{"correct_choice_ids": [1]}', 1.00, NULL, '{}', false, '2026-02-02 15:00:44.995448+00', '2026-02-02 15:00:44.995448+00'),
	('941469f6-70f0-4d84-aa44-1a741a553198', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "2341232", "explanation": "1234"}', '{"correct_choice_ids": [0]}', 1.00, NULL, '{}', false, '2026-02-02 15:00:14.895839+00', '2026-02-02 15:01:25.437352+00'),
	('40499302-9252-4fdf-b593-c78f0ee5b00c', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "1234", "explanation": "1234"}', '{"correct_choice_ids": [1]}', 1.00, NULL, '{}', false, '2026-02-02 15:00:37.638385+00', '2026-02-02 15:01:38.991861+00'),
	('f4297d4c-b271-4070-a395-426b0d40ff51', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Trong Flutter, kiểu dữ liệu nào được sử dụng để lưu trữ một chuỗi ký tự?", "images": []}', '{"correct_choice_ids": [1]}', 1.00, 3, '{Flutter,"Data Types",String}', false, '2026-02-03 09:24:35.354619+00', '2026-02-03 09:24:35.354619+00'),
	('f188ec75-3d96-492b-bf42-697aa8bc6078', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Kiểu dữ liệu nào trong Dart/Flutter được sử dụng để lưu trữ giá trị đúng hoặc sai?", "images": []}', '{"correct_choice_ids": [0]}', 1.00, 3, '{Flutter,"Data Types",Boolean}', false, '2026-02-03 09:24:36.06251+00', '2026-02-03 09:24:36.06251+00'),
	('7d766c1b-2cd8-4185-b27e-87c74810da75', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Để khai báo một biến kiểu số nguyên trong Flutter, bạn sử dụng từ khóa nào?", "images": []}', '{"correct_choice_ids": [2]}', 1.00, 3, '{Flutter,"Data Types",Integer}', false, '2026-02-03 09:24:36.656551+00', '2026-02-03 09:24:36.656551+00'),
	('fa185f0f-f250-4d17-9325-f79a545e7756', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Kiểu dữ liệu `double` trong Flutter dùng để lưu trữ loại giá trị nào?", "images": []}', '{"correct_choice_ids": [3]}', 1.00, 3, '{Flutter,"Data Types",Double}', false, '2026-02-03 09:24:37.206362+00', '2026-02-03 09:24:37.206362+00'),
	('6941fcc5-5be3-44fa-8c59-eebc257401ef', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Trong Flutter, bạn sử dụng từ khóa nào để khai báo một biến có thể nhận bất kỳ kiểu dữ liệu nào?", "images": []}', '{"correct_choice_ids": [0]}', 1.00, 3, '{Flutter,"Data Types",Dynamic}', false, '2026-02-03 09:24:37.801625+00', '2026-02-03 09:24:37.801625+00'),
	('dd13a100-7484-4f6c-bf41-929b8aab26bd', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Sự khác biệt chính giữa `var` và `dynamic` trong Dart/Flutter là gì?", "images": []}', '{"correct_choice_ids": [2]}', 1.00, 3, '{Flutter,"Data Types",var,dynamic}', false, '2026-02-03 09:24:38.469315+00', '2026-02-03 09:24:38.469315+00'),
	('34b5de09-5e77-42fa-ba37-b668df00eb03', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Trong Flutter, kiểu dữ liệu nào được sử dụng để biểu diễn một danh sách các đối tượng có cùng kiểu dữ liệu?", "images": []}', '{"correct_choice_ids": [1]}', 1.00, 3, '{Flutter,"Data Types",List}', false, '2026-02-03 09:24:39.007104+00', '2026-02-03 09:24:39.007104+00'),
	('3fff1f70-1e35-4ca8-98f7-da7613f1c8de', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Kiểu dữ liệu `Map` trong Dart/Flutter dùng để làm gì?", "images": []}', '{"correct_choice_ids": [3]}', 1.00, 3, '{Flutter,"Data Types",Map}', false, '2026-02-03 09:24:39.55151+00', '2026-02-03 09:24:39.55151+00'),
	('746cfd74-b3aa-4304-8263-b0bf6dd4242b', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Trong Dart/Flutter, kiểu dữ liệu nào biểu diễn một tập hợp các giá trị duy nhất?", "images": []}', '{"correct_choice_ids": [0]}', 1.00, 3, '{Flutter,"Data Types",Set}', false, '2026-02-03 09:24:40.078211+00', '2026-02-03 09:24:40.078211+00'),
	('57f0d55b-5709-4cd0-862e-71d01487d0de', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Biến nào sau đây được khai báo đúng cách trong Flutter/Dart để lưu trữ số thập phân?", "images": []}', '{"correct_choice_ids": [2]}', 1.00, 3, '{Flutter,"Data Types",Declaration}', false, '2026-02-03 09:24:40.599882+00', '2026-02-03 09:24:40.599882+00'),
	('ecf48338-cce1-4ded-bb48-21f8b7725b4c', '6af4527c-8caa-4903-bb50-dbadcf1778d4', 'multiple_choice', '{"text": "4+4=?"}', '{"correct_choice_ids": [3]}', 1.00, 1, '{}', false, '2026-02-04 09:18:05.103177+00', '2026-02-04 09:18:05.103177+00'),
	('5e70a789-5469-4083-a212-6603c16a959f', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Khi triển khai ứng dụng Flutter lên Supabase, bạn nên sử dụng chiến lược nào để quản lý các khóa API một cách an toàn, đặc biệt là các khóa `SUPABASE_URL` và `SUPABASE_ANON_KEY`?", "images": []}', '{"correct_choice_ids": [0]}', 1.00, 4, '{Supabase,Flutter,Deployment}', false, '2026-02-04 09:42:15.309958+00', '2026-02-04 09:42:15.309958+00'),
	('f315cf28-b2ea-445a-9268-374fd5329b30', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Để đảm bảo ứng dụng Flutter hoạt động chính xác sau khi triển khai lên Supabase, bạn cần cấu hình CORS (Cross-Origin Resource Sharing) như thế nào?", "images": []}', '{"correct_choice_ids": [1]}', 1.00, 4, '{Supabase,CORS,Flutter}', false, '2026-02-04 09:42:15.892314+00', '2026-02-04 09:42:15.892314+00'),
	('b4bbec70-8ebe-4004-a37f-4eeaabc58212', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Khi sử dụng Supabase functions để thực hiện các tác vụ backend cho ứng dụng Flutter, bạn cần chú ý điều gì về xác thực (authentication) người dùng?", "images": []}', '{"correct_choice_ids": [2]}', 1.00, 4, '{Supabase,Functions,Authentication}', false, '2026-02-04 09:42:16.412183+00', '2026-02-04 09:42:16.412183+00'),
	('ef37b2c6-b528-4808-b7c1-a4bc84e745e5', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Bạn nên sử dụng loại cơ sở dữ liệu nào của Supabase để lưu trữ dữ liệu có cấu trúc và mối quan hệ phức tạp trong ứng dụng Flutter?", "images": []}', '{"correct_choice_ids": [0]}', 1.00, 4, '{Supabase,Database,Flutter}', false, '2026-02-04 09:42:16.922085+00', '2026-02-04 09:42:16.922085+00'),
	('5619eef8-cb21-460a-8d0b-1464e03198d1', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Khi triển khai ứng dụng Flutter lên Supabase, làm thế nào bạn có thể tối ưu hóa hiệu suất truy vấn cơ sở dữ liệu?", "images": []}', '{"correct_choice_ids": [1]}', 1.00, 4, '{Supabase,Performance,Flutter}', false, '2026-02-04 09:42:17.499743+00', '2026-02-04 09:42:17.499743+00'),
	('cf85fe3e-ff4c-4acc-b906-bc6d69db70e1', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Trong quá trình phát triển và triển khai ứng dụng Flutter sử dụng Supabase, bạn cần làm gì để quản lý schema cơ sở dữ liệu một cách hiệu quả?", "images": []}', '{"correct_choice_ids": [0]}', 1.00, 4, '{Supabase,Schema,Flutter}', false, '2026-02-04 09:42:18.073395+00', '2026-02-04 09:42:18.073395+00'),
	('b22ecf36-9c4c-417c-88b7-8b1d3e1f8055', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Khi triển khai ứng dụng Flutter sử dụng Supabase Auth, bạn cần cấu hình redirect URL nào?", "images": []}', '{"correct_choice_ids": [0]}', 1.00, 4, '{Supabase,Auth,Flutter}', false, '2026-02-04 09:42:19.12364+00', '2026-02-04 09:42:19.12364+00'),
	('0debe068-7067-4958-9cd6-ca68e4b4afc8', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Khi sử dụng Supabase Storage để lưu trữ hình ảnh và tệp tin cho ứng dụng Flutter, bạn cần làm gì để đảm bảo người dùng chỉ có thể truy cập tệp tin của riêng mình?", "images": []}', '{"correct_choice_ids": [0]}', 1.00, 4, '{Supabase,Storage,Flutter}', false, '2026-02-04 09:42:20.133035+00', '2026-02-04 09:42:20.133035+00'),
	('b5d21c37-583f-4f6e-8417-30d60764697b', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Để kiểm tra và gỡ lỗi ứng dụng Flutter kết nối với Supabase sau khi triển khai, bạn sử dụng công cụ nào để theo dõi các request và lỗi?", "images": []}', '{"correct_choice_ids": [2]}', 1.00, 4, '{Supabase,Debugging,Flutter}', false, '2026-02-04 09:42:18.609878+00', '2026-02-04 09:42:18.609878+00'),
	('650e8de5-b7f4-486e-8893-2e565b79bd69', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "Để đảm bảo tính bảo mật của dữ liệu trong ứng dụng Flutter sử dụng Supabase, bạn nên sử dụng tính năng nào của Supabase để kiểm soát quyền truy cập?", "images": []}', '{"correct_choice_ids": [1]}', 1.00, 4, '{Supabase,Security,Flutter}', false, '2026-02-04 09:42:19.617639+00', '2026-02-04 09:42:19.617639+00'),
	('d92741f0-9d01-4eae-bac3-ac23d24b7573', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "123wer"}', '{"correct_choice_ids": []}', 1.00, NULL, '{}', false, '2026-03-12 06:40:14.322976+00', '2026-03-12 06:40:14.322976+00'),
	('61493832-56d3-4745-a986-20af34b7c23b', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "234q23"}', '{"correct_choice_ids": [0]}', 1.00, NULL, '{}', false, '2026-03-12 06:40:46.563275+00', '2026-03-12 06:40:46.563275+00'),
	('d925f523-f65c-4828-a29b-dd9d84b5707b', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "2314", "explanation": "waerwaer"}', '{"correct_choice_ids": [0]}', 1.00, 4, '{}', false, '2026-03-12 08:13:53.64515+00', '2026-03-12 08:13:53.64515+00'),
	('7e0afa24-9674-458c-881d-d32652a9947b', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'essay', '{"text": "31432", "explanation": "324"}', NULL, 1.00, 3, '{qe2323}', false, '2026-03-12 08:14:09.576184+00', '2026-03-12 08:17:12.810146+00'),
	('ed8e2918-0e7f-41e6-afba-5ce12c73c80d', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "124321412"}', '{"correct_choice_ids": []}', 1.00, 3, '{1234213}', false, '2026-03-12 06:40:51.137373+00', '2026-03-12 08:17:28.445705+00'),
	('492e3a44-498a-4b88-a997-931acfa41e6c', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "1342134", "explanation": "3241243"}', '{"correct_choice_ids": [1]}', 1.00, 5, '{}', false, '2026-03-12 06:40:00.410032+00', '2026-03-12 08:17:31.927608+00'),
	('d1f602b1-059f-450c-a0c3-446f7ce9a3be', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"explanation": "31231", "override_text": "123q2r3"}', '{"correct_choice_ids": [0]}', 1.00, 4, '{123}', false, '2026-03-12 08:46:59.101189+00', '2026-03-12 08:46:59.101189+00'),
	('13e51e09-aa34-4500-8512-ac8677b9c6a4', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"override_text": "Một cửa hàng có 5 bao gạo, mỗi bao nặng 20kg. Cửa hàng đã bán được 65kg gạo. Hỏi cửa hàng còn lại bao nhiêu ki-lô-gam gạo?"}', '{"correct_choice_ids": [2]}', 1.00, 3, '{"toán lớp 3","bài toán có lời văn","phép nhân","phép trừ"}', false, '2026-03-12 08:48:25.21559+00', '2026-03-12 08:48:25.21559+00'),
	('8e416e65-c9e9-4417-bec1-07c3a91ce252', 'd810df06-78c5-441c-8eaf-90e6e505adad', 'multiple_choice', '{"text": "2+2=?"}', '{"correct_choice_ids": []}', 1.00, NULL, '{}', false, '2026-02-04 09:22:46.863589+00', '2026-03-12 17:31:16.336256+00');


--
-- Data for Name: assignment_questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."assignment_questions" ("id", "assignment_id", "question_id", "custom_content", "points", "rubric", "order_idx") VALUES
	('2a5c3ee0-7337-4fd6-9b7f-2bafe94a57ed', 'b7378904-1541-4504-912e-563e46c1950e', '8e416e65-c9e9-4417-bec1-07c3a91ce252', '{"type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "2", "isCorrect": false}, {"id": 1, "text": "4", "isCorrect": false}, {"id": 2, "text": "5", "isCorrect": false}], "override_text": "2+2=?"}', 0.17, NULL, 1),
	('77573fb2-2e24-4ffa-899d-b52964273f94', 'b7378904-1541-4504-912e-563e46c1950e', NULL, '{"type": "math", "hints": [], "override_text": "Một người có 45 viên bi. Người đó cho bạn 1/3 số bi. Hỏi người đó còn lại bao nhiêu viên bi?"}', 0.20, NULL, 2),
	('76409777-8348-4589-9e41-663ae3d3c814', 'b7378904-1541-4504-912e-563e46c1950e', NULL, '{"type": "math", "hints": [], "override_text": "Một hình chữ nhật có chiều dài 12cm và chiều rộng bằng 1/4 chiều dài. Tính diện tích của hình chữ nhật đó."}', 0.20, NULL, 3),
	('718f8aa8-8ecf-48c2-a0ad-c44802bbb5d5', 'b7378904-1541-4504-912e-563e46c1950e', NULL, '{"type": "math", "hints": [], "override_text": "Có 3 thùng kẹo, mỗi thùng có 25 viên kẹo. Nếu chia đều số kẹo này cho 5 bạn, mỗi bạn sẽ được bao nhiêu viên kẹo?"}', 0.20, NULL, 4),
	('357c2099-7c6f-4796-a20b-ecff60a21344', 'b7378904-1541-4504-912e-563e46c1950e', NULL, '{"type": "math", "hints": [], "override_text": "Tìm số còn thiếu trong dãy số sau: 2, 6, 12, 20, __, 42."}', 0.20, NULL, 5),
	('84288619-2a2a-4e3a-916b-9372485e6049', 'b7378904-1541-4504-912e-563e46c1950e', NULL, '{"type": "math", "hints": [], "override_text": "Một người đi xe đạp từ nhà đến chợ mất 30 phút. Nếu người đó đi với vận tốc nhanh gấp đôi, hỏi người đó sẽ mất bao nhiêu phút để đến chợ?"}', 0.20, NULL, 6),
	('cab6d37b-00f2-4561-a0cf-6fc21fc014c1', 'b7378904-1541-4504-912e-563e46c1950e', NULL, '{"type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "25 kg", "isCorrect": false}, {"id": 1, "text": "45 kg", "isCorrect": false}, {"id": 2, "text": "35 kg", "isCorrect": true}, {"id": 3, "text": "165 kg", "isCorrect": false}], "override_text": "Một cửa hàng có 5 bao gạo, mỗi bao nặng 20kg. Cửa hàng đã bán được 65kg gạo. Hỏi cửa hàng còn lại bao nhiêu ki-lô-gam gạo?"}', 0.17, NULL, 7),
	('dba1cb68-2c11-4cf1-b867-315a0eb9c068', 'b7378904-1541-4504-912e-563e46c1950e', NULL, '{"type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "6", "isCorrect": false}, {"id": 1, "text": "7", "isCorrect": true}, {"id": 2, "text": "8", "isCorrect": false}, {"id": 3, "text": "9", "isCorrect": false}], "override_text": "Tìm X, biết: X x 7 = 49"}', 0.17, NULL, 8),
	('dbdbe9e6-69c4-4ac5-a885-a138eebb6734', 'b7378904-1541-4504-912e-563e46c1950e', NULL, '{"type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "16 cm", "isCorrect": false}, {"id": 1, "text": "24 cm", "isCorrect": false}, {"id": 2, "text": "64 cm", "isCorrect": false}, {"id": 3, "text": "32 cm", "isCorrect": true}], "override_text": "Một hình vuông có cạnh dài 8cm. Tính chu vi của hình vuông đó."}', 0.17, NULL, 9),
	('1db16fdf-8787-4c90-a3aa-f14ddc7698dc', 'b7378904-1541-4504-912e-563e46c1950e', NULL, '{"type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "400", "isCorrect": false}, {"id": 1, "text": "490", "isCorrect": false}, {"id": 2, "text": "500", "isCorrect": true}, {"id": 3, "text": "510", "isCorrect": false}], "override_text": "Kết quả của phép tính 125 + 375 là:"}', 0.17, NULL, 10),
	('ef696c88-1bb9-4095-9bcd-f60d15da5dc0', 'b7378904-1541-4504-912e-563e46c1950e', NULL, '{"type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "345", "isCorrect": false}, {"id": 1, "text": "435", "isCorrect": false}, {"id": 2, "text": "354", "isCorrect": false}, {"id": 3, "text": "453", "isCorrect": true}], "override_text": "Số lớn nhất trong các số: 345, 435, 354, 453 là:"}', 0.17, NULL, 11),
	('a38edd4c-473b-4c8f-a3fa-c0a6022861a7', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', NULL, '{"tags": ["Flutter", "Data Types", "var", "dynamic"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "`var` chỉ dùng cho số, `dynamic` cho chuỗi.", "isCorrect": false}, {"id": 1, "text": "`dynamic` nhanh hơn `var`.", "isCorrect": false}, {"id": 2, "text": "`var` suy luận kiểu lúc biên dịch, `dynamic` kiểm tra kiểu lúc chạy.", "isCorrect": true}, {"id": 3, "text": "Không có sự khác biệt.", "isCorrect": false}], "difficulty": 3, "explanation": "", "override_text": "Sự khác biệt chính giữa `var` và `dynamic` trong Dart/Flutter là gì?", "learningObjectives": []}', 1.00, NULL, 6),
	('94773762-7bbb-4777-97d7-4855daf7fe5d', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', NULL, '{"tags": ["Flutter", "Data Types", "Boolean"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "bool", "isCorrect": true}, {"id": 1, "text": "int", "isCorrect": false}, {"id": 2, "text": "String", "isCorrect": false}, {"id": 3, "text": "double", "isCorrect": false}], "difficulty": 3, "explanation": "", "override_text": "Kiểu dữ liệu nào trong Dart/Flutter được sử dụng để lưu trữ giá trị đúng hoặc sai?", "learningObjectives": []}', 1.00, NULL, 2),
	('04d5d507-82ef-4438-893c-325b6fb1fda4', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', NULL, '{"tags": ["Flutter", "Data Types", "Integer"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "string", "isCorrect": false}, {"id": 1, "text": "boolean", "isCorrect": false}, {"id": 2, "text": "int", "isCorrect": true}, {"id": 3, "text": "float", "isCorrect": false}], "difficulty": 3, "explanation": "", "override_text": "Để khai báo một biến kiểu số nguyên trong Flutter, bạn sử dụng từ khóa nào?", "learningObjectives": []}', 1.00, NULL, 3),
	('9ba82923-239b-4e0b-ac05-ec2debe02e72', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', NULL, '{"tags": ["Flutter", "Data Types", "Double"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Số nguyên", "isCorrect": false}, {"id": 1, "text": "Chuỗi ký tự", "isCorrect": false}, {"id": 2, "text": "Giá trị đúng/sai", "isCorrect": false}, {"id": 3, "text": "Số thực dấu phẩy động", "isCorrect": true}], "difficulty": 3, "explanation": "", "override_text": "Kiểu dữ liệu `double` trong Flutter dùng để lưu trữ loại giá trị nào?", "learningObjectives": []}', 1.00, NULL, 4),
	('662b8674-c721-4176-9b5d-28f196d53a98', '1a5970b0-a790-4ec3-b20f-6b07f8671d7c', NULL, '{"tags": ["toan", "lop3"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "x = 1", "isCorrect": false}, {"id": 1, "text": "x = 3", "isCorrect": true}, {"id": 2, "text": "x = 5", "isCorrect": false}, {"id": 3, "text": "x = 7", "isCorrect": false}], "difficulty": 3, "explanation": "", "override_text": "Tìm số nguyên dương x sao cho 2x + 5 = 11", "learningObjectives": []}', 1.00, NULL, 1),
	('a7302f6c-108e-4921-8411-df72b7b3c0ac', '1a5970b0-a790-4ec3-b20f-6b07f8671d7c', NULL, '{"tags": ["toan", "lop3"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "x = 1", "isCorrect": false}, {"id": 1, "text": "x = 2", "isCorrect": true}, {"id": 2, "text": "x = 3", "isCorrect": false}, {"id": 3, "text": "x = 4", "isCorrect": false}], "difficulty": 3, "explanation": "", "override_text": "Tìm số nguyên dương x sao cho 3x - 2 = 7", "learningObjectives": []}', 1.00, NULL, 4),
	('4bd34fdc-70af-43db-b43d-7d4e30e4c4e5', '1a5970b0-a790-4ec3-b20f-6b07f8671d7c', NULL, '{"tags": ["toan", "lop3"], "type": "essay", "hints": [], "difficulty": 3, "explanation": "", "override_text": "Viết lại các phép tính sau dưới dạng toán học", "learningObjectives": []}', 1.00, NULL, 3),
	('6af629dd-3332-4e2b-880f-f17cb8f420ee', 'f9f717a1-d750-41b3-8c17-9a963b732a18', '492e3a44-498a-4b88-a997-931acfa41e6c', '{"tags": [], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "afeaf", "isCorrect": false}, {"id": 1, "text": "werqr23", "isCorrect": true}], "difficulty": 5, "explanation": "3241243", "override_text": "1342134", "learningObjectives": []}', 5.00, NULL, 1),
	('67fa1869-999f-4b42-8cdb-476c9a2aa609', 'f9f717a1-d750-41b3-8c17-9a963b732a18', 'd1f602b1-059f-450c-a0c3-446f7ce9a3be', '{"tags": ["123"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "124234", "isCorrect": true}, {"id": 1, "text": "r23r", "isCorrect": false}, {"id": 2, "text": "234", "isCorrect": false}], "difficulty": 4, "explanation": "31231", "override_text": "123q2r3", "learningObjectives": []}', 5.00, NULL, 2),
	('0d3edd31-860f-430d-ba01-78a259a28984', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', NULL, '{"tags": ["Flutter", "Data Types", "Dynamic"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "dynamic", "isCorrect": true}, {"id": 1, "text": "var", "isCorrect": false}, {"id": 2, "text": "object", "isCorrect": false}, {"id": 3, "text": "any", "isCorrect": false}], "difficulty": 3, "explanation": "", "override_text": "Trong Flutter, bạn sử dụng từ khóa nào để khai báo một biến có thể nhận bất kỳ kiểu dữ liệu nào?", "learningObjectives": []}', 1.00, NULL, 5),
	('c98d626a-4436-4c75-8da8-366db32005e7', 'e0ff7227-ed43-409f-a405-87bf2cf698ee', NULL, '{"tags": ["Dart"], "type": "multiple_choice", "choices": [{"id": 0, "text": "int", "isCorrect": true}, {"id": 1, "text": "string", "isCorrect": false}, {"id": 2, "text": "bool", "isCorrect": false}, {"id": 3, "text": "list", "isCorrect": false}], "difficulty": 3, "override_text": "Câu hỏi 1"}', 1.00, NULL, 1),
	('ed1042ad-b72b-42b7-b542-5b45074ffb19', 'e0ff7227-ed43-409f-a405-87bf2cf698ee', NULL, '{"tags": ["Flutter"], "type": "multiple_choice", "choices": [{"id": 0, "text": "StatelessWidget", "isCorrect": true}, {"id": 1, "text": "StatefulWidget", "isCorrect": false}, {"id": 2, "text": "MaterialApp", "isCorrect": false}, {"id": 3, "text": "Scaffold", "isCorrect": false}], "difficulty": 3, "override_text": "Câu hỏi 2"}', 1.00, NULL, 2),
	('d0dccfba-d692-4fb5-b8ba-921f448da3dc', 'e0ff7227-ed43-409f-a405-87bf2cf698ee', NULL, '{"tags": ["Dart"], "type": "multiple_choice", "choices": [{"id": 0, "text": "true", "isCorrect": true}, {"id": 1, "text": "false", "isCorrect": false}], "difficulty": 3, "override_text": "Câu hỏi 3"}', 1.00, NULL, 3),
	('134b53bd-ab04-4282-9d31-36aa5eedf604', 'e0ff7227-ed43-409f-a405-87bf2cf698ee', NULL, '{"tags": ["Flutter"], "type": "short_answer", "difficulty": 3, "override_text": "Câu hỏi 4"}', 1.00, NULL, 4),
	('a3af1dba-26f8-46fa-a11f-554d3e38c61a', 'e0ff7227-ed43-409f-a405-87bf2cf698ee', NULL, '{"tags": ["Flutter"], "type": "multiple_choice", "difficulty": 3, "override_text": "Câu hỏi 5"}', 1.00, NULL, 5),
	('6b26ac3f-ddc1-45e7-a916-d4d1cd695c51', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', NULL, '{"tags": ["Flutter", "Data Types", "String"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "int", "isCorrect": false}, {"id": 1, "text": "String", "isCorrect": true}, {"id": 2, "text": "bool", "isCorrect": false}, {"id": 3, "text": "double", "isCorrect": false}], "difficulty": 3, "explanation": "", "override_text": "Trong Flutter, kiểu dữ liệu nào được sử dụng để lưu trữ một chuỗi ký tự?", "learningObjectives": []}', 1.00, NULL, 1),
	('2a45fc4f-ae41-42e5-abd7-98292aa27fa0', '7983b234-5899-42e9-92cf-1ddd65a52e91', NULL, '{"tags": ["Supabase", "Flutter", "Deployment"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Sử dụng biến môi trường (environment variables) và một file `.env` được loại trừ khỏi Git.", "isCorrect": true}, {"id": 1, "text": "Nhúng trực tiếp các khóa API vào mã nguồn Dart của ứng dụng.", "isCorrect": false}, {"id": 2, "text": "Lưu trữ khóa API trong local storage của trình duyệt.", "isCorrect": false}, {"id": 3, "text": "Gửi khóa API qua URL parameters mỗi khi thực hiện một request.", "isCorrect": false}], "difficulty": 4, "explanation": "", "override_text": "Khi triển khai ứng dụng Flutter lên Supabase, bạn nên sử dụng chiến lược nào để quản lý các khóa API một cách an toàn, đặc biệt là các khóa `SUPABASE_URL` và `SUPABASE_ANON_KEY`?", "learningObjectives": []}', 1.00, NULL, 1),
	('3160f2f0-89f2-4147-8a0f-72f1b2a367b1', '7983b234-5899-42e9-92cf-1ddd65a52e91', NULL, '{"tags": ["Supabase", "CORS", "Flutter"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Tắt hoàn toàn CORS để cho phép tất cả các nguồn truy cập.", "isCorrect": false}, {"id": 1, "text": "Cho phép domain của ứng dụng Flutter (ví dụ: `https://your-app.com`) trong cài đặt CORS của Supabase.", "isCorrect": true}, {"id": 2, "text": "Chỉ cho phép các request từ localhost.", "isCorrect": false}, {"id": 3, "text": "Không cần cấu hình CORS vì Supabase tự động xử lý.", "isCorrect": false}], "difficulty": 4, "explanation": "", "override_text": "Để đảm bảo ứng dụng Flutter hoạt động chính xác sau khi triển khai lên Supabase, bạn cần cấu hình CORS (Cross-Origin Resource Sharing) như thế nào?", "learningObjectives": []}', 1.00, NULL, 2),
	('8f42e977-23d8-45e1-bf3f-537d3a1ef9d7', '7983b234-5899-42e9-92cf-1ddd65a52e91', NULL, '{"tags": ["Supabase", "Functions", "Authentication"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Supabase functions tự động xác thực người dùng dựa trên session của ứng dụng Flutter.", "isCorrect": false}, {"id": 1, "text": "Không cần xác thực người dùng trong Supabase functions để giảm độ phức tạp.", "isCorrect": false}, {"id": 2, "text": "Cần xác thực người dùng trong Supabase functions bằng cách kiểm tra JWT (JSON Web Token) được gửi từ ứng dụng Flutter.", "isCorrect": true}, {"id": 3, "text": "Sử dụng một khóa bí mật (secret key) được chia sẻ giữa ứng dụng Flutter và Supabase function.", "isCorrect": false}], "difficulty": 4, "explanation": "", "override_text": "Khi sử dụng Supabase functions để thực hiện các tác vụ backend cho ứng dụng Flutter, bạn cần chú ý điều gì về xác thực (authentication) người dùng?", "learningObjectives": []}', 1.00, NULL, 3),
	('ee353ef1-5ed9-4ee9-ab5e-7f8e667c462c', '7983b234-5899-42e9-92cf-1ddd65a52e91', NULL, '{"tags": ["Supabase", "Database", "Flutter"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "PostgreSQL.", "isCorrect": true}, {"id": 1, "text": "Realtime database.", "isCorrect": false}, {"id": 2, "text": "Edge Functions.", "isCorrect": false}, {"id": 3, "text": "Object Storage.", "isCorrect": false}], "difficulty": 4, "explanation": "", "override_text": "Bạn nên sử dụng loại cơ sở dữ liệu nào của Supabase để lưu trữ dữ liệu có cấu trúc và mối quan hệ phức tạp trong ứng dụng Flutter?", "learningObjectives": []}', 1.00, NULL, 4),
	('f4c2ab8f-4f94-4a82-9716-b87bc8b52ce0', '7983b234-5899-42e9-92cf-1ddd65a52e91', NULL, '{"tags": ["Supabase", "Performance", "Flutter"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Truy vấn tất cả dữ liệu mỗi lần và lọc ở phía ứng dụng Flutter.", "isCorrect": false}, {"id": 1, "text": "Sử dụng indexes trên các cột được truy vấn thường xuyên.", "isCorrect": true}, {"id": 2, "text": "Vô hiệu hóa tất cả các triggers cơ sở dữ liệu.", "isCorrect": false}, {"id": 3, "text": "Sử dụng raw SQL queries thay vì ORM.", "isCorrect": false}], "difficulty": 4, "explanation": "", "override_text": "Khi triển khai ứng dụng Flutter lên Supabase, làm thế nào bạn có thể tối ưu hóa hiệu suất truy vấn cơ sở dữ liệu?", "learningObjectives": []}', 1.00, NULL, 5),
	('d936ced1-00fe-41d7-a3cf-d13d5f1530ed', '7983b234-5899-42e9-92cf-1ddd65a52e91', NULL, '{"tags": ["Supabase", "Schema", "Flutter"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Sử dụng migrations để theo dõi và áp dụng các thay đổi schema.", "isCorrect": true}, {"id": 1, "text": "Thực hiện thay đổi schema trực tiếp trên production database.", "isCorrect": false}, {"id": 2, "text": "Xóa và tạo lại cơ sở dữ liệu mỗi khi có thay đổi schema.", "isCorrect": false}, {"id": 3, "text": "Không cần quản lý schema, Supabase tự động xử lý.", "isCorrect": false}], "difficulty": 4, "explanation": "", "override_text": "Trong quá trình phát triển và triển khai ứng dụng Flutter sử dụng Supabase, bạn cần làm gì để quản lý schema cơ sở dữ liệu một cách hiệu quả?", "learningObjectives": []}', 1.00, NULL, 6),
	('33437673-3004-4b83-b222-9706774ab003', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', NULL, '{"tags": ["Flutter", "Data Types", "List"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Set", "isCorrect": false}, {"id": 1, "text": "List", "isCorrect": true}, {"id": 2, "text": "Map", "isCorrect": false}, {"id": 3, "text": "Tuple", "isCorrect": false}], "difficulty": 3, "explanation": "", "override_text": "Trong Flutter, kiểu dữ liệu nào được sử dụng để biểu diễn một danh sách các đối tượng có cùng kiểu dữ liệu?", "learningObjectives": []}', 1.00, NULL, 7),
	('05e10c3d-145c-49a7-a562-92638909d6d2', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', NULL, '{"tags": ["Flutter", "Data Types", "Map"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Lưu trữ một chuỗi ký tự duy nhất.", "isCorrect": false}, {"id": 1, "text": "Lưu trữ một danh sách các số nguyên.", "isCorrect": false}, {"id": 2, "text": "Lưu trữ một giá trị boolean.", "isCorrect": false}, {"id": 3, "text": "Lưu trữ các cặp key-value.", "isCorrect": true}], "difficulty": 3, "explanation": "", "override_text": "Kiểu dữ liệu `Map` trong Dart/Flutter dùng để làm gì?", "learningObjectives": []}', 1.00, NULL, 8),
	('f6f4ff9f-3c92-4f0f-8a28-77d042fc78ba', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', NULL, '{"tags": ["Flutter", "Data Types", "Set"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Set", "isCorrect": true}, {"id": 1, "text": "List", "isCorrect": false}, {"id": 2, "text": "Map", "isCorrect": false}, {"id": 3, "text": "Array", "isCorrect": false}], "difficulty": 3, "explanation": "", "override_text": "Trong Dart/Flutter, kiểu dữ liệu nào biểu diễn một tập hợp các giá trị duy nhất?", "learningObjectives": []}', 1.00, NULL, 9),
	('8c09d9bd-6dbf-492f-b59c-9bc48917c900', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', NULL, '{"tags": ["Flutter", "Data Types", "Declaration"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "int number = 3.14;", "isCorrect": false}, {"id": 1, "text": "number = 3.14;", "isCorrect": false}, {"id": 2, "text": "double number = 3.14;", "isCorrect": true}, {"id": 3, "text": "String number = ''3.14'';", "isCorrect": false}], "difficulty": 3, "explanation": "", "override_text": "Biến nào sau đây được khai báo đúng cách trong Flutter/Dart để lưu trữ số thập phân?", "learningObjectives": []}', 1.00, NULL, 10),
	('606c25f0-4d66-45ff-a6a6-7f1a24b095d1', 'd16fb952-7eb3-405d-9cd3-a1aa82362bae', 'ecf48338-cce1-4ded-bb48-21f8b7725b4c', '{"tags": [], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "2", "isCorrect": false}, {"id": 1, "text": "4", "isCorrect": false}, {"id": 2, "text": "6", "isCorrect": false}, {"id": 3, "text": "8", "isCorrect": true}], "difficulty": 1, "explanation": "", "override_text": "4+4=?", "learningObjectives": []}', 1.00, NULL, 1),
	('ac700f94-1922-41e0-92b9-e0c6854ff5be', '7983b234-5899-42e9-92cf-1ddd65a52e91', NULL, '{"tags": ["Supabase", "Debugging", "Flutter"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Chỉ sử dụng `print()` statements trong mã Flutter.", "isCorrect": false}, {"id": 1, "text": "Sử dụng trình gỡ lỗi của trình duyệt web.", "isCorrect": false}, {"id": 2, "text": "Sử dụng Supabase dashboard để xem logs và metrics.", "isCorrect": true}, {"id": 3, "text": "Không có công cụ nào để theo dõi sau khi triển khai.", "isCorrect": false}], "difficulty": 4, "explanation": "", "override_text": "Để kiểm tra và gỡ lỗi ứng dụng Flutter kết nối với Supabase sau khi triển khai, bạn sử dụng công cụ nào để theo dõi các request và lỗi?", "learningObjectives": []}', 1.00, NULL, 7),
	('d56837c3-2127-41e2-8af3-1d23c23b2fc0', '7983b234-5899-42e9-92cf-1ddd65a52e91', NULL, '{"tags": ["Supabase", "Auth", "Flutter"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Redirect URL của ứng dụng Flutter (ví dụ: `myapp://callback`).", "isCorrect": true}, {"id": 1, "text": "URL của Supabase project.", "isCorrect": false}, {"id": 2, "text": "URL của Google Sign-In.", "isCorrect": false}, {"id": 3, "text": "Không cần cấu hình redirect URL.", "isCorrect": false}], "difficulty": 4, "explanation": "", "override_text": "Khi triển khai ứng dụng Flutter sử dụng Supabase Auth, bạn cần cấu hình redirect URL nào?", "learningObjectives": []}', 1.00, NULL, 8),
	('0e6f8702-3d19-43be-8980-9e99a097755b', '7983b234-5899-42e9-92cf-1ddd65a52e91', NULL, '{"tags": ["Supabase", "Security", "Flutter"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "CORS (Cross-Origin Resource Sharing).", "isCorrect": false}, {"id": 1, "text": "Row Level Security (RLS).", "isCorrect": true}, {"id": 2, "text": "Biến môi trường (environment variables).", "isCorrect": false}, {"id": 3, "text": "HTTPS.", "isCorrect": false}], "difficulty": 4, "explanation": "", "override_text": "Để đảm bảo tính bảo mật của dữ liệu trong ứng dụng Flutter sử dụng Supabase, bạn nên sử dụng tính năng nào của Supabase để kiểm soát quyền truy cập?", "learningObjectives": []}', 1.00, NULL, 9),
	('ef4fa8a5-c547-4eae-99d1-1ba7fc02c66b', '7983b234-5899-42e9-92cf-1ddd65a52e91', NULL, '{"tags": ["Supabase", "Storage", "Flutter"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "Sử dụng Row Level Security (RLS) để kiểm soát quyền truy cập dựa trên ID người dùng.", "isCorrect": true}, {"id": 1, "text": "Lưu trữ tất cả các tệp tin công khai.", "isCorrect": false}, {"id": 2, "text": "Sử dụng một khóa bí mật (secret key) để mã hóa các tệp tin.", "isCorrect": false}, {"id": 3, "text": "Không cần kiểm soát quyền truy cập, Supabase tự động xử lý.", "isCorrect": false}], "difficulty": 4, "explanation": "", "override_text": "Khi sử dụng Supabase Storage để lưu trữ hình ảnh và tệp tin cho ứng dụng Flutter, bạn cần làm gì để đảm bảo người dùng chỉ có thể truy cập tệp tin của riêng mình?", "learningObjectives": []}', 1.00, NULL, 10),
	('b7a68d40-5186-416b-a6b9-4928fb12f76a', '1a5970b0-a790-4ec3-b20f-6b07f8671d7c', NULL, '{"tags": ["toan", "lop3"], "type": "multiple_choice", "hints": [], "choices": [{"id": 0, "text": "2(3) + 5 = 11", "isCorrect": true}, {"id": 1, "text": "2(3) + 5 = 10", "isCorrect": false}, {"id": 2, "text": "2(3) + 5 = 6", "isCorrect": false}, {"id": 3, "text": "2(3) + 5 = 8", "isCorrect": false}], "difficulty": 3, "explanation": "", "override_text": "Tinh gia tri cua bieu thuc 2x + 5 khi x = 3", "learningObjectives": []}', 1.00, NULL, 2);


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profiles" ("id", "full_name", "role", "avatar_url", "bio", "metadata", "updated_at", "phone", "gender") VALUES
	('d0fab6ce-74bf-4b57-8299-cd9a5bfdb480', 'Khánh Toàn', 'student', NULL, NULL, NULL, '2026-02-04 09:08:42.304429+00', '0986658863', 'male'),
	('a874ce65-1214-42b0-86b6-20ed5a36a49f', 'A', 'admin', NULL, NULL, NULL, '2026-02-04 09:13:56.435031+00', '0900900990', 'male'),
	('6af4527c-8caa-4903-bb50-dbadcf1778d4', 'B', 'teacher', NULL, NULL, NULL, '2026-02-04 09:14:49.749861+00', '0900900090', 'male'),
	('dcb2cce8-f8d5-440f-ae53-1e39a260254b', 'Trần Văn Thắng', 'teacher', NULL, NULL, NULL, '2026-02-05 00:56:34.505751+00', '0855363050', 'male'),
	('d810df06-78c5-441c-8eaf-90e6e505adad', 'Thái Anh Huy', 'teacher', NULL, NULL, '{"ai": {"model": "llama-3.1-8b-instant", "provider": "groq"}, "api_keys": {"groq": "REDACTED_GROQ_API_KEY", "gemini": "AIzaSyAxq7SUSpxjYlqK8kISDLwx7UWp43Bdbac"}}', '2026-03-08 16:19:01.592091+00', '0123456987', 'male'),
	('f2e3f942-8f0e-464f-b386-7adcc8e90243', 'djidađ', 'student', NULL, NULL, NULL, '2025-12-28 17:13:38.633076+00', NULL, NULL),
	('6c8533ea-659f-46f1-9c7d-59768ea871d2', 'huhiadf', 'student', NULL, NULL, NULL, '2025-12-28 17:16:37.367299+00', NULL, NULL),
	('7d26a7e2-b16b-4c4e-93df-4061076f4786', 'kien', 'student', NULL, NULL, NULL, '2025-12-28 17:53:24.669755+00', NULL, NULL),
	('381068fc-5eef-4350-ae44-1e65dd28d02c', 'kllllolkkk', 'teacher', NULL, NULL, NULL, '2026-01-13 06:08:02.409796+00', NULL, NULL),
	('af06a4fd-9e7f-411d-b801-4b6aca63fca1', 'Thái Anh Huy', 'admin', NULL, NULL, NULL, '2025-12-15 13:41:32.453363+00', '0123456789', 'male'),
	('076de02d-75ba-4e79-898d-1b5e43141894', 'Nguyễn Khánh Toàn', 'student', NULL, NULL, NULL, '2025-12-15 16:04:13.651004+00', '0987654321', 'male'),
	('7d467ecf-0c8b-4b1f-9506-6ae7cd83a3d5', 'Trương Thị Thư', 'teacher', NULL, NULL, NULL, '2025-12-22 02:46:20.658109+00', '0912345678', 'female'),
	('def12bef-7d75-48ac-a3f8-3427ede277ec', 'Lữ Quang Thái', 'student', NULL, NULL, NULL, '2025-12-28 16:35:02.652844+00', '0987123456', 'male'),
	('61d5066a-4827-44bd-a05c-43f2d62c3213', 'Kieu Manh Trinh', 'student', NULL, NULL, NULL, '2025-12-28 16:42:13.820488+00', '0912345678', 'female'),
	('91a6b04f-45ae-4038-9a43-7a0304d68552', 'Trần Văn Nam', 'student', NULL, NULL, NULL, '2026-01-13 06:56:23.498689+00', NULL, NULL);


--
-- Data for Name: work_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."work_sessions" ("id", "assignment_distribution_id", "assignment_id", "student_id", "started_at", "submitted_at", "attempt", "status", "time_spent_seconds", "created_at", "updated_at") VALUES
	('40950c84-5f66-4457-b68b-72919e29bbd7', 'b9dcbc49-98d5-4924-b9bc-9727ae196564', '7983b234-5899-42e9-92cf-1ddd65a52e91', '076de02d-75ba-4e79-898d-1b5e43141894', NULL, '2026-03-21 17:50:46.350073+00', 1, 'submitted', 0, '2026-03-21 10:50:02.749474+00', '2026-03-21 17:50:46.350073+00'),
	('3dfdc594-2050-4820-aad8-fa1b2a820f9e', '0f323291-838b-4779-b75b-6910cbcf45b7', '7983b234-5899-42e9-92cf-1ddd65a52e91', '076de02d-75ba-4e79-898d-1b5e43141894', NULL, '2026-03-22 15:06:57.018769+00', 1, 'graded', 0, '2026-03-20 07:13:40.674481+00', '2026-03-22 08:08:39.791776+00'),
	('5475849c-d838-4a6a-9509-545b6080e492', '53e37693-058b-4e43-9bdf-5ce1b917781b', '1a5970b0-a790-4ec3-b20f-6b07f8671d7c', '076de02d-75ba-4e79-898d-1b5e43141894', NULL, '2026-03-10 21:17:08.677678+00', 1, 'in_progress', 0, '2026-03-08 10:30:51.981048+00', '2026-03-10 21:17:08.677678+00'),
	('440def24-7240-4496-8ea4-183cd1dd6d27', '8a277cc5-0a2d-472e-8318-9d660a2bc748', 'b7378904-1541-4504-912e-563e46c1950e', '076de02d-75ba-4e79-898d-1b5e43141894', NULL, '2026-03-10 21:48:56.331731+00', 1, 'in_progress', 0, '2026-03-08 11:08:23.521507+00', '2026-03-10 21:48:56.331731+00'),
	('af3ab11b-ee21-4645-b678-b759d6e10357', '5df28496-4898-4142-998c-3defa720c3d7', 'f9f717a1-d750-41b3-8c17-9a963b732a18', '076de02d-75ba-4e79-898d-1b5e43141894', NULL, '2026-03-12 18:20:24.268568+00', 1, 'graded', 0, '2026-03-12 08:55:40.633539+00', '2026-03-16 10:00:56.778959+00'),
	('6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', 'f761378d-b9b9-427d-b50f-60a644d3fa09', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', '076de02d-75ba-4e79-898d-1b5e43141894', NULL, '2026-03-21 15:59:05.95407+00', 1, 'graded', 0, '2026-03-05 13:32:10.868611+00', '2026-03-21 10:48:58.203394+00');


--
-- Data for Name: submission_answers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."submission_answers" ("id", "session_id", "assignment_question_id", "answer", "files", "flagged", "ai_score", "ai_confidence", "final_score", "ai_feedback", "teacher_feedback", "graded_by", "graded_at", "created_at", "updated_at") VALUES
	('7b949001-8a9a-48a9-9e44-fbe1df284584', 'af3ab11b-ee21-4645-b678-b759d6e10357', '6af629dd-3332-4e2b-880f-f17cb8f420ee', '{"selected_choices": [1]}', NULL, false, NULL, NULL, 5.00, NULL, NULL, NULL, NULL, '2026-03-12 11:20:25.536121+00', '2026-03-12 11:20:25.536121+00'),
	('f5213006-e194-4d09-8c56-b6055641bfd8', '6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', '94773762-7bbb-4777-97d7-4855daf7fe5d', '{"selected_choice_ids": [0]}', NULL, false, NULL, NULL, 1.00, NULL, NULL, NULL, NULL, '2026-03-21 08:59:07.151172+00', '2026-03-21 08:59:07.151172+00'),
	('030b8c14-89b4-40a0-92f0-4c61edbcb1db', '6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', '8c09d9bd-6dbf-492f-b59c-9bc48917c900', '{"selected_choice_ids": [2]}', NULL, false, NULL, NULL, 1.00, NULL, NULL, NULL, NULL, '2026-03-21 08:59:07.362897+00', '2026-03-21 08:59:07.362897+00'),
	('92d08aed-28dd-45b5-b1d3-babc78393076', '6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', 'f6f4ff9f-3c92-4f0f-8a28-77d042fc78ba', '{"selected_choice_ids": [1]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-21 08:59:07.577037+00', '2026-03-21 08:59:07.577037+00'),
	('790b9a59-1acc-498a-afcf-9d07d3a10587', '6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', '05e10c3d-145c-49a7-a562-92638909d6d2', '{"selected_choice_ids": [3]}', NULL, false, NULL, NULL, 1.00, NULL, NULL, NULL, NULL, '2026-03-21 08:59:07.786091+00', '2026-03-21 08:59:07.786091+00'),
	('9eb58ad9-ea7b-4fdf-8afc-5aade1ca9a49', '6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', '33437673-3004-4b83-b222-9706774ab003', '{"selected_choice_ids": [1]}', NULL, false, NULL, NULL, 1.00, NULL, NULL, NULL, NULL, '2026-03-21 08:59:07.99796+00', '2026-03-21 08:59:07.99796+00'),
	('43c085da-ab6c-4a99-be97-a51b1a351d1c', '6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', 'a38edd4c-473b-4c8f-a3fa-c0a6022861a7', '{"selected_choice_ids": [1]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-21 08:59:08.216341+00', '2026-03-21 08:59:08.216341+00'),
	('4baf9bb9-bedb-405b-a21f-377d69e13147', '6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', '0d3edd31-860f-430d-ba01-78a259a28984', '{"selected_choice_ids": [1]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-21 08:59:08.418897+00', '2026-03-21 08:59:08.418897+00'),
	('793a79cc-831d-4fd7-9f48-0d23d1c6d1d0', '6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', '6b26ac3f-ddc1-45e7-a916-d4d1cd695c51', '{"selected_choice_ids": []}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-21 08:59:06.5+00', '2026-03-21 08:59:06.5+00'),
	('deb7c325-8506-4700-a3e4-029352c4f9e6', '40950c84-5f66-4457-b68b-72919e29bbd7', '2a45fc4f-ae41-42e5-abd7-98292aa27fa0', '{"selected_choice_ids": [0]}', NULL, false, NULL, NULL, 1.00, NULL, NULL, NULL, NULL, '2026-03-21 10:50:47.198773+00', '2026-03-21 10:50:47.198773+00'),
	('ca0294de-0ae7-4390-8602-81afa3b1a5a4', '40950c84-5f66-4457-b68b-72919e29bbd7', '3160f2f0-89f2-4147-8a0f-72f1b2a367b1', '{"selected_choice_ids": [0]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-21 10:50:47.40564+00', '2026-03-21 10:50:47.40564+00'),
	('1e011d2f-a6f9-4405-bd2c-6a7eba2156e1', '40950c84-5f66-4457-b68b-72919e29bbd7', '8f42e977-23d8-45e1-bf3f-537d3a1ef9d7', '{"selected_choice_ids": [0]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-21 10:50:47.61654+00', '2026-03-21 10:50:47.61654+00'),
	('0138cba1-b626-4bf8-8aa9-bf664bb31a4a', '40950c84-5f66-4457-b68b-72919e29bbd7', 'ee353ef1-5ed9-4ee9-ab5e-7f8e667c462c', '{"selected_choice_ids": [2]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-21 10:50:47.823906+00', '2026-03-21 10:50:47.823906+00'),
	('4572a5ff-335b-4468-9b9f-ad1832132680', 'af3ab11b-ee21-4645-b678-b759d6e10357', '67fa1869-999f-4b42-8cdb-476c9a2aa609', '{"selected_choices": [0]}', NULL, false, NULL, NULL, 5.00, NULL, '{"comment": "rewt435"}', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-16 06:47:35.32554+00', '2026-03-12 11:20:25.338227+00', '2026-03-16 06:47:35.32554+00'),
	('3db71dec-3d04-47c0-80b6-7f43e790e426', '40950c84-5f66-4457-b68b-72919e29bbd7', 'f4c2ab8f-4f94-4a82-9716-b87bc8b52ce0', '{"selected_choice_ids": [2]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-21 10:50:48.032686+00', '2026-03-21 10:50:48.032686+00'),
	('901e8aa3-c015-43a5-94c0-91364eeeca05', '40950c84-5f66-4457-b68b-72919e29bbd7', 'd936ced1-00fe-41d7-a3cf-d13d5f1530ed', '{"selected_choice_ids": [2]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-21 10:50:48.263211+00', '2026-03-21 10:50:48.263211+00'),
	('3de8539f-d64c-4779-8f9b-d54165fb1026', '40950c84-5f66-4457-b68b-72919e29bbd7', 'ac700f94-1922-41e0-92b9-e0c6854ff5be', '{"selected_choice_ids": [1]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-21 10:50:48.467845+00', '2026-03-21 10:50:48.467845+00'),
	('8dd91851-3108-4389-9d1c-20550e134881', '40950c84-5f66-4457-b68b-72919e29bbd7', 'd56837c3-2127-41e2-8af3-1d23c23b2fc0', '{"selected_choice_ids": [1]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-21 10:50:48.737633+00', '2026-03-21 10:50:48.737633+00'),
	('dfe60b26-d2fb-45b5-9694-a6486f4fb329', '40950c84-5f66-4457-b68b-72919e29bbd7', 'ef4fa8a5-c547-4eae-99d1-1ba7fc02c66b', '{"selected_choice_ids": [0]}', NULL, false, NULL, NULL, 1.00, NULL, NULL, NULL, NULL, '2026-03-21 10:50:48.956181+00', '2026-03-21 10:50:48.956181+00'),
	('e686a2c4-e0d8-4a5a-b01b-1b48fba6d5a8', '40950c84-5f66-4457-b68b-72919e29bbd7', '0e6f8702-3d19-43be-8980-9e99a097755b', '{"selected_choice_ids": [1]}', NULL, false, NULL, NULL, 1.00, NULL, NULL, NULL, NULL, '2026-03-21 10:50:49.165955+00', '2026-03-21 10:50:49.165955+00'),
	('6b58d2c9-bc39-42d5-aae2-c941b7d5a78f', '3dfdc594-2050-4820-aad8-fa1b2a820f9e', 'ef4fa8a5-c547-4eae-99d1-1ba7fc02c66b', '{"selected_choice_ids": [0]}', NULL, false, NULL, NULL, 1.00, NULL, NULL, NULL, NULL, '2026-03-22 08:06:57.888183+00', '2026-03-22 08:06:57.888183+00'),
	('46c4305f-cf24-4b11-a5ab-323865dcd60b', '3dfdc594-2050-4820-aad8-fa1b2a820f9e', '0e6f8702-3d19-43be-8980-9e99a097755b', '{"selected_choice_ids": [0]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-22 08:06:58.11669+00', '2026-03-22 08:06:58.11669+00'),
	('7059c462-c346-4c46-882d-6a0c67cefea6', '3dfdc594-2050-4820-aad8-fa1b2a820f9e', 'd56837c3-2127-41e2-8af3-1d23c23b2fc0', '{"selected_choice_ids": [1]}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-22 08:06:58.316349+00', '2026-03-22 08:06:58.316349+00'),
	('f2306590-0b60-470e-a644-23a3c48d133c', '3dfdc594-2050-4820-aad8-fa1b2a820f9e', '2a45fc4f-ae41-42e5-abd7-98292aa27fa0', '{"selected_choice_ids": []}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-22 08:06:58.718679+00', '2026-03-22 08:06:58.718679+00'),
	('af6b9441-28bd-4bf6-84f5-1119ea186834', '3dfdc594-2050-4820-aad8-fa1b2a820f9e', '3160f2f0-89f2-4147-8a0f-72f1b2a367b1', '{"selected_choice_ids": []}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-22 08:06:58.924058+00', '2026-03-22 08:06:58.924058+00'),
	('3722c255-65f2-4fe2-ac0c-ca785ea12cf7', '3dfdc594-2050-4820-aad8-fa1b2a820f9e', '8f42e977-23d8-45e1-bf3f-537d3a1ef9d7', '{"selected_choice_ids": []}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-22 08:06:59.12202+00', '2026-03-22 08:06:59.12202+00'),
	('892ce782-5032-40f0-8775-f4e8d5d3c32d', '3dfdc594-2050-4820-aad8-fa1b2a820f9e', 'ee353ef1-5ed9-4ee9-ab5e-7f8e667c462c', '{"selected_choice_ids": []}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-22 08:06:59.318701+00', '2026-03-22 08:06:59.318701+00'),
	('6640d4ad-48e1-4ee4-8d4c-84118227c1f5', '3dfdc594-2050-4820-aad8-fa1b2a820f9e', 'f4c2ab8f-4f94-4a82-9716-b87bc8b52ce0', '{"selected_choice_ids": []}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-22 08:06:59.524321+00', '2026-03-22 08:06:59.524321+00'),
	('e27cf5ed-eb49-4926-b839-c027d5bb77eb', '3dfdc594-2050-4820-aad8-fa1b2a820f9e', 'd936ced1-00fe-41d7-a3cf-d13d5f1530ed', '{"selected_choice_ids": []}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-22 08:06:59.737441+00', '2026-03-22 08:06:59.737441+00'),
	('27d915b2-4e51-4fc6-b457-b2da9f546cd0', '3dfdc594-2050-4820-aad8-fa1b2a820f9e', 'ac700f94-1922-41e0-92b9-e0c6854ff5be', '{"selected_choice_ids": []}', NULL, false, NULL, NULL, 0.00, NULL, NULL, NULL, NULL, '2026-03-22 08:06:59.942511+00', '2026-03-22 08:06:59.942511+00'),
	('7929f646-20fe-44c5-a212-a6ebf5967a18', '6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', '04d5d507-82ef-4438-893c-325b6fb1fda4', '{"selected_choice_ids": [2]}', NULL, false, NULL, NULL, 1.00, NULL, '{"text": "ha234"}', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 06:50:06.023+00', '2026-03-21 08:59:06.934042+00', '2026-03-24 06:50:06.023+00'),
	('edd874aa-6962-41ad-83fe-2f8b76f4c589', '6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', '9ba82923-239b-4e0b-ac05-ec2debe02e72', '{"selected_choice_ids": [3]}', NULL, false, NULL, NULL, 1.00, NULL, '{"text": "adá"}', 'd810df06-78c5-441c-8eaf-90e6e505adad', '2026-03-24 07:00:36.473+00', '2026-03-21 08:59:06.716294+00', '2026-03-24 07:00:36.473+00');


--
-- Data for Name: ai_evaluations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: ai_queue; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: ai_recommendations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."ai_recommendations" ("id", "teacher_id", "class_id", "student_id", "type", "priority", "title", "description", "resources", "dismissed", "created_at") VALUES
	('3bfb648f-afcb-4248-a2b6-42ee45ce998c', 'd810df06-78c5-441c-8eaf-90e6e505adad', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', '076de02d-75ba-4e79-898d-1b5e43141894', 'individual', 2, 'TEST: Em nghỉ học 5 buổi liên tiếp', 'Học sinh có tỷ lệ tham gia dưới 70%. Cần kiểm tra và liên hệ gia đình.', '{"videos": ["https://youtube.com"], "documents": [], "exercises": []}', false, '2026-03-23 15:03:50.176453+00'),
	('630eb7a4-d84b-43c3-82cd-52688bdce381', 'd810df06-78c5-441c-8eaf-90e6e505adad', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', '076de02d-75ba-4e79-898d-1b5e43141894', 'individual', 3, 'TEST: Gợi ý bài ôn tập Hình học', 'Học sinh có điểm yếu ở phần Hình học không gian.', '{"videos": [], "documents": ["https://docs.google.com"], "exercises": ["ex2", "ex3"]}', false, '2026-03-22 15:03:50.176453+00'),
	('8419d6a1-f71f-4420-bd5d-59db6a255275', 'd810df06-78c5-441c-8eaf-90e6e505adad', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', '076de02d-75ba-4e79-898d-1b5e43141894', 'individual', 4, 'TEST: Cơ hội cải thiện cho học sinh', 'Học sinh có tiến bộ rõ rệt. Có thể giao bài nâng cao.', '{"videos": [], "documents": [], "exercises": ["ex4"]}', false, '2026-03-20 15:03:50.176453+00'),
	('da2d1440-23c7-44c9-9903-e7c09f367362', 'd810df06-78c5-441c-8eaf-90e6e505adad', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', '076de02d-75ba-4e79-898d-1b5e43141894', 'individual', 5, 'TEST: Cần ôn luyện Đại số', 'Kết quả kiểm tra cho thấy chưa nắm vững Phương trình bậc 2.', '{"videos": ["https://youtube.com"], "documents": [], "exercises": ["ex5"]}', false, '2026-03-18 15:03:50.176453+00'),
	('4abfc614-4c94-45c5-a15f-e2d30859d2ac', 'd810df06-78c5-441c-8eaf-90e6e505adad', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', '076de02d-75ba-4e79-898d-1b5e43141894', 'individual', 2, 'TEST: [DA_AN] Bài đã được giải quyết', 'Bài tập đã được xử lý.', '{"videos": [], "documents": [], "exercises": []}', true, '2026-03-15 15:03:50.176453+00'),
	('61a7fba9-f88c-45bc-83c8-aa006c1e362b', 'd810df06-78c5-441c-8eaf-90e6e505adad', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', NULL, 'class', 3, 'TEST: Lớp cần ôn tập trước kỳ thi', '20/35 học sinh có điểm dưới trung bình.', '{"videos": [], "documents": [], "exercises": ["ex6"]}', false, '2026-03-21 15:03:50.176453+00'),
	('eb1f7a15-6845-44aa-ac3e-0c2db8392f48', 'd810df06-78c5-441c-8eaf-90e6e505adad', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', NULL, 'small_group', 2, 'TEST: 5 học sinh nhóm Yếu cần bổ trợ', 'Nhóm 5 học sinh có điểm thấp nhất lớp.', '{"videos": [], "documents": [], "exercises": []}', false, '2026-03-19 15:03:50.176453+00'),
	('6734a2a2-9365-4981-910e-6a9bf6383bbb', 'd810df06-78c5-441c-8eaf-90e6e505adad', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', '076de02d-75ba-4e79-898d-1b5e43141894', 'individual', 2, 'TEST: Bạn cần ôn Hình học không gian', 'Kết quả học tập gần đây cho thấy cần củng cố Hình học.', '{"videos": ["https://youtube.com"], "documents": [], "exercises": ["ex7"]}', false, '2026-03-24 15:03:50.176453+00'),
	('222af49a-dca5-4c20-a394-cc52e34e2a6a', 'd810df06-78c5-441c-8eaf-90e6e505adad', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', '076de02d-75ba-4e79-898d-1b5e43141894', 'individual', 3, 'TEST: Bài tập Đại số được gợi ý', 'Hệ thống gợi ý bài ôn tập phù hợp với năng lực của bạn.', '{"videos": [], "documents": [], "exercises": ["ex8", "ex9"]}', false, '2026-03-23 15:03:50.176453+00'),
	('83e3318f-d4ff-4115-8fd7-cc75e69ab72c', 'd810df06-78c5-441c-8eaf-90e6e505adad', '1872e253-05cd-4635-a4ec-cf8195fb3f0a', '076de02d-75ba-4e79-898d-1b5e43141894', 'individual', 1, 'TEST: Học sinh cần hỗ trợ khẩn', 'Học sinh có 3 bài tập liên tiếp điểm thấp dưới trung bình. Cần liên hệ phụ huynh.', '{"videos": [], "documents": [], "exercises": ["ex1"]}', true, '2026-03-24 15:03:50.176453+00');


--
-- Data for Name: assignment_variants; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: autosave_answers; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: class_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."class_members" ("class_id", "student_id", "role", "joined_at", "status") VALUES
	('a49750ce-f35a-4fa7-a781-0bebca4ba351', '076de02d-75ba-4e79-898d-1b5e43141894', 'student', '2026-01-28 16:25:10.23899+00', 'approved'),
	('7304b388-6696-41de-81dd-7f28257eb48f', '076de02d-75ba-4e79-898d-1b5e43141894', 'student', '2026-01-28 17:07:05.598827+00', 'pending'),
	('d602cfa2-6af1-4d7b-a37f-49bb49563566', '076de02d-75ba-4e79-898d-1b5e43141894', 'student', '2026-02-04 09:15:57.966747+00', 'pending'),
	('1872e253-05cd-4635-a4ec-cf8195fb3f0a', '076de02d-75ba-4e79-898d-1b5e43141894', 'student', '2026-02-04 09:38:14.517367+00', 'approved');


--
-- Data for Name: class_teachers; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: file_links; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: grade_overrides; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: group_members; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: learning_objectives; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: question_choices; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."question_choices" ("id", "question_id", "content", "is_correct") VALUES
	(0, '8362d950-e419-42a4-ab36-38176fcbd763', '"123"', false),
	(1, '8362d950-e419-42a4-ab36-38176fcbd763', '"123"', true),
	(0, '727ca4e2-237d-48fe-8b13-1bba7cd71d9a', '"123"', false),
	(1, '727ca4e2-237d-48fe-8b13-1bba7cd71d9a', '"241"', true),
	(0, '1a842e4c-138e-4dc5-914d-d75750f6b3fd', '"214"', false),
	(1, '1a842e4c-138e-4dc5-914d-d75750f6b3fd', '""', true),
	(0, '3583e43c-8080-4089-9379-e92007760f39', '"23"', false),
	(1, '3583e43c-8080-4089-9379-e92007760f39', '"23"', true),
	(0, 'a42cc9fe-fbac-4412-9a39-fbc377492f27', '"21"', false),
	(1, 'a42cc9fe-fbac-4412-9a39-fbc377492f27', '"23"', true),
	(0, '443a2292-f4c8-46b3-8532-75ebba81fb30', '""', false),
	(1, '443a2292-f4c8-46b3-8532-75ebba81fb30', '""', true),
	(0, '941469f6-70f0-4d84-aa44-1a741a553198', '"123"', true),
	(1, '941469f6-70f0-4d84-aa44-1a741a553198', '"123"', false),
	(0, '40499302-9252-4fdf-b593-c78f0ee5b00c', '"123"', false),
	(1, '40499302-9252-4fdf-b593-c78f0ee5b00c', '"123"', true),
	(0, 'f4297d4c-b271-4070-a395-426b0d40ff51', '{"text": "int", "image": null}', false),
	(1, 'f4297d4c-b271-4070-a395-426b0d40ff51', '{"text": "String", "image": null}', true),
	(2, 'f4297d4c-b271-4070-a395-426b0d40ff51', '{"text": "bool", "image": null}', false),
	(3, 'f4297d4c-b271-4070-a395-426b0d40ff51', '{"text": "double", "image": null}', false),
	(0, 'f188ec75-3d96-492b-bf42-697aa8bc6078', '{"text": "bool", "image": null}', true),
	(1, 'f188ec75-3d96-492b-bf42-697aa8bc6078', '{"text": "int", "image": null}', false),
	(2, 'f188ec75-3d96-492b-bf42-697aa8bc6078', '{"text": "String", "image": null}', false),
	(3, 'f188ec75-3d96-492b-bf42-697aa8bc6078', '{"text": "double", "image": null}', false),
	(0, '7d766c1b-2cd8-4185-b27e-87c74810da75', '{"text": "string", "image": null}', false),
	(1, '7d766c1b-2cd8-4185-b27e-87c74810da75', '{"text": "boolean", "image": null}', false),
	(2, '7d766c1b-2cd8-4185-b27e-87c74810da75', '{"text": "int", "image": null}', true),
	(3, '7d766c1b-2cd8-4185-b27e-87c74810da75', '{"text": "float", "image": null}', false),
	(0, 'fa185f0f-f250-4d17-9325-f79a545e7756', '{"text": "Số nguyên", "image": null}', false),
	(1, 'fa185f0f-f250-4d17-9325-f79a545e7756', '{"text": "Chuỗi ký tự", "image": null}', false),
	(2, 'fa185f0f-f250-4d17-9325-f79a545e7756', '{"text": "Giá trị đúng/sai", "image": null}', false),
	(3, 'fa185f0f-f250-4d17-9325-f79a545e7756', '{"text": "Số thực dấu phẩy động", "image": null}', true),
	(0, '6941fcc5-5be3-44fa-8c59-eebc257401ef', '{"text": "dynamic", "image": null}', true),
	(1, '6941fcc5-5be3-44fa-8c59-eebc257401ef', '{"text": "var", "image": null}', false),
	(2, '6941fcc5-5be3-44fa-8c59-eebc257401ef', '{"text": "object", "image": null}', false),
	(3, '6941fcc5-5be3-44fa-8c59-eebc257401ef', '{"text": "any", "image": null}', false),
	(0, 'dd13a100-7484-4f6c-bf41-929b8aab26bd', '{"text": "`var` chỉ dùng cho số, `dynamic` cho chuỗi.", "image": null}', false),
	(1, 'dd13a100-7484-4f6c-bf41-929b8aab26bd', '{"text": "`dynamic` nhanh hơn `var`.", "image": null}', false),
	(2, 'dd13a100-7484-4f6c-bf41-929b8aab26bd', '{"text": "`var` suy luận kiểu lúc biên dịch, `dynamic` kiểm tra kiểu lúc chạy.", "image": null}', true),
	(3, 'dd13a100-7484-4f6c-bf41-929b8aab26bd', '{"text": "Không có sự khác biệt.", "image": null}', false),
	(0, '34b5de09-5e77-42fa-ba37-b668df00eb03', '{"text": "Set", "image": null}', false),
	(1, '34b5de09-5e77-42fa-ba37-b668df00eb03', '{"text": "List", "image": null}', true),
	(2, '34b5de09-5e77-42fa-ba37-b668df00eb03', '{"text": "Map", "image": null}', false),
	(3, '34b5de09-5e77-42fa-ba37-b668df00eb03', '{"text": "Tuple", "image": null}', false),
	(0, '3fff1f70-1e35-4ca8-98f7-da7613f1c8de', '{"text": "Lưu trữ một chuỗi ký tự duy nhất.", "image": null}', false),
	(1, '3fff1f70-1e35-4ca8-98f7-da7613f1c8de', '{"text": "Lưu trữ một danh sách các số nguyên.", "image": null}', false),
	(2, '3fff1f70-1e35-4ca8-98f7-da7613f1c8de', '{"text": "Lưu trữ một giá trị boolean.", "image": null}', false),
	(3, '3fff1f70-1e35-4ca8-98f7-da7613f1c8de', '{"text": "Lưu trữ các cặp key-value.", "image": null}', true),
	(0, '746cfd74-b3aa-4304-8263-b0bf6dd4242b', '{"text": "Set", "image": null}', true),
	(1, '746cfd74-b3aa-4304-8263-b0bf6dd4242b', '{"text": "List", "image": null}', false),
	(2, '746cfd74-b3aa-4304-8263-b0bf6dd4242b', '{"text": "Map", "image": null}', false),
	(3, '746cfd74-b3aa-4304-8263-b0bf6dd4242b', '{"text": "Array", "image": null}', false),
	(0, '57f0d55b-5709-4cd0-862e-71d01487d0de', '{"text": "int number = 3.14;", "image": null}', false),
	(1, '57f0d55b-5709-4cd0-862e-71d01487d0de', '{"text": "number = 3.14;", "image": null}', false),
	(2, '57f0d55b-5709-4cd0-862e-71d01487d0de', '{"text": "double number = 3.14;", "image": null}', true),
	(3, '57f0d55b-5709-4cd0-862e-71d01487d0de', '{"text": "String number = ''3.14'';", "image": null}', false),
	(0, 'ecf48338-cce1-4ded-bb48-21f8b7725b4c', '"2"', false),
	(1, 'ecf48338-cce1-4ded-bb48-21f8b7725b4c', '"4"', false),
	(2, 'ecf48338-cce1-4ded-bb48-21f8b7725b4c', '"6"', false),
	(3, 'ecf48338-cce1-4ded-bb48-21f8b7725b4c', '"8"', true),
	(0, '5e70a789-5469-4083-a212-6603c16a959f', '{"text": "Sử dụng biến môi trường (environment variables) và một file `.env` được loại trừ khỏi Git.", "image": null}', true),
	(1, '5e70a789-5469-4083-a212-6603c16a959f', '{"text": "Nhúng trực tiếp các khóa API vào mã nguồn Dart của ứng dụng.", "image": null}', false),
	(2, '5e70a789-5469-4083-a212-6603c16a959f', '{"text": "Lưu trữ khóa API trong local storage của trình duyệt.", "image": null}', false),
	(3, '5e70a789-5469-4083-a212-6603c16a959f', '{"text": "Gửi khóa API qua URL parameters mỗi khi thực hiện một request.", "image": null}', false),
	(0, 'f315cf28-b2ea-445a-9268-374fd5329b30', '{"text": "Tắt hoàn toàn CORS để cho phép tất cả các nguồn truy cập.", "image": null}', false),
	(1, 'f315cf28-b2ea-445a-9268-374fd5329b30', '{"text": "Cho phép domain của ứng dụng Flutter (ví dụ: `https://your-app.com`) trong cài đặt CORS của Supabase.", "image": null}', true),
	(2, 'f315cf28-b2ea-445a-9268-374fd5329b30', '{"text": "Chỉ cho phép các request từ localhost.", "image": null}', false),
	(3, 'f315cf28-b2ea-445a-9268-374fd5329b30', '{"text": "Không cần cấu hình CORS vì Supabase tự động xử lý.", "image": null}', false),
	(0, 'b4bbec70-8ebe-4004-a37f-4eeaabc58212', '{"text": "Supabase functions tự động xác thực người dùng dựa trên session của ứng dụng Flutter.", "image": null}', false),
	(1, 'b4bbec70-8ebe-4004-a37f-4eeaabc58212', '{"text": "Không cần xác thực người dùng trong Supabase functions để giảm độ phức tạp.", "image": null}', false),
	(2, 'b4bbec70-8ebe-4004-a37f-4eeaabc58212', '{"text": "Cần xác thực người dùng trong Supabase functions bằng cách kiểm tra JWT (JSON Web Token) được gửi từ ứng dụng Flutter.", "image": null}', true),
	(3, 'b4bbec70-8ebe-4004-a37f-4eeaabc58212', '{"text": "Sử dụng một khóa bí mật (secret key) được chia sẻ giữa ứng dụng Flutter và Supabase function.", "image": null}', false),
	(0, 'ef37b2c6-b528-4808-b7c1-a4bc84e745e5', '{"text": "PostgreSQL.", "image": null}', true),
	(1, 'ef37b2c6-b528-4808-b7c1-a4bc84e745e5', '{"text": "Realtime database.", "image": null}', false),
	(2, 'ef37b2c6-b528-4808-b7c1-a4bc84e745e5', '{"text": "Edge Functions.", "image": null}', false),
	(3, 'ef37b2c6-b528-4808-b7c1-a4bc84e745e5', '{"text": "Object Storage.", "image": null}', false),
	(0, '5619eef8-cb21-460a-8d0b-1464e03198d1', '{"text": "Truy vấn tất cả dữ liệu mỗi lần và lọc ở phía ứng dụng Flutter.", "image": null}', false),
	(1, '5619eef8-cb21-460a-8d0b-1464e03198d1', '{"text": "Sử dụng indexes trên các cột được truy vấn thường xuyên.", "image": null}', true),
	(2, '5619eef8-cb21-460a-8d0b-1464e03198d1', '{"text": "Vô hiệu hóa tất cả các triggers cơ sở dữ liệu.", "image": null}', false),
	(3, '5619eef8-cb21-460a-8d0b-1464e03198d1', '{"text": "Sử dụng raw SQL queries thay vì ORM.", "image": null}', false),
	(0, 'b5d21c37-583f-4f6e-8417-30d60764697b', '{"text": "Chỉ sử dụng `print()` statements trong mã Flutter.", "image": null}', false),
	(1, 'b5d21c37-583f-4f6e-8417-30d60764697b', '{"text": "Sử dụng trình gỡ lỗi của trình duyệt web.", "image": null}', false),
	(2, 'b5d21c37-583f-4f6e-8417-30d60764697b', '{"text": "Sử dụng Supabase dashboard để xem logs và metrics.", "image": null}', true),
	(3, 'b5d21c37-583f-4f6e-8417-30d60764697b', '{"text": "Không có công cụ nào để theo dõi sau khi triển khai.", "image": null}', false),
	(0, '650e8de5-b7f4-486e-8893-2e565b79bd69', '{"text": "CORS (Cross-Origin Resource Sharing).", "image": null}', false),
	(1, '650e8de5-b7f4-486e-8893-2e565b79bd69', '{"text": "Row Level Security (RLS).", "image": null}', true),
	(2, '650e8de5-b7f4-486e-8893-2e565b79bd69', '{"text": "Biến môi trường (environment variables).", "image": null}', false),
	(3, '650e8de5-b7f4-486e-8893-2e565b79bd69', '{"text": "HTTPS.", "image": null}', false),
	(0, 'cf85fe3e-ff4c-4acc-b906-bc6d69db70e1', '{"text": "Sử dụng migrations để theo dõi và áp dụng các thay đổi schema.", "image": null}', true),
	(1, 'cf85fe3e-ff4c-4acc-b906-bc6d69db70e1', '{"text": "Thực hiện thay đổi schema trực tiếp trên production database.", "image": null}', false),
	(2, 'cf85fe3e-ff4c-4acc-b906-bc6d69db70e1', '{"text": "Xóa và tạo lại cơ sở dữ liệu mỗi khi có thay đổi schema.", "image": null}', false),
	(3, 'cf85fe3e-ff4c-4acc-b906-bc6d69db70e1', '{"text": "Không cần quản lý schema, Supabase tự động xử lý.", "image": null}', false),
	(0, 'b22ecf36-9c4c-417c-88b7-8b1d3e1f8055', '{"text": "Redirect URL của ứng dụng Flutter (ví dụ: `myapp://callback`).", "image": null}', true),
	(1, 'b22ecf36-9c4c-417c-88b7-8b1d3e1f8055', '{"text": "URL của Supabase project.", "image": null}', false),
	(2, 'b22ecf36-9c4c-417c-88b7-8b1d3e1f8055', '{"text": "URL của Google Sign-In.", "image": null}', false),
	(3, 'b22ecf36-9c4c-417c-88b7-8b1d3e1f8055', '{"text": "Không cần cấu hình redirect URL.", "image": null}', false),
	(0, '0debe068-7067-4958-9cd6-ca68e4b4afc8', '{"text": "Sử dụng Row Level Security (RLS) để kiểm soát quyền truy cập dựa trên ID người dùng.", "image": null}', true),
	(1, '0debe068-7067-4958-9cd6-ca68e4b4afc8', '{"text": "Lưu trữ tất cả các tệp tin công khai.", "image": null}', false),
	(2, '0debe068-7067-4958-9cd6-ca68e4b4afc8', '{"text": "Sử dụng một khóa bí mật (secret key) để mã hóa các tệp tin.", "image": null}', false),
	(3, '0debe068-7067-4958-9cd6-ca68e4b4afc8', '{"text": "Không cần kiểm soát quyền truy cập, Supabase tự động xử lý.", "image": null}', false),
	(0, 'd92741f0-9d01-4eae-bac3-ac23d24b7573', '"qe"', false),
	(1, 'd92741f0-9d01-4eae-bac3-ac23d24b7573', '"aweawea"', false),
	(2, 'd92741f0-9d01-4eae-bac3-ac23d24b7573', '"awea"', false),
	(3, 'd92741f0-9d01-4eae-bac3-ac23d24b7573', '"aewwq"', false),
	(0, '61493832-56d3-4745-a986-20af34b7c23b', '"à"', true),
	(1, '61493832-56d3-4745-a986-20af34b7c23b', '"afewrư"', false),
	(2, '61493832-56d3-4745-a986-20af34b7c23b', '"uwr"', false),
	(3, '61493832-56d3-4745-a986-20af34b7c23b', '"234"', false),
	(0, 'd925f523-f65c-4828-a29b-dd9d84b5707b', '"arr"', true),
	(1, 'd925f523-f65c-4828-a29b-dd9d84b5707b', '"rearar"', false),
	(2, 'd925f523-f65c-4828-a29b-dd9d84b5707b', '"rurqar"', false),
	(0, 'ed8e2918-0e7f-41e6-afba-5ce12c73c80d', '"12341234123"', false),
	(1, 'ed8e2918-0e7f-41e6-afba-5ce12c73c80d', '"trưqẻ"', false),
	(0, '492e3a44-498a-4b88-a997-931acfa41e6c', '"afeaf"', false),
	(1, '492e3a44-498a-4b88-a997-931acfa41e6c', '"werqr23"', true),
	(0, 'd1f602b1-059f-450c-a0c3-446f7ce9a3be', '{"id": 0, "text": "124234", "isCorrect": true}', true),
	(1, 'd1f602b1-059f-450c-a0c3-446f7ce9a3be', '{"id": 1, "text": "r23r", "isCorrect": false}', false),
	(2, 'd1f602b1-059f-450c-a0c3-446f7ce9a3be', '{"id": 2, "text": "234", "isCorrect": false}', false),
	(0, '13e51e09-aa34-4500-8512-ac8677b9c6a4', '{"id": 0, "text": "25 kg", "isCorrect": false}', false),
	(1, '13e51e09-aa34-4500-8512-ac8677b9c6a4', '{"id": 1, "text": "45 kg", "isCorrect": false}', false),
	(2, '13e51e09-aa34-4500-8512-ac8677b9c6a4', '{"id": 2, "text": "35 kg.", "isCorrect": true}', true),
	(3, '13e51e09-aa34-4500-8512-ac8677b9c6a4', '{"id": 3, "text": "165 kg", "isCorrect": false}', false),
	(0, '8e416e65-c9e9-4417-bec1-07c3a91ce252', '{"id": 0, "text": "2", "isCorrect": false}', false),
	(1, '8e416e65-c9e9-4417-bec1-07c3a91ce252', '{"id": 1, "text": "4", "isCorrect": false}', false),
	(2, '8e416e65-c9e9-4417-bec1-07c3a91ce252', '{"id": 2, "text": "5", "isCorrect": false}', false),
	(3, '8e416e65-c9e9-4417-bec1-07c3a91ce252', '{"id": 3, "text": "3", "isCorrect": false}', false);


--
-- Data for Name: question_objectives; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: question_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: student_skill_mastery; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."submissions" ("id", "assignment_id", "student_id", "session_id", "variant_id", "started_at", "submitted_at", "is_late", "total_score", "ai_graded", "created_at", "updated_at", "is_voided", "assignment_distribution_id") VALUES
	('69432cb3-7ba3-4eb8-a180-ed2318d40bad', 'f9f717a1-d750-41b3-8c17-9a963b732a18', '076de02d-75ba-4e79-898d-1b5e43141894', 'af3ab11b-ee21-4645-b678-b759d6e10357', NULL, NULL, '2026-03-12 18:20:24.268568+00', false, 10.00, false, '2026-03-12 18:06:11.296701+00', '2026-03-12 18:20:24.268568+00', false, '5df28496-4898-4142-998c-3defa720c3d7'),
	('b374472f-ad08-4796-b8f5-f5258dff404c', 'd8d32c65-8bf2-4809-8d2f-858fd5fdab34', '076de02d-75ba-4e79-898d-1b5e43141894', '6cd7813f-4d24-4a8f-a58c-0806f31ea3ae', NULL, NULL, '2026-03-21 15:59:05.95407+00', false, 6.00, false, '2026-03-21 15:59:05.95407+00', '2026-03-21 15:59:05.95407+00', false, 'f761378d-b9b9-427d-b50f-60a644d3fa09'),
	('b61bf99e-5772-4dff-9225-ada7f135773c', '7983b234-5899-42e9-92cf-1ddd65a52e91', '076de02d-75ba-4e79-898d-1b5e43141894', '40950c84-5f66-4457-b68b-72919e29bbd7', NULL, NULL, '2026-03-21 17:50:46.350073+00', true, 3.00, false, '2026-03-21 17:50:46.350073+00', '2026-03-21 17:50:46.350073+00', false, 'b9dcbc49-98d5-4924-b9bc-9727ae196564'),
	('22eb9628-02bd-48c3-bc55-b612ce23ebb3', '7983b234-5899-42e9-92cf-1ddd65a52e91', '076de02d-75ba-4e79-898d-1b5e43141894', '3dfdc594-2050-4820-aad8-fa1b2a820f9e', NULL, NULL, '2026-03-22 15:06:57.018769+00', true, 1.00, false, '2026-03-22 15:06:57.018769+00', '2026-03-22 15:06:57.018769+00', false, '0f323291-838b-4779-b75b-6910cbcf45b7');


--
-- Data for Name: submission_analytics; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: teacher_notes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 503, true);


--
-- PostgreSQL database dump complete
--

-- \unrestrict YvSPNIykVs35KVDs3N3P5K60kDcCauwG8L3ohAtwHgW0UqjQfScxfTfq913LKTU

RESET ALL;
