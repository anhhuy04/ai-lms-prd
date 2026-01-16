# Quy ước tạo file tài liệu (Markdown) trong dự án

## Mục tiêu
- Tất cả tài liệu hướng dẫn/ghi chú nội bộ phải nằm trong `docs/` để dễ tìm và dễ dọn rác.
- Không tạo thêm file `.md` ở root (trừ `README.md`).

## Quy ước vị trí
- Tài liệu AI/Cursor: `docs/ai/`
- Tài liệu MCP: `docs/mcp/`
- Tài liệu vận hành (Supabase/CI/CD): `docs/ops/`
- Ghi chú linh tinh: `docs/notes/`

## Quy ước đặt tên
- Dùng `kebab-case.md`.
- Ví dụ:
  - `docs/ai/cursor-setup.md`
  - `docs/mcp/using-supabase-mcp.md`
  - `docs/ops/supabase-setup.md`

## Prompt bắt buộc (dán vào Cursor khi yêu cầu AI tạo docs)

```text
YÊU CẦU TẠO TÀI LIỆU:
- Chỉ được tạo/cập nhật file Markdown trong thư mục docs/.
- Tuyệt đối không tạo file .md ở root (ngoại trừ README.md).
- Nếu cần tạo ghi chú tạm/thử nghiệm, đặt trong tmp/ hoặc artifacts/ (và không commit).
- Trước khi tạo file mới, kiểm tra xem đã có file tương tự trong docs/ chưa.
- Khi tạo file mới, hãy đề xuất đúng path theo cấu trúc: docs/{ai|mcp|ops|notes}/<ten>.md
- Nếu phát hiện file .md nằm sai chỗ, liệt kê và đề xuất di chuyển về docs/.
```

## Prompt cho MCP Memory (Auto-save những thứ cần nhớ)

Tham chiếu file:
- `docs/ai/MEMORY_MCP_PROMPT.md`
