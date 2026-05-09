**AI-Powered Learning Management System**

**Hệ thống Quản lý Học tập Hỗ trợ AI**\
Product Requirements Document — Phiên bản 1.0 | November 2025

**Mục tiêu: Cá nhân hóa học tập ở quy mô lớn**

**(Objective: Personalized Learning at Scale)**

**Tóm tắt điều hành (Executive Summary)**

Tài liệu này trình bày yêu cầu cho một hệ thống **LMS hỗ trợ AI** nhằm tinh giản việc giao bài tập, đánh giá học sinh và đề xuất lộ trình học cá nhân trong môi trường lớp học. Hệ thống sử dụng trí tuệ nhân tạo để phân tích hiệu suất học sinh, xác định điểm mạnh — điểm yếu, và cung cấp thông tin hữu dụng cho giáo viên nhằm can thiệp đúng chỗ và thực hiện giảng dạy phân hóa.

**Thông tin tài liệu (Document Information)**

**Chủ sở hữu tài liệu:** Product Manager\
**Đối tượng mục tiêu:** Giáo viên, Học sinh, Quản trị viên trường\
**Cập nhật lần cuối:** November 11, 2025

-----
**Tổng quan sản phẩm (Product Overview)**

**Tầm nhìn sản phẩm (Product Vision)**

Tạo ra một hệ sinh thái học tập thông minh giúp giáo viên có các thông tin dựa trên dữ liệu để cá nhân hóa giáo dục, tối đa hóa kết quả học tập của học sinh qua các can thiệp có mục tiêu, và biến bài tập truyền thống thành trải nghiệm học thích ứng (adaptive) nhận diện và giải quyết nhu cầu riêng của từng học sinh trong thời gian thực.

**Vấn đề cần giải quyết (Problem Statement)**

Giáo viên đang gặp nhiều khó khăn trong việc:

- Quản lý và chấm điểm bài tập cho lớp đông một cách hiệu quả.
- Xác định lỗ hổng học tập của từng học sinh trên nhiều chủ đề.
- Cung cấp phản hồi cá nhân hóa kịp thời cho từng học sinh.
- Theo dõi tiến trình và phát triển kỹ năng theo thời gian.
- Ra quyết định giảng dạy dựa trên dữ liệu để điều chỉnh bước tiếp theo.
-----
**Người dùng mục tiêu (Target Users)**

**Người dùng chính: Giáo viên (Primary Users: Teachers)**

- Tạo và giao bài tập với mức độ tuỳ chỉnh về độ khó.
- Xem xét các đánh giá và insight do AI tạo.
- Truy cập phân tích học sinh và báo cáo tiến độ toàn diện.
- Nhận đề xuất hành động cụ thể để can thiệp trong lớp.

**Người dùng phụ: Học sinh (Secondary Users: Students)**

- Nhận bài tập với hướng dẫn rõ ràng.
- Nộp bài qua nền tảng.
- Xem phản hồi cá nhân hóa và đề xuất học tập.
- Theo dõi tiến bộ và thành tích của mình.

**Người dùng thứ cấp: Quản trị viên (Tertiary Users: Administrators)**

- Giám sát các chỉ số hiệu suất toàn hệ thống.
- Theo dõi mô hình sử dụng của giáo viên và học sinh.
- Tạo báo cáo cấp trường phục vụ hoạch định chương trình.

**Các tính năng cốt lõi & Yêu cầu (Core Features & Requirements)**
1. # **Tạo và Giao Bài Tập (Homework Creation & Assignment)**
   1. ## **Trình tạo bài tập (Assignment Builder)**
Mức ưu tiên: P0 (Must Have)

Mô tả: Giáo viên có thể tạo bài tập bằng giao diện builder linh hoạt hỗ trợ nhiều loại câu hỏi và định dạng.

Yêu cầu: 

