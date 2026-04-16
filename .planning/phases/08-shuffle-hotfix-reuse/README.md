# Phase 08: Shuffle, Hotfix & Reuse

**Ngày tạo:** 2026-04-16  
**Status:** Planning

## Mô tả

4 feature groups liên quan đến quản lý bài tập nâng cao:

| Group | Tên | Dependency | Plan file |
|-------|-----|------------|-----------|
| 08-A | Data Contract Fix (Choice IDs + DB Function rewrite) | None — làm TRƯỚC | `docs/superpowers/plans/2026-04-16-phase-08A-data-contract-fix.md` |
| 08-B | Shuffle Wiring vào Workspace | Phụ thuộc 08-A | `docs/superpowers/plans/2026-04-16-phase-08B-shuffle-wiring.md` |
| 08-C | Hotfix câu hỏi sau Publish + Batch Regrade | Độc lập | `docs/superpowers/plans/2026-04-16-phase-08C-hotfix-questions.md` |
| 08-D | Reuse + Deep Clone | Độc lập | `docs/superpowers/plans/2026-04-16-phase-08D-reuse-deep-clone.md` |

## Thứ tự đề xuất

```
08-A  →  08-B
         ↑
08-C ────┤  (song song)
         ↓
08-D ────┘  (song song)
```

08-C và 08-D có thể làm song song với 08-B sau khi 08-A xong.

## Kiến trúc Key Decisions

1. **Snapshot Architecture**: Variant chỉ lưu ORDER pointer `[{aq_id, display_order, shuffled_choices}]`, không lưu content.
2. **Delta Override**: Hotfix chỉ ghi vào `assignment_questions.custom_content`, không đụng `questions` bank.
3. **Structural Immutability**: Khi đã có work_sessions → chỉ cho sửa text, lock thêm/xóa choice.
4. **Immutable Deep Clone**: Clone giữ `question_id` tham chiếu bank, `custom_content=NULL`.
5. **Dumb TV Pattern**: Frontend render theo variant data, gửi ID gốc, không tự tính toán.
