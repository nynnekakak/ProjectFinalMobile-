import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  // Sử dụng khóa nhất quán cho userId
  static const _userIdKey = 'userId'; // Đổi khóa thành 'userId'

  // Lưu userId
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId); // Sử dụng khóa 'userId'
    /// Lấy userId đã lưu
    ///
    /// Trả về null nếu không có userId được lưu.
    ///
    /// Trả về userId đã lưu dưới dạng String.
  }

  // Lấy userId đã lưu
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey); // Sử dụng khóa 'userId'
  }

  // Xóa userId khi người dùng đăng xuất
  Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey); // Sử dụng khóa 'userId'
  }
}
