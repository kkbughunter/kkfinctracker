// lib/pages/user_details_tools.dart

import 'package:flutter/material.dart';
import 'user_details_controller.dart';

class UserDetailsTools {
  void showTransactionDialog(
      BuildContext context,
      String type,
      String groupName,
      String userName,
      UserDetailsController controller,
      Function updateUserDetails) {
    final _amountController = TextEditingController();
    final _remarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add $type amount for $userName in $groupName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _remarkController,
                decoration: const InputDecoration(labelText: 'Remark'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.parse(_amountController.text);
                String remark = _remarkController.text;
                if (remark == "") remark = 'food';
                controller.addTransaction(
                    groupName, userName, type, amount, remark);
                Navigator.pop(context);
                updateUserDetails();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
