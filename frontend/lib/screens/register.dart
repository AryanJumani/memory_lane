import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPwd = TextEditingController();
  String _message = '';

  Future<void> register() async {
    if (_confirmPwd.text != _passwordController.text) {
      setState(() {
        _message = "Passwords don't match";
      });
      return;
    }
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration successful! Login."),
        ),
      );
      Navigator.pop(context);
    } else {
      String errorMessage = "Registration failed.";
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey("error")) {
          errorMessage = decoded["error"];
        }
      } on Exception catch (e) {
        _message = e.toString();
      }
      setState(() {
        _message += "Error: $errorMessage";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text("Register"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _confirmPwd,
              decoration: InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: Text("Register"),
            ),
            SizedBox(height: 10),
            Text(
              _message,
              style: TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
