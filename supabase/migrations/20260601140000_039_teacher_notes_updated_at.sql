-- Batch A / Track 1: thêm updated_at + trigger cho teacher_notes (notes editable)
-- RLS đã có policy ALL "Teachers can manage their teacher_notes" (auth.uid()=teacher_id) -> KHÔNG đụng.
ALTER TABLE public.teacher_notes
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

CREATE OR REPLACE FUNCTION public.set_teacher_notes_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_teacher_notes_updated_at ON public.teacher_notes;
CREATE TRIGGER trg_teacher_notes_updated_at
  BEFORE UPDATE ON public.teacher_notes
  FOR EACH ROW EXECUTE FUNCTION public.set_teacher_notes_updated_at();
