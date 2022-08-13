import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/page.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snippet_coder_utils/hex_color.dart';

import 'widgets.dart';
class PageContainer extends StatefulWidget {
  const PageContainer({Key? key}) : super(key: key);

  @override
  _PageContainerState createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> {

  List<Posts> listPosts = [];
  Query? itemRefPosts;
  bool _anchorToBottom = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefPosts = database.reference().child('KUUNGAA').child('Posts')
        .orderByChild('post_category').equalTo('pagesfeed');
    itemRefPosts!.onChildAdded.listen(_onEntryAddedPosts);
    itemRefPosts!.onChildRemoved.listen(_onEntryRemovedPosts);
  }

  _onEntryAddedPosts(Event event) async {
    DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(FirebaseAuth.instance.currentUser!.uid).child(event.snapshot.key!);
    hiddenRef.once().then((DataSnapshot snapshot) async {
      if(!snapshot.exists){
        Posts post = Posts();
        post.post_id = event.snapshot.key;
        post.pid = event.snapshot.value["post_id"];
        post.post_description = event.snapshot.value["post_description"];
        post.post_time = event.snapshot.value["post_time"];
        post.poster_id = event.snapshot.value["poster_id"];
        post.post_privacy = event.snapshot.value["post_privacy"];
        post.post_city = event.snapshot.value["post_city"];
        post.post_countryname = event.snapshot.value["post_countryname"];
        post.post_finelocation = event.snapshot.value["post_finelocation"];
        post.post_category = event.snapshot.value["post_category"];
        post.kpage = await getPageFromId(event.snapshot.value["post_id"]);
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
        setState(() {
          listPosts.add(post);
        });
      }
    });
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
                  PagePostMainContainer(post: listPosts[index],),
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
          future: getAllPagesPosts(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot){
            if(snapshot.connectionState == ConnectionState.done)
            {
              return ListView.builder(
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                addSemanticIndexes: true,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index){
                  return Column(
                    children: [
                      PagePostMainContainer(post: snapshot.data![index],
                      ),
                      snapshot.data!.length > 1 ?
                      Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                      ) : const SizedBox.shrink(),
                    ],
                  );

                },
              );
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

  Future<List> getAllPagesPosts()  async {

    List<Posts> allPosts = [];

    final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts')
        .orderByChild('post_category').equalTo('pagesfeed');
    //allPosts.clear();
    await query.once().then((event) async {
      allPosts.clear();
      var keys = event.value.keys;
      var values = event.value;

      if(event.value != ''){
        //Posts post = Posts.fromSnapshot(event.snapshot);
        //allPosts.add(post);
        // servicesList.add(userServices!);
        for (var key in keys)
        {
          Posts post = Posts();
          post.post_id = key;
          post.pid = values [key]["post_id"];
          post.post_description = values [key]["post_description"];
          post.post_time = values [key]["post_time"];
          post.poster_id = values [key]["poster_id"];
          post.post_privacy = values [key]["post_privacy"];
          post.post_city = values [key]["post_city"];
          post.post_countryname = values [key]["post_countryname"];
          post.post_finelocation = values [key]["post_finelocation"];
          post.post_category = values [key]["post_category"];
          post.kpage = await getPageFromId(values [key]["post_id"]);
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
    return allPosts.reversed.toList();
  }
}

class PagePostMainContainer extends StatefulWidget {
  final Posts? post;


  const PagePostMainContainer({
    Key? key,
    this.post
  }) : super(key: key);

  @override
  State<PagePostMainContainer> createState() => _PagePostMainContainerState();
}

class _PagePostMainContainerState extends State<PagePostMainContainer> {

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
                    SizedBox(
                      height: 35.0,
                      width: 35.0,
                      child: Stack(
                        children: [
                          InkWell(
                            onTap: () async {
                              Kpage kpage = await getPageFromId(widget.post!.pid!);
                              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SinglePage(kpage: kpage,)));
                            },
                            child: BoxAvatar(imageUrl: widget.post!.kpage!.page_icon!),
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
                    const SizedBox(width: 8.0,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            child: InkWell(
                              onTap: () async {
                                Kpage kpage = await getPageFromId(widget.post!.pid!);
                                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SinglePage(kpage: kpage,)));
                              },
                              child: Text(
                                widget.post!.kpage!.page_name!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: HexColor("#4285F4"),
                                ),
                              ),
                            ),
                          ),

                          InkWell(
                            onTap: (){
                              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post!.poster_id!,)));
                            },
                            child: Row(
                              children: [
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
                                ),
                                const Text(" . "),
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
                          ),
                        ],
                      ),
                    ),

                    ContextMenu(post: widget.post!),
                  ],
                ),
              ),

              widget.post!.taggedUsers != null?
              Container(
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
}
