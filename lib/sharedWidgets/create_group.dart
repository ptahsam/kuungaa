

import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

import 'widgets.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {

  bool _isButtonDisabled = false;
  String privacyDropdownvalue = 'public';
  var privacyItems =  ['public','private'];
  TextEditingController groupNameTextEditingController = TextEditingController();

  File? userSelectedGroupFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            shadowColor: Colors.transparent,
            backgroundColor: Palette.kuungaaDefault,
            title: Text("Create a group",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                )
            ),
            centerTitle: false,
            floating: true,
            automaticallyImplyLeading: true,
            snap: true,
            elevation: 40.0,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.green,
                ),
                iconSize: 22.0,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 8.0, 12.0, 8.0),
                child: ElevatedButton(
                  onPressed: _isButtonDisabled? (){
                    createGroup();
                  } : null,
                  child: const Text("Create"),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ProfileAvatar(imageUrl: userCurrentInfo != null?userCurrentInfo!.user_profileimage! : "", radius: 22.0,),
                  const SizedBox(width: 10.0,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userCurrentInfo!.user_firstname != null? userCurrentInfo!.user_firstname! + " " + userCurrentInfo!.user_lastname! : ""),
                      const Text("Admin", style: TextStyle(fontSize: 12.0, color: Palette.kuungaaDefault),),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: TextField(
                onChanged: (value) {
                  //Do something with the user input.
                },
                controller: groupNameTextEditingController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 2,
                onTap: (){
                  if(_isButtonDisabled){}else{
                    setState(() {
                      _isButtonDisabled = true;
                    });
                  }
                },
                style: TextStyle(
                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter group name',
                  hintStyle: TextStyle(
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.black54, width: 0.2),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Palette.kuungaaDefault, width: 0.2),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(top: 10.0),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text("Select privacy", style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                const SizedBox(height: 6.0,),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.5,
                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      hint: const Text("Select privacy"),
                      isExpanded: true,
                      value: privacyDropdownvalue,
                      //value: categories[0],
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items:privacyItems.map((String items) {
                        return DropdownMenuItem(
                            value: items,
                            child: Row(
                              children: [
                                Text(items, style: const TextStyle(fontSize: 14.0),),
                              ],
                            )
                        );
                      }
                      ).toList(),

                      onChanged: (newValue){
                        setState(() {
                          privacyDropdownvalue = newValue!.toString();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Upload group icon", style: TextStyle(fontWeight: FontWeight.bold),),
                  const SizedBox(height: 6.0,),
                  userSelectedGroupFile != null? Stack(
                    children: [
                      Container(
                        height: 200.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(userSelectedGroupFile!),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            width: 0.5,
                            color: HexColor("#ced4da"),
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),

                      ),
                      Positioned(
                        right: 8.0,
                        top: 4.0,
                        child: ElevatedButton(
                          onPressed:  () async {
                            var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>const FileSelector(allowMultiple: false, isUserPhoto: true,)));
                            setState(() {
                              userSelectedGroupFile = res;
                            });
                          },
                          child: const Text("Change"),
                        ),
                      ),
                    ],
                  ): Stack(
                    children: [
                      Container(
                          height: 200.0,
                          decoration: BoxDecoration(
                            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100],
                            border: Border.all(
                              width: 0.5,
                              color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:HexColor("#ced4da"),
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Center(
                            child: Icon(
                              FontAwesomeIcons.image,
                              size: 40.0,
                              color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                            ),
                          )
                      ),
                      Positioned(
                        right: 8.0,
                        top: 4.0,
                        child: ElevatedButton(
                          onPressed:  () async {
                            var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>const FileSelector(allowMultiple: false, isUserPhoto: true,)));
                            setState(() {
                              userSelectedGroupFile = res;
                            });
                          },
                          child: const Text("Select"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  createGroup() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Creating your group, Please wait...",);
        }
    );

    if(groupNameTextEditingController.text.isNotEmpty && privacyDropdownvalue.isNotEmpty && userSelectedGroupFile != null){
      DatabaseReference groupRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Groups').push();
      String groupKey = groupRef.key;

      File file = File(userSelectedGroupFile!.path);
      String basename = path.basename(userSelectedGroupFile!.path);

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Groups").child("icons").child(groupKey).child(basename);
      //await ref.putFile(file).whenComplete((snapshot) => {});
      firebase_storage.UploadTask uploadTask = ref.putFile(file);

      String imageUrl = await(await uploadTask).ref.getDownloadURL();

      var offsetRef = FirebaseDatabase.instance.reference().child(".info/serverTimeOffset");
      offsetRef.onValue.listen((event){
        int offset = event.snapshot.value;
        var grouptime = ((DateTime.now().millisecondsSinceEpoch) + offset);
        Map groupDataMap = {
          "group_createddate" : grouptime.toString(),
          "group_creator" : userCurrentInfo!.user_id!,
          "group_name" : groupNameTextEditingController.text,
          "group_icon" : imageUrl,
          "group_privacy" : privacyDropdownvalue,
          "group_id" : groupKey,
        };
        groupRef.set(groupDataMap).then((onValue) {
          DatabaseReference groupMembersRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Groups').child(groupKey).child("members");

          Map groupMemberDataMap = {
            userCurrentInfo!.user_id! : userCurrentInfo!.user_id!,
          };
          groupMembersRef.set(groupMemberDataMap);
          displayToastMessage("Your group was created successfully", context);
          Navigator.pop(context);
          Navigator.pop(context);
          //Navigator.pushNamedAndRemoveUntil(context, NavScreen.idScreen, (route) => false);
        }).catchError((onError) {
          Navigator.pop(context);
          displayToastMessage("An error occurred. Please try again later", context);
        });
        //print("Server offset: " + posttime);
      });
    }
  }
}


