import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:moneyboys/data/Models/spending.dart';
import 'package:moneyboys/data/Models/budget.dart';
import 'package:moneyboys/data/Models/category.dart';
import 'package:intl/intl.dart';

class GeminiService {
  static const String _apiKey =
      'AIzaSyD_fOXxxqQVBaiDgjIiZGmcHR9f4GLY4ss'; // Thay bằng API key của bạn
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-pro', // Sử dụng Gemini Pro cho sinh viên
      apiKey: _apiKey,
    );
  }

  // Phân tích chi tiêu và đưa ra lời khuyên
  Future<String> analyzeSpending(
    List<Spending> spendings,
    List<Budget> budgets,
    List<Category> categories,
  ) async {
    if (spendings.isEmpty) {
      return 'Bạn chưa có giao dịch chi tiêu nào. Hãy bắt đầu ghi chép để tôi có thể hỗ trợ bạn tốt hơn!';
    }

    // Tính toán thống kê
    double totalExpense = 0;
    double totalIncome = 0;
    Map<String, double> categoryExpenses = {};

    for (var spending in spendings) {
      final category = categories.firstWhere(
        (c) => c.id == spending.categoryId,
        orElse: () => Category(
          id: spending.categoryId,
          name: 'Unknown',
          type: 'expense',
          isShared: false,
          createdAt: DateTime.now(),
        ),
      );

      if (category.type == 'expense') {
        totalExpense += spending.amount;
        categoryExpenses[category.name] =
            (categoryExpenses[category.name] ?? 0) + spending.amount;
      } else {
        totalIncome += spending.amount;
      }
    }

    final formatter = NumberFormat('#,###', 'vi_VN');

    final budgetInfo = budgets.isEmpty
        ? 'Chưa có ngân sách được thiết lập'
        : budgets
              .map((b) {
                final categoryName = categories
                    .firstWhere(
                      (c) => c.id == b.categoryId,
                      orElse: () => Category(
                        id: b.categoryId,
                        name: 'Unknown',
                        type: 'expense',
                        isShared: false,
                        createdAt: DateTime.now(),
                      ),
                    )
                    .name;
                return '- $categoryName: ${formatter.format(b.amount)} VND';
              })
              .join('\n');

    String prompt =
        '''
Bạn là một chuyên gia tư vấn tài chính cá nhân thông minh và thân thiện. Hãy phân tích tình hình tài chính sau:

📊 TỔNG QUAN:
- Tổng thu nhập: ${formatter.format(totalIncome)} VND
- Tổng chi tiêu: ${formatter.format(totalExpense)} VND
- Số dư: ${formatter.format(totalIncome - totalExpense)} VND
- Số giao dịch: ${spendings.length}

💰 NGÂN SÁCH:
$budgetInfo

📝 YÊU CẦU:
1. Đánh giá tình hình tài chính hiện tại (tốt/trung bình/cần cải thiện)
2. Đưa ra 3-4 lời khuyên cụ thể để quản lý tài chính tốt hơn
3. Gợi ý về việc tiết kiệm và đầu tư (nếu có thể)
4. Cảnh báo nếu chi tiêu vượt mức an toàn

Hãy trả lời bằng tiếng Việt, ngắn gọn, dễ hiểu, và sử dụng emoji phù hợp.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ??
          'Xin lỗi, tôi không thể phân tích được dữ liệu của bạn lúc này.';
    } catch (e) {
      return 'Lỗi kết nối với AI: ${e.toString()}. Vui lòng kiểm tra API key và kết nối internet.';
    }
  }

  // Tư vấn cho ngân sách cụ thể
  Future<String> adviseBudget(
    Budget budget,
    List<Spending> relatedSpendings,
    List<Category> categories,
  ) async {
    double totalSpent = relatedSpendings.fold(0, (sum, s) => sum + s.amount);

    double percentUsed = (totalSpent / budget.amount) * 100;
    final formatter = NumberFormat('#,###', 'vi_VN');

    final categoryName = categories
        .firstWhere(
          (c) => c.id == budget.categoryId,
          orElse: () => Category(
            id: budget.categoryId,
            name: 'Unknown',
            type: 'expense',
            isShared: false,
            createdAt: DateTime.now(),
          ),
        )
        .name;

    String prompt =
        '''
Bạn là chuyên gia tài chính. Hãy tư vấn cho người dùng về ngân sách sau:

📋 THÔNG TIN NGÂN SÁCH:
- Danh mục: $categoryName
- Tổng ngân sách: ${formatter.format(budget.amount)} VND
- Đã chi tiêu: ${formatter.format(totalSpent)} VND
- Phần trăm sử dụng: ${percentUsed.toStringAsFixed(1)}%
- Số giao dịch: ${relatedSpendings.length}

Hãy:
1. Đánh giá tình trạng sử dụng ngân sách (an toàn/cảnh báo/nguy hiểm)
2. Đưa ra 2-3 lời khuyên cụ thể
3. Gợi ý cách tiết kiệm trong phạm vi ngân sách này

Trả lời ngắn gọn bằng tiếng Việt với emoji phù hợp.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Không thể tạo lời khuyên lúc này.';
    } catch (e) {
      return 'Lỗi: ${e.toString()}';
    }
  }

  // Trả lời câu hỏi chung về tài chính
  Future<String> askQuestion(String question, {String? context}) async {
    String prompt =
        '''
Bạn là trợ lý tài chính cá nhân thông minh. Người dùng hỏi: "$question"

${context != null ? 'BỐI CẢNH:\n$context\n' : ''}

Hãy trả lời:
- Ngắn gọn, dễ hiểu
- Bằng tiếng Việt
- Có ví dụ cụ thể nếu cần
- Sử dụng emoji phù hợp
- Tập trung vào lời khuyên thực tế
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Xin lỗi, tôi không thể trả lời câu hỏi này.';
    } catch (e) {
      return 'Lỗi: ${e.toString()}';
    }
  }

  // Gợi ý tiết kiệm dựa trên thói quen chi tiêu
  Future<String> getSavingTips(
    List<Spending> recentSpendings,
    List<Category> categories,
  ) async {
    if (recentSpendings.isEmpty) {
      return '💡 Hãy bắt đầu ghi chép chi tiêu để tôi có thể đưa ra lời khuyên tiết kiệm phù hợp!';
    }

    Map<String, double> categoryTotals = {};
    for (var spending in recentSpendings) {
      final category = categories.firstWhere(
        (c) => c.id == spending.categoryId,
        orElse: () => Category(
          id: spending.categoryId,
          name: 'Unknown',
          type: 'expense',
          isShared: false,
          createdAt: DateTime.now(),
        ),
      );

      if (category.type == 'expense') {
        categoryTotals[category.name] =
            (categoryTotals[category.name] ?? 0) + spending.amount;
      }
    }

    var sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final formatter = NumberFormat('#,###', 'vi_VN');
    String topExpenses = sortedCategories
        .take(3)
        .map((e) => '- ${e.key}: ${formatter.format(e.value)} VND')
        .join('\n');

    int expenseCount = recentSpendings.where((s) {
      final cat = categories.firstWhere(
        (c) => c.id == s.categoryId,
        orElse: () => Category(
          id: s.categoryId,
          name: 'Unknown',
          type: 'expense',
          isShared: false,
          createdAt: DateTime.now(),
        ),
      );
      return cat.type == 'expense';
    }).length;

    String prompt =
        '''
Phân tích chi tiêu gần đây và đưa ra 3-4 mẹo tiết kiệm cụ thể:

CHI TIÊU NHIỀU NHẤT:
$topExpenses

Tổng $expenseCount giao dịch chi tiêu.

Hãy đưa ra lời khuyên tiết kiệm thực tế, dễ áp dụng bằng tiếng Việt với emoji.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Không thể tạo gợi ý tiết kiệm.';
    } catch (e) {
      return 'Lỗi: ${e.toString()}';
    }
  }

  // Phân tích xu hướng chi tiêu
  Future<String> analyzeTrends(
    List<Spending> spendings,
    List<Category> categories,
    int days,
  ) async {
    if (spendings.isEmpty) {
      return '📊 Chưa có đủ dữ liệu để phân tích xu hướng.';
    }

    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(Duration(days: days));

    var periodSpendings = spendings.where((s) {
      final category = categories.firstWhere(
        (c) => c.id == s.categoryId,
        orElse: () => Category(
          id: s.categoryId,
          name: 'Unknown',
          type: 'expense',
          isShared: false,
          createdAt: DateTime.now(),
        ),
      );
      return s.date.isAfter(startDate) && category.type == 'expense';
    }).toList();

    double total = periodSpendings.fold(0, (sum, s) => sum + s.amount);
    double avgPerDay = total / days;

    final formatter = NumberFormat('#,###', 'vi_VN');

    String prompt =
        '''
Phân tích xu hướng chi tiêu trong $days ngày qua:

📈 THỐNG KÊ:
- Tổng chi tiêu: ${formatter.format(total)} VND
- Trung bình/ngày: ${formatter.format(avgPerDay)} VND
- Số giao dịch: ${periodSpendings.length}

Hãy:
1. Nhận xét về xu hướng chi tiêu
2. So sánh với mức trung bình hợp lý
3. Đưa ra 2-3 lời khuyên

Trả lời ngắn gọn bằng tiếng Việt với emoji.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Không thể phân tích xu hướng.';
    } catch (e) {
      return 'Lỗi: ${e.toString()}';
    }
  }
}
