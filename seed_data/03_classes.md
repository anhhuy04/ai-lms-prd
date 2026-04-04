# Seed Data: Các Lớp Học Phần

<!--
  Ánh xạ Supabase:
  - Bảng: public.classes (mỗi dòng = 1 lớp học phần)
  - Columns: id, school_id, teacher_id, name, subject, academic_year, class_settings (chứa lịch học, phòng học)
             student_group, semester, academic_year, schedule_day, schedule_periods,
             room, start_date, end_date, is_lab
-->

| STT | Mã lớp HP | Tên học phần | GV phụ trách | Lớp SV | Học kỳ | Năm học | Thứ/Tiết | Phòng | Ngày bắt đầu | Ngày kết thúc | Loại |
|-----|-----------|-------------|-------------|--------|--------|---------|----------|-------|-------------|--------------|------|
| 1 | MMT(224)_01/K18A1 | Mạng máy tính | Phạm Thị Đào | DHCTTCK18A1 | HK2 | 2024-2025 | Thứ 6, tiết 3,4 | A2.310 | 30/12/2024 | 04/05/2025 | LT |
| 2 | MMT(225)_01/K19A1 | Mạng máy tính | Phạm Thị Đào | DHCTTCK19A1, DHKTMCK18A1 | HK2 | 2025-2026 | Thứ 2, tiết 3,4 | A2.208 | 05/01/2026 | 10/05/2026 | LT |
| 3 | MMT(225)_03/K19A2 | Mạng máy tính | Phạm Thị Đào | DHCTTCK19A2 | HK2 | 2025-2026 | Thứ 6, tiết 8,9 | A2.411 | 22/12/2025 | 26/04/2026 | LT |
| 4 | TCB(125)_17/DTCNK20A1 | Tin học cơ bản | Phạm Thị Đào | DHDTVCK20A1 | HK1 | 2025-2026 | Thứ 6, tiết 1,2,3 | A2.404 | 08/09/2025 | 21/12/2025 | LT |
| 5 | PTUDW1(123)_04_TH/K17A2 | Phát triển ứng dụng Web 1 TH | Phạm Thị Đào | DHCTTCK17A2 | HK1 | 2023-2024 | (xưởng) | A3.204 | 16/10/2023 | 26/11/2023 | TH |
| 6 | SQLSERVER(123)_01_TH/K17A1 | Hệ quản trị CSDL SQL Server TH | Phạm Thị Đào | DHCTTCK17A1 | HK1 | 2023-2024 | (xưởng) | A3.204 | 25/09/2023 | 14/10/2023 | TH |
| 7 | PTUDW1(125)_03_TH/K19A2 | Phát triển ứng dụng Web 1 TH | Nguyễn Thị Lan Anh + Phạm Thị Đào | DHCTTCK19A2, DHCTTLK18Z | HK1 | 2025-2026 | (xưởng) | A3.402 | 01/09/2025 | 12/10/2025 | TH |
| 8 | SQLSERVER(125)_03_TH/K19A2_A | Hệ quản trị CSDL SQL Server TH (đợt 1) | Phạm Thị Đào | DHCTTCK19A2, DHCTTCK19A1, DHCTTLK18Z | HK1 | 2025-2026 | (xưởng sáng) | A3.402 | 11/08/2025 | 01/09/2025 | TH |
| 9 | SQLSERVER(125)_03_TH/K19A2_B | Hệ quản trị CSDL SQL Server TH (đợt 2) | Phạm Thị Đào | DHCTTCK19A2, DHCTTCK19A1, DHCTTLK16Z | HK1 | 2025-2026 | (xưởng chiều) | A3.402 | 01/09/2025 | 21/09/2025 | TH |
| 10 | TTTNN(225)_01/K17-K18 | Trí tuệ nhân tạo nâng cao | Phạm Thị Đào | DHCTTCK17A1, DHCTTCK17A2, DHCTTCK18A1, DHCTTCK18A2 | HK2 | 2025-2026 | Thứ 4, tiết 1,2 | A2.411 | 05/01/2025 | 10/05/2026 | LT |
| 11 | CSLTWEB(225)_01/K20A1 | Cơ sở lập trình web | Phạm Thị Đào | DHCTTCK20A1, DHCTTCK18A2, DHCTTLK18Z, DHCTTLK16Z | HK2 | 2025-2026 | Thứ 5, tiết 1,2 | A2.502 | 02/02/2026 | 07/06/2026 | LT |
| 12 | TCB(225)_08 | Tin học cơ bản | Lê Thị Linh | DHOTOCK20A5-A9, DHCTTLK18Z | HK2 | 2025-2026 | Thứ 5, tiết 6,7,8 | A2.401 | 02/02/2026 | 07/06/2026 | LT |

---

## Ghi chú mã lớp HP

- `(224)` = học phần mã 224 (chương trình cũ)
- `(225)` = học phần mã 225 (chương trình mới)
- `(123)` = học phần mã 123 (cũ)
- `(125)` = học phần mã 125 (mới)
- `_TH` = lớp thực hành
- Prefix lớp SV: DHCTTCK = ĐH Công nghệ Thông tin chính quy; DHKTMCK = ĐH Kỹ thuật máy tính; DHDTVCK = ĐH Điện tử viễn thông; DHOTOCK = ĐH Ô tô; DHCTTLK = ĐH CNTT liên kết
