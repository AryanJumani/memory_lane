import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial_flutter/constants.dart';
import 'dart:convert';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String? _message;
  bool _isUploading = false;
  final TextEditingController _taggedController = TextEditingController();
  final List<String> _taggedUsernames = [];

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

  void _handleTagInput(String value) {
    if (value.endsWith(' ')) {
      final username = value.trim();
      if (username.isNotEmpty && !_taggedUsernames.contains(username)) {
        setState(() {
          _taggedUsernames.add(username);
        });
      }
      _taggedController.clear();
    }
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
        final photoResp =
            await http.get(Uri.parse("$BASE_URL/api/photos/user/$userId"));

        if (photoResp.statusCode == 200) {
          final photos =
              List<Map<String, dynamic>>.from(jsonDecode(photoResp.body));
          final latestPhotoId = photos.last["photo_id"];

          for (final username in _taggedUsernames) {
            final lookupResp = await http.get(
              Uri.parse("$BASE_URL/api/users/lookup?username=$username"),
            );

            if (lookupResp.statusCode == 200) {
              final lookupData = jsonDecode(lookupResp.body);
              final tagUserId = lookupData["user_id"];

              await http.post(
                Uri.parse("$BASE_URL/api/tags"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "photo_id": latestPhotoId,
                  "tagged_user": tagUserId,
                }),
              );
            } else {
              setState(() {
                _message =
                    "Tag failed. Could not find user $username, but photo was uploaded.";
              });
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Photo uploaded!")),
        );
        Navigator.pop(context);
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: _taggedUsernames
                      .map(
                        (username) => Chip(
                          label: Text(username),
                          onDeleted: () {
                            setState(() {
                              _taggedUsernames.remove(username);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _taggedController,
                  decoration: InputDecoration(
                    labelText: "Tag users (press space to add)",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _handleTagInput,
                ),
              ],
            ),
          ),
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
