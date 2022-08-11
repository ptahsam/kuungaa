import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
class GroupMenu extends StatefulWidget {
  const GroupMenu({Key? key}) : super(key: key);

  @override
  _GroupMenuState createState() => _GroupMenuState();
}

class _GroupMenuState extends State<GroupMenu> {

  int selectedIndex = 0;
  final List<String> groupMenu = ["Home", "Your Groups", "Joined Groups", "Suggested Groups"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: groupMenu.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index){
          return InkWell(
            onTap: (){
              setState(() {
                selectedIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                height: 20.0,
                decoration: Provider.of<AppData>(context).darkTheme?BoxDecoration(
                  color: index == selectedIndex ? Palette.darker : Palette.mediumDarker,
                  border: Border.all(
                    width: 0.8,
                    color: Palette.kuungaaDefault,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ):BoxDecoration(
                  color: index == selectedIndex ? HexColor("#ced4da") : HexColor("#e9ecef"),
                  border: Border.all(
                    width: 0.8,
                    color: Palette.kuungaaDefault,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Center(
                  child: Text(
                    groupMenu[index],
                    style: TextStyle(
                      fontWeight: index == selectedIndex ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
