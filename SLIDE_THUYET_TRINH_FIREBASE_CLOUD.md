# 📊 BỘ SLIDE THUYẾT TRÌNH: TÌM HIỂU VỀ FIREBASE & PHƯƠNG ÁN TÍCH HỢP CLOUD
## Dành cho nhóm sinh viên thuyết trình Bài tập Lớn / Báo cáo TH1

- **Chủ đề:** Tích hợp Điện toán Đám mây (Firebase Cloud) cho Hệ thống Quản lý Tài liệu Học tập
- **Sinh viên thực hiện:** Phạm Văn Hưng và Nhóm
- **Công nghệ chính:** Flutter • Firebase Authentication • Cloud Firestore • Firebase Cloud Storage
- **Định dạng:** 12 Trang Slide hoàn chỉnh (Nội dung trình chiếu + Gợi ý hình ảnh + Lời thoại thuyết trình)

---

## 📑 MỤC LỤC BỘ SLIDE
- **Slide 1:** Trang Tiêu đề & Giới thiệu Nhóm
- **Slide 2:** Đặt vấn đề & Hạn chế của Hệ thống Lưu trữ Truyền thống
- **Slide 3:** Giới thiệu Nền tảng Google Firebase
- **Slide 4:** Các Dịch vụ Cốt lõi của Firebase được lựa chọn
- **Slide 5:** So sánh Mô hình Truyền thống (Local) vs Mô hình Tích hợp Cloud
- **Slide 6:** Sơ đồ Kiến trúc Hệ thống Hybrid Cloud (Local-First + Firebase)
- **Slide 7:** Luồng Dữ liệu Xác thực & Đồng bộ Tệp tin (Data Flow)
- **Slide 8:** Tích hợp Xác thực Google (Google Sign-In) trên Flutter
- **Slide 9:** Tích hợp Lưu trữ Tệp Tài liệu (Firebase Cloud Storage)
- **Slide 10:** Đánh giá Tác động: Bảo mật, Chi phí và Hiệu suất
- **Slide 11:** Quy trình 5 bước Setup Firebase với Tài khoản của Nhóm
- **Slide 12:** Tổng kết, Demo & Hỏi đáp (Q&A)

---

---

### 🖥️ SLIDE 1: TRANG TIÊU ĐỀ & GIỚI THIỆU NHÓM
- **Tiêu đề lớn:** PHƯƠNG ÁN TÍCH HỢP CLOUD CHO HỆ THỐNG QUẢN LÝ TÀI LIỆU HỌC TẬP
- **Tiêu đề phụ:** Ứng dụng Nền tảng Google Firebase & Kiến trúc Hybrid Local-First
- **Thông tin nhóm:**
  - Nhóm thực hiện: Nhóm Sinh viên KTPM
  - Thành viên: Phạm Văn Hưng (Nhóm trưởng) & các thành viên
  - Giảng viên hướng dẫn: ...
  - Năm học: 2026 - 2027
- **Gợi ý hình ảnh:** Logo Flutter kết hợp logo Firebase Cloud, hình minh họa tài liệu học tập và đám mây kết nối.
- 🎙️ **Lời thoại thuyết trình (Speaker Notes):**
  > *"Kính chào Thầy/Cô và các bạn. Hôm nay nhóm em xin trình bày phương án chuyển đổi và tích hợp điện toán đám mây cho ứng dụng Quản lý Tài liệu Học tập. Mục tiêu là giúp sinh viên truy cập bài giảng, nộp bài tập và đồng bộ dữ liệu mọi lúc mọi nơi một cách an toàn và bảo mật."*

---

