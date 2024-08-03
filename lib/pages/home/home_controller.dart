import 'package:firebase_database/firebase_database.dart';

class HomeController {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  Stream<Map<dynamic, dynamic>> fetchUsersStream() {
    return _databaseReference.onValue.map((event) {
      if (event.snapshot.value != null) {
        var data = event.snapshot.value as Map<dynamic, dynamic>;
        return data;
      } else {
        return {};
      }
    });
  }

  Future<void> addTransaction(String groupName, String userName, String type,
      double amount, String remark) async {
    final userRef = _databaseReference.child('$groupName/$userName');
    final snapshot = await userRef.get();
    if (snapshot.exists) {
      var data = snapshot.value as Map;
      double currentSpend = (data['total_spend'] ?? 0).toDouble();
      double currentIncome = (data['total_income'] ?? 0).toDouble();

      String transactionType = type == 'spend' ? 'spend_list' : 'income_list';
      String totalType = type == 'spend' ? 'total_spend' : 'total_income';
      String totalYearType = type == 'spend' ? 'spend_total' : 'income_total';

      // Get current date and time
      String dateTime = DateTime.now().toIso8601String();

      // Add the new transaction
      await userRef.child('$transactionType/$dateTime').set({
        'amount': amount,
        'remark': remark,
      });

      // Update the total amount
      if (type == 'spend') {
        currentSpend += amount;
        await userRef.update({'total_spend': currentSpend});
      } else {
        currentIncome += amount;
        await userRef.update({'total_income': currentIncome});
      }

      // Update the year-month total
      String year = DateTime.now().year.toString();
      String month = DateTime.now().month.toString().padLeft(2, '0');

      double currentMonthTotal =
          (data[totalYearType]?[year]?[month] ?? 0).toDouble();
      currentMonthTotal += amount;

      await userRef
          .child('$totalYearType/$year')
          .update({month: currentMonthTotal});
    }
  }

  Future<bool> addNewGroup(String groupName) async {
    final groupRef = _databaseReference.child(groupName);
    final snapshot = await groupRef.get();

    if (!snapshot.exists) {
      await groupRef.set({
        'number_of_users': 0,
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addNewUser(String groupName, String userName) async {
    final userRef = _databaseReference.child('$groupName/$userName');
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'total_spend': 0,
        'total_income': 0,
        'current_month_spend': 0, // Initialize current month's spending
        'role': 'user',
        'password': '1234',
        'income_list': {},
        'spend_list': {},
        'income_total': {},
        'spend_total': {},
      });

      final groupRef = _databaseReference.child(groupName);
      final groupSnapshot = await groupRef.get();
      if (groupSnapshot.exists) {
        var groupData = groupSnapshot.value as Map<dynamic, dynamic>;
        int numberOfUsers = (groupData['number_of_users'] ?? 0) as int;
        numberOfUsers++;
        await groupRef.update({'number_of_users': numberOfUsers});
      }

      return true;
    } else {
      return false;
    }
  }
}
