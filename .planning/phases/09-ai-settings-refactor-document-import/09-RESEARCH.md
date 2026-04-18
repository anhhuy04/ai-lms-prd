# Phase 9: AI Settings Refactor & Document Import - Research

**Researched:** 2026-04-18
**Domain:** RAG pipeline (pgvector), document parsing (Edge Functions), Flutter file upload, heuristic routing, stateful checkpointing
**Confidence:** HIGH (core decisions) / MEDIUM (Edge Function npm specifics)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Tao `AiQuestionSettingsScreen` moi — hoan toan tach biet voi `SettingsScreen`
- **D-02:** Gear icon tren `TeacherAiGenerateQuestionScreen` (line 904) doi route sang `AiQuestionSettingsScreen`
- **D-03:** `AiQuestionSettingsScreen` co: tile "Cai dat API Key" + section "Thu vien Tai lieu"
- **D-04:** Files luu persistent — Knowledge Library model (khong throw away)
- **D-05:** Upload pipeline 5 buoc: Storage → files → file_links → ai_queue → UI chip ngay lap tuc
- **D-06:** `file_links.target_type='teacher'`, `target_id=teacher_id` — file theo profile, khong theo lop
- **D-07:** Them section "Nguon Du Lieu Tham Khao" vao `TeacherAiGenerateQuestionScreen`
- **D-08:** Hien Chip/Tag tick chon — query qua `file_links` cua teacher
- **D-09:** Nut [+] Them tai lieu moi — file picker → upload pipeline → chip da tick
- **D-10:** UI Toggle bat buoc cho mode selection (khong dung God Prompt)
- **D-11:** 2 mode: Trich xuat (Extraction) va Sinh cau hoi (Generation)
- **D-12:** .docx → mammoth.js → 100% LLM. .xlsx → xlsx library → Heuristic Router
- **D-13:** Heuristic Router: Fast Track (map()) vs LLM Fallback (few-shot prompt)
- **D-14:** Few-Shot Prompt cho Excel lon xon (JSON stringify + schema mau)
- **D-15:** Word (.docx) prompt tu plain text mammoth
- **D-16 (REVISED):** RAG + pgvector — KHONG dung Long Context Window
- **D-16-ext:** Nut [Xuat file mau Excel] trong `AiQuestionSettingsScreen`
- **D-17:** Chunking — RecursiveCharacterTextSplitter: chunk_size=500 tokens, chunk_overlap=100
- **D-18:** Embedding — text-embedding-3-small hoac nomic-embed-text → luu vao `document_chunks`
- **D-19:** pgvector tren Supabase — `CREATE EXTENSION vector` + bang `document_chunks`
- **D-20:** Batch processing qua `ai_queue` — 10 trang/batch, sleep 2s, async hoan toan
- **D-21:** Retrieval: vector hoa query → Cosine Similarity → Top 5 chunks → CO-STAR prompt
- **D-22:** CO-STAR Prompt template cho Generation Pipeline
- **D-23:** Temperature cao hon Luong 1
- **D-24:** Ca 2 pipeline tra ve `List<QuestionDTO>` — same JSON schema
- **D-25:** Flutter Frontend khong biet pipeline nao da chay (Clean Architecture)
- **D-26:** Staging Area — xem truoc, chinh sua truoc khi luu
- **D-27:** 2 action: [Luu vao Ngan hang] va [Luu va Them vao De thi] (DB Transaction)
- **D-28:** Khong co option "Them thang vao De thi ma khong luu Bank" — tranh Orphan Data
- **D-29:** Stateful Checkpointing — UPDATE ai_queue.result voi processed_chunks truoc/sau moi batch
- **D-30:** Content Hashing / Differential Update — SHA-256 moi chunk, so sanh Set Difference

### Claude's Discretion

- Animation/loading state khi pipeline dang xu ly
- Error handling cho file parse failures
- File size limit va supported MIME types (xlsx, docx confirmed; PDF deferred)
- Cach hien staging area (bottom sheet vs full screen)
- Cach generate Excel template (static file tu Storage hoac on-device bang `excel` Dart package)

### Deferred Ideas (OUT OF SCOPE)

- Pinecone external
- AI Grading tu tai lieu (Phase 3)
- Analytics section trong settings
- PDF support
</user_constraints>

---

## Summary

Phase 9 xay dung 2 luong doc lap: (1) AI Settings Refactor — man hinh cai dat AI rieng cho GV, (2) Document Import — upload Excel/Word → Edge Function xu ly → RAG pipeline → sinh cau hoi.

Loi kien truc chinh la dung **pgvector tren Supabase** thay the Long Context Window, giai quyet vendor lock-in. Toan bo data pipeline chay tren Deno Edge Functions voi npm compat (`npm:` specifier). Flutter side chi can them 1 package moi (`file_picker`) — phai hoi user truoc khi them. Package `crypto` da co san trong dependency tree (transitive dep qua supabase_flutter).

