import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial_flutter/screens/login.dart';
import 'package:trial_flutter/screens/widgets/dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final data = await getUserData();
    setState(() {
      userData = data;
    });
  }

  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final uri = Uri.parse("http://10.0.2.2:5000/api/users/$userId");
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Deleted Account"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting account"),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final uri = Uri.parse("http://10.0.2.2:5000/api/users/$userId");
    final response = await http.get(uri);
    print("res body: " + response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"message": "Error getting data"};
    }
  }

  Future<void> updateUsername(String username, String password) async {
    if (password != userData["password_hash"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Wrong Password"),
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final uri = Uri.parse("http://10.0.2.2:5000/api/users/$userId");
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": username, "email": "", "password": ""}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Username updated"),
        ),
      );
      logout(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error occured, ${response.statusCode}"),
        ),
      );
      print("failed");
    }
  }

  Future<void> updateEmail(String email, String password) async {
    if (password != userData["password_hash"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Wrong Password"),
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final uri = Uri.parse("http://10.0.2.2:5000/api/users/$userId");
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": "", "email": email, "password": ""}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email updated"),
        ),
      );
      logout(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error occured, ${response.statusCode}"),
        ),
      );
      print("failed");
    }
  }

  Future<void> updatePwd(String newPwd, String password) async {
    if (password != userData["password_hash"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Wrong Password"),
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final uri = Uri.parse("http://10.0.2.2:5000/api/users/$userId");
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": "", "email": "", "password": newPwd}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password updated"),
        ),
      );
      logout(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error occured, ${response.statusCode}"),
        ),
      );
      print("failed");
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
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
                topLeft: Radius.circular(state == 0 || state == 3 ? 10 : 0),
                topRight: Radius.circular(state == 0 || state == 3 ? 10 : 0),
                bottomLeft: Radius.circular(state == 2 || state == 3 ? 10 : 0),
                bottomRight: Radius.circular(state == 2 || state == 3 ? 10 : 0),
              ),
              side: BorderSide(color: color.primary.withOpacity(0.2)),
            ),
          ),
          onPressed: onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, color: color.onSurface)),
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
            actionButton("Change Username", userData["username"], () {
              showChangeFieldDialog(
                context,
                newThing: "Username",
                onConfirm: (newVal, password) {
                  updateUsername(newVal, password);
                },
              );
            }, 0),
            actionButton("Change Email", userData["email"], () {
              showChangeFieldDialog(
                context,
                newThing: "Email",
                onConfirm: (newVal, password) {
                  updateEmail(newVal, password);
                },
              );
            }, 1),
            actionButton("Change Password", "••••••••••", () {
              showChangeFieldDialog(
                context,
                newThing: "Password",
                onConfirm: (newVal, password) {
                  updatePwd(newVal, password);
                },
              );
            }, 2),
            sectionLabel("Session"),
            actionButton("Log Out", "Sign out from this account", () {
              logout(context);
            }, 3),
            sectionLabel("Danger Zone"),
            actionButton("Delete Account", "This action is irreversible", () {
              showChangeFieldDialog(
                context,
                newThing: "",
                onConfirm: (newVal, password) {
                  deleteAccount();
                  logout(context);
                },
              );
            }, 3),
          ],
        ),
      ),
    );
  }
}
