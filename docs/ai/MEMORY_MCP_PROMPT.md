# MCP Memory Prompt (Auto-save những thứ cần nhớ)

```text
VAI TRÒ:
Bạn là AI agent làm việc trong repo này. Bạn có quyền dùng Memory MCP để lưu/đọc ghi nhớ dài hạn.

MỤC TIÊU MEMORY:
- Memory dùng để lưu "facts bền vững" và "quy ước/decision" giúp làm việc các session sau.
- Không lưu thông tin tạm thời, không lưu output dài, không lưu dữ liệu nhạy cảm.

NGUYÊN TẮC LƯU (KHI NÀO LƯU):
Sau mỗi khi xảy ra 1 trong các sự kiện sau, bạn PHẢI cân nhắc lưu Memory:
1) Quyết định kiến trúc / pattern / conventions (ví dụ: state management, folder structure, naming).
2) Thay đổi cấu trúc dự án (di chuyển file, đổi đường dẫn docs).
3) Setup tooling quan trọng (MCP servers, cách chạy dự án, scripts dọn rác).
4) Discovery quan trọng về hệ thống (module nào làm gì, luồng dữ liệu, constraint).
5) Fix bug "khó" (root cause + cách tránh tái phát).

KHÔNG ĐƯỢC LƯU:
- Secrets/tokens/keys/password.
- Nội dung chat dài hoặc log dài.
- Thông tin có thể suy ra trực tiếp từ code mỗi lần (trừ khi là quy ước dễ quên).
- TODO ngắn hạn hoặc việc đang làm dở (để vào task list, không phải memory).

MEMORY SCORE (0-5):
Chỉ lưu nếu score >= 3.
+1: Thông tin tái sử dụng ở session sau
+1: Là quy ước/decision ảnh hưởng nhiều file hoặc workflow
+1: Nếu quên sẽ gây lỗi/đi sai hướng
+1: Có Source cụ thể (file/command/path)
+1: Không dễ suy ra lại từ code trong 30s

ĐỊNH DẠNG MEMORY (BẮT BUỘC):
Mỗi memory phải theo mẫu sau (ngắn gọn, có cấu trúc):

[TYPE] <title ngắn>
Context: <vì sao cần nhớ / dùng khi nào>
Decision/Fact: <điểm chính 1-3 gạch đầu dòng>
Source: <file paths / thư mục / lệnh / PR/commit nếu có>
Tags: <kebab-case tags, 2-6 tags>
Updated: <yyyy-mm-dd>

QUY TẮC CHỐNG TRÙNG:
- Trước khi lưu memory mới, hãy search/retrieve memory theo từ khóa liên quan.
- Nếu đã có memory tương tự: cập nhật (append/replace) thay vì tạo bản mới.

QUY TẮC CHẤT LƯỢNG:
- 1 memory: tối đa ~10-15 dòng.
- Ưu tiên "how to apply" hơn là "diễn giải dài".
- Luôn ghi Source để kiểm chứng.

CHU KỲ:
- Cuối mỗi phiên hoặc sau khi hoàn thành 1 milestone, hãy tạo mục "Session Summary" (ngắn) và lưu.

THỰC THI:
- Khi bạn quyết định cần lưu, hãy gọi Memory MCP (store) ngay.
- Khi bắt đầu task mới, hãy gọi Memory MCP (retrieve/search) theo từ khóa liên quan trước khi đoán.

VÍ DỤ MEMORY ĐÚNG:

[CONVENTION] Docs organization
Context: Tài liệu dự án cần gom 1 chỗ để dễ dọn repo.
Decision/Fact:
- Docs nội bộ đặt trong docs/{ai|mcp|ops|notes}/
- Không tạo .md ở root trừ README.md
- Script dọn: tools/cleanup_docs.ps1
Source: docs/ai/DOCS_PROMPT_RULES.md, tools/cleanup_docs.ps1
Tags: docs, convention, cleanup, mcp
Updated: 2026-01-15
```
