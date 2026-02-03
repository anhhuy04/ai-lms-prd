# Code Health Tools (dependency_validator + DCM)

Mục tiêu: kiểm soát **nợ kỹ thuật** (dependencies, code bỏ hoang) ngay từ đầu, tránh tình trạng `lib/` phình to nhưng nhiều code không còn dùng.

## 1) dependency_validator (bắt buộc dùng định kỳ)

### Vì sao nên dùng?

- **Bắt lỗi sớm** khi bạn thêm/bớt feature:
  - dependency đã khai báo nhưng không dùng (unused)
  - dependency dùng trong `lib/` nhưng lại khai trong `dev_dependencies` (under-promoted)
  - dependency chỉ dùng cho build/test nhưng lại nằm trong `dependencies` (over-promoted)
  - dependency thiếu khai báo (missing)

### Khi nào chạy?

- Mỗi lần:
  - thêm package mới vào `pubspec.yaml`
  - xóa/migrate module, đổi kiến trúc, refactor lớn
  - trước khi merge PR lớn / trước khi release

### Cách chạy

```bash
dart run dependency_validator
```

## 2) DCM (bản free/CLI) - chống code “bỏ hoang”

### Vì sao nên dùng?

- Kiểm tra các widget/file/code trong `lib/` **có thực sự được dùng** không.
- Phát hiện sớm:
  - unused files
  - unused code
  - dependency sai chỗ

### Cách dùng (nếu đã cài)

```bash
dcm check-dependencies lib
dcm check-unused-code lib
dcm check-unused-files lib
```

Ghi chú: nếu bạn chưa cài DCM, script `tool/quality_checks.ps1` sẽ tự bỏ qua và in hướng dẫn.

## 3) Tool chạy 1 lệnh (CI-ready)

### Windows (PowerShell)

```powershell
.\tool\quality_checks.ps1
```

Tuỳ chọn:
- `-SkipPubGet`: bỏ `flutter pub get` (khi bạn vừa chạy xong)
- `-SkipAnalyze`: bỏ `flutter analyze`

### macOS/Linux

```bash
chmod +x tool/quality_checks.sh
./tool/quality_checks.sh
```

Tuỳ chọn environment:
- `SKIP_PUB_GET=true`
- `SKIP_ANALYZE=true`

## 4) Quy ước áp dụng trong team

- Mỗi PR lớn: chạy `quality_checks` 1 lần.
- Mỗi khi thêm/bớt package: chạy `dependency_validator` 1 lần.
- Nếu DCM báo unused code: ưu tiên **xóa**, hoặc ghi chú rõ vì sao cần giữ (tránh “nợ” tích tụ).

## 5) Ghi chú về DCM & lỗi `realm_dart` hiện tại

Trong thời điểm thiết lập dự án (Dart 3.x, đầu 2026), việc cài DCM bằng:

```bash
dart pub global activate dcm
```

có thể **thất bại** với lỗi tương tự:

```text
Failed to build dcm:dcm:
... realm_dart-2.3.0/lib/src/native/realm_core.dart:3518:31:
Error: The method 'asUint8List' isn't defined for the type 'Uint8List'.
...
Error: The argument type 'ByteBuffer' can't be assigned to the parameter type 'Uint8List'.
```

Điều này xuất phát từ việc `dcm` phụ thuộc `realm_dart 2.3.0`, phiên bản này chưa tương thích API Dart mới (`Uint8List.asUint8List`, type changes).

**Cách xử lý tạm thời trong project này:**

- Không ép cài DCM global nếu `dart pub global activate dcm` báo lỗi build.
- Chấp nhận để script `tool/quality_checks.ps1`:
  - Chạy `flutter analyze`, `dependency_validator`, `dart fix --dry-run` bình thường.
  - Nếu không tìm thấy `dcm` trong PATH, chỉ log:  
    `"DCM chưa được cài. Bỏ qua. (Xem docs để cài bản free/CLI)"`  
    và **không fail pipeline**.
- Khi DCM ra phiên bản mới đã compatible, chỉ cần:

```bash
dart pub global activate dcm
dcm --version
```

nếu thành công, `tool/quality_checks.ps1` sẽ tự động bắt đầu chạy thêm các lệnh `dcm check-*` mà không cần sửa code.

## Prompt chuẩn “Housekeeping toàn bộ codebase”

