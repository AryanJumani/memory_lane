import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trial_flutter/constants.dart';
import 'album_view.dart';

class AlbumPage extends StatefulWidget {
  final int userId;
  const AlbumPage({super.key, required this.userId});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  Map<String, List<Map<String, dynamic>>> _albums = {};

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final uri = Uri.parse("$BASE_URL/api/photos/user/${widget.userId}");
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final grouped = <String, List<Map<String, dynamic>>>{};

      for (var photo in data) {
        final landmark = photo["landmark"] ?? "Unknown";
        grouped.putIfAbsent(landmark, () => []).add(photo);
      }

      setState(() => _albums = grouped);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Albums")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: _albums.entries.map((entry) {
          final landmark = entry.key;
          final photos = entry.value;
          final firstPhoto = photos.first;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlbumView(landmark: landmark, photos: photos),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Image.network(
                    "${firstPhoto['photo_url']}",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    child: Text(
                      "$landmark (${photos.length} photos)",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