Cac migration DB can thiet: (a) `CREATE EXTENSION vector`, (b) bang `document_chunks`, (c) them `'vectorize_document'` vao `ai_queue.request_type` CHECK constraint, (d) xac nhan `file_links.target_type` khong co CHECK constraint.

**Primary recommendation:** Trien khai theo thu tu: migrations → Edge Function moi → Flutter UI. Khong sua existing `process-ai-queue` — tao Edge Function moi `process-document-queue` cho vectorize flow.

---

## Project Constraints (from CLAUDE.md)

| Directive | Impact on Phase 9 |
|-----------|-------------------|
| KHONG tu them library ngoai stack — hoi user truoc | `file_picker` chua co trong pubspec.yaml — REQUIRED: xin phep truoc khi plan task install |
| State: `@riverpod` generator, KHONG StateNotifierProvider | Moi provider cho file list, upload status dung `@riverpod` |
| Routing: `pushNamed()` cho screens co back button | Gear icon → AiQuestionSettingsScreen phai dung `pushNamed()`, KHONG `goNamed()` |
| Widget build() max 50 lines, class max 300 lines | TeacherAiGenerateQuestionScreen (3127 lines) can tach widget nho khi them section |
| KHONG hardcoded paths — dung AppRoute constants | Them constants moi vao route_constants.dart |
| Design tokens bat buoc: DesignColors, DesignSpacing, etc | Toan bo UI moi phai dung design tokens |
| flutter analyze KHONG errors | Check sau moi task |
| Schema First: doc docs/note sql.txt + Supabase MCP inspect truoc khi assume columns | Doc schema truoc khi viet DataSource |
| RLS bat buoc tren moi public table | document_chunks, files bucket policies can RLS |
| Data flow: UI → Provider → Repository(interface) → DataSource → Supabase | Tuan thu Clean Architecture cho moi DataSource moi |

---

## Standard Stack

### Core — Server Side (Edge Functions / Deno)

| Library | Version | Purpose | Notes |
|---------|---------|---------|-------|
| `npm:mammoth` | 1.8.0 | Parse .docx to plain text | Import via `npm:mammoth` in Deno |
| `npm:xlsx` | 0.18.5 | Parse .xlsx to JSON array | SheetJS, widely used |
| `npm:@xenova/transformers` | 2.x | Local embedding (nomic-embed-text) | Alternative — nang RAM, xem xet |
| OpenAI Embeddings API | text-embedding-3-small | 1536-dim vectors | Recommended: goi API, khong local |
| pgvector extension | bundled w/ Supabase | Vector similarity search | `CREATE EXTENSION IF NOT EXISTS vector` |
| `@supabase/supabase-js` | 2.x | DB access trong Edge Function | Da co trong existing function |

### Core — Flutter / Dart

| Library | Version | Purpose | Status |
|---------|---------|---------|--------|
| `file_picker` | 11.0.2 | File selection (xlsx, docx) | NOT in pubspec — can user approval |
| `crypto` | 3.0.7 | SHA-256 cho content hashing (D-30) | Available as transitive dep, can add directly |
| `supabase_flutter` | ^2.0.0 | Storage upload, DB calls | Da co |
| `flutter_riverpod` + `@riverpod` | ^2.5.1 | State management | Da co |

### Package Approval Required

**CRITICAL:** Theo CLAUDE.md, planner phai include task "xin user confirm" truoc khi add:
- `file_picker: ^11.0.2` — chua co trong pubspec, can them vao dependencies
- `crypto: ^3.0.7` — co trong transitive deps nhung chua explicit; an toan hon khi them explicit

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `file_picker` | `image_picker` (da co) | image_picker khong ho tro xlsx/docx |
| OpenAI text-embedding-3-small | nomic-embed-text (local) | Local: khong ton API nhung OOM risk tren free tier Edge Function |
| Separate Edge Function | Extend existing process-ai-queue | Tach ra de maintain, tranh breaking existing flow |

### Installation (sau user approval)

```bash
# pubspec.yaml
flutter pub add file_picker
flutter pub add crypto
```

---

## Architecture Patterns

### Recommended Project Structure — New Files

```
lib/
├── data/
│   ├── datasources/
│   │   └── teacher_file_datasource.dart      # upload, list, link files
│   └── repositories/
│       └── teacher_file_repository_impl.dart
├── domain/
│   └── repositories/
│       └── teacher_file_repository.dart      # interface
├── presentation/
│   ├── providers/
│   │   └── teacher_file_providers.dart       # @riverpod providers
│   └── views/
│       └── settings/
│           └── ai_question_settings_screen.dart  # D-01
supabase/
└── functions/
    └── process-document-queue/
        └── index.ts                           # NEW Edge Function (khong sua process-ai-queue)
db/
└── migrations/
    └── 011_document_chunks_pgvector.sql       # CREATE EXTENSION + bang + RPC
    └── 012_ai_queue_vectorize_type.sql        # Them 'vectorize_document' vao CHECK
```

### Pattern 1: Supabase Storage Upload (Flutter)

