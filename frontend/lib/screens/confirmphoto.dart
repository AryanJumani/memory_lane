import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial_flutter/constants.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String? _message;
  bool _isUploading = false;

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

  Future<void> uploadPhoto() async {
    setState(() {
      _isUploading = true;
      _message = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    final uri = Uri.parse("$BASE_URL/api/photos");
    Position? position = await _getCurrentPosition();

    if (position == null) {
      setState(() {
        _isUploading = false;
        _message = "Failed to get GPS coordinates.";
      });
      return;
    }

    var request = http.MultipartRequest("POST", uri);
    request.fields['user_id'] = '$userId';
    request.fields['latitude'] = position.latitude.toString();
    request.fields['longitude'] = position.longitude.toString();

    request.files.add(await http.MultipartFile.fromPath(
      'photo',
      widget.imagePath,
      filename: path.basename(widget.imagePath),
    ));

    try {
      final response = await request.send();

      setState(() => _isUploading = false);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Photo uploaded!")),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _message = "Upload failed. (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _message = "Upload failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preview Photo')),
      body: Column(
        children: [
          Expanded(child: Image.file(File(widget.imagePath))),
          if (_isUploading) CircularProgressIndicator(),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_message!, style: TextStyle(color: Colors.redAccent)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                label: Text("Retake"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton.icon(
                label: Text("Upload"),
                onPressed: _isUploading ? null : uploadPhoto,
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
