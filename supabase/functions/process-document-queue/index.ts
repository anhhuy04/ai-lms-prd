import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import mammoth from 'npm:mammoth';
import * as XLSX from 'npm:xlsx';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const BATCH_SIZE = 10; // Process 10 chunks per batch (D-20)
const CHUNK_SIZE = 500; // tokens approx (D-17)
const CHUNK_OVERLAP = 100; // tokens (D-17)

// Standard Excel headers that trigger Fast Track (D-13)
const FAST_TRACK_KEYS = [
  ['câu hỏi', 'đáp án a', 'đáp án b', 'đáp án đúng'],
  ['question', 'option a', 'option b', 'correct answer'],
  ['nội dung câu hỏi', 'lựa chọn a', 'lựa chọn b', 'đáp án'],
];

// ---------------------------------------------------------------------------
// Gemini Embedding API — 768-dim (text-embedding-004)
// CRITICAL: response path is data.embedding.values (768 floats)
// ---------------------------------------------------------------------------
async function callGeminiEmbedding(text: string, apiKey: string): Promise<number[]> {
  const url = 'https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent';
  const resp = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'X-goog-api-key': apiKey },
    body: JSON.stringify({ content: { parts: [{ text }] } }),
    signal: AbortSignal.timeout(10_000),
  });
  if (!resp.ok) throw new Error(`Embedding API ${resp.status}: ${await resp.text()}`);
  const data = await resp.json();
  return data.embedding.values as number[]; // 768-element array
}