```dart
// Source: Supabase Dart docs + existing student workspace pattern
Future<String> uploadTeacherDocument(String teacherId, String fileName, Uint8List bytes) async {
  final path = 'teachers/$teacherId/$fileName';
  await supabase.storage.from('teacher-documents').uploadBinary(
    path,
    bytes,
    fileOptions: const FileOptions(upsert: true),
  );
  return supabase.storage.from('teacher-documents').getPublicUrl(path);
}
```

### Pattern 2: pgvector Document Chunks Table

```sql
-- Source: Supabase official pgvector docs (supabase.com/docs/guides/ai/vector-columns)
CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;

CREATE TABLE public.document_chunks (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  file_id       uuid NOT NULL REFERENCES public.files(id) ON DELETE CASCADE,
  chunk_index   integer NOT NULL,
  chunk_text    text NOT NULL,
  content_hash  varchar(64) NOT NULL,  -- D-30: SHA-256 hex string
  embedding     extensions.vector(1536),  -- text-embedding-3-small dimensions
  created_at    timestamptz DEFAULT now(),
  UNIQUE(file_id, content_hash)  -- Idempotency guard cho D-30
);

-- HNSW index for cosine similarity (recommended over IVFFlat — auto-updates on writes)
CREATE INDEX ON public.document_chunks
  USING hnsw (embedding extensions.vector_cosine_ops);
```

### Pattern 3: Cosine Similarity RPC (match_document_chunks)

```sql
-- Source: Supabase docs — match_documents pattern adapted for chunks
CREATE OR REPLACE FUNCTION match_document_chunks(
  query_embedding extensions.vector(1536),
  file_ids        uuid[],
  match_count     int DEFAULT 5,
  match_threshold float DEFAULT 0.5
)
RETURNS TABLE (
  chunk_text  text,
  similarity  float,
  file_id     uuid
)
LANGUAGE sql STABLE AS $$
  SELECT
    chunk_text,
    1 - (embedding <=> query_embedding) AS similarity,
    file_id
  FROM public.document_chunks
  WHERE file_id = ANY(file_ids)
    AND 1 - (embedding <=> query_embedding) > match_threshold
  ORDER BY embedding <=> query_embedding ASC
  LIMIT match_count;
$$;
```

### Pattern 4: Stateful Checkpointing (D-29) trong Edge Function

```typescript
// Source: CONTEXT.md D-29 — implemented in Deno Edge Function
async function vectorizeDocument(supabase: any, queueItem: AiQueueItem) {
  const fileId = queueItem.payload?.file_id as string;
  const chunks = await parseAndChunkDocument(supabase, fileId);

  // Init checkpoint
  await supabase.from('ai_queue').update({
    result: { total_chunks: chunks.length, processed_chunks: 0 }
  }).eq('id', queueItem.id);

  // Resume: skip already-processed chunks
  const processed = (queueItem.result as any)?.processed_chunks ?? 0;
  const remaining = chunks.slice(processed);

  const BATCH_SIZE = 10;
  let done = processed;

  for (let i = 0; i < remaining.length; i += BATCH_SIZE) {
    const batch = remaining.slice(i, i + BATCH_SIZE);
    await embedAndSaveBatch(supabase, fileId, batch, done);
    done += batch.length;

    // Update checkpoint after each batch
    await supabase.from('ai_queue').update({
      result: { total_chunks: chunks.length, processed_chunks: done }
    }).eq('id', queueItem.id);

    // Avoid OOM — sleep between batches
    await new Promise(r => setTimeout(r, 2000));
  }
}
```

### Pattern 5: Content Hashing / Differential Update (D-30) trong Deno

```typescript
// SHA-256 trong Deno (built-in Web Crypto API — KHONG can npm package)
async function hashChunk(text: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(text);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// Differential update logic
async function diffAndUpdate(supabase: any, fileId: string, newChunks: string[]) {
  // Get existing hashes from DB
  const { data: existing } = await supabase
    .from('document_chunks')
    .select('content_hash')
    .eq('file_id', fileId);

  const oldHashes = new Set(existing?.map((r: any) => r.content_hash) ?? []);
  const newHashes = new Set<string>();

  for (const chunk of newChunks) {
    const hash = await hashChunk(chunk);
    newHashes.add(hash);

    if (!oldHashes.has(hash)) {
      // Hash moi — can embed va INSERT
      const embedding = await callEmbeddingApi(chunk);
      await supabase.from('document_chunks').insert({
        file_id: fileId,
        chunk_text: chunk,
        content_hash: hash,
        embedding,
      });
    }
    // else: hash cu — bo qua hoan toan ($0 API cost)
  }

  // Xoa chunks khong con trong file moi
  const toDelete = [...oldHashes].filter(h => !newHashes.has(h));
  if (toDelete.length > 0) {
    await supabase.from('document_chunks')
      .delete()
      .eq('file_id', fileId)
      .in('content_hash', toDelete);
  }
}
```

**Luu y quan trong:** Deno co built-in `crypto.subtle` (Web Crypto API) — KHONG can import npm crypto. Dart side dung `package:crypto` cho SHA-256 neu can (e.g., verify hash phia client).

