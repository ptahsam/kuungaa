import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
class UserSettings extends StatefulWidget {
  const UserSettings({Key? key}) : super(key: key);

  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<AppData>(context);
    return Scaffold(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      appBar: AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white,),
          //iconSize: 36.0,
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Settings & Privacy",
          style: TextStyle(
            color: Colors.white,
            //fontSize: 22.0,
            //fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0.0,
        actions: const [
          /*IconButton(
            icon: Icon(Icons.search),
            //iconSize: 36.0,
            color: Colors.white,
            onPressed: (){},
          ),*/
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              decoration: BoxDecoration(
                //color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: const [
                    Icon(
                      FontAwesomeIcons.userLock
                    ),
                    SizedBox(width: 8.0,),
                    Text("Privacy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text("Bio"),
              subtitle: userCurrentInfo!.user_bio != ""?Text(userCurrentInfo!.user_bio!): const Text("No bio available"),
              trailing: SizedBox(
                width: 120.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(
                        FontAwesomeIcons.globeAfrica
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text("Public"),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text("Nickname"),
              subtitle: userCurrentInfo!.user_nickname != ""?Text(userCurrentInfo!.user_nickname!): const Text("No nickname available"),
              trailing: SizedBox(
                width: 120.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(
                        FontAwesomeIcons.globeAfrica
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text("Public"),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text("Phone"),
              subtitle: userCurrentInfo!.user_phone != ""?Text(userCurrentInfo!.user_phone!): const Text("No phone number available"),
              trailing: SizedBox(
                width: 120.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(
                        FontAwesomeIcons.globeAfrica
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text("Public"),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text("Email"),
              subtitle: Text(userCurrentInfo!.user_bio!),
              trailing: SizedBox(
                width: 120.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(
                        FontAwesomeIcons.globeAfrica
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text("Public"),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              decoration: BoxDecoration(
                //color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: const [
                    Icon(
                        FontAwesomeIcons.language
                    ),
                    SizedBox(width: 8.0,),
                    Text("Languages", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              decoration: BoxDecoration(
                //color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: const [
                    Icon(
                        FontAwesomeIcons.lock
                    ),
                    SizedBox(width: 4.0,),
                    Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              decoration: BoxDecoration(
                //color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          MdiIcons.themeLightDark,
                        ),
                        SizedBox(width: 4.0,),
                        Text("Use dark mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                      ],
                    ),
                    Checkbox(
                      value: themeChange.darkTheme,
                      onChanged: (value) {
                        themeChange.darkTheme = value!;
                      }
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
