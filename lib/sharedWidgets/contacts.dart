import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/profile_avatar.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class UserContacts extends StatefulWidget {
  const UserContacts({Key? key}) : super(key: key);

  @override
  State<UserContacts> createState() => _UserContactsState();
}

class _UserContactsState extends State<UserContacts> {

  List<Contact> listContacts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContactPermission();
  }

  Future getContactPermission() async {
    Future.delayed(Duration.zero,() async {
      if(await FlutterContacts.requestPermission()){
          List<Contact> userContacts = await FlutterContacts.getContacts(
            withProperties: true, withPhoto: true);
          if(userContacts.isNotEmpty){
            setState(() {
              listContacts = userContacts;
            });
          }
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 0.0),
      height: MediaQuery.of(context).size.height,
      child: listContacts.isNotEmpty?
      ListView.builder(
        itemCount: Provider.of<AppData>(context).favoriteContacts!.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index){
          Users users = Provider.of<AppData>(context).favoriteContacts![index];
          return ListTile(
            leading: ProfileAvatar(imageUrl: users.user_profileimage!,),
            title: Text("${users.user_firstname!+" "+users.user_lastname!}"),
            subtitle: Text(users.user_bio!),
            trailing: Container(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: (){
                      startMessegeUser(context, users.user_id!);
                    },
                    child: Icon(
                      Icons.message,
                      color: Palette.kuungaaDefault,
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: (){
                      displayToastMessage("This feature is currently under development.", context);
                    },
                    child: Icon(
                      Icons.call,
                      color: Palette.kuungaaDefault,
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: users.user_id!,)));
                    },
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Palette.kuungaaDefault,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ):const SizedBox.shrink(),
    );
  }
}
