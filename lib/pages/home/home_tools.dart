import 'package:flutter/material.dart';
import 'home_controller.dart';

class HomeTools {
  final HomeController _controller = HomeController();

  void showTransactionDialog(
      BuildContext context, String groupName, String userName, String type) {
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
                final remark = _remarkController.text;
                _controller.addTransaction(
                    groupName, userName, type, amount, remark);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void addNewGroup(BuildContext context) {
    final _groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Group'),
          content: TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(labelText: 'Group Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final groupName = _groupNameController.text;
                _controller.addNewGroup(groupName).then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Group added successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Group already exists')),
                    );
                  }
                  Navigator.pop(context);
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void addNewUser(BuildContext context, String groupName) {
    final _userNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New User to $groupName'),
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
                _controller.addNewUser(groupName, userName).then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User added successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User already exists')),
                    );
                  }
                  Navigator.pop(context);
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
