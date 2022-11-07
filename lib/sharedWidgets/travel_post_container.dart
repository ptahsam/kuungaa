import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snippet_coder_utils/hex_color.dart';

import 'widgets.dart';

class TravelPostContainer extends StatefulWidget {
  final String travelCategory;
  const TravelPostContainer({
    Key? key,
    required this.travelCategory
  }) : super(key: key);

  @override
  _TravelPostContainerState createState() => _TravelPostContainerState();
}

class _TravelPostContainerState extends State<TravelPostContainer> {

  //late Future<List> getTravelPosts;

  List<Posts> listPosts = [];
  Query? itemRefPosts;
  bool _anchorToBottom = false;
  bool categoryHasPosts = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    listPosts.clear();
  }

  @override
  void didUpdateWidget(covariant TravelPostContainer oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(widget.travelCategory == "All"){
      listPosts.clear();
      itemRefPosts = FirebaseDatabase.instance.reference().child('KUUNGAA').child("Posts").orderByChild('post_category').equalTo('travelfeed').limitToLast(100);
    }else{
      listPosts.clear();
      itemRefPosts = FirebaseDatabase.instance.reference().child('KUUNGAA').child("Posts").orderByChild('post_travelcategory').equalTo(widget.travelCategory).limitToLast(100);
    }
      itemRefPosts!.once().then(_onPost);
    //print("travel category :: " + widget.travelCategory);
      itemRefPosts!.onChildAdded.listen(_onEntryAddedPosts);
    //itemRefComment!.onChildChanged.listen(_onEntryChangedComment);
      itemRefPosts!.onChildRemoved.listen(_onEntryRemovedPosts);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    if(widget.travelCategory == "All"){
      listPosts.clear();
      itemRefPosts = database.reference().child('KUUNGAA').child("Posts").orderByChild('post_category').equalTo('travelfeed').limitToLast(100);
    }else{
      listPosts.clear();
      itemRefPosts = database.reference().child('KUUNGAA').child("Posts").orderByChild('post_travelcategory').equalTo(widget.travelCategory).limitToLast(100);
    }
    itemRefPosts!.once().then(_onPost);
    //print("travel category :: " + widget.travelCategory);
    itemRefPosts!.onChildAdded.listen(_onEntryAddedPosts);
    //itemRefComment!.onChildChanged.listen(_onEntryChangedComment);
    itemRefPosts!.onChildRemoved.listen(_onEntryRemovedPosts);

  }

  _onPost(DataSnapshot snapshot){
    if(snapshot.exists){
      if(snapshot.value != "" || snapshot.value != null){
        setState(() {
          categoryHasPosts = true;
        });
      }
    }else{
      setState(() {
        categoryHasPosts = false;
      });
    }
  }

  _onEntryAddedPosts(Event event) async {
    if(event.snapshot.exists){
      DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(FirebaseAuth.instance.currentUser!.uid).child(event.snapshot.key!);
      await hiddenRef.once().then((DataSnapshot snapshot) async {
        if(!snapshot.exists){
          Posts post = Posts();
          post.post_id = event.snapshot.value["post_id"];
          post.post_description = event.snapshot.value["post_description"];
          post.post_time = event.snapshot.value["post_time"];
          post.poster_id = event.snapshot.value["poster_id"];
          post.post_privacy = event.snapshot.value["post_privacy"];
          post.post_city = event.snapshot.value["post_city"];
          post.post_countryname = event.snapshot.value["post_countryname"];
          post.post_countrycode = event.snapshot.value["post_countrycode"];
          post.post_finelocation = event.snapshot.value["post_finelocation"];
          post.post_category = event.snapshot.value["post_category"];
          post.post_travelcategory = event.snapshot.value["post_travelcategory"];
          post.post_expression = event.snapshot.value["post_expression"];
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
    return categoryHasPosts?Container(
      padding: const EdgeInsets.only(top: 5.0),
      child: listPosts.isNotEmpty?FirebaseAnimatedList(
          physics: const NeverScrollableScrollPhysics(),
          query: itemRefPosts!,
          reverse: _anchorToBottom,
          key: ValueKey<bool>(_anchorToBottom),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder:(_, DataSnapshot snapshot, Animation<double> animation, int index){
            if(snapshot.exists){
              if(index + 1 <= listPosts.length) {
                return Column(
                  children: [
                    TravelPostMainContainer(post: listPosts[index],),
                    listPosts.length > 1 ?
                    Divider(color: Provider
                        .of<AppData>(context)
                        .darkTheme ? Palette.mediumDarker : Colors.grey[300]!,
                    ) : const SizedBox.shrink(),
                  ],
                );
              }else{
                return SizedBox.shrink();
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
          future: getAllTravelPosts(widget.travelCategory),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot){
            if(snapshot.connectionState == ConnectionState.done)
            {
              if(snapshot.data!.isNotEmpty){
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index){
                    return Column(
                      children: [
                        TravelPostMainContainer(post: snapshot.data![index],),
                        snapshot.data!.length > 1 ?
                        Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        ) : const SizedBox.shrink(),
                      ],
                    );
                  },
                );
              }else{
                return const Align(
                  alignment: Alignment.center,
                  child: Text("No posts in this category yet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),),
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
    ):Container(
      padding: EdgeInsets.only(top: 20.0),
      child: Align(
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
                  MdiIcons.newspaper,
                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                ),
                SizedBox(height: 6.0,),
                Text("No posts in this category", textAlign: TextAlign.center,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List> getAllTravelPosts(String travelCategory)  async {

    List<Posts> allPosts = [];

    if(travelCategory == "All"){

      final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts')
          .orderByChild('post_category').equalTo('travelfeed');
      //allPosts.clear();
      await query.once().then((event) async {

        if(event.exists){
          allPosts.clear();
          var keys = event.value.keys;
          var values = event.value;
          //Posts post = Posts.fromSnapshot(event.snapshot);
          //allPosts.add(post);
         // servicesList.add(userServices!);
          for (var key in keys)
          {
            Posts post = Posts();
            post.post_id = values [key]["post_id"];
            post.post_description = values [key]["post_description"];
            post.post_time = values [key]["post_time"];
            post.poster_id = values [key]["poster_id"];
            post.post_privacy = values [key]["post_privacy"];
            post.post_city = values [key]["post_city"];
            post.post_countryname = values [key]["post_countryname"];
            post.post_countrycode = values [key]["post_countrycode"];
            post.post_finelocation = values [key]["post_finelocation"];
            post.post_category = values [key]["post_category"];
            post.post_travelcategory = values [key]["post_travelcategory"];
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

                      //print("tagged user 2 ::" + users.user_id!);
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
        }
      });
    }else {
      final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts')
          .orderByChild('post_travelcategory').equalTo(travelCategory);
      //allPosts.clear();
      await query.once().then((event) async {

        if(event.exists){
          allPosts.clear();
          var keys = event.value.keys;
          var values = event.value;
          //Posts post = Posts.fromSnapshot(event.snapshot);
          //allPosts.add(post);
          // servicesList.add(userServices!);
          for (var key in keys)
          {
            Posts post = Posts();
            post.post_id = values [key]["post_id"];
            post.post_description = values [key]["post_description"];
            post.post_time = values [key]["post_time"];
            post.poster_id = values [key]["poster_id"];
            post.post_privacy = values [key]["post_privacy"];
            post.post_city = values [key]["post_city"];
            post.post_countryname = values [key]["post_countryname"];
            post.post_countrycode = values [key]["post_countrycode"];
            post.post_finelocation = values [key]["post_finelocation"];
            post.post_travelcategory = values [key]["post_travelcategory"];
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

                      //print("tagged user 2 ::" + users.user_id!);
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
        }
      });
    }
    return allPosts.reversed.toList();
  }
}

class TravelPostMainContainer extends StatefulWidget {
  final Posts? post;


  const TravelPostMainContainer({
    Key? key,
    this.post
  }) : super(key: key);

  @override
  State<TravelPostMainContainer> createState() => _TravelPostMainContainerState();
}

class _TravelPostMainContainerState extends State<TravelPostMainContainer> {

  List<Widget> _taggedUserList = [];

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
              style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    FutureBuilder(
                      future: getTravelUserPostData(widget.post!.poster_id!, "user_profileimage"),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                        if(snapshot.hasData){
                          return InkWell(
                            onTap: (){
                              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post!.poster_id!,)));
                            },
                            child: ProfileAvatar(imageUrl: snapshot.data!),
                          );
                        }else{
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    const SizedBox(width: 8.0,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Row(
                            children: [
                              FutureBuilder(
                                future: getTravelCategory(widget.post!.post_travelcategory!),
                                builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                                  if(snapshot.hasData){
                                    return Text(
                                      snapshot.data! + " . ",
                                      style: TextStyle(
                                        color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                        fontSize: 12.0,
                                      ),
                                    );
                                  }else{
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                              Icon(
                                Icons.public,
                                color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                size: 12.0,
                              ),
                              const SizedBox(width: 4.0,),
                              Text(
                                convertToTimeAgo(widget.post!.post_time!),
                                //'${post!.post_time!}',

                                style: TextStyle(
                                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    ContextMenu(post: widget.post!),
                  ],
                ),
              ),
              const SizedBox(height: 8.0,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4.0),
                      margin: const EdgeInsets.only(bottom: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.5,
                          color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:HexColor("#ced4da"),
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Row(
                        children: [
                          ExtendedImage.asset(
                            'icons/flags/png/' + widget.post!.post_countrycode!.toLowerCase() + '.png', package: 'country_icons',
                            height: 25.0,
                            width: 25.0,
                            fit: BoxFit.cover,
                            shape: BoxShape.circle,
                          ),
                          const SizedBox(width: 5.0,),
                          Text(widget.post!.post_city! + ", " + widget.post!.post_countryname!),
                          //widget.post!.post_privacy == "off"? Text(widget.post!.post_city! + ", " + widget.post!.post_countryname!) : Text(widget.post!.post_finelocation!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              widget.post!.taggedUsers != null?
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Wrap(
                  children: _taggedUserList,
                ),
              ):SizedBox.shrink(),

              widget.post!.post_description != ""?Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(widget.post!.post_description!),
              ):SizedBox.shrink(),
            ],
          ),
          PostMedia(post: widget.post!),
          PostStats(post: widget.post!),
        ],
      ),
    );
  }

  Future<String> getTravelCategory(String travelcatoryid) async {
    return AssistantMethods.getTravelCategoryname(travelcatoryid);
  }
}

Future<String> getTravelUserPostData(String uid, String field) async{
  return AssistantMethods.getUserFieldname(uid, field);
}