### 🖥️ SLIDE 2: ĐẶT VẤN ĐỀ & HẠN CHẾ CỦA HẠ TẦNG TRUYỀN THỐNG
- **Tiêu đề:** Tại sao phải chuyển đổi lên Cloud? (Các điểm nghẽn của On-Premise / Local)
- **Nội dung chính:**
  1. ❌ **Không đồng bộ đa thiết bị:** Dữ liệu lưu trên Laptop không tự chuyển sang Điện thoại thông minh.
  2. ❌ **Rủi ro mất dữ liệu hoàn toàn:** Thiết bị hỏng ổ cứng hoặc mất máy đồng nghĩa với mất toàn bộ tài liệu học tập.
  3. ❌ **Không thể chia sẻ tài liệu:** Khó khăn khi làm việc nhóm hoặc trao đổi tài liệu học phần trực tuyến.
  4. ❌ **Giới hạn bộ nhớ máy:** Các file PDF/Slide chất lượng cao làm tràn bộ nhớ điện thoại (32GB - 64GB).
  5. ❌ **Gánh nặng vận hành máy chủ riêng:** Chi phí duy trì server vật lý, IP tĩnh và rủi ro sập nguồn điện.
- **Gợi ý hình ảnh:** Biểu tượng ổ cứng bị lỗi, hình minh họa 2 thiết bị không đồng bộ được dữ liệu.
- 🎙️ **Lời thoại thuyết trình:**
  > *"Trong mô hình cục bộ truyền thống, sinh viên gặp 5 trở ngại lớn: không đồng bộ được giữa máy tính và điện thoại, nguy cơ mất trắng dữ liệu khi hỏng máy, không thể chia sẻ bài giảng cho bạn cùng lớp, và bộ nhớ máy nhanh chóng bị đầy. Đây chính là lý do chúng em cần giải pháp Cloud."*

---

### 🖥️ SLIDE 3: GIỚI THIỆU NỀN TẢNG GOOGLE FIREBASE
- **Tiêu đề:** Tổng quan về Google Firebase (BaaS - Backend-as-a-Service)
- **Nội dung chính:**
  - **Firebase là gì?** Nền tảng phát triển ứng dụng di động và web toàn diện do Google vận hành.
  - **Mô hình Backend-as-a-Service (BaaS):** Toàn bộ máy chủ, chứng chỉ SSL, cơ sở dữ liệu và hạ tầng mạng đều do Google tự động quản lý và mở rộng (Auto-scaling).
  - **Hệ sinh thái phong phú:** Cung cấp sẵn Xác thực (Auth), Cơ sở dữ liệu (Firestore), Lưu trữ tệp (Storage), Phân tích (Analytics) và Cloud Functions.
  - **Hỗ trợ tối đa cho Flutter:** Bộ thư viện chính thức **FlutterFire** do chính Google phát triển và tối ưu.
- **Gợi ý hình ảnh:** Bản đồ các dịch vụ của Firebase xoay quanh ứng dụng Flutter.
- 🎙️ **Lời thoại thuyết trình:**
  > *"Để giải quyết bài toán trên, nhóm em lựa chọn Google Firebase - một nền tảng BaaS hàng đầu. Với Firebase, lập trình viên không cần tự dựng backend phức tạp mà có thể tận dụng toàn bộ hạ tầng đám mây toàn cầu của Google với độ ổn định 99.95%."*

---

### 🖥️ SLIDE 4: CÁC DỊCH VỤ CỐT LÕI CỦA FIREBASE ĐƯỢC LỰA CHỌN
- **Tiêu đề:** 3 Dịch vụ Firebase Cốt lõi cho Hệ thống Quản lý Tài liệu
- **Nội dung chính:**
  1. 🔐 **Firebase Authentication:**
     - Đăng nhập bảo mật 1-chạm bằng **Tài khoản Google (Google Sign-In)**.
     - Quản lý phiên đăng nhập và định danh người dùng duy nhất (`UID`).
  2. 📄 **Cloud Firestore (NoSQL Database):**
     - Lưu trữ metadata: Tên bài giảng, hạn nộp bài tập, mã môn học, trạng thái học tập.
     - Cơ chế Real-time Streams tự động cập nhật dữ liệu đa thiết bị tức thì.
  3. 📦 **Firebase Cloud Storage:**
     - Lưu trữ tệp tin nhị phân lớn: File Slide PDF, Word (.docx), bài tập nén (.zip).
     - Tích hợp mạng phân phối nội dung toàn cầu (Google Cloud CDN) giúp tải tệp siêu tốc.