// ---------------------------------------------------------------------------
// SHA-256 content hash (D-30) — Deno built-in crypto
// ---------------------------------------------------------------------------
async function sha256(text: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(text);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  return Array.from(new Uint8Array(hashBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

// ---------------------------------------------------------------------------
// Recursive character text splitter (D-17)
// chunk_size=500 chars (approximation of tokens), overlap=100
// ---------------------------------------------------------------------------
function splitText(text: string): string[] {
  const chunks: string[] = [];
  const separators = ['\n\n', '\n', '. ', ' ', ''];

  function split(text: string, separatorIdx: number): void {
    if (text.length <= CHUNK_SIZE || separatorIdx >= separators.length) {
      if (text.trim()) chunks.push(text.trim());
      return;
    }
    const sep = separators[separatorIdx];
    const parts = sep ? text.split(sep) : [text];

    let currentChunk = '';
    for (const part of parts) {
      const candidate = currentChunk ? `${currentChunk}${sep}${part}` : part;
      if (candidate.length <= CHUNK_SIZE) {
        currentChunk = candidate;
      } else {
        if (currentChunk.trim()) chunks.push(currentChunk.trim());
        // Apply overlap: take last CHUNK_OVERLAP chars of previous chunk
        const overlap = currentChunk.slice(-CHUNK_OVERLAP);
        currentChunk = overlap ? `${overlap} ${part}` : part;
      }
    }
    if (currentChunk.trim()) chunks.push(currentChunk.trim());
  }

  split(text, 0);
  return chunks.filter(c => c.length > 20); // Skip trivially short chunks
}

// ---------------------------------------------------------------------------
// Heuristic Router (D-13)
// ---------------------------------------------------------------------------
interface QuestionDTO {
  type: string;
  content: { text: string };
  answer: { correct_index?: number; correct_text?: string };
  choices?: Array<{ id: number; text: string }>;
}

function detectFastTrack(rows: Record<string, unknown>[]): string[] | null {
  if (!rows.length) return null;
  const keys = Object.keys(rows[0]).map(k => k.toLowerCase().trim());
  for (const pattern of FAST_TRACK_KEYS) {
    if (pattern.every(required => keys.some(k => k.includes(required)))) {
      return Object.keys(rows[0]); // return original case keys
    }
  }
  return null;
}

function fastTrackMap(rows: Record<string, unknown>[], headers: string[]): QuestionDTO[] {
  const lower = headers.map(h => h.toLowerCase().trim());

  const questionKey = headers[lower.findIndex(h => h.includes('câu hỏi') || h.includes('question') || h.includes('nội dung'))];
  // BUG-A fix: prioritise exact/longer match so 'đáp án a'/'đáp án b' do NOT win over 'đáp án đúng'.
  // Use h === 'đáp án' for bare exact match (pattern-3); h.includes('đáp án đúng') for pattern-1;
  // h.includes('correct answer') for pattern-2 (more specific than bare 'correct').
  const correctKey = headers[lower.findIndex(h =>
    h.includes('đáp án đúng') || h.includes('correct answer') || h === 'đáp án'
  )];
  const choiceKeys = headers.filter((_, i) =>
    lower[i].includes('đáp án') || lower[i].includes('option') || lower[i].includes('lựa chọn')
  ).filter(k => k !== correctKey);

  return rows
    .filter(row => row[questionKey])
    .map((row) => ({
      type: 'multiple_choice',
      content: { text: String(row[questionKey] ?? '') },
      answer: { correct_index: choiceKeys.indexOf(String(row[correctKey] ?? '')) },
      choices: choiceKeys.map((k, i) => ({ id: i, text: String(row[k] ?? '') })),
    }));
}

// ---------------------------------------------------------------------------
// LLM call (reuse pattern from process-ai-queue — Gemini only for extraction)
// ---------------------------------------------------------------------------
async function callLLMForExtraction(content: string, apiKey: string, isWord: boolean): Promise<QuestionDTO[]> {
  const prompt = isWord
    ? `[Context] Văn bản tài liệu học/đề thi:\n${content}\n\n[Objective] Nhận diện và trích xuất TẤT CẢ câu hỏi trắc nghiệm trong văn bản. Đọc cấu trúc đề thi trong văn bản tự do.\n[Constraint] KHÔNG tự sáng tác câu hỏi. Chỉ trích xuất những gì có trong văn bản. Bỏ qua metadata (họ tên, ngày thi).\n[Response Format] Trả về JSON array thuần túy List<QuestionDTO>, KHÔNG bọc markdown. Schema:\n[{"type":"multiple_choice","content":{"text":"..."},"choices":[{"id":0,"text":"..."}],"answer":{"correct_index":0}}]`
    : `[Context] Dữ liệu Excel thô (JSON):\n${content}\n\n[Objective] Đọc cấu trúc ẩn, trích xuất câu hỏi trắc nghiệm + đáp án.\n[Constraint] Bỏ qua nhiễu ("Họ tên HS", "Ngày thi"). KHÔNG tự sáng tác câu hỏi.\n[Response Format] JSON array thuần túy List<QuestionDTO>, KHÔNG bọc markdown:\n[{"type":"multiple_choice","content":{"text":"..."},"choices":[{"id":0,"text":"..."}],"answer":{"correct_index":0}}]`;

  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent`;
  const resp = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'X-goog-api-key': apiKey },
    body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
  });
  if (!resp.ok) throw new Error(`LLM API ${resp.status}: ${await resp.text()}`);
  const data = await resp.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text ?? '[]';
  // Strip markdown code fences if present
  const clean = text.replace(/^```json?\n?/, '').replace(/\n?```$/, '').trim();
  return JSON.parse(clean) as QuestionDTO[];
}

// ---------------------------------------------------------------------------
// Vectorize pipeline with stateful checkpointing (D-29) + content hashing (D-30)
// ---------------------------------------------------------------------------
async function vectorizeDocument(
  // deno-lint-ignore no-explicit-any
  supabase: any,
  fileId: string,
  queueId: string,
  fileBytes: Uint8Array,
  mimeType: string,
  apiKey: string,
  existingResult: Record<string, unknown> | null,
): Promise<void> {
  // Extract text
  let rawText = '';
  if (mimeType.includes('wordprocessingml')) {
    const { value } = await mammoth.extractRawText({ buffer: fileBytes });
    rawText = value;
  } else {
    const wb = XLSX.read(fileBytes, { type: 'array' });
    const ws = wb.Sheets[wb.SheetNames[0]];
    rawText = XLSX.utils.sheet_to_txt(ws);
  }

  const chunks = splitText(rawText);
  const totalChunks = chunks.length;
  // Read checkpoint from result.vectorize (nested) to avoid conflicting with result.extraction
  const existingVectorize = (existingResult as Record<string, unknown>)?.vectorize as Record<string, unknown> | undefined;
  let processedChunks: number = (existingVectorize?.processed_chunks as number) ?? 0;

  // Initialise checkpoint if fresh start — write to result.vectorize only (merge via RPC or re-read)
  if (!existingVectorize || processedChunks === 0) {
    // Use postgres jsonb merge: fetch current result, deep-merge, update
    const { data: current } = await supabase.from('ai_queue').select('result').eq('id', queueId).single();
    const merged = { ...(current?.result ?? {}), vectorize: { total_chunks: totalChunks, processed_chunks: 0 } };
    await supabase.from('ai_queue').update({
      result: merged,
      status: 'processing',
    }).eq('id', queueId);
  }

  // D-30: Get existing content hashes for this file
  const { data: existingChunks } = await supabase
    .from('document_chunks')
    .select('id, content_hash')
    .eq('file_id', fileId);

  const existingHashes = new Set((existingChunks ?? []).map((c: {content_hash: string}) => c.content_hash));
  const newHashes: string[] = [];

  // Process in batches (D-20) — resume from checkpoint (D-29)
  for (let i = processedChunks; i < totalChunks; i += BATCH_SIZE) {
    const batch = chunks.slice(i, i + BATCH_SIZE);

    for (let j = 0; j < batch.length; j++) {
      const chunkText = batch[j];
      const chunkIndex = i + j;
      const hash = await sha256(chunkText);
      newHashes.push(hash);

      // D-30: Skip unchanged chunks
      if (existingHashes.has(hash)) continue;

      // New chunk — embed and insert
      const embedding = await callGeminiEmbedding(chunkText, apiKey);

      await supabase.from('document_chunks').insert({
        file_id: fileId,
        chunk_index: chunkIndex,
        chunk_text: chunkText,
        content_hash: hash,
        embedding: `[${embedding.join(',')}]`, // pgvector format
      });
    }

    // D-29: Update checkpoint after each batch — write to result.vectorize (deep merge to preserve result.extraction)
    processedChunks = Math.min(i + BATCH_SIZE, totalChunks);
    const { data: cur } = await supabase.from('ai_queue').select('result').eq('id', queueId).single();
    const merged = { ...(cur?.result ?? {}), vectorize: { total_chunks: totalChunks, processed_chunks: processedChunks } };
    await supabase.from('ai_queue').update({ result: merged }).eq('id', queueId);

    // Avoid OOM on free tier (D-20)
    if (i + BATCH_SIZE < totalChunks) {
      await new Promise(r => setTimeout(r, 2000));
    }
  }

  // D-30: Delete stale chunks (in old but not in new)
  const newHashSet = new Set(newHashes);
  const staleIds = (existingChunks ?? [])
    .filter((c: {id: string; content_hash: string}) => !newHashSet.has(c.content_hash))
    .map((c: {id: string}) => c.id);

  if (staleIds.length > 0) {
    await supabase.from('document_chunks').delete().in('id', staleIds);
  }
}

// ---------------------------------------------------------------------------
// Main handler
// ---------------------------------------------------------------------------
serve(async (_req) => {
  // deno-lint-ignore no-explicit-any
  const supabase = createClient<any>(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  // Poll pending ai_queue rows
  const { data: jobs } = await supabase
    .from('ai_queue')
    .select('*')
    .eq('request_type', 'vectorize_document')
    .in('status', ['pending', 'processing'])
    .lt('attempts', 3)
    .order('created_at', { ascending: true })
    .limit(5);

  if (!jobs?.length) {
    return new Response(JSON.stringify({ processed: 0 }), { status: 200 });
  }

  let processed = 0;

  for (const job of jobs) {
    try {
      // Use `payload` column (NOT `request_payload`) — matches existing schema and process-ai-queue pattern
      const fileId = job.payload?.file_id as string;
      const action = job.payload?.action as string;

      // Get file metadata
      const { data: file } = await supabase
        .from('files')
        .select('*, file_links(target_id)')
        .eq('id', fileId)
        .single();

      if (!file) throw new Error(`File ${fileId} not found`);

      const teacherId = file.file_links?.[0]?.target_id as string;

      // Get teacher's Gemini API key (same pattern as process-ai-queue)
      const { data: profile } = await supabase
        .from('profiles')
        .select('metadata')
        .eq('id', teacherId)
        .single();

      const apiKey = profile?.metadata?.api_keys?.gemini as string;
      if (!apiKey) throw new Error(`No Gemini API key for teacher ${teacherId}`);

      // Download file bytes from Storage
      const { data: fileData, error: dlError } = await supabase.storage
        .from('teacher-documents')
        .download(file.storage_path);

      if (dlError || !fileData) throw new Error(`Cannot download file: ${dlError?.message}`);
      const fileBytes = new Uint8Array(await fileData.arrayBuffer());

      // Route based on action
      if (action === 'extract_or_vectorize') {
        const mimeType = file.mime_type as string;

        if (mimeType.includes('spreadsheetml')) {
          // Excel — Heuristic Router (D-13)
          const wb = XLSX.read(fileBytes, { type: 'array' });
          const ws = wb.Sheets[wb.SheetNames[0]];
          const rows = XLSX.utils.sheet_to_json<Record<string, unknown>>(ws);

          const fastTrackHeaders = detectFastTrack(rows);
          let questions: QuestionDTO[];

          if (fastTrackHeaders) {
            // Fast Track — $0, ~0.1s
            questions = fastTrackMap(rows, fastTrackHeaders);
          } else {
            // LLM Fallback
            questions = await callLLMForExtraction(JSON.stringify(rows.slice(0, 50)), apiKey, false);
          }

          // BUG-B fix: deep-merge into existing result so result.vectorize checkpoint is preserved on retry.
          // Plain `.update({ result: {...} })` replaces the entire JSONB column — wiping vectorize progress.
          const { data: _curEx } = await supabase.from('ai_queue').select('result').eq('id', job.id).single();
          await supabase.from('ai_queue').update({
            result: { ...(_curEx?.result ?? {}), extraction: { questions, path: fastTrackHeaders ? 'fast_track' : 'llm_fallback' } },
          }).eq('id', job.id);

        } else {
          // Word .docx — always LLM extraction (D-12, D-15)
          const { value: text } = await mammoth.extractRawText({ buffer: fileBytes });
          const questions = await callLLMForExtraction(text.slice(0, 8000), apiKey, true);

          // BUG-B fix: deep-merge to preserve result.vectorize checkpoint across retries.
          const { data: _curWord } = await supabase.from('ai_queue').select('result').eq('id', job.id).single();
          await supabase.from('ai_queue').update({
            result: { ...(_curWord?.result ?? {}), extraction: { questions, path: 'llm_word' } },
          }).eq('id', job.id);
        }

        // Also vectorize for RAG (generation pipeline)
        // vectorizeDocument writes checkpointing to result.vectorize — does NOT overwrite result.extraction
        await vectorizeDocument(supabase, fileId, job.id, fileBytes, file.mime_type, apiKey, job.result);

        // Mark completed AFTER both extraction and vectorize finish
        await supabase.from('ai_queue').update({
          status: 'completed',  // 'completed' not 'done' — matches existing codebase convention
        }).eq('id', job.id);
      }

      processed++;

    } catch (err) {
      console.error(`Job ${job.id} failed:`, err);
      // Use 'failed' not 'error' — matches existing process-ai-queue.ts convention
      await supabase.from('ai_queue').update({
        status: job.attempts >= 2 ? 'failed' : 'pending',
        attempts: (job.attempts ?? 0) + 1,
      }).eq('id', job.id);
    }
  }

  return new Response(JSON.stringify({ processed }), { status: 200 });
});

// ---------------------------------------------------------------------------
// Export internal helpers for unit tests (index.test.ts)
// ---------------------------------------------------------------------------
export { detectFastTrack, fastTrackMap, sha256, splitText };
export type { QuestionDTO };
