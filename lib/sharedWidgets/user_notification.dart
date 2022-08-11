import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/notification.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/allScreens/screens.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'widgets.dart';
class UserNotification extends StatefulWidget {
  const UserNotification({Key? key}) : super(key: key);

  @override
  _UserNotificationState createState() => _UserNotificationState();
}

class _UserNotificationState extends State<UserNotification> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            shadowColor: Colors.transparent,
            backgroundColor: Palette.kuungaaDefault,
            title: Text("Your notifications",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
            ),
            centerTitle: false,
            floating: true,
            automaticallyImplyLeading: true,
            snap: true,
            elevation: 40.0,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: FutureBuilder(
                future: getUserNotifications(),
                builder: (BuildContext context, AsyncSnapshot<List> snap){
                  if(snap.connectionState == ConnectionState.done){
                    if(snap.hasData){
                      if(snap.data!.isNotEmpty){
                        return ListView.builder(
                          padding: EdgeInsets.only(bottom: 30.0),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snap.data!.length,
                          itemBuilder: (BuildContext context, int index){
                            Notifications notif = snap.data![index];
                            return InkWell(
                              onTap: () async {
                                if (notif.notification_type == "tagged" || notif.notification_type == "comments" || notif.notification_type == "likes") {
                                  Posts post = await getPostFromID(notif.notification_actionid!);
                                  List<Media> mediaList = await getPostMediaImages(notif.notification_actionid!);
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewPostImage(post: post, media: mediaList,)));
                                }
                                if (notif.notification_type == "friendsrequest") {
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: NavScreen(isNavigate: true, sendIndex: 4,)));
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 3.0),
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                                decoration: Provider.of<AppData>(context).darkTheme?BoxDecoration(
                                  color: notif.notification_status == ""? Palette.mediumDarker : Palette.darker,
                                  borderRadius: BorderRadius.circular(5.0),
                                ):BoxDecoration(
                                  color: notif.notification_status == ""? Colors.grey[200]! : Colors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Row(
                                  children: [
                                    ProfileAvatar(imageUrl: notif.userCreator!.user_profileimage!,),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notif.userCreator!.user_firstname! + " " + notif.userCreator!.user_lastname!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0
                                            ),
                                          ),
                                          Text(notif.notification_message!),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                                            decoration: Provider.of<AppData>(context).darkTheme?BoxDecoration(
                                                borderRadius: BorderRadius.circular(8.0),
                                                color: notif.notification_status == ""? Palette.lessDarker : Palette.mediumDarker
                                            ):BoxDecoration(
                                                borderRadius: BorderRadius.circular(8.0),
                                                color: notif.notification_status == ""? Colors.white : Colors.grey[200]!
                                            ),
                                            child: Text(
                                              convertToDate(notif.notification_time!),
                                              style: TextStyle(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
                              color: Colors.grey[100]!,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 6.0,),
                                  Text("You have no notifications", textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }else{
                      return const Center(
                        child: Text(
                          "No notifications",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                        ),
                      );
                    }
                  }else{
                    return const Center(
                      child: CircularProgressIndicator(),
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

  Future<List> getUserNotifications() async {
    List<Notifications> notificationsList = [];
    Query notifRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Notifications").
    orderByChild("notification_recipient").equalTo(userCurrentInfo!.user_id!);
    notificationsList.clear();
    await notifRef.once().then((event) async {
      if(event.exists){
        var keys = event.value.keys;
        var values = event.value;
        for(var i in keys){
          Notifications notification = Notifications();
          notification.notification_creator = values[i]["notification_creator"];
          notification.notification_type = values[i]["notification_type"];
          notification.notification_id = values[i]["notification_id"];
          notification.notification_actionid = values[i]["notification_actionid"];
          notification.notification_status = values[i]["notification_status"];
          notification.notification_message = values[i]["notification_message"];
          notification.notification_time = values[i]["notification_time"];
          notification.notification_recipient = values[i]["notification_recipient"];
          notification.userCreator = await AssistantMethods.getCurrentOnlineUser(values[i]["notification_creator"]);
          notificationsList.add(notification);
        }
      }
    });
    return notificationsList.reversed.toList();
  }

  void updateNotif(Notifications notif) {
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Notifications").child(notif.notification_id!);
    Map<String, dynamic> dbRefNotifMap = {
      "notification_status" : "seen"
    };
    dbRef.update(dbRefNotifMap).then((onValue) {
      setState(() {

      });

    }).catchError((onError) {
      displayToastMessage("An error occurred. Please try again later.", context);
    });
  }

  void updateNotifications() async {
    Query dbQuery = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Notifications").orderByChild("notification_recipient").equalTo(userCurrentInfo!.user_id!);
    await dbQuery.once().then((DataSnapshot snapshot) async {
      if(snapshot.exists){
        var keys = snapshot.value.keys;
        var values = snapshot.value;

        for(var key in keys){
          if(values[key]["notification_status"] != "seen"){
            Map<String, dynamic> dbRefNotifMap = {
              "notification_status" : "seen"
            };
            DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Notifications").child(key);
            await dbRef.update(dbRefNotifMap).then((onValue) {


            }).catchError((onError) {
              displayToastMessage("An error occurred. Please try again later.", context);
            });
          }
        }
      }
    });
  }
}
