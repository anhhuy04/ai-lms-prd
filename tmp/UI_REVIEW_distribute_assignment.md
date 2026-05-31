# UI Review — Trang Giao Bài Tập (teacher_distribute_assignment_screen.dart)

> 2026-05-31. User báo "giao diện & chức năng chưa ổn, nhất là màn PC". Quan sát qua marionette (web 1920px) + đọc source.

## Vấn đề (PC / wide screen)
1. **Không center-constrain nội dung** — `body: CustomScrollView` (dòng 190) với `SliverToBoxAdapter > Container` full-width, KHÔNG bọc `WideContentWrapper`/`ConstrainedBox(maxWidth)`. Trên PC 1920px form giãn sát 2 mép → thưa, khó đọc, các ô ngày/giờ rộng bất thường. (Trái với pattern dự án — xem memory `project_student_adaptive_layout`: ≥600px phải center-constrain.)
2. **Nút "Giao Bài Ngay"** nổi trong card ở giữa đáy, đè lên section "Cài đặt nâng cao" → trên PC trông như floating bar lệch, che nội dung. Nên là bottom bar full-width cố định hoặc nằm trong luồng content có max-width.
3. **Card "Đối tượng" + "Thêm Lớp/Nhóm/Học sinh"** kéo dài hết chiều ngang → mảng trống lớn.
4. Header "DOTEST Inline Objective + Dự kiến 0 học sinh" căn giữa nhưng phần dưới full-width → bố cục không nhất quán.

## Fix đề xuất (ưu tiên)
- **A. Center-constrain (cao):** Bọc nội dung scroll trong `WideContentWrapper` (đã có sẵn ở `lib/widgets/responsive/wide_content_wrapper.dart`) hoặc `Center(child: ConstrainedBox(maxWidth: 720~840))`. Áp cho cả phần body lẫn bottom action bar để cùng 1 cột.
- **B. Bottom action ("Giao Bài Ngay"):** chuyển thành `bottomNavigationBar`/`SafeArea` bar full-width (hoặc trong cột constrained), bỏ kiểu card-nổi-đè-nội-dung.
- **C. Lịch trình:** 2 ô ngày/giờ giữ dạng 2 cột nhưng trong cột constrained; ≤600px stack dọc.
- Dùng design tokens (`DesignSpacing/DesignColors`), `.sp` cho text (cấm `.r/.w/.h` theo memory student-adaptive).

## Lưu ý
- Đã verify CHỨC NĂNG phân phối HOẠT ĐỘNG ĐÚNG: giao DOTEST cho lớp "4" → `assignment_distributions` 1 dòng (type=class). Vấn đề thuần UI/responsive, không phải logic.
- Có `ConstrainedBox` ở dòng ~571 (centerContent) cho 1 sub-widget khác — chưa áp cho body chính.

## TODO khi fix
1. Đọc full build (63-200) + bottom button + structure.
2. Bọc body + action bar trong WideContentWrapper/maxWidth.
3. flutter analyze + hot reload + screenshot PC để đối chiếu trước/sau.
