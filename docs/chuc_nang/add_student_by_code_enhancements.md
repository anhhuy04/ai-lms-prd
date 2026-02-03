# Tính năng nâng cao cho Add Student By Code Screen

## 📋 Tổng quan

File này track các tính năng nâng cao cho màn hình `add_student_by_code_screen.dart` và các đề xuất implementation.

---

## 🎯 Tính năng đã hoàn thành (Cơ bản)

- ✅ Load/Save class settings từ database
- ✅ Generate QR code từ join code
- ✅ Copy mã vào clipboard
- ✅ Generate mã mới (random 6 ký tự)
- ✅ Share mã (copy to clipboard)
- ✅ Manual join limit (giới hạn số học sinh)
- ✅ UI theo Design System

## 🎯 Tính năng đã hoàn thành (Phase 1: Quick Wins)

- ✅ **Auto-refresh QR Code** - QR code tự động rebuild khi `join_code` thay đổi (đã có sẵn trong Flutter state management)
- ✅ **Validate Join Code** - Format validation (6 ký tự, A-Z0-9) và unique check trong database
- ✅ **Unsaved Changes Dialog** - Track original values, detect changes, và hiển thị dialog xác nhận khi back với thay đổi chưa lưu

---

## 🚀 Tính năng nâng cao (TODO)

### 1. Share với share_plus package (Native Share Dialog)

**Mục đích:** Cho phép chia sẻ mã QR qua các app khác (WhatsApp, Email, SMS, etc.)

**Đề xuất Implementation:**

#### Option A: Share QR Code Image
- Export QR code thành image (PNG/JPG)
- Share image qua native share dialog
- **Ưu điểm:** User có thể share QR code trực tiếp
- **Nhược điểm:** Cần generate image từ QR widget

#### Option B: Share Text + Link
- Share text: "Mã tham gia lớp học: ABC123"
- Kèm deep link: `https://app.example.com/join/classId:code`
- **Ưu điểm:** Đơn giản, không cần generate image
- **Nhược điểm:** User phải tự quét QR code

#### Option C: Share cả Image và Text
- Generate QR code image
- Share với text description
- **Ưu điểm:** Linh hoạt nhất
- **Nhược điểm:** Phức tạp hơn

**Đề xuất:** **Option C** - Linh hoạt nhất, user có thể chọn cách share

**Cần thêm:**
- Package: `share_plus` (đã có trong pubspec.yaml?)
- Method: `_shareQrCodeImage()` - Export QR thành image
- Method: `_shareViaNative()` - Gọi native share dialog

---

### 2. Validate Join Code (Kiểm tra trùng, format)

**Mục đích:** Đảm bảo join code không trùng và có format hợp lệ

**Đề xuất Implementation:**

#### Option A: Validate trên Frontend
- Check format: 6 ký tự, A-Z0-9
- Check trùng: Query database xem code đã tồn tại chưa
- **Ưu điểm:** Feedback nhanh cho user
- **Nhược điểm:** Có thể có race condition

#### Option B: Validate trên Backend
- Frontend generate code, gửi lên backend
- Backend check trùng và validate
- Nếu trùng → generate lại
- **Ưu điểm:** Đảm bảo unique, không race condition
- **Nhược điểm:** Cần thêm API endpoint

#### Option C: Hybrid (Frontend + Backend)
- Frontend validate format
- Backend validate unique khi save
- **Ưu điểm:** Cân bằng giữa UX và data integrity
- **Nhược điểm:** Cần xử lý cả 2 tầng

**Đề xuất:** **Option C** - Cân bằng tốt nhất

**Cần thêm:**
- Method: `_validateJoinCodeFormat(String code)` - Check format
- Method: `_checkCodeExists(String code)` - Check trùng trong DB
- UI: Hiển thị error nếu code không hợp lệ
- Auto-retry: Nếu trùng, tự động generate lại

---

### 3. QR Code với Logo/Theme tùy chỉnh

