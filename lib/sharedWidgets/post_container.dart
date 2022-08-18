import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/Models/group.dart';
import 'package:kuungaa/Models/live.dart';
import 'package:kuungaa/Models/page.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:snippet_coder_utils/hex_color.dart';
import '../DataHandler/appData.dart';
import '../config/palette.dart';
import 'widgets.dart';

class PostContainer extends StatefulWidget {
  //final bool getMore;
  const PostContainer({
    Key? key,
    //required this.isRefresh,
    //required this.getMore
  }) : super(key: key);


  @override
  State<PostContainer> createState() => _PostContainerState();
}


class _PostContainerState extends State<PostContainer> {

  String referenceToOldestKey = "";

  List<Posts> listPosts = [];
  Query? itemRefPosts;

  Future<List<Posts>>? _future;

  bool nextItems = false;

  int itemCount = 0;
  int itemAddedCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    _future = getAllPosts();
    super.initState();
    if(nextItems){
      setState(() {
        _future = getNextPosts(referenceToOldestKey);
      });
    }
    //getAllPosts();
    //getFeedPosts();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefPosts = database.reference().child('KUUNGAA').child("Posts").orderByKey().limitToLast(100);
    itemRefPosts!.onChildAdded.listen(_onEntryAddedPosts);
    //itemRefComment!.onChildChanged.listen(_onEntryChangedComment);
    itemRefPosts!.onChildRemoved.listen(_onEntryRemovedPosts);
    database.reference().child('KUUNGAA').child('Posts').once().then(_getAllPosts);
  }

  _getAllPosts(DataSnapshot snapshot){
    if(snapshot.exists){
      var keys = snapshot.value.keys;
      for(var key in keys){
        setState(() {
          itemCount = itemCount + 1;
        });
      }
    }
  }

  _onEntryAddedPosts(Event event) async {
    if(event.snapshot.exists){
      DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(FirebaseAuth.instance.currentUser!.uid).child(event.snapshot.key!);
      await hiddenRef.once().then((DataSnapshot snapshot) async {
        if(!snapshot.exists){
          Provider.of<AppData>(context, listen: false).updateGettingHomeFeed(true);
          Posts post = Posts();
          post.post_id = event.snapshot.key!;
          post.pid = event.snapshot.value["post_id"];
          post.post_description = event.snapshot.value["post_description"];
          post.post_time = event.snapshot.value["post_time"];
          post.poster_id = event.snapshot.value["poster_id"];
          post.post_privacy = event.snapshot.value["post_privacy"];
          post.post_category = event.snapshot.value["post_category"];
          post.post_countrycode = event.snapshot.value["post_countrycode"];
          post.post_expression = event.snapshot.value["post_expression"];
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
            itemAddedCount = itemAddedCount + 1;
          });
          //print("posts totalcount :: " + itemCount.toString());
          //print("posts addedcount :: " + itemAddedCount.toString());
          //Provider.of<AppData>(context, listen: false).updateGettingHomeFeed(false);
          if(listPosts.length >= itemCount){
            Provider.of<AppData>(context, listen: false).updateGettingHomeFeed(false);
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

  /*_onEntryAddedPosts(DataSnapshot snapshotPosts) async {
    if(snapshotPosts.exists){
      var keys = snapshotPosts.value.keys;
      var values = snapshotPosts.value;

      var i = 0;

      for (var key in keys)
      {
        i = i + 1;
        referenceToOldestKey = key;
        if(i == 10){
          //fetchNextItems();
        }
        DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(userCurrentInfo!.user_id!).child(key);
        await hiddenRef.once().then((DataSnapshot snapshot) async {
          if(!snapshot.exists){
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
            setState(() {
              listPosts.add(post);
            });
          }
        });

      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    getAllPosts();
    return
    listPosts.isNotEmpty?FirebaseAnimatedList(
      physics: NeverScrollableScrollPhysics(),
      query: itemRefPosts!,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder:(_, DataSnapshot snapshot, Animation<double> animation, int index){
        if(snapshot.exists){
          List<Posts> posts = listPosts.reversed.toList();
          if(listPosts.length > 1){
            if(index + 1 <= posts.length) {
              return PostMainContainer(post: posts[index],
                postIndex: index,
                postsLength: posts.length,);
            }else{
              return Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: Palette.kuungaaDefault,
                  size: 200,
                ),
              );
            }
          }else{
            return Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Palette.kuungaaDefault,
                size: 200,
              ),
            );
          }
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
                    Text("An error occured when loading posts!", textAlign: TextAlign.center,),
                  ],
                ),
              ),
            ),
          );
        }
      }
    ):ListView.builder(
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
    );
    /*FutureBuilder<List<Posts>>(
      future: _future,
      builder: (context, AsyncSnapshot<List<Posts>> snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasData){
            List<Posts> posts = snapshot.data!;
            //updateGetNextItems(false);
            Posts post = Posts();
            if(snapshot.data!.length >= 3){
              posts.insert(3, post);
            }

            if(snapshot.data!.length >= 5){
              posts.insert(5, post);
            }

            if(snapshot.data!.length >= 8){
              posts.insert(8, post);
            }
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: posts.length,
              itemBuilder: (context, int index){

                if(index == (posts.length - 1)){
                  //updateGetNextItems(true);
                }
              //List<Posts> showPosts = listPosts;
              //Posts post = Posts();
              //showPosts.insert(5, post);
              return PostMainContainer(post: posts[index], postIndex: index, postsLength: snapshot.data!.length,);
              },
            );
          }else{
            return Text("No Posts");
          }
        }else{
          return ListView.builder(
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
          );
        }
    },
    );*/
  }
  
  Future<List<Posts>> getNextPosts(String lastId) async {

    List<Posts> feedPosts = [];

    await FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").orderByKey().endAt(lastId).limitToLast(10).
    once().then((DataSnapshot snapshot) async {
      if(snapshot.exists){
        var keys = snapshot.value.keys;
        var values = snapshot.value;

        for (var key in keys)
        {
          referenceToOldestKey = key;
          //print("feed posts lastKey ::" + referenceToOldestKey);
          Users user = await AssistantMethods.getCurrentOnlineUser(FirebaseAuth.instance.currentUser!.uid);

          DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(user.user_id!).child(key);
          await hiddenRef.once().then((DataSnapshot snapshot) async {
            if(!snapshot.exists){
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
              feedPosts.add(post);
            }
          });

        }
      }
    });
    return feedPosts.reversed.toList();
  }

   Future<List<Posts>> getAllPosts()  async {
    List<Posts> allPosts = [];
    final Query dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts")
        .orderByKey()
        .limitToLast(5);
      await dbReference.once().then((DataSnapshot snapshotPosts) async {
        if(snapshotPosts.exists){
          allPosts.clear();
          var keys = snapshotPosts.value.keys;
          var values = snapshotPosts.value;

          for (var key in keys)
          {
            referenceToOldestKey = key;

            DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(FirebaseAuth.instance.currentUser!.uid).child(key);
            await hiddenRef.once().then((DataSnapshot snapshot) async {
              if(!snapshot.exists){
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
                allPosts.add(post);
              }
            });

          }
        }
      });
      return allPosts.reversed.toList();
  }

  void updateGetNextItems(bool status) {
    Future.delayed(Duration.zero,(){
      setState(() {
        nextItems = status;
      });
    });
  }
}

class PostMainContainer extends StatefulWidget {
  final Posts? post;
  final int postIndex;
  final int postsLength;

  const PostMainContainer({
    Key? key,
    this.post,
    required this.postIndex,
    required this.postsLength
  }) : super(key: key);

  @override
  State<PostMainContainer> createState() => _PostMainContainerState();
}

class _PostMainContainerState extends State<PostMainContainer> {

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
    _getTaggedList();

  }

  stateSetter(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.postsLength >= 3 && widget.postIndex == 3){
      return FutureBuilder(
        future: getFriendSuggestions(),
        builder: (context, AsyncSnapshot<List> snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData){
              return SizedBox(
                height: 350.0,
                width: MediaQuery.of(context).size.width,
                //color: Colors.grey[100]!,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                      child: Text("People you may know", style: TextStyle(color: Palette.kuungaaDefault, fontSize: 18.0, fontWeight: FontWeight.w600),textAlign: TextAlign.start, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        itemCount: snapshot.data!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, int index){
                          Users user = snapshot.data![index];
                          return Container(
                            width: 250.0,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              //borderRadius: BorderRadius.circular(5.0),
                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                              border: Border.all(
                                width: 0.5,
                                color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: (){
                                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: user.user_id!,)));
                                    },
                                    child: ExtendedImage.network(
                                      user.user_profileimage!,
                                      width: 250.0,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0,),
                                InkWell(
                                  onTap:() {
                                    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: user.user_id!,)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                                    child: Text(user.user_firstname! + " " + user.user_lastname!, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800), textAlign: TextAlign.start,),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0, left: 7.0, right: 7.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(user.friend_count!.toString() + " Friends"),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          addFriend(user.user_id!, context, stateSetter);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Palette.kuungaaDefault,
                                        ),
                                        icon: const Icon(MdiIcons.plus, size: 18, color: Colors.black,),
                                        label: const Text("Add Friend", style: TextStyle(color: Colors.black,),),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }else{
              return const SizedBox.shrink();
            }
          }else{
            return SizedBox(
              height: 350.0,
              child: ListView.builder(
                itemCount: 3,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, int index){
                  return Shimmer.fromColors(
                    baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200]!,
                    highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                    child: Container(
                      width: 250.0,
                      height: double.infinity,
                        decoration: BoxDecoration(
                          //borderRadius: BorderRadius.circular(5.0),
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200]!,
                          border: Border.all(
                            width: 0.5,
                            color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey,
                          ),
                        ),
                    ),
                  );
                },
              ),
            );
          }
        },

      );
    }

    if(widget.postsLength >= 5 && widget.postIndex == 5){
      return FutureBuilder(
        future: getGroupSuggestion(),
        builder: (context, AsyncSnapshot<List> snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData){
              if(snapshot.data!.isNotEmpty){
                return SizedBox(
                  height: 350.0,
                  width: MediaQuery.of(context).size.width,
                  //color: Colors.grey[100]!,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                        child: Text("Explore suggested groups", style: TextStyle(color: Palette.kuungaaDefault, fontSize: 18.0, fontWeight: FontWeight.w600),textAlign: TextAlign.start, maxLines: 1, overflow: TextOverflow.ellipsis,),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          itemCount: snapshot.data!.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, int index){
                            Group group = snapshot.data![index];
                            return Container(
                              width: 250.0,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(5.0),
                                color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                                border: Border.all(
                                  width: 0.5,
                                  color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:Colors.grey[300]!,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SingleGroup(group: group,)));
                                      },
                                      child: ExtendedImage.network(
                                        group.group_icon!,
                                        width: 250.0,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0,),
                                  InkWell(
                                    onTap:() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SingleGroup(group: group,)));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                                      child: Text(group.group_name!, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800), textAlign: TextAlign.start,),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0, left: 7.0, right: 7.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            // Respond to button press
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          icon: const Icon(Icons.close, size: 18, color: Colors.white,),
                                          label: const Text("Remove", style: TextStyle(color: Colors.white,),),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            DatabaseReference gRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Groups").child(group.group_id!).child("members");
                                            gRef.child(userCurrentInfo!.user_id!).set(userCurrentInfo!.user_id!).then((onValue) {
                                              displayToastMessage("You have joined " + group.group_name!, context);
                                              setState(() {

                                              });
                                            }).catchError((onError) {
                                              Navigator.pop(context);
                                              displayToastMessage("An error occurred. Please try again later", context);
                                            });
                                            // Respond to button press
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Palette.kuungaaDefault,
                                          ),
                                          icon: const Icon(MdiIcons.plus, size: 18, color: Colors.white,),
                                          label: const Text("Join", style: TextStyle(color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }else{
                return SizedBox.shrink();
              }
            }else{
              return const SizedBox.shrink();
            }
          }else{
            return const SizedBox.shrink();
          }
        },
      );
    }

    if(widget.postsLength >= 8 && widget.postIndex == 8){
      return FutureBuilder(
        future: getPageSuggestion(),
        builder: (context, AsyncSnapshot<Kpage> snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData){
              Kpage page = snapshot.data!;
              //print("suggested page 2::" + page.page_name!.toString());
              return SizedBox(
                height: 400.0,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                      child: Text("Page you might like", style: TextStyle(color: Palette.kuungaaDefault, fontSize: 18.0, fontWeight: FontWeight.w600),textAlign: TextAlign.start, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              /*borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5.0),
                                topRight: Radius.circular(5.0),
                              ),*/
                              borderRadius: BorderRadius.circular(5.0),
                              child: ExtendedImage.network(
                                page.page_icon!,
                                width: MediaQuery.of(context).size.width,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              height: double.infinity,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.0,
                                  color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(5.0)
                              ),
                            ),
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 1.0, right: 1.0, left: 1.0),
                                padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0, top: 5.0),
                                decoration: BoxDecoration(
                                  /* border: Border(
                                      left: BorderSide(
                                        color: Colors.grey,
                                        width: 0.7,
                                      ),
                                      right: BorderSide(
                                        color: Colors.grey,
                                        width: 0.7,
                                      ),
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 0.7,
                                      ),
                                    ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(5.0),
                                    bottomRight: Radius.circular(5.0),
                                  ),*/
                                  //borderRadius: BorderRadius.circular(5.0),
                                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        Kpage kpage = await getPageFromId(page.page_id!);
                                        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SinglePage(kpage: kpage,)));
                                      },
                                      child: Text(toBeginningOfSentenceCase(page.page_name!)!, style: const TextStyle(fontWeight: FontWeight.w100, fontSize: 17.0), maxLines: 2, overflow: TextOverflow.ellipsis,),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        page.page_postscount != null?Text(
                                            page.page_postscount.toString(),
                                        ):SizedBox.shrink(),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            DatabaseReference pRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Pages").child(page.page_id!).child("members");
                                            pRef.child(userCurrentInfo!.user_id!).set(userCurrentInfo!.user_id!).then((onValue) {
                                              displayToastMessage("You have liked this page", context);
                                              setState(() {

                                              });
                                            }).catchError((onError) {
                                              displayToastMessage("An error occurred. Please try again later", context);
                                            });
                                            // Respond to button press
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                                          ),
                                          icon: Icon(MdiIcons.thumbUpOutline, size: 18, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,),
                                          label: Text("Like", style: TextStyle(color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,),),
                                        ),
                                        /*OutlinedButton.icon(
                                          onPressed: () {
                                            // Respond to button press
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Palette.kuungaaDefault,
                                          ),
                                          icon: const Icon(MdiIcons.messageOutline, size: 18, color: Colors.white,),
                                          label: const Text("Message", style: TextStyle(color: Colors.white,),),
                                        ),*/
                                      ],
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
              );
            }else{
              return const SizedBox.shrink();
            }
          }else{
            return Shimmer.fromColors(
              baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200]!,
              highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
              child: Container(
                height: 400.0,
                width: MediaQuery.of(context).size.width,
                color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200]!,
              ),
            );
          }
        },
      );
    }
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

              widget.post!.post_description != ''?Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(widget.post!.post_description!),
              ):const SizedBox.shrink(),
            ],
          ),
          PostMedia(post: widget.post!),
          PostStats(post: widget.post!),
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _PostComment(),
          ),*/
          Divider(color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!),
        ],
      ),
    );
  }

  getFieldValue(String category, String postid, String field) {
    return AssistantMethods.getFieldname(category, postid, field);
  }

  Future<List> getFriendSuggestions() async{
    List<Users> userSuggestionsList = [];
    final DatabaseReference homeFriendsRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users");
    await homeFriendsRef.once().then((DataSnapshot snapshotPosts) async {
      userSuggestionsList.clear();
      var keys = snapshotPosts.value.keys;
      var values = snapshotPosts.value;

      for (var key in keys)
      {
        String userid = values [key]["user_id"];

        if(userid != userCurrentInfo!.user_id!){

          Query checkFriendDbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(userCurrentInfo!.user_id!).child(userid).orderByKey();
          await checkFriendDbRef.once().then((DataSnapshot snapshot) async {
            if(!snapshot.exists){

              Query checkHiddenFriendRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(userCurrentInfo!.user_id!).child(userid).orderByKey();
              await checkHiddenFriendRef.once().then((DataSnapshot snap) async {
                if(!snap.exists){

                  Users users = Users();
                  Query friendCountRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(userid).orderByKey();
                  await friendCountRef.once().then((DataSnapshot count){

                    int friendCount = 0;

                    if(count.exists){
                      var zees = count.value.keys;
                      var data = count.value;
                      for(var zee in zees)
                      {
                        if(data [zee]["status"] == "confirmed"){
                          friendCount = friendCount + 1;
                        }
                      }
                    }

                    users.user_id = values [key]["user_id"];
                    users.user_firstname = values [key]["user_firstname"];
                    users.user_lastname = values [key]["user_lastname"];
                    users.user_profileimage = values [key]["user_profileimage"];
                    users.friend_count = friendCount;
                    userSuggestionsList.add(users);
                  });
                }
              });
            }
          });
        }
      }
    });
    return userSuggestionsList.reversed.toList();
  }

 Future<Kpage> getPageSuggestion() async{
    List<Kpage> suggestedPagesList = [];
    DatabaseReference pRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Pages");
    await pRef.once().then((DataSnapshot snapshot) async {
      if(snapshot.exists){
        var keys = snapshot.value.keys;
        var values = snapshot.value;
        //print("suggested page ::" +snapshot.value.toString());
        for(var key in keys){
          bool userIsMember = await AssistantMethods.checkUserIsMember("Pages", values[key]["page_id"], userCurrentInfo!.user_id!);
          //print("suggested page 0::" + userIsMember.toString());
          if(userIsMember == false){
            Kpage kpage = Kpage();
            String pid = values [key]["page_id"];
            kpage.page_id = values [key]["page_id"];
            kpage.page_name = values [key]["page_name"];
            kpage.page_icon = values [key]["page_icon"];
            kpage.page_description = values [key]["page_description"];
            kpage.page_creator = values [key]["page_creator"];
            kpage.page_createddate = values [key]["page_createddate"];
            kpage.page_category = values [key]["page_category"];

            DatabaseReference pRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts");
            await pRef.orderByChild("post_id").equalTo(key).once().then((DataSnapshot psnapshot){
              if(psnapshot.exists){
                var pKeys = snapshot.value.keys;
                int i = 0;
                for(var pKey in pKeys){
                  i = i + 1;
                }
                kpage.page_postscount = i;
              }
            });

            //print("suggested page 1::" + kpage.page_name!.toString());

            suggestedPagesList.add(kpage);
          }
        }
      }
    });
    return suggestedPagesList.reversed.toList()[0];
 }

  Future<List> getGroupSuggestion() async{
    List<Group> suggestedGroupList = [];
    DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Groups");
    await dbReference.once().then((DataSnapshot dataSnapshot) async {
      suggestedGroupList.clear();
      var keys = dataSnapshot.value.keys;
      var values = dataSnapshot.value;

      for (var key in keys)
      {

        String gid = values [key]["group_id"];
        DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Groups").child(gid).child("members").child(userCurrentInfo!.user_id!);
        await dbRef.once().then((DataSnapshot snapshot){
          if(!snapshot.exists){
            Group group = Group();
            group.group_id = values [key]["group_id"];
            group.group_name = values [key]["group_name"];
            group.group_icon = values [key]["group_icon"];
            group.group_privacy = values [key]["group_privacy"];
            group.group_creator = values [key]["group_creator"];
            group.group_createddate = values [key]["group_createddate"];

            suggestedGroupList.add(group);
          }
        });
      }
    });

    return suggestedGroupList;
  }
}

Future<String> getUserPostData(String uid, String field) async{
  return AssistantMethods.getUserFieldname(uid, field);
}









