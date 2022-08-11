import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:provider/provider.dart';

import 'widgets.dart';
class UserAbout extends StatefulWidget {
  final Users user;
  const UserAbout({
    Key? key,
    required this.user
  }) : super(key: key);

  @override
  _UserAboutState createState() => _UserAboutState();
}

class _UserAboutState extends State<UserAbout> {
  TextEditingController fieldNameTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          widget.user.user_id == userCurrentInfo!.user_id!? "Your info": widget.user.user_firstname! + "'" + "s" + " info",
          style: const TextStyle(
            color: Colors.white,
            //fontSize: 22.0,
            //fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
              child: widget.user.user_id == userCurrentInfo!.user_id!?Column(
                children: [

                  ListTile(
                    leading: Icon(FontAwesomeIcons.bookReader, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Bio", style: TextStyle(fontSize: 16.0),),
                    subtitle: widget.user.user_bio != ""?Text(widget.user.user_bio!): const Text("No bio"),
                    trailing: widget.user.user_bio != ""?
                    const Icon(Icons.edit)
                        :InkWell(
                        onTap: (){
                          showModalBottomSheet(
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                            ),
                            context: context,
                            builder: (context) => buildAddProfileSheet("user_bio", "bio"),
                          );
                        },
                        child: const Icon(Icons.add)
                    ),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.userNinja, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Nickname", style: TextStyle(fontSize: 16.0),),
                    subtitle: widget.user.user_nickname != ""?Text(widget.user.user_nickname!):const Text("No nickname"),
                    trailing: widget.user.user_nickname != ""?const Icon(Icons.edit)
                        :InkWell(
                        onTap: (){
                          showModalBottomSheet(
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                            ),
                            context: context,
                            builder: (context) => buildAddProfileSheet("user_nickname", "nickname"),
                          );
                        },
                        child: const Icon(Icons.add),
                    ),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.user, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Name", style: TextStyle(fontSize: 16.0),),
                    subtitle: Text(widget.user.user_firstname! + " " + widget.user.user_lastname!),
                    trailing: const Icon(Icons.edit),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.phone, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Contact phone", style: TextStyle(fontSize: 16.0),),
                    subtitle: widget.user.user_phone != ""?Text(widget.user.user_phone!):const Text("No contact phone"),
                    trailing: widget.user.user_phone != ""?const Icon(Icons.edit):const Icon(Icons.add),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.envelope, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Email", style: TextStyle(fontSize: 16.0),),
                    subtitle: widget.user.user_email != ""?Text(widget.user.user_email!):const Text("No email"),
                    //trailing: Icon(Icons.edit),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.birthdayCake, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Birthday", style: TextStyle(fontSize: 16.0),),
                    //subtitle: widget.user.user_birthday != ""?Text(widget.user.user_birthday!.toString()):SizedBox.shrink(),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.venusDouble, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Gender", style: TextStyle(fontSize: 16.0),),
                    subtitle: widget.user.user_gender != ""?Text(widget.user.user_gender!):const SizedBox.shrink(),
                  ),
                ],
              ) : Column(
                children: [
                  ListTile(
                    leading: Icon(FontAwesomeIcons.bookReader, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Bio", style: TextStyle(fontSize: 16.0),),
                    subtitle: widget.user.user_bio != ""?Text(widget.user.user_bio!):const Text("No bio"),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.userNinja, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Nickname", style: TextStyle(fontSize: 16.0),),
                    subtitle: widget.user.user_nickname != ""?Text(widget.user.user_nickname!):const Text("No nickname"),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.user, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Name", style: TextStyle(fontSize: 16.0),),
                    subtitle: Text(widget.user.user_firstname! + " " + widget.user.user_lastname!),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.phone, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Contact phone", style: TextStyle(fontSize: 16.0),),
                    subtitle: widget.user.user_phone != ""?Text(widget.user.user_phone!):const Text("No contact phone"),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.envelope, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Email", style: TextStyle(fontSize: 16.0),),
                    subtitle: widget.user.user_email != ""?Text(widget.user.user_email!):const Text("No email"),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.birthdayCake, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Birthday", style: TextStyle(fontSize: 16.0),),
                    //subtitle: widget.user.user_birthday != ""?Text(widget.user.user_birthday!.toString()):SizedBox.shrink(),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.venusDouble, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey[600]!,),
                    title: const Text("Gender", style: TextStyle(fontSize: 16.0),),
                    subtitle: widget.user.user_gender != ""?Text(widget.user.user_gender!):const Text("No gender"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddProfileSheet(String field, String fieldType) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200]!,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 25.0,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                        saveField(fieldType, field, fieldNameTextEditingController.text);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0, top: 10.0),
              child: TextField(
                onChanged: (value) {
                  //Do something with the user input.
                },
                controller: fieldNameTextEditingController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 1,
                onTap: (){

                },
                style: TextStyle(
                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your ' + fieldType,
                  hintStyle: TextStyle(
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.black54, width: 0.2),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Palette.kuungaaDefault, width: 0.2),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveField(String fieldtype, String field, String text) {
    if(text.isNotEmpty){
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context)
          {
            return ProgressDialog(message: "Uploading your " + fieldtype + ", Please wait...",);
          }
      );
      DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(userCurrentInfo!.user_id!);
      Map<String, dynamic> updateFieldMap = {
        field : text,
      };
      dbRef.update(updateFieldMap).then((onValue) {
        Navigator.pop(context);
        displayToastMessage("Your have added your " + fieldtype +" successfully", context);

      }).catchError((onError) {
        displayToastMessage("An error occurred. Please try again later", context);
      });
    }
  }
}
