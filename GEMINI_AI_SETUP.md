# Hướng dẫn tích hợp Gemini AI vào MoneyBoys App

## 🎯 Tổng quan

Dự án đã được tích hợp **Gemini AI** - trợ lý tài chính thông minh của Google để:
- 📊 Phân tích chi tiêu và đưa ra lời khuyên tài chính cá nhân hóa
- 💰 Tư vấn về ngân sách và cách quản lý tiền hiệu quả
- 📈 Phân tích xu hướng chi tiêu theo thời gian
- 💡 Đề xuất các mẹo tiết kiệm phù hợp với thói quen người dùng

## 🔑 Cách lấy API Key từ Google AI Studio

### Bước 1: Truy cập Google AI Studio
1. Mở trình duyệt và truy cập: https://makersuite.google.com/app/apikey
2. Hoặc tìm kiếm "Google AI Studio" trên Google

### Bước 2: Đăng nhập
- Đăng nhập bằng tài khoản Google của bạn
- Nếu chưa có, hãy tạo tài khoản Google miễn phí

### Bước 3: Tạo API Key
1. Nhấn vào nút **"Create API Key"** hoặc **"Get API Key"**
2. Chọn project Google Cloud của bạn (hoặc tạo mới nếu chưa có)
3. Hệ thống sẽ tạo API Key mới cho bạn
4. **Sao chép** API Key này (có dạng: `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`)

### Bước 4: Bảo mật API Key
⚠️ **LƯU Ý QUAN TRỌNG:**
- **KHÔNG** chia sẻ API Key với người khác
- **KHÔNG** commit API Key lên GitHub hoặc repository công khai
- Giữ API Key an toàn như mật khẩu

## 📝 Cấu hình API Key trong dự án

### Cách 1: Thay trực tiếp trong code (Không khuyến khích)

Mở file `lib/data/services/gemini_service.dart` và thay thế:

```dart
class GeminiService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE'; // <-- Thay ở đây
  // ...
}
```

### Cách 2: Sử dụng Environment Variables (Khuyến khích)

#### 2.1. Tạo file `.env` (cho Flutter)
1. Cài đặt package `flutter_dotenv`:
```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

2. Tạo file `.env` ở thư mục gốc dự án:
```env
GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

3. Thêm `.env` vào `.gitignore`:
```gitignore
.env
```

4. Thêm `.env` vào `pubspec.yaml`:
```yaml
flutter:
  assets:
    - .env
```

5. Sửa `gemini_service.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  // ...
}
```

6. Khởi tạo trong `main.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

## 🚀 Sử dụng AI Assistant

### Trên màn hình Home
- Nhấn nút **"Hỏi AI"** (màu tím) ở góc dưới bên phải
- AI sẽ phân tích tổng quan tình hình tài chính của bạn
- Đưa ra lời khuyên về chi tiêu, tiết kiệm và quản lý ngân sách

### Trên màn hình Budget
- Nhấn nút **"Hỏi AI"** 
- AI sẽ tư vấn cụ thể về các ngân sách của bạn
- Cảnh báo nếu chi tiêu vượt mức và đưa ra giải pháp

### Trên màn hình Spending Chart
- Nhấn nút **"Hỏi AI"**
- AI phân tích xu hướng chi tiêu theo tuần/tháng
- So sánh với mức trung bình và đưa ra nhận xét

## 🎨 Các tính năng AI

### 1. Phân tích chi tiêu tổng quan
- Đánh giá tình hình tài chính (tốt/trung bình/cần cải thiện)
- So sánh thu nhập và chi tiêu
- Đưa ra 3-4 lời khuyên cụ thể

### 2. Tư vấn ngân sách
- Đánh giá việc sử dụng ngân sách (an toàn/cảnh báo/nguy hiểm)
- Gợi ý cách tiết kiệm trong từng danh mục
- Cảnh báo khi chi tiêu vượt mức

### 3. Phân tích xu hướng
- Phân tích chi tiêu theo tuần/tháng
- So sánh với mức trung bình hợp lý
- Dự đoán xu hướng chi tiêu trong tương lai

### 4. Gợi ý tiết kiệm
- Phân tích thói quen chi tiêu
- Đưa ra mẹo tiết kiệm thực tế
- Cá nhân hóa theo từng người dùng

## 🔧 Troubleshooting

### Lỗi: "Không thể kết nối với AI"
**Nguyên nhân:**
- API Key chưa được cấu hình
- API Key không hợp lệ
- Không có kết nối internet

**Giải pháp:**
1. Kiểm tra API Key đã nhập đúng chưa
2. Kiểm tra kết nối internet
3. Thử tạo API Key mới nếu key cũ hết hạn

### Lỗi: "403 Forbidden"
**Nguyên nhân:**
- API Key không có quyền truy cập
- Đã vượt quá giới hạn request

**Giải pháp:**
1. Kiểm tra API Key có được kích hoạt chưa
2. Kiểm tra quota trên Google AI Studio
3. Chờ một lúc nếu đã vượt rate limit

### AI trả lời bằng tiếng Anh
**Giải pháp:**
- Code đã được cấu hình để AI trả lời bằng tiếng Việt
- Nếu vẫn bị, hãy kiểm tra lại prompt trong `gemini_service.dart`

## 📚 Tài liệu tham khảo

- [Google AI Studio](https://makersuite.google.com/)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Flutter Google Generative AI Package](https://pub.dev/packages/google_generative_ai)

## 💡 Lưu ý

1. **Miễn phí**: Gemini API có gói miễn phí với giới hạn request hợp lý
2. **Bảo mật**: Không bao giờ commit API Key lên Git
3. **Hiệu suất**: AI cần kết nối internet để hoạt động
4. **Độ chính xác**: AI đưa ra lời khuyên dựa trên dữ liệu, không phải tư vấn tài chính chính thức

## 📞 Hỗ trợ

Nếu gặp vấn đề, hãy:
1. Kiểm tra lại các bước cấu hình
2. Xem phần Troubleshooting
3. Liên hệ với đội ngũ phát triển

---

**Chúc bạn quản lý tài chính hiệu quả với sự hỗ trợ của AI! 🎉**