- Hỗ trợ nhiều loại câu hỏi: trắc nghiệm (multiple choice), trả lời ngắn (short answer), bài luận (essay), bài toán (problem-solving), cho phép upload tệp (file upload).
- Trình soạn thảo văn bản phong phú (rich text editor) cho câu hỏi, hỗ trợ chèn hình ảnh, video và LaTeX.
- Khả năng nhập câu hỏi từ ngân hàng câu hỏi hoặc các bài tập trước.
- Gắn thẻ câu hỏi theo mục tiêu học tập, mức độ khó và môn học.
- Thiết lập điểm và tiêu chí chấm (grading rubrics) cho từng câu hỏi.
- Xem trước bài tập ở góc nhìn học sinh trước khi xuất bản.
  1. ## **Tạo câu hỏi hỗ trợ AI (AI-Assisted Question Generation)**
Mức ưu tiên: P1 (Should Have)

Mô tả: AI sinh câu hỏi liên quan dựa trên chuẩn chương trình, mục tiêu học tập hoặc tài liệu giảng dạy được tải lên.

Yêu cầu:

Sinh câu hỏi từ chủ đề chương trình hoặc nội dung bài giảng tải lên.

Cho phép giáo viên chỉ định mức độ khó, loại câu hỏi và số lượng.

Cung cấp lý giải cho câu hỏi sinh ra, liên kết với mục tiêu học tập.

Cho phép giáo viên chỉnh sửa, phê duyệt hoặc từ chối câu hỏi do AI tạo.
1. ## **Phân phối bài tập (Assignment Distribution)**
Mức ưu tiên: P0 (Must Have)

Mô tả: Phân phối bài linh hoạt với tuỳ chọn lên lịch và phân hóa.

Yêu cầu:

Giao cho cả lớp, nhóm chọn lọc hoặc từng học sinh cá nhân.

Thiết lập ngày nộp, cửa sổ thời gian truy cập và giới hạn thời gian làm bài.

Cho phép bật/tắt nộp muộn với chính sách tuỳ chỉnh.

Hỗ trợ bài tập phân hóa (phiên bản khác nhau cho từng học sinh).

Tự động thông báo tới học sinh khi bài được xuất bản.

1. **Nộp bài & Theo dõi công việc học sinh (Student Submission & Work Tracking)**
   1. ## **Không gian làm việc học sinh (Student Workspace)**
**Mức ưu tiên: P0 (Must Have)**\
**Mô tả:** Giao diện trực quan cho học sinh hoàn thành và nộp bài.\
**Yêu cầu:**

- Giao diện sạch, ít gây phân tâm, tối ưu cho công việc học sinh.
- Tự động lưu (auto-save) để tránh mất dữ liệu.
- Hiển thị tiến độ: đã làm / còn lại.
- Hỗ trợ upload tệp (hình ảnh, PDF, văn bản).
- Hiển thị thời gian còn lại cho bài thi có thời gian giới hạn.
- Cho phép đánh dấu câu hỏi để giáo viên xem xét (flag).
  1. ## **Quản lý nộp bài (Submission Management)**
**Mức ưu tiên: P0 (Must Have)**\
**Yêu cầu:**

- Xác nhận nộp bài rõ ràng kèm dấu thời gian (timestamp).
- Khả năng xem lại bài trước khi nộp cuối cùng.
- Tùy chọn nộp lại nếu giáo viên cho phép.
- Email xác nhận nộp gửi tới học sinh và giáo viên.
-----
1. **Đánh giá & Chấm điểm bằng AI (AI-Powered Evaluation & Grading)**
   1. ## **Chấm điểm tự động (Automated Grading)**
**Mức ưu tiên: P0 (Must Have)**\
**Mô tả:** AI chấm câu hỏi khách quan và đưa điểm sơ bộ cho câu trả lời mang tính chủ quan.\
**Yêu cầu:**

- Chấm ngay lập tức cho trắc nghiệm, đúng/sai (true/false) và câu nối khớp (matching).
- AI hỗ trợ chấm cho trả lời ngắn và bài luận dựa trên rubric.
- Nhận dạng mẫu cho bài toán và câu trả lời dạng công thức.
- Điểm tin cậy (confidence scores) cho biết mức độ chắc chắn của AI khi chấm.
- Giáo viên có thể ghi đè (override) mọi điểm do AI đưa ra.
  1. ## **Sinh phản hồi chi tiết (Detailed Feedback Generation)**