**Mục đích:** QR code đẹp hơn, có branding

**Đề xuất Implementation:**

#### Option A: Logo ở giữa QR code
- Embed logo của app/school ở center
- Sử dụng `QrHelper.buildQrWithLogo()`
- **Ưu điểm:** Professional, có branding
- **Nhược điểm:** Cần có logo asset

#### Option B: Custom colors
- Primary color cho QR code
- Background color tùy chỉnh
- **Ưu điểm:** Match với app theme
- **Nhược điểm:** `pretty_qr_code` có thể không support đầy đủ

#### Option C: Cả Logo và Colors
- Logo ở center
- Custom colors
- **Ưu điểm:** Đẹp nhất, professional nhất
- **Nhược điểm:** Phức tạp nhất

**Đề xuất:** **Option A** - Bắt đầu với logo, colors có thể thêm sau

**Cần thêm:**
- Asset: Logo image (app logo hoặc school logo)
- Method: `_buildQrWithLogo()` - Sử dụng QrHelper.buildQrWithLogo()
- Config: Cho phép enable/disable logo (settings)

---

### 4. Auto-refresh QR Code khi settings thay đổi

**Mục đích:** QR code tự động cập nhật khi user thay đổi settings

**Đề xuất Implementation:**

#### Option A: Rebuild widget khi state thay đổi
- Watch state changes
- Auto rebuild QR code widget
- **Ưu điểm:** Đơn giản, tự động
- **Nhược điểm:** Có thể rebuild không cần thiết

#### Option B: Manual refresh button
- User phải nhấn nút "Refresh QR" để update
- **Ưu điểm:** User control, không rebuild không cần thiết
- **Nhược điểm:** User có thể quên refresh

#### Option C: Smart auto-refresh
- Chỉ refresh khi join_code thay đổi
- Không refresh khi chỉ thay đổi settings khác
- **Ưu điểm:** Cân bằng giữa UX và performance
- **Nhược điểm:** Cần logic phức tạp hơn

**Đề xuất:** **Option C** - Smart và efficient

**Cần thêm:**
- Watch `_classCode` changes
- Rebuild QR code widget khi `_classCode` thay đổi
- Debounce để tránh rebuild quá nhiều

---

### 5. History của các mã đã tạo

**Mục đích:** Lưu lại lịch sử các mã đã tạo để có thể xem lại

**Đề xuất Implementation:**

#### Option A: Lưu trong Local Storage
- Sử dụng `flutter_secure_storage` hoặc `shared_preferences`
- Lưu danh sách mã đã tạo
- **Ưu điểm:** Nhanh, không cần backend
- **Nhược điểm:** Chỉ lưu trên device, không sync

#### Option B: Lưu trong Database
- Thêm table `join_code_history` trong Supabase
- Lưu: class_id, join_code, created_at, expires_at, is_active
- **Ưu điểm:** Sync across devices, có thể query
- **Nhược điểm:** Cần migration, phức tạp hơn

#### Option C: Hybrid
- Lưu tạm trong local storage
- Sync lên database khi có internet
- **Ưu điểm:** Best of both worlds
- **Nhược điểm:** Phức tạp nhất

**Đề xuất:** **Option B** - Database là best practice cho production

**Cần thêm:**
- Database migration: Tạo table `join_code_history`
- Repository method: `getJoinCodeHistory(String classId)`
- UI: List view hiển thị history
- Feature: Có thể reactivate mã cũ

---

### 6. Analytics: Số lần quét QR code

**Mục đích:** Track số lần QR code được quét để analytics

**Đề xuất Implementation:**

#### Option A: Simple counter
- Lưu `scan_count` trong `class_settings.enrollment.qr_code`
- Increment mỗi lần có student join bằng QR
- **Ưu điểm:** Đơn giản, không cần table mới
- **Nhược điểm:** Không track chi tiết (who, when)

