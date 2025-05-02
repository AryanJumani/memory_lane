import 'package:flutter/material.dart';
import 'package:trial_flutter/constants.dart';

class AlbumView extends StatelessWidget {
  final String landmark;
  final List<Map<String, dynamic>> photos;

  const AlbumView({super.key, required this.landmark, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(landmark)),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: photos.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final photo = photos[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "$BASE_URL/${photo['photo_url']}",
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
