/**
 * Real TypeScript tests — process-document-queue Edge Function
 *
 * Replaces W0 stubs. Covers pure functions only (no network, no Supabase).
 * vectorizeDocument / callGeminiEmbedding require live mocks — out of scope.
 *
 * Run: deno test --allow-all index.test.ts
 */

import {
  assertEquals,
  assertNotEquals,
  assertExists,
} from 'https://deno.land/std@0.208.0/assert/mod.ts';

import {
  detectFastTrack,
  fastTrackMap,
  sha256,
  splitText,
} from './index.ts';

// ---------------------------------------------------------------------------
// detectFastTrack — Heuristic Router (D-13)
// ---------------------------------------------------------------------------

Deno.test('detectFastTrack: pattern-1 Vietnamese headers → returns headers', () => {
  const rows = [
    {
      'Câu hỏi': 'Q1',
      'Đáp án A': 'Opt A',
      'Đáp án B': 'Opt B',
      'Đáp án đúng': 'Đáp án A',
    },
  ];
  const result = detectFastTrack(rows);
  assertExists(result, 'Expected headers array, got null');
  assertEquals(Array.isArray(result), true);
});

Deno.test('detectFastTrack: pattern-2 English headers → returns headers', () => {
  const rows = [
    {
      'Question': 'Q1',
      'Option A': 'Opt A',
      'Option B': 'Opt B',
      'Correct Answer': 'Option A',
    },
  ];
  const result = detectFastTrack(rows);
  assertExists(result, 'Expected headers array, got null');
});

Deno.test('detectFastTrack: pattern-3 nội dung / lựa chọn / đáp án → returns headers', () => {
  const rows = [
    {
      'Nội dung câu hỏi': 'Q1',
      'Lựa chọn A': 'Opt A',
      'Lựa chọn B': 'Opt B',
      'Đáp án': 'Lựa chọn A',
    },
  ];
  const result = detectFastTrack(rows);
  assertExists(result, 'Expected headers array, got null');
});

Deno.test('detectFastTrack: non-standard headers → returns null', () => {
  const rows = [{ 'Content': 'Q1', 'Reply': 'A', 'Score': '10' }];
  const result = detectFastTrack(rows);
  assertEquals(result, null);
});

Deno.test('detectFastTrack: empty rows array → returns null', () => {
  const result = detectFastTrack([]);
  assertEquals(result, null);
});

Deno.test('detectFastTrack: partial match (missing đáp án đúng) → returns null', () => {
  // Has 'câu hỏi' and 'đáp án a' but NOT 'đáp án đúng' — pattern-1 requires all 4 keys
  const rows = [{ 'câu hỏi': 'Q1', 'đáp án a': 'A' }];
  const result = detectFastTrack(rows);
  assertEquals(result, null);
});

// ---------------------------------------------------------------------------
// fastTrackMap — Question mapping (D-13)
// Also regression test for BUG A (correctKey ambiguity)
// ---------------------------------------------------------------------------

Deno.test('fastTrackMap: maps question text correctly', () => {
  const headers = ['câu hỏi', 'đáp án a', 'đáp án b', 'đáp án đúng'];
  const rows = [
    {
      'câu hỏi': 'Thủ đô Việt Nam là?',
      'đáp án a': 'Hà Nội',
      'đáp án b': 'TP.HCM',
      'đáp án đúng': 'đáp án a',
    },
  ];
  const questions = fastTrackMap(rows, headers);
  assertEquals(questions.length, 1);
  assertEquals(questions[0].content.text, 'Thủ đô Việt Nam là?');
});

Deno.test('fastTrackMap: maps choices correctly (excludes correctKey column)', () => {
  const headers = ['câu hỏi', 'đáp án a', 'đáp án b', 'đáp án c', 'đáp án đúng'];
  const rows = [
    {
      'câu hỏi': 'Q?',
      'đáp án a': 'Choice A',
      'đáp án b': 'Choice B',
      'đáp án c': 'Choice C',
      'đáp án đúng': 'đáp án b',
    },
  ];
  const questions = fastTrackMap(rows, headers);
  assertEquals(questions[0].choices?.length, 3);
  // 'đáp án đúng' must NOT appear as a choice
  const choiceTexts = questions[0].choices?.map(c => c.text);
  assertEquals(choiceTexts?.includes('đáp án đúng'), false);
});

// BUG-A regression: with headers ordered [câu hỏi, đáp án a, đáp án b, đáp án đúng],
// correctKey must resolve to 'đáp án đúng', NOT 'đáp án a'.
// Before the fix: h.includes('đáp án') matched 'đáp án a' first → correct_index = -1.
Deno.test('fastTrackMap BUG-A regression: correct_index != -1 when đáp án đúng appears after đáp án a/b', () => {
  const headers = ['câu hỏi', 'đáp án a', 'đáp án b', 'đáp án đúng'];
  const rows = [
    {
      'câu hỏi': 'Câu hỏi?',
      'đáp án a': 'Sai',
      'đáp án b': 'Đúng',
      // Value references the column name of the correct choice
      'đáp án đúng': 'đáp án b',
    },
  ];
  const questions = fastTrackMap(rows, headers);
  assertEquals(questions.length, 1);
  // correct_index should be 1 (index of 'đáp án b' in choiceKeys = ['đáp án a', 'đáp án b'])
  assertNotEquals(questions[0].answer.correct_index, -1,
    'BUG-A: correct_index is -1 — correctKey resolved to the wrong column');
  assertEquals(questions[0].answer.correct_index, 1);
});