**Mức ưu tiên: P0 (Must Have)**\
**Mô tả:** AI tạo phản hồi cá nhân hóa, mang tính xây dựng cho từng câu trả lời của học sinh.\
**Yêu cầu:**

- Phản hồi ở cấp câu hỏi chỉ rõ lỗi hoặc hiểu lầm cụ thể.
- Khuyến khích khi trả lời đúng và khen ngợi công việc tốt.
- Gợi ý hoặc tài nguyên học tập cho câu trả lời sai.
- Tuỳ chỉnh giọng điệu (encouraging, direct, detailed) theo sở thích giáo viên.
- Giáo viên có thể chỉnh sửa hoặc thêm vào phản hồi do AI tạo.
  1. ## **Quy trình chấm điểm (Grading Workflow)**
**Mức ưu tiên: P0 (Must Have)**\
**Yêu cầu:**

- Bảng điều khiển (dashboard) hiển thị tất cả nộp bài cần xem xét.
- Tùy chọn chấm hàng loạt cho câu hỏi tương tự giữa các học sinh.
- Hiển thị cạnh nhau: câu trả lời học sinh, đáp án đúng và rubric.
- Điều hướng nhanh giữa các bài nộp của học sinh.
- Xuất bản điểm hàng loạt hoặc từng cá nhân khi đã xem xét xong.
-----
1. **Phân tích & Insight cho học sinh (Student Analytics & Insights)**
   1. ## **Phân tích điểm mạnh & điểm yếu (Strength & Weakness Analysis)**
**Mức ưu tiên: P0 (Must Have)**\
**Mô tả:** AI phân tích hiệu suất học sinh qua các bài tập để nhận diện mô hình học tập, điểm mạnh và điểm cần cải thiện.\
**Yêu cầu:**

- Theo dõi mức độ thành thạo kỹ năng liên kết với chuẩn chương trình (skill-level mastery tracking).
- Nhận diện các lỗi lặp lại hoặc quan niệm sai.
- Xu hướng hiệu suất theo thời gian với biểu diễn trực quan.
- So sánh với trung bình lớp và dự đoán quỹ đạo học tập (learning trajectory predictions).
- Làm nổi bật điểm mạnh theo môn để tăng sự tự tin.
  1. ## **Bảng điều khiển cá nhân học sinh (Individual Student Dashboard)**
**Mức ưu tiên: P0 (Must Have)**\
**Yêu cầu:**

- Hồ sơ toàn diện với lịch sử học tập và tóm tắt hiệu suất.
- Bản đồ kỹ năng (skill map) hiển thị mức độ thành thạo theo mục tiêu học tập.
- Hiệu suất các bài tập gần nhất với xu hướng điểm.
- Chỉ số tương tác (engagement metrics): nộp đúng hạn, thời gian làm bài.
- Mục ghi chú cho giáo viên ghi nhận quan sát.
  1. ## **Phân tích cấp lớp (Class-Level Analytics)**
**Mức ưu tiên: P1 (Should Have)**\
**Yêu cầu:**

- Phân phối hiệu suất và thống kê toàn lớp.
- Xác định câu hay khái niệm bị bỏ qua nhiều.
- Đề xuất nhóm để can thiệp mục tiêu.
- Theo dõi tiến độ so với mục tiêu học tập cấp lớp.
-----
1. **Đề xuất cá nhân hóa (Personalized Recommendations)**
   1. ## **Đề xuất hành động tiếp theo cho giáo viên (Next Action Recommendations for Teachers)**
**Mức ưu tiên: P0 (Must Have)**\
**Mô tả:** AI cung cấp đề xuất hành động khả thi cho giảng dạy dựa trên dữ liệu hiệu suất học sinh.\
**Yêu cầu:**

