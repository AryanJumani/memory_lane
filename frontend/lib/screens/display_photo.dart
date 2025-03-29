import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/ImageList.dart';

class DisplayPhoto extends StatefulWidget {
  const DisplayPhoto({super.key});

  @override
  State<DisplayPhoto> createState() => _DisplayPhotoState();
}

class _DisplayPhotoState extends State<DisplayPhoto> {
  late Future<List<Map<String, dynamic>>> photos;

  @override
  void initState() {
    super.initState();
    photos = getPhotos('1'); // TODO: replace with proper user id later
  }

  Future<List<Map<String, dynamic>>> getPhotos(String userId) async {
    final uri = Uri.parse("http://10.0.2.2:5000/api/photos/user/$userId");
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        if (json is List) {
          return json.map((e) => e as Map<String, dynamic>).toList();
        } else {
          print("Unexpected things: $json");
          return [];
        }
      } else {
        print("Failed to get photos: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: photos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error occured"),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView(
              children: snapshot.data!
                  .map((photo) => ImageCard(photo: photo))
                  .toList());
        } else {
          return Center(child: Text("No photos found."));
        }
      },
    );
  }
}