### Pattern 6: Heuristic Router cho Excel (D-13)

```typescript
// Source: CONTEXT.md D-12/13 logic
import * as XLSX from 'npm:xlsx';

function parseExcel(buffer: ArrayBuffer): { fastTrack: boolean; rows: any[] } {
  const wb = XLSX.read(new Uint8Array(buffer), { type: 'array' });
  const ws = wb.Sheets[wb.SheetNames[0]];
  const rows = XLSX.utils.sheet_to_json(ws) as Record<string, unknown>[];

  if (rows.length === 0) return { fastTrack: false, rows };

  const headers = Object.keys(rows[0]).map(h => h.toLowerCase().trim());
  const KNOWN_QUESTION_HEADERS = ['câu hỏi', 'cau hoi', 'question'];
  const KNOWN_ANSWER_HEADERS = ['đáp án a', 'dap an a', 'answer a', 'a'];
  const KNOWN_CORRECT_HEADERS = ['đáp án đúng', 'dap an dung', 'correct', 'answer'];

  const hasQuestion = headers.some(h => KNOWN_QUESTION_HEADERS.some(k => h.includes(k)));
  const hasAnswers = headers.some(h => KNOWN_ANSWER_HEADERS.some(k => h.includes(k)));
  const hasCorrect = headers.some(h => KNOWN_CORRECT_HEADERS.some(k => h.includes(k)));

  return { fastTrack: hasQuestion && hasAnswers && hasCorrect, rows };
}

// Fast Track: $0 API cost, ~0.1s
function mapRowsToQuestions(rows: any[]): QuestionDTO[] {
  return rows.map(row => {
    const text = row['Câu hỏi'] ?? row['Question'] ?? row['cau hoi'];
    // ... map A/B/C/D to choices[], find correct
    return { type: 'multiple_choice', override_text: text, choices: [...] };
  });
}
```

### Pattern 7: Mammoth.js trong Deno Edge Function

```typescript
// npm: prefix cho Deno import — supported in Supabase Edge Functions
import mammoth from 'npm:mammoth';

async function parseDocx(buffer: ArrayBuffer): Promise<string> {
  // mammoth.extractRawText: ignore formatting, tung doan cach nhau 2 newlines
  const result = await mammoth.extractRawText({ buffer });
  return result.value; // plain text string
}
```

### Pattern 8: Text Chunking trong Deno (pure JS, khong dung LangChain)

```typescript
// Pure JS implementation — tranh nang dependency trong Edge Function
function chunkText(text: string, chunkSize = 1500, overlap = 300): string[] {
  // Separator hierarchy: paragraph → sentence → word
  const separators = ['\n\n', '\n', '. ', ' '];
  const chunks: string[] = [];
  let start = 0;

  while (start < text.length) {
    let end = Math.min(start + chunkSize, text.length);

    // Tim separator gan nhat de cat
    if (end < text.length) {
      for (const sep of separators) {
        const lastSep = text.lastIndexOf(sep, end);
        if (lastSep > start) { end = lastSep + sep.length; break; }
      }
    }

    chunks.push(text.slice(start, end).trim());
    start = Math.max(start + 1, end - overlap); // overlap giua cac chunk
  }

  return chunks.filter(c => c.length > 50); // bo qua chunks qua ngan
}
```

**Ly do dung pure JS thay LangChain:** LangChain.js them ~50MB vao Edge Function bundle, dat RAM limit cua Supabase free tier (500MB). Pure implementation du cho usecase nay.

### Pattern 9: file_picker cho Flutter (sau user approval)

```dart
// Source: file_picker pub.dev docs (version 11.0.2)
import 'package:file_picker/file_picker.dart';

Future<void> _pickAndUploadDocument() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx', 'docx'],
    withData: true, // lay bytes tren tat ca platforms
  );

  if (result == null || result.files.isEmpty) return;

  final file = result.files.first;
  final bytes = file.bytes;
  if (bytes == null) return;

  // Validate truoc khi upload (file explorer co the bo qua filter)
  final ext = file.extension?.toLowerCase();
  if (ext != 'xlsx' && ext != 'docx') {
    // Hien error — khong hop le
    return;
  }

  // Upload len Supabase Storage
  await _uploadFile(file.name, bytes, ext!);
}
```

**Luu y Android:** file_picker ^11 khong can them READ_EXTERNAL_STORAGE permission tren Android 13+ (API 33+). Tren Android < 13 can them permission vao AndroidManifest.xml.

### Pattern 10: QuestionDTO Unified Schema (D-24)

Ca 2 pipeline deu tra ve cung 1 format — SAME schema nhu prompt hien tai trong `AiService.getGenerateQuestionsPrompt()`:

```json
[
  {
    "type": "multiple_choice",
    "override_text": "Noi dung cau hoi?",
    "choices": [
      {"id": 0, "text": "Dap an A", "isCorrect": true},
      {"id": 1, "text": "Dap an B", "isCorrect": false},
      {"id": 2, "text": "Dap an C", "isCorrect": false},
      {"id": 3, "text": "Dap an D", "isCorrect": false}
    ],
    "tags": ["tag1"]
  }
]
```