#### Option B: Detailed analytics table
- Tạo table `qr_code_scans` với: class_id, join_code, student_id, scanned_at
- Track mỗi lần scan (kể cả không join)
- **Ưu điểm:** Analytics chi tiết, có thể query
- **Nhược điểm:** Cần table mới, phức tạp hơn

#### Option C: Event-based tracking
- Sử dụng analytics service (Firebase Analytics, Mixpanel, etc.)
- Track event: `qr_code_scanned`, `qr_code_used_to_join`
- **Ưu điểm:** Professional, có dashboard
- **Nhược điểm:** Cần setup analytics service

**Đề xuất:** **Option B** - Detailed analytics, có thể mở rộng sau

**Cần thêm:**
- Database migration: Tạo table `qr_code_scans`
- Repository method: `trackQrCodeScan(String classId, String joinCode, String? studentId)`
- Repository method: `getQrCodeScanStats(String classId, String joinCode)`
- UI: Hiển thị số lần scan trong screen

---

### 7. Deep Linking: QR code chứa deep link để join class trực tiếp

**Mục đích:** QR code chứa deep link, khi scan sẽ mở app và join class tự động

**Đề xuất Implementation:**

#### Option A: App-specific deep link
- Format: `ai-lms://join/classId:joinCode`
- Setup URL scheme trong Android/iOS
- **Ưu điểm:** Native, nhanh
- **Nhược điểm:** Chỉ hoạt động khi app đã cài

#### Option B: Universal link (Web fallback)
- Format: `https://app.example.com/join/classId:joinCode`
- Nếu app chưa cài → mở web, hướng dẫn cài app
- **Ưu điểm:** Hoạt động cả khi app chưa cài
- **Nhược điểm:** Cần setup web server

#### Option C: Smart link (App + Web)
- Format: `https://app.example.com/join/classId:joinCode`
- Nếu app đã cài → mở app
- Nếu chưa cài → mở web
- **Ưu điểm:** Best UX, universal
- **Nhược điểm:** Phức tạp nhất, cần setup nhiều

**Đề xuất:** **Option C** - Best UX, nhưng có thể bắt đầu với Option A

**Cần thêm:**
- URL scheme setup: `android:scheme`, `ios:CFBundleURLSchemes`
- Deep link handler: Parse URL và navigate
- GoRouter: Thêm route `/join/:classId/:code`
- Logic: Auto join class khi scan QR code

---

## 📝 Implementation Plan

### Phase 1: Quick Wins (Ưu tiên cao) ✅ HOÀN THÀNH
1. ✅ **Auto-refresh QR Code** - QR code tự động rebuild khi join_code thay đổi
2. ✅ **Validate Join Code** - Format validation (6 ký tự, A-Z0-9) + unique check trong database
3. ✅ **Unsaved Changes Dialog** - Track changes và hiển thị dialog khi back

### Phase 2: UX Improvements (Ưu tiên trung bình)
3. ⏳ **Share với share_plus** - Native share dialog (nút "Chia sẻ mã" đã tạm ẩn)
4. ✅ **QR Code với Logo** - Logo ở center QR code (với toggle enable/disable, error correction level H)

### Phase 3: Advanced Features (Ưu tiên thấp)
5. ⏳ **History của mã** - Database table + UI
6. ⏳ **Analytics** - Track scans
7. ⏳ **Deep Linking** - App + Web links

---

## 🎨 Design Decisions

### QR Code Format
- **Current:** `classId:joinCode` (e.g., `abc123:XY78ZQ`)
- **Proposed:** `https://app.example.com/join/abc123:XY78ZQ` (for deep linking)

### Join Code Format
- **Current:** 6 ký tự random (A-Z0-9)
- **Validation:** 
  - Length: 6 characters
  - Characters: A-Z, 0-9 only
  - Unique: Check trong database

### Settings Structure
```json
{
  "enrollment": {
    "qr_code": {
      "is_active": true,
      "join_code": "XY78ZQ",
      "expires_at": "2024-12-31T23:59:59Z",
      "require_approval": true,
      "scan_count": 0,
      "created_at": "2024-01-01T00:00:00Z"
    },
    "manual_join_limit": 50
  }
}
```

