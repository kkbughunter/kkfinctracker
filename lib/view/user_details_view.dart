// lib/view/user_details_view.dart

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserDetailsPage extends StatelessWidget {
  final String userName;

  UserDetailsPage({required this.userName});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('$userName Details'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Spend'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TransactionList(userName: userName, type: 'amount_spend'),
            TransactionList(userName: userName, type: 'amount_income'),
          ],
        ),
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final String userName;
  final String type;

  TransactionList({required this.userName, required this.type});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference _databaseReference =
        FirebaseDatabase.instance.ref();

    return StreamBuilder<DatabaseEvent>(
      stream: _databaseReference.child('$userName/$type').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          var data = snapshot.data!.snapshot.value;
          List<MapEntry<dynamic, dynamic>> transactions;

          if (data is Map<dynamic, dynamic>) {
            transactions = data.entries.toList();
          } else if (data is List<dynamic>) {
            transactions = data.asMap().entries.toList();
          } else {
            return const Center(child: Text('No data available'));
          }

          // Exclude the first entry
          if (transactions.isNotEmpty) {
            transactions = transactions.sublist(1);
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var entry = transactions[index];
              bool isSpend = type == 'amount_spend';

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: isSpend
                    ? Colors.red[50]
                    : Colors.green[50], // Light red/green background
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSpend ? Colors.red : Colors.green,
                    child: Icon(
                      isSpend ? Icons.remove : Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    '₹${entry.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  // subtitle: Text('ID: ${entry.key}'),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
