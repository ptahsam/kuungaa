import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class CustomTabBar extends StatelessWidget {

  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onTap;
  final bool isBottomIndicator;

  const CustomTabBar({
    Key? key,
    required this.icons,
    required this.selectedIndex,
    required this.onTap,
    this.isBottomIndicator = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorPadding: EdgeInsets.zero,
      indicator: BoxDecoration(
        border: isBottomIndicator?Border(
          bottom: BorderSide(
            color: HexColor("#2dce89"),
            width: 3.0,

          ),
        ) : Border(
          top: BorderSide(
            color: HexColor("#2dce89"),
            width: 3.0,
            
          ),
         ),
        //borderRadius: BorderRadius.circular(5.0),
      ),
      tabs: Provider.of<AppData>(context).darkTheme?icons.asMap()
      .map((i, e) => MapEntry(i, Tab(
        icon: Icon(e,
          color: i == selectedIndex
              ? HexColor("#2dce89")
              : Colors.white,
          size: 24.0,
        ),
      ),
      )).values
      .toList():icons.asMap()
          .map((i, e) => MapEntry(i, Tab(
        icon: Icon(e,
          color: i == selectedIndex
              ? HexColor("#2dce89")
              : Colors.black45,
          size: 24.0,
        ),
      ),
      )).values
          .toList(),
      onTap: onTap,
    );
  }
}