---

## 📚 Dependencies cần thêm

```yaml
# pubspec.yaml
dependencies:
  share_plus: ^7.0.0  # Native share dialog
  # pretty_qr_code: ^3.5.0  # Đã có
```

---

## 🔄 Migration Plan (nếu cần)

### Database Migration cho History
```sql
CREATE TABLE IF NOT EXISTS join_code_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  join_code VARCHAR(10) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN NOT NULL DEFAULT false,
  created_by UUID NOT NULL REFERENCES profiles(id),
  UNIQUE(class_id, join_code)
);

CREATE INDEX idx_join_code_history_class_id ON join_code_history(class_id);
CREATE INDEX idx_join_code_history_join_code ON join_code_history(join_code);
```

### Database Migration cho Analytics
```sql
CREATE TABLE IF NOT EXISTS qr_code_scans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  join_code VARCHAR(10) NOT NULL,
  student_id UUID REFERENCES profiles(id),
  scanned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  joined BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX idx_qr_code_scans_class_code ON qr_code_scans(class_id, join_code);
```

---

## ✅ Checklist Implementation

### Tính năng 1: Share với share_plus
- [ ] Add `share_plus` package
- [ ] Implement `_exportQrCodeImage()` method
- [ ] Implement `_shareViaNative()` method
- [ ] Update UI: Thay đổi nút "Chia sẻ mã"
- [ ] Test trên Android/iOS

### Tính năng 2: Validate Join Code ✅ HOÀN THÀNH
- [x] Implement `_validateJoinCodeFormat()` method (6 ký tự, A-Z0-9)
- [x] Implement `_generateValidJoinCode()` method với auto-retry (check unique trong DB)
- [x] Add validation khi generate code (format + unique check)
- [x] Auto-retry nếu code trùng (max 5 lần)
- [x] Repository method: `checkJoinCodeExists()` trong `SchoolClassRepository`
- [x] DataSource method: `checkJoinCodeExists()` trong `SchoolClassDataSource`

### Tính năng 3: QR Code với Logo ✅ HOÀN THÀNH
- [x] Add logo asset (`assets/icon/logo_app.png`)
- [x] Implement `QrHelper.buildQrWithLogo()` method (với error correction level H)
- [x] Update `_buildQRCodeSection()` để dùng logo khi `_qrLogoEnabled = true`
- [x] Add setting để enable/disable logo (toggle "Hiển thị logo trên QR code")
- [x] Save `logo_enabled` vào database (`class_settings.enrollment.qr_code.logo_enabled`)
- [x] Load `logo_enabled` từ database khi mở screen
- [x] Thêm `logo_enabled: true` vào `Class.defaultClassSettings()` và `create_class_screen.dart`

### Tính năng 4: Auto-refresh QR Code
- [ ] Watch `_classCode` changes
- [ ] Rebuild QR widget khi code thay đổi
- [ ] Add debounce để tránh rebuild quá nhiều

### Tính năng 5: History của mã
- [ ] Create database migration
- [ ] Add repository methods
- [ ] Add UI: History list view
- [ ] Add feature: Reactivate old code

### Tính năng 6: Analytics
- [ ] Create database migration
- [ ] Add repository methods
- [ ] Track scan events
- [ ] Add UI: Display scan stats

### Tính năng 7: Deep Linking
- [ ] Setup URL scheme (Android/iOS)
- [ ] Add GoRouter route `/join/:classId/:code`
- [ ] Implement deep link handler
- [ ] Update QR code format
- [ ] Test deep linking

---

## 💡 Notes

- Mỗi tính năng nên được implement độc lập
- Test từng tính năng trước khi chuyển sang tính năng tiếp theo
- Có thể skip một số tính năng nếu không cần thiết
- Ưu tiên các tính năng có impact cao (Share, Deep Linking)
