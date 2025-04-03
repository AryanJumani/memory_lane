import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:trial_flutter/constants.dart';
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

  final TextEditingController _radiusController =
      TextEditingController(text: '10');
  final TextEditingController _usernameController = TextEditingController();
  DateTime? _selectedDate;

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
      await applyFilters(pos);
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

  Future<void> applyFilters(Position position) async {
    setState(() => _loading = true);
    double radius = double.tryParse(_radiusController.text.trim()) ?? 10.0;
    String username = _usernameController.text.trim().toLowerCase();
    DateTime? date = _selectedDate;

    final uri = Uri.parse(
        "$BASE_URL/api/photos/nearby?latitude=${position.latitude}&longitude=${position.longitude}&radius=$radius");

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        List<Map<String, dynamic>> allPhotos =
            json.map((item) => item as Map<String, dynamic>).toList();

        // Apply filters locally
        List<Map<String, dynamic>> filtered = allPhotos.where((photo) {
          bool userMatch = username.isEmpty ||
              (photo['username']?.toString().toLowerCase() ?? "")
                  .contains(username);
          bool dateMatch = date == null ||
              DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(photo['timestamp'])) ==
                  DateFormat('yyyy-MM-dd').format(date);
          return userMatch && dateMatch;
        }).toList();

        setState(() {
          _photos = filtered;
          _message = filtered.isEmpty ? "No matching photos." : null;
        });
      } else {
        setState(() {
          _photos = [];
          _message = "Failed to load photos.";
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _photos = [];
        _message = "Something went wrong.";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Filter Photos"),
        backgroundColor: color.surface,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _radiusController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Radius (km)"),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    decoration:
                        InputDecoration(labelText: "Posted by (username)"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickDate,
                  icon: Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null
                      ? "Select Date"
                      : DateFormat('dd MMM yyyy').format(_selectedDate!)),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    Position? pos = await _getCurrentPosition();
                    if (pos != null) await applyFilters(pos);
                  },
                  child: Text("Apply Filters"),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Photo results
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator())
                  : _photos.isEmpty
                      ? Center(child: Text(_message ?? "No results"))
                      : ListView.builder(
                          itemCount: _photos.length,
                          itemBuilder: (context, index) {
                            return ImageCard(
                              photo: _photos[index],
                              showDelete: false,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
