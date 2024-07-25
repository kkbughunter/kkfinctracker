// lib/view/home/home_tools.dart

import 'package:flutter/material.dart';
import 'package:kkfinctracker/controler/home_controller.dart';

class HomeTools {
  final HomeController _controller = HomeController();

  void showTransactionDialog(
      BuildContext context, String userName, String type) {
    final _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add $type amount for $userName'),
          content: TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.parse(_amountController.text);
                _controller.addTransaction(userName, type, amount);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void addNewUser(BuildContext context) {
    final _userNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: TextField(
            controller: _userNameController,
            decoration: const InputDecoration(labelText: 'User Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final userName = _userNameController.text;
                if (userName.isNotEmpty) {
                  _controller.addNewUser(userName).then((success) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('User added successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to add user')),
                      );
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