Frontend tai dung `_handleSaveToQuestionBank()` hien co trong `TeacherAiGenerateQuestionScreen` — chi can extend them 1 button "Luu va Them vao De thi" voi DB transaction.

### Anti-Patterns to Avoid

- **God Prompt:** Khong dung 1 prompt de tu doan ca Extraction va Generation — D-10 yeu cau UI Toggle ro rang
- **Long Context Window thay RAG:** Gui toan bo file vao LLM = vendor lock-in, OOM, chi phi cao — D-16 cam
- **Extend process-ai-queue:** Them vectorize logic vao existing function = breaking change. Tao Edge Function moi
- **LangChain.js trong Edge Function:** Bundle qua lon — dung pure JS chunking
- **Local embedding model trong Edge Function:** `@xenova/transformers` download model ~200MB+ = OOM tren free tier
- **Blocking UI khi upload:** Upload pipeline phai async — UI hien chip ngay lap tuc (D-05)

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| SHA-256 in Deno | Custom hash function | `crypto.subtle.digest('SHA-256', ...)` | Web Crypto API built-in Deno, zero deps |
| SHA-256 in Dart | Custom hash | `package:crypto` sha256.convert() | Da co trong dep tree |
| Excel parsing | Custom binary reader | `npm:xlsx` (SheetJS) | OOXML format cuc phuc tap, binary spec |
| Word parsing | Custom XML extractor | `npm:mammoth` | .docx la ZIP chua XML phuc tap |
| Vector cosine similarity | Custom distance | pgvector `<=>` operator + index | DB-level, indexed, nhanh hon app-level |
| Chunking overlap | Manual string slicing | Pure JS chunking function (Pattern 8) | De implement, du chinh xac |
| File selection UI | Custom file browser | `file_picker` package | Native OS file picker, handle permissions |

**Key insight:** Document parsing va vector math luon phuc tap hon tuong tuong. OOXML, DOCX compression, UTF-8/Windows-1252 encoding issues, vector normalization — tat ca da duoc giai quyet trong cac thu vien tren.

---

## Database Migrations Required

Planner MUST include migration tasks theo thu tu:

### Migration 011: pgvector + document_chunks

```sql
-- File: db/migrations/011_document_chunks_pgvector.sql
-- Buoc 1: Enable extension
CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;

-- Buoc 2: Bang document_chunks
CREATE TABLE IF NOT EXISTS public.document_chunks (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  file_id       uuid NOT NULL REFERENCES public.files(id) ON DELETE CASCADE,
  chunk_index   integer NOT NULL,
  chunk_text    text NOT NULL,
  content_hash  varchar(64) NOT NULL,
  embedding     extensions.vector(1536),
  created_at    timestamptz DEFAULT now(),
  UNIQUE(file_id, content_hash)
);

-- RLS
ALTER TABLE public.document_chunks ENABLE ROW LEVEL SECURITY;
-- Teacher co the xem chunks cua files cua minh
CREATE POLICY "teacher_view_own_chunks" ON public.document_chunks
  FOR SELECT TO authenticated
  USING (
    file_id IN (
      SELECT fl.file_id FROM public.file_links fl
      WHERE fl.target_type = 'teacher'
        AND fl.target_id = (SELECT auth.uid())
    )
  );
-- Service role (Edge Function) co the CRUD
-- (Edge Functions dung SUPABASE_SERVICE_ROLE_KEY, bypass RLS)

-- HNSW index
CREATE INDEX IF NOT EXISTS document_chunks_embedding_idx
  ON public.document_chunks
  USING hnsw (embedding extensions.vector_cosine_ops);

-- RPC function
CREATE OR REPLACE FUNCTION match_document_chunks(
  query_embedding extensions.vector(1536),
  file_ids        uuid[],
  match_count     int DEFAULT 5,
  match_threshold float DEFAULT 0.5
)
RETURNS TABLE (chunk_text text, similarity float, file_id uuid)
LANGUAGE sql STABLE AS $$
  SELECT chunk_text,
         1 - (embedding <=> query_embedding) AS similarity,
         file_id
  FROM public.document_chunks
  WHERE file_id = ANY(file_ids)
    AND 1 - (embedding <=> query_embedding) > match_threshold
  ORDER BY embedding <=> query_embedding ASC
  LIMIT match_count;
$$;
```

### Migration 012: ai_queue request_type constraint

```sql
-- File: db/migrations/012_ai_queue_vectorize_type.sql
-- Hien tai CHECK constraint chi cho: 'score', 'feedback', 'analysis'
-- Can them 'vectorize_document' cho D-05 pipeline

ALTER TABLE public.ai_queue DROP CONSTRAINT IF EXISTS ai_queue_request_type_check;
ALTER TABLE public.ai_queue ADD CONSTRAINT ai_queue_request_type_check
  CHECK (request_type IN ('score', 'feedback', 'analysis', 'vectorize_document'));

-- submission_answer_id la nullable nen safe khi request_type='vectorize_document'
-- (khong co submission lien quan)
```

