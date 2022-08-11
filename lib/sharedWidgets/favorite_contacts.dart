import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:provider/provider.dart';

class FavoriteContacts extends StatelessWidget {
  const FavoriteContacts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Contact",
            style: TextStyle(
              color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.blueGrey,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: (){},
            color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}
