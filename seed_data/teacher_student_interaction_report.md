# Báo Cáo Phân Tích Dữ Liệu Seed: Giáo Viên Phạm Thị Đào & Sinh Viên Thái Anh Huy

Được trích xuất từ database Supabase CLI nội bộ (local docker).

## 1. Thông Tin Chung
* **Giáo viên:** Phạm Thị Đào 
  * Email: `phamthidaoskv@gmail.com`
  * ID (UUID): `51e467a2-9033-5e85-b666-164ea075f6c9`
  * Role: Teacher
* **Sinh viên:** Thái Anh Huy
  * Email: `anhhuy@gmail.com`
  * ID (UUID): `b3e27ac4-a528-5174-92f8-99a8f273eb84`
  * Role: Student

## 2. Các Lớp Học Tương Tác
Giáo viên Phạm Thị Đào dạy tổng cộng 11 lớp. Sinh viên Thái Anh Huy tham gia tổng cộng 7 lớp. 
Hai người có tương tác trực tiếp ở **5 lớp học chung**:
1. `MMT(225)_01/K19A1 - Mạng máy tính` 
2. `SQLSERVER(125)_03_TH/K19A2_A - Hệ quản trị CSDL SQL Server TH (đợt 1)`
3. `TTTNN(225)_01/K17-K18 - Trí tuệ nhân tạo nâng cao`
4. `CSLTWEB(225)_01/K20A1 - Cơ sở lập trình web`
5. `K17A1` (Lập trình Python & Web)

## 3. Hoạt Động Bài Tập (Assignments & Submissions)
Trong các lớp học giảng dạy bởi cô Đào, sinh viên Anh Huy đã nộp các bài tập sau:

**Lớp K17A1 (Python & Web):**
Sinh viên này có làm nhiều lần trên cùng một assignment, cho thấy dữ liệu seed có nhiều attempts hoặc trùng lặp submissions.
* *Kiểm tra 15 phút - Cú pháp Python cơ bản:* 2 submissions (Điểm lần 1: 9.50, lần 2: 8.50)
* *Bài tập: Vòng lặp và Hàm trong Python:* 2 submissions (Điểm lần 1: 7.50, lần 2: 7.00)
* *Kiểm tra Giữa kỳ - Lập trình Hướng đối tượng Python:* 2 submissions (Điểm lần 1: 5.00, lần 2: 9.00)
* *Bài tập Web: HTML/CSS và Flask cơ bản:* 2 submissions (Điểm lần 1: 10.00, lần 2: 7.50)

**Lớp TTTNN(225)_01/K17-K18 - Trí tuệ nhân tạo nâng cao:**
*(Lưu ý: Dữ liệu seed có sự gắn nhầm nội dung Mạng máy tính vào lớp Trí tuệ nhân tạo, cho thấy logic auto-seed ngẫu nhiên chưa matching chặt chẽ môn học)*
* *Bài tập chương 1: Mô hình OSI:* 1 submission (Điểm: 8.00)
* *Bài tập chương 2: Địa chỉ IP và Subnet:* 1 submission (Điểm: 7.50)
* *Kiểm tra giữa kỳ Mạng máy tính:* 1 submission (Điểm: 6.00)

## 4. Tình Trạng Làm Chủ Kiến Thức của Sinh Viên (Skill Mastery)
Môn học Mạng máy tính (MMT) - là môn mà giáo viên Đào có tham gia dạy, hệ thống AI đã phân tích mức độ Mastery của sinh viên Anh Huy (Skill Mastery):
* **MMT.1** - Hiểu mô hình OSI và các tầng mạng: **72%** (0.72) / 8 lượt làm
* **MMT.2** - Hiểu và phân biệt giao thức TCP, UDP: **65%** (0.65) / 6 lượt làm
* **MMT.3** - Tính toán địa chỉ IP và Subnet Mask: **55%** (0.55) / 8 lượt làm *(Chưa nắm vững)*
* **MMT.4** - Phân biệt thiết bị mạng (Hub, Switch, Router): **75%** (0.75) / 4 lượt làm
* **MMT.5** - Hiểu các dịch vụ mạng (DHCP, DNS, SMTP): **50%** (0.50) / 6 lượt làm *(Cần cải thiện)*
* **MMT.6** - Cấu hình và quản lý VLAN: **60%** (0.60) / 4 lượt làm

## Nhận Xét & Phân Tích
* **Phong phú về tương tác:** Hai user này có liên kết mạnh mẽ với số lượng lớn dữ liệu bài tập và điểm số đa dạng, **rất lý tưởng để dùng làm dữ liệu test cho Analytics Dashboard (Của giáo viên và Sinh viên).**
* **Điểm cần chú ý:** 
  1. Multiple submissions: Seed data tạo ra nhiều submission trên 1 bài kiểm tra, cần đảm bảo UI hiển thị điểm attempt cuối cùng/highest score (hoặc list attempts).
  2. Data logic: Có một số assignment về "Mạng máy tính" xuất hiện trong lớp "Trí tuệ nhân tạo nâng cao" do randomize seed - cần verify xem app UI hiển thị thế nào.
  3. Có dữ liệu override grade từ giáo viên (`grade_overrides`), chứng tỏ mock data khá đầy đủ để test tính năng Teacher Grading.
