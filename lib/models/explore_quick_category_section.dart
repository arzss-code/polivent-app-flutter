import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';

class CategoryEvents {
  String name;
  Color boxColor;

  CategoryEvents({
    required this.name,
    required this.boxColor,
  });

  static List<CategoryEvents> getCategories() {
    List<CategoryEvents> categories = [];

    categories.add(CategoryEvents(
      name: 'Seminar',
      boxColor: UIColor.primaryColor,
    ));
    categories.add(CategoryEvents(
      name: 'Competition',
      boxColor: UIColor.solidWhite,
    ));
    categories.add(CategoryEvents(
      name: 'Workshop',
      boxColor: UIColor.solidWhite,
    ));
    categories.add(CategoryEvents(
      name: 'Exhibition',
      boxColor: UIColor.solidWhite,
    ));
    categories.add(CategoryEvents(
      name: 'Bussiness',
      boxColor: UIColor.solidWhite,
    ));
    categories.add(CategoryEvents(
      name: 'Art',
      boxColor: UIColor.solidWhite,
    ));
    categories.add(CategoryEvents(
      name: 'Sport',
      boxColor: UIColor.solidWhite,
    ));
    categories.add(CategoryEvents(
      name: 'Gaming',
      boxColor: UIColor.solidWhite,
    ));

    return categories;
  }
}

class QuickCategorySection extends StatefulWidget {
  const QuickCategorySection({super.key});

  @override
  _QuickCategorySectionState createState() => _QuickCategorySectionState();
}

class _QuickCategorySectionState extends State<QuickCategorySection> {
  int _selectedIndex = 0; // To track the selected category

  @override
  Widget build(BuildContext context) {
    List<CategoryEvents> categories = CategoryEvents.getCategories();

    return SizedBox(
      height: 30,
      child: ListView.separated(
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 20),
        separatorBuilder: (context, index) => const SizedBox(
          width: 10,
        ),
        itemBuilder: (context, index) {
          bool isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                color: isSelected ? UIColor.primaryColor : UIColor.solidWhite,
                border: Border.all(
                  color:
                      isSelected ? UIColor.primaryColor : UIColor.primaryColor,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                categories[index].name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? UIColor.solidWhite : UIColor.primaryColor,
                  height: 2.5,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
