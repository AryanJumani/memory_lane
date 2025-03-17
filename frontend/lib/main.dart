import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Lane App',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF0f0f1f),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF3f3f6a),
          secondary: Color(0xFF61618f),
          background: Color(0xFF0f0f1f),
          surface: Color(0xFF22223c),
          onPrimary: Color(0xFFd5d5e2),
          onSecondary: Color(0xFFadadc7),
          onBackground: Color(0xFFd5d5e2),
          onSurface: Color(0xFF8686ac),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3f3f6a),
            foregroundColor: Color(0xFFd5d5e2),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF22223c),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF61618f)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF8686ac), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          hintStyle: TextStyle(color: Color(0xFFadadc7)),
          labelStyle: TextStyle(color: Color(0xFFd5d5e2)),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = "Login successful!";
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      setState(() {
        _message = "Invalid credentials. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text("Login"),
            ),
            SizedBox(height: 10),
            Text(_message, style: TextStyle(color: Colors.redAccent)),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: Text("Don't have an account? Register",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground)),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  Future<void> register() async {
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
      setState(() {
        _message = "Registration successful! Please login.";
      });
      Navigator.pop(context);
    } else {
      setState(() {
        _message = "Error: ${jsonDecode(response.body)['error']}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: Text("Register"),
            ),
            SizedBox(height: 10),
            Text(_message, style: TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Text("Welcome to Memory Lane!",
            style:
                TextStyle(color: Theme.of(context).colorScheme.onBackground)),
      ),
    );
  }
}
