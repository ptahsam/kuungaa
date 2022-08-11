import 'package:firebase_database/firebase_database.dart';
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

  @override
  Widget build(BuildContext context) {
    return userCurrentInfo != null?FutureBuilder(
      future: widget.userid == ""?getUserFriends(userCurrentInfo!.user_id!) : getUserFriends(widget.userid),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasData){
            if(snapshot.data!.isNotEmpty){
              return ListView.builder(
                padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 20.0, top: 0.0),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index){
                  Users users = snapshot.data![index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
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
                        Text("You have no friends right now", textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                ),
              );
            }
          }else{
            return const Center(
              child: Text("No friends yet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,),),
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
          );
        }
      },
    ):SizedBox.shrink();
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