### Migration 013: Supabase Storage Bucket + RLS

```sql
-- KHONG phai SQL migration thong thuong — tao qua Supabase Dashboard hoac API
-- Bucket name: 'teacher-documents' (private bucket)
-- RLS policies tren storage.objects:

-- INSERT: Teacher upload vao folder cua chinh minh
CREATE POLICY "teacher_upload_own_folder"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'teacher-documents' AND
  (storage.foldername(name))[1] = 'teachers' AND
  (storage.foldername(name))[2] = (SELECT auth.uid()::text)
);

-- SELECT: Teacher chi xem file cua minh
CREATE POLICY "teacher_view_own_files"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'teacher-documents' AND
  (storage.foldername(name))[1] = 'teachers' AND
  (storage.foldername(name))[2] = (SELECT auth.uid()::text)
);

-- DELETE: Teacher xoa file cua minh
CREATE POLICY "teacher_delete_own_files"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'teacher-documents' AND
  (storage.foldername(name))[1] = 'teachers' AND
  (storage.foldername(name))[2] = (SELECT auth.uid()::text)
);
```

### file_links: Khong can migration CHECK constraint

**Verified:** `file_links.target_type` trong schema la `text NOT NULL` — KHONG co CHECK constraint tren cot nay. Gia tri `'teacher'` co the dung ngay ma KHONG can migration ALTER.

---

## Common Pitfalls

### Pitfall 1: OOM trong Edge Function khi embed local model
**What goes wrong:** Import `@xenova/transformers` de embed tren-device → download model 200-500MB → Edge Function crash RAM limit (500MB free tier)
**Why it happens:** Embedding models lon, free tier co gioi han RAM chat
**How to avoid:** Goi OpenAI Embeddings API (`text-embedding-3-small`) hoac Ollama endpoint tu server. Khong run embedding model trong Edge Function
**Warning signs:** Edge Function timeout >30s, memory exceeded error trong logs

### Pitfall 2: LangChain.js bundle size
**What goes wrong:** Import `@langchain/textsplitters` → bundle tang 40-60MB → deploy cham, RAM cao
**How to avoid:** Dung pure JS chunking function (Pattern 8 tren) — du chinh xac, zero deps
**Warning signs:** Supabase CLI bao "bundle too large" khi deploy

### Pitfall 3: ai_queue.submission_answer_id NOT NULL assumption
**What goes wrong:** Code gia su submission_answer_id phai co gia tri → crash khi insert vectorize_document item (khong co submission lien quan)
**Why it happens:** Column la nullable trong schema nhung code co the assume NOT NULL
**How to avoid:** Insert ai_queue voi `submission_answer_id: null` cho request_type='vectorize_document', payload: `{file_id: '...', action: 'vectorize_document'}`

### Pitfall 4: Gear icon dung `context.push()` thay `context.pushNamed()`
**What goes wrong:** `context.push(AppRoute.settingsPath)` — hardcoded path string, vi pham CLAUDE.md routing rules
**Why it happens:** Existing code (line 904) dung push truc tiep
**How to avoid:** Doi sang `context.pushNamed(AppRoute.aiQuestionSettings)` — dung named route constant

### Pitfall 5: file_picker tra ve null bytes tren mot so platform
**What goes wrong:** `file.bytes` null khi khong pass `withData: true` trong FilePicker.platform.pickFiles()
**How to avoid:** LUON pass `withData: true` khi can bytes. Tren web/desktop, bytes luon co san. Tren mobile, can `withData: true`

### Pitfall 6: pgvector extension schema conflict
**What goes wrong:** `CREATE EXTENSION vector` (khong chi dinh schema) vs `CREATE EXTENSION vector WITH SCHEMA extensions` — tao ra mismatch khi query dung `extensions.vector`
**How to avoid:** Luon dung `WITH SCHEMA extensions` khi create, tham chieu nhu `extensions.vector(1536)` trong DDL

### Pitfall 7: Excel Fast Track bo sot accent/diacritic trong header matching
**What goes wrong:** GV luu file Excel voi encoding Windows-1252 → header "Câu hỏi" khong match voi UTF-8 string comparison
**How to avoid:** Normalize headers truoc khi compare: `header.normalize('NFC').toLowerCase().trim()`

### Pitfall 8: Staging Area component trong file 3127 lines
**What goes wrong:** Them Staging Area vao existing `TeacherAiGenerateQuestionScreen` day file len >3500 lines, vi pham class max 300 lines
**How to avoid:** Tach `StagingAreaWidget` ra file rieng trong `widgets/` subfolder. Planner phai split task ro rang

### Pitfall 9: DB Transaction cho "Luu va Them vao De thi"
**What goes wrong:** INSERT questions rieng, INSERT assignment_questions rieng — neu connection fail giua 2 buoc → Orphan Data
**How to avoid:** Dung Supabase RPC function (SECURITY DEFINER) de wrap ca 2 INSERT trong 1 DB transaction — KHONG dung sequential DataSource calls

