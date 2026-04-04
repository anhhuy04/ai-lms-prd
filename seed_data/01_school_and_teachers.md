# Seed Data: Trường và Giảng viên

<!-- 
  Ánh xạ Supabase:
  - Bảng: schools (1 record)
  - Bảng: auth.users (role = 'teacher', 14 records)
  - Bảng: public.profiles (role = 'teacher', metadata chứa school_name, degree_title)
  - Ghi chú: Lưu thông tin môn học phụ trách vào metadata hoặc bảng liên kết.
-->

---

## 1. THÔNG TIN TRƯỜNG

| Trường | Khoa | Địa chỉ |
|--------|------|---------|
| Trường Đại học Sư phạm Kỹ thuật Vinh (ĐHSPKT Vinh) | Khoa Công nghệ Thông tin | Vinh, Nghệ An |

**SQL gợi ý:**
```sql
INSERT INTO schools (id, name, short_name, faculty, address, city)
VALUES (
  gen_random_uuid(),
  'Trường Đại học Sư phạm Kỹ thuật Vinh',
  'ĐHSPKT Vinh',
  'Khoa Công nghệ Thông tin',
  'Vinh',
  'Nghệ An'
);
```

---

## 2. DANH SÁCH GIẢNG VIÊN KHOA CNTT (14 GV)

  - Bảng: auth.users (role = 'teacher', 14 records)

| STT | Họ và tên | Email | Điện thoại | Ngày sinh | Quê quán | Học vị / Chức vụ | Metadata (JSON) |
|-----|-----------|-------|-----------|-----------|----------|-----------------|---|
| 1 | Nguyễn Thị Lan Anh | anhntl.skv@gmail.com | 0919776383 | 20/01/1982 | Quỳnh Lưu, Nghệ An | ThS | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS"}` |
| 2 | Phạm Thị Thanh Bình | binmc31383@gmail.com | 0913272335 | 31/03/1983 | Hưng Nguyên, Nghệ An | ThS | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS"}` |
| 3 | Phạm Thị Đào | phamthidaoskv@gmail.com | 0399162789 | 03/07/1979 | Nghi Lộc, Nghệ An | ThS, Chủ tịch CĐBP | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS, Chủ tịch CĐBP"}` |
| 4 | Trần Thị Gia | tranthigia40@gmail.com | 0963143666 | 10/10/1981 | Yên Định, Thanh Hóa | ThS | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS"}` |
| 5 | Phan Việt Đức | phanvietducktv@gmail.com | 0904597555 | 31/05/1985 | Đức Thọ, Hà Tĩnh | GV kiêm nhiệm | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "GV kiêm nhiệm"}` |
| 6 | Trần Bình Giang | binhgiangktv@gmai.com | 0944330567 | 09/04/1981 | Quỳnh Lưu, Nghệ An | ThS | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS"}` |
| 7 | Nguyễn Quốc Khánh | khanh.nguyen.224.229@gmail.com | 0946433919 | 14/04/1977 | Thanh Chương, Nghệ An | ThS | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS"}` |
| 8 | Vũ Thị Thu Hiền | thuhienktv@gmail.com | 0904315557 | 11/05/1978 | Vinh, Nghệ An | ThS, Phó Trưởng Khoa | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS, Phó Trưởng Khoa"}` |
| 9 | Võ Thị Kim Hoa | ngaymaitroivanxanh@gmail.com | 0975640641 | 12/09/1983 | Nghi Lộc, Nghệ An | ThS | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS"}` |
| 10 | Lê Thị Ánh Hồng | hongskv@gmail.com | 0968611850 | 16/12/1980 | Hương Khê, Hà Tĩnh | ThS | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS"}` |
| 11 | Nguyễn Thị Phương Thủy | phuongthuyskv@gmail.com | 0904295567 | 01/01/1979 | Anh Sơn, Nghệ An | ThS | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS"}` |
| 12 | Hồ Ngọc Vinh | hongocvinh@gmail.com | 0968134666 | 11/11/1977 | Quỳnh Lưu, Nghệ An | TS, Trưởng Khoa | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "TS, Trưởng Khoa"}` |
| 13 | Lê Thị Linh | lelinhktv@gmail.com | 0989458282 | 26/07/1982 | Quảng Ninh, Quảng Bình | ThS | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS"}` |
| 14 | Nguyễn Thị Quỳnh Vinh | vinhnq82@gmail.com | 0964632567 | 11/11/1982 | Vinh, Nghệ An | ThS | `{"school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh", "degree_title": "ThS"}` |