- Đề xuất cho từng học sinh (ví dụ: “Ôn lại phân số cho Sarah (Review fractions with Sarah)”, “Thách thức Michael với bài nâng cao (Challenge Michael with advanced problems)”).
- Gợi ý can thiệp nhóm nhỏ dựa trên điểm yếu chung.
- Điều chỉnh giảng dạy cho toàn lớp khi phát hiện khoảng trống rộng.
- Gợi ý tài nguyên (video, worksheet, hoạt động).
- Xếp hạng ưu tiên các can thiệp theo mức tác động.
- Mẹo triển khai và ước tính thời gian cần thiết.
  1. ## **Lộ trình học thích ứng cho học sinh (Adaptive Learning Paths for Students)**
**Mức ưu tiên: P1 (Should Have)**\
**Mô tả:** Học sinh nhận đề xuất luyện tập cá nhân dựa trên hiệu suất.\
**Yêu cầu:**

- Bài tập đề nghị phù hợp với điểm yếu đã được xác định.
- Đề xuất kỹ năng tiền đề khi thiếu nền tảng.
- Hoạt động mở rộng cho học sinh đã thể hiện thành thạo.
- Thư viện tài nguyên học tập được tuyển chọn theo nhu cầu học sinh.
  1. ## **Trợ lý phân hoá (Differentiation Assistant)**
**Mức ưu tiên: P2 (Nice to Have)**\
**Yêu cầu:**

- Tự động gợi ý phiên bản bài khác cho học sinh đang gặp khó.
- Đề xuất chiến lược hỗ trợ (scaffolding) cho khái niệm cụ thể.
- Sinh câu hỏi điều chỉnh ở mức độ phù hợp.
  1. ## **Trợ lý phân hoá (Differentiation Assistant)**
**Mức ưu tiên: P2 (Nice to Have)**\
**Yêu cầu:**

- Tự động gợi ý phiên bản bài khác cho học sinh đang gặp khó.
- Đề xuất chiến lược hỗ trợ (scaffolding) cho khái niệm cụ thể.
- Sinh câu hỏi điều chỉnh ở mức độ phù hợp.
-----
**Yêu cầu trải nghiệm người dùng (User Experience Requirements)**

**Trải nghiệm giáo viên (Teacher Experience)**

- Thời gian tạo và giao bài cho một bài tiêu chuẩn ≤ 10 phút.
- Thời gian chấm giảm 60–70% so với chấm thủ công.
- Dashboard tải dưới <2 giây với tất cả thông tin quan trọng hiển thị.
- Thiết kế responsive cho xem trên tablet/điện thoại.
- Tối đa 3 lần nhấp để truy cập bất kỳ tính năng chính nào từ màn hình chính.

**Trải nghiệm học sinh (Student Experience)**

- Giao diện phù hợp độ tuổi (có thể điều chỉnh theo khối lớp).
- Ít gây phân tán, tập trung vào nhiệm vụ.
- Chỉ báo tiến độ rõ ràng để giảm lo lắng.
- Thiết kế truy cập (accessible) theo chuẩn WCAG 2.1 AA.
- Khả năng offline để hoàn thành bài khi không có internet.

**Nền tảng & Hạ tầng (Platform & Infrastructure)**

- Ứng dụng web truy cập qua các trình duyệt hiện đại (Chrome, Firefox, Safari, Edge).
- Thiết kế responsive cho desktop, tablet, mobile.
- Hạ tầng cloud hosting với SLA uptime 99.9%.
- Kiến trúc có khả năng mở rộng hỗ trợ 10,000+ người dùng đồng thời.

**Yêu cầu AI/ML (AI/ML Requirements)**

- Xử lý ngôn ngữ tự nhiên (NLP) cho chấm bài luận và phản hồi.
- Mô hình ML dự báo hiệu suất và nhận dạng mẫu.
- Học liên tục từ các chỉnh sửa của giáo viên để cải thiện độ chính xác.
- AI có thể giải thích (Explainable AI) lý do cho điểm và đề xuất.
- Chỉ tiêu hiệu năng mô hình: >90% chính xác cho câu hỏi khách quan, >80% đồng thuận với giáo viên cho câu hỏi chủ quan.

