# Ứng dụng Quản lý Tài liệu Học tập theo Kiến trúc Cashew (TH1)

- **Sinh viên:** Phạm Văn Hưng
- **GitHub:** [https://github.com/pvhung2112/study_document_app](https://github.com/pvhung2112/study_document_app)
- **Đề tài:** TH1 - Xây dựng Ứng dụng Quản lý Tài liệu Học tập theo Kiến trúc Cashew

---

## 📌 Tổng quan dự án
Ứng dụng được thiết kế và triển khai áp dụng 100% các nguyên lý kiến trúc của ứng dụng **Cashew**:
- **Local-First Architecture:** Phản hồi tức thời trên bộ nhớ cục bộ, đồng bộ nền 2 chiều qua Sync Client.
- **Phân tách 4 lớp rõ ràng:**
  1. `lib/struct/`: Các thực thể dữ liệu (`StudyDocument`, `StudyCourse`, `StudyGoal`) và các dịch vụ nền (`SyncClient`, `ReminderService`, `StorageService`).
  2. `lib/database/`: Tầng truy xuất dữ liệu độc lập (`DocumentDao`, `CourseDao`, `GoalDao`) với Reactive Streams.
  3. `lib/widgets/`: Giao diện tái sử dụng chuẩn phong cách Cashew (Thanh điều hướng Sidebar viền hồng mượt mà, Thẻ bo góc 16px).
  4. `lib/pages/`: Các màn hình nghiệp vụ (Dashboard, Danh sách 3 Tabs Bài giảng/Bài tập/Tham khảo, Tìm kiếm & Lọc tức thì, Quản lý Môn học & Mục tiêu).
  5. `test/`: Bộ 11 bài kiểm thử tự động đạt chuẩn 100% kiểm thử phân tách logic.

---

## 🚀 Hướng dẫn cài đặt và chạy ứng dụng

```powershell
# 1. Cài đặt các gói phụ thuộc
flutter pub get

# 2. Chạy toàn bộ 11 bài kiểm thử tự động (PASS 100%)
flutter test

# 3. Khởi chạy ứng dụng
flutter run -d chrome
# Hoặc chạy trên Windows Desktop:
flutter run -d windows
```

---

## 📑 Báo cáo chi tiết 5 mục Checklist
Xem chi tiết toàn bộ báo cáo giải trình, sơ đồ kiến trúc Mermaid và sơ đồ luồng dữ liệu DFD tại:
👉 [BAO_CAO_TH1_QUAN_LY_TAI_LIEU_CASHEW.md](./BAO_CAO_TH1_QUAN_LY_TAI_LIEU_CASHEW.md)
