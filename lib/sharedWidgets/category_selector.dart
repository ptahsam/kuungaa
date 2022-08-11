import 'package:flutter/material.dart';
import 'package:kuungaa/config/palette.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({Key? key}) : super(key: key);

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {

  int selectedIndex = 0;
  final List<String> categories = ["Chats", "Contacts", "Calls"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      color: Palette.kuungaaDefault,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index){
          return InkWell(
            onTap: (){
              setState(() {
                selectedIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 15.0, top: 30.0, bottom: 5.0),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: index == selectedIndex ? Colors.white : Colors.white60,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          );
        }, separatorBuilder: (BuildContext context, int index) {
          return const Spacer();
      },
      ),
    );
  }
}