**Bảo mật & Quyền riêng tư (Security & Privacy)**

- Tuân thủ FERPA (Family Educational Rights and Privacy Act) cho dữ liệu học sinh.
- Tuân thủ COPPA (Children’s Online Privacy Protection Act) cho học sinh dưới 13 tuổi.
- Kiểm soát truy cập theo vai trò (teacher, student, admin).
- Mã hóa dữ liệu khi lưu trữ và truyền tải (AES-256, TLS 1.3).
- Kiểm toán bảo mật định kỳ và penetration testing.
- Chính sách lưu trữ dữ liệu và quyền xóa dữ liệu bởi phụ huynh/người giám hộ.

**Yêu cầu tích hợp (Integration Requirements)**

- Hỗ trợ Single Sign-On (SSO) qua Google, Microsoft, Clever.
- Tích hợp LTI 1.3 để tương thích LMS hiện có.
- Xuất gradebook sang CSV và tích hợp với hệ thống SIS.
- API cho nhà cung cấp nội dung bên thứ ba và tích hợp công cụ.
## **Chỉ số thành công (Success Metrics)**
### **Chỉ số chính (Primary Metrics)**


|**Metric**|**Mục tiêu**|**Phương pháp đo**|
| :-: | :-: | :-: |
|Tiết kiệm thời gian chấm của giáo viên (Teacher time savings on grading)|Giảm 60%|Theo dõi thời gian + khảo sát|
|Tỷ lệ hoàn thành bài tập của học sinh (Student assignment completion rate)|≥ 85%|Phân tích hệ thống|
|Tỷ lệ giáo viên áp dụng (Teacher adoption rate)|70% trong 6 tháng|Theo dõi người dùng kích hoạt|
|Độ chính xác chấm của AI (AI grading accuracy)|90% cho khách quan, 80% cho chủ quan|So sánh với chấm tay giáo viên|
|Tỷ lệ giáo viên ghi đè (Teacher override tracking)|—|Theo dõi hệ thống|
|Điểm hài lòng giáo viên (Teacher satisfaction score)|≥ 4.0/5.0|Khảo sát NPS hàng quý|

**Chỉ số phụ (Secondary Metrics)**

- Tương tác học sinh: thời gian trên nền tảng mỗi tuần.
- Kết quả học tập: cải thiện điểm kiểm tra theo kỳ.
- Tỷ lệ sử dụng tính năng: % giáo viên sử dụng đề xuất AI.
- Hiệu năng hệ thống: thời gian tải trang, uptime.
- Yêu cầu hỗ trợ: khối lượng ticket và thời gian giải quyết.

**Lộ trình triển khai (Implementation Timeline)**

**Giai đoạn 1: MVP (Tháng 1–3)**

- Tạo và phân phối bài tập bằng AI.
- Cổng nộp bài cho học sinh.
- Chấm tự động cơ bản (trắc nghiệm, đúng/sai).
- Báo cáo điểm đơn giản.
- Xác thực giáo viên và học sinh.

**Giai đoạn 2: Tích hợp AI (Tháng 4–6)**

- Chấm AI cho trả lời ngắn và bài luận.
- Sinh phản hồi tự động.
- Phân tích cơ bản và theo dõi hiệu suất.
- Xác định điểm mạnh – điểm yếu.

**Giai đoạn 3: Tính năng nâng cao (Tháng 7–9)**

- Sinh câu hỏi bằng AI.
- Đề xuất cá nhân hóa cho giáo viên và học sinh.
- Dashboard phân tích nâng cao.
- Insights cấp lớp.
- Tích hợp với nền tảng ngoài (Google Classroom, v.v.).

**Giai đoạn 4: Tối ưu & Mở rộng (Tháng 10–12)**

