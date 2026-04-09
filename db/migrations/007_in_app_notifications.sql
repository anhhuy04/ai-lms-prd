-- Phase 7: In-app notification infrastructure (D-13)
-- NOT FCM -- simple DB table with Realtime subscription from Flutter

CREATE TABLE IF NOT EXISTS public.in_app_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  type text NOT NULL,          -- 'grade_override', 'ai_graded', 'recommendation', etc.
  title text NOT NULL,
  body text,
  payload jsonb,               -- { "submission_answer_id": "...", "old_score": 3, "new_score": 5 }
  read_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- RLS: Users can only see their own notifications
ALTER TABLE public.in_app_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
  ON public.in_app_notifications
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications (mark read)"
  ON public.in_app_notifications
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Index for fast queries by user
CREATE INDEX IF NOT EXISTS idx_in_app_notifications_user_id
  ON public.in_app_notifications(user_id, created_at DESC);
