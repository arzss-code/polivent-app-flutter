import 'package:flutter/material.dart';
import 'package:polivent_app/screens/home.dart';
import '../models/ui_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SelectInterestScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class SelectInterestScreen extends StatefulWidget {
  const SelectInterestScreen({super.key});

  @override
  State<SelectInterestScreen> createState() => _SelectInterestScreenState();
}

class _SelectInterestScreenState extends State<SelectInterestScreen> {
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.mic, 'label': 'Seminar'},
    {'icon': Icons.build, 'label': 'Workshop'},
    {'icon': Icons.emoji_events, 'label': 'Competition'},
    {'icon': Icons.celebration, 'label': 'Exhibition'},
    {'icon': Icons.business_center, 'label': 'Business'},
    {'icon': Icons.health_and_safety, 'label': 'Health'},
    {'icon': Icons.computer, 'label': 'Technology'},
    {'icon': Icons.music_note, 'label': 'Music'},
    {'icon': Icons.videogame_asset, 'label': 'Gaming'},
    {'icon': Icons.sports_soccer, 'label': 'Sports'},
    {'icon': Icons.brush, 'label': 'Art'},
    {'icon': Icons.restaurant, 'label': 'Food'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Select Your Interest',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your favorite topics and get personalized event recommendations just for you. Explore events that match your passions and update your preferences anytime!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: categories.map((category) {
                  return FilterChip(
                    avatar: Icon(category['icon']),
                    label: Text(category['label']),
                    onSelected: (bool selected) {},
                    backgroundColor: Colors.grey[200],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Aksi ketika tombol ditekan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const Home(), // Ganti ke screen berikutnya
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor:
                        UIColor.primaryColor, // Warna biru dari palet utama
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
