import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
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
class UserFriendsContainer extends StatefulWidget {
  final String userid;
  const UserFriendsContainer({
    Key? key,
     this.userid = ""
  }) : super(key: key);

  @override
  _UserFriendsContainerState createState() => _UserFriendsContainerState();
}

class _UserFriendsContainerState extends State<UserFriendsContainer> {

  stateSetter(){
    setState(() {

    });
  }

  Query? itemRefFriends;
  bool _anchorToBottom = false;
  List<Users> searchList = [];
  List<Users> userFriendsList = [];

  bool _iconIsVisible = false;

  TextEditingController textSearchEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    if(widget.userid != ""){
      itemRefFriends = database.reference().child("KUUNGAA").child("Friends").child(widget.userid)
          .orderByChild("status").equalTo("confirmed");
    }else{
      itemRefFriends = database.reference().child("KUUNGAA").child("Friends").child(FirebaseAuth.instance.currentUser!.uid)
          .orderByChild("status").equalTo("confirmed");
    }
    itemRefFriends!.onChildAdded.listen(_onEntryAddedFriends);
  }

  _onEntryAddedFriends(Event event) async {
    String friendId = event.snapshot.value["friendid"];
    final DatabaseReference friendInfoRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(friendId);
    await friendInfoRef.once().then((DataSnapshot snapshot) async {
      Users users = Users.fromSnapshot(snapshot);
      Query friendCountRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(friendId).orderByKey();
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
        users.friend_count = friendCount;
      });
      setState(() {
        userFriendsList.add(users);
      });
    });
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
                      child: Text("Your friends", style: TextStyle(fontWeight: FontWeight.bold),),
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
          child: userFriendsList.isNotEmpty || searchList.isNotEmpty?Container(
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
                            List<Users> result = userFriendsList.where((Users user)
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
                          hintText: "Search your friend list ...",
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
          child: searchList.isNotEmpty?ListView.builder(
            padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 20.0, top: 0.0),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchList.length,
            itemBuilder: (BuildContext context, int index){
              Users users = searchList[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
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
                      trailing: InkWell(
                        onTap: (){
                          showModalBottomSheet(
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                            ),
                            context: context,
                            builder: (context) => buildFriendsSheet(users),
                          );
                        },
                        child: const Icon(Icons.more_horiz),
                      ),
                    ),
                  ],
                ),
              );
            },
          ):userFriendsList.isNotEmpty?FirebaseAnimatedList(
              physics: const NeverScrollableScrollPhysics(),
              query: itemRefFriends!,
              reverse: _anchorToBottom,
              key: ValueKey<bool>(_anchorToBottom),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder:(_, DataSnapshot snapshot, Animation<double> animation, int index){
                if(snapshot.exists){
                  if(index + 1 <= userFriendsList.length){
                    Users users = userFriendsList[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
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
                            trailing: InkWell(
                              onTap: (){
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                                  ),
                                  context: context,
                                  builder: (context) => buildFriendsSheet(users),
                                );
                              },
                              child: const Icon(Icons.more_horiz),
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
          ): ListView.builder(
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
                      trailing: Shimmer.fromColors(
                        baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                        child: Container(
                          height: 24.0,
                          width: 24.0,
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildFriendsSheet(Users users) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              unFriend(users.user_id!, stateSetter);
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      FontAwesomeIcons.userMinus,
                      color: Colors.red,
                    ),
                    iconSize: 22.0,
                    onPressed: () => {},
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Unfriend",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              startMessegeUser(context, users.user_id!);
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.message,
                      color: Colors.green,
                    ),
                    iconSize: 22.0,
                    onPressed: () => {},
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Message",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
