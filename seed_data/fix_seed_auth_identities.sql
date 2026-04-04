-- ============================================================
-- FIX: Seed users cannot login — missing required fields
-- Root causes:
--   1. auth.identities.identity_data missing email_verified + phone_verified
--      → GoTrue cannot build valid JWT token
--   2. auth.users token columns (confirmation_token etc.) are NULL
--      → GoTrue panics: "converting NULL to string is unsupported"
-- Apply on: local Supabase (docker) via:
--   npx supabase db query --db-url "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f seed_data/fix_seed_auth_identities.sql
-- ============================================================

-- Fix 1: Add email_verified + phone_verified to identity_data
UPDATE auth.identities
SET
  identity_data = identity_data
    || '{"email_verified": false, "phone_verified": false}'::jsonb,
  updated_at = now()
WHERE provider = 'email'
  AND (
    identity_data->>'email_verified' IS NULL
    OR identity_data->>'phone_verified' IS NULL
  );

-- Fix 2: Set NULL token columns to empty string
UPDATE auth.users SET
  confirmation_token       = COALESCE(confirmation_token, ''),
  recovery_token           = COALESCE(recovery_token, ''),
  email_change             = COALESCE(email_change, ''),
  email_change_token_new   = COALESCE(email_change_token_new, ''),
  email_change_token_current = COALESCE(email_change_token_current, ''),
  phone_change             = COALESCE(phone_change, ''),
  phone_change_token       = COALESCE(phone_change_token, ''),
  reauthentication_token   = COALESCE(reauthentication_token, ''),
  updated_at = now()
WHERE confirmation_token IS NULL
   OR recovery_token IS NULL
   OR email_change IS NULL
   OR email_change_token_new IS NULL
   OR email_change_token_current IS NULL
   OR phone_change IS NULL
   OR phone_change_token IS NULL
   OR reauthentication_token IS NULL;

-- Verify
SELECT
  u.email,
  i.identity_data->>'email_verified' as email_verified,
  i.identity_data->>'phone_verified' as phone_verified,
  u.confirmation_token IS NOT NULL as has_confirmation_token
FROM auth.users u
JOIN auth.identities i ON i.user_id = u.id
WHERE i.provider = 'email'
ORDER BY u.email
LIMIT 5;