## Bạn có thể copy nguyên khối này để dùng cho các phiên sau:
Bạn đang làm việc trong project Flutter AI_LMS_PRD.MỤC TIÊU: Chạy FULL bộ “housekeeping / code health” để:- Làm sạch pubspec.yaml và dependencies.- Tìm code/file/asset thừa.- Giảm lint errors/warnings quan trọng.- Gợi ý refactor nơi code quá phức tạp.Trước khi làm gì, hãy:1. Đọc nhanh:   - `.cursor/.clinerules`   - `.cursor/.cursorrules`   - `docs/guides/development/code-health-tools.md`   - `.cursor/plans/tong_ket_toan_bo_qua_trinh_thuc_hien_tu_dau_den_hien_tai.md`2. Tóm tắt ngắn trạng thái lint/housekeeping hiện tại (nếu đã có log trước đó trong `docs/ai/session-notes.md`).Sau đó, hãy thực hiện lần lượt các bước sau (trên Windows, root project):### B1. Chạy script housekeeping chuẩn- Lệnh chính:
powershell
tool\quality_checks.ps1 -SkipPubGet
Script này sẽ tự:- Chạy `flutter analyze --no-fatal-infos`.- Chạy `dart run dependency_validator`.- Chạy `dart fix --dry-run`.- Nếu DCM đã cài global: chạy `dcm check-dependencies lib`, `dcm check-unused-code lib`, `dcm check-unused-files lib`.Hãy:- Ghi lại kết quả tóm tắt từng phần (lint, dependency_validator, dart fix, DCM).- Không tự ý bỏ qua error, chỉ có thể “chấp nhận tạm thời” với lý do rõ ràng trong log.### B2. Phân tích kết quả từng tool và đề xuất hành động1) **dependency_validator** (GIỮ pubspec.yaml sạch – bắt buộc nếu muốn ship Store)- Đọc output:  - `may be unused`: kiểm tra trong code. Nếu thật sự không dùng, đề xuất:    - Xóa dependency khỏi `pubspec.yaml` HOẶC    - Ghi lý do giữ lại (vd: “sẽ dùng cho feature X”) vào comment trong `pubspec.yaml`.  - `under-promoted / over-promoted`: nếu package chỉ dùng trong test/build → chuyển sang `dev_dependencies`; nếu dùng trong `lib/` → chuyển sang `dependencies`.  - `pinned version` (như retrofit):     - Kiểm tra lại report và `.plans` xem có lý do (vd: tránh conflict drift) → nếu có, giữ nguyên và ghi rõ lại trong log; nếu không, đề xuất nới version.- Đưa ra danh sách đề xuất dạng:  - “Có thể gỡ bỏ: …”  - “Nên chuyển dependency ↔ dev_dependency: …”  - “Pinned nhưng có lý do kỹ thuật: giữ lại”.2) **DCM (Dart Code Metrics)** – “vũ khí hạng nặng cho app lớn”Nếu DCM đã cài (nếu chưa, chỉ gợi ý, không cài giúp):
powershell
dcm check-dependencies lib
dcm check-unused-code lib
dcm check-unused-files lib
- Với mỗi output:  - `unused-code`: liệt kê top các function/class/file không dùng → đề xuất:    - Xóa nếu chắc chắn legacy.    - Hoặc di chuyển sang thư mục `legacy/` + ghi chú nếu cần giữ.  - `complexity` / large file: chỉ ra những file/hàm phức tạp → đề xuất:    - Tách nhỏ (extract widget, service, helper) nhưng CHỈ khi không đổi behavior.  - `unused-files`: assets, widgets, screens không tham chiếu → đề xuất dọn sau khi confirm.3) **dart_depcheck** (nếu project có hoặc user muốn dùng thêm)Nếu muốn dùng `dart_depcheck`:
powershell
dart pub global activate dart_depcheck
dart_depcheck
- Dùng nó như một **“sanity check nhanh”** về unused deps, bổ sung cho dependency_validator:  - Nếu cả dart_depcheck + dependency_validator cùng báo một gói unused → gần như chắc chắn có thể xóa (sau khi confirm).  - Nếu chỉ 1 trong 2 báo → ghi chú “cần kiểm tra tay” thay vì xóa ngay.### B3. Đề xuất & (chỉ khi an toàn) áp dụng thay đổi- Với từng nhóm vấn đề:  - **Nhóm an toàn cao** (format, prefer_single_quotes, doc comment, nhỏ lẻ) → có thể áp dụng ngay (bằng `dart fix --apply` hoặc chỉnh tay).  - **Nhóm ảnh hưởng cấu trúc** (xóa dependency, xóa file, refactor lớn) →     - CHỈ đề xuất + viết rõ trong summary: “nên làm khi có thời gian test riêng”.    - Không tự động xóa nếu không có chỉ định.- Sau khi áp dụng các fix an toàn:  - Chạy lại: `flutter analyze --no-fatal-infos`.  - Nếu sạch error, ghi rõ trong log.### B4. Cập nhật log & memory cho phiên này- Append entry mới vào:  - `docs/ai/session-notes.md` (theo template sẵn có – timestamp, files chạm, quyết định, TODO).  - `.cursor/plans/tong_ket_toan_bo_qua_trinh_thuc_hien_tu_dau_den_hien_tai.md` (mục “Housekeeping / Code Health”).- Nếu có quyết định quan trọng mang tính định hướng (ví dụ: “giữ retrofit pin vì drift conflict”, “bắt buộc chạy `tool\quality_checks.ps1` trước mọi PR”) → cập nhật:  - `memory-bank/activeContext.md` phần “Currently In Progress” hoặc “Critical Technical Decisions Made”.### B5. Quy tắc quan trọng khi chạy housekeeping- **Không được nuốt exception hoặc ẩn lỗi thật** chỉ để hết lint.- Ưu tiên:  1. Error/breaking → phải fix hoặc log lý do defer.  2. Warnings có nguy cơ crash (async-gap BuildContext, deprecated critical API).  3. Sau đó mới đến cosmetic (quotes, formatting, v.v.).- Mọi thay đổi “lớn” (xóa dependency, xóa file) phải:  - Được ghi lại trong session-notes.  - Tôn trọng các rule trong `.clinerules`, `.cursorrules`.Bây giờ hãy thực hiện toàn bộ quy trình