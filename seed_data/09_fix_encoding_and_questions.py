"""
Fix script for seed data issues:
1. Fix Vietnamese encoding (broken UTF-8) in assignments table
2. Create proper questions + question_choices for all 12 new assignments
3. Update assignment_questions with correct question_id + custom_content

The SQL output is written directly as a .sql file and must be piped to
`docker exec` with proper UTF-8 encoding.
"""
import json
import uuid

TEACHER_ID = '51e467a2-9033-5e85-b666-164ea075f6c9'

# ======================================================================
# Assignment data (same as original, for re-insert with correct encoding)
# ======================================================================
ASSIGNMENTS = [
    # (index, assignment_uuid, title, description)
    (1, 'dd000100-0000-4a00-a000-000000000001',
     'Kiểm tra chương 1: Tổng quan mô hình OSI',
     'Kiểm tra kiến thức về 7 tầng mô hình OSI, chức năng từng tầng và các giao thức liên quan.'),
    (2, 'dd000200-0000-4a00-a000-000000000001',
     'Bài tập chương 2: Giao thức TCP và UDP',
     'Phân biệt TCP/UDP, phân tích header, three-way handshake, flow control.'),
    (3, 'dd000300-0000-4a00-a000-000000000001',
     'Kiểm tra giữa kỳ: Địa chỉ IP và Subnetting',
     'Tính toán CIDR, chia subnet, xác định network/broadcast address, VLSM.'),
    (4, 'dd000400-0000-4a00-a000-000000000001',
     'Bài tập thực hành: Cấu hình VLAN và Routing cơ bản',
     'Cấu hình VLAN trên switch, inter-VLAN routing, static routing, NAT cơ bản.'),
    (5, 'dd000500-0000-4a00-a000-000000000001',
     'Lab 1: Ngôn ngữ DDL và Ràng buộc toàn vẹn',
     'CREATE TABLE, ALTER TABLE, ràng buộc PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, DEFAULT.'),
    (6, 'dd000600-0000-4a00-a000-000000000001',
     'Lab 2: Truy vấn SELECT, JOIN và Hàm Aggregate',
     'INNER/LEFT/RIGHT/FULL JOIN, GROUP BY, HAVING, COUNT, SUM, AVG, subquery.'),
    (7, 'dd000700-0000-4a00-a000-000000000001',
     'Kiểm tra giữa kỳ thực hành SQL Server',
     'Tổng hợp DDL, DML, truy vấn phức tạp, stored procedure cơ bản, transaction.'),
    (8, 'dd000800-0000-4a00-a000-000000000001',
     'Bài tập HTML/CSS cơ bản',
     'Cấu trúc HTML5 semantic, CSS selectors, Flexbox layout, Box model.'),
    (9, 'dd000900-0000-4a00-a000-000000000001',
     'Bài tập JavaScript và DOM manipulation',
     'Biến, hàm, event handling, querySelector, createElement, form validation.'),
    (10, 'dd000a00-0000-4a00-a000-000000000001',
     'Kiểm tra giữa kỳ: Lập trình Web tổng hợp',
     'HTML/CSS/JS tổng hợp, Responsive Design, HTTP methods, Client-Server.'),
    (11, 'dd000b00-0000-4a00-a000-000000000001',
     'Bài tập chương 3: Tầng vận chuyển và Socket',
     'TCP/UDP socket, multiplexing/demultiplexing, reliable data transfer, congestion control.'),
    (12, 'dd000c00-0000-4a00-a000-000000000001',
     'Bài tập chương 4: Tầng ứng dụng (DNS, HTTP, SMTP)',
     'Phân tích DNS resolution, HTTP request/response, email protocols, P2P vs Client-Server.'),
]

# ======================================================================
# Question bank per assignment
# Format: list of (question_text, explanation, difficulty, [
#   (choice_text, is_correct), ...
# ])
# ======================================================================
QUESTIONS_BANK = {
    # ---- MMT Assignment 1: OSI ----
    1: [
        ("Mô hình OSI có bao nhiêu tầng?", "Mô hình OSI gồm 7 tầng.", 2, [
            ("5 tầng", False), ("6 tầng", False), ("7 tầng", True), ("8 tầng", False)
        ]),
        ("Tầng nào trong mô hình OSI chịu trách nhiệm định tuyến?", "Tầng Network (tầng 3) chịu trách nhiệm định tuyến.", 2, [
            ("Tầng Transport", False), ("Tầng Network", True), ("Tầng Data Link", False), ("Tầng Physical", False)
        ]),
        ("Giao thức nào hoạt động ở tầng Transport?", "TCP và UDP hoạt động ở tầng Transport.", 2, [
            ("HTTP", False), ("TCP", True), ("ARP", False), ("ICMP", False)
        ]),
        ("Đơn vị dữ liệu ở tầng Data Link gọi là gì?", "Đơn vị dữ liệu ở tầng Data Link là Frame.", 2, [
            ("Packet", False), ("Segment", False), ("Frame", True), ("Bit", False)
        ]),
        ("Tầng nào chịu trách nhiệm mã hóa và nén dữ liệu?", "Tầng Presentation chịu trách nhiệm mã hóa, nén dữ liệu.", 3, [
            ("Session", False), ("Presentation", True), ("Application", False), ("Transport", False)
        ]),
        ("PDU của tầng Transport là gì?", "PDU của tầng Transport là Segment.", 2, [
            ("Packet", False), ("Frame", False), ("Segment", True), ("Data", False)
        ]),
        ("Thiết bị Switch hoạt động ở tầng nào?", "Switch hoạt động ở tầng 2 (Data Link).", 2, [
            ("Tầng 1", False), ("Tầng 2", True), ("Tầng 3", False), ("Tầng 4", False)
        ]),
        ("Giao thức ARP thuộc tầng nào?", "ARP hoạt động ở tầng Network/Data Link.", 3, [
            ("Tầng Application", False), ("Tầng Network", True), ("Tầng Physical", False), ("Tầng Session", False)
        ]),
        ("Router hoạt động ở tầng nào của mô hình OSI?", "Router hoạt động ở tầng 3 (Network).", 2, [
            ("Tầng 2", False), ("Tầng 3", True), ("Tầng 4", False), ("Tầng 1", False)
        ]),
        ("Chức năng chính của tầng Physical là gì?", "Tầng Physical truyền bit qua đường truyền vật lý.", 1, [
            ("Định tuyến", False), ("Truyền bit qua đường truyền vật lý", True), ("Mã hóa dữ liệu", False), ("Quản lý phiên", False)
        ]),
    ],
    # ---- MMT Assignment 2: TCP/UDP ----
    2: [
        ("TCP là giao thức hướng kết nối hay không kết nối?", "TCP là giao thức hướng kết nối (connection-oriented).", 2, [
            ("Không kết nối", False), ("Hướng kết nối", True), ("Cả hai", False), ("Không xác định", False)
        ]),
        ("UDP phù hợp cho ứng dụng nào?", "UDP phù hợp cho streaming, VoIP, DNS do tốc độ cao, độ trễ thấp.", 2, [
            ("Truyền file lớn", False), ("Email", False), ("Video streaming", True), ("Web browsing", False)
        ]),
        ("Three-way handshake gồm những bước nào?", "Three-way handshake: SYN → SYN-ACK → ACK.", 2, [
            ("SYN → ACK → FIN", False), ("SYN → SYN-ACK → ACK", True), ("ACK → SYN → FIN", False), ("FIN → ACK → SYN", False)
        ]),
        ("Port number nào là Well-known port?", "Well-known ports: 0-1023.", 2, [
            ("0-1023", True), ("1024-49151", False), ("49152-65535", False), ("0-65535", False)
        ]),
        ("Flow control trong TCP sử dụng cơ chế nào?", "TCP sử dụng Sliding Window cho flow control.", 3, [
            ("Token Bucket", False), ("Sliding Window", True), ("Leaky Bucket", False), ("FIFO Queue", False)
        ]),
        ("Header TCP có kích thước tối thiểu bao nhiêu byte?", "Header TCP tối thiểu 20 bytes.", 2, [
            ("8 bytes", False), ("16 bytes", False), ("20 bytes", True), ("32 bytes", False)
        ]),
        ("So sánh TCP và UDP: phát biểu nào đúng?", "TCP đảm bảo truyền tin cậy, UDP không đảm bảo nhưng nhanh hơn. TCP có cơ chế kiểm soát lỗi và flow control.", 3, [
            ("UDP đảm bảo truyền tin cậy hơn TCP", False),
            ("TCP có cơ chế kiểm soát lỗi, UDP không có", True),
            ("TCP và UDP đều không có flow control", False),
            ("UDP có three-way handshake", False)
        ]),
    ],
    # ---- MMT Assignment 3: IP/Subnetting ----
    3: [
        ("Địa chỉ IP 192.168.1.0/24 thuộc lớp nào?", "192.168.x.x thuộc lớp C (Class C).", 2, [
            ("Lớp A", False), ("Lớp B", False), ("Lớp C", True), ("Lớp D", False)
        ]),
        ("Subnet mask /28 tương ứng bao nhiêu host?", "/28 = 255.255.255.240, có 2^4 - 2 = 14 host.", 3, [
            ("14 host", True), ("16 host", False), ("30 host", False), ("62 host", False)
        ]),
        ("Địa chỉ broadcast của mạng 10.0.0.0/8 là gì?", "Broadcast address = 10.255.255.255.", 2, [
            ("10.0.0.255", False), ("10.255.255.255", True), ("10.0.255.255", False), ("10.255.0.0", False)
        ]),
        ("VLSM dùng để làm gì?", "VLSM cho phép chia subnet với các prefix length khác nhau.", 3, [
            ("Tăng tốc độ mạng", False), ("Chia subnet với prefix length khác nhau", True),
            ("Mã hóa dữ liệu", False), ("Quản lý VLAN", False)
        ]),
        ("Địa chỉ 172.16.0.0 - 172.31.255.255 là địa chỉ gì?", "Đây là dải địa chỉ Private IP Class B.", 2, [
            ("Public IP", False), ("Private IP", True), ("Multicast", False), ("Loopback", False)
        ]),
        ("CIDR notation /20 có bao nhiêu IP?", "/20 có 2^12 = 4096 IP.", 3, [
            ("1024", False), ("2048", False), ("4096", True), ("8192", False)
        ]),
        ("Network address của 192.168.10.130/25?", "192.168.10.128/25 là network address.", 3, [
            ("192.168.10.0", False), ("192.168.10.128", True), ("192.168.10.127", False), ("192.168.10.130", False)
        ]),
        ("Loopback address là gì?", "127.0.0.1 là loopback address.", 1, [
            ("127.0.0.1", True), ("192.168.0.1", False), ("10.0.0.1", False), ("255.255.255.255", False)
        ]),
        ("Tính số subnet khi chia /24 thành /26?", "Từ /24 sang /26: mượn 2 bit, 2^2 = 4 subnet.", 3, [
            ("2 subnet", False), ("4 subnet", True), ("8 subnet", False), ("16 subnet", False)
        ]),
        ("Xác định host hợp lệ đầu tiên của mạng 172.16.32.0/20?", "Host đầu tiên = 172.16.32.1.", 3, [
            ("172.16.32.0", False), ("172.16.32.1", True), ("172.16.33.0", False), ("172.16.31.1", False)
        ]),
        ("Tính toán: Mạng 10.10.0.0/22 chứa bao nhiêu host sử dụng được?", "Mạng /22: 2^10 - 2 = 1022 host.", 3, [
            ("254", False), ("510", False), ("1022", True), ("1024", False)
        ]),
    ],
    # ---- MMT Assignment 4: VLAN/Routing ----
    4: [
        ("VLAN dùng để làm gì?", "VLAN chia mạng LAN vật lý thành các mạng logic riêng biệt.", 2, [
            ("Tăng tốc độ mạng", False), ("Chia mạng logic", True), ("Mã hóa dữ liệu", False), ("Quản lý IP", False)
        ]),
        ("Inter-VLAN routing cần thiết bị gì?", "Cần Router hoặc Layer 3 Switch để thực hiện inter-VLAN routing.", 2, [
            ("Hub", False), ("Switch Layer 2", False), ("Router hoặc Switch Layer 3", True), ("Access Point", False)
        ]),
        ("Static routing khác dynamic routing ở điểm nào?", "Static routing cấu hình thủ công, Dynamic routing tự cập nhật.", 2, [
            ("Static routing tự cập nhật", False), ("Static routing cấu hình thủ công", True),
            ("Không có sự khác biệt", False), ("Dynamic routing cấu hình thủ công", False)
        ]),
        ("NAT dùng để làm gì?", "NAT chuyển đổi địa chỉ IP private sang public và ngược lại.", 2, [
            ("Mã hóa dữ liệu", False), ("Chuyển đổi IP private-public", True),
            ("Chia VLAN", False), ("Quản lý DNS", False)
        ]),
        ("Cấu hình trunk port trên switch dùng lệnh gì?", "Dùng lệnh switchport mode trunk.", 3, [
            ("switchport mode access", False), ("switchport mode trunk", True),
            ("interface vlan", False), ("ip route", False)
        ]),
        ("Giao thức 802.1Q dùng để làm gì?", "802.1Q là chuẩn VLAN tagging trên trunk link.", 3, [
            ("Mã hóa wireless", False), ("VLAN tagging", True),
            ("Định tuyến", False), ("Quản lý bandwidth", False)
        ]),
    ],
    # ---- SQL Assignment 5: DDL ----
    5: [
        ("Lệnh nào tạo bảng mới?", "CREATE TABLE dùng để tạo bảng mới.", 1, [
            ("INSERT TABLE", False), ("CREATE TABLE", True), ("MAKE TABLE", False), ("NEW TABLE", False)
        ]),
        ("Ràng buộc PRIMARY KEY có đặc điểm gì?", "PRIMARY KEY đảm bảo giá trị duy nhất và NOT NULL.", 2, [
            ("Cho phép NULL", False), ("Duy nhất và NOT NULL", True),
            ("Cho phép trùng lặp", False), ("Chỉ dùng cho số", False)
        ]),
        ("FOREIGN KEY dùng để làm gì?", "FOREIGN KEY tạo ràng buộc tham chiếu giữa 2 bảng.", 2, [
            ("Mã hóa dữ liệu", False), ("Tạo index", False),
            ("Tham chiếu giữa 2 bảng", True), ("Xóa bảng", False)
        ]),
        ("ALTER TABLE dùng để?", "ALTER TABLE sửa đổi cấu trúc bảng đã có.", 2, [
            ("Xóa bảng", False), ("Tạo bảng mới", False),
            ("Sửa đổi cấu trúc bảng", True), ("Truy vấn dữ liệu", False)
        ]),
        ("Ràng buộc CHECK dùng để?", "CHECK kiểm tra điều kiện cho giá trị của cột.", 2, [
            ("Kiểm tra điều kiện giá trị", True), ("Tạo khóa chính", False),
            ("Xóa dữ liệu", False), ("Tạo index", False)
        ]),
        ("Viết lệnh DDL tạo bảng Students(id, name, email) với PRIMARY KEY và UNIQUE constraint?",
         "CREATE TABLE Students (id INT PRIMARY KEY, name NVARCHAR(100) NOT NULL, email NVARCHAR(255) UNIQUE);", 3, [
            ("Đúng cú pháp với PRIMARY KEY trên id và UNIQUE trên email", True),
            ("Thiếu PRIMARY KEY", False),
            ("Thiếu UNIQUE constraint", False),
            ("Sai kiểu dữ liệu", False)
        ]),
    ],
    # ---- SQL Assignment 6: SELECT/JOIN ----
    6: [
        ("INNER JOIN trả về kết quả gì?", "INNER JOIN trả về các bản ghi có kết quả khớp ở cả 2 bảng.", 2, [
            ("Tất cả bản ghi bảng trái", False), ("Bản ghi khớp ở cả 2 bảng", True),
            ("Tất cả bản ghi bảng phải", False), ("Tất cả bản ghi", False)
        ]),
        ("LEFT JOIN khác INNER JOIN ở điểm nào?", "LEFT JOIN trả về tất cả bản ghi bảng trái, kể cả không khớp.", 2, [
            ("Giống nhau", False), ("Trả về tất cả bản ghi bảng trái", True),
            ("Trả về tất cả bảng phải", False), ("Chỉ trả về NULL", False)
        ]),
        ("Hàm COUNT() dùng để?", "COUNT() đếm số bản ghi.", 1, [
            ("Tính tổng", False), ("Đếm số bản ghi", True),
            ("Tính trung bình", False), ("Tìm giá trị lớn nhất", False)
        ]),
        ("GROUP BY dùng kết hợp với?", "GROUP BY thường dùng với các hàm aggregate.", 2, [
            ("WHERE", False), ("Hàm aggregate (COUNT, SUM, AVG...)", True),
            ("ORDER BY", False), ("LIMIT", False)
        ]),
        ("HAVING khác WHERE ở điểm nào?", "HAVING lọc kết quả sau GROUP BY, WHERE lọc trước GROUP BY.", 3, [
            ("Giống nhau", False), ("HAVING lọc sau GROUP BY", True),
            ("WHERE lọc sau GROUP BY", False), ("HAVING chỉ dùng với SELECT", False)
        ]),
        ("Subquery là gì?", "Subquery là truy vấn lồng bên trong truy vấn khác.", 2, [
            ("Truy vấn riêng biệt", False), ("Truy vấn lồng bên trong truy vấn khác", True),
            ("Stored procedure", False), ("View", False)
        ]),
        ("Viết truy vấn đếm số sinh viên mỗi lớp có điểm trung bình > 7?",
         "SELECT class_id, COUNT(*) FROM students GROUP BY class_id HAVING AVG(score) > 7;", 3, [
            ("Dùng GROUP BY + HAVING AVG(score) > 7", True),
            ("Dùng WHERE AVG(score) > 7", False),
            ("Không cần GROUP BY", False),
            ("Dùng DISTINCT thay GROUP BY", False)
        ]),
    ],
    # ---- SQL Assignment 7: Giữa kỳ ----
    7: [
        ("DML gồm những lệnh nào?", "DML: INSERT, UPDATE, DELETE, SELECT.", 2, [
            ("CREATE, ALTER, DROP", False), ("INSERT, UPDATE, DELETE, SELECT", True),
            ("GRANT, REVOKE", False), ("BEGIN, COMMIT, ROLLBACK", False)
        ]),
        ("Stored Procedure là gì?", "Stored Procedure là chương trình được lưu trữ trong database.", 2, [
            ("Một loại bảng", False), ("Chương trình lưu trong database", True),
            ("Một loại index", False), ("Một loại constraint", False)
        ]),
        ("Transaction đảm bảo tính chất gì?", "Transaction đảm bảo ACID: Atomicity, Consistency, Isolation, Durability.", 3, [
            ("BASE", False), ("ACID", True), ("CRUD", False), ("REST", False)
        ]),
        ("COMMIT dùng để?", "COMMIT xác nhận các thay đổi trong transaction.", 2, [
            ("Hủy bó thay đổi", False), ("Xác nhận thay đổi", True),
            ("Bắt đầu transaction", False), ("Tạo savepoint", False)
        ]),
        ("INDEX dùng để?", "INDEX tăng tốc độ truy vấn dữ liệu.", 2, [
            ("Xóa dữ liệu", False), ("Mã hóa dữ liệu", False),
            ("Tăng tốc truy vấn", True), ("Tạo constraint", False)
        ]),
        ("ROLLBACK dùng khi nào?", "ROLLBACK hủy bỏ các thay đổi chưa COMMIT.", 2, [
            ("Khi muốn lưu dữ liệu", False), ("Khi muốn hủy thay đổi", True),
            ("Khi tạo bảng mới", False), ("Khi xóa database", False)
        ]),
        ("Trigger là gì?", "Trigger là stored program tự chạy khi có sự kiện INSERT/UPDATE/DELETE.", 3, [
            ("Một loại view", False), ("Stored program tự chạy khi có sự kiện", True),
            ("Một loại index", False), ("Một loại constraint", False)
        ]),
        ("VIEW khác TABLE ở điểm nào?", "VIEW là bảng ảo dựa trên kết quả truy vấn, không lưu dữ liệu vật lý.", 2, [
            ("Giống nhau hoàn toàn", False), ("VIEW là bảng ảo, không lưu dữ liệu vật lý", True),
            ("VIEW lưu dữ liệu nhiều hơn TABLE", False), ("TABLE không thể JOIN được", False)
        ]),
        ("Viết stored procedure tính tổng điểm sinh viên theo mã SV?",
         "CREATE PROCEDURE sp_TongDiem @MaSV INT AS SELECT SUM(Diem) FROM BangDiem WHERE MaSV = @MaSV;", 3, [
            ("Đúng cú pháp CREATE PROCEDURE với tham số và SELECT SUM", True),
            ("Thiếu tham số đầu vào", False),
            ("Sai cú pháp PROCEDURE", False),
            ("Dùng FUNCTION thay PROCEDURE", False)
        ]),
        ("Viết transaction chuyển tiền giữa 2 tài khoản?",
         "BEGIN TRANSACTION; UPDATE Accounts SET Balance = Balance - 100 WHERE ID = 1; UPDATE Accounts SET Balance = Balance + 100 WHERE ID = 2; COMMIT;", 3, [
            ("Đúng: BEGIN, 2 UPDATE, COMMIT", True),
            ("Thiếu COMMIT", False),
            ("Không cần BEGIN TRANSACTION", False),
            ("Dùng INSERT thay UPDATE", False)
        ]),
    ],
    # ---- WEB Assignment 8: HTML/CSS ----
    8: [
        ("Thẻ semantic nào dùng cho phần header?", "<header> là thẻ semantic dùng cho phần đầu trang.", 1, [
            ("<div>", False), ("<header>", True), ("<head>", False), ("<top>", False)
        ]),
        ("CSS Flexbox: justify-content dùng để?", "justify-content căn chỉnh item theo trục chính.", 2, [
            ("Căn chỉnh trục phụ", False), ("Căn chỉnh trục chính", True),
            ("Đổi hướng flex", False), ("Đặt kích thước", False)
        ]),
        ("Box Model gồm những thành phần nào?", "Box Model: Content, Padding, Border, Margin.", 2, [
            ("Content, Padding, Border, Margin", True), ("Content, Spacing, Border", False),
            ("Padding, Margin, Width", False), ("Content, Border only", False)
        ]),
        ("Thuộc tính display: flex dùng để?", "display: flex kích hoạt Flexbox layout cho container.", 2, [
            ("Ẩn phần tử", False), ("Kích hoạt Flexbox layout", True),
            ("Tạo grid layout", False), ("Xóa phần tử", False)
        ]),
        ("CSS selector .class khác #id ở điểm nào?", ".class chọn nhiều phần tử, #id chọn 1 phần tử duy nhất.", 2, [
            ("Giống nhau", False), (".class chọn nhiều, #id chọn 1", True),
            ("#id chọn nhiều phần tử", False), (".class có ưu tiên cao hơn", False)
        ]),
        ("Thẻ <nav> dùng để?", "<nav> chứa các liên kết điều hướng.", 1, [
            ("Hiển thị hình ảnh", False), ("Chứa liên kết điều hướng", True),
            ("Tạo form", False), ("Hiển thị bảng", False)
        ]),
        ("Giải thích sự khác nhau giữa Flexbox và CSS Grid? Khi nào dùng cái nào?",
         "Flexbox: 1 chiều (row/column). Grid: 2 chiều (row + column). Flexbox cho component nhỏ, Grid cho layout tổng thể.", 3, [
            ("Flexbox 1 chiều, Grid 2 chiều, phù hợp tùy trường hợp", True),
            ("Flexbox và Grid giống nhau", False),
            ("Chỉ nên dùng Grid cho mọi trường hợp", False),
            ("Flexbox đã lỗi thời, chỉ dùng Grid", False)
        ]),
    ],
    # ---- WEB Assignment 9: JavaScript DOM ----
    9: [
        ("document.querySelector() trả về gì?", "querySelector trả về phần tử đầu tiên khớp selector.", 2, [
            ("Tất cả phần tử", False), ("Phần tử đầu tiên khớp", True),
            ("NodeList", False), ("Mảng phần tử", False)
        ]),
        ("addEventListener() dùng để?", "addEventListener gắn hàm xử lý sự kiện cho phần tử.", 2, [
            ("Tạo phần tử mới", False), ("Gắn hàm xử lý sự kiện", True),
            ("Xóa phần tử", False), ("Thay đổi CSS", False)
        ]),
        ("Sự khác nhau giữa let và var?", "let có block scope, var có function scope.", 2, [
            ("Giống nhau", False), ("let block scope, var function scope", True),
            ("var block scope, let function scope", False), ("Cả hai đều global", False)
        ]),
        ("createElement() dùng để?", "createElement tạo phần tử HTML mới trong DOM.", 2, [
            ("Xóa phần tử", False), ("Tạo phần tử HTML mới", True),
            ("Tìm phần tử", False), ("Sửa CSS", False)
        ]),
        ("Event bubbling là gì?", "Event bubbling: sự kiện lan từ phần tử con lên phần tử cha.", 3, [
            ("Sự kiện lan từ cha xuống con", False), ("Sự kiện lan từ con lên cha", True),
            ("Sự kiện bị hủy", False), ("Sự kiện lặp lại", False)
        ]),
        ("innerHTML khác textContent ở điểm nào?", "innerHTML parse HTML, textContent chỉ xử lý text thuần.", 2, [
            ("Giống nhau", False), ("innerHTML parse HTML, textContent text thuần", True),
            ("textContent parse HTML", False), ("innerHTML chỉ text", False)
        ]),
        ("Viết hàm JavaScript validate form: kiểm tra email không rỗng và có chứa ký tự @?",
         "function validate(email) { return email && email.includes('@'); }", 3, [
            ("Kiểm tra email không rỗng và chứa @", True),
            ("Chỉ kiểm tra rỗng", False),
            ("Không cần kiểm tra @", False),
            ("Dùng regex phức tạp cho mọi trường hợp", False)
        ]),
    ],
    # ---- WEB Assignment 10: Giữa kỳ Web ----
    10: [
        ("HTTP method GET dùng để?", "GET yêu cầu dữ liệu từ server.", 1, [
            ("Gửi dữ liệu", False), ("Yêu cầu dữ liệu", True),
            ("Xóa dữ liệu", False), ("Cập nhật dữ liệu", False)
        ]),
        ("Status code 404 nghĩa là gì?", "404: Không tìm thấy tài nguyên (Not Found).", 1, [
            ("Thành công", False), ("Không tìm thấy", True),
            ("Lỗi server", False), ("Chuyển hướng", False)
        ]),
        ("Media Query @media (max-width: 768px) áp dụng cho?", "Áp dụng cho màn hình có chiều rộng tối đa 768px.", 2, [
            ("Màn hình lớn hơn 768px", False), ("Màn hình nhỏ hơn hoặc bằng 768px", True),
            ("Tất cả màn hình", False), ("Chỉ tablet", False)
        ]),
        ("Viewport meta tag dùng để?", "Viewport meta tag giúp responsive trên mobile.", 2, [
            ("SEO", False), ("Responsive trên mobile", True),
            ("Mã hóa trang", False), ("Cache dữ liệu", False)
        ]),
        ("POST khác GET ở điểm nào?", "POST gửi dữ liệu trong body, GET gửi qua URL parameters.", 2, [
            ("Giống nhau", False), ("POST gửi trong body, GET qua URL", True),
            ("GET an toàn hơn POST", False), ("POST chỉ dùng cho hình ảnh", False)
        ]),
        ("Client-Server architecture là gì?", "Client gửi request, Server xử lý và trả response.", 2, [
            ("Client và Server giống nhau", False), ("Client gửi request, Server trả response", True),
            ("Chỉ có Server", False), ("P2P architecture", False)
        ]),
        ("CSS Grid: grid-template-columns dùng để?", "Định nghĩa số lượng và kích thước cột.", 2, [
            ("Định nghĩa hàng", False), ("Định nghĩa cột", True),
            ("Định nghĩa gap", False), ("Xóa grid", False)
        ]),
        ("DOM là gì?", "DOM (Document Object Model) biểu diễn trang web dưới dạng cây đối tượng.", 2, [
            ("Database Object Model", False), ("Document Object Model", True),
            ("Data Object Management", False), ("Display Output Method", False)
        ]),
        ("Thiết kế responsive layout cho trang có sidebar và main content sử dụng CSS Grid?",
         "Dùng grid-template-columns với media query để đổi layout trên mobile.", 3, [
            ("Dùng CSS Grid + media query cho responsive", True),
            ("Chỉ dùng float", False),
            ("Không cần media query", False),
            ("Dùng table layout", False)
        ]),
        ("Tổng hợp: Giải thích luồng HTTP khi người dùng nhập URL và nhấn Enter?",
         "DNS lookup → TCP connection → HTTP request → Server xử lý → HTTP response → Browser render.", 3, [
            ("DNS → TCP → HTTP Request → Response → Render", True),
            ("Chỉ gửi HTTP request", False),
            ("Không cần DNS", False),
            ("Server tự gửi dữ liệu", False)
        ]),
    ],
    # ---- TTTNN Assignment 11: Transport/Socket ----
    11: [
        ("Socket là gì?", "Socket là điểm cuối (endpoint) của giao tiếp mạng, kết hợp IP + Port.", 2, [
            ("Một loại cáp mạng", False), ("Endpoint giao tiếp mạng (IP + Port)", True),
            ("Một giao thức", False), ("Một thiết bị phần cứng", False)
        ]),
        ("Multiplexing ở tầng Transport là gì?", "Multiplexing: gộp dữ liệu từ nhiều ứng dụng vào 1 kết nối.", 2, [
            ("Chia dữ liệu ra nhiều kết nối", False), ("Gộp nhiều ứng dụng vào 1 kết nối", True),
            ("Mã hóa dữ liệu", False), ("Nén dữ liệu", False)
        ]),
        ("Demultiplexing nghĩa là gì?", "Demultiplexing: phân phối dữ liệu đến đúng ứng dụng theo port.", 2, [
            ("Gộp dữ liệu", False), ("Phân phối dữ liệu đến đúng ứng dụng", True),
            ("Xóa dữ liệu", False), ("Mã hóa dữ liệu", False)
        ]),
        ("Reliable Data Transfer đảm bảo điều gì?", "RDT đảm bảo dữ liệu đến đích chính xác, đúng thứ tự.", 3, [
            ("Tốc độ cao nhất", False), ("Dữ liệu chính xác, đúng thứ tự", True),
            ("Không cần ACK", False), ("Chỉ cần gửi 1 lần", False)
        ]),
        ("Congestion control khác flow control ở điểm nào?", "Congestion control: kiểm soát tắc nghẽn mạng. Flow control: kiểm soát tốc độ receiver.", 3, [
            ("Giống nhau", False),
            ("Congestion control cho mạng, flow control cho receiver", True),
            ("Chỉ TCP mới cần", False),
            ("Không liên quan tầng Transport", False)
        ]),
        ("TCP Reno và TCP Tahoe khác nhau ở?", "TCP Reno: Fast Recovery sau 3 duplicate ACK. Tahoe: quay về Slow Start.", 3, [
            ("Giống nhau hoàn toàn", False), ("Cách xử lý sau 3 duplicate ACK", True),
            ("Tốc độ truyền", False), ("Kích thước header", False)
        ]),
        ("Slow Start trong TCP là gì?", "Slow Start tăng cwnd theo cấp số nhân từ 1 MSS.", 3, [
            ("Giảm tốc độ dần", False), ("Tăng cwnd theo cấp số nhân", True),
            ("Giữ tốc độ không đổi", False), ("Chỉ dùng cho UDP", False)
        ]),
        ("Port 80 thường dùng cho dịch vụ gì?", "Port 80 dùng cho HTTP.", 1, [
            ("FTP", False), ("HTTP", True), ("SMTP", False), ("DNS", False)
        ]),
        ("So sánh connection-oriented vs connectionless transport: phân tích ưu nhược điểm?",
         "Connection-oriented (TCP): tin cậy, có handshake. Connectionless (UDP): nhanh, nhẹ, không đảm bảo.", 3, [
            ("TCP tin cậy có handshake, UDP nhanh không đảm bảo, tùy use case", True),
            ("TCP luôn tốt hơn UDP", False),
            ("UDP luôn tốt hơn TCP", False),
            ("Không có sự khác biệt", False)
        ]),
    ],
    # ---- TTTNN Assignment 12: Application Layer ----
    12: [
        ("DNS dùng để làm gì?", "DNS chuyển đổi tên miền thành địa chỉ IP.", 1, [
            ("Mã hóa dữ liệu", False), ("Chuyển đổi tên miền thành IP", True),
            ("Truyền file", False), ("Gửi email", False)
        ]),
        ("HTTP là giao thức ở tầng nào?", "HTTP hoạt động ở tầng Application.", 1, [
            ("Transport", False), ("Application", True), ("Network", False), ("Session", False)
        ]),
        ("SMTP dùng để?", "SMTP dùng để gửi email.", 1, [
            ("Nhận email", False), ("Gửi email", True), ("Duyệt web", False), ("Truyền file", False)
        ]),
        ("POP3 và IMAP khác nhau gì?", "POP3 tải về và xóa trên server. IMAP đồng bộ giữ trên server.", 2, [
            ("Giống nhau", False), ("POP3 tải xóa, IMAP đồng bộ", True),
            ("IMAP tải xóa", False), ("Cả hai đều xóa", False)
        ]),
        ("P2P khác Client-Server ở điểm nào?", "P2P: mỗi node vừa client vừa server. Client-Server: vai trò tách biệt.", 2, [
            ("Giống nhau", False), ("P2P mỗi node là cả client và server", True),
            ("Client-Server nhanh hơn luôn", False), ("P2P cần server trung tâm", False)
        ]),
        ("DNS sử dụng giao thức gì?", "DNS chủ yếu dùng UDP port 53, TCP cho zone transfer.", 2, [
            ("Chỉ TCP", False), ("Chủ yếu UDP", True), ("Chỉ HTTP", False), ("FTP", False)
        ]),
        ("HTTP/2 cải tiến gì so với HTTP/1.1?", "HTTP/2: multiplexing, header compression, server push.", 3, [
            ("Không có cải tiến", False), ("Multiplexing, header compression, server push", True),
            ("Chỉ nhanh hơn một chút", False), ("Bỏ TCP dùng UDP", False)
        ]),
        ("Caching trong web hoạt động như thế nào?", "Cache lưu trữ tạm tài nguyên để giảm request đến server.", 2, [
            ("Xóa dữ liệu cũ", False), ("Lưu trữ tạm giảm request", True),
            ("Tăng traffic", False), ("Mã hóa dữ liệu", False)
        ]),
        ("Phân tích quá trình DNS resolution khi gõ www.google.com?",
         "Browser cache → Local DNS → Root → TLD (.com) → Authoritative DNS → IP trả về.", 3, [
            ("Cache → Local DNS → Root → TLD → Authoritative → IP", True),
            ("Chỉ hỏi 1 DNS server", False),
            ("Không cần cache", False),
            ("Gửi thẳng HTTP request", False)
        ]),
    ],
}


def escape_sql(s: str) -> str:
    """Escape single quotes for SQL."""
    return s.replace("'", "''")


def generate_fix_sql():
    lines = []
    lines.append("-- ============================================================")
    lines.append("-- FIX: Encoding + Question Structure for seed assignments")
    lines.append("-- Date: 2026-04-08")
    lines.append("-- ============================================================")
    lines.append("")
    lines.append("BEGIN;")
    lines.append("")

    # ================================================================
    # PART 1: Fix Vietnamese encoding in assignments
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- PART 1: Fix Vietnamese encoding in assignments")
    lines.append("-- ============================================================")
    for idx, a_id, title, desc in ASSIGNMENTS:
        lines.append(
            f"UPDATE assignments SET title = E'{escape_sql(title)}', "
            f"description = E'{escape_sql(desc)}' "
            f"WHERE id = '{a_id}';"
        )
    lines.append("")

    # ================================================================
    # PART 2: Create questions in `questions` table
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- PART 2: Create questions in questions table")
    lines.append("-- ============================================================")

    # Track question UUIDs per assignment for linking
    question_uuids = {}  # {(a_idx, q_idx): uuid_str}

    for a_idx, questions in QUESTIONS_BANK.items():
        a_data = ASSIGNMENTS[a_idx - 1]
        a_id = a_data[1]

        lines.append(f"")
        lines.append(f"-- Questions for Assignment {a_idx}: {escape_sql(a_data[2])}")

        for q_idx, (q_text, explanation, difficulty, choices) in enumerate(questions):
            q_uuid = str(uuid.uuid5(uuid.NAMESPACE_DNS, f"seed-q-{a_idx}-{q_idx}"))
            question_uuids[(a_idx, q_idx)] = q_uuid

            q_type = "multiple_choice"
            content_obj = {"text": q_text, "explanation": explanation}
            # Find correct choice IDs
            correct_ids = [i for i, (_, is_correct) in enumerate(choices) if is_correct]
            answer_obj = {"correct_choice_ids": correct_ids}

            lines.append(
                f"INSERT INTO questions (id, author_id, type, content, answer, default_points, difficulty, tags, is_public, created_at, updated_at) VALUES "
                f"('{q_uuid}', '{TEACHER_ID}', '{q_type}', "
                f"'{escape_sql(json.dumps(content_obj, ensure_ascii=False))}'::jsonb, "
                f"'{json.dumps(answer_obj)}'::jsonb, "
                f"1.00, {difficulty}, ARRAY[]::text[], false, NOW(), NOW()) "
                f"ON CONFLICT (id) DO NOTHING;"
            )

            # Insert choices
            for c_idx, (c_text, is_correct) in enumerate(choices):
                lines.append(
                    f"INSERT INTO question_choices (id, question_id, content, is_correct) VALUES "
                    f"({c_idx}, '{q_uuid}', "
                    f"'{escape_sql(json.dumps(c_text, ensure_ascii=False))}'::jsonb, "
                    f"{'true' if is_correct else 'false'}) "
                    f"ON CONFLICT DO NOTHING;"
                )

    lines.append("")

    # ================================================================
    # PART 3: Update assignment_questions with question_id + custom_content
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- PART 3: Update assignment_questions with question_id + custom_content")
    lines.append("-- ============================================================")

    # Map from make_uuid function (same as in generate_analytics_seed.py)
    def make_uuid(prefix, a_idx, sub_idx, category):
        a_hex = f"{a_idx:02x}"
        s_hex = f"{sub_idx:02x}"
        return f"{prefix}00{a_hex}{s_hex}-0000-4a00-{category}000-000000000001"

    for a_idx, questions in QUESTIONS_BANK.items():
        a_data = ASSIGNMENTS[a_idx - 1]
        lines.append(f"")
        lines.append(f"-- Link questions for Assignment {a_idx}")

        for q_idx, (q_text, explanation, difficulty, choices) in enumerate(questions):
            aq_id = make_uuid('ee', a_idx, q_idx + 1, 'a')  # order_idx is 1-based
            q_uuid = question_uuids[(a_idx, q_idx)]

            # Build custom_content matching the working format
            custom_choices = []
            for c_idx, (c_text, is_correct) in enumerate(choices):
                custom_choices.append({
                    "id": c_idx,
                    "text": c_text,
                    "isCorrect": is_correct
                })

            custom_content = {
                "type": "multiple_choice",
                "hints": [],
                "choices": custom_choices,
                "override_text": q_text,
                "difficulty": difficulty,
                "explanation": explanation,
                "learningObjectives": [],
                "tags": []
            }

            lines.append(
                f"UPDATE assignment_questions SET "
                f"question_id = '{q_uuid}', "
                f"custom_content = '{escape_sql(json.dumps(custom_content, ensure_ascii=False))}'::jsonb "
                f"WHERE id = '{aq_id}';"
            )

    lines.append("")
    lines.append("COMMIT;")
    lines.append("")
    lines.append("-- ============================================================")
    lines.append("-- END OF FIX")
    lines.append("-- ============================================================")

    return "\n".join(lines)


if __name__ == '__main__':
    sql = generate_fix_sql()
    output_path = 'd:/code/Flutter_Android/Flutter_Android/AI_LMS_PRD/seed_data/09_fix_encoding_and_questions.sql'
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(sql)
    print(f"Generated fix SQL: {output_path}")
    total_lines = sql.count('\n')
    print(f"Total lines: {total_lines}")