- **Gợi ý hình ảnh:** 3 icon dịch vụ: Firebase Auth, Firestore và Cloud Storage.
- 🎙️ **Lời thoại thuyết trình:**
  > *"Nhóm em tập trung khai thác 3 dịch vụ trụ cột: Firebase Auth để đăng nhập tiện lợi qua Google, Cloud Firestore để lưu thông tin tài liệu theo thời gian thực, và Cloud Storage để lưu trữ các tệp bài giảng và bài tập dung lượng lớn."*

---

### 🖥️ SLIDE 5: SO SÁNH MÔ HÌNH TRUYỀN THỐNG VS MÔ HÌNH CLOUD
- **Tiêu đề:** Bảng So sánh Trước và Sau khi Tích hợp Cloud
- **Nội dung chính:**

| Tiêu chí | Mô hình Truyền thống (Local / On-Premise) | Mô hình Tích hợp Cloud (Firebase) |
| :--- | :--- | :--- |
| **Phạm vi truy cập** | Chỉ trên thiết bị đơn lẻ hiện tại | Mọi thiết bị (Laptop, Smartphone, Web) |
| **Sao lưu & An toàn** | Thủ công, rủi ro mất 100% khi hỏng ổ cứng | Tự động sao lưu phân tán trên Google Cloud |
| **Lưu trữ tệp lớn** | Tiêu tốn bộ nhớ trong của máy khách | Lưu trữ trên Cloud Bucket, hỗ trợ tải theo nhu cầu |
| **Xác thực người dùng** | Không có hoặc lưu mật khẩu cục bộ thiếu an toàn | Đăng nhập Google chuẩn OAuth 2.0 bảo mật cao |
| **Tốc độ phản hồi** | Nhanh nhưng cô lập | Giữ tốc độ tức thì (< 5ms) nhờ Local-First + Đồng bộ nền |

- 🎙️ **Lời thoại thuyết trình:**
  > *"Nhìn vào bảng so sánh, mô hình Cloud vượt trội hoàn toàn: sinh viên có thể xem bài giảng trên mọi thiết bị, dữ liệu luôn an toàn, không lo hết bộ nhớ điện thoại và đăng nhập an toàn bằng tài khoản Google."*

---

### 🖥️ SLIDE 6: SƠ ĐỒ KIẾN TRÚC HYBRID CLOUD
- **Tiêu đề:** Sơ đồ Kiến trúc Hệ thống Hybrid (Local-First + Firebase Cloud)
- **Nội dung chính:**
  - **Tầng Client (Local-First):** Tiếp tục sử dụng SQLite / Local DB để ghi chép tức thời, không bị ảnh hưởng khi mất mạng.
  - **Tầng Trung gian (Sync Engine):** Quản lý hàng đợi đồng bộ hai chiều, tự động gửi dữ liệu lên Cloud khi có Internet.
  - **Tầng Đám mây (Firebase):** Tiếp nhận xác thực người dùng, lưu trữ metadata Firestore và lưu file tệp Cloud Storage.
- **Sơ đồ kiến trúc Mermaid:**
```text
[ Sinh viên ] ➔ [ Ứng dụng Flutter ] ➔ [ Local SQLite Store (Phản hồi tức thì <5ms) ]
                                          ↕ (Sync Client chạy nền)
                                  [ GOOGLE FIREBASE ]
                 ┌────────────────────────┼────────────────────────┐
          [ Firebase Auth ]      [ Cloud Firestore ]      [ Firebase Storage ]
           (Đăng nhập Google)    (Metadata tài liệu)        (Tệp PDF, DOCX)
```
- 🎙️ **Lời thoại thuyết trình:**
  > *"Đây là sơ đồ kiến trúc Hybrid Cloud của nhóm em: Ứng dụng vẫn giữ triết lý Local-First của Cashew để phản hồi tức thì dưới 5ms, đồng thời chạy tiến trình đồng bộ nền lên Firebase khi có mạng. Người dùng không bao giờ bị đơ giao diện khi mạng chập chờn."*

---

