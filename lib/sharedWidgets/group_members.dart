import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/profile_avatar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class GroupMembers extends StatefulWidget {
  final String groupid;
  final String groupcreatorid;
  const GroupMembers({
    Key? key,
    required this.groupid,
    required this.groupcreatorid
  }) : super(key: key);

  @override
  _GroupMembersState createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {

  stateSetter(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0,),
      child: FutureBuilder(
        future: getGroupMembers(widget.groupid),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot){
            if(snapshot.hasData)
            {
              return ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index){
                  Users members = snapshot.data![index];
                  if(widget.groupcreatorid == members.user_id){
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(bottom: 5.0),
                        decoration: BoxDecoration(
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: ListTile(
                          leading: ProfileAvatar(imageUrl: members.user_profileimage!,),
                          title: members.user_id == FirebaseAuth.instance.currentUser!.uid?const Text("You"):Text(
                            members.user_firstname! + " " + members.user_lastname!,
                          ),
                          subtitle: const Text("Admin", style: TextStyle(color: Palette.kuungaaDefault, fontSize: 12.0),),
                        trailing: members.user_id == FirebaseAuth.instance.currentUser!.uid?SizedBox.shrink():InkWell(
                          onTap: (){
                            showModalBottomSheet(
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                              ),
                              context: context,
                              builder: (context) => buildFriendsSheet(members),
                            );
                          },
                          child: const Icon(
                              Icons.more_horiz
                          ),
                        ),
                      ),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(bottom: 5.0),
                    decoration: BoxDecoration(
                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      leading: ProfileAvatar(imageUrl: members.user_profileimage!,),
                      title: members.user_id == FirebaseAuth.instance.currentUser!.uid?const Text("You"):Text(
                        members.user_firstname! + " " + members.user_lastname!,
                      ),
                      subtitle: const Text("Member", style: TextStyle(fontSize: 12.0),),
                      trailing: members.user_id == FirebaseAuth.instance.currentUser!.uid?SizedBox.shrink():InkWell(
                        onTap: (){
                          showModalBottomSheet(
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                            ),
                            context: context,
                            builder: (context) => buildFriendsSheet(members),
                          );
                        },
                        child: const Icon(
                          Icons.more_horiz
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            else
            {
              return Align(
                alignment: Alignment.center,
                child: Center(
                  child: LoadingAnimationWidget.flickr(
                    leftDotColor: Palette.kuungaaDefault,
                    rightDotColor: Colors.red,
                    size: 50,
                  ),
                ),
              );
            }
          }
      ),
    );
  }

  Future<List> getGroupMembers(String groupid) async{
    List<Users> membersList = [];

    final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Groups').child(groupid).child("members");
    await query.once().then((event) async {
      membersList.clear();
      var keys = event.value.keys;

      if(event.value != ''){
        //Posts post = Posts.fromSnapshot(event.snapshot);
        //allPosts.add(post);
        // servicesList.add(userServices!);
        for (var key in keys)
        {
          String memberid = key;

          DatabaseReference reference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users");

          await reference.child(memberid).once().then((DataSnapshot snap)
          {
            if(snap.value != null)
            {
              //print("User infodetails" + snap.value.toString());
              Users users = Users.fromSnapshot(snap);
              //print("User infodetails:" + userCurrentInfo.toString());
              membersList.add(users);

            }
          });
        }
      }
    });
    return membersList;
   }

  Widget buildFriendsSheet(Users members) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder(
              future: checkUserFriendStatus(members.user_id!),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                if(snapshot.connectionState == ConnectionState.done){
                  if(snapshot.hasData){
                    String status = snapshot.data!;
                    if(status == "is_friend"){
                      return InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          unFriend(members.user_id!, stateSetter);
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
                      );
                    }else if(status == "requesting"){
                      return InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          declineFriend(members.user_id!, context, stateSetter);
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
                                  FontAwesomeIcons.userSlash,
                                  color: Colors.red,
                                ),
                                iconSize: 22.0,
                                onPressed: () => {},
                              ),
                            ),
                            const SizedBox(width: 14.0,),
                            const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }else if(status == "requested"){
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              acceptFriend(members.user_id!, context, stateSetter);
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
                                      FontAwesomeIcons.userPlus,
                                      color: Palette.kuungaaDefault,
                                    ),
                                    iconSize: 22.0,
                                    onPressed: () => {},
                                  ),
                                ),
                                const SizedBox(width: 14.0,),
                                const Text(
                                  "Accept",
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
                              declineFriend(members.user_id!, context, stateSetter);
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
                                      FontAwesomeIcons.userAltSlash,
                                      color: Colors.red,
                                    ),
                                    iconSize: 22.0,
                                    onPressed: () => {},
                                  ),
                                ),
                                const SizedBox(width: 14.0,),
                                const Text(
                                  "Decline",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }else{
                      return InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          addFriend(members.user_id!, context, stateSetter);
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
                                  Icons.add,
                                  color: Colors.green,
                                ),
                                iconSize: 22.0,
                                onPressed: () => {},
                              ),
                            ),
                            const SizedBox(width: 14.0,),
                            const Text(
                              "Add Friend",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }else{
                    return SizedBox.shrink();
                  }
                }else{
                  return Container(
                    child: Align(
                      alignment: Alignment.center,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
              }
          ),
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              startMessegeUser(context, members.user_id!);
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
