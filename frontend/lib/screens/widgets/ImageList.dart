import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final Map<String, dynamic> photo;
  const ImageCard({super.key, required this.photo});

  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return "${dt.day} ${month(dt.month)} ${dt.year}";
    } catch (e) {
      return iso;
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
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              photo["username"] ?? "Unkown User",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 2),
            Text(
              "${photo["latitude"]}, ${photo["longitude"]}",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
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
            SizedBox(height: 4),
            Text(
              _formatTimestamp(photo["timestamp"]),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
