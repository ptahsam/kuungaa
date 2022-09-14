import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/profile_avatar.dart';
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
    Future.delayed(Duration.zero,() async{
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
        itemCount: Provider.of<AppData>(context).chatUsersList!.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index){
          Contact contact = listContacts[index];
          return InkWell(
            onTap: (){
              //startMessegeUser(context, user.user_id!);
            },
            child: ListTile(
              leading: contact.photo != null?Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: ExtendedFileImageProvider(
                      File.fromRawPath(contact.photo!),
                    ),
                  )
                ),
              ):ProfileAvatar(imageUrl: uProfile),
              title: Text(contact.displayName),
              subtitle: Text(contact.phones[0].number),
            ),
          );
        },
      ):const SizedBox.shrink(),
    );
  }
}
