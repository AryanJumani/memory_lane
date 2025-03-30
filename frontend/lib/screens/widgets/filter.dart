import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:trial_flutter/screens/widgets/ImageList.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? _message;
  bool _loading = true;
  List<Map<String, dynamic>> _photos = [];

  @override
  void initState() {
    super.initState();
    getDefaultPhotos();
  }

  Future<void> getDefaultPhotos() async {
    Position? pos = await _getCurrentPosition();
    if (pos == null) {
      setState(() {
        _message = "Unable to get location.";
        _loading = false;
      });
    } else {
      final photos = await getNearbyPhotos(pos, 10);
      setState(() {
        _photos = photos;
        _loading = false;
      });
    }
  }

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _message = "Location services are disabled.");
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        setState(() => _message = "Location permission denied.");
        return null;
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<Map<String, dynamic>>> getNearbyPhotos(
      Position position, double radius) async {
    final uri = Uri.parse(
        "http://10.0.2.2:5000/api/photos/nearby?latitude=${position.latitude.toString()}&longitude=${position.longitude.toString()}&radius=$radius");
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        if (json is List) {
          return json.map((item) => item as Map<String, dynamic>).toList();
        } else {
          print("Unexpected response format: $json");
          return [];
        }
      } else {
        print("Failed to load nearby photos: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching nearby photos: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter photos"),
        backgroundColor: color.surface,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? Center(
                  child: Text(_message ?? "No photos"),
                )
              : ListView.builder(
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    return ImageCard(
                      photo: _photos[index],
                      showDelete: false,
                    );
                  },
                ),
    );
  }
}
