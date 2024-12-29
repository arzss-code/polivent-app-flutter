import 'package:flutter/material.dart';
import 'package:polivent_app/services/data/interest_model.dart';
import 'package:polivent_app/services/interest_services.dart';

class InterestsSelectorScreen extends StatefulWidget {
  const InterestsSelectorScreen({Key? key}) : super(key: key);

  @override
  _InterestsSelectorScreenState createState() =>
      _InterestsSelectorScreenState();
}

class _InterestsSelectorScreenState extends State<InterestsSelectorScreen> {
  final InterestsService _interestsService = InterestsService();
  List<Interest> _availableInterests = [];
  List<Interest> _selectedInterests = [];

  // Dummy data interests - sesuaikan dengan kebutuhan
  final List<Interest> _allInterests = [
    Interest(id: 1, name: 'Music', category: 'Art'),
    Interest(id: 2, name: 'Art', category: 'Creative'),
    Interest(id: 3, name: 'Sports', category: 'Physical'),
    Interest(id: 4, name: 'Technology', category: 'Science'),
    Interest(id: 5, name: 'Cooking', category: 'Lifestyle'),
    Interest(id: 6, name: 'Travel', category: 'Lifestyle'),
    Interest(id: 7, name: 'Photography', category: 'Art'),
    Interest(id: 8, name: 'Reading', category: 'Education'),
    Interest(id: 9, name: 'Gaming', category: 'Entertainment'),
    Interest(id: 10, name: 'Movies', category: 'Entertainment'),
    Interest(id: 11, name: 'Fitness', category: 'Health'),
    Interest(id: 12, name: 'Design', category: 'Creative'),
    Interest(id: 13, name: 'Workshop', category: 'Education'),
    Interest(id: 14, name: 'Seminar', category: 'Professional'),
    Interest(id: 15, name: 'E-Sport', category: 'Gaming'),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialInterests();
  }

  Future<void> _loadInitialInterests() async {
    final savedInterests = await _interestsService.getUserInterests();

    setState(() {
      _availableInterests = _allInterests;
      _selectedInterests = savedInterests;
    });
  }

  void _toggleInterest(Interest interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _saveInterests() async {
    await _interestsService.saveUserInterests(_selectedInterests);
    Navigator.pop(context, _selectedInterests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Interests'),
        actions: [
          TextButton(
            onPressed: _saveInterests,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          // Interests yang sudah dipilih
          if (_selectedInterests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _selectedInterests.map((interest) {
                  return InputChip(
                    label: Text(interest.name),
                    onDeleted: () => _toggleInterest(interest),
                  );
                }).toList(),
              ),
            ),

          // Grid interests yang bisa dipilih
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _availableInterests.length,
              itemBuilder: (context, index) {
                final interest = _availableInterests[index];
                final isSelected = _selectedInterests.contains(interest);

                return GestureDetector(
                  onTap: () => _toggleInterest(interest),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            interest.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            interest.category,
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
