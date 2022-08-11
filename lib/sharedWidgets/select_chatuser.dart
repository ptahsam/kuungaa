import 'package:flutter/material.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class SelectChatUser extends StatefulWidget {
  const SelectChatUser({Key? key}) : super(key: key);

  @override
  _SelectChatUserState createState() => _SelectChatUserState();
}

class _SelectChatUserState extends State<SelectChatUser> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: Text("No call history"),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){

        },
        child: Icon(
          MdiIcons.phone,
          color: Colors.white,
        ),
        backgroundColor: Palette.kuungaaDefault,
      ),
    );
  }
}
