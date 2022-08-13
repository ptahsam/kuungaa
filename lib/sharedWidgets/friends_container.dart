import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'widgets.dart';
class FriendsContainer extends StatefulWidget {
  const FriendsContainer({Key? key}) : super(key: key);

  @override
  _FriendsContainerState createState() => _FriendsContainerState();
}

class _FriendsContainerState extends State<FriendsContainer> {

  bool isSending = false;

  Query? itemRefFriends;
  bool _anchorToBottom = false;

  List<Users> searchList = [];

  List<Users> homeFriendsList = [];

  bool _iconIsVisible = false;

  TextEditingController textSearchEditingController = TextEditingController();

  stateSetter(){
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefFriends = database.reference().child("KUUNGAA").child("Users").orderByKey().limitToLast(100);
    itemRefFriends!.onChildAdded.listen(_onEntryAddedFriends);
  }

  _onEntryAddedFriends(Event event) async {
    if(event.snapshot.exists){
      String userid = event.snapshot.value["user_id"];

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

                  users.user_id = event.snapshot.value["user_id"];
                  users.user_firstname = event.snapshot.value["user_firstname"];
                  users.user_lastname = event.snapshot.value["user_lastname"];
                  users.user_profileimage = event.snapshot.value["user_profileimage"];
                  users.friend_count = friendCount;
                  setState(() {
                    homeFriendsList.add(users);
                  });
                });
              }
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,)
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("People you may know", style: TextStyle(fontWeight: FontWeight.bold),),
                    ),

                    Expanded(
                        child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!)
                    ),
                  ]
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: homeFriendsList.isNotEmpty || searchList.isNotEmpty?Container(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                    ),
                    Expanded(
                      child: TextField(
                        controller: textSearchEditingController,
                        onChanged: (input){
                          if(input != "" || input != null){
                            List<Users> result = homeFriendsList.where((Users user) 
                              => user.user_firstname!.toLowerCase().contains(input.toLowerCase()) 
                                || user.user_lastname!.toLowerCase().contains(input.toLowerCase()) 
                            ).toSet().toList();
                            setState(() {
                              searchList = result.toSet().toList();
                              _iconIsVisible = true;
                            });
                          }else{
                            setState(() {
                              searchList.clear();
                              _iconIsVisible = false;
                            });
                          }
                        },
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 1,
                        style: TextStyle(
                          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding:
                          EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                          hintText: "Search for friends ...",
                          hintStyle: TextStyle(
                            color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                          ),
                        ),

                      ),
                    ),
                    Visibility(
                      visible: _iconIsVisible,
                      child: InkWell(
                        onTap: (){
                          setState(() {
                            searchList.clear();
                            textSearchEditingController.text = "";
                            _iconIsVisible = false;
                          });
                        },
                        child: Icon(
                          Icons.close
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ):SizedBox.shrink(),
        ),
        SliverToBoxAdapter(
          child: searchList.isNotEmpty?
          ListView.builder(
            padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 20.0, top: 0.0),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchList.length,
            itemBuilder: (BuildContext context, int index){
              Users users = searchList[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: InkWell(
                        onTap: (){
                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: users.user_id!,)));
                        },
                        child: ProfileAvatar(imageUrl: users.user_profileimage!, radius: 28.0,),
                      ),
                      title: InkWell(
                        onTap: (){
                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: users.user_id!,)));
                        },
                        child: Text(users.user_firstname! + " " + users.user_lastname!),
                      ),
                      subtitle: Text(users.friend_count == 0? "No friends" : users.friend_count!.toString() + " friends"),
                      trailing: isSending ? const SizedBox(
                        child: CircularProgressIndicator(),
                        height: 10.0,
                        width: 10.0,
                      ) : const SizedBox.shrink(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 9.0, bottom: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => addFriend(users.user_id!, context, stateSetter),
                            child: const Text(
                              "Add Friend",
                              style: TextStyle(

                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 6.0,),
                          ElevatedButton(
                            onPressed: () => removeFriend(users.user_id!),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                            ),
                            child: const Text(
                              "Remove",
                              style: TextStyle(

                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ):homeFriendsList.isNotEmpty?FirebaseAnimatedList(
              physics: const NeverScrollableScrollPhysics(),
              query: itemRefFriends!,
              reverse: _anchorToBottom,
              key: ValueKey<bool>(_anchorToBottom),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder:(_, DataSnapshot snapshot, Animation<double> animation, int index){
                if(snapshot.exists){
                  if(index + 1 <= homeFriendsList.length){
                    Users users = homeFriendsList[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: InkWell(
                              onTap: (){
                                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: users.user_id!,)));
                              },
                              child: ProfileAvatar(imageUrl: users.user_profileimage!, radius: 28.0,),
                            ),
                            title: InkWell(
                              onTap: (){
                                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: users.user_id!,)));
                              },
                              child: Text(users.user_firstname! + " " + users.user_lastname!),
                            ),
                            subtitle: Text(users.friend_count == 0? "No friends" : users.friend_count!.toString() + " friends"),
                            trailing: isSending ? const SizedBox(
                              child: CircularProgressIndicator(),
                              height: 10.0,
                              width: 10.0,
                            ) : const SizedBox.shrink(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 9.0, bottom: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => addFriend(users.user_id!, context, stateSetter),
                                  child: const Text(
                                    "Add Friend",
                                    style: TextStyle(

                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 6.0,),
                                ElevatedButton(
                                  onPressed: () => removeFriend(users.user_id!),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                  ),
                                  child: const Text(
                                    "Remove",
                                    style: TextStyle(

                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }else{
                    return SizedBox.shrink();
                  }
                }else{
                  return SizedBox.shrink();
                }
              }
          ):ListView.builder(
            padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 20.0, top: 0.0),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 15,
            itemBuilder: (BuildContext context, int index){
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Shimmer.fromColors(
                        baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                        child: Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                          ),
                        ),
                      ),
                      title: Shimmer.fromColors(
                        baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                        child: Container(height: 16.0, color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!),
                      ),
                      subtitle: Shimmer.fromColors(
                        baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                        child: Container(height: 16.0, color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 6.0, left: 60.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Shimmer.fromColors(
                              baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                              highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                              child: Container(
                                height: 30.0,
                                color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6.0,),
                          Expanded(
                            child: Shimmer.fromColors(
                              baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                              highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                              child: Container(
                                height: 30.0,
                                color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          /*:FutureBuilder<List<Users>>(
            future: getHomeFriends(),
            builder: (BuildContext context, AsyncSnapshot<List<Users>> snapshot) {
              if(snapshot.connectionState == ConnectionState.done){
                if(snapshot.hasData){
                  if(snapshot.data!.isNotEmpty){
                    List<Users> userList = snapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 20.0, top: 0.0),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userList.toSet().toList().length,
                      itemBuilder: (BuildContext context, int index){
                        Users users = userList.toSet().toList()[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(
                            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: InkWell(
                                  onTap: (){
                                    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: users.user_id!,)));
                                  },
                                  child: ProfileAvatar(imageUrl: users.user_profileimage!, radius: 28.0,),
                                ),
                                title: InkWell(
                                  onTap: (){
                                    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: users.user_id!,)));
                                  },
                                  child: Text(users.user_firstname! + " " + users.user_lastname!),
                                ),
                                subtitle: Text(users.friend_count == 0? "No friends" : users.friend_count!.toString() + " friends"),
                                trailing: isSending ? const SizedBox(
                                  child: CircularProgressIndicator(),
                                  height: 10.0,
                                  width: 10.0,
                                ) : const SizedBox.shrink(),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 9.0, bottom: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => addFriend(users.user_id!, context, stateSetter),
                                      child: const Text(
                                        "Add Friend",
                                        style: TextStyle(

                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 6.0,),
                                    ElevatedButton(
                                      onPressed: () => removeFriend(users.user_id!),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.blue,
                                      ),
                                      child: const Text(
                                        "Remove",
                                        style: TextStyle(

                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.userFriends,
                                color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                              ),
                              SizedBox(height: 6.0,),
                              Text("You have no friends requests right now", textAlign: TextAlign.center,),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
               }else{
                  return const Center(
                    child: Text("No friends requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,),),
                  );
                }
              }else{
                return ListView.builder(
                  padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 20.0, top: 0.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 15,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Shimmer.fromColors(
                              baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                              highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                              child: Container(
                                height: 60.0,
                                width: 60.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                ),
                              ),
                            ),
                            title: Shimmer.fromColors(
                              baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                              highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                              child: Container(height: 16.0, color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!),
                            ),
                            subtitle: Shimmer.fromColors(
                              baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                              highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                              child: Container(height: 16.0, color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0, bottom: 6.0, left: 60.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Shimmer.fromColors(
                                    baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                    highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                    child: Container(
                                      height: 30.0,
                                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6.0,),
                                Expanded(
                                  child: Shimmer.fromColors(
                                    baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                    highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                    child: Container(
                                      height: 30.0,
                                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),*/
        ),
      ],
    );
  }

  Future<List<Users>> getHomeFriends() async{

    final DatabaseReference homeFriendsRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users");
    await homeFriendsRef.once().then((DataSnapshot snapshotPosts) async {
      homeFriendsList.clear();
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
                    homeFriendsList.add(users);
                  });
                }
              });
            }
          });
        }
      }
    });
    return homeFriendsList.reversed.toSet().toList();
  }

  removeFriend(String friendid) async{
    isSending = true;
    DatabaseReference userDBRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(userCurrentInfo!.user_id!).child(friendid);
    DatabaseReference friendDBRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(friendid).child(userCurrentInfo!.user_id!);

    userDBRef.once().then((DataSnapshot snapshot){
      if(snapshot.exists){
        userDBRef.remove();
        friendDBRef.remove();
      }else{
        DatabaseReference dbRef =  FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden").child(userCurrentInfo!.user_id!).child(friendid);
        dbRef.once().then((DataSnapshot dataSnapshot){
          if(!dataSnapshot.exists){
            Map dbRefMap = {
              "post_id" : friendid,
            };
            dbRef.set(dbRefMap).then((onValue) {
              displayToastMessage("This user has been removed from your friends suggestions.", context);
              isSending = false;
              setState(() {

              });

            }).catchError((onError) {
              isSending = false;
              displayToastMessage("An error occurred. Please try again later.", context);
            });
          }
        });
      }
    });
  }
}
