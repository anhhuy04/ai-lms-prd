-- Migration 011: pgvector extension + document_chunks table
-- Phase 9: AI Settings Refactor & Document Import
-- Embedding model: Gemini text-embedding-004 → 768 dimensions

-- Enable pgvector extension (idempotent)
CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;

-- document_chunks: stores text chunks + embeddings for RAG retrieval
CREATE TABLE IF NOT EXISTS public.document_chunks (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  file_id         UUID NOT NULL REFERENCES public.files(id) ON DELETE CASCADE,
  chunk_index     INTEGER NOT NULL,       -- 0-based position in document
  chunk_text      TEXT NOT NULL,
  content_hash    VARCHAR(64) NOT NULL,   -- SHA-256 hex, for differential update (D-30)
  embedding       extensions.vector(768), -- Gemini text-embedding-004 (768-dim, NOT 1536)
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(file_id, chunk_index)
);

-- Index for cosine similarity search (D-21)
-- HNSW preferred over IVFFlat: no training required, effective from 0 rows
-- IVFFlat needs ~sqrt(n_rows) lists → ineffective on new/small tables
CREATE INDEX IF NOT EXISTS document_chunks_embedding_cosine_idx
  ON public.document_chunks
  USING hnsw (embedding extensions.vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- Index for differential update lookup by content_hash (D-30)
CREATE INDEX IF NOT EXISTS document_chunks_file_hash_idx
  ON public.document_chunks (file_id, content_hash);

-- RLS
ALTER TABLE public.document_chunks ENABLE ROW LEVEL SECURITY;

-- Teachers can read chunks for their own files
CREATE POLICY "teacher_read_own_chunks"
  ON public.document_chunks
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.file_links fl
      JOIN public.profiles p ON p.id = fl.target_id
      WHERE fl.file_id = document_chunks.file_id
        AND fl.target_type = 'teacher'
        AND p.id = (SELECT auth.uid())
    )
  );

-- Service role can insert (Edge Function uses service role key)
CREATE POLICY "service_role_insert_chunks"
  ON public.document_chunks
  FOR INSERT
  WITH CHECK (TRUE);  -- Restricted by service role key at application level

CREATE POLICY "service_role_delete_chunks"
  ON public.document_chunks
  FOR DELETE
  USING (TRUE);  -- Restricted by service role key at application level

-- match_document_chunks RPC for RAG retrieval (D-21)
-- Returns Top 5 chunks by cosine similarity to query_embedding
-- Note: set search_path to extensions so vector operators (<=> etc.) are accessible
CREATE OR REPLACE FUNCTION public.match_document_chunks(
  query_embedding extensions.vector(768),
  file_ids        UUID[],
  match_count     INT DEFAULT 5
)
RETURNS TABLE (
  id          UUID,
  file_id     UUID,
  chunk_index INTEGER,
  chunk_text  TEXT,
  similarity  FLOAT
)
LANGUAGE sql
STABLE
SET search_path = extensions, public, pg_temp
AS $$
  SELECT
    dc.id,
    dc.file_id,
    dc.chunk_index,
    dc.chunk_text,
    1 - (dc.embedding <=> query_embedding) AS similarity
  FROM public.document_chunks dc
  WHERE dc.file_id = ANY(file_ids)
    AND dc.embedding IS NOT NULL
  ORDER BY dc.embedding <=> query_embedding
  LIMIT match_count;
$$;

-- Teachers (authenticated) need EXECUTE to call RAG retrieval from Flutter
GRANT EXECUTE ON FUNCTION public.match_document_chunks(extensions.vector(768), UUID[], INT) TO authenticated;
