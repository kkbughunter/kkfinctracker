// lib/pages/user_details_controller.dart

import 'package:firebase_database/firebase_database.dart';
import 'user_details_model.dart';

class UserDetailsController {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  Future<UserDetailsModel?> getUserDetails(
      String groupName, String userName) async {
    final userRef = _databaseReference.child('$groupName/$userName');
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      return UserDetailsModel.fromMap(snapshot.value as Map<dynamic, dynamic>);
    } else {
      return null;
    }
  }

  Future<void> addTransaction(
      String groupName, String userName, String type, double amount, String remark) async {
    final userRef = _databaseReference.child('$groupName/$userName');
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      var userData = snapshot.value as Map<dynamic, dynamic>;
      var currentMonthSpend =
          userData['current_month_spend']?.toDouble() ?? 0.0;
      var totalSpend = userData['total_spend']?.toDouble() ?? 0.0;
      var totalIncome = userData['total_income']?.toDouble() ?? 0.0;

      if (type == 'Spend') {
        currentMonthSpend += amount;
        totalSpend += amount;
      } else if (type == 'Income') {
        totalIncome += amount;
      }

      await userRef.update({
        'current_month_spend': currentMonthSpend,
        'total_spend': totalSpend,
        'total_income': totalIncome,
      });

      // Add the transaction to the respective list (income_list or spend_list)
      var transactionList = type == 'Spend'
          ? userData['spend_list'] as Map<dynamic, dynamic>?
          : userData['income_list'] as Map<dynamic, dynamic>?;
      transactionList = transactionList ?? {};

      var transactionKey = DateTime.now().millisecondsSinceEpoch.toString();
      transactionList[transactionKey] = {
        'amount': amount,
        'remark': remark,
      };

      await userRef.update({
        type == 'Spend' ? 'spend_list' : 'income_list': transactionList,
      });
    }
  }
}
