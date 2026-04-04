-- ==============================================================
-- Script: Import Production Data into Local Docker Supabase
-- Date: 2026-03-31
-- Purpose: 
--   1. Clear any existing local test data
--   2. Import prod_data.sql (auth + public tables)
--   3. Generate profiles from auth.users raw_user_meta_data
--      (production dump does NOT include profiles table data)
-- ==============================================================

-- Step 1: Clean local data first (reverse FK order)
-- Disable triggers to allow clean deletion
SET session_replication_role = replica;

TRUNCATE public.submission_analytics CASCADE;
TRUNCATE public.grade_overrides CASCADE;
TRUNCATE public.ai_evaluations CASCADE;
TRUNCATE public.ai_queue CASCADE;
TRUNCATE public.ai_recommendations CASCADE;
TRUNCATE public.teacher_notes CASCADE;
TRUNCATE public.autosave_answers CASCADE;
TRUNCATE public.submission_answers CASCADE;
TRUNCATE public.submissions CASCADE;
TRUNCATE public.work_sessions CASCADE;
TRUNCATE public.assignment_distributions CASCADE;
TRUNCATE public.assignment_variants CASCADE;
TRUNCATE public.assignment_questions CASCADE;
TRUNCATE public.question_choices CASCADE;
TRUNCATE public.question_objectives CASCADE;
TRUNCATE public.question_stats CASCADE;
TRUNCATE public.questions CASCADE;
TRUNCATE public.assignments CASCADE;
TRUNCATE public.file_links CASCADE;
TRUNCATE public.files CASCADE;
TRUNCATE public.group_members CASCADE;
TRUNCATE public.groups CASCADE;
TRUNCATE public.class_members CASCADE;
TRUNCATE public.class_teachers CASCADE;
TRUNCATE public.classes CASCADE;
TRUNCATE public.schools CASCADE;
TRUNCATE public.student_skill_mastery CASCADE;
TRUNCATE public.learning_objectives CASCADE;
TRUNCATE public.profiles CASCADE;

-- Also clean auth data to avoid duplicates
DELETE FROM auth.mfa_amr_claims;
DELETE FROM auth.refresh_tokens;
DELETE FROM auth.sessions;
DELETE FROM auth.identities;
DELETE FROM auth.users;

SET session_replication_role = DEFAULT;

-- Step 2: Done by a separate command (prod_data.sql already imported)
-- This script is run AFTER prod_data.sql

-- Step 3: Generate profiles from auth.users raw_user_meta_data
-- Production has NO profiles data in the dump, so we reconstruct them
-- from the metadata stored in auth.users
INSERT INTO public.profiles (id, full_name, role, phone, gender, avatar_url)
SELECT
    u.id,
    u.raw_user_meta_data->>'full_name',
    COALESCE(
        CASE 
            WHEN u.raw_user_meta_data->>'role' IN ('teacher', 'student', 'admin') 
            THEN u.raw_user_meta_data->>'role'
            ELSE NULL
        END,
        'student'
    ),
    u.raw_user_meta_data->>'phone',
    CASE 
        WHEN u.raw_user_meta_data->>'gender' IN ('male', 'female', 'other')
        THEN u.raw_user_meta_data->>'gender'
        ELSE NULL
    END,
    u.raw_user_meta_data->>'avatar_url'
FROM auth.users u
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role,
    phone = EXCLUDED.phone,
    gender = EXCLUDED.gender,
    avatar_url = EXCLUDED.avatar_url;
