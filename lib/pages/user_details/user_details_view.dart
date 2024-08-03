// lib/pages/user_details_view.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kkfinctracker/pages/user_details/user_details_tool.dart';
import 'user_details_controller.dart';
import 'user_details_model.dart';
import 'package:firebase_database/firebase_database.dart';

class UserDetailsView extends StatefulWidget {
  final String groupName;
  final String userName;

  const UserDetailsView(
      {Key? key, required this.groupName, required this.userName})
      : super(key: key);

  @override
  _UserDetailsViewState createState() => _UserDetailsViewState();
}

class _UserDetailsViewState extends State<UserDetailsView> {
  final UserDetailsController _controller = UserDetailsController();
  final UserDetailsTools _tools = UserDetailsTools();
  late Future<UserDetailsModel?> _userDetails;
  late DatabaseReference _userRef;
  late StreamSubscription<DatabaseEvent> _dataSubscription;

  @override
  void initState() {
    super.initState();
    _userRef = FirebaseDatabase.instance
        .ref()
        .child('${widget.groupName}/${widget.userName}');
    _userDetails =
        _controller.getUserDetails(widget.groupName, widget.userName);
    _listenForDataChanges();
  }

  void _listenForDataChanges() {
    _dataSubscription = _userRef.onValue.listen((event) {
      var snapshot = event.snapshot;
      var data = snapshot.value;

      if (data != null) {
        setState(() {
          _userDetails = Future.value(
              UserDetailsModel.fromMap(data as Map<dynamic, dynamic>));
        });
      }
    }, onError: (Object error) {
      print('Error listening for data: $error');
    });
  }

  @override
  void dispose() {
    _dataSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[300],
        title: Text('${widget.userName} Details'),
      ),
      body: FutureBuilder<UserDetailsModel?>(
        future: _userDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            var userDetails = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Month Spend: \₹${userDetails.currentMonthSpend.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Total Spend: \₹${userDetails.totalSpend.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Total Income: \₹${userDetails.totalIncome.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _tools.showTransactionDialog(
                              context,
                              'Spend',
                              widget.groupName,
                              widget.userName,
                              _controller,
                              _updateUserDetails);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text(
                          'Add Spend Amount',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _tools.showTransactionDialog(
                              context,
                              'Income',
                              widget.groupName,
                              widget.userName,
                              _controller,
                              _updateUserDetails);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text(
                          'Add Income Amount',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(text: 'Spend Transactions'),
                              Tab(text: 'Income Transactions'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                ListView(
                                  children: userDetails.spendList.entries
                                      .map((entry) {
                                        DateTime date =
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(entry.key));
                                        String formattedDate =
                                            DateFormat('dd MMM yyyy, hh:mm a')
                                                .format(date);
                                        return ListTile(
                                          title: Text(
                                            '\₹${entry.value['amount'].toStringAsFixed(2)}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Date: $formattedDate'),
                                              Text(
                                                  'Remark: ${entry.value['remark']}'),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList()
                                      .reversed
                                      .toList(),
                                ),
                                ListView(
                                  children: userDetails.incomeList.entries
                                      .map((entry) {
                                        DateTime date =
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(entry.key));
                                        String formattedDate =
                                            DateFormat('dd MMM yyyy, hh:mm a')
                                                .format(date);
                                        return ListTile(
                                          title: Text(
                                            'Amount: \₹${entry.value['amount'].toStringAsFixed(2)}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Date: $formattedDate'),
                                              Text(
                                                  'Remark: ${entry.value['remark']}'),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList()
                                      .reversed
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  void _updateUserDetails() {
    setState(() {
      _userDetails =
          _controller.getUserDetails(widget.groupName, widget.userName);
    });
  }
}