Deno.test('fastTrackMap BUG-A regression: đáp án a as correct answer → correct_index = 0', () => {
  const headers = ['câu hỏi', 'đáp án a', 'đáp án b', 'đáp án đúng'];
  const rows = [
    {
      'câu hỏi': 'Q?',
      'đáp án a': 'Đúng',
      'đáp án b': 'Sai',
      'đáp án đúng': 'đáp án a',
    },
  ];
  const questions = fastTrackMap(rows, headers);
  assertEquals(questions[0].answer.correct_index, 0);
});

Deno.test('fastTrackMap: filters rows where questionKey is empty/falsy', () => {
  const headers = ['câu hỏi', 'đáp án a', 'đáp án đúng'];
  const rows = [
    { 'câu hỏi': '', 'đáp án a': 'A', 'đáp án đúng': 'đáp án a' },
    { 'câu hỏi': 'Real Q', 'đáp án a': 'A', 'đáp án đúng': 'đáp án a' },
  ];
  const questions = fastTrackMap(rows, headers);
  assertEquals(questions.length, 1);
  assertEquals(questions[0].content.text, 'Real Q');
});

Deno.test('fastTrackMap: English pattern-2 maps correctly', () => {
  const headers = ['Question', 'Option A', 'Option B', 'Correct Answer'];
  const rows = [
    {
      'Question': 'Capital of France?',
      'Option A': 'Berlin',
      'Option B': 'Paris',
      'Correct Answer': 'Option B',
    },
  ];
  const questions = fastTrackMap(rows, headers);
  assertEquals(questions.length, 1);
  assertEquals(questions[0].content.text, 'Capital of France?');
  assertEquals(questions[0].answer.correct_index, 1); // 'Option B' is index 1
});

// ---------------------------------------------------------------------------
// sha256 — Content hashing (D-30)
// ---------------------------------------------------------------------------

Deno.test('sha256: same input produces identical hash', async () => {
  const hash1 = await sha256('Hello, World!');
  const hash2 = await sha256('Hello, World!');
  assertEquals(hash1, hash2);
});

Deno.test('sha256: different inputs produce different hashes', async () => {
  const hash1 = await sha256('text one');
  const hash2 = await sha256('text two');
  assertNotEquals(hash1, hash2);
});

Deno.test('sha256: output is 64-char hex string', async () => {
  const hash = await sha256('test');
  assertEquals(hash.length, 64);
  assertEquals(/^[0-9a-f]+$/.test(hash), true, 'hash is not lowercase hex');
});

Deno.test('sha256: empty string produces known SHA-256 hash', async () => {
  const hash = await sha256('');
  // SHA-256('') = e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
  assertEquals(hash, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
});

// ---------------------------------------------------------------------------
// splitText — Recursive character splitter (D-17)
// ---------------------------------------------------------------------------

Deno.test('splitText: short text (< CHUNK_SIZE) returned as single chunk', () => {
  const text = 'A short sentence that is well under five hundred characters.';
  const chunks = splitText(text);
  assertEquals(chunks.length, 1);
  assertEquals(chunks[0], text.trim());
});

Deno.test('splitText: trivially short chunks (≤ 20 chars) are filtered out', () => {
  // Lots of short paragraphs padded with a long one
  const longPara = 'X'.repeat(600);
  const text = `Hi\n\n${longPara}`;
  const chunks = splitText(text);
  // 'Hi' is 2 chars — should be filtered; longPara chunk(s) should remain
  assertEquals(chunks.every(c => c.length > 20), true);
});

Deno.test('splitText: long text split at \\n\\n boundary produces multiple chunks', () => {
  const para1 = 'A'.repeat(300);
  const para2 = 'B'.repeat(300);
  const text = `${para1}\n\n${para2}`;
  const chunks = splitText(text);
  assertEquals(chunks.length >= 2, true, 'Expected at least 2 chunks');
  // Each chunk must not massively exceed CHUNK_SIZE (allow overlap)
  chunks.forEach(c => assertEquals(c.length <= 600, true, `Chunk too large: ${c.length}`));
});

Deno.test('splitText: each chunk from splitting long text is <= CHUNK_SIZE + CHUNK_OVERLAP', () => {
  const text = ('Word '.repeat(50) + '\n\n').repeat(10);
  const chunks = splitText(text);
  // CHUNK_SIZE=500, CHUNK_OVERLAP=100 → max chunk with overlap ≈ 600
  chunks.forEach(c =>
    assertEquals(c.length <= 600, true, `Chunk exceeds limit: ${c.length} chars`)
  );
});

Deno.test('splitText: empty string returns no chunks', () => {
  const chunks = splitText('');
  assertEquals(chunks.length, 0);
});

Deno.test('splitText: whitespace-only string returns no chunks', () => {
  const chunks = splitText('   \n\n  \n  ');
  assertEquals(chunks.length, 0);
});

Deno.test('splitText: overlap causes end of chunk[0] to appear at start of chunk[1]', () => {
  // Build text with clear paragraph breaks so chunks split predictably
  const para1 = 'Alpha '.repeat(90).trim(); // ~540 chars → forces split
  const para2 = 'Beta '.repeat(90).trim();
  const text = `${para1}\n\n${para2}`;
  const chunks = splitText(text);
  // With overlap, chunk[1] should start with the last 100 chars of chunk[0]
  if (chunks.length >= 2) {
    const overlapFromChunk0 = chunks[0].slice(-100).trim();
    assertEquals(
      chunks[1].startsWith(overlapFromChunk0),
      true,
      'Overlap not found at beginning of second chunk'
    );
  }
});
