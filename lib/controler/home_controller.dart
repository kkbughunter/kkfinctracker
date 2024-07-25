// lib/controler/home_controller.dart

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

  Future<void> addTransaction(
      String userName, String type, double amount) async {
    final userRef = _databaseReference.child(userName);
    final snapshot = await userRef.get();
    if (snapshot.exists) {
      var data = snapshot.value as Map;
      double currentSpend = (data['total_spend'] ?? 0).toDouble();
      double currentIncome = (data['total_income'] ?? 0).toDouble();

      // Determine the correct path and key for the new transaction
      String transactionType =
          type == 'spend' ? 'amount_spend' : 'amount_income';
      DatabaseReference transactionRef = userRef.child(transactionType);
      DatabaseReference counterRef =
          userRef.child('${transactionType}_counter');

      // Get the current counter value
      final counterSnapshot = await counterRef.get();
      int counter = 1;
      if (counterSnapshot.exists) {
        counter = counterSnapshot.value as int;
      }

      // Insert the new transaction with the incremented key
      transactionRef.child(counter.toString()).set(amount);

      // Update the counter value
      counterRef.set(counter + 1);

      // Update the total spend or income
      if (type == 'spend') {
        userRef.update({'total_spend': currentSpend + amount});
      } else {
        userRef.update({'total_income': currentIncome + amount});
      }
    }
  }

  Future<bool> addNewUser(String userName) async {
    final newUser = {
      userName: {
        "amount_spend": {},
        "amount_income": {},
        "total_spend": 0,
        "total_income": 0,
        "password": "12345",
        "amount_spend_counter": 1,
        "amount_income_counter": 1
      }
    };
    try {
      await _databaseReference.update(newUser);
      return true;
    } catch (e) {
      return false;
    }
  }
}
