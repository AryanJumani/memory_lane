import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial_flutter/screens/home.dart';
import 'theme.dart';
import 'screens/login.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');
  //prefs.remove('user_id');
  //await dotenv.load(fileName: ".env");

  runApp(MyApp(isLoggedIn: userId != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Lane App',
      theme: darkTheme,
      home: isLoggedIn ? HomeScreen() : LoginScreen(),
    );
  }
}
