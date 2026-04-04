# Seed Data: Danh sách Sinh viên (Tổng hợp)

<!--
  Ánh xạ Supabase:
  - Bảng: auth.users (role = 'student')
  - Bảng: public.profiles (role = 'student', metadata chứa thông tin thêm: student_code, enrollment_class, school_name)
  - Dedup: cùng mã SV chỉ insert 1 lần
  
  Nguồn dữ liệu:
  - dhcttck17a1-dtk.md (53 SV K17A1)
  - danh-sach-cung-svk17a2.md (90 SV K17A2)
  - so-tay.md (TTTNN: SV K17A1, K17A2, K18A1, K18A2)
  - so-taymmt-k18a1.md (MMT K18A1 + DHKTMCK17A1)
  - so-tay-mmt-k19a1.md (MMT K19A1 + DHKTMCK18A1)
  - so-tay-mmt-k19a2.md (MMT K19A2)
  - so-tay-th.md (TH K17A1, K17A2)
  - so-tay-th-ptud-1.md (TH Web1 K19A2, DHCTTLK18Z)
  - so-tay-th-sql-02.md + so-tay-th-sql-03.md (SQL K19A2, K19A1)
  - so-tay-co-so-lt-web-k20a1.md (Web K20A1, K18A2, DHCTTLK18Z, DHCTTLK16Z)
  - thcb-08.md (THCB DHOTOCK20A5-A9, DHCTTLK18Z)
  - so-tay-tcb-chinh-thuc.md (TCB DHDTVCK20A1)
-->

---

## DHCTTCK17A1 — 53 sinh viên (Kết quả toàn khóa)

