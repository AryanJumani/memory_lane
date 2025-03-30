import 'package:flutter/material.dart';

void showChangeFieldDialog(
  BuildContext context, {
  required String? newThing,
  required void Function(String newValue, String password) onConfirm,
}) {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newValueController = TextEditingController();

  if (newThing == "" || newThing == "ph") {
    String del = newThing == "ph" ? "photo" : "account";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm deletion of $del"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final pwd = passwordController.text;
              final val = newValueController.text;
              onConfirm(val, pwd);
              Navigator.pop(context);
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change $newThing"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: newValueController,
              decoration: InputDecoration(
                labelText: "New $newThing",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final pwd = passwordController.text;
              final val = newValueController.text;
              if (pwd.isNotEmpty && val.isNotEmpty) {
                onConfirm(val, pwd);
                Navigator.pop(context);
              }
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
