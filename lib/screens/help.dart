import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Help',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add search functionality
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: const [
          HelpItem(
            title: 'What is Polivent?',
            content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Ut et massa mi. Aliquam in hendrerit urna. Pellentesque '
                'sit amet sapien fringilla, mattis ligula consectetur, '
                'ultrices mauris. Maecenas vitae mattis tellus. Nullam q...',
          ),
          HelpItem(
            title: 'What is Polivent?',
            content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Ut et massa mi. Aliquam in hendrerit urna. Pellentesque '
                'sit amet sapien fringilla, mattis ligula consectetur, '
                'ultrices mauris. Maecenas vitae mattis tellus. Nullam q...',
          ),
          HelpItem(
            title: 'What is Polivent?',
            content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Ut et massa mi. Aliquam in hendrerit urna. Pellentesque '
                'sit amet sapien fringilla, mattis ligula consectetur, '
                'ultrices mauris. Maecenas vitae mattis tellus. Nullam q...',
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
    );
  }
}

class HelpItem extends StatelessWidget {
  final String title;
  final String content;

  const HelpItem({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 204, 203, 203),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(
                  height: 2, // Reduced height to make divider more compact
                  thickness: 2, // Increased thickness for a more prominent line
                  color: Colors
                      .black26, // Slightly darker color for better visibility
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