| STT | Mã SV | Lớp nhập học | Họ và tên | Ngày sinh | Email | Metadata (JSON) |
|---|---|---|---|---|---|---|
| 1 | 1705220057 | DHCTTCK17A1 | Thái Anh Huy | 10/02/2004 | anhhuy@gmail.com | `{"student_code": "1705220057", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 2 | 1705220035 | DHCTTCK17A1 | Lữ Quang Thái | 13/11/2000 | quangthai@gmail.com | `{"student_code": "1705220035", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 3 | 1705220544 | DHCTTCK17A1 | Phan Huy Đệ | 13/10/2004 | huyde@gmail.com | `{"student_code": "1705220544", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 4 | 1705220157 | DHCTTCK17A1 | Nguyễn Khánh Toàn | 15/10/2004 | khanhtoan@gmail.com | `{"student_code": "1705220157", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 5 | 1705220843 | DHCTTCK17A1 | Lê Xuân Trung | 16/01/2004 | xuantrung@gmail.com | `{"student_code": "1705220843", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 6 | 1305180594 | DHCTTCK15A2 | Cao Đức Anh Quân | 25/05/1999 | anhquan@gmail.com | `{"student_code": "1305180594", "enrollment_class": "DHCTTCK15A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 7 | 1705220749 | DHCTTCK17A1 | Hồ Trung Thành | 13/08/2004 | trungthanh@gmail.com | `{"student_code": "1705220749", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 8 | 1705220246 | DHCTTCK17A1 | Võ Tiến Hưng | 24/11/2003 | tienhung@gmail.com | `{"student_code": "1705220246", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 9 | 1705220484 | DHCTTCK17A1 | Trần Đình Nam | 09/02/2004 | dinhnam@gmail.com | `{"student_code": "1705220484", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 10 | 1705220245 | DHCTTCK17A1 | Hà Đặng Anh Quyến | 01/06/2004 | anhquyen@gmail.com | `{"student_code": "1705220245", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 11 | 1705220221 | DHCTTCK17A1 | Trần Quốc Trung | 04/06/2004 | quoctrung@gmail.com | `{"student_code": "1705220221", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 12 | 1705220994 | DHCTTCK17A1 | Lê Văn Hoàn | 26/02/2004 | vanhoan@gmail.com | `{"student_code": "1705220994", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 13 | 1705220467 | DHCTTCK17A1 | Kiều Mạnh Trinh | 03/09/2004 | manhtrinh@gmail.com | `{"student_code": "1705220467", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 14 | 1705220247 | DHCTTCK17A1 | Dương Kim Úc | 06/07/2004 | kimuc@gmail.com | `{"student_code": "1705220247", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 15 | 1705221188 | DHCTTCK17A1 | KHOTPHOUTHONE Soulima | 18/04/2004 | khotphouthonesoulima@gmail.com | `{"student_code": "1705221188", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 16 | 1705220451 | DHCTTCK17A1 | Nguyễn Viết Mười | 18/12/2003 | vietmuoi@gmail.com | `{"student_code": "1705220451", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 17 | 1705221201 | DHCTTCK17A1 | XAMONTY Angoun | 14/03/2003 | xamontyangoun@gmail.com | `{"student_code": "1705221201", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 18 | 1705220002 | DHCTTCK17A1 | Biện Văn Tài | 30/04/2002 | vantai@gmail.com | `{"student_code": "1705220002", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 19 | 1705220533 | DHCTTCK17A1 | Trương Văn Quang | 04/08/2004 | vanquang@gmail.com | `{"student_code": "1705220533", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 20 | 1705220535 | DHCTTCK17A1 | Hà Đình Đạt | 08/10/2004 | dinhdat@gmail.com | `{"student_code": "1705220535", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 21 | 1705220454 | DHCTTCK17A1 | Lê Văn Thắng | 03/08/2004 | vanthang@gmail.com | `{"student_code": "1705220454", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 22 | 1705220441 | DHCTTCK17A1 | Trần Văn Nhật | 21/10/2004 | vannhat@gmail.com | `{"student_code": "1705220441", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 23 | 1705221190 | DHCTTCK17A1 | PHETSALAT Emmy | 01/01/2003 | phetsalatemmy@gmail.com | `{"student_code": "1705221190", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 24 | 1705221079 | DHCTTCK17A1 | Phạm Trung Kiên | 18/03/2004 | trungkien@gmail.com | `{"student_code": "1705221079", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 25 | 1705221087 | DHCTTCK17A1 | Lương Trường Phi | 27/07/2002 | truongphi@gmail.com | `{"student_code": "1705221087", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 26 | 1705220081 | DHCTTCK17A1 | Lương Thê Hy | 07/02/2004 | thehy@gmail.com | `{"student_code": "1705220081", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 27 | 1705221191 | DHCTTCK17A1 | KHANTIVONG Bounthavy | 24/01/2004 | khantivongbounthavy@gmail.com | `{"student_code": "1705221191", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 28 | 1705221085 | DHCTTCK17A1 | Lô Nhất Linh | 12/04/2002 | nhatlinh@gmail.com | `{"student_code": "1705221085", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 29 | 1705220531 | DHCTTCK17A1 | Hồ Viết Giáp | 25/04/2004 | vietgiap@gmail.com | `{"student_code": "1705220531", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 30 | 1705220220 | DHCTTCK17A1 | Nguyễn Ngọc Thiện | 10/11/2004 | ngocthien@gmail.com | `{"student_code": "1705220220", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 31 | 1705220785 | DHCTTCK17A1 | Mai Huy Quý | 20/07/2003 | huyquy@gmail.com | `{"student_code": "1705220785", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 32 | 1705220240 | DHCTTCK17A1 | Nguyễn Phúc Tấn Minh | 27/10/2004 | tanminh@gmail.com | `{"student_code": "1705220240", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 33 | 1705220961 | DHCTTCK17A1 | Nguyễn Minh Huy | 10/10/2004 | minhhuy@gmail.com | `{"student_code": "1705220961", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 34 | 1705220446 | DHCTTCK17A1 | Hồ Văn Công Sách | 14/02/2004 | congsach@gmail.com | `{"student_code": "1705220446", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 35 | 1705220034 | DHCTTCK17A1 | Nguyễn Công Đoàn | 24/07/2001 | congdoan@gmail.com | `{"student_code": "1705220034", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 36 | 1705221187 | DHCTTCK17A1 | KHOUNNOLATH Anouphap | 30/05/2004 | khounnolathanouphap@gmail.com | `{"student_code": "1705221187", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 37 | 1705220112 | DHCTTCK17A1 | Hồ Hữu Hoạt | 01/06/2004 | huuhoat@gmail.com | `{"student_code": "1705220112", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 38 | 1705220042 | DHCTTCK17A1 | Trương Văn Sang | 02/06/2003 | vansang@gmail.com | `{"student_code": "1705220042", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 39 | 1705220236 | DHCTTCK17A1 | Nguyễn Văn Hoàng | 14/04/2004 | vanhoang@gmail.com | `{"student_code": "1705220236", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 40 | 1705221109 | DHCTTCK17A1 | Nguyễn Viết Trung | 18/02/2003 | viettrung@gmail.com | `{"student_code": "1705221109", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 41 | 1705220529 | DHCTTCK17A1 | Bùi Đình Lộc | 30/08/2004 | dinhloc@gmail.com | `{"student_code": "1705220529", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 42 | 1705220449 | DHCTTCK17A1 | Đào Bình Phước | 26/04/2004 | binhphuoc@gmail.com | `{"student_code": "1705220449", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 43 | 1705221189 | DHCTTCK17A1 | CHANTHATHEB Poumsavanh | 10/10/2003 | chanthathebpoumsavanh@gmail.com | `{"student_code": "1705221189", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 44 | 1705220789 | DHCTTCK17A1 | Hồ Phi Quân | 25/11/2004 | phiquan@gmail.com | `{"student_code": "1705220789", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 45 | 1705220174 | DHCTTCK17A1 | Lê Vinh Kiên | 11/03/2004 | vinhkien@gmail.com | `{"student_code": "1705220174", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 46 | 1705220453 | DHCTTCK17A1 | Trịnh Tuấn Kiệt | 28/08/2004 | tuankiet@gmail.com | `{"student_code": "1705220453", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 47 | 1705220223 | DHCTTCK17A1 | Nguyễn Sỹ Quang Huy | 19/10/2004 | quanghuy@gmail.com | `{"student_code": "1705220223", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 48 | 1705220099 | DHCTTCK17A1 | Nguyễn Trung Kiên | 10/02/2004 | trungkien1@gmail.com | `{"student_code": "1705220099", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 49 | 1705221192 | DHCTTCK17A1 | THAMMAVONGSA Thotsaphone | 14/11/2003 | thammavongsathotsaphone@gmail.com | `{"student_code": "1705221192", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 50 | 1705220455 | DHCTTCK17A1 | Nguyễn Trọng Quân | 01/11/2004 | trongquan@gmail.com | `{"student_code": "1705220455", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 51 | 1705220182 | DHCTTCK17A1 | Võ Thành Đạt | 06/08/2004 | thanhdat@gmail.com | `{"student_code": "1705220182", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 52 | 1705220001 | DHCTTCK17A1 | Trần Văn An | 24/11/2002 | vanan@gmail.com | `{"student_code": "1705220001", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 53 | 1705220466 | DHCTTCK17A1 | Vũ Duy Quân | 03/03/2004 | duyquan@gmail.com | `{"student_code": "1705220466", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 54 | 1705220123 | DHCTTCK17A1 | Phạm Huy Hoàng | (không có) | huyhoang@gmail.com | `{"student_code": "1705220123", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 55 | 1705220243 | DHCTTCK17A1 | Lê Văn Anh Thế | (không có) | anhthe@gmail.com | `{"student_code": "1705220243", "enrollment_class": "DHCTTCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |

---

## DHCTTCK17A2 — 90 sinh viên (từ danh-sach-cung-svk17a2.md)

| STT | Mã SV | Lớp nhập học | Họ và tên | Ngày sinh | Email | Metadata (JSON) |
|---|---|---|---|---|---|---|
| 1 | 1705221201 | DHCTTCK17A2 | XAMONTY Angoun | 14/03/2003 | xamontyangoun1@gmail.com | `{"student_code": "1705221201", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 2 | 1705220492 | DHCTTCK17A2 | Nguyễn Tuấn Anh | 20/02/2004 | tuananh@gmail.com | `{"student_code": "1705220492", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 3 | 1705221187 | DHCTTCK17A2 | KHOUNNOLATH Anouphap | 30/05/2004 | khounnolathanouphap1@gmail.com | `{"student_code": "1705221187", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 4 | 1705220928 | DHCTTCK17A2 | Cao Võ Thái Bảo | 11/08/2004 | thaibao@gmail.com | `{"student_code": "1705220928", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 5 | 1705220543 | DHCTTCK17A2 | Nguyễn Công Thái Bảo | 14/07/2004 | thaibao1@gmail.com | `{"student_code": "1705220543", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 6 | 1705221191 | DHCTTCK17A2 | KHANTIVONG Bounthavy | 24/01/2004 | khantivongbounthavy1@gmail.com | `{"student_code": "1705221191", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 7 | 1705221180 | DHCTTCK17A2 | LOUANGSITTHIDETH Chemin | 22/04/2000 | louangsitthidethchemin@gmail.com | `{"student_code": "1705221180", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 8 | 1705220957 | DHCTTCK17A2 | Trần Huy Chiến | 10/10/2004 | huychien@gmail.com | `{"student_code": "1705220957", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 9 | 1705221168 | DHCTTCK17A2 | Võ Văn Chính | 01/08/2004 | vanchinh@gmail.com | `{"student_code": "1705221168", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 10 | 1705220487 | DHCTTCK17A2 | Nguyễn Đình Công | 15/08/2004 | dinhcong@gmail.com | `{"student_code": "1705220487", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 11 | 1705220991 | DHCTTCK17A2 | Nguyễn Thế Diệu | 16/06/2004 | thedieu@gmail.com | `{"student_code": "1705220991", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 12 | 1705220925 | DHCTTCK17A2 | Nguyễn Tiến Dũng | 09/10/2004 | tiendung@gmail.com | `{"student_code": "1705220925", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 13 | 1705220981 | DHCTTCK17A2 | Phan Đức Dũng | 30/07/2004 | ducdung@gmail.com | `{"student_code": "1705220981", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 14 | 1705220778 | DHCTTCK17A2 | Võ Lâm Dũng | 02/02/2004 | lamdung@gmail.com | `{"student_code": "1705220778", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 15 | 1705220550 | DHCTTCK17A2 | Lê Vũ Duy | 17/02/2004 | vuduy@gmail.com | `{"student_code": "1705220550", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 16 | 1705220999 | DHCTTCK17A2 | Nguyễn Đình Đạt | 06/11/2004 | dinhdat1@gmail.com | `{"student_code": "1705220999", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 17 | 1705220940 | DHCTTCK17A2 | Phạm Quốc Đạt | 02/08/2004 | quocdat@gmail.com | `{"student_code": "1705220940", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 18 | 1705221042 | DHCTTCK17A2 | Trương Quang Đạt | 17/09/2004 | quangdat@gmail.com | `{"student_code": "1705221042", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 19 | 1705221148 | DHCTTCK17A2 | Trần Hải Đăng | 26/08/2004 | haidang@gmail.com | `{"student_code": "1705221148", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 20 | 1705221068 | DHCTTCK17A2 | Nguyễn Văn Đô | 16/02/2004 | vando@gmail.com | `{"student_code": "1705221068", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 21 | 1705220712 | DHCTTCK17A2 | Lê Hữu Đức | 11/01/2003 | huuduc@gmail.com | `{"student_code": "1705220712", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 22 | 1705220975 | DHCTTCK17A2 | Lê Văn Đức | 17/06/2004 | vanduc@gmail.com | `{"student_code": "1705220975", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 23 | 1705220534 | DHCTTCK17A2 | Nguyễn Hữu Đức | 26/07/2004 | huuduc1@gmail.com | `{"student_code": "1705220534", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 24 | 1705220848 | DHCTTCK17A2 | Nguyễn Minh Đức | 26/10/2004 | minhduc@gmail.com | `{"student_code": "1705220848", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 25 | 1705220444 | DHCTTCK17A2 | Nguyễn Tuấn Đức | 12/01/2004 | tuanduc@gmail.com | `{"student_code": "1705220444", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 26 | 1705220987 | DHCTTCK17A2 | Trịnh Minh Đức | 22/06/2004 | minhduc1@gmail.com | `{"student_code": "1705220987", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 27 | 1705221190 | DHCTTCK17A2 | PHETSALAT Emmy | 01/01/2003 | phetsalatemmy1@gmail.com | `{"student_code": "1705221190", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 28 | 1705220959 | DHCTTCK17A2 | Hoàng Xuân Hiếu | 31/05/2004 | xuanhieu@gmail.com | `{"student_code": "1705220959", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 29 | 1705220856 | DHCTTCK17A2 | Hồ Sỹ Hiếu | 28/08/2004 | syhieu@gmail.com | `{"student_code": "1705220856", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 30 | 1705221077 | DHCTTCK17A2 | Phan Thị Hoài | 08/03/2004 | thihoai@gmail.com | `{"student_code": "1705221077", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 31 | 1705220960 | DHCTTCK17A2 | Cao Việt Hoàng | 16/04/2004 | viethoang@gmail.com | `{"student_code": "1705220960", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 32 | 1705220714 | DHCTTCK17A2 | Lê Bảo Hoàng | 22/07/2003 | baohoang@gmail.com | `{"student_code": "1705220714", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 33 | 1705221045 | DHCTTCK17A2 | Trần Huy Hoàng | 14/05/2004 | huyhoang1@gmail.com | `{"student_code": "1705221045", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 34 | 1705220926 | DHCTTCK17A2 | Hồ Văn Hùng | 04/06/2004 | vanhung@gmail.com | `{"student_code": "1705220926", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 35 | 1705220475 | DHCTTCK17A2 | Vi Khánh Hùng | 18/12/2004 | khanhhung@gmail.com | `{"student_code": "1705220475", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 36 | 1705220855 | DHCTTCK17A2 | Nguyễn Quang Huy | 06/10/2004 | quanghuy1@gmail.com | `{"student_code": "1705220855", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 37 | 1705220927 | DHCTTCK17A2 | Phạm Đức Huy | 08/09/2004 | duchuy@gmail.com | `{"student_code": "1705220927", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 38 | 1705221184 | DHCTTCK17A2 | SOMPHONHEUANG Jackkie | 22/09/2003 | somphonheuangjackkie@gmail.com | `{"student_code": "1705221184", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 39 | 1705221183 | DHCTTCK17A2 | XAYYASITH Keopaserd | 08/02/2003 | xayyasithkeopaserd@gmail.com | `{"student_code": "1705221183", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 40 | 1705220974 | DHCTTCK17A2 | Nguyễn Đăng Kiên | 23/04/2004 | dangkien@gmail.com | `{"student_code": "1705220974", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 41 | 1705220186 | DHCTTCK17A2 | Lê Xuân Lâm | 02/01/2003 | xuanlam@gmail.com | `{"student_code": "1705220186", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 42 | 1705220553 | DHCTTCK17A2 | Bùi Quang Linh | 01/09/2004 | quanglinh@gmail.com | `{"student_code": "1705220553", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 43 | 1705220547 | DHCTTCK17A2 | Đinh Lê Quyền Linh | 30/11/2004 | quyenlinh@gmail.com | `{"student_code": "1705220547", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 44 | 1705221030 | DHCTTCK17A2 | Dương Tiểu Long | 12/09/2004 | tieulong@gmail.com | `{"student_code": "1705221030", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 45 | 1705220642 | DHCTTCK17A2 | Nguyễn Đăng Lực | 26/03/2004 | dangluc@gmail.com | `{"student_code": "1705220642", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 46 | 1705220929 | DHCTTCK17A2 | Trần Đức Lương | 12/12/2004 | ducluong@gmail.com | `{"student_code": "1705220929", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 47 | 1705220924 | DHCTTCK17A2 | Trần Văn Mạnh | 28/02/2003 | vanmanh@gmail.com | `{"student_code": "1705220924", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 48 | 1705221070 | DHCTTCK17A2 | Nguyễn Tài Nguyên | 04/07/2004 | tainguyen@gmail.com | `{"student_code": "1705221070", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 49 | 1705220503 | DHCTTCK17A2 | Nguyễn Trọng Nhật | 30/01/2004 | trongnhat@gmail.com | `{"student_code": "1705220503", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 50 | 1705220985 | DHCTTCK17A2 | Võ Đình Phát | 17/11/2004 | dinhphat@gmail.com | `{"student_code": "1705220985", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 51 | 1705220472 | DHCTTCK17A2 | Lê Văn Tấn Phong | 05/10/2004 | tanphong@gmail.com | `{"student_code": "1705220472", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 52 | 1705221021 | DHCTTCK17A2 | Trần Quang Phúc | 11/10/2004 | quangphuc@gmail.com | `{"student_code": "1705221021", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 53 | 1705221189 | DHCTTCK17A2 | CHANTHATHEB Poumsavanh | 10/10/2003 | chanthathebpoumsavanh1@gmail.com | `{"student_code": "1705221189", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 54 | 1705220936 | DHCTTCK17A2 | Đặng Huỳnh Quang | 13/08/2004 | huynhquang@gmail.com | `{"student_code": "1705220936", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 55 | 1705221007 | DHCTTCK17A2 | Lê Hồng Quang | 28/02/2004 | hongquang@gmail.com | `{"student_code": "1705221007", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 56 | 1705220539 | DHCTTCK17A2 | Cao Minh Quân | 16/10/2004 | minhquan@gmail.com | `{"student_code": "1705220539", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 57 | 1705221014 | DHCTTCK17A2 | Hoàng Văn Quân | 20/09/2004 | vanquan@gmail.com | `{"student_code": "1705221014", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 58 | 1705220782 | DHCTTCK17A2 | Hồ Minh Quân | 05/01/2004 | minhquan1@gmail.com | `{"student_code": "1705220782", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 59 | 1705221162 | DHCTTCK17A2 | Lê Anh Quân | 23/04/2004 | anhquan1@gmail.com | `{"student_code": "1705221162", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 60 | 1705221067 | DHCTTCK17A2 | Nguyễn Anh Quân | 03/08/2004 | anhquan2@gmail.com | `{"student_code": "1705221067", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 61 | 1705220160 | DHCTTCK17A2 | Nguyễn Hồng Quân | 10/04/2004 | hongquan@gmail.com | `{"student_code": "1705220160", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 62 | 1705220690 | DHCTTCK17A2 | Nguyễn Hữu Quân | 07/08/2004 | huuquan@gmail.com | `{"student_code": "1705220690", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 63 | 1705220983 | DHCTTCK17A2 | Nguyễn Quốc Quân | 22/03/2003 | quocquan@gmail.com | `{"student_code": "1705220983", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 64 | 1705220933 | DHCTTCK17A2 | Phan Tiến Quân | 20/12/2004 | tienquan@gmail.com | `{"student_code": "1705220933", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 65 | 1705221094 | DHCTTCK17A2 | Trương Anh Quân | 24/06/2004 | anhquan3@gmail.com | `{"student_code": "1705221094", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 66 | 1705221096 | DHCTTCK17A2 | Nguyễn Trọng Quốc | 25/05/2003 | trongquoc@gmail.com | `{"student_code": "1705221096", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 67 | 1705221099 | DHCTTCK17A2 | Nguyễn Viết Quỳnh | 15/09/2004 | vietquynh@gmail.com | `{"student_code": "1705221099", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 68 | 1705221029 | DHCTTCK17A2 | Trần Văn Sang | 23/09/2004 | vansang1@gmail.com | `{"student_code": "1705221029", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 69 | 1705221188 | DHCTTCK17A2 | KHOTPHOUTHONE Soulima | 18/04/2004 | khotphouthonesoulima1@gmail.com | `{"student_code": "1705221188", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 70 | 1705221185 | DHCTTCK17A2 | CHIASOUATONGKHA Southida | 06/10/2003 | chiasouatongkhasouthida@gmail.com | `{"student_code": "1705221185", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 71 | 1705221095 | DHCTTCK17A2 | Nguyễn Văn Tài | 18/01/2004 | vantai1@gmail.com | `{"student_code": "1705221095", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 72 | 1705220992 | DHCTTCK17A2 | Phùng Quốc Thành | 07/05/2004 | quocthanh@gmail.com | `{"student_code": "1705220992", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 73 | 1705220885 | DHCTTCK17A2 | Lê Xuân Thao | 25/09/2004 | xuanthao@gmail.com | `{"student_code": "1705220885", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 74 | 1705220982 | DHCTTCK17A2 | Hoàng Văn Thắng | 07/11/2004 | vanthang1@gmail.com | `{"student_code": "1705220982", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 75 | 1705220949 | DHCTTCK17A2 | Trần Văn Thắng | 12/10/2003 | vanthang2@gmail.com | `{"student_code": "1705220949", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 76 | 1705221155 | DHCTTCK17A2 | Ngô Đức Thịnh | 21/04/2002 | ducthinh@gmail.com | `{"student_code": "1705221155", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 77 | 1705221181 | DHCTTCK17A2 | LUANGPHITHAK Thipkesone | 05/07/2003 | luangphithakthipkesone@gmail.com | `{"student_code": "1705221181", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 78 | 1705221192 | DHCTTCK17A2 | THAMMAVONGSA Thotsaphone | 14/11/2003 | thammavongsathotsaphone1@gmail.com | `{"student_code": "1705221192", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 79 | 1705220495 | DHCTTCK17A2 | Nguyễn Trọng Thông | 28/04/2004 | trongthong@gmail.com | `{"student_code": "1705220495", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 80 | 1705221151 | DHCTTCK17A2 | Trần Văn Thủy | 06/12/2004 | vanthuy@gmail.com | `{"student_code": "1705221151", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 81 | 1705220986 | DHCTTCK17A2 | Hàn Mạnh Tiến | 18/01/2004 | manhtien@gmail.com | `{"student_code": "1705220986", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 82 | 1705220771 | DHCTTCK17A2 | Thịnh Quang Trung | 31/12/2003 | quangtrung@gmail.com | `{"student_code": "1705220771", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 83 | 1705220930 | DHCTTCK17A2 | Nguyễn Văn Trường | 30/06/2004 | vantruong@gmail.com | `{"student_code": "1705220930", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 84 | 1705220931 | DHCTTCK17A2 | Nguyễn Xuân Trường | 26/06/2004 | xuantruong@gmail.com | `{"student_code": "1705220931", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 85 | 1705221065 | DHCTTCK17A2 | Nguyễn Minh Tuấn | 28/05/2004 | minhtuan@gmail.com | `{"student_code": "1705221065", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 86 | 1705220932 | DHCTTCK17A2 | Nguyễn Doãn Uy | 15/11/2004 | doanuy@gmail.com | `{"student_code": "1705220932", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 87 | 1705220845 | DHCTTCK17A2 | Lê Viết Việt | 03/12/2004 | vietviet@gmail.com | `{"student_code": "1705220845", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 88 | 1705221182 | DHCTTCK17A2 | CHANTHAVVONG Vilaphon | 04/05/2003 | chanthavvongvilaphon@gmail.com | `{"student_code": "1705221182", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 89 | 1705221186 | DHCTTCK17A2 | LENGTUAPOR Xengva | 15/11/2003 | lengtuaporxengva@gmail.com | `{"student_code": "1705221186", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 90 | 1705221179 | DHCTTCK17A2 | VUECHAYER Yingyu | 25/01/2004 | vuechayeryingyu@gmail.com | `{"student_code": "1705221179", "enrollment_class": "DHCTTCK17A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |

---

## DHCTTCK18A1 — (từ so-taymmt-k18a1.md)

| STT | Mã SV | Lớp nhập học | Họ và tên | Email | Metadata (JSON) |
|---|---|---|---|---|---|
| 1 | 1805230284 | DHCTTCK18A1 | Bùi Đức Anh | ducanh@gmail.com | `{"student_code": "1805230284", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 2 | 1805231064 | DHCTTCK18A1 | Vi Tú Anh | tuanh@gmail.com | `{"student_code": "1805231064", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 3 | 1805230364 | DHCTTCK18A1 | Vũ Thị Quỳnh Anh | quynhanh@gmail.com | `{"student_code": "1805230364", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 4 | 1805230288 | DHCTTCK18A1 | Nguyễn Đình Cường | dinhcuong@gmail.com | `{"student_code": "1805230288", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 5 | 1805230319 | DHCTTCK18A1 | Trần Thùy Dung | thuydung@gmail.com | `{"student_code": "1805230319", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 6 | 1805230282 | DHCTTCK18A1 | Nguyễn Đình Đạt | dinhdat2@gmail.com | `{"student_code": "1805230282", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 7 | 1805230276 | DHCTTCK18A1 | Nguyễn Văn Anh Đức | anhduc@gmail.com | `{"student_code": "1805230276", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 8 | 1805230300 | DHCTTCK18A1 | Nguyễn Thọ Hoàng | thohoang@gmail.com | `{"student_code": "1805230300", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 9 | 1805230270 | DHCTTCK18A1 | Trần Vũ Hoàng | vuhoang@gmail.com | `{"student_code": "1805230270", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 10 | 1805230302 | DHCTTCK18A1 | Lê Đắc Huy | dachuy@gmail.com | `{"student_code": "1805230302", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 11 | 1805230304 | DHCTTCK18A1 | Lê Thị Khánh Huyền | khanhhuyen@gmail.com | `{"student_code": "1805230304", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 12 | 1805230309 | DHCTTCK18A1 | Nguyễn Quốc Khánh | quockhanh@gmail.com | `{"student_code": "1805230309", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 13 | 1805230311 | DHCTTCK18A1 | Nguyễn Gia Khiêm | giakhiem@gmail.com | `{"student_code": "1805230311", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 14 | 1805231126 | DHCTTCK18A1 | Nguyễn Thành Long | thanhlong@gmail.com | `{"student_code": "1805231126", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 15 | 1805230271 | DHCTTCK18A1 | Đặng Hữu Nguyên | huunguyen@gmail.com | `{"student_code": "1805230271", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 16 | 1805230269 | DHCTTCK18A1 | Lê Văn Nhật | vannhat1@gmail.com | `{"student_code": "1805230269", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 17 | 1805230298 | DHCTTCK18A1 | Nguyễn Nhuận Quang | nhuanquang@gmail.com | `{"student_code": "1805230298", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 18 | 1805230294 | DHCTTCK18A1 | Thái Ánh Sáng | anhsang@gmail.com | `{"student_code": "1805230294", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 19 | 1805230289 | DHCTTCK18A1 | Nguyễn Công Ngọc Sơn | ngocson@gmail.com | `{"student_code": "1805230289", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 20 | 1805230268 | DHCTTCK18A1 | Đặng Văn Tài | vantai2@gmail.com | `{"student_code": "1805230268", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 21 | 1805230283 | DHCTTCK18A1 | Nguyễn Đức Tài | ductai@gmail.com | `{"student_code": "1805230283", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 22 | 1805230846 | DHCTTCK18A1 | Hoàng Thanh Tâm | thanhtam@gmail.com | `{"student_code": "1805230846", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 23 | 1805230536 | DHCTTCK18A1 | Nguyễn Đình Võ Toàn | votoan@gmail.com | `{"student_code": "1805230536", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 24 | 1805230318 | DHCTTCK18A1 | Lê Văn Trọng | vantrong@gmail.com | `{"student_code": "1805230318", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 25 | 1805230967 | DHCTTCK18A1 | Đặng Văn Trưởng | vantruong1@gmail.com | `{"student_code": "1805230967", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 26 | 1805230337 | DHCTTCK18A1 | Nguyễn Hoàng Việt | hoangviet@gmail.com | `{"student_code": "1805230337", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 27 | 1805230275 | DHCTTCK18A1 | Nguyễn Văn Ngọc | vanngoc@gmail.com | `{"student_code": "1805230275", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 28 | 1805230320 | DHCTTCK18A1 | Nguyễn Đình Nhân | dinhnhan@gmail.com | `{"student_code": "1805230320", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 29 | 1805230290 | DHCTTCK18A1 | Cao Hồng Quân | hongquan1@gmail.com | `{"student_code": "1805230290", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 30 | 1805230363 | DHCTTCK18A1 | Trịnh Anh Quân | anhquan4@gmail.com | `{"student_code": "1805230363", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 31 | 1805230307 | DHCTTCK18A1 | Lê Quốc Đạt | quocdat1@gmail.com | `{"student_code": "1805230307", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 32 | 1805230306 | DHCTTCK18A1 | Trần Tuấn Đạt | tuandat@gmail.com | `{"student_code": "1805230306", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 33 | 1805230308 | DHCTTCK18A1 | Vũ Đình Thể | dinhthe@gmail.com | `{"student_code": "1805230308", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 34 | 1805230313 | DHCTTCK18A1 | Nguyễn Bỉnh Huy | binhhuy@gmail.com | `{"student_code": "1805230313", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 35 | 1805230009 | DHCTTCK18A1 | Nguyễn Đình Thắng | dinhthang@gmail.com | `{"student_code": "1805230009", "enrollment_class": "DHCTTCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |

---

## DHCTTCK18A2 — (từ so-tay.md + so-tay-1.md)

| STT | Mã SV | Lớp nhập học | Họ và tên | Email | Metadata (JSON) |
|---|---|---|---|---|---|
| 1 | 1805230841 | DHCTTCK18A2 | Lê Văn Minh Chiến | minhchien@gmail.com | `{"student_code": "1805230841", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 2 | 1805230422 | DHCTTCK18A2 | Nguyễn Văn Chương | vanchuong@gmail.com | `{"student_code": "1805230422", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 3 | 1805230366 | DHCTTCK18A2 | Nguyễn Quốc Cường | quoccuong@gmail.com | `{"student_code": "1805230366", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 4 | 1805230661 | DHCTTCK18A2 | Nguyễn Doãn Thế Dũng | thedung@gmail.com | `{"student_code": "1805230661", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 5 | 1805230668 | DHCTTCK18A2 | Hà Văn Đại | vandai@gmail.com | `{"student_code": "1805230668", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 6 | 1805230853 | DHCTTCK18A2 | Trương Thành Đạt | thanhdat1@gmail.com | `{"student_code": "1805230853", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 7 | 1805230840 | DHCTTCK18A2 | Phan Văn Hoàng | vanhoang1@gmail.com | `{"student_code": "1805230840", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 8 | 1805231019 | DHCTTCK18A2 | Bùi Quốc Tuấn Hưng | tuanhung@gmail.com | `{"student_code": "1805231019", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 9 | 1805230807 | DHCTTCK18A2 | Nguyễn Văn Quốc Kiên | quockien@gmail.com | `{"student_code": "1805230807", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 10 | 1805230390 | DHCTTCK18A2 | Nguyễn Hồng Quân | hongquan2@gmail.com | `{"student_code": "1805230390", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 11 | 1805230400 | DHCTTCK18A2 | Nguyễn Việt Quốc | vietquoc@gmail.com | `{"student_code": "1805230400", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 12 | 1805230928 | DHCTTCK18A2 | Moong Văn Sơn | vanson@gmail.com | `{"student_code": "1805230928", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 13 | 1805230864 | DHCTTCK18A2 | Nguyễn Duy Thức | duythuc@gmail.com | `{"student_code": "1805230864", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 14 | 1805230652 | DHCTTCK18A2 | Lê Huy Toàn | huytoan@gmail.com | `{"student_code": "1805230652", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 15 | 1805231135 | DHCTTCK18A2 | Vongvichitdee Athiza | vongvichitdeeathiza@gmail.com | `{"student_code": "1805231135", "enrollment_class": "DHCTTCK18A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |

---

## DHCTTCK19A1 — (từ so-tay-mmt-k19a1.md + so-tay-th-ptud-1.md + so-tay-th-sql-02.md)

| STT | Mã SV | Lớp nhập học | Họ và tên | Email | Metadata (JSON) |
|---|---|---|---|---|---|
| 1 | 1905240483 | DHCTTCK19A1 | Bùi Đình Anh | dinhanh@gmail.com | `{"student_code": "1905240483", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 2 | 1905240413 | DHCTTCK19A1 | Hồ Bá Anh | baanh@gmail.com | `{"student_code": "1905240413", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 3 | 1905240166 | DHCTTCK19A1 | Trần Xuân Ân | xuanan@gmail.com | `{"student_code": "1905240166", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 4 | 1905241146 | DHCTTCK19A1 | Thái Thị Thu Hằng | thuhang@gmail.com | `{"student_code": "1905241146", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 5 | 1905240258 | DHCTTCK19A1 | Phan Thái Hiệu | thaihieu@gmail.com | `{"student_code": "1905240258", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 6 | 1905240815 | DHCTTCK19A1 | Đinh Lê Hoàng | lehoang@gmail.com | `{"student_code": "1905240815", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 7 | 1905240406 | DHCTTCK19A1 | Nguyễn Huy Hoàng | huyhoang2@gmail.com | `{"student_code": "1905240406", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 8 | 1905241057 | DHCTTCK19A1 | Võ Huy Hoàng | huyhoang3@gmail.com | `{"student_code": "1905241057", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 9 | 1905241172 | DHCTTCK19A1 | Hồ Trung Kiên | trungkien2@gmail.com | `{"student_code": "1905241172", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 10 | 1905240113 | DHCTTCK19A1 | Nguyễn Quang Hưng | quanghung@gmail.com | `{"student_code": "1905240113", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 11 | 1905240376 | DHCTTCK19A1 | Phạm Văn Lâu | vanlau@gmail.com | `{"student_code": "1905240376", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 12 | 1905241156 | DHCTTCK19A1 | Hồ Sĩ Lộc | siloc@gmail.com | `{"student_code": "1905241156", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 13 | 1905240088 | DHCTTCK19A1 | Lê Văn Mạnh | vanmanh1@gmail.com | `{"student_code": "1905240088", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 14 | 1905240053 | DHCTTCK19A1 | Bùi Quang Minh | quangminh@gmail.com | `{"student_code": "1905240053", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 15 | 1905240599 | DHCTTCK19A1 | Nguyễn Đậu Nguyên | daunguyen@gmail.com | `{"student_code": "1905240599", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 16 | 1905240019 | DHCTTCK19A1 | Nguyễn Thanh Ngần | thanhngan@gmail.com | `{"student_code": "1905240019", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 17 | 1905240608 | DHCTTCK19A1 | Bùi Duy Quân | duyquan1@gmail.com | `{"student_code": "1905240608", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 18 | 1905240043 | DHCTTCK19A1 | Văn Đình Quyền | dinhquyen@gmail.com | `{"student_code": "1905240043", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 19 | 1905240600 | DHCTTCK19A1 | Hồ Minh Quyết | minhquyet@gmail.com | `{"student_code": "1905240600", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 20 | 1905241139 | DHCTTCK19A1 | Hoàng Thế Tài | thetai@gmail.com | `{"student_code": "1905241139", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 21 | 1905240172 | DHCTTCK19A1 | Trương Công Thành | congthanh@gmail.com | `{"student_code": "1905240172", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 22 | 1905240279 | DHCTTCK19A1 | Nguyễn Đăng Thiện | dangthien@gmail.com | `{"student_code": "1905240279", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 23 | 1905240062 | DHCTTCK19A1 | Nguyễn Trường Vũ | truongvu@gmail.com | `{"student_code": "1905240062", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 24 | 1905240326 | DHCTTCK19A1 | Lê Văn Đại | vandai1@gmail.com | `{"student_code": "1905240326", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 25 | 1905240443 | DHCTTCK19A1 | Trần Văn Hòa | vanhoa@gmail.com | `{"student_code": "1905240443", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 26 | 1905241330 | DHCTTCK19A1 | Nguyễn Hữu Ngọc | huungoc@gmail.com | `{"student_code": "1905241330", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 27 | 1905240467 | DHCTTCK19A1 | Trần Thị Quỳnh Như | quynhnhu@gmail.com | `{"student_code": "1905240467", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 28 | 1905240098 | DHCTTCK19A1 | Võ Hồng Quân | hongquan3@gmail.com | `{"student_code": "1905240098", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 29 | 1905241129 | DHCTTCK19A1 | Đậu Đức Toàn | ductoan@gmail.com | `{"student_code": "1905241129", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 30 | 1905240475 | DHCTTCK19A1 | Nguyễn Trọng Toàn | trongtoan@gmail.com | `{"student_code": "1905240475", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 31 | 1905240521 | DHCTTCK19A1 | Lê Xuân Hải Dương | haiduong@gmail.com | `{"student_code": "1905240521", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 32 | 1905241288 | DHCTTCK19A1 | Phan Nguyễn Tiến Đạt | tiendat@gmail.com | `{"student_code": "1905241288", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 33 | 1905240470 | DHCTTCK19A1 | Lê Hữu Huân | huuhuan@gmail.com | `{"student_code": "1905240470", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 34 | 1905240743 | DHCTTCK19A1 | Lê Văn Quang | vanquang1@gmail.com | `{"student_code": "1905240743", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 35 | 1905240328 | DHCTTCK19A1 | Nguyễn Đặng Anh Tài | anhtai@gmail.com | `{"student_code": "1905240328", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 36 | 1905241254 | DHCTTCK19A1 | Trần Chí Thành | chithanh@gmail.com | `{"student_code": "1905241254", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 37 | 1905241129 | DHCTTCK19A1 | Đậu Đức Toàn | ductoan1@gmail.com | `{"student_code": "1905241129", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 38 | 1905240639 | DHCTTCK19A1 | Đinh Hải Siêu | haisieu@gmail.com | `{"student_code": "1905240639", "enrollment_class": "DHCTTCK19A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |

---

## DHCTTCK19A2 — (từ so-tay-mmt-k19a2.md + so-tay-th-ptud-1.md + so-tay-th-sql)

| STT | Mã SV | Lớp nhập học | Họ và tên | Email | Metadata (JSON) |
|---|---|---|---|---|---|
| 1 | 1905240838 | DHCTTCK19A2 | Nguyễn Trần Thành An | thanhan@gmail.com | `{"student_code": "1905240838", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 2 | 1905240923 | DHCTTCK19A2 | Hồ Đức An | ducan@gmail.com | `{"student_code": "1905240923", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 3 | 1905240580 | DHCTTCK19A2 | Hồ Đức Minh Anh | minhanh@gmail.com | `{"student_code": "1905240580", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 4 | 1905241075 | DHCTTCK19A2 | Nguyễn Đức Tuấn Anh | tuananh1@gmail.com | `{"student_code": "1905241075", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 5 | 1905240890 | DHCTTCK19A2 | Nguyễn Việt Anh | vietanh@gmail.com | `{"student_code": "1905240890", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 6 | 1905241296 | DHCTTCK19A2 | Dương Công Quốc Anh | quocanh@gmail.com | `{"student_code": "1905241296", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 7 | 1905241349 | DHCTTCK19A2 | CHANTHILARD Chilaxard | chanthilardchilaxard@gmail.com | `{"student_code": "1905241349", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 8 | 1905240144 | DHCTTCK19A2 | Lương Võ Thế Công | thecong@gmail.com | `{"student_code": "1905240144", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 9 | 1905241018 | DHCTTCK19A2 | Trần Quốc Đạt | quocdat2@gmail.com | `{"student_code": "1905241018", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 10 | 1905241120 | DHCTTCK19A2 | Cự Bá Đồng | badong@gmail.com | `{"student_code": "1905241120", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 11 | 1905240867 | DHCTTCK19A2 | Nguyễn Xuân Giáp | xuangiap@gmail.com | `{"student_code": "1905240867", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 12 | 1905240914 | DHCTTCK19A2 | Nguyễn Văn Hiền | vanhien@gmail.com | `{"student_code": "1905240914", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 13 | 1905240229 | DHCTTCK19A2 | Lê Đức Hoàng | duchoang@gmail.com | `{"student_code": "1905240229", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 14 | 1905240728 | DHCTTCK19A2 | Trần Quang Huy | quanghuy2@gmail.com | `{"student_code": "1905240728", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 15 | 1905241313 | DHCTTCK19A2 | Trần Đình Huy | dinhhuy@gmail.com | `{"student_code": "1905241313", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 16 | 1905240576 | DHCTTCK19A2 | Thái Huy Gia Hưng | giahung@gmail.com | `{"student_code": "1905240576", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 17 | 1905240924 | DHCTTCK19A2 | Vi Quang Khải | quangkhai@gmail.com | `{"student_code": "1905240924", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 18 | 1905241341 | DHCTTCK19A2 | PHENGPHOMKONG Konevisit | phengphomkongkonevisit@gmail.com | `{"student_code": "1905241341", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 19 | 1905240845 | DHCTTCK19A2 | Lê Quang Linh | quanglinh1@gmail.com | `{"student_code": "1905240845", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 20 | 1905241338 | DHCTTCK19A2 | SISOUVONG Malisa | sisouvongmalisa@gmail.com | `{"student_code": "1905241338", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 21 | 1905240418 | DHCTTCK19A2 | Phạm Bru Nây | brunay@gmail.com | `{"student_code": "1905240418", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 22 | 1905240377 | DHCTTCK19A2 | Lê Văn Nguyên | vannguyen@gmail.com | `{"student_code": "1905240377", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 23 | 1905241340 | DHCTTCK19A2 | LOUANGLAXA Oudavanh | louanglaxaoudavanh@gmail.com | `{"student_code": "1905241340", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 24 | 1905240202 | DHCTTCK19A2 | Đào Duy Phúc | duyphuc@gmail.com | `{"student_code": "1905240202", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 25 | 1905240020 | DHCTTCK19A2 | Nguyễn Hữu Hoàng Phúc | hoangphuc@gmail.com | `{"student_code": "1905240020", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 26 | 1905241049 | DHCTTCK19A2 | Nguyễn Văn Quyến | vanquyen@gmail.com | `{"student_code": "1905241049", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 27 | 1905241350 | DHCTTCK19A2 | THAMPHAVONG SOMMAY | thamphavongsommay@gmail.com | `{"student_code": "1905241350", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 28 | 1905241344 | DHCTTCK19A2 | THIENGCHANHOME Thanongsak | thiengchanhomethanongsak@gmail.com | `{"student_code": "1905241344", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 29 | 1905240942 | DHCTTCK19A2 | Phạm Huy Thắng | huythang@gmail.com | `{"student_code": "1905240942", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 30 | 1905241221 | DHCTTCK19A2 | Trần Văn Thuấn | vanthuan@gmail.com | `{"student_code": "1905241221", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 31 | 1905240362 | DHCTTCK19A2 | Nguyễn Văn Tiến | vantien@gmail.com | `{"student_code": "1905240362", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 32 | 1905241286 | DHCTTCK19A2 | Lữ Thị Kiên Trang | kientrang@gmail.com | `{"student_code": "1905241286", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 33 | 1905240896 | DHCTTCK19A2 | Lê Sỹ Tú | sytu@gmail.com | `{"student_code": "1905240896", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 34 | 1905241126 | DHCTTCK19A2 | Trần Lang Anh Tuấn | anhtuan@gmail.com | `{"student_code": "1905241126", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 35 | 1905240581 | DHCTTCK19A2 | Vũ Cát Tường | cattuong@gmail.com | `{"student_code": "1905240581", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 36 | 1905241352 | DHCTTCK19A2 | Lê Nguyễn Thiên Vũ | thienvu@gmail.com | `{"student_code": "1905241352", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 37 | 1905241351 | DHCTTCK19A2 | Lê Nguyên Vũ | nguyenvu@gmail.com | `{"student_code": "1905241351", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 38 | 1905240504 | DHCTTCK19A2 | Nguyễn Thiên Vương | thienvuong@gmail.com | `{"student_code": "1905240504", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 39 | 1905241347 | DHCTTCK19A2 | ANOTHAY Xaybandith | anothayxaybandith@gmail.com | `{"student_code": "1905241347", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 40 | 1905241339 | DHCTTCK19A2 | SOULIVONG Anon | soulivonganon@gmail.com | `{"student_code": "1905241339", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 41 | 1905240443 | DHCTTCK19A2 | Trần Văn Hòa | vanhoa1@gmail.com | `{"student_code": "1905240443", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |

---

## DHCTTCK20A1 — (từ so-tay-co-so-lt-web-k20a1.md)

| STT | Mã SV | Lớp nhập học | Họ và tên | Email | Metadata (JSON) |
|---|---|---|---|---|---|
| 1 | 2005251589 | DHCTTCK20A1 | Đặng Bảo Anh | baoanh@gmail.com | `{"student_code": "2005251589", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 2 | 2005251217 | DHCTTCK20A1 | Nguyễn Đình Bảo | dinhbao@gmail.com | `{"student_code": "2005251217", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 3 | 2005250370 | DHCTTCK20A1 | Nguyễn Lê Đức Bảo | ducbao@gmail.com | `{"student_code": "2005250370", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 4 | 2005250435 | DHCTTCK20A1 | Lê Đình Dũng | dinhdung@gmail.com | `{"student_code": "2005250435", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 5 | 2005250033 | DHCTTCK20A1 | Trần Đức Dũng | ducdung1@gmail.com | `{"student_code": "2005250033", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 6 | 2005250073 | DHCTTCK20A1 | Trương Văn Duy | vanduy@gmail.com | `{"student_code": "2005250073", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 7 | 2005250420 | DHCTTCK20A1 | Nguyễn Viết Đạt | vietdat@gmail.com | `{"student_code": "2005250420", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 8 | 2005250285 | DHCTTCK20A1 | Trần Văn Đạt | vandat@gmail.com | `{"student_code": "2005250285", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 9 | 2005251172 | DHCTTCK20A1 | Trương Tấn Đạt | tandat@gmail.com | `{"student_code": "2005251172", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 10 | 2005250859 | DHCTTCK20A1 | Trần Hữu Đoàn | huudoan@gmail.com | `{"student_code": "2005250859", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 11 | 2005251131 | DHCTTCK20A1 | Trần Trung Đức | trungduc@gmail.com | `{"student_code": "2005251131", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 12 | 2005250436 | DHCTTCK20A1 | Đồng Nguyên Hiếu | nguyenhieu@gmail.com | `{"student_code": "2005250436", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 13 | 2005251349 | DHCTTCK20A1 | Lê Trọng Hùng | tronghung@gmail.com | `{"student_code": "2005251349", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 14 | 2005250496 | DHCTTCK20A1 | Ngô Kim Huy | kimhuy@gmail.com | `{"student_code": "2005250496", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 15 | 2005250038 | DHCTTCK20A1 | Hồ Đình Huyên | dinhhuyen@gmail.com | `{"student_code": "2005250038", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 16 | 2005250928 | DHCTTCK20A1 | Đặng Doãn Huy Lâm | huylam@gmail.com | `{"student_code": "2005250928", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 17 | 2005250369 | DHCTTCK20A1 | Phan Thị Hoàng Linh | hoanglinh@gmail.com | `{"student_code": "2005250369", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 18 | 2005250451 | DHCTTCK20A1 | Nguyễn Tiến Mại | tienmai@gmail.com | `{"student_code": "2005250451", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 19 | 2005251042 | DHCTTCK20A1 | Võ Duy Nam | duynam@gmail.com | `{"student_code": "2005251042", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 20 | 2005251450 | DHCTTCK20A1 | Thái Bá Nghĩa | banghia@gmail.com | `{"student_code": "2005251450", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 21 | 2005251441 | DHCTTCK20A1 | Nguyễn Khoa Ngọc | khoangoc@gmail.com | `{"student_code": "2005251441", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 22 | 2005250162 | DHCTTCK20A1 | Nguyễn Mậu Nhật Nguyên | nhatnguyen@gmail.com | `{"student_code": "2005250162", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 23 | 2005250973 | DHCTTCK20A1 | Cao Đình Nhật | dinhnhat@gmail.com | `{"student_code": "2005250973", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 24 | 2005250625 | DHCTTCK20A1 | Đoàn Anh Nhật | anhnhat@gmail.com | `{"student_code": "2005250625", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 25 | 2005251289 | DHCTTCK20A1 | Trần Văn Niệm | vanniem@gmail.com | `{"student_code": "2005251289", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 26 | 2005251146 | DHCTTCK20A1 | Hồ Ngọc Phát | ngocphat@gmail.com | `{"student_code": "2005251146", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 27 | 2005250402 | DHCTTCK20A1 | Nguyễn Văn Phát | vanphat@gmail.com | `{"student_code": "2005250402", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 28 | 2005250100 | DHCTTCK20A1 | Nguyễn Ngọc Minh Phương | minhphuong@gmail.com | `{"student_code": "2005250100", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 29 | 2005251245 | DHCTTCK20A1 | Lê Anh Quân | anhquan5@gmail.com | `{"student_code": "2005251245", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 30 | 2005250022 | DHCTTCK20A1 | Nguyễn Hồng Quân | hongquan4@gmail.com | `{"student_code": "2005250022", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 31 | 2005250143 | DHCTTCK20A1 | Trương Đức Quân | ducquan@gmail.com | `{"student_code": "2005250143", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 32 | 2005251220 | DHCTTCK20A1 | Nguyễn Công Sáng | congsang@gmail.com | `{"student_code": "2005251220", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 33 | 2005250953 | DHCTTCK20A1 | Đặng Minh Sơn | minhson@gmail.com | `{"student_code": "2005250953", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 34 | 2005251153 | DHCTTCK20A1 | Hoàng Châu Sơn | chauson@gmail.com | `{"student_code": "2005251153", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 35 | 2005250113 | DHCTTCK20A1 | Trần Khắc Sơn | khacson@gmail.com | `{"student_code": "2005250113", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 36 | 2005250747 | DHCTTCK20A1 | Nguyễn Nguyên Chí Tài | chitai@gmail.com | `{"student_code": "2005250747", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 37 | 2005251205 | DHCTTCK20A1 | Nguyễn Anh Thái | anhthai@gmail.com | `{"student_code": "2005251205", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 38 | 2005250626 | DHCTTCK20A1 | Trần Văn Thành | vanthanh@gmail.com | `{"student_code": "2005250626", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 39 | 2005250581 | DHCTTCK20A1 | Trịnh Thị Thúy | thithuy@gmail.com | `{"student_code": "2005250581", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 40 | 2005250023 | DHCTTCK20A1 | Nguyễn Đình Tuệ | dinhtue@gmail.com | `{"student_code": "2005250023", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 41 | 2005250411 | DHCTTCK20A1 | Nguyễn Văn Xuân Tùng | xuantung@gmail.com | `{"student_code": "2005250411", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 42 | 2005250691 | DHCTTCK20A1 | Đặng Thế Anh Vũ | anhvu@gmail.com | `{"student_code": "2005250691", "enrollment_class": "DHCTTCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 43 | 2005251744 | DHCTTCK20A2 | Singhaduangpunya Panya | singhaduangpunyapanya@gmail.com | `{"student_code": "2005251744", "enrollment_class": "DHCTTCK20A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 44 | 2005251745 | DHCTTCK20A2 | Vongvilay Sinnaphat | vongvilaysinnaphat@gmail.com | `{"student_code": "2005251745", "enrollment_class": "DHCTTCK20A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |

---

## DHDTVCK20A1 — 61 sinh viên (từ so-tay-tcb-chinh-thuc.md)

| STT | Mã SV | Lớp nhập học | Họ và tên | Email | Metadata (JSON) |
|---|---|---|---|---|---|
| 1 | 2005250191 | DHDTVCK20A1 | Lê Việt Anh | vietanh1@gmail.com | `{"student_code": "2005250191", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 2 | 2005250449 | DHDTVCK20A1 | Bùi Gia Bảo | giabao@gmail.com | `{"student_code": "2005250449", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 3 | 2005251456 | DHDTVCK20A1 | Lê Văn Bắc | vanbac@gmail.com | `{"student_code": "2005251456", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 4 | 2005251534 | DHDTVCK20A1 | Hoàng Văn Bổn | vanbon@gmail.com | `{"student_code": "2005251534", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 5 | 2005251469 | DHDTVCK20A1 | Phạm Ngọc Sinh Cung | sinhcung@gmail.com | `{"student_code": "2005251469", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 6 | 2005251602 | DHDTVCK20A1 | Cao Cường | caocuong@gmail.com | `{"student_code": "2005251602", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 7 | 2005251089 | DHDTVCK20A1 | Lê Doãn Cường | doancuong@gmail.com | `{"student_code": "2005251089", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 8 | 2005251142 | DHDTVCK20A1 | Lê Hồng Duy | hongduy@gmail.com | `{"student_code": "2005251142", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 9 | 2005250926 | DHDTVCK20A1 | Trần Văn Duy | vanduy1@gmail.com | `{"student_code": "2005250926", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 10 | 2005251227 | DHDTVCK20A1 | Nguyễn Hải Dương | haiduong1@gmail.com | `{"student_code": "2005251227", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 11 | 2005251033 | DHDTVCK20A1 | Hồ Hữu Khánh Đăng | khanhdang@gmail.com | `{"student_code": "2005251033", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 12 | 2005251327 | DHDTVCK20A1 | Nguyễn Quân Đô | quando@gmail.com | `{"student_code": "2005251327", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 13 | 2005251034 | DHDTVCK20A1 | Lê Quang Đông | quangdong@gmail.com | `{"student_code": "2005251034", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 14 | 2005251685 | DHDTVCK20A1 | Lê Anh Đức | anhduc1@gmail.com | `{"student_code": "2005251685", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 15 | 2005251651 | DHDTVCK20A1 | Nguyễn Văn Đức | vanduc1@gmail.com | `{"student_code": "2005251651", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 16 | 2005251317 | DHDTVCK20A1 | Phan Cao Anh Đức | anhduc2@gmail.com | `{"student_code": "2005251317", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 17 | 2005250753 | DHDTVCK20A1 | Phan Văn Đức | vanduc2@gmail.com | `{"student_code": "2005250753", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 18 | 2005251455 | DHDTVCK20A1 | Lê Quang Hiếu | quanghieu@gmail.com | `{"student_code": "2005251455", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 19 | 2005250733 | DHDTVCK20A1 | Bạch Thị Hoài | thihoai1@gmail.com | `{"student_code": "2005250733", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 20 | 2005251082 | DHDTVCK20A1 | Phan Văn Hoàng | vanhoang2@gmail.com | `{"student_code": "2005251082", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 21 | 2005250351 | DHDTVCK20A1 | Trần Văn Hoàng | vanhoang3@gmail.com | `{"student_code": "2005250351", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 22 | 2005251522 | DHDTVCK20A1 | Hoàng Trọng Hùng | tronghung1@gmail.com | `{"student_code": "2005251522", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 23 | 2005251440 | DHDTVCK20A1 | Cao Xuân Huy | xuanhuy@gmail.com | `{"student_code": "2005251440", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 24 | 2005250977 | DHDTVCK20A1 | Quách Đức Huy | duchuy1@gmail.com | `{"student_code": "2005250977", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 25 | 2005250417 | DHDTVCK20A1 | Văn Minh Huy | minhhuy1@gmail.com | `{"student_code": "2005250417", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 26 | 2005251437 | DHDTVCK20A1 | Trần Bảo Khanh | baokhanh@gmail.com | `{"student_code": "2005251437", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 27 | 2005251563 | DHDTVCK20A1 | Bùi Duy Khánh | duykhanh@gmail.com | `{"student_code": "2005251563", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 28 | 2005251570 | DHDTVCK20A1 | Phạm Trung Kiên | trungkien3@gmail.com | `{"student_code": "2005251570", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 29 | 2005250477 | DHDTVCK20A1 | Hồ Anh Kiệt | anhkiet@gmail.com | `{"student_code": "2005250477", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 30 | 2005251197 | DHDTVCK20A1 | Nguyễn Chỉ Linh | chilinh@gmail.com | `{"student_code": "2005251197", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 31 | 2005251075 | DHDTVCK20A1 | Đặng Đình Lưu | dinhluu@gmail.com | `{"student_code": "2005251075", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 32 | 2005251372 | DHDTVCK20A1 | Lê Quang Mạnh | quangmanh@gmail.com | `{"student_code": "2005251372", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 33 | 2005250566 | DHDTVCK20A1 | Nguyễn Đức Mạnh | ducmanh@gmail.com | `{"student_code": "2005250566", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 34 | 2005251684 | DHDTVCK20A1 | Trần Tiến Mạnh | tienmanh@gmail.com | `{"student_code": "2005251684", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 35 | 2005251465 | DHDTVCK20A1 | Vũ Xuân Mạnh | xuanmanh@gmail.com | `{"student_code": "2005251465", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 36 | 2005251240 | DHDTVCK20A1 | Hồ Cường Nam | cuongnam@gmail.com | `{"student_code": "2005251240", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 37 | 2005251256 | DHDTVCK20A1 | Nguyễn Xuân Nam | xuannam@gmail.com | `{"student_code": "2005251256", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 38 | 2005251701 | DHDTVCK20A1 | Nguyễn Thị Ngà | thinga@gmail.com | `{"student_code": "2005251701", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 39 | 2005251216 | DHDTVCK20A1 | Đặng Đình Nghĩa | dinhnghia@gmail.com | `{"student_code": "2005251216", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 40 | 2005250961 | DHDTVCK20A1 | Hoàng Thục Ngôn | thucngon@gmail.com | `{"student_code": "2005250961", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 41 | 2005251335 | DHDTVCK20A1 | Nguyễn Đình Nhân | dinhnhan1@gmail.com | `{"student_code": "2005251335", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 42 | 2005251431 | DHDTVCK20A1 | Đậu Xuân Nhật | xuannhat@gmail.com | `{"student_code": "2005251431", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 43 | 2005250111 | DHDTVCK20A1 | Nguyễn Xuân Phát | xuanphat@gmail.com | `{"student_code": "2005250111", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 44 | 2005250864 | DHDTVCK20A1 | Nguyễn Hữu Phúc | huuphuc@gmail.com | `{"student_code": "2005250864", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 45 | 2005251237 | DHDTVCK20A1 | Vũ Anh Quân | anhquan6@gmail.com | `{"student_code": "2005251237", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 46 | 2005251451 | DHDTVCK20A1 | Hồ Trọng Quyền | trongquyen@gmail.com | `{"student_code": "2005251451", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 47 | 2005251457 | DHDTVCK20A1 | Hoàng Thế Sơn | theson@gmail.com | `{"student_code": "2005251457", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 48 | 2005251379 | DHDTVCK20A1 | Nguyễn Hữu Thái | huuthai@gmail.com | `{"student_code": "2005251379", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 49 | 2005251388 | DHDTVCK20A1 | Lưu Đức Thiện | ducthien@gmail.com | `{"student_code": "2005251388", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 50 | 2005250963 | DHDTVCK20A1 | Nguyễn Công Thiện | congthien@gmail.com | `{"student_code": "2005250963", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 51 | 2005251079 | DHDTVCK20A1 | Nguyễn Cảnh Thịnh | canhthinh@gmail.com | `{"student_code": "2005251079", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 52 | 2005251462 | DHDTVCK20A1 | Hoàng Văn Thưởng | vanthuong@gmail.com | `{"student_code": "2005251462", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 53 | 2005250781 | DHDTVCK20A1 | Cao Mạnh Tiến | manhtien1@gmail.com | `{"student_code": "2005250781", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 54 | 2005251300 | DHDTVCK20A1 | Trần Viết Tiến | viettien@gmail.com | `{"student_code": "2005251300", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 55 | 2005251275 | DHDTVCK20A1 | Võ Viết Trung | viettrung1@gmail.com | `{"student_code": "2005251275", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 56 | 2005251397 | DHDTVCK20A1 | Nguyễn Văn Trường | vantruong2@gmail.com | `{"student_code": "2005251397", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 57 | 2005250772 | DHDTVCK20A1 | Hồ Minh Tuấn | minhtuan1@gmail.com | `{"student_code": "2005250772", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 58 | 2005251006 | DHDTVCK20A1 | Nguyễn Lâm Tuấn | lamtuan@gmail.com | `{"student_code": "2005251006", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 59 | 2005251385 | DHDTVCK20A1 | Hồ Đức Việt | ducviet@gmail.com | `{"student_code": "2005251385", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 60 | 2005250668 | DHDTVCK20A1 | Hồ Quốc Việt | quocviet@gmail.com | `{"student_code": "2005250668", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 61 | 2005251196 | DHDTVCK20A1 | Lê Khánh Việt | khanhviet@gmail.com | `{"student_code": "2005251196", "enrollment_class": "DHDTVCK20A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |

---

## DHOTOCK20A5 đến A9 — (từ thcb-08.md, GV Lê Thị Linh)

| STT | Mã SV | Lớp nhập học | Họ và tên | Email | Metadata (JSON) |
|---|---|---|---|---|---|
| 1 | 2005250847 | DHOTOCK20A6 | Trần Hoàng Anh | hoanganh@gmail.com | `{"student_code": "2005250847", "enrollment_class": "DHOTOCK20A6", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 2 | 2005250117 | DHOTOCK20A6 | Trần Văn Bách | vanbach@gmail.com | `{"student_code": "2005250117", "enrollment_class": "DHOTOCK20A6", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 3 | 2005250352 | DHOTOCK20A8 | Đặng Xuân Bảng | xuanbang@gmail.com | `{"student_code": "2005250352", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 4 | 2005250679 | DHOTOCK20A9 | Dương Bùi Thái Bình | thaibinh@gmail.com | `{"student_code": "2005250679", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 5 | 2005251025 | DHOTOCK20A9 | Nguyễn Trọng Cung | trongcung@gmail.com | `{"student_code": "2005251025", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 6 | 2005250699 | DHOTOCK20A8 | Lê Trọng Cường | trongcuong@gmail.com | `{"student_code": "2005250699", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 7 | 2005250399 | DHOTOCK20A8 | Nguyễn Anh Dũng | anhdung@gmail.com | `{"student_code": "2005250399", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 8 | 2005251092 | DHOTOCK20A6 | Nguyễn Minh Dũng | minhdung@gmail.com | `{"student_code": "2005251092", "enrollment_class": "DHOTOCK20A6", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 9 | 2005250984 | DHOTOCK20A9 | Trần Viết Dũng | vietdung@gmail.com | `{"student_code": "2005250984", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 10 | 2005250529 | DHOTOCK20A8 | Bùi Văn Duy | vanduy2@gmail.com | `{"student_code": "2005250529", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 11 | 2005250048 | DHOTOCK20A9 | Hoàng Đăng Duy | dangduy@gmail.com | `{"student_code": "2005250048", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 12 | 2005250884 | DHOTOCK20A6 | Hồ Quốc Duy | quocduy@gmail.com | `{"student_code": "2005250884", "enrollment_class": "DHOTOCK20A6", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 13 | 2005250627 | DHOTOCK20A9 | Lê Văn Duy | vanduy3@gmail.com | `{"student_code": "2005250627", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 14 | 2005250339 | DHOTOCK20A9 | Phạm Như Duy | nhuduy@gmail.com | `{"student_code": "2005250339", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 15 | 2005250386 | DHOTOCK20A9 | Đinh Thành Đạt | thanhdat2@gmail.com | `{"student_code": "2005250386", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 16 | 2005251418 | DHOTOCK20A9 | Nguyễn Trần Thành Đạt | thanhdat3@gmail.com | `{"student_code": "2005251418", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 17 | 2005250238 | DHOTOCK20A9 | Cao Việt Đức | vietduc@gmail.com | `{"student_code": "2005250238", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 18 | 2005250479 | DHOTOCK20A9 | Nguyễn Đình Đức | dinhduc@gmail.com | `{"student_code": "2005250479", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 19 | 2005251159 | DHOTOCK20A8 | Nguyễn Trung Đức | trungduc1@gmail.com | `{"student_code": "2005251159", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 20 | 2005250446 | DHOTOCK20A9 | Phạm Nhật Đức | nhatduc@gmail.com | `{"student_code": "2005250446", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 21 | 2005250825 | DHOTOCK20A8 | Đoàn Văn Giang | vangiang@gmail.com | `{"student_code": "2005250825", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 22 | 2005250867 | DHOTOCK20A9 | Trương Hoàng Hải | hoanghai@gmail.com | `{"student_code": "2005250867", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 23 | 2005251145 | DHOTOCK20A6 | Nguyễn Chỉ Ánh Hào | anhhao@gmail.com | `{"student_code": "2005251145", "enrollment_class": "DHOTOCK20A6", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 24 | 2005250878 | DHOTOCK20A9 | Đặng Đình Hiếu | dinhhieu@gmail.com | `{"student_code": "2005250878", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 25 | 2005250178 | DHOTOCK20A9 | Lê Đức Hiếu | duchieu@gmail.com | `{"student_code": "2005250178", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 26 | 2005250685 | DHOTOCK20A9 | Lê Trung Hiếu | trunghieu@gmail.com | `{"student_code": "2005250685", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 27 | 2005250967 | DHOTOCK20A9 | Phan Minh Hiếu | minhhieu@gmail.com | `{"student_code": "2005250967", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 28 | 2005251069 | DHOTOCK20A8 | Nguyễn Trọng Hiệu | tronghieu@gmail.com | `{"student_code": "2005251069", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 29 | 2005250936 | DHOTOCK20A8 | Nguyễn Ngọc Hoàn | ngochoan@gmail.com | `{"student_code": "2005250936", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 30 | 2005250087 | DHOTOCK20A8 | Nguyễn Hữu Hùng | huuhung@gmail.com | `{"student_code": "2005250087", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 31 | 2005251492 | DHOTOCK20A5 | Nguyễn Quốc Hùng | quochung@gmail.com | `{"student_code": "2005251492", "enrollment_class": "DHOTOCK20A5", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 32 | 2005250663 | DHOTOCK20A8 | Nguyễn Đăng Huy | danghuy@gmail.com | `{"student_code": "2005250663", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 33 | 2005251010 | DHOTOCK20A9 | Bùi Văn Khang | vankhang@gmail.com | `{"student_code": "2005251010", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 34 | 2005250658 | DHOTOCK20A9 | Phạm Viết Khang | vietkhang@gmail.com | `{"student_code": "2005250658", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 35 | 2005250512 | DHOTOCK20A9 | Bùi Nam Khánh | namkhanh@gmail.com | `{"student_code": "2005250512", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 36 | 2005250662 | DHOTOCK20A8 | Đậu Quốc Mạnh | quocmanh@gmail.com | `{"student_code": "2005250662", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 37 | 2005250651 | DHOTOCK20A8 | Trần Văn Mạnh | vanmanh2@gmail.com | `{"student_code": "2005250651", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 38 | 2005250042 | DHOTOCK20A9 | Vi Đức Mạnh | ducmanh1@gmail.com | `{"student_code": "2005250042", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 39 | 2005250522 | DHOTOCK20A8 | Mạnh Lộc Phú Nguyên | phunguyen@gmail.com | `{"student_code": "2005250522", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 40 | 2005251729 | DHOTOCK20A8 | Nguyễn Đình Nhân | dinhnhan2@gmail.com | `{"student_code": "2005251729", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 41 | 2005251037 | DHOTOCK20A9 | Bùi Hải Nhật | hainhat@gmail.com | `{"student_code": "2005251037", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 42 | 2005251076 | DHOTOCK20A7 | Trần Văn Phong | vanphong@gmail.com | `{"student_code": "2005251076", "enrollment_class": "DHOTOCK20A7", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 43 | 2005250630 | DHOTOCK20A8 | Trần Xuân Phong | xuanphong@gmail.com | `{"student_code": "2005250630", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 44 | 2005250606 | DHOTOCK20A8 | Phạm Hoàng Quân | hoangquan@gmail.com | `{"student_code": "2005250606", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 45 | 2005250576 | DHOTOCK20A8 | Trần Việt Quân | vietquan@gmail.com | `{"student_code": "2005250576", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 46 | 2005250816 | DHOTOCK20A8 | Trần Văn Quốc | vanquoc@gmail.com | `{"student_code": "2005250816", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 47 | 2005250193 | DHOTOCK20A8 | Nguyễn Đình Sơn | dinhson@gmail.com | `{"student_code": "2005250193", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 48 | 2005251015 | DHOTOCK20A8 | Nguyễn Đình Sơn (2) | son2@gmail.com | `{"student_code": "2005251015", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 49 | 2005250110 | DHOTOCK20A9 | Nguyễn Đức Thắng | ducthang@gmail.com | `{"student_code": "2005250110", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 50 | 2005250844 | DHOTOCK20A8 | Trần Sĩ Minh Thắng | minhthang@gmail.com | `{"student_code": "2005250844", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 51 | 2005250942 | DHOTOCK20A6 | Nguyễn Văn Thuận | vanthuan1@gmail.com | `{"student_code": "2005250942", "enrollment_class": "DHOTOCK20A6", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 52 | 2005251247 | DHOTOCK20A8 | Nguyễn Lê Đông Tiến | dongtien@gmail.com | `{"student_code": "2005251247", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 53 | 2005250383 | DHOTOCK20A8 | Nguyễn Xuân Tiến | xuantien@gmail.com | `{"student_code": "2005250383", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 54 | 2005250943 | DHOTOCK20A6 | Phan Công Tiến | congtien@gmail.com | `{"student_code": "2005250943", "enrollment_class": "DHOTOCK20A6", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 55 | 2005250348 | DHOTOCK20A8 | Phạm Ngọc Tú | ngoctu@gmail.com | `{"student_code": "2005250348", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 56 | 2005250538 | DHOTOCK20A9 | Đậu Đình Ước | dinhuoc@gmail.com | `{"student_code": "2005250538", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 57 | 2005250713 | DHOTOCK20A9 | Vũ Đình Việt | dinhviet@gmail.com | `{"student_code": "2005250713", "enrollment_class": "DHOTOCK20A9", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 58 | 2005250613 | DHOTOCK20A8 | Lương Minh Vũ | minhvu@gmail.com | `{"student_code": "2005250613", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 59 | 2005251449 | DHOTOCK20A8 | Lê Ngọc Vỹ | ngocvy@gmail.com | `{"student_code": "2005251449", "enrollment_class": "DHOTOCK20A8", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |

---

## Sinh viên các lớp khác (lẻ tẻ từ các sổ tay)

| STT | Mã SV | Lớp nhập học | Họ và tên | Nguồn | Email | Metadata (JSON) |
|---|---|---|---|---|---|---|
| 1 | 1505200664 | DHCTTCK15A2 | Trần Việt Tùng | so-tay.md | viettung@gmail.com | `{"student_code": "1505200664", "enrollment_class": "DHCTTCK15A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 2 | 1505201214 | DHCTTCK15A2 | Hoàng Sỹ Nhân | so-tay-mmt-k19a1.md | synhan@gmail.com | `{"student_code": "1505201214", "enrollment_class": "DHCTTCK15A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 3 | 1605211364 | DHKTMCK16A1 | Nguyễn Tùng Dương | so-taymmt-k18a1.md | tungduong@gmail.com | `{"student_code": "1605211364", "enrollment_class": "DHKTMCK16A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 4 | 1605211328 | DHCTTCK16A2 | Hồ Văn Hải | so-tay-th-sql-03.md | vanhai@gmail.com | `{"student_code": "1605211328", "enrollment_class": "DHCTTCK16A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 5 | 1605211412 | DHCTTCK16A2 | Nguyễn Văn Nam | so-tay-th-sql-03.md | vannam@gmail.com | `{"student_code": "1605211412", "enrollment_class": "DHCTTCK16A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 6 | 1605230050 | DHCTTLK16Z | Nguyễn Như Minh Nhật | so-tay-th-sql-02.md | minhnhat@gmail.com | `{"student_code": "1605230050", "enrollment_class": "DHCTTLK16Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 7 | 1805250021 | DHCTTLK18Z | Trần Đức Dũng | so-tay-mmt-k19a1.md | ducdung2@gmail.com | `{"student_code": "1805250021", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 8 | 1805250054 | DHCTTLK18Z | Nguyễn Trung Hiếu | thcb-08.md | trunghieu1@gmail.com | `{"student_code": "1805250054", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 9 | 1805250033 | DHCTTLK18Z | Hồ Thị Hòa | so-tay-th-ptud-1.md | thihoa@gmail.com | `{"student_code": "1805250033", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 10 | 1805250057 | DHCTTLK18Z | Nguyễn Vĩnh Khiêm | so-tay-th-ptud-1.md | vinhkhiem@gmail.com | `{"student_code": "1805250057", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 11 | 1805250076 | DHCTTLK18Z | Đoàn Thanh Quang | so-tay-th-ptud-1.md | thanhquang@gmail.com | `{"student_code": "1805250076", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 12 | 1805250077 | DHCTTLK18Z | Dương Nguyễn Hoàng Quân | so-tay-th-sql-03.md | hoangquan1@gmail.com | `{"student_code": "1805250077", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 13 | 1805250131 | DHCTTLK18Z | Nguyễn Minh Đức | so-tay-co-so-lt-web.md | minhduc2@gmail.com | `{"student_code": "1805250131", "enrollment_class": "DHCTTLK18Z", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 14 | 1805250901 | DHKTMCK18A1 | Trần Ngọc Anh | so-tay-mmt-k19a1.md | ngocanh@gmail.com | `{"student_code": "1805250901", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 15 | 1805230328 | DHKTMCK18A1 | Lăng Trọng Huy | so-tay-mmt-k19a1.md | tronghuy@gmail.com | `{"student_code": "1805230328", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 16 | 1805230568 | DHKTMCK18A1 | Nguyễn Văn Kiên | so-tay-mmt-k19a1.md | vankien@gmail.com | `{"student_code": "1805230568", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 17 | 1805230411 | DHKTMCK18A1 | Cao Xuân Quang | so-tay-mmt-k19a1.md | xuanquang@gmail.com | `{"student_code": "1805230411", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 18 | 1805230279 | DHKTMCK18A1 | Đặng Văn Tài | so-tay-mmt-k19a1.md | vantai3@gmail.com | `{"student_code": "1805230279", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 19 | 1805230692 | DHKTMCK18A1 | Vương Viết Trường | so-tay-mmt-k19a1.md | viettruong@gmail.com | `{"student_code": "1805230692", "enrollment_class": "DHKTMCK18A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 20 | 1905241313 | DHCTTCK19A2 | Trần Đình Huy | so-tay-mmt-k19a1.md | dinhhuy1@gmail.com | `{"student_code": "1905241313", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 21 | 1905241339 | DHCTTCK19A2 | SOULIVONG Anon | so-tay-mmt-k19a1.md | soulivonganon1@gmail.com | `{"student_code": "1905241339", "enrollment_class": "DHCTTCK19A2", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 22 | 1705220020 | DHKTMCK17A1 | PHIMMATHAT Akkaxay | so-taymmt-k18a1.md | phimmathatakkaxay@gmail.com | `{"student_code": "1705220020", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 23 | 1705221071 | DHKTMCK17A1 | Ngô Công Tuấn Anh | so-taymmt-k18a1.md | tuananh2@gmail.com | `{"student_code": "1705221071", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 24 | 1705220021 | DHKTMCK17A1 | INTHAVONG Chanthaphone | so-taymmt-k18a1.md | inthavongchanthaphone@gmail.com | `{"student_code": "1705220021", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 25 | 1705220440 | DHKTMCK17A1 | Hồ Tùng Dương | so-taymmt-k18a1.md | tungduong1@gmail.com | `{"student_code": "1705220440", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 26 | 1705220950 | DHKTMCK17A1 | Nguyễn Thành Đạt | so-taymmt-k18a1.md | thanhdat4@gmail.com | `{"student_code": "1705220950", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 27 | 1705220056 | DHKTMCK17A1 | Hồ Văn Võ Đồng | so-taymmt-k18a1.md | vodong@gmail.com | `{"student_code": "1705220056", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 28 | 1705220537 | DHKTMCK17A1 | Trần Xuân Đức | so-taymmt-k18a1.md | xuanduc@gmail.com | `{"student_code": "1705220537", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 29 | 1705220526 | DHKTMCK17A1 | Nguyễn Văn Huy | so-taymmt-k18a1.md | vanhuy@gmail.com | `{"student_code": "1705220526", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 30 | 1705220439 | DHKTMCK17A1 | Nguyễn Đăng Khánh | so-taymmt-k18a1.md | dangkhanh@gmail.com | `{"student_code": "1705220439", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 31 | 1705221006 | DHKTMCK17A1 | Lê Văn Nam | so-taymmt-k18a1.md | vannam1@gmail.com | `{"student_code": "1705221006", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 32 | 1705220022 | DHKTMCK17A1 | VANNAVONG Phoneseng | so-taymmt-k18a1.md | vannavongphoneseng@gmail.com | `{"student_code": "1705220022", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 33 | 1705220023 | DHKTMCK17A1 | ITTHAVONG Sisawat | so-taymmt-k18a1.md | itthavongsisawat@gmail.com | `{"student_code": "1705220023", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 34 | 1705220024 | DHKTMCK17A1 | PAPHATSALANG Soukpaseuth | so-taymmt-k18a1.md | paphatsalangsoukpaseuth@gmail.com | `{"student_code": "1705220024", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 35 | 1705220491 | DHKTMCK17A1 | Đậu Cao Thêm | so-taymmt-k18a1.md | caothem@gmail.com | `{"student_code": "1705220491", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
| 36 | 1705220784 | DHKTMCK17A1 | Hoàng Trung Thu | so-taymmt-k18a1.md | trungthu@gmail.com | `{"student_code": "1705220784", "enrollment_class": "DHKTMCK17A1", "school_name": "Trường Đại học Sư phạm Kỹ thuật Vinh"}` |
