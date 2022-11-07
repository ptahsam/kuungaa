import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/allScreens/screens.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/select_expression.dart';
import 'package:mime/mime.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

import 'widgets.dart';

class CreatePost extends StatefulWidget {

  final Posts? post;

  final bool isSelectMedia;

  final bool isSelectExpression;

  const CreatePost({
    Key? key,
    this.post,
    required this.isSelectMedia,
    required this.isSelectExpression
  }) : super(key: key);

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {

  TextEditingController postTextEditingController = TextEditingController();
  List<File>? userSelectedFileList = [];
  List? userSelectedTagged = [];

  bool _isButtonDisabled = false;

  String dropdownvalue = 'Public';

  var items =  ['Public','Friends','Only Me'];

  String selectedExpression = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.isSelectMedia){
      getUserMedia();
    }
    if(widget.isSelectExpression){
      getUserExpression();
    }

    if(widget.post != null){
      selectedExpression = widget.post!.post_expression!;
      postTextEditingController.text = widget.post!.post_description!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,
            pinned: true,
            leadingWidth: 30.0,
            leading: InkWell(
              onTap:()
              {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
              ),
            ),
            title: Text("${widget.post != null?"Edit Post":"Create a post"}", style: TextStyle(fontSize: 18.0, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black)),
            actions: [
              Container(
                padding: const EdgeInsets.only(right: 12.0, top: 5.0, bottom: 5.0),
                child: ElevatedButton(
                  onPressed: _isButtonDisabled? (){
                    savePost();
                  } : null,
                  child: widget.post != null?Text("Update"):Text("Post"),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ProfileAvatar(imageUrl: userCurrentInfo != null?userCurrentInfo!.user_profileimage! : "", radius: 28.0,),
                      const SizedBox(width: 10.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15.0,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userCurrentInfo!.user_firstname != null? userCurrentInfo!.user_firstname! + " " + userCurrentInfo!.user_lastname! : "", maxLines: 1, overflow: TextOverflow.fade,),
                              //selectedExpression != ""? const SizedBox(width: 6.0,):const SizedBox.shrink(),
                              selectedExpression != ""? Text(" - Feeling " + selectedExpression, maxLines: 1, overflow: TextOverflow.fade,): const SizedBox.shrink(),
                            ],
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton(

                              value: dropdownvalue,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items:items.map((String items) {
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
                                  dropdownvalue = newValue!.toString();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  child: TextField(
                    onChanged: (value) {
                      //Do something with the user input.
                    },
                    controller: postTextEditingController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 5,
                    maxLines: 5,
                    style: TextStyle(
                      color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                    ),
                    onTap: (){
                      if(_isButtonDisabled){}else{
                        setState(() {
                          _isButtonDisabled = true;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                      hintText: 'Type something here',
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
                Container(
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
                            getUserMedia();
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
                                userSelectedFileList!.isNotEmpty ?
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(60.0),
                                    ),
                                    child: Text(userSelectedFileList!.length.toString())
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
                Column(
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
                          getUserExpression();
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
                Column(
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
                            userSelectedTagged = res;
                            if(userSelectedTagged!.isNotEmpty){
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
                              userSelectedTagged!.isNotEmpty ?
                              Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(60.0),
                                  ),
                                  child: Text(userSelectedTagged!.length.toString())
                              ) :
                              const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void savePost() async{
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
    String description = postTextEditingController.text;
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

    if(userSelectedTagged!.isNotEmpty){
      for(var i = 0; i < userSelectedTagged!.length; i++){
        Tagged tag = Tagged();
        tag = userSelectedTagged![i];
        Map userTaggedDetails = {
          "userid" : tag.userid!
        };
        tagged.add(userTaggedDetails);
      }
    }

    if(userSelectedFileList!.isNotEmpty){
      for(var i = 0; i < userSelectedFileList!.length; i++){
        String? mimeType = lookupMimeType(userSelectedFileList![i].path);
        String basename = path.basename(userSelectedFileList![i].path);
        //print("User selected file" + mimeType! + " :: "+basename);
        File file = File(userSelectedFileList![i].path);
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Posts").child(refKey).child(basename);
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
          "post_id" : refKey,
          "post_description" : description,
          "post_time" : posttime,
          "post_category" : "newsfeed",
          "post_city" : postcitylocation,
          "post_countryname" : postcountrylocation,
          "post_privacy" : postprivacy,
          "post_media" : postmedia,
          "post_tagged" : tagged.isEmpty? "" : tagged,
          "post_expression" : selectedExpression,
        };
        postRef.set(postDataMap).then((onValue) {
          imageFileListAll!.clear();
          //taggedUsers.clear();
          createNotification(refKey);
          print("sending notif in post");
          Navigator.pushNamedAndRemoveUntil(context, NavScreen.idScreen, (route) => false);
          displayToastMessage("Your post was uploaded successfully", context);
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
          "post_id" : refKey,
          "post_description" : description,
          "post_time" : posttime,
          "post_category" : "newsfeed",
          "post_city" : postcitylocation,
          "post_countryname" : postcountrylocation,
          "post_privacy" : postprivacy,
          "post_media" : "",
          "post_tagged" : tagged.isEmpty? "" : tagged,
          "post_expression" : selectedExpression,
        };
        postRef.set(postDataMap).then((onValue) {
          createNotification(refKey);
          Navigator.pushNamedAndRemoveUntil(context, NavScreen.idScreen, (route) => false);
          displayToastMessage("Your post was uploaded successfully", context);
        }).catchError((onError) {
          Navigator.pop(context);
          displayToastMessage("An error occurred. Please try again later", context);
        });
        //print("Server offset: " + posttime);
      });
    }
  }

  Future<void> getUserExpression() async{
    Future.delayed(Duration.zero,()
    async{
      var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>const SelectExpression()));
      if(res != "" || res != null){
        setState(() {
          selectedExpression = res;
        });
      }
    });
  }

  Future<void> getUserMedia() async {
    Future.delayed(Duration.zero,()
    async {
      var res = await Navigator.push(context, PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const FileSelector(allowMultiple: true, isUserPhoto: false,)));
      if(res != "" && res != null){
        setState(() {
          userSelectedFileList = res;
          if (userSelectedFileList!.isNotEmpty) {
            if (_isButtonDisabled) {} else {
              _isButtonDisabled = true;
            }
          }
        });
      }
    });
  }

  void createNotification(String refKey) {
    if(userSelectedTagged!.isNotEmpty){
      for(var i = 0; i < userSelectedTagged!.length; i++){
        Tagged tag = Tagged();
        tag = userSelectedTagged![i];
        saveGeneralNotification("tagged you in a post", tag.userid!, "tagged", refKey);
      }
    }
  }

}

displayToastMessage(String message, BuildContext context)
{
  Fluttertoast.showToast(msg: message);
}


