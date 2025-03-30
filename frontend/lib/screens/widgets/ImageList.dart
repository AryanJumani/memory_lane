import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trial_flutter/screens/home.dart';
import 'package:trial_flutter/screens/widgets/dialog.dart';

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
  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return "${dt.day} ${month(dt.month)} ${dt.year}";
    } catch (e) {
      return iso;
    }
  }

  Future<void> deletePhoto(BuildContext context, int photoId) async {
    final uri = Uri.parse("http://10.0.2.2:5000/api/photos/$photoId");
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
              "${photo["latitude"]}, ${photo["longitude"]}",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),

            // Image
            SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "http://10.0.2.2:5000/${photo['photo_url']}",
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
          ],
        ),
      ),
    );
  }
}
