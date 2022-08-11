import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class ContactList extends StatefulWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethods.getUserFavoriteContacts(context);
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.0,
      child: Provider.of<AppData>(context).favoriteContacts != null ?ListView.builder(
        padding: const EdgeInsets.only(left: 10.0),
        scrollDirection: Axis.horizontal,
        itemCount: Provider.of<AppData>(context).favoriteContacts!.length,
        itemBuilder: (BuildContext context, int index)
        {
          Users user = Provider.of<AppData>(context).favoriteContacts![index];
          return InkWell(
            onTap: (){
              startMessegeUser(context, user.user_id!);
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 55.0,
                    width: 55.0,
                    child: Stack(
                      children: [
                        ProfileAvatar(imageUrl: user.user_profileimage!, radius: 26.0, hasBorder: true, borderWidth: 24.0, backGroundColor: "#ffffff",),
                        Positioned(
                          bottom: 7.0,
                          right: 7.0,
                          child: user.isOnline?Container(
                            height: 8.0,
                            width: 8.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Palette.kuungaaDefault
                            ),
                          ):Container(
                            height: 8.0,
                            width: 8.0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red
                            ),
                          ),
                        ),
                      ],
                    )),
                  const SizedBox(height: 3.0,),
                  Text(
                    user.user_firstname!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );

        },
      ):SizedBox.shrink(),
    );
  }

  Future<List> getContactList() async{
    List<Users> contactList = [];
    DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users");
    await dbReference.once().then((DataSnapshot dataSnapshot){
      contactList.clear();
      var keys = dataSnapshot.value.keys;
      var values = dataSnapshot.value;

      for (var key in keys)
      {
        if(userCurrentInfo!.user_id != values [key]["user_id"]){
          Users users = Users();
          users.user_id = values [key]["user_id"];
          users.user_firstname = values [key]["user_firstname"];
          users.user_lastname = values [key]["user_lastname"];
          users.user_profileimage = values [key]["user_profileimage"];

          contactList.add(users);
        }
      }
    });
    return contactList;
  }
}