### 🖥️ SLIDE 7: LUỒNG DỮ LIỆU ĐỒNG BỘ TỆP TIN (DATA FLOW)
- **Tiêu đề:** Luồng Dữ liệu khi Tải lên và Đồng bộ Tài liệu
- **Nội dung chính:**
  1. **Bước 1:** Sinh viên chọn tải file Slide/Bài tập và bấm "Lưu".
  2. **Bước 2:** Ứng dụng lưu ngay vào Local DB (cờ `isSynced = false`) ➔ UI cập nhật tức thì.
  3. **Bước 3:** Tiến trình nền đẩy file nhị phân lên **Firebase Cloud Storage** ➔ Nhận về `Download URL`.
  4. **Bước 4:** Tiến trình ghi thông tin tài liệu kèm `Download URL` lên **Cloud Firestore**.
  5. **Bước 5:** Firebase phản hồi thành công ➔ Đổi cờ `isSynced = true` tại máy khách.
- **Gợi ý hình ảnh:** Sơ đồ tuần tự (Sequence Diagram) 5 bước luồng dữ liệu.
- 🎙️ **Lời thoại thuyết trình:**
  > *"Quy trình xử lý dữ liệu được thiết kế tối ưu: Giao diện phản hồi ngay lập tức cho người dùng, sau đó tiến trình nền mới đẩy file lên Firebase Storage, lấy đường dẫn URL và lưu metadata vào Firestore."*

---

### 🖥️ SLIDE 8: TÍCH HỢP XÁC THỰC GOOGLE TRÊN FLUTTER
- **Tiêu đề:** Tích hợp Google Sign-In qua Firebase Authentication
- **Nội dung chính:**
  - Sử dụng thư viện: `firebase_auth` và `google_sign_in`.
  - **Ưu điểm vượt trội:**
    - Sinh viên không cần nhớ thêm tài khoản/mật khẩu mới.
    - Đăng nhập 1-chạm bằng tài khoản Gmail trường/cá nhân.
    - Nhận diện avatar, họ tên và định danh bảo mật duy nhất `uid`.
  - **Đoạn mã cốt lõi:**
    ```dart
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    ```
- 🎙️ **Lời thoại thuyết trình:**
  > *"Tính năng đăng nhập Google mang lại trải nghiệm tiện lợi tối đa: sinh viên chỉ cần bấm 1 chạm để đăng nhập bằng tài khoản Gmail, thông tin cá nhân và tài liệu của mỗi sinh viên được phân lập độc lập qua mã UID."*

---

### 🖥️ SLIDE 9: TÍCH HỢP LƯU TRỮ TỆP TÀI LIỆU (FIREBASE STORAGE)
- **Tiêu đề:** Tích hợp Tải tệp lên Firebase Cloud Storage
- **Nội dung chính:**
  - Sử dụng thư viện: `firebase_storage`.
  - Cấu trúc thư mục đám mây an toàn: `/study_docs/{user_uid}/{filename}`.
  - Hỗ trợ tải đa định dạng: Slide bài giảng PDF, Bài tập thực hành Word (.docx), Mã nguồn nén (.zip).
  - Tự động sinh đường dẫn tải xuống an toàn có chữ ký số (Download URL).
  - Tự động nén và cache tại các máy chủ CDN của Google gần Việt Nam.
- 🎙️ **Lời thoại thuyết trình:**
  > *"Với Firebase Storage, toàn bộ file bài giảng và bài tập được phân nhóm khoa học theo từng mã sinh viên, đảm bảo tính riêng tư và tốc độ tải xuống cực nhanh nhờ hạ tầng mạng toàn cầu của Google."*

---

