import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final first = 0;
    final middle = 1;
    final last = 2;
    Widget sectionLabel(String label) => Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );

    Widget actionButton(
        String title, String subtitle, VoidCallback onPressed, int state) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color.surface,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            alignment: Alignment.centerLeft,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(state == 0 ? 10 : 0),
                topRight: Radius.circular(state == 0 ? 10 : 0),
                bottomLeft: Radius.circular(state == 2 ? 10 : 0),
                bottomRight: Radius.circular(state == 2 ? 10 : 0),
              ),
              side: BorderSide(color: color.primary.withOpacity(0.2)),
            ),
          ),
          onPressed: onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, color: color.onBackground)),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: color.secondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: color.surface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionLabel("Account Management"),
            actionButton("Change Username", "current_username", () {
              // TODO: Open username change modal
            }, 0),
            actionButton("Change Email", "user@example.com", () {
              // TODO: Open email change modal
            }, 1),
            actionButton("Change Password", "••••••••••", () {
              // TODO: Open password change modal
            }, 2),
            sectionLabel("Session"),
            actionButton("Log Out", "Sign out from this account", () {
              // TODO: Trigger logout API
            }, 1),
            sectionLabel("Danger Zone"),
            actionButton("Delete Account", "This action is irreversible", () {
              // TODO: Confirm and delete account
            }, 1),
          ],
        ),
      ),
    );
  }
}
