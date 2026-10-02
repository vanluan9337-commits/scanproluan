# ScanPro – Ứng dụng quét tài liệu cho iPhone (miễn phí, không quảng cáo)

## Tính năng
1. **Quét tài liệu bằng camera**: tự nhận diện cạnh giấy, tự cắt và nắn thẳng phối cảnh, quét nhiều trang liên tiếp.
2. **Nền trắng như máy scan**: 4 chế độ – Màu / Xám / Đen trắng / Gốc (menu góc trên bên trái).
3. **Xuất PDF** lưu trong ứng dụng, xem trước, xoá bằng vuốt trái.
4. **Chia sẻ PDF** sang mọi ứng dụng (Zalo, Mail, Drive, Files…) bằng nút chia sẻ; không giới hạn số lần hay dung lượng. File cũng xuất hiện trong ứng dụng **Tệp > ScanPro**.
5. **Dịch ảnh**: chụp hoặc chọn ảnh → nhận dạng chữ (OCR, tự phát hiện ngôn ngữ) → dịch sang Việt, Anh, Trung, Nhật, Hàn, Pháp, Đức, Tây Ban Nha, Nga, Thái. Dùng bộ dịch của Apple, chạy trên máy, không cần API key, không tốn phí.
6. Không quảng cáo, không thu thập dữ liệu, không yêu cầu mạng (lần đầu dịch một cặp ngôn ngữ iOS có thể hỏi tải gói ngôn ngữ).

Yêu cầu: iPhone dùng **iOS 18 trở lên**.

## Cách tạo file cài đặt (.ipa)
### Cách A – Không cần Mac (GitHub Actions, miễn phí)
1. Tạo tài khoản GitHub, tạo repository mới, tải toàn bộ thư mục dự án này lên (giữ nguyên thư mục `.github`).
2. Vào tab **Actions** → **Build IPA** → **Run workflow**.
3. Khi xong (5–10 phút), mở lần chạy đó → mục **Artifacts** → tải **ScanPro-ipa** → giải nén được `ScanPro.ipa`.

### Cách B – Có Mac
Cài Xcode 16+, mở Terminal tại thư mục dự án: `./build_ipa.sh` → file ở `build/ScanPro.ipa`.

## Cách cài .ipa lên iPhone
File .ipa tạo ra **chưa được ký**, bạn cần ký bằng Apple ID của mình. Chọn một cách:
- **Sideloadly** (Windows/Mac, miễn phí): kết nối iPhone qua cáp → kéo `ScanPro.ipa` vào → nhập Apple ID → Start. Trên iPhone: *Cài đặt > Cài đặt chung > VPN & Quản lý thiết bị* → tin cậy tài khoản; bật *Chế độ nhà phát triển* nếu được hỏi.
- **AltStore** (miễn phí): cài AltServer trên máy tính, rồi mở .ipa bằng AltStore trên iPhone.
- **Xcode** (Mac): mở `ScanPro.xcodeproj` (tạo bằng `xcodegen generate`), chọn Team của bạn, bấm Run.

Lưu ý: Apple ID miễn phí chỉ cho app chạy **7 ngày**, sau đó cần cài lại/làm mới (AltStore tự làm mới được). Muốn dùng lâu dài hoặc đưa lên App Store cần tài khoản Apple Developer (99 USD/năm). Nếu Sideloadly báo trùng Bundle ID, đổi `PRODUCT_BUNDLE_IDENTIFIER` trong `project.yml` thành tên riêng của bạn.

## Hướng dẫn sử dụng
**Quét**: tab *Tài liệu* → **Quét** → đưa camera vào giấy, app tự chụp khi nhận diện khung → quét thêm trang nếu cần → **Lưu**. PDF xuất hiện trong danh sách. Nếu cạnh chưa chuẩn, kéo 4 góc trước khi lưu.
**Đổi chế độ**: nút *Chế độ* bên trái. Giấy tờ in nên dùng *Đen trắng* hoặc *Xám*; tài liệu có hình màu dùng *Màu*.
**Chia sẻ**: mở file → biểu tượng chia sẻ góc phải, hoặc vuốt phải trên dòng file.
**Xoá**: vuốt trái.
**Dịch**: tab *Dịch ảnh* → chọn ngôn ngữ đích → chụp hoặc chọn ảnh → xem bản dịch bên dưới, có thể sửa văn bản nhận dạng rồi bấm *Dịch lại*, hoặc chia sẻ bản dịch.
**Mẹo**: đặt giấy trên nền tối, đủ sáng, tránh bóng tay để nền ra trắng đều.