---

## 3. PHÂN CÔNG HỌC PHẦN PHỤ TRÁCH

  - Ghi chú: Lưu thông tin môn học phụ trách vào metadata hoặc bảng liên kết.

| Giảng viên | Học phần phụ trách |
|-----------|-------------------|
| Nguyễn Thị Lan Anh | Kiểm thử phần mềm; Phát triển ứng dụng Web 1; Hệ quản trị CSDL SQL Server; Phân tích thiết kế hệ thống với UML; Đồ án phát triển ứng dụng Web; Phát triển ứng dụng Web 2; Mẫu thiết kế cho phần mềm; Tin học cơ bản |
| Phạm Thị Thanh Bình | Phát triển ứng dụng Windows 1; Cơ sở lập trình web; Lập trình C/C++; Phát triển ứng dụng Windows 2; Lập trình Windows; Tin học cơ bản |
| Phạm Thị Đào | Cơ sở lập trình web; Trí tuệ nhân tạo nâng cao; Phát triển ứng dụng Web 1; Hệ quản trị CSDL SQL Server; Cơ sở dữ liệu; Mạng máy tính; Phát triển ứng dụng Web 2; Tin học cơ bản |
| Trần Thị Gia | Khai phá dữ liệu; Tin học cơ bản; Toán rời rạc; Trí tuệ nhân tạo nâng cao |
| Phan Việt Đức | Tin học cơ bản |
| Trần Bình Giang | Phát triển ứng dụng di động 1; Lập trình di động; Xử lý ảnh số; Tin học cơ bản; Ứng dụng AI trong CNTT; Thiết kế lắp đặt hệ thống IOT; Phát triển ứng dụng di động 2 |
| Nguyễn Quốc Khánh | Thiết kế hệ thống mạng; Mạng máy tính; Quản trị mạng; Chuyên đề tốt nghiệp 2; Hệ điều hành Windows Server; Tin học cơ bản |
| Vũ Thị Thu Hiền | Cấu trúc máy tính; Lập trình di động; Phát triển ứng dụng di động 2; Kỹ thuật lập trình nhúng; Điện toán đám mây; Phát triển ứng dụng di động 1; Kỹ thuật ghép nối máy tính; Tin học cơ bản |
| Võ Thị Kim Hoa | Thiết kế lắp đặt hệ thống IOT; Xử lý ảnh số; Phát triển ứng dụng di động 1; Tin học cơ bản; Lập trình di động; Lập trình Java |
| Lê Thị Ánh Hồng | (chưa có dữ liệu học phần) |
| Nguyễn Thị Phương Thủy | Lập trình C/C++; Lập trình Windows; Phát triển ứng dụng Windows 1; Tin học cơ bản; Hệ quản trị CSDL SQL Server; Phân tích thiết kế hệ thống với UML; Phát triển ứng dụng Windows 2 |
| Hồ Ngọc Vinh | Bảo mật thông tin; Nhập môn chuyên ngành; Quản trị dự án; Tin học cơ bản; Cấu trúc dữ liệu và giải thuật; Chuyên đề tốt nghiệp 1; Chuyên đề tốt nghiệp 2 |
| Lê Thị Linh | Thiết kế lắp đặt hệ thống IOT; Hệ quản trị CSDL SQL Server; Tin học cơ bản; Cơ sở dữ liệu; Lập trình C/C++ |
| Nguyễn Thị Quỳnh Vinh | Cấu trúc dữ liệu và giải thuật; Lập trình Java; Phát triển ứng dụng di động 1; Tin học cơ bản; Lập trình song song; Lập trình di động; Phát triển ứng dụng di động 2 |
