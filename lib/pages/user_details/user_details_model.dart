// lib/pages/user_details_model.dart

class UserDetailsModel {
  double totalSpend;
  double totalIncome;
  double currentMonthSpend;
  Map<String, Map<String, dynamic>> incomeList;
  Map<String, Map<String, dynamic>> spendList;

  UserDetailsModel({
    required this.totalSpend,
    required this.totalIncome,
    required this.currentMonthSpend,
    required this.incomeList,
    required this.spendList,
  });

  factory UserDetailsModel.fromMap(Map<dynamic, dynamic> data) {
    return UserDetailsModel(
      totalSpend: data['total_spend']?.toDouble() ?? 0.0,
      totalIncome: data['total_income']?.toDouble() ?? 0.0,
      currentMonthSpend: data['current_month_spend']?.toDouble() ?? 0.0,
      incomeList: (data['income_list'] as Map<dynamic, dynamic>?)?.map(
            (key, value) => MapEntry(key as String, Map<String, dynamic>.from(value)),
          ) ??
          {},
      spendList: (data['spend_list'] as Map<dynamic, dynamic>?)?.map(
            (key, value) => MapEntry(key as String, Map<String, dynamic>.from(value)),
          ) ??
          {},
    );
  }
}