---

## Runtime State Inventory

Phase 9 la feature moi, KHONG phai rename/refactor. Tuy nhien kiem tra:

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | ai_queue hiện tại chỉ có 3 request_types (score/feedback/analysis) | Migration 012: ALTER CHECK constraint thêm 'vectorize_document' |
| Live service config | process-ai-queue Edge Function đang deployed | Không sửa — tạo Edge Function mới riêng |
| OS-registered state | None | — |
| Secrets/env vars | SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY đã có trong Edge Function env | Edge Function mới cần cùng env vars + thêm EMBEDDING_API_KEY |
| Build artifacts | Không có stale artifacts | — |

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All Flutter tasks | ✓ | Dart 3.8.1 | — |
| supabase_flutter | Storage upload, DB | ✓ | ^2.0.0 | — |
| file_picker | Document file selection | ✗ | — | Không có — cần user approval + install |
| crypto (Dart) | SHA-256 client-side | ✓ (transitive) | 3.0.7 | Có sẵn, chỉ cần declare explicit |
| pgvector extension | document_chunks table | Cần verify | — | Migration 011 sẽ enable |
| Supabase Edge Functions | Vectorize pipeline | ✓ | Existing process-ai-queue deployed | — |
| npm:mammoth (Deno) | .docx parsing | Cần test | 1.8.0 | — |
| npm:xlsx (Deno) | .xlsx parsing | Cần test | 0.18.5 | — |
| Embedding API | RAG vectorization | Cần user configure | — | Dùng API key từ profiles.metadata.api_keys |

**Missing dependencies với no fallback:**
- `file_picker` — REQUIRED cho D-09. Planner phai include task "xin user approval + flutter pub add file_picker"

**Cần verify trước khi implement:**
- pgvector extension: chạy `SELECT * FROM pg_extension WHERE extname = 'vector';` trên Supabase để xác nhận có chưa
- Embedding API key: GV cần có key trong settings; Edge Function đọc từ `profiles.metadata.api_keys` (same pattern as existing AI feedback)

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Flutter test (built-in) + mocktail |
| Config file | Không cần riêng — existing test setup |
| Quick run | `flutter test test/unit/ -x` |
| Full suite | `flutter test` + `flutter analyze` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | Notes |
|--------|----------|-----------|-------------------|-------|
| 9-01 | AiQuestionSettingsScreen route đúng từ gear icon | Widget test | `flutter test test/widget/ai_settings_test.dart` | Wave 0 gap |
| 9-01 | Tile "Cài đặt API Key" navigate đến ApiKeySetupScreen | Widget test | — | Wave 0 gap |
| 9-02 | file_picker trả về .xlsx/.docx bytes | Manual smoke | Device test only | Không mock được native picker |
| 9-02 | Upload đến Supabase Storage thành công | Integration | Manual — cần real Supabase | — |
| 9-02 | INSERT files + file_links với target_type='teacher' | Unit test | `flutter test test/unit/teacher_file_datasource_test.dart` | Wave 0 gap |
| 9-03 | Heuristic Router: Fast Track khi header chuẩn | Unit test | Edge Function test | Viết trong index.test.ts |
| 9-03 | Heuristic Router: LLM Fallback khi header lộn xộn | Unit test | Edge Function test | — |
| 9-03 | Stateful checkpointing resume đúng từ processed_chunks | Unit test | Edge Function test | — |
| 9-03 | Content hash differential: bỏ qua chunk unchanged | Unit test | Edge Function test | — |
| 9-03 | match_document_chunks RPC trả về Top 5 | SQL test | Supabase SQL editor | Manual verify |
| 9-03 | QuestionDTO output từ cả 2 pipeline có cùng schema | Unit test | `flutter test test/unit/question_dto_test.dart` | Wave 0 gap |
| 9-03 | Staging Area hiển thị câu hỏi từ AI | Widget test | `flutter test test/widget/staging_area_test.dart` | Wave 0 gap |
| 9-03 | "Lưu vào Ngân hàng" INSERT vào questions table | Unit test | Mock datasource | Wave 0 gap |
| 9-03 | "Lưu và Thêm vào Đề thi" DB Transaction không tạo Orphan Data | Integration | Manual — cần real DB | — |

### Sampling Rate

- **Per task commit:** `flutter analyze && flutter test test/unit/ --no-pub`
- **Per wave merge:** `flutter test && flutter analyze`
- **Phase gate:** Full suite green + manual device smoke test trước `/gsd:verify-work`

### Wave 0 Gaps (cần tạo trước khi implement)

