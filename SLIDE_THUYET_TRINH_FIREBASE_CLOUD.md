# 📊 BỘ SLIDE THUYẾT TRÌNH: TÌM HIỂU VỀ FIREBASE & PHƯƠNG ÁN TÍCH HỢP CLOUD
## Dành cho nhóm sinh viên thuyết trình Bài tập Lớn / Báo cáo Chuyên đề

- **Chủ đề:** Tích hợp Điện toán Đám mây (Google Firebase) cho Hệ thống Quản lý Tài liệu Học tập
- **Ứng dụng triển khai:** `study_document_app` (Kiến trúc Cashew Local-First)
- **Kho lưu trữ GitHub:** [https://github.com/pvhung2112/cloud_study_document_app](https://github.com/pvhung2112/cloud_study_document_app)
- **Công nghệ chính:** Flutter • Firebase Authentication (Google Sign-In) • Cloud Firestore • Firebase Cloud Storage
- **Định dạng:** 12 Trang Slide hoàn chỉnh (Nội dung trình chiếu + Gợi ý hình ảnh + Lời thoại thuyết trình)

---

## 👥 DANH SÁCH NHÓM SINH VIÊN THỰC HIỆN

| STT | Họ và Tên | Mã Sinh Viên | Vai Trò | Nhiệm Vụ Phụ Trách |
| :---: | :--- | :---: | :--- | :--- |
| **1** | **Phạm Văn Hưng** | `2351170598` | **Trưởng nhóm / Core Architect** | Cấu hình dự án Flutter, hoạch định kiến trúc Local-First, tích hợp Google Firebase REST API, điều phối luồng đồng bộ dữ liệu & kiểm soát mã nguồn. |
| **2** | **Trịnh Trung Kiên** | `2251172396` | **Thành viên / Frontend Developer** | Thiết kế giao diện UI/UX theo ngôn ngữ Cashew Design, xây dựng màn hình Kho tài liệu học tập (3 Tabs: Bài giảng, Bài tập, Tham khảo) & Danh mục môn học. |
| **3** | **Đỗ Việt Tiến** | `2251243452` | **Thành viên / Frontend Developer** | Thiết kế giao diện Tìm kiếm thời gian thực, Bộ lọc phân loại đa tiêu chí (theo môn, tags, độ ưu tiên) & Hộp thoại Cloud Firebase Sync Modal. |
| **4** | **Cao Đức Đạo** | `2351170581` | **Thành viên / Backend & Database** | Quản lý cơ sở dữ liệu Local-First (DAO Layer, Reactive Streams), thiết lập cấu trúc Cloud Firestore & kiểm soát bảo mật Firebase Security Rules. |
| **5** | **Trương Tuấn Hải** | `2351170590` | **Thành viên / Cloud Research & Documentation** | Nghiên cứu nền tảng Google Firebase (Auth & Storage), xây dựng Slide thuyết trình nhóm, viết tài liệu hướng dẫn Setup & biên soạn Báo cáo Kỹ thuật. |

---

## 📑 MỤC LỤC BỘ SLIDE
- **Slide 1:** Trang Tiêu đề & Danh sách Nhóm thực hiện
- **Slide 2:** 4 Thành phần Cốt lõi của Hệ thống Quản lý Tài liệu
- **Slide 3:** Các Điểm nghẽn của Hạ tầng Truyền thống (Local / On-Premise)
- **Slide 4:** Lựa chọn Mô hình Cloud & So sánh Giải pháp (AWS vs Azure vs Firebase)
- **Slide 5:** Sơ đồ Kiến trúc Hệ thống Hybrid Cloud (Local-First + Firebase)
- **Slide 6:** Mô tả Luồng Dữ liệu Đồng bộ 2 Chiều (Data Flow)
- **Slide 7:** Đánh giá Tác động: Bảo mật, Chi phí và Hiệu suất
- **Slide 8:** Tìm hiểu về Nền tảng Google Firebase (Hệ sinh thái BaaS)
- **Slide 9:** Quy trình Setup Firebase cho Flutter theo chuẩn Google (`flutterfire`)
- **Slide 10:** Cấu hình Dự án với Tài khoản Nhóm thực tế (`study-document-cloud`)
- **Slide 11:** Mã nguồn Tích hợp Đăng nhập Google & Tải tệp lên Storage
- **Slide 12:** Tổng kết, Demo & Hỏi đáp (Q&A)

---

### 🖥️ SLIDE 1: TRANG TIÊU ĐỀ & GIỚI THIỆU NHÓM
- **Tiêu đề lớn:** PHƯƠNG ÁN TÍCH HỢP CLOUD CHO HỆ THỐNG QUẢN LÝ TÀI LIỆU HỌC TẬP
- **Tiêu đề phụ:** Ứng dụng Nền tảng Google Firebase & Kiến trúc Hybrid Local-First
- **Thông tin nhóm:**
  - Nhóm sinh viên thực hiện: Phạm Văn Hưng, Trịnh Trung Kiên, Đỗ Việt Tiến, Cao Đức Đạo, Trương Tuấn Hải
  - Dự án GitHub: `pvhung2112/cloud_study_document_app`
- **Gợi ý hình ảnh:** Logo Flutter kết hợp logo Firebase Cloud, hình minh họa tài liệu học tập và đám mây kết nối.
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Kính chào Thầy/Cô và các bạn. Hôm nay nhóm em xin trình bày phương án chuyển đổi và tích hợp điện toán đám mây cho ứng dụng Quản lý Tài liệu Học tập. Mục tiêu là giúp sinh viên truy cập bài giảng, nộp bài tập và đồng bộ dữ liệu mọi lúc mọi nơi một cách an toàn và bảo mật."*

---

### 🖥️ SLIDE 2: 4 THÀNH PHẦN CỐT LÕI CỦA ỨNG DỤNG QUẢN LÝ TÀI LIỆU
- **Nội dung chính:**
  1. **Frontend:** Giao diện Flutter đa nền tảng, thiết kế bo góc mềm mại theo ngôn ngữ Cashew, kho tài liệu 3 tabs và thanh điều hướng sidebar.
  2. **Backend:** Tầng xử lý logic nghiệp vụ cục bộ tại máy khách, phân loại tài liệu, quản lý cờ đồng bộ `isSynced` và kết nối REST API.
  3. **Database:** CSDL có cấu trúc quản lý metadata tài liệu (tiêu đề, môn học, deadline, tags) với cơ chế Reactive Streams phản hồi tức thì.
  4. **File Storage:** Lưu trữ các tệp tin bài giảng PDF, slide bài tập DOCX/ZIP dung lượng lớn, liên kết với đám mây.
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Hệ thống quản lý tài liệu được phân tách rõ ràng thành 4 khối chức năng: Giao diện người dùng mượt mà, Logic nghiệp vụ client-side, CSDL cấu trúc quản lý metadata và Kho lưu trữ chuyên biệt cho các tệp bài giảng nặng."*

---

### 🖥️ SLIDE 3: ĐIỂM NGHẼN CỦA HẠ TẦNG TRUYỀN THỐNG
- **Hạn chế của mô hình Offline cục bộ:**
  - Mất mát dữ liệu hoàn toàn nếu hỏng máy hoặc nhiễm virus (SPOF).
  - Không thể đồng bộ qua lại giữa laptop và điện thoại khi đi học.
  - Nguy cơ tràn bộ nhớ điện thoại do lưu nhiều file slide nặng.
- **Rào cản nếu tự dựng Server riêng:**
  - Chi phí phần cứng, tiền điện, IP tĩnh quá đắt đỏ cho sinh viên.
  - Sập server vào mùa cao điểm thi cử do nghẽn băng thông.
  - Khó kiểm soát an ninh mạng và vá lỗ hổng bảo mật.
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Nếu chỉ lưu trữ cục bộ, sinh viên đối mặt với nguy cơ mất trắng tài liệu khi hỏng máy. Còn nếu tự dựng máy chủ riêng thì chi phí và công tác vận hành là bất khả thi. Vì vậy, chuyển dịch lên Đám mây là giải pháp tất yếu."*

---

### 🖥️ SLIDE 4: LỰA CHỌN MÔ HÌNH CLOUD & SO SÁNH GIẢI PHÁP
- **Mô hình triển khai:** **Hybrid Cloud** (Kết hợp ưu điểm phản hồi tức thì của Local-First và tính sẵn sàng của Public Cloud).
- **So sánh 3 nền tảng:**
  - AWS (S3 + Cognito): Mạnh mẽ nhưng SDK cho Flutter cồng kềnh, cấu hình phức tạp.
  - Azure (Blob Storage): Phù hợp doanh nghiệp Microsoft, ít tối ưu cho mobile/Flutter.
  - **Google Firebase:** Hỗ trợ Flutter số 1 thế giới (FlutterFire), tích hợp sẵn Google Sign-In, miễn phí trọn đời gói Spark Plan (1GB DB, 5GB File Storage).
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Nhóm đã phân tích và lựa chọn Google Firebase vì tính tích hợp sâu nhất với Flutter, hỗ trợ đăng nhập Google sẵn có và gói miễn phí trọn đời hoàn toàn phù hợp với ứng dụng của sinh viên."*

---

### 🖥️ SLIDE 5: SƠ ĐỒ KIẾN TRÚC TÍCH HỢP CLOUD FIREBASE
- **Hình ảnh trình chiếu:** Sơ đồ kiến trúc `cloud_architecture_diagram.jpg`
- **Các tầng kiến trúc:**
  - Tầng Client (Local-First): Flutter App, Local DAO, SQLite, Reactive Streams.
  - Tầng Đám mây (Firebase Cloud Services):
    - Firebase Authentication (Google OAuth 2.0).
    - Cloud Firestore (NoSQL Collection `study_documents`).
    - Firebase Cloud Storage (Bucket chứa tệp nhị phân `/study_docs/{userId}/`).
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Kiến trúc của ứng dụng gồm 2 phần tương hỗ: Phía người dùng hoạt động theo chuẩn Local-First đảm bảo tốc độ cao nhất, và phía đám mây Firebase đảm nhiệm 3 vai trò: Xác thực tài khoản Google, CSDL đám mây Firestore và Lưu trữ tệp Storage."*

---

### 🖥️ SLIDE 6: MÔ TẢ LUỒNG DỮ LIỆU ĐỒNG BỘ 2 CHIỀU (DATA FLOW)
- **Quy trình 5 bước:**
  1. Người dùng thêm tài liệu mới kèm tệp ➔ Ghi vào CSDL cục bộ ngay tức thì (0ms).
  2. Đẩy tác vụ vào hàng đợi `SyncQueue`.
  3. Khi có mạng, tệp tài liệu được tải lên Firebase Cloud Storage ➔ Nhận về Download URL.
  4. Đẩy Metadata lên Cloud Firestore qua REST API ➔ Đánh dấu `isSynced = true`.
  5. Đồng bộ kéo (Pull): Tự động cập nhật tài liệu mới từ Cloud về các thiết bị khác theo nguyên tắc *Last-Write-Wins (LWW)*.
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Luồng dữ liệu được thiết kế thông minh: luôn lưu vào máy trước để trải nghiệm không bị gián đoạn, sau đó tiến trình đồng bộ nền sẽ tự động tải file lên Storage và cập nhật Firestore."*

---

### 🖥️ SLIDE 7: ĐÁNH GIÁ TÁC ĐỘNG (BẢO MẬT, CHI PHÍ, HIỆU SUẤT)
- **Bảo mật:**
  - Mã hóa 100% dữ liệu truyền qua HTTPS và lưu trữ AES-256.
  - Firebase Security Rules đảm bảo người dùng chỉ được xem/sửa tài liệu của mình.
- **Chi phí:**
  - 0 VNĐ nhờ gói Spark Plan miễn phí 1GB Firestore và 5GB Cloud Storage.
- **Hiệu suất:**
  - 0ms phản hồi giao diện nhờ Local-First.
  - Tốc độ tải tệp cực nhanh nhờ mạng CDN toàn cầu của Google.
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Sau khi tích hợp Cloud, dữ liệu được bảo mật an toàn tuyệt đối, chi phí vận hành bằng 0 đồng và hiệu suất ứng dụng luôn đạt tốc độ tối đa."*

---

### 🖥️ SLIDE 8: TÌM HIỂU VỀ NỀN TẢNG GOOGLE FIREBASE
- **Khái niệm:** Nền tảng Backend-as-a-Service (BaaS) hàng đầu thế giới của Google.
- **Các thành phần cốt lõi sử dụng trong dự án:**
  - **Firebase Authentication:** Quản lý phiên đăng nhập và định danh người dùng qua tài khoản Google.
  - **Cloud Firestore:** Cơ sở dữ liệu NoSQL lưu trữ tài liệu phân tán dạng Collections & Documents.
  - **Cloud Storage:** Lưu trữ an toàn các tệp tin slide PDF, tài liệu DOCX của sinh viên.
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Firebase là giải pháp BaaS hoàn chỉnh của Google, giúp nhóm phát triển đầy đủ tính năng đám mây chất lượng cao mà không cần tốn nhiều tháng để tự viết server backend."*

---

### 🖥️ SLIDE 9: QUY TRÌNH SETUP THEO TÀI LIỆU CHÍNH THỨC CỦA GOOGLE
- **Tham khảo:** [https://firebase.google.com/docs/flutter/setup?hl=vi](https://firebase.google.com/docs/flutter/setup?hl=vi)
- **Các bước thiết lập tự động với FlutterFire CLI:**
  ```bash
  # 1. Cài đặt Firebase CLI
  npm install -g firebase-tools

  # 2. Đăng nhập Google
  firebase login

  # 3. Kích hoạt FlutterFire CLI
  dart pub global activate flutterfire_cli

  # 4. Cấu hình tự động dự án Flutter
  flutterfire configure --project=study-document-cloud
  ```
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Theo chuẩn của Google, việc tích hợp vào Flutter hiện nay được tự động hóa hoàn toàn thông qua FlutterFire CLI, tự sinh file firebase_options.dart chứa toàn bộ cấu hình nền tảng."*

---

### 🖥️ SLIDE 10: CẤU HÌNH DỰ ÁN VỚI TÀI KHOẢN NHÓM THỰC TẾ
- **Thông tin Dự án nhóm:**
  - Project ID: `study-document-cloud`
  - Tài khoản Quản trị: `phamvanhung21122004@gmail.com`
  - Cấu hình Authentication: Kích hoạt nhà cung cấp Google Sign-In.
  - Vị trí máy chủ: `asia-southeast1` (Singapore) cho độ trễ kết nối thấp nhất.
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Nhóm đã triển khai thực tế trên Firebase Console với tên dự án study-document-cloud, đặt máy chủ tại Singapore để tối ưu tốc độ truy cập cho sinh viên tại Việt Nam."*

---

### 🖥️ SLIDE 11: MÃ NGUỒN TÍCH HỢP AUTH & STORAGE
- **Xác thực Google Sign-In:** Sử dụng `GoogleAuthProvider.credential` kết hợp `FirebaseAuth.instance.signInWithCredential`.
- **Tải tệp tin lên Storage:** Phân quyền theo UID người dùng: `FirebaseStorage.instance.ref('study_docs/${user.uid}/$name').putFile(file)`.
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Mã nguồn Flutter được cấu trúc rõ ràng trong tầng struct, đảm bảo mỗi người dùng có một thư mục riêng biệt trên Cloud Storage và dữ liệu được bảo vệ an toàn."*

---

### 🖥️ SLIDE 12: TỔNG KẾT & KẾT QUẢ ĐẠT ĐƯỢC
- **Kết quả nghiệm thu:**
  - Hoàn thành đầy đủ các yêu cầu phân tích kiến trúc, điểm nghẽn, lựa chọn cloud, luồng dữ liệu và đánh giá tác động.
  - Ứng dụng chạy mượt mà trên Web và Windows Desktop.
  - Toàn bộ mã nguồn, báo cáo kỹ thuật và slide thuyết trình đã được lưu trữ công khai tại GitHub: [https://github.com/pvhung2112/cloud_study_document_app](https://github.com/pvhung2112/cloud_study_document_app).
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Nhóm xin chân thành cảm ơn Thầy/Cô và các bạn đã chú ý lắng nghe bài thuyết trình. Nhóm rất mong nhận được câu hỏi và ý kiến đóng góp!"*
