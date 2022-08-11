import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/folder.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
class UserSaved extends StatefulWidget {
  const UserSaved({Key? key}) : super(key: key);

  @override
  State<UserSaved> createState() => _UserSavedState();
}

class _UserSavedState extends State<UserSaved> {

  late Future<List<Folder>> getFolders;

  int selectedIndex = 0;

  String folderid = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFolders = getUserProfileFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
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
            title: Text("Saved Items", style: TextStyle(fontSize: 18.0, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black)),
            actions: [

            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              child: FutureBuilder(
                future: getFolders,
                builder: (ctx, AsyncSnapshot<List<Folder>> snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                      if(snapshot.hasData){
                        return Container(
                          height: 40.0,
                          margin: EdgeInsets.only(top: 15.0),
                          padding: EdgeInsets.only(left: 12.0, right: 12.0,),
                          decoration: BoxDecoration(
                            //color: Palette.kuungaaDefault,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: snapshot.data!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (ctx, int index){
                              Folder folder = snapshot.data![index];
                              return InkWell(
                                onTap: (){
                                  setState(() {
                                    selectedIndex = index;
                                    folderid = folder.folder_key!;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 6.0),
                                  padding: EdgeInsets.all(4.0),
                                  decoration: Provider.of<AppData>(context).darkTheme?BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    color: selectedIndex == index?Palette.darker:Palette.mediumDarker,
                                    border: Border.all(
                                        width: 1.0,
                                        color: HexColor("#ced4da"),
                                    ),
                                  ):BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    color: selectedIndex == index?HexColor("#ced4da"):HexColor("#e9ecef"),
                                    border: Border.all(
                                        width: 1.0,
                                        color: HexColor("#999999"),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selectedIndex == index?MdiIcons.folderOpen:MdiIcons.folder,
                                      ),
                                      SizedBox(width: 2.0,),
                                      Text(folder.folder_name!),
                                      SizedBox(width: 3.0,),
                                      Text(folder.folder_count!.toString()),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }else{
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
                                    MdiIcons.folderAlert,
                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                  ),
                                  SizedBox(height: 6.0,),
                                  Text("You have no saved items", textAlign: TextAlign.center,),
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
                        child: SizedBox(
                          height: 40.0,
                          width: 40.0,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: FutureBuilder<List<Posts>>(
                future: getItemsInFolder(folderid),
                builder: (ctx, AsyncSnapshot<List<Posts>> snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasData){
                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, int index){
                          return PostSavedContainer(post: snapshot.data![index],);
                        },
                      );
                    }else{
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
                                  MdiIcons.folderAlert,
                                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                ),
                                SizedBox(height: 6.0,),
                                Text("You have no saved items", textAlign: TextAlign.center,),
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
                        child: SizedBox(
                          height: 40.0,
                          width: 40.0,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Folder>> getUserProfileFolders() async {
    List<Folder> userFolders = [];
    
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Folders").child(userCurrentInfo!.user_id!);
    await dbRef.once().then((DataSnapshot snapshot) async {
      if(snapshot.exists){
        var keys = snapshot.value.keys;
        var values = snapshot.value;

        for(var key in keys){
          Folder folder = Folder();
          folder.folder_key = values [key]["folder_key"];
          folder.folder_name = values [key]["folder_name"];

          int folderCount = 0;

          DatabaseReference saveRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Saves").child(userCurrentInfo!.user_id!).child(folder.folder_key!);
          await saveRef.once().then((DataSnapshot saveSnapshot){
            if(saveSnapshot.exists){
              var saveKeys = saveSnapshot.value.keys;
              for(var saveKey in saveKeys){
                folderCount = folderCount + 1;
              }
            }
          });
          folder.folder_count = folderCount;

          userFolders.add(folder);
        }
      }
    });

    return userFolders.reversed.toList();
  }

 Future<List<Posts>> getItemsInFolder(String folderid) async {
    List<Posts> postsList = [];
    if(folderid == ""){
      print("getting saved ::");
      final Query dbFolders = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Folders').child(userCurrentInfo!.user_id!).orderByKey().limitToLast(1);
      await dbFolders.once().then((DataSnapshot snapshotFolders) async {
        if(snapshotFolders.exists){
          var keys = snapshotFolders.value.keys;
          var values = snapshotFolders.value;
          for (var key in keys)
          {
            String folderKey = values [key]["folder_key"];

            print("getting saved ::" + folderKey);

            DatabaseReference saveDbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Saves").child(userCurrentInfo!.user_id!).child(folderKey);
            await saveDbRef.once().then((DataSnapshot saveSnapshot) async {
                if(saveSnapshot.exists){
                  var saveKeys = saveSnapshot.value.keys;
                  var saveValues = saveSnapshot.value;

                  for(var saveKey in saveKeys){
                    print("getting saved ::" + saveKey);
                    DatabaseReference postDbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(saveValues[saveKey]["post_id"]);
                    await postDbRef.once().then((DataSnapshot postSnapshot) async {
                      if(postSnapshot.exists){

                        String postKey = postSnapshot.key!;
                        var postValues = postSnapshot.value;

                        print("getting saved postid ::" + postKey);
                        DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(userCurrentInfo!.user_id!).child(postKey);
                        await hiddenRef.once().then((DataSnapshot hiddenSnapshot) async {
                          if(!hiddenSnapshot.exists){
                            Posts post = Posts();
                            post.post_id = postKey;
                            post.pid = postValues["post_id"];
                            post.post_description = postValues["post_description"];
                            post.post_time = postValues["post_time"];
                            post.poster_id = postValues["poster_id"];
                            post.post_privacy = postValues["post_privacy"];
                            post.post_category = postValues["post_category"];
                            post.post_countrycode = postValues["post_countrycode"];
                            post.post_expression = postValues["post_expression"];
                            if(postValues["post_category"] == "pagesfeed"){
                              post.kpage = await getPageFromId(postValues["post_id"]);
                            }
                            if(postValues["post_category"] == "groupsfeed"){
                              post.group = await getGroupFromId(postValues["post_id"]);
                            }
                            DatabaseReference tagRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postKey).child("post_tagged");
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
                            postsList.add(post);
                          }
                        });

                      }
                    });

                  }
                }
            });
          }
        }
      });
    }else{
      DatabaseReference saveDbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Saves").child(userCurrentInfo!.user_id!).child(folderid);
      await saveDbRef.once().then((DataSnapshot saveSnapshot) async {
        if(saveSnapshot.exists){
          var saveKeys = saveSnapshot.value.keys;
          var saveValues = saveSnapshot.value;

          for(var saveKey in saveKeys){
            print("getting saved ::" + saveKey);
            DatabaseReference postDbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(saveValues[saveKey]["post_id"]);
            await postDbRef.once().then((DataSnapshot postSnapshot) async {
              if(postSnapshot.exists){

                String postKey = postSnapshot.key!;
                var postValues = postSnapshot.value;

                print("getting saved postid ::" + postKey);
                DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(userCurrentInfo!.user_id!).child(postKey);
                await hiddenRef.once().then((DataSnapshot hiddenSnapshot) async {
                  if(!hiddenSnapshot.exists){
                    Posts post = Posts();
                    post.post_id = postKey;
                    post.pid = postValues["post_id"];
                    post.post_description = postValues["post_description"];
                    post.post_time = postValues["post_time"];
                    post.poster_id = postValues["poster_id"];
                    post.post_privacy = postValues["post_privacy"];
                    post.post_category = postValues["post_category"];
                    post.post_countrycode = postValues["post_countrycode"];
                    post.post_expression = postValues["post_expression"];
                    if(postValues["post_category"] == "pagesfeed"){
                      post.kpage = await getPageFromId(postValues["post_id"]);
                    }
                    if(postValues["post_category"] == "groupsfeed"){
                      post.group = await getGroupFromId(postValues["post_id"]);
                    }
                    DatabaseReference tagRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postKey).child("post_tagged");
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
                    postsList.add(post);
                  }
                });

              }
            });

          }
        }
      });
    }
    return postsList.reversed.toList();
  }

}

class PostSavedContainer extends StatefulWidget {
  final Posts? post;
  const PostSavedContainer({
    Key? key,
    this.post
  }) : super(key: key);

  @override
  State<PostSavedContainer> createState() => _PostSavedContainerState();
}

class _PostSavedContainerState extends State<PostSavedContainer> {

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
}