- [ ] `test/unit/teacher_file_datasource_test.dart` — covers REQ 9-02 (upload + DB inserts)
- [ ] `test/unit/question_dto_test.dart` — covers REQ 9-03 (unified output schema)
- [ ] `test/widget/ai_settings_test.dart` — covers REQ 9-01 (navigation)
- [ ] `test/widget/staging_area_test.dart` — covers REQ 9-03 (staging area display)
- [ ] `supabase/functions/process-document-queue/index.test.ts` — covers REQ 9-03 (Edge Function logic)

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| IVFFlat index | HNSW index | pgvector 0.5.0 (2023) | HNSW auto-updates on writes, no rebuild needed |
| text-embedding-ada-002 (1536d) | text-embedding-3-small (1536d) | Jan 2024 | 5x cheaper, same dimensions, drop-in replacement |
| `context.push(path)` | `context.pushNamed(name)` | CLAUDE.md rule | Type-safe, no hardcoded strings |
| One Edge Function cho all AI tasks | Separate Edge Functions per domain | Best practice | Isolation, khong breaking existing flow |

**Deprecated/outdated:**
- `context.push(AppRoute.settingsPath)` tại line 904: vi pham routing rules, phai doi sang `pushNamed`
- Local embedding model trong Edge Function: khong kha thi voi Supabase free tier RAM limit

---

## Open Questions

1. **Embedding API Key source cho Edge Function**
   - What we know: Existing process-ai-queue doc GV API key tu `profiles.metadata.api_keys`
   - What's unclear: GV co the chua setup key khi upload file — Edge Function phai handle gracefully
   - Recommendation: Neu chua co key, mark ai_queue.status='pending' voi error note, GV setup key sau → retry manual

2. **Excel template generation (D-16-ext)**
   - What we know: 2 options — static file tren Storage, hoac generate on-device voi Dart `excel` package
   - What's unclear: `excel` package chua co trong approved stack
   - Recommendation: Option A (static file): Upload template.xlsx vao Supabase Storage (public), link URL trong `AiQuestionSettingsScreen`. Zero additional package. Planner nen chon option nay.

3. **Staging Area placement**
   - What we know: Claude's Discretion — bottom sheet vs full screen
   - Recommendation: Bottom sheet cho <10 cau hoi, full screen (push route) cho >=10 cau hoi

4. **pgvector da enable tren Supabase project chua?**
   - What we know: Chua co bang document_chunks trong schema
   - Action: Planner phai include task check + enable truoc khi tao bang

5. **file_picker Android permission co can khong?**
   - What we know: Android 13+ (API 33+) khong can READ_EXTERNAL_STORAGE. Android < 13 can
   - Recommendation: Them permission vao AndroidManifest.xml de support ca hai — `READ_EXTERNAL_STORAGE` voi `android:maxSdkVersion="32"`

---

## Sources

### Primary (HIGH confidence)
- [Supabase pgvector Docs](https://supabase.com/docs/guides/ai/vector-columns) — CREATE EXTENSION, table schema, query pattern
- [Supabase Semantic Search Docs](https://supabase.com/docs/guides/database/extensions/pgvector) — match_documents RPC pattern
- [Supabase Storage Access Control](https://supabase.com/docs/guides/storage/security/access-control) — RLS patterns cho storage.objects
- [Supabase Dart Storage Upload](https://supabase.com/docs/reference/dart/storage-from-upload) — uploadBinary với Uint8List
- Existing `process-ai-queue/index.ts` — Verified: Deno.serve pattern, supabase-js usage, ai_queue structure
- Schema `db/schema_03_submissions_ai_analytics.sql` — Verified: files, file_links, ai_queue table structures
- Schema `db/schema_02_questions_assignments.sql` — Verified: questions, assignment_questions structures

### Secondary (MEDIUM confidence)
- [file_picker pub.dev](https://pub.dev/packages/file_picker) — version 11.0.2, allowedExtensions usage, withData flag
- [crypto pub.dev](https://pub.dev/packages/crypto) — version 3.0.7, SHA-256 usage (verified as transitive dep)
- [Supabase Edge Functions npm compat](https://supabase.com/blog/edge-functions-node-npm) — npm: specifier pattern confirmed
- [WebSearch: text-embedding-3-small 1536 dimensions] — Confirmed from multiple OpenAI sources
- [WebSearch: mammoth.js extractRawText] — Confirmed API pattern
- [WebSearch: SheetJS/xlsx sheet_to_json] — Confirmed API pattern

### Tertiary (LOW confidence — needs validation)
- Text chunking pure JS implementation — custom, chua test tren Supabase Edge Function
- mammoth.js + npm: specifier trong Deno — chua co specific example tren Supabase docs

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — verified existing packages, supabase-js patterns from real code
- DB migrations: HIGH — verified schema files directly, CHECK constraint analysis accurate
- Architecture: HIGH — patterns from official Supabase docs + existing codebase patterns
- Edge Function npm imports: MEDIUM — general npm compat confirmed, mammoth+xlsx specific not tested
- Flutter file_picker: MEDIUM — package exists + API verified, but not in project yet
- Pitfalls: HIGH — verified from schema analysis + CLAUDE.md rules

**Research date:** 2026-04-18
**Valid until:** 2026-05-18 (stable ecosystem — pgvector, supabase-js, file_picker APIs khong thay doi nhanh)
