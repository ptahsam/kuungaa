import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/Models/user.dart';
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

class CreateGroupPost extends StatefulWidget {
  final Posts? post;
  final String groupname;
  final String groupid;
  final String groupicon;
  const CreateGroupPost({
    Key? key,
    this.post,
    required this.groupname,
    required this.groupid,
    required this.groupicon
  }) : super(key: key);

  @override
  _CreateGroupPostState createState() => _CreateGroupPostState();
}

class _CreateGroupPostState extends State<CreateGroupPost> {

  List<File>? userGroupSelectedFileList = [];
  List userGroupSelectedTagged = [];

  bool _isButtonDisabled = false;

  String dropdownvalue = 'Public';

  var items =  ['Public','Friends','Only Me'];

  String selectedExpression = "";

  TextEditingController groupPostTextEditingController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userGroupSelectedFileList!.clear();
    userGroupSelectedTagged.clear();
    taggedUsers.clear();
    groupPostTextEditingController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.post != null){
      //selectedExpression = widget.post!.post_expression!=null||
       //   widget.post!.post_expression!=""?widget.post!.post_expression!:"";
      groupPostTextEditingController.text = widget.post!.post_description!=null||
          widget.post!.post_description!=""?widget.post!.post_description!:"";
      setTaggedUser();
      getEditPostMedia();
    }
  }

  setTaggedUser() async {
    if(widget.post!.taggedUsers!.isNotEmpty){
      for(var i = 0; i < widget.post!.taggedUsers!.length; i++){
        Users user = widget.post!.taggedUsers![i];
        Tagged tagged = Tagged();
        tagged.userid = user.user_id!;
        setState(() {
          taggedUsers.add(tagged);
          userGroupSelectedTagged = taggedUsers;
        });
      }
    }
  }

  getEditPostMedia() async {
    List<Media> mediaList = await getPostMediaImages(widget.post!.post_id!);
    if(mediaList.isNotEmpty){
      for(var i = 0; i < mediaList.length; i++){
        File file = await convertUriToFile(mediaList[i].url!);
        setState(() {
          userGroupSelectedFileList!.add(file);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            shadowColor: Colors.transparent,
            backgroundColor: Palette.kuungaaDefault,
            title: Text(widget.groupname,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                )
            ),
            centerTitle: false,
            floating: true,
            automaticallyImplyLeading: true,
            actionsIconTheme: IconThemeData(opacity: 0.0),
            snap: true,
            elevation: 40.0,
            pinned: true,
            actions: [
              Container(
                margin: EdgeInsets.only(right: 12.0, bottom: 5, top: 5),
                child: InkWell(
                  onTap: (){
                    if(selectedExpression != "" || groupPostTextEditingController.text.isNotEmpty
                        || userGroupSelectedFileList!.isNotEmpty || userGroupSelectedTagged.isNotEmpty){
                      if(widget.post != null){
                        updateGroupPost(widget.groupid);
                      }else {
                        saveGroupPost(widget.groupid);
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                    ),
                    child: widget.post != null?Center(
                      child: Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                    ):Center(
                      child: Text(
                        "Post",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
            flexibleSpace: ExtendedImage.network(
              widget.groupicon,
              fit: BoxFit.cover,
            ),
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
                controller: groupPostTextEditingController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                enableInteractiveSelection: true,
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
                          userGroupSelectedFileList = res;
                          if(userGroupSelectedFileList!.isNotEmpty){
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
                            userGroupSelectedFileList!.isNotEmpty ?
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(60.0),
                                ),
                                child: Text(userGroupSelectedFileList!.length.toString())
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
                        userGroupSelectedTagged = res;
                        if(userGroupSelectedTagged.isNotEmpty){
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
                          userGroupSelectedTagged.isNotEmpty ?
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(60.0),
                              ),
                              child: Text(userGroupSelectedTagged.length.toString())
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

  void updateGroupPost(String groupid)
  async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Updating your post, Please wait...",);
        }
    );

    DatabaseReference postRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts').child(widget.post!.post_id!);
    String refKey = widget.post!.post_id!;
    String postcitylocation = "";
    String postcountrylocation = "";
    String posterId = userCurrentInfo!.user_id!;
    String description = groupPostTextEditingController.text;
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

    if(userGroupSelectedTagged.isNotEmpty){
      for(var i = 0; i < userGroupSelectedTagged.length; i++){
        Tagged tag = Tagged();
        tag = userGroupSelectedTagged[i];
        //print("Tagged user" + tag.userid!);
        Map userTaggedDetails = {
          "userid" : tag.userid!
        };
        tagged.add(userTaggedDetails);
      }
    }

    if(userGroupSelectedFileList!.isNotEmpty){
      firebase_storage.Reference fRef = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Posts").child(groupid);
      await fRef.listAll().then((result) async {
        for (var file in result.items) {
          file.delete();
        }
      });

      for(var i = 0; i < userGroupSelectedFileList!.length; i++){
        String? mimeType = lookupMimeType(userGroupSelectedFileList![i].path);
        //print("User selected file" + mimeType!);
        File file = File(userGroupSelectedFileList![i].path);
        String basename = path.basename(userGroupSelectedFileList![i].path);
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Posts").child(groupid).child(basename);
        //await ref.putFile(file).whenComplete((snapshot) => {});
        firebase_storage.UploadTask uploadTask = ref.putFile(file);

        String imageUrl = await(await uploadTask).ref.getDownloadURL();

        Map postmediadetails = {
          "url" : imageUrl,
          "type" : mimeType
        };
        postmedia.add(postmediadetails);
      }

      var posttime = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> postDataMap = {
        "poster_id" : posterId,
        "post_id" : groupid,
        "post_description" : description,
        "post_time" : posttime,
        "post_category" : "groupsfeed",
        "post_city" : postcitylocation,
        "post_countryname" : postcountrylocation,
        "post_privacy" : postprivacy,
        "post_media" : postmedia,
        "post_tagged" : tagged,
      };
      postRef.update(postDataMap).then((onValue) {
        displayToastMessage("Your post was updated successfully", context);
        imageFileListAll!.clear();
        createNotification(refKey);
        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((onError) {
        Navigator.pop(context);
        displayToastMessage("An error occurred. Please try again later", context);
      });
    }else{
      var posttime = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> postDataMap = {
        "poster_id" : posterId,
        "post_id" : groupid,
        "post_description" : description,
        "post_time" : posttime,
        "post_category" : "groupsfeed",
        "post_city" : postcitylocation,
        "post_countryname" : postcountrylocation,
        "post_privacy" : postprivacy,
        "post_media" : "",
        "post_tagged" : tagged,
      };
      postRef.update(postDataMap).then((onValue) {
        createNotification(refKey);
        displayToastMessage("Your post was updated successfully", context);
        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((onError) {
        Navigator.pop(context);
        displayToastMessage("An error occurred. Please try again later", context);
      });
    }
  }

  void saveGroupPost(String groupid) async{
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
    String description = groupPostTextEditingController.text;
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

    if(userGroupSelectedTagged.isNotEmpty){
      for(var i = 0; i < userGroupSelectedTagged.length; i++){
        Tagged tag = Tagged();
        tag = userGroupSelectedTagged[i];
        //print("Tagged user" + tag.userid!);
        Map userTaggedDetails = {
          "userid" : tag.userid!
        };
        tagged.add(userTaggedDetails);
      }
    }

    if(userGroupSelectedFileList!.isNotEmpty){
      for(var i = 0; i < userGroupSelectedFileList!.length; i++){
        String? mimeType = lookupMimeType(userGroupSelectedFileList![i].path);
        //print("User selected file" + mimeType!);
        File file = File(userGroupSelectedFileList![i].path);
        String basename = path.basename(userGroupSelectedFileList![i].path);
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Posts").child(groupid).child(basename);
        //await ref.putFile(file).whenComplete((snapshot) => {});
        firebase_storage.UploadTask uploadTask = ref.putFile(file);

        String imageUrl = await(await uploadTask).ref.getDownloadURL();

        Map postmediadetails = {
          "url" : imageUrl,
          "type" : mimeType
        };

        postmedia.add(postmediadetails);

      }

      var posttime = ((DateTime.now().millisecondsSinceEpoch));
      Map postDataMap = {
        "poster_id" : posterId,
        "post_id" : groupid,
        "post_description" : description,
        "post_time" : posttime,
        "post_category" : "groupsfeed",
        "post_city" : postcitylocation,
        "post_countryname" : postcountrylocation,
        "post_privacy" : postprivacy,
        "post_media" : postmedia,
        "post_tagged" : tagged,
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

    }else{
      var posttime = ((DateTime.now().millisecondsSinceEpoch));
      Map postDataMap = {
        "poster_id" : posterId,
        "post_id" : groupid,
        "post_description" : description,
        "post_time" : posttime,
        "post_category" : "groupsfeed",
        "post_city" : postcitylocation,
        "post_countryname" : postcountrylocation,
        "post_privacy" : postprivacy,
        "post_media" : "",
        "post_tagged" : tagged,
      };
      postRef.set(postDataMap).then((onValue) {
        createNotification(refKey);
        displayToastMessage("Your post was uploaded successfully", context);
        Navigator.pop(context);
        Navigator.pop(context, "created_group_post");
      }).catchError((onError) {
        Navigator.pop(context);
        displayToastMessage("An error occurred. Please try again later", context);
      });
    }
  }

  void createNotification(String refKey) {
    if(userGroupSelectedTagged.isNotEmpty){
      for(var i = 0; i < userGroupSelectedTagged.length; i++){
        Tagged tag = Tagged();
        tag = userGroupSelectedTagged[i];
        saveGeneralNotification("tagged you in a post", tag.userid!, "tagged", refKey);
      }
    }
  }

}
