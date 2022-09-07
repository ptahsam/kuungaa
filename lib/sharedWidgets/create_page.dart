

import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
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

class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {

  bool _isButtonDisabled = false;
  String privacyDropdownvalue = 'public';
  var privacyItems =  ['public','private'];
  TextEditingController pageNameTextEditingController = TextEditingController();
  TextEditingController categoryNameTextEditingController = TextEditingController();
  TextEditingController descriptionTextEditingController = TextEditingController();

  File? userSelectedPageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            shadowColor: Colors.transparent,
            backgroundColor: Palette.kuungaaDefault,
            title: Text("Create a page",
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
                    createPage();
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
                controller: pageNameTextEditingController,
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
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black
                ),
                decoration: InputDecoration(
                  hintText: 'Enter page name',
                  hintStyle: TextStyle(
                      color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black
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
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: TextField(
                onChanged: (value) {
                  //Do something with the user input.
                },
                controller: categoryNameTextEditingController,
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
                  hintText: 'Categories i.e food, sports, gaming e.t.c',
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
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: TextField(
                onChanged: (value) {
                  //Do something with the user input.
                },
                controller: descriptionTextEditingController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 2,
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
                  hintText: 'Enter page description',
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Upload page icon", style: TextStyle(fontWeight: FontWeight.bold),),
                  const SizedBox(height: 6.0,),
                  userSelectedPageFile != null? Stack(
                    children: [
                      Container(
                        height: 200.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(userSelectedPageFile!),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            width: 0.5,
                            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
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
                              userSelectedPageFile = res;
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
                              userSelectedPageFile = res;
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


  createPage() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Creating your page, Please wait...",);
        }
    );

    if(pageNameTextEditingController.text.isNotEmpty && categoryNameTextEditingController.text.isNotEmpty && descriptionTextEditingController.text.isNotEmpty && userSelectedPageFile != null){
      DatabaseReference pageRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Pages').push();
      String pageKey = pageRef.key;

      File file = File(userSelectedPageFile!.path);
      String basename = path.basename(userSelectedPageFile!.path);

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Pages").child("icons").child(pageKey).child(basename);
      //await ref.putFile(file).whenComplete((snapshot) => {});
      firebase_storage.UploadTask uploadTask = ref.putFile(file);

      String imageUrl = await(await uploadTask).ref.getDownloadURL();

        int pagetime = DateTime.now().millisecondsSinceEpoch;;

        Map pageDataMap = {
          "page_name": pageNameTextEditingController.text,
          "page_category": categoryNameTextEditingController.text,
          "page_description": descriptionTextEditingController.text,
          "page_creator": userCurrentInfo!.user_id!,
          "page_icon": imageUrl,
          "page_createddate": pagetime,
          "page_id": pageKey
        };
        pageRef.set(pageDataMap).then((onValue) {
          DatabaseReference pageMembersRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Pages').child(pageKey).child("members");

          Map pageMemberDataMap = {
            userCurrentInfo!.user_id! : userCurrentInfo!.user_id!,
          };
          pageMembersRef.set(pageMemberDataMap);
          displayToastMessage("Your page was created successfully", context);
          Navigator.pop(context);
          Navigator.pop(context);
          //Navigator.pushNamedAndRemoveUntil(context, NavScreen.idScreen, (route) => false);
        }).catchError((onError) {
          Navigator.pop(context);
          displayToastMessage("An error occurred. Please try again later", context);
        });
        //print("Server offset: " + posttime);
    }
  }
}


