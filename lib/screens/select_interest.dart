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
    {'icon': '🎤', 'label': 'Seminar'},
    {'icon': '🛠', 'label': 'Workshop'},
    {'icon': '🏆', 'label': 'Competition'},
    {'icon': '🎪', 'label': 'Exhibition'},
    {'icon': '💼', 'label': 'Business'},
    {'icon': '💉', 'label': 'Health'},
    {'icon': '💻', 'label': 'Technology'},
    {'icon': '🎵', 'label': 'Music'},
    {'icon': '🎮', 'label': 'Gaming'},
    {'icon': '⚽️', 'label': 'Sports'},
    {'icon': '🎨', 'label': 'Art'},
    {'icon': '🍲', 'label': 'Food'},
  ];

  // Menyimpan kategori yang dipilih
  final Set<String> selectedInterests = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                spacing: 14.0,
                runSpacing: 14.0,
                children: categories.map((category) {
                  final isSelected =
                      selectedInterests.contains(category['label']);
                  return FilterChip(
                    avatar: Text(
                      category['icon'],
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter'),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),

                    label: Text(category['label']),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedInterests.add(category['label']);
                        } else {
                          selectedInterests.remove(category['label']);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor:
                        UIColor.primaryColor, // Warna biru saat dipilih
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
              // const SizedBox(height: 38,),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Aksi ketika tombol ditekan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const HomeScreen(), // Ganti ke screen berikutnya
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(
                      MediaQuery.of(context).size.width * 1,
                      MediaQuery.of(context).size.height * 0.06,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor:
                        UIColor.primaryColor, // Warna biru dari palet utama
                  ),
                  child: const SizedBox(
                    // width: MediaQuery.of(context).size.width * 1,
                    // height: MediaQuery.of(context).size.height * 0.06,
                    child: Text(
                      "Continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
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
