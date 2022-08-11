import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/select_expression.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:mime/mime.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
class CreatePagePost extends StatefulWidget {
  final String pagename;
  final String pageid;
  const CreatePagePost({
    Key? key,
    required this.pagename,
    required this.pageid
  }) : super(key: key);

  @override
  _CreatePagePostState createState() => _CreatePagePostState();
}

class _CreatePagePostState extends State<CreatePagePost> {

  List<File>? userPageSelectedFileList = [];
  List userPageSelectedTagged = [];

  bool _isButtonDisabled = false;

  String dropdownvalue = 'Public';

  var items =  ['Public','Friends','Only Me'];

  String selectedExpression = "";

  TextEditingController pagePostTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            shadowColor: Colors.transparent,
            backgroundColor: Palette.kuungaaDefault,
            title: Text(widget.pagename,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
            ),
            centerTitle: false,
            floating: true,
            automaticallyImplyLeading: true,
            snap: true,
            elevation: 40.0,
            pinned: true,

            actions: [
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 8.0, 12.0, 8.0),
                child: ElevatedButton(
                  onPressed: _isButtonDisabled? (){
                    savePagePost(widget.pageid);
                  } : null,
                  child: const Text("Post"),
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
                      Row(
                        children: [
                          Text(userCurrentInfo!.user_firstname != null? userCurrentInfo!.user_firstname! + " " + userCurrentInfo!.user_lastname! : ""),
                          selectedExpression != ""? const SizedBox(width: 6.0,):const SizedBox.shrink(),
                          selectedExpression != ""? Text(" - Feeling " + selectedExpression): const SizedBox.shrink(),
                        ],
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                            border: Border.all(
                              width: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: const Text("Public post", style: TextStyle(fontSize: 12.0),)),
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
                controller: pagePostTextEditingController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 5,
                maxLines: 5,
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
                  hintText: 'Write something here',
                  hintStyle: TextStyle(
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"), width: 0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.blueAccent, width: 0.2),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 15.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
                          width: 0.5,

                        ),
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        var res = await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: const FileSelector(allowMultiple: true, isUserPhoto: false,)));
                        setState(() {
                          userPageSelectedFileList = res;
                          if(userPageSelectedFileList!.isNotEmpty){
                            if(_isButtonDisabled){}else{

                              _isButtonDisabled = true;

                            }
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              width: 55.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300],
                              ),
                              child: const Icon(
                                IconData(0xe92e, fontFamily: "icomoon"),
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12.0,),
                            const Expanded(
                              child: Text(
                                  "Photo/Videos"
                              ),
                            ),
                            userPageSelectedFileList!.isNotEmpty ?
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(60.0),
                                ),
                                child: Text(userPageSelectedFileList!.length.toString())
                            ) :
                            const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
                        width: 0.5,

                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () async {
                      var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>const SelectExpression()));
                      if(res != ""){
                        setState(() {
                          selectedExpression = res;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            width: 55.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300],
                            ),
                            child: const Icon(
                              IconData(0xe910, fontFamily: "icomoon"),
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12.0,),
                          const Expanded(
                            child: Text(
                                "Expression"
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
                        width: 0.5,

                      ),
                      bottom: BorderSide(
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"),
                        width: 0.5,

                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () async {
                      var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>const TagUsers()));
                      setState(() {
                        userPageSelectedTagged = res;
                        if(userPageSelectedTagged.isNotEmpty){
                          if(_isButtonDisabled){}else{

                            _isButtonDisabled = true;

                          }
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            width: 55.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300],
                            ),
                            child: const Icon(
                              IconData(0xe939, fontFamily: "icomoon"),
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12.0,),
                          const Expanded(
                            child: Text(
                                "Tag other people"
                            ),
                          ),
                          userPageSelectedTagged.isNotEmpty ?
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(60.0),
                              ),
                              child: Text(userPageSelectedTagged.length.toString())
                          ) :
                          const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void savePagePost(String pageid) async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Uploading your post, Please wait...",);
        }
    );
    DatabaseReference postRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts').push();
    String refKey = postRef.key;
    String postcitylocation = "";
    String postcountrylocation = "";
    String posterId = userCurrentInfo!.user_id!;
    String description = pagePostTextEditingController.text;
    List tagged = [];
    List postmedia = [];
    String postprivacy = "";

    if(dropdownvalue == "Public"){
      postprivacy = "public";
    }else if(dropdownvalue == "Friends"){
      postprivacy = "friends";
    }else{
      postprivacy = "onlyme";
    }

    if(userPageSelectedTagged.isNotEmpty){
      for(var i = 0; i < userPageSelectedTagged.length; i++){
        Tagged tag = Tagged();
        tag = userPageSelectedTagged[i];
        //print("Tagged user" + tag.userid!);
        Map userTaggedDetails = {
          "userid" : tag.userid!
        };
        tagged.add(userTaggedDetails);
      }
    }

    if(userPageSelectedFileList!.isNotEmpty){
      for(var i = 0; i < userPageSelectedFileList!.length; i++){
        String? mimeType = lookupMimeType(userPageSelectedFileList![i].path);
        //print("User selected file" + mimeType!);
        File file = File(userPageSelectedFileList![i].path);
        String basename = path.basename(userPageSelectedFileList![i].path);
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Posts").child(pageid).child(basename);
        //await ref.putFile(file).whenComplete((snapshot) => {});
        firebase_storage.UploadTask uploadTask = ref.putFile(file);

        String imageUrl = await(await uploadTask).ref.getDownloadURL();

        Map postmediadetails = {
          "url" : imageUrl,
          "type" : mimeType
        };

        postmedia.add(postmediadetails);

      }

      var offsetRef = FirebaseDatabase.instance.reference().child(".info/serverTimeOffset");
      offsetRef.onValue.listen((event){
        int offset = event.snapshot.value;
        var posttime = ((DateTime.now().millisecondsSinceEpoch) + offset);
        Map postDataMap = {
          "poster_id" : posterId,
          "post_id" : pageid,
          "post_description" : description,
          "post_time" : posttime,
          "post_category" : "pagesfeed",
          "post_city" : postcitylocation,
          "post_countryname" : postcountrylocation,
          "post_privacy" : postprivacy,
          "post_media" : postmedia,
          "post_tagged" : tagged.isEmpty? "" : tagged,
        };
        postRef.set(postDataMap).then((onValue) {
          displayToastMessage("Your post was uploaded successfully", context);
          imageFileListAll!.clear();
          createNotification(refKey);
          Navigator.pop(context);
          Navigator.pop(context, "created_group_post");
        }).catchError((onError) {
          Navigator.pop(context);
          displayToastMessage("An error occurred. Please try again later", context);
        });
        //print("Server offset: " + posttime);
      });

    }else{
      var offsetRef = FirebaseDatabase.instance.reference().child(".info/serverTimeOffset");
      offsetRef.onValue.listen((event){
        int offset = event.snapshot.value;
        var posttime = ((DateTime.now().millisecondsSinceEpoch) + offset);
        Map postDataMap = {
          "poster_id" : posterId,
          "post_id" : pageid,
          "post_description" : description,
          "post_time" : posttime,
          "post_category" : "pagesfeed",
          "post_city" : postcitylocation,
          "post_countryname" : postcountrylocation,
          "post_privacy" : postprivacy,
          "post_media" : "",
          "post_tagged" : tagged.isEmpty? "" : tagged,
        };
        postRef.set(postDataMap).then((onValue) {
          createNotification(refKey);
          displayToastMessage("Your post was uploaded successfully", context);
          Navigator.pop(context);
          Navigator.pop(context, "created_page_post");
        }).catchError((onError) {
          Navigator.pop(context);
          displayToastMessage("An error occurred. Please try again later", context);
        });
        //print("Server offset: " + posttime);
      });
    }
  }

  void createNotification(String refKey) {
    if(userPageSelectedTagged.isNotEmpty){
      for(var i = 0; i < userPageSelectedTagged.length; i++){
        Tagged tag = Tagged();
        tag = userPageSelectedTagged[i];
        saveGeneralNotification("tagged you in a post", tag.userid!, "tagged", refKey);
      }
    }
  }
}
