import 'package:firebase_database/firebase_database.dart';

class HomeModel {
  final DatabaseReference ref = FirebaseDatabase.instance.ref();

  Future<dynamic> getUsers() async {
    final snapshot = await ref.get();
    return snapshot.value;
  }

  void updateUserTransaction(String userName, String type, double amount) {
    final userRef = ref.child(userName);

    userRef.once().then((snapshot) {
      var data = snapshot.snapshot.value as Map;
      double currentSpend = (data['total_spend'] ?? 0).toDouble();
      double currentIncome = (data['total_income'] ?? 0).toDouble();

      if (type == 'spend') {
        userRef.update({'total_spend': currentSpend + amount});
      } else {
        userRef.update({'total_income': currentIncome + amount});
      }
    });
  }

  /*
   * Input: the newly creating User Name and the structure.
   * 
   * Working: Inserts the user structure into the database.
   * 
   * Output: true for success, false for failure.  
   */
  Future<bool> insertNewUser(String userName, Map<String, dynamic> newUser) async {
    try {
      await ref.child(userName).set(newUser);
      print("User $userName successfully added to Firebase.");
      return true;
    } catch (e) {
      print("Firebase NewUser Insert Error: $e");
      return false;
    }
  }
}