- Lộ trình học thích ứng (adaptive learning paths).
- Trợ lý phân hoá (differentiation assistant).
- Ứng dụng di động (iOS, Android).
- Tối ưu hiệu năng dựa trên dữ liệu sử dụng.
- Cổng phụ huynh để theo dõi tiến độ.
  1. ## **Rủi ro & Biện pháp giảm thiểu (Risks & Mitigation)**

|**Rủi ro (Risk)**|**Tác động (Impact)**|**Chiến lược giảm thiểu (Mitigation Strategy)**|
| :-: | :-: | :-: |
|AI chấm không chính xác (AI grading inaccuracy)|Giáo viên mất niềm tin, ít áp dụng|Thử nghiệm rộng rãi, cho phép giáo viên ghi đè, cải tiến mô hình liên tục|
|Quan ngại quyền riêng tư dữ liệu|Trách nhiệm pháp lý, phản ứng phụ huynh|Tuân thủ FERPA/COPPA nghiêm ngặt, chính sách minh bạch, kiểm toán định kỳ|
|Giáo viên chống lại AI|Ít áp dụng, tác động hạn chế|Chương trình quản lý thay đổi, đào tạo chuyên môn, nhấn mạnh quyền kiểm soát của giáo viên|
|Độ phức tạp kỹ thuật|Trễ tiến độ, vượt chi phí|Ra mắt theo pha, đội dev có kinh nghiệm, phương pháp agile|
|Thiên lệch trong đề xuất AI (Bias)|Kết quả không công bằng, tổn hại danh tiếng|Dữ liệu huấn luyện đa dạng, kiểm tra bias, kiểm toán công bằng, giám sát con người|

**Câu hỏi mở (Open Questions)**

1. **Tập trung môn học (Subject Focus)**: MVP nên tập trung môn cụ thể (ví dụ: toán, ngữ văn) hay hỗ trợ mọi môn từ đầu?
1. **Ưu tiên bậc học (Grade Level Priority)**: Nên ưu tiên khối lớp nào cho phát triển ban đầu (tiểu học, THCS, THPT)?
1. **Mô hình định giá (Pricing Model)**: Freemium, bản quyền theo giáo viên, bản quyền theo trường hay hợp đồng theo quận?
1. **Chức năng offline (Offline Functionality)**: Offline quan trọng đến mức nào cho học sinh ở vùng kết nối yếu, có nên đưa vào MVP không?
1. **Truy cập phụ huynh (Parent Access)**: Phụ huynh có nên xem dashboard tiến độ học sinh, và mức độ chi tiết là bao nhiêu?
1. **Gamification**: Có nên thêm phần trò chơi hoá (badge, điểm, bảng xếp hạng) để tăng tương tác không?
-----
**Phụ lục (Appendix)**

**Thuật ngữ (Glossary)**

- LMS: Learning Management System — hệ thống quản lý học tập (phần mềm cho quản trị, lưu trữ, theo dõi, báo cáo và phân phối khoá học).
- FERPA: Family Educational Rights and Privacy Act — luật liên bang Hoa Kỳ bảo vệ hồ sơ giáo dục học sinh.
- COPPA: Children’s Online Privacy Protection Act — luật Hoa Kỳ quy định thu thập thông tin trực tuyến của trẻ dưới 13 tuổi.
- NLP: Natural Language Processing — công nghệ AI xử lý và hiểu ngôn ngữ con người.
- SSO: Single Sign-On — phương thức xác thực cho phép truy cập nhiều ứng dụng bằng một bộ thông tin.
- LTI: Learning Tools Interoperability — chuẩn tích hợp công cụ học tập với nền tảng.

**Tài liệu tham khảo (References)**

- “The State of EdTech 2024” — Education Week Research Center.
- “AI in Education: Promises and Implications” — UNESCO Report 2023.
- “Teacher Time Use Study” — National Center for Education Statistics.
- “Automated Grading Systems: A Review” — Journal of Educational Technology.
- “Personalized Learning at Scale” — Bill & Melinda Gates Foundation Report.