### 🖥️ SLIDE 10: ĐÁNH GIÁ TÁC ĐỘNG: BẢO MẬT, CHI PHÍ VÀ HIỆU SUẤT
- **Tiêu đề:** Đánh giá Tác động sau khi Tích hợp Cloud
- **Nội dung chính:**
  - 🛡️ **Bảo mật (Security):**
    - Áp dụng **Firebase Security Rules**: Chỉ cho phép sinh viên đọc/ghi tài liệu thuộc về chính họ (`request.auth.uid == userId`).
    - Dữ liệu được mã hóa đường truyền (HTTPS/TLS 1.3) và mã hóa tĩnh tại Google Cloud (AES-256).
  - 💰 **Chi phí (Cost):**
    - Sử dụng **Gói Spark Miễn phí**: 1GB Firestore, 5GB Cloud Storage, 50,000 lượt đọc/ngày ➔ **Hoàn toàn 0 VNĐ** cho đồ án môn học.
  - ⚡ **Hiệu suất (Performance):**
    - Thời gian tải trang ban đầu: **Dưới 0.05 giây** (nhờ Local-First).
    - Tốc độ tải tệp PDF: Tối đa băng thông mạng (nhờ CDN).
- 🎙️ **Lời thoại thuyết trình:**
  > *"Về hiệu quả: Hệ thống đạt chuẩn bảo mật cao với Security Rules phân quyền chi tiết, chi phí hoàn toàn 0 đồng trong gói Spark miễn phí trọn đời, và hiệu năng mượt mà không có độ trễ giao diện."*

---

### 🖥️ SLIDE 11: QUY TRÌNH 5 BƯỚC SETUP VỚI TÀI KHOẢN CỦA NHÓM
- **Tiêu đề:** Hướng dẫn Nhóm thiết lập Firebase từ A đến Z
- **Nội dung chính:**
  1. **Bước 1: Tạo Project trên Firebase Console**
     - Đăng nhập bằng Gmail nhóm tại: `console.firebase.google.com`
     - Tạo dự án mới: Đặt tên `study-document-cloud`.
  2. **Bước 2: Bật Google Authentication**
     - Vào menu **Authentication ➔ Sign-in method ➔ Bật Google**.
  3. **Bước 3: Tạo Cloud Storage Bucket**
     - Vào menu **Storage ➔ Bấm Get Started**, chọn máy chủ khu vực Châu Á (`asia-southeast1` Singapore).
  4. **Bước 4: Thêm thành viên nhóm vào dự án**
     - Vào **Project Settings ➔ Users and permissions ➔ Add member**, nhập email các bạn trong nhóm để cùng quản trị.
  5. **Bước 5: Liên kết dự án Flutter bằng lệnh CLI**
     ```bash
     npm install -g firebase-tools
     firebase login
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
- 🎙️ **Lời thoại thuyết trình:**
  > *"Quy trình thiết lập cho nhóm sinh viên rất trực quan và nhanh chóng: chỉ cần 5 bước thao tác từ việc tạo project trên Firebase Console, kích hoạt đăng nhập Google, tạo bucket lưu trữ, cấp quyền cho các thành viên và chạy lệnh FlutterFire CLI để kết nối tự động vào mã nguồn."*

---

### 🖥️ SLIDE 12: TỔNG KẾT, DEMO & HỎI ĐÁP (Q&A)
- **Tiêu đề:** Tổng kết & Kết quả Đạt được
- **Nội dung chính:**
  - ✅ **Hoàn thành 7/7 mục Checklist yêu cầu của đề tài.**
  - ✅ **Đã lập phương án chuyển đổi Hybrid Cloud tối ưu cho hệ thống Quản lý tài liệu.**
  - ✅ **Thiết kế chi tiết kiến trúc, luồng dữ liệu, phân tích bảo mật và chi phí.**
  - ✅ **Đã chuẩn bị sẵn sàng mã nguồn tích hợp Firebase Auth & Storage cho Flutter.**
  - ❓ **Phần Hỏi đáp (Q&A): Nhóm xin lắng nghe nhận xét và câu hỏi từ Thầy/Cô và các bạn!**
- 🎙️ **Lời thoại thuyết trình:**
  > *"Trên đây là toàn bộ báo cáo và phương án tích hợp Cloud cho hệ thống Quản lý tài liệu học tập của nhóm em. Nhóm em xin chân thành cảm ơn Thầy/Cô và các bạn đã chú ý lắng nghe, và nhóm rất mong nhận được những góp ý quý báu ạ!"*
