import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photos"),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Text("Memory Lane!!!"),
      ),
    );
  }
}
