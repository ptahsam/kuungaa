import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/MultiManager/flick_multimanager.dart';
import 'package:kuungaa/MultiManager/flick_multiplayer.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'widgets.dart';
class VideosPostContainer extends StatefulWidget {
  const VideosPostContainer({Key? key}) : super(key: key);

  @override
  _VideosPostContainerState createState() => _VideosPostContainerState();
}

class _VideosPostContainerState extends State<VideosPostContainer> {

  List<Posts> listPosts = [];
  Query? itemRefPosts;
  bool _anchorToBottom = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefPosts = database.reference().child('KUUNGAA').child('Posts')
        .orderByKey();
    itemRefPosts!.onChildAdded.listen(_onEntryAddedPosts);
    itemRefPosts!.onChildRemoved.listen(_onEntryRemovedPosts);
  }

  _onEntryAddedPosts(Event event) async {
    if(event.snapshot.exists){
      DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(FirebaseAuth.instance.currentUser!.uid).child(event.snapshot.key!);
      await hiddenRef.once().then((DataSnapshot hiddenSnapshot) async {
        if(!hiddenSnapshot.exists){
          String videoUrl = await getPostVideo(event.snapshot.key);

          if(videoUrl != ""){
            //print("postmedia" + videoUrl);
            Posts post = Posts();
            post.post_id = event.snapshot.key;
            post.pid = event.snapshot.value["post_id"];
            post.post_description = event.snapshot.value["post_description"];
            post.post_time = event.snapshot.value["post_time"];
            post.poster_id = event.snapshot.value["poster_id"];
            post.post_privacy = event.snapshot.value["post_privacy"];
            post.post_category = event.snapshot.value["post_category"];
            post.post_countrycode = event.snapshot.value["post_countrycode"];
            post.post_expression = event.snapshot.value["post_expression"];
            post.video_url = videoUrl;

            if(event.snapshot.value["post_category"] == "pagesfeed"){
              post.kpage = await getPageFromId(event.snapshot.value["post_id"]);
            }
            if(event.snapshot.value["post_category"] == "groupsfeed"){
              post.group = await getGroupFromId(event.snapshot.value["post_id"]);
            }

            DatabaseReference tagRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(event.snapshot.key!).child("post_tagged");
            await tagRef.once().then((DataSnapshot tagSnapshot) async {
              if(tagSnapshot.exists){
                if(tagSnapshot.value != ""){
                  //print("tagged user ::" + tagSnapshot.value.toString());
                  List<Users> taggedUsersList = [];
                  for(var i in tagSnapshot.value){
                    Tagged tagged = Tagged.fromJson(Map<String, dynamic>.from(i));
                    //print("tagged user 1 ::" + tagged.userid!);
                    DatabaseReference userRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(tagged.userid!);
                    await userRef.once().then((DataSnapshot userSnapshot){
                      Users users = Users.fromSnapshot(userSnapshot);
                      // print("tagged user 2 ::" + users.user_id!);
                      taggedUsersList.add(users);
                    });
                  }
                  post.taggedUsers = taggedUsersList;
                }
              }
            });
            Users postUser = await AssistantMethods.getCurrentOnlineUser(post.poster_id!);
            post.postUser = postUser;
            setState(() {
              listPosts.add(post);
              arrangePosts(listPosts);
            });
          }
        }
      });
    }
  }

  _onEntryRemovedPosts(Event event) async {
    var removed = listPosts.singleWhere((entry) {
      return entry.post_id == event.snapshot.key;
    });

    setState(() {
      listPosts.removeWhere((Posts post) => post.post_id == removed.post_id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5.0,),
      child: listPosts.isNotEmpty?FirebaseAnimatedList(
          physics: const NeverScrollableScrollPhysics(),
          query: itemRefPosts!,
          reverse: _anchorToBottom,
          key: ValueKey<bool>(_anchorToBottom),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder:(_, DataSnapshot snapshot, Animation<double> animation, int index){
            if(snapshot.exists){
              if(index + 1 <= listPosts.length){
                return Column(
                  children: [
                    PostVideosMainContainer(post: listPosts[index],),
                    listPosts.length > 1 ?
                    Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                    ) : const SizedBox.shrink(),
                  ],
                );
              }
              return SizedBox.shrink();
            }else{
              return Align(
                alignment: Alignment.center,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.13,
                  width: MediaQuery.of(context).size.width * 0.65,
                  decoration: BoxDecoration(
                    color: Colors.grey[100]!,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.newspaper,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 6.0,),
                        Text("There are no posts found!", textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
      ):SizedBox(
        height: 1000,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 100,
          itemBuilder: (BuildContext context, int index){
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5.0),
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                          highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                          child: Container(
                            height: 40.0,
                            width: 40.0,
                            decoration: BoxDecoration(
                              color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.0,),
                        Expanded(
                          child: Column(
                            children: [
                              Shimmer.fromColors(
                                baseColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                                highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                child: Container(
                                  height: 20.0,
                                  color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                                ),
                              ),
                              const SizedBox(height: 4.0,),
                              Shimmer.fromColors(
                                baseColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                                highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                child: Container(
                                  height: 10.0,
                                  color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0,),
                  Shimmer.fromColors(
                    baseColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                    highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                    child: Container(
                      height: 200.0,
                      color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      /*FutureBuilder(
          future: getAllVideosPosts(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot){
            if(snapshot.connectionState == ConnectionState.done)
            {
              if(snapshot.hasData){
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index){
                    return Column(
                      children: [
                        PostVideosMainContainer(post: snapshot.data![index],),
                        snapshot.data!.length > 1 ?
                        Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        ) : const SizedBox.shrink(),
                      ],
                    );
                  },
                );
              }
              else{
                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.13,
                    width: MediaQuery.of(context).size.width * 0.65,
                    decoration: BoxDecoration(
                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_call_rounded,
                            color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                          ),
                          SizedBox(height: 6.0,),
                          Text("No videos available", textAlign: TextAlign.center,),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
            else
            {
              return SizedBox(
                height: 1000,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 100,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                                  highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                  child: Container(
                                    height: 40.0,
                                    width: 40.0,
                                    decoration: BoxDecoration(
                                      color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4.0,),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                                        highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                        child: Container(
                                          height: 20.0,
                                          color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0,),
                                      Shimmer.fromColors(
                                        baseColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                                        highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                        child: Container(
                                          height: 10.0,
                                          color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0,),
                          Shimmer.fromColors(
                            baseColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                            highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                            child: Container(
                              height: 200.0,
                              color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
          }
      ),*/
    );
  }

 Future<List> getAllVideosPosts() async {
    List<Posts> videosPosts = [];

    final DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts");
    await dbReference.once().then((DataSnapshot snapshotPosts) async {
      videosPosts.clear();
      var keys = snapshotPosts.value.keys;
      var values = snapshotPosts.value;

      for (var key in keys)
      {
        DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(userCurrentInfo!.user_id!).child(key);
        await hiddenRef.once().then((DataSnapshot hiddenSnapshot) async {
          if(!hiddenSnapshot.exists){
            String videoUrl = await getPostVideo(key);

            if(videoUrl != ""){
              //print("postmedia" + videoUrl);
              Posts post = Posts();
              post.post_id = key;
              post.pid = values [key]["post_id"];
              post.post_description = values [key]["post_description"];
              post.post_time = values [key]["post_time"];
              post.poster_id = values [key]["poster_id"];
              post.post_privacy = values [key]["post_privacy"];
              post.post_category = values [key]["post_category"];
              post.post_countrycode = values [key]["post_countrycode"];
              post.post_expression = values [key]["post_expression"];
              post.video_url = videoUrl;

              if(values [key]["post_category"] == "pagesfeed"){
                post.kpage = await getPageFromId(values [key]["post_id"]);
              }
              if(values [key]["post_category"] == "groupsfeed"){
                post.group = await getGroupFromId(values [key]["post_id"]);
              }

              DatabaseReference tagRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(key).child("post_tagged");
              await tagRef.once().then((DataSnapshot tagSnapshot) async {
                if(tagSnapshot.exists){
                  if(tagSnapshot.value != ""){
                    //print("tagged user ::" + tagSnapshot.value.toString());
                    List<Users> taggedUsersList = [];
                    for(var i in tagSnapshot.value){
                      Tagged tagged = Tagged.fromJson(Map<String, dynamic>.from(i));
                      //print("tagged user 1 ::" + tagged.userid!);
                      DatabaseReference userRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(tagged.userid!);
                      await userRef.once().then((DataSnapshot userSnapshot){
                        Users users = Users.fromSnapshot(userSnapshot);
                        // print("tagged user 2 ::" + users.user_id!);
                        taggedUsersList.add(users);
                      });
                    }
                    post.taggedUsers = taggedUsersList;
                  }
                }
              });
              Users postUser = await AssistantMethods.getCurrentOnlineUser(post.poster_id!);
              post.postUser = postUser;
              videosPosts.add(post);
            }
          }
        });
      }
    });

    return videosPosts.reversed.toList();

  }
}

class PostVideosMainContainer extends StatefulWidget {
  final Posts? post;


  const PostVideosMainContainer({
    Key? key,
    this.post
  }) : super(key: key);

  @override
  State<PostVideosMainContainer> createState() => _PostVideosMainContainerState();
}

class _PostVideosMainContainerState extends State<PostVideosMainContainer> {
  late FlickMultiManager flickMultiManager;
  final List<Widget> _taggedUserList = [];

  void _getTaggedList(){
    if(widget.post!.taggedUsers != null){
      for(var i = 0; i < widget.post!.taggedUsers!.length; i ++){
        Widget tagContainer = Container(
          padding: const EdgeInsets.all(2.0),
          child: InkWell(
            onTap: (){
              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post!.taggedUsers![i].user_id!,)));
            },
            child: Text(
              "#" + widget.post!.taggedUsers![i].user_firstname! + " " + widget.post!.taggedUsers![i].user_lastname!,
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        );
        _taggedUserList.add(tagContainer);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flickMultiManager = FlickMultiManager();
    _getTaggedList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Row(
                  children: [
                    if(widget.post!.post_category == "pagesfeed")
                      SizedBox(
                        height: 35.0,
                        width: 35.0,
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () async {
                                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SinglePage(kpage: widget.post!.kpage!,)));
                              },
                              child: BoxAvatar(
                                imageUrl: widget.post!.kpage!.page_icon!,
                              ),
                            ),
                            Positioned(
                              bottom: 0.0,
                              right: 0.0,
                              child: InkWell(
                                  onTap: (){
                                    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post!.poster_id!,)));
                                  },
                                  child: ProfileAvatar(imageUrl: widget.post!.postUser!.user_profileimage!, hasBorder: true, radius: 12.0, borderWidth: 11.0, backGroundColor: "#2dce89",)
                              ),
                            ),
                          ],
                        ),
                      ),

                    if(widget.post!.post_category == "groupsfeed")
                      SizedBox(
                        height: 35.0,
                        width: 35.0,
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () async {
                                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SingleGroup(group: widget.post!.group!,)));
                              },
                              child: BoxAvatar(
                                  imageUrl: widget.post!.group!.group_icon!
                              ),
                            ),
                            Positioned(
                              bottom: 0.0,
                              right: 0.0,
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post!.poster_id!,)));
                                },
                                child: ProfileAvatar(imageUrl: widget.post!.postUser!.user_profileimage!, hasBorder: true, radius: 12.0, borderWidth: 11.0, backGroundColor: "#2dce89",),
                              ),
                            ),
                          ],
                        ),
                      ),
                    //if(widget.post!.post_category == "groupsfeed")

                    if(widget.post!.post_category == "newsfeed" || widget.post!.post_category == "travelfeed")
                      InkWell(
                        onTap: (){
                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post!.poster_id!,)));
                        },
                        child: ProfileAvatar(imageUrl: widget.post!.postUser!.user_profileimage!),
                      ),
                    const SizedBox(width: 8.0,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if(widget.post!.post_category == "pagesfeed")
                                InkWell(
                                  onTap: () async {
                                    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SinglePage(kpage: widget.post!.kpage!,)));
                                  },
                                  child: Text(
                                    widget.post!.kpage!.page_name!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: HexColor("#4285F4"),
                                    ),
                                  ),
                                ),
                              if(widget.post!.post_category == "groupsfeed")
                                InkWell(
                                  onTap: () async {
                                    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SingleGroup(group: widget.post!.group!,)));
                                  },
                                  child: Text(
                                    widget.post!.group!.group_name!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: HexColor("#4285F4"),
                                    ),
                                  ),
                                ),
                              if(widget.post!.post_category == "newsfeed" || widget.post!.post_category == "travelfeed")
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post!.poster_id!,)));
                                      },
                                      child: Text(
                                        widget.post!.postUser!.user_firstname! + " " + widget.post!.postUser!.user_lastname!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: HexColor("#4285F4"),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                      ),

                                    ),
                                    //widget.post!.post_expression != ""?const SizedBox(width: 4.0,):const SizedBox.shrink(),
                                    widget.post!.post_expression != ""?Text(" — is feeling " + widget.post!.post_expression!, maxLines: 1, overflow: TextOverflow.fade,):const SizedBox.shrink(),
                                  ],
                                ),
                              /*if(widget.post!.post_category == "newsfeed" || widget.post!.post_category == "travelfeed")
                              widget.post!.post_expression != ""?const SizedBox(width: 4.0,):const SizedBox.shrink(),
                              Expanded(child: widget.post!.post_expression != ""?Text(" — is feeling " + widget.post!.post_expression!, maxLines: 2, overflow: TextOverflow.fade,):const SizedBox.shrink()),
                              */
                            ],
                          ),

                          Row(
                            children: [
                              widget.post!.post_category == "groupsfeed" || widget.post!.post_category == "pagesfeed"?
                              InkWell(
                                onTap: (){
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post!.poster_id!,)));
                                },
                                child: Text(
                                  widget.post!.postUser!.user_firstname! + " " + widget.post!.postUser!.user_lastname!,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                  ),
                                ),
                              ):const SizedBox.shrink(),
                              widget.post!.post_category == "groupsfeed"?
                              const Text(" . ")
                                  :const SizedBox.shrink(),
                              widget.post!.post_category == "travelfeed"?
                              Row(
                                children: [
                                  ExtendedImage.asset(
                                    'icons/flags/png/' + widget.post!.post_countrycode!.toLowerCase() + '.png', package: 'country_icons',
                                    height: 20.0,
                                    width: 20.0,
                                    fit: BoxFit.cover,
                                    shape: BoxShape.circle,
                                  ),
                                  const SizedBox(width: 5.0,),
                                  Text(
                                    "Travel and Culture . ",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.normal,
                                      color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                    ),
                                  ),
                                ],
                              )
                                  :const SizedBox.shrink(),
                              if(widget.post!.post_privacy == "public")
                                Icon(
                                  Icons.public,
                                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                  size: 12.0,
                                ),
                              if(widget.post!.post_privacy == "friends")
                                Icon(
                                  FontAwesomeIcons.userFriends,
                                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                  size: 12.0,
                                ),
                              if(widget.post!.post_privacy == "onlyme")
                                Icon(
                                  FontAwesomeIcons.userLock,
                                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                  size: 12.0,
                                ),
                              const SizedBox(width: 8.0,),
                              widget.post!.post_time != null?Text(
                                convertToTimeAgo(widget.post!.post_time!),
                                //'${post!.post_time!}',

                                style: TextStyle(
                                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                  fontSize: 12.0,
                                ),
                              ):const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    ContextMenu(post: widget.post!),//context menu
                  ],
                ),
              ),

              widget.post!.taggedUsers != null?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Wrap(
                  children: _taggedUserList,
                ),
              ):const SizedBox.shrink(),

              widget.post!.post_description != ""?Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(widget.post!.post_description!),
              ):const SizedBox.shrink(),
            ],
          ),
          SizedBox(
            height: 350.0,
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: 1,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: 1 / 1,),
                    itemBuilder: (BuildContext context, int index){
                      return VisibilityDetector(
                        key: ObjectKey(flickMultiManager),
                        onVisibilityChanged: (visibility) {
                          if (visibility.visibleFraction == 0 && mounted) {
                            flickMultiManager.pause();
                          }
                        },
                        child: Container(
                            height: 350,
                            margin: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(0),
                              child: FlickMultiPlayer(
                                url: widget.post!.video_url!,
                                flickMultiManager: flickMultiManager,
                                image: "images/video_thumbnail.png",
                              ),
                            )
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          PostStats(post: widget.post!),
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _PostComment(),
          ),*/
        ],
      ),
    );
  }

  Future<List> getPostMediaData(String postid) async {
    List<Media> listImage = [];
    final DatabaseReference mediaReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postid).child("post_media");
    await mediaReference.once().then((DataSnapshot snapshotPosts){
      if(snapshotPosts.exists){
        //print(snapshotPosts.value);
        listImage.clear();

        for(var i in snapshotPosts.value){
          Media media = Media.fromJson(Map<String, dynamic>.from(i));
          listImage.add(media);
        }

      }
    });


    return listImage;
  }

  getFieldValue(String postid, String field) {
    return AssistantMethods.getFieldname("Groups", postid, field);
  }
}


