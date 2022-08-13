import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'widgets.dart';
class FriendsRequestContainer extends StatefulWidget {
  const FriendsRequestContainer({Key? key}) : super(key: key);

  @override
  _FriendsRequestContainerState createState() => _FriendsRequestContainerState();
}

class _FriendsRequestContainerState extends State<FriendsRequestContainer> {

  stateSetter(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFriendsRequest(),
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
                          //trailing: Icon(Icons.more_horiz),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 9.0, bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => acceptFriend(users.user_id!, context, stateSetter),
                                child: const Text(
                                  "Accept",
                                  style: TextStyle(

                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 6.0,),
                              ElevatedButton(
                                onPressed: () => declineFriend(users.user_id!, context, stateSetter),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                ),
                                child: const Text(
                                  "Decline",
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
                          FontAwesomeIcons.userPlus,
                          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                        ),
                        SizedBox(height: 6.0,),
                        Text("You have no friend requests", textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
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
                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.userPlus,
                        color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                      ),
                      SizedBox(height: 6.0,),
                      Text("You have no friend requests", textAlign: TextAlign.center,),
                    ],
                  ),
                ),
              ),
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
    );
  }

  Future<List> getFriendsRequest() async{
    List<Users> friendsRequestList = [];

    final Query friendsRequestRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(userCurrentInfo!.user_id!).orderByChild("friendtype").equalTo("acceptor");
    await friendsRequestRef.once().then((DataSnapshot dataSnapshot) async {
      if(dataSnapshot.exists){
        friendsRequestList.clear();
        var keys = dataSnapshot.value.keys;
        var values = dataSnapshot.value;

        for(var key in keys){
          if(values [key]["status"] == "unconfirmed"){
            String friendId = values [key]["friendid"];
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
              friendsRequestList.add(users);
            });
          }
        }
      }
    });
    return friendsRequestList.reversed.toList();
  }
}
