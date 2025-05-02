import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial_flutter/constants.dart';
import 'package:trial_flutter/screens/home.dart';
import 'package:trial_flutter/screens/widgets/dialog.dart';
import 'dart:convert';

class ImageCard extends StatefulWidget {
  final Map<String, dynamic> photo;
  final bool showDelete;
  const ImageCard({
    super.key,
    required this.photo,
    this.showDelete = true,
  });

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  final _commentController = TextEditingController();

  //String? _nearestLandmark;
  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return "${dt.day} ${month(dt.month)} ${dt.year}";
    } catch (e) {
      return iso;
    }
  }

  /*Future<void> _fetchNearestLnadmark() async {
    final latitude = widget.photo['latitude'];
    final longitude = widget.photo['longitude'];
    final landmark =
        await LocationService.getNearestLandmark(latitude, longitude);
    setState(() {
      _nearestLandmark = landmark;
    });
  }*/

  Future<void> deletePhoto(BuildContext context, int photoId) async {
    final uri = Uri.parse("$BASE_URL/api/photos/$photoId");
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Photo deleted")),
      );
      // Optional: trigger UI update (e.g. callback to parent)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Unable to delete photo")),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchComments(int photoId) async {
    final uri = Uri.parse("$BASE_URL/api/comments/$photoId");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    }
    return [];
  }

  Future<List<String>> fetchTaggedUsernames(int photoId) async {
    final uri = Uri.parse("$BASE_URL/api/tags/$photoId");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data.map((tag) => tag["username"]));
    }
    return [];
  }

  String month(int m) {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  photo["username"] ?? "Unknown User",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (widget.showDelete)
                  IconButton(
                    onPressed: () {
                      showChangeFieldDialog(
                        context,
                        newThing: "ph",
                        onConfirm: (val, _) {
                          deletePhoto(context, photo["photo_id"]);
                        },
                      );
                    },
                    icon: Icon(Icons.delete_outline),
                  ),
              ],
            ),

            // Location
            SizedBox(height: 2),
            Text(
              "${photo["landmark"]}",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),

            // Image
            SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "${photo['photo_url']}",
                height: 300,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),

            // Timestamp
            SizedBox(height: 4),
            Text(
              _formatTimestamp(photo["timestamp"]),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            FutureBuilder<List<String>>(
              future: fetchTaggedUsernames(photo["photo_id"]),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox.shrink();
                }

                final taggedUsernames = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 6,
                    children: taggedUsernames.map((username) {
                      return Chip(
                        label: Text("@$username"),
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            FutureBuilder(
              future: fetchComments(widget.photo["photo_id"]),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6),
                    Text("Comments:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...snapshot.data!.map((c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text("${c["username"]}: ${c["comment"]}"),
                        )),
                  ],
                );
              },
            ),
            SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  final comment = _commentController.text.trim();
                  if (comment.isEmpty) return;
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt("user_id");

                  await http.post(
                    Uri.parse("$BASE_URL/api/comments"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "photo_id": widget.photo["photo_id"],
                      "user_id": userId,
                      "comment": comment,
                    }),
                  );
                  _commentController.clear();
                  setState(() {});
                },
                child: Text("Post"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
