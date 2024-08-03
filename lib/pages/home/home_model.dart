import 'package:firebase_database/firebase_database.dart';

class HomeModel {
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child('groups');

  Future<dynamic> getUsers() async {
    final snapshot = await ref.get();
    return snapshot.value;
  }

  void updateUserTransaction(String groupName, String userName, String type,
      double amount, String remark) {
    final userRef = ref.child(groupName).child(userName);

    userRef.once().then((snapshot) {
      var data = snapshot.snapshot.value as Map;
      double currentSpend = (data['total_spend'] ?? 0).toDouble();
      double currentIncome = (data['total_income'] ?? 0).toDouble();

      String transactionType = type == 'spend' ? 'spend_list' : 'income_list';
      String totalType = type == 'spend' ? 'total_spend' : 'total_income';
      String totalYearType = type == 'spend' ? 'spend_total' : 'income_total';

      // Get current date and time
      String dateTime = DateTime.now().toIso8601String();

      // Add the new transaction
      userRef.child('$transactionType/$dateTime').set({
        'amount': amount,
        'remark': remark,
      });

      // Update the total amount
      if (type == 'spend') {
        userRef.update({'total_spend': currentSpend + amount});
      } else {
        userRef.update({'total_income': currentIncome + amount});
      }

      // Update the year-month total
      String year = DateTime.now().year.toString();
      String month = DateTime.now().month.toString().padLeft(2, '0');

      double currentMonthTotal =
          (data[totalYearType]?[year]?[month] ?? 0).toDouble();
      currentMonthTotal += amount;

      userRef.child('$totalYearType/$year').update({month: currentMonthTotal});
    });
  }

  Future<bool> insertNewUser(
      String groupName, String userName, Map<String, dynamic> newUser) async {
    try {
      await ref.child(groupName).child(userName).set(newUser);
      print(
          "User $userName successfully added to Firebase in $groupName group.");
      return true;
    } catch (e) {
      print("Firebase NewUser Insert Error: $e");
      return false;
    }
  }
}
