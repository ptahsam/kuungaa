import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/comment.dart';
import 'package:kuungaa/Models/like.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';

import '../config/config.dart';
import '../config/palette.dart';
import 'widgets.dart';
class PostComments extends StatefulWidget {
  final String postid;
  final String posterid;
  const PostComments({
    Key? key,
    required this.postid,
    required this.posterid
  }) : super(key: key);

  @override
  State<PostComments> createState() => _PostCommentsState();
}

class _PostCommentsState extends State<PostComments> {
  late FocusNode myFocusNode;
  TextEditingController commentTextEditingController = TextEditingController();

  List<Comments> listComments = [];
  DatabaseReference? itemRefComment;
  String tagid = "";
  bool isContainerVisible = false;
  bool isBoxVisible = false;
  bool commentsExists = false;
  Users? selectedUser, replyUser;
  String commentType = "main-comment";
  String replycommentid = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFocusNode = FocusNode();
    myFocusNode.requestFocus();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefComment = database.reference().child('KUUNGAA').child("Posts").child(widget.postid).child("comments");
    itemRefComment!.onChildAdded.listen(_onEntryAddedComment);
    itemRefComment!.onChildChanged.listen(_onEntryChangedComment);
    itemRefComment!.onChildRemoved.listen(_onEntryRemovedComment);
    database.reference().child('KUUNGAA').child("Posts").child(widget.postid).child("comments").once()
        .then(_onComments);
  }

  _onComments(DataSnapshot snapshot){
    if(snapshot.exists){
      if(snapshot.value != "" || snapshot.value != null){
        setState(() {
          commentsExists = true;
        });
      }
    }
  }

  _onEntryAddedComment(Event event) async {
    Comments comments = Comments();
    comments.comment_user = await AssistantMethods.getCurrentOnlineUser(event.snapshot.value["commenter_id"]);
    comments.comment_id = event.snapshot.value["comment_id"];
    comments.comment_text = event.snapshot.value["comment_text"];
    comments.comment_time = event.snapshot.value["comment_time"];
    comments.commenter_id = event.snapshot.value["commenter_id"];
    comments.post_id = event.snapshot.value["post_id"];
    comments.tag_id = event.snapshot.value["tagid"];
    if(event.snapshot.value["tagid"] != ""){
      comments.tagged_user = await AssistantMethods.getCurrentOnlineUser(event.snapshot.value["tagid"]);
    }
    setState(() {
      listComments.add(comments);
    });
  }

  _onEntryChangedComment(Event event) async {
    var old = listComments.singleWhere((entry) {
      return entry.comment_id == event.snapshot.key;
    });
    Comments comments = Comments();
    comments.comment_user = await AssistantMethods.getCurrentOnlineUser(event.snapshot.value["commenter_id"]);
    comments.comment_id = event.snapshot.value["comment_id"];
    comments.comment_text = event.snapshot.value["comment_text"];
    comments.comment_time = event.snapshot.value["comment_time"];
    comments.commenter_id = event.snapshot.value["commenter_id"];
    comments.post_id = event.snapshot.value["post_id"];
    comments.tag_id = event.snapshot.value["tagid"];
    if(event.snapshot.value["tagid"] != ""){
      comments.tagged_user = await AssistantMethods.getCurrentOnlineUser(event.snapshot.value["tagid"]);
    }
    setState(() {
      listComments[listComments.indexOf(old)] = comments;
    });
  }

  _onEntryRemovedComment(Event event) async {
    var removed = listComments.singleWhere((entry) {
      return entry.comment_id == event.snapshot.key;
    });

    setState(() {
      listComments.removeWhere((Comments comments) => comments.comment_id == removed.comment_id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:HexColor("#e9ecef"),
      appBar: AppBar(
        title: Text("Comments"),
        centerTitle: false,
        backgroundColor: Palette.kuungaaDefault,
      ),
      body: Stack(
        children: [
          commentsExists?
          listComments.isNotEmpty?Container(
            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 40.0, bottom: 90.0),
            child: FirebaseAnimatedList(
              query: itemRefComment!,
              itemBuilder:(_, DataSnapshot snapshot, Animation<double> animation, int index){
                Comments comment = listComments[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ProfileAvatar(imageUrl: comment.comment_user!.user_profileimage!, radius: 14.0,),
                          const SizedBox(width: 4.0,),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.comment_user!.user_firstname! + " " + comment.comment_user!.user_lastname!,
                                    style: TextStyle(
                                      color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      InkWell(
                        onLongPress: (){
                          if(widget.posterid == userCurrentInfo!.user_id! || comment.comment_id == userCurrentInfo!.user_id!) {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(15.0)),
                              ),
                              context: context,
                              builder: (context) => buildCommentSheet(comment),
                            );
                          }
                        },
                        child: Container(
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                                padding: const EdgeInsets.fromLTRB(10.0, 15.0, 15.0, 10.0),
                                decoration: BoxDecoration(
                                  color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:HexColor("#e9ecef"),

                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    comment.tagged_user != null?Text(
                                      "#" + comment.tagged_user!.user_firstname! + " " + comment.tagged_user!.user_lastname!,
                                      style: TextStyle(
                                        color: HexColor("#4285F4"),
                                      ),
                                    ):SizedBox.shrink(),
                                    Text(comment.comment_text!),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 0.0,
                                bottom: 2.0,
                                child: MainCommentLikes(postid: widget.postid, commentid: comment.comment_id!,),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.fromLTRB(20.0, 5.0, 0.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            LikeMainComment(postid: widget.postid,commentid: comment.comment_id!,),
                            SizedBox(width: 7.0,),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  if(isBoxVisible){
                                    isBoxVisible = false;
                                  }else{
                                    isBoxVisible = true;
                                  }
                                });
                                commentType = "main-comment-reply";
                                replycommentid = comment.comment_id!;
                                replyUser = comment.comment_user!;
                                myFocusNode.requestFocus();
                              },
                              child: Text(
                                "Reply",
                                style: TextStyle(
                                    //color: HexColor("#999999"),
                                    fontSize: 14.0
                                ),
                              ),
                            ),
                            SizedBox(width: 7.0,),
                            Text(
                              convertToTimeAgo(comment.comment_time!),
                              style: TextStyle(
                                  //color: HexColor("#999999"),
                                  fontSize: 14.0
                              ),
                            ),
                          ],
                        ),
                      ),
                      ChildComment(postid: widget.postid, posterid:widget.posterid, commentid: comment.comment_id!, parentComment: comment, childcommentid: '', type: 'child-comment',),
                    ],
                  ),
                );
              }
            ),
          ):Align(
            alignment: Alignment.center,
            child: Center(
                child: LoadingAnimationWidget.flickr(
                    leftDotColor: Palette.kuungaaDefault,
                    rightDotColor: Colors.black,
                    size: 40
                ),
            ),
          ): Align(
            alignment: Alignment.center,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.13,
              width: MediaQuery.of(context).size.width * 0.65,
              decoration: BoxDecoration(
                color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[100]!,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.comment,
                      color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                    ),
                    SizedBox(height: 6.0,),
                    Text("No comments", textAlign: TextAlign.center,),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            left: 0.0,
            child: Column(
              children: [
                Visibility(
                  visible: isContainerVisible,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                      border: Border.all(
                        width: 0.9,
                        color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:HexColor("#e9ecef"),
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: FutureBuilder(
                      future: getTagUsers(),
                      builder: (context, AsyncSnapshot<List> snapshot){
                        if(snapshot.connectionState == ConnectionState.done){
                          if(snapshot.hasData){
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, int index){
                                Users user = snapshot.data![index];
                                return InkWell(
                                  onTap: (){
                                    selectedUser = user;
                                    toggleContainer();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                                    child: Row(
                                      children: [
                                        ProfileAvatar(imageUrl: user.user_profileimage!),
                                        SizedBox(width: 8.0,),
                                        Text(user.user_firstname! + " " + user.user_lastname!),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }else{
                            return Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.13,
                                width: MediaQuery.of(context).size.width * 0.65,
                                decoration: BoxDecoration(
                                  color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:Colors.grey[100]!,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        MdiIcons.alert,
                                        color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                      ),
                                      SizedBox(height: 6.0,),
                                      Text("No data", textAlign: TextAlign.center,),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        }else{
                          return Align(
                            alignment: Alignment.center,
                            child: Center(
                              child: LoadingAnimationWidget.flickr(
                                leftDotColor: Palette.kuungaaDefault,
                                rightDotColor: Colors.black,
                                size: 40
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: isBoxVisible,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                      border: Border.all(
                        width: 0.9,
                        color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:HexColor("#e9ecef"),
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        replyUser != null?
                        Text(
                          "Reply to " + replyUser!.user_firstname! + " " + replyUser!.user_lastname!,
                        ):SizedBox.shrink(),
                        InkWell(
                          onTap: (){
                            setState((){
                              isBoxVisible = false;
                              commentType = "main-comment";
                              replycommentid = "";
                              replyUser = null;
                            });
                          },
                          child: Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:HexColor("#e9ecef"),
                        width: 1.0,
                      ),
                    ),
                    color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 15.0, left: 12.0, right: 12.0, bottom: 15.0),
                    child: Row(
                      children: [
                        ProfileAvatar(imageUrl: userCurrentInfo!.user_profileimage!=null? userCurrentInfo!.user_profileimage! : "https://firebasestorage.googleapis.com/v0/b/kuungaa-42ba2.appspot.com/o/KUUNGAA%2Fimages%2Fprofile.jpg?alt=media&token=8426002b-381d-4dfb-98aa-b49570cd1303", radius: 18.0,),
                        const SizedBox(width: 4.0,),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#e9ecef"),
                              border: Border.all(
                                width: 0.5,
                                color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:HexColor("#dddddd"),
                              ),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: (){
                                    toggleContainer();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.0),
                                    margin: EdgeInsets.only(right: 3.0),
                                    decoration: BoxDecoration(
                                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                      //shape: selectedUser != null?BoxShape.rectangle : BoxShape.circle,
                                      borderRadius: selectedUser != null? BorderRadius.circular(20):BorderRadius.circular(60),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          MdiIcons.pound,
                                          color: Provider.of<AppData>(context).darkTheme?Colors.white:HexColor("#222222"),
                                          size: 18.0,
                                        ),
                                        selectedUser != null?Text(
                                          selectedUser!.user_firstname! + " " + selectedUser!.user_lastname!,
                                          style: TextStyle(

                                          ),
                                        ):SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ),
                                 Expanded(
                                  child: TextField(
                                    decoration: InputDecoration.collapsed(
                                      hintText: ("Write a comment"),
                                      hintStyle: TextStyle(
                                        color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                                      ),
                                    ),
                                    //autofocus: true,
                                    style: TextStyle(
                                      color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                                    ),
                                    focusNode: myFocusNode,
                                    controller: commentTextEditingController,
                                    minLines: 1,
                                    maxLines: 1,
                                  ),
                                ),
                                /*const Icon(
                                  IconData(0xe92e, fontFamily: "icomoon"),
                                  color: Colors.grey,
                                  size: 18.0,
                                ),
                                const SizedBox(width: 6.0,),
                                const Icon(
                                  IconData(0xe910, fontFamily: "icomoon"),
                                  color: Colors.grey,
                                  size: 18.0,
                                ),
                                const SizedBox(width: 8.0,),*/
                                InkWell(
                                  onTap: (){
                                    saveComment();
                                  },
                                  child: const Icon(
                                    Icons.send,
                                    color: Palette.kuungaaDefault,
                                    size: 22.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Future<List> getTagUsers() async {
    List<Users> usersList = [];
    DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users");
    await dbReference.once().then((DataSnapshot dataSnapshot){
      usersList.clear();
      var keys = dataSnapshot.value.keys;
      var values = dataSnapshot.value;

      for (var key in keys)
      {
        if(values [key]["user_id"] != userCurrentInfo!.user_id!){
          Users users = Users();
          users.user_id = values [key]["user_id"];
          users.user_firstname = values [key]["user_firstname"];
          users.user_lastname = values [key]["user_lastname"];
          users.user_profileimage = values [key]["user_profileimage"];

          usersList.add(users);
        }
      }
    });
    return usersList;
  }

  Widget buildCommentSheet(Comments comment) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                MdiIcons.pencil,
                color: Provider.of<AppData>(context).darkTheme?Colors.white:HexColor("#999999"),
              ),
              SizedBox(width: 8.0,),
              Text(
                "Edit",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          InkWell(
            onTap: (){
              DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(widget.postid).child("comments").child(comment.comment_id!);
              dbRef.remove();
              Navigator.pop(context);
            },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    MdiIcons.delete,
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:HexColor("#999999"),
                  ),
                  SizedBox(width: 8.0,),
                  Text(
                    "Delete",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void saveComment() async {
    if(commentTextEditingController.text.isNotEmpty) {
      if (commentType == "main-comment") {
        DatabaseReference commentRef = FirebaseDatabase.instance.reference()
            .child('KUUNGAA').child('Posts').child(widget.postid).child(
            "comments")
            .push();
        String refKey = commentRef.key;

        var commenttime = DateTime.now().millisecondsSinceEpoch;;

        if (selectedUser != null) {
          tagid = selectedUser!.user_id!;
        }

        Map commentDataMap = {
          "comment_id": refKey,
          "comment_text": commentTextEditingController.text,
          "comment_time": commenttime,
          "commenter_id": userCurrentInfo!.user_id!,
          "post_id": widget.postid,
          "tagid": tagid
        };

        commentRef.set(commentDataMap).then((onValue) {
          if(widget.posterid != userCurrentInfo!.user_id!){
            saveGeneralNotification("commented on your post", widget.posterid, "comments", widget.postid);
          }
          commentTextEditingController.clear();
          setState(() {
            selectedUser = null;
          });
        }).catchError((onError) {
          displayToastMessage(
              "An error occurred. Please try again later", context);
        });

      }else if(commentType == "main-comment-reply"){
        DatabaseReference commentRef = FirebaseDatabase.instance.reference()
            .child('KUUNGAA').child('Posts').child(widget.postid).child(
            "comments").child(replycommentid).child("comments")
            .push();

        String refKey = commentRef.key;

        var commenttime = DateTime.now().millisecondsSinceEpoch;;

        if (selectedUser != null) {
          tagid = selectedUser!.user_id!;
        }

        Map commentMap = {
          "childcommenter_id" : userCurrentInfo!.user_id!,
          "childcomment_text" : commentTextEditingController.text,
          "childpost_id" : widget.postid,
          "childcomment_time" : commenttime,
          "childcomment_id" : refKey,
          "childtagid" : tagid,
          "replycommentid" : replycommentid,
          "replyuserid" : replyUser!.user_id!
        };

        commentRef.set(commentMap).then((onValue) {
          
          if(widget.posterid != userCurrentInfo!.user_id!){
            saveGeneralNotification("commented on your post", widget.posterid, "comments", widget.postid);
          }

          commentTextEditingController.clear();

          setState(() {
            selectedUser = null;
            isBoxVisible = false;
            commentType = "main-comment";
            replycommentid = "";
            replyUser = null;
          });

        }).catchError((onError) {
          displayToastMessage(
              "An error occurred. Please try again later", context);
        });

      }
    }
  }

  void toggleContainer() {
    if(isContainerVisible){
      setState(() {
        isContainerVisible = false;
      });
    }else{
      setState(() {
        isContainerVisible = true;
      });
    }
  }

}

class ChildComment extends StatefulWidget {
  final String postid;
  final String posterid;
  final String commentid;
  final String childcommentid;
  final Comments parentComment;
  final String type;
  const ChildComment({
    Key? key,
    required this.postid,
    required this.posterid,
    required this.commentid,
    required this.childcommentid,
    required this.parentComment,
    required this.type
  }) : super(key: key);

  @override
  State<ChildComment> createState() => _ChildCommentState();
}

class _ChildCommentState extends State<ChildComment> {

  List<Comments> listChildComments = [];
  Query? itemRefChildComment;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
      itemRefChildComment =
          database.reference().child('KUUNGAA').child("Posts").child(
              widget.postid).child("comments").child(widget.commentid).child(
              "comments");

    itemRefChildComment!.onChildAdded.listen(_onEntryAddedChildComment);
    itemRefChildComment!.onChildChanged.listen(_onEntryChangedChildComment);
    itemRefChildComment!.onChildRemoved.listen(_onEntryRemovedChildComment);
  }

  _onEntryAddedChildComment(Event event) async {
    Comments comments = Comments();
    print("post child comments:" + event.snapshot.value.toString());
    comments.comment_user = await AssistantMethods.getCurrentOnlineUser(event.snapshot.value["childcommenter_id"]);
    comments.replied_user = await AssistantMethods.getCurrentOnlineUser(event.snapshot.value["replyuserid"]);
    comments.comment_id = event.snapshot.value["childcomment_id"];
    comments.comment_text = event.snapshot.value["childcomment_text"];
    comments.comment_time = event.snapshot.value["childcomment_time"];
    comments.commenter_id = event.snapshot.value["childcommenter_id"];
    comments.post_id = event.snapshot.value["childpost_id"];
    comments.tag_id = event.snapshot.value["childtagid"];
    if(event.snapshot.value["childtagid"] != ""){
      comments.tagged_user = await AssistantMethods.getCurrentOnlineUser(event.snapshot.value["childtagid"]);
    }
    setState(() {
      listChildComments.add(comments);
    });
  }

  _onEntryChangedChildComment(Event event) async {
    var old = listChildComments.singleWhere((entry) {
      return entry.comment_id == event.snapshot.key;
    });
    Comments comments = Comments();
    comments.comment_user = await AssistantMethods.getCurrentOnlineUser(event.snapshot.value["childcommenter_id"]);
    comments.replied_user = await AssistantMethods.getCurrentOnlineUser(event.snapshot.value["replyuserid"]);
    comments.comment_id = event.snapshot.value["childcomment_id"];
    comments.comment_text = event.snapshot.value["childcomment_text"];
    comments.comment_time = event.snapshot.value["childcomment_time"];
    comments.commenter_id = event.snapshot.value["childcommenter_id"];
    comments.post_id = event.snapshot.value["childpost_id"];
    comments.tag_id = event.snapshot.value["childtagid"];
    if(event.snapshot.value["childtagid"] != ""){
      comments.tagged_user = await AssistantMethods.getCurrentOnlineUser(event.snapshot.value["childtagid"]);
    }
    setState(() {
      listChildComments[listChildComments.indexOf(old)] = comments;
    });
  }

  _onEntryRemovedChildComment(Event event) async {
    var removed = listChildComments.singleWhere((entry) {
      return entry.comment_id == event.snapshot.key;
    });

    setState(() {
      listChildComments.removeWhere((Comments comments) => comments.comment_id == removed.comment_id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return listChildComments.isNotEmpty?Container(
      constraints: BoxConstraints(
        maxHeight: double.infinity,
      ),
      child: FirebaseAnimatedList(
          query: itemRefChildComment!,
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 30.0,right: 12.0),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder:(_, DataSnapshot snapshot, Animation<double> animation, int index){
            Comments comment = listChildComments[index];
            print("post child comments:" + snapshot.value.toString());
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ProfileAvatar(imageUrl: comment.comment_user!.user_profileimage!, radius: 14.0,),
                      const SizedBox(width: 4.0,),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                comment.comment_user!.user_firstname! + " " + comment.comment_user!.user_lastname!,
                                style: TextStyle(
                                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  InkWell(
                    onLongPress: (){
                      if(widget.posterid == userCurrentInfo!.user_id! || comment.comment_id == userCurrentInfo!.user_id) {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0)),
                          ),
                          context: context,
                          builder: (context) =>
                              buildCommentSheet(comment, widget.commentid),
                        );
                      }
                    },
                    child: Container(
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                            padding: const EdgeInsets.fromLTRB(10.0, 15.0, 15.0, 10.0),
                            decoration: BoxDecoration(
                              color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:HexColor("#e9ecef"),

                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                comment.tagged_user != null?Text(
                                  "#" + comment.tagged_user!.user_firstname! + " " + comment.tagged_user!.user_lastname!,
                                  style: TextStyle(
                                    color: HexColor("#4285F4"),
                                  ),
                                ):SizedBox.shrink(),
                                comment.commenter_id == widget.parentComment.commenter_id!?
                                Text(comment.comment_text!):
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      comment.replied_user!.user_firstname! + " " + comment.replied_user!.user_lastname! + " >",
                                      style: TextStyle(
                                        color: HexColor("#2dce89"),
                                      ),
                                    ),
                                    Text(comment.comment_text!),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0.0,
                            bottom: 2.0,
                            child: SubCommentLikes(postid: widget.postid, commentid: widget.commentid, subcommentid: comment.comment_id!,),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.fromLTRB(20.0, 5.0, 0.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        LikeSubComment(postid: widget.postid, commentid: widget.commentid, subcommentid: comment.comment_id!,),
                        SizedBox(width: 7.0,),
                        Text(
                          "Reply",
                          style: TextStyle(
                            //color: HexColor("#999999"),
                              fontSize: 14.0
                          ),
                        ),
                        SizedBox(width: 7.0,),
                        Text(
                          convertToTimeAgo(comment.comment_time!),
                          style: TextStyle(
                            //color: HexColor("#999999"),
                              fontSize: 14.0
                          ),
                        ),
                      ],
                    ),
                  ),
                  //ChildComment(postid: widget.postid, commentid: comment.comment_id!, parentComment: comment, childcommentid: comment.comment_id!, type: 'sub-comment',),
                ],
              ),
            );
          }
      ),
    ):SizedBox.shrink();
  }

  Widget buildCommentSheet(Comments comment, String commentid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                MdiIcons.pencil,
                color: Provider.of<AppData>(context).darkTheme?Colors.white:HexColor("#999999"),
              ),
              SizedBox(width: 8.0,),
              Text(
                "Edit",
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          InkWell(
            onTap: (){
              DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(widget.postid).child("comments").child(commentid).child("comments").child(comment.comment_id!);
              dbRef.remove();
              Navigator.pop(context);
            },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    MdiIcons.delete,
                    color: Provider.of<AppData>(context).darkTheme?Colors.white:HexColor("#999999"),
                  ),
                  SizedBox(width: 8.0,),
                  Text(
                    "Delete",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LikeSubComment extends StatefulWidget {
  final String postid;
  final String commentid;
  final String subcommentid;
  const LikeSubComment({
    Key? key,
    required this.postid,
    required this.commentid,
    required this.subcommentid
  }) : super(key: key);

  @override
  State<LikeSubComment> createState() => _LikeSubCommentState();
}

class _LikeSubCommentState extends State<LikeSubComment> {

  Query? itemRefLikes;

  bool isLike = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefLikes = database.reference().child('KUUNGAA').child("Posts").child(widget.postid).child("comments").child(widget.commentid).child("comments").child(widget.subcommentid).child("likes").orderByChild("liker_id").equalTo(userCurrentInfo!.user_id!);
    itemRefLikes!.onChildAdded.listen(_onEntryAddedLikes);
    itemRefLikes!.onChildRemoved.listen(_onEntryRemovedLikes);
  }

  _onEntryAddedLikes(Event event) async {
    setState(() {
      isLike = true;
    });
  }

  _onEntryRemovedLikes(Event event) async {
    setState(() {
      isLike = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(widget.postid).child("comments").child(widget.commentid).child("comments").child(widget.subcommentid).child("likes").child(userCurrentInfo!.user_id!);
        dbRef.once().then((DataSnapshot snapshot){
          if(snapshot.exists){
            dbRef.remove();
          }else{
            Map likeRef = {
              "liker_id" : userCurrentInfo!.user_id!
            };
            dbRef.set(likeRef);
          }
        });
      },
      child: Text(
        "Like",
        style: Provider.of<AppData>(context).darkTheme?TextStyle(
          //color: HexColor("#999999"),
            fontSize: 14.0,
            color: isLike?Colors.blue:Colors.white
        ):TextStyle(
          //color: HexColor("#999999"),
            fontSize: 14.0,
            color: isLike?Colors.blue:Colors.black
        ),
      ),
    );
  }
}


class LikeMainComment extends StatefulWidget {

  final String postid;
  final String commentid;
  const LikeMainComment({
    Key? key,
    required this.postid,
    required this.commentid
  }) : super(key: key);

  @override
  State<LikeMainComment> createState() => _LikeMainCommentState();

}

class _LikeMainCommentState extends State<LikeMainComment> {

  Query? itemRefLikes;

  bool isLike = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefLikes = database.reference().child('KUUNGAA').child("Posts").child(widget.postid).child("comments").child(widget.commentid).child("likes").orderByChild("liker_id").equalTo(userCurrentInfo!.user_id!);
    itemRefLikes!.onChildAdded.listen(_onEntryAddedLikes);
    itemRefLikes!.onChildRemoved.listen(_onEntryRemovedLikes);
  }

  _onEntryAddedLikes(Event event) async {
    setState(() {
      isLike = true;
    });
  }

  _onEntryRemovedLikes(Event event) async {
    setState(() {
      isLike = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(widget.postid).child("comments").child(widget.commentid).child("likes").child(userCurrentInfo!.user_id!);
        dbRef.once().then((DataSnapshot snapshot){
          if(snapshot.exists){
            dbRef.remove();
          }else{
            Map likeRef = {
              "liker_id" : userCurrentInfo!.user_id!
            };
            dbRef.set(likeRef);
          }
        });
      },
      child: Text(
        "Like",
        style: Provider.of<AppData>(context).darkTheme?TextStyle(
          //color: HexColor("#999999"),
          fontSize: 14.0,
          color: isLike?Colors.blue:Colors.white
        ):TextStyle(
          //color: HexColor("#999999"),
            fontSize: 14.0,
            color: isLike?Colors.blue:Colors.black
        ),
      ),
    );
  }
}


class MainCommentLikes extends StatefulWidget {
  final String postid;
  final String commentid;

  const MainCommentLikes({
    Key? key,
    required this.postid,
    required this.commentid
  }) : super(key: key);

  @override
  State<MainCommentLikes> createState() => _MainCommentLikesState();
}

class _MainCommentLikesState extends State<MainCommentLikes> {

  List<Likes> commentLikes = [];
  DatabaseReference? itemRefLikes;

  bool isLike = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefLikes = database.reference().child('KUUNGAA').child("Posts").child(widget.postid).child("comments").child(widget.commentid).child("likes");
    itemRefLikes!.onChildAdded.listen(_onEntryAddedLikes);
    itemRefLikes!.onChildRemoved.listen(_onEntryRemovedLikes);
  }

  _onEntryAddedLikes(Event event) async {
    Likes likes = Likes();
    likes.like_id = event.snapshot.key;
    likes.liker_id = event.snapshot.value["liker_id"];

    setState(() {
      commentLikes.add(likes);
      if(likes.liker_id == userCurrentInfo!.user_id!){
        isLike = true;
      }
    });
  }

  _onEntryRemovedLikes(Event event) async {
    var removed = commentLikes.singleWhere((entry) {
      return entry.like_id == event.snapshot.key;
    });

    setState(() {
      if(removed.liker_id == userCurrentInfo!.user_id!){
        isLike = false;
      }
      commentLikes.removeWhere((Likes likes) => likes.like_id == removed.like_id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return commentLikes.isNotEmpty?Row(
      children: [
        Provider.of<AppData>(context).darkTheme?Icon(
          Icons.thumb_up,
          color: isLike?Colors.blue:Colors.white,
        ):Icon(
          Icons.thumb_up,
          color: isLike?Colors.blue:Colors.grey,
        ),
        SizedBox(width: 2.0,),
        Text(commentLikes.length.toString()),
      ],
    ):SizedBox.shrink();
  }
}

class SubCommentLikes extends StatefulWidget {
  final String postid;
  final String commentid;
  final String subcommentid;
  const SubCommentLikes({
    Key? key,
    required this.postid,
    required this.commentid,
    required this.subcommentid
  }) : super(key: key);

  @override
  State<SubCommentLikes> createState() => _SubCommentLikesState();
}

class _SubCommentLikesState extends State<SubCommentLikes> {

  List<Likes> commentLikes = [];
  DatabaseReference? itemRefLikes;

  bool isLike = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefLikes = database.reference().child('KUUNGAA').child("Posts").child(widget.postid).child("comments").child(widget.commentid).child("comments").child(widget.subcommentid).child("likes");
    itemRefLikes!.onChildAdded.listen(_onEntryAddedLikes);
    itemRefLikes!.onChildRemoved.listen(_onEntryRemovedLikes);
  }

  _onEntryAddedLikes(Event event) async {
    Likes likes = Likes();
    likes.like_id = event.snapshot.key;
    likes.liker_id = event.snapshot.value["liker_id"];

    setState(() {
      commentLikes.add(likes);
      if(likes.liker_id == userCurrentInfo!.user_id!){
        isLike = true;
      }
    });
  }

  _onEntryRemovedLikes(Event event) async {
    var removed = commentLikes.singleWhere((entry) {
      return entry.like_id == event.snapshot.key;
    });

    setState(() {
      if(removed.liker_id == userCurrentInfo!.user_id!){
        isLike = false;
      }
      commentLikes.removeWhere((Likes likes) => likes.like_id == removed.like_id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return commentLikes.isNotEmpty?Row(
      children: [
        Provider.of<AppData>(context).darkTheme?Icon(
          Icons.thumb_up,
          color: isLike?Colors.blue:Colors.white,
        ):Icon(
          Icons.thumb_up,
          color: isLike?Colors.blue:Colors.grey,
        ),
        SizedBox(width: 2.0,),
        Text(commentLikes.length.toString()),
      ],
    ):SizedBox.shrink();
  }
}



