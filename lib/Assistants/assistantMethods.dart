
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kuungaa/Assistants/requestAssistant.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/address.dart';
import 'package:kuungaa/Models/chat.dart';
import 'package:kuungaa/Models/group.dart';
import 'package:kuungaa/Models/like.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/message.dart';
import 'package:kuungaa/Models/notification.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:provider/provider.dart';


class AssistantMethods
{
  static Future<String> searchCoordinateAddress(Position position, context) async
  {
    String placeAddress = "";
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    //String url = "http://api.positionstack.com/v1/reverse?access_key=3ab30a2f2cfba83e8ba75e2e6bb027cf&query=40.7638435,-73.9729691";

    var response = await RequestAssistant.getRequest(url);

    if(response != "failed")
    {

      placeAddress = response["results"][0]["formatted_address"];
      //st1 = response["results"][0]["address_components"][3]["long_name"];
      //st2 = response["results"][0]["address_components"][5]["long_name"];
      Address userCurrentAddress = Address();

      userCurrentAddress.longitude = position.longitude;
      userCurrentAddress.latitude = position.latitude;
      userCurrentAddress.placeFormattedAddress = placeAddress;

      List<dynamic> addressComponents = response['results'][0]['address_components'];
      String countryname = addressComponents
          .firstWhere((entry) => entry['types'].contains('country'))['long_name'];
      String countrycode = addressComponents
          .firstWhere((entry) => entry['types'].contains('country'))['short_name'];
      String city = addressComponents
          .firstWhere((entry) => entry['types'].contains('administrative_area_level_1'))['long_name'];


     // String countryname = response["results"][0]["address_components"].toString();
     // String countrycode = response["results"][0]["address_components"][4]["short_name"];;
      //String city = response["results"][0]["address_components"][3]["long_name"];;



      userCurrentAddress.placeCityName = city;
      userCurrentAddress.placeCountryName = countryname;
      userCurrentAddress.placeCountryCode = countrycode;

      //Address userCurrentAddress = Address.fromJson(response);

      Provider.of<AppData>(context, listen: false).updateUserCurrentLocationAddress(userCurrentAddress);      //st3 = response["results"][0]["address_components"][6]["long_name"];
      //st4 = response["results"][0]["address_components"][7]["long_name"];

      //placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;


    }
    else{
      placeAddress = "No data yet";
    }

    return placeAddress;
  }

  static userIsTyping(BuildContext context, String chatid, String userid) async {
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatid).child("members").child(userid).child("isTyping");
    await dbRef.onValue.forEach((data) {
      if(data.snapshot.exists){
        if(data.snapshot.value == true){
          Provider.of<AppData>(context, listen: false).updateUserTypingStatus(true);
        }else{
          Provider.of<AppData>(context, listen: false).updateUserTypingStatus(false);
        }
      }
    });
  }

  static userOnline() async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser!.uid;
    DatabaseReference conRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(userId).child("connections");
    DatabaseReference lastOnlineRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(userId).child("lastOnline");

    DatabaseReference connectedRef = FirebaseDatabase.instance.reference().child('.info/connected');

    connectedRef.onValue.forEach((event) async {
      if(event.snapshot.value == true){
        var con = conRef.push();
        con.onDisconnect().remove();
        con.set(true);

        int time = await getCurrentTime();
        Map lastOnlineMap = {
          "last_seen" : time
        };

        lastOnlineRef.onDisconnect().set(lastOnlineMap);
      }
    });
  }

  static getPostCommentCount(BuildContext context, String postid) async {
    int count = 0;
    Query dbQuery = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postid).child("comments");
    dbQuery.onChildAdded.forEach((event) {
      if(event.snapshot.exists){
        count = count + 1;
        postCommentCount = count;
        Provider.of<AppData>(context, listen: false).updatePostCommentCount(count);
      }
    });

    dbQuery.onChildRemoved.forEach((event) {
      if(event.snapshot.exists){
        postCommentCount = postCommentCount - 1;
        Provider.of<AppData>(context, listen: false).updatePostCommentCount(postCommentCount);
      }
    });
  }

  static updateUserNotification(BuildContext context) async{
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser!.uid;


    Query dbQuery = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Notifications").orderByChild("notification_recipient").equalTo(userId);
    await dbQuery.onChildChanged.forEach((event) {
      if(event.snapshot.exists){
        if(event.snapshot.value["notification_status"] == "seen"){
          userNotificationsCount = userNotificationsCount - 1;
          Notifications notifications = Notifications();
          notifications.notification_count = userNotificationsCount;
          //print("Nitification count ::" + notifcount.toString() );
          Provider.of<AppData>(context, listen: false).updateNotification(notifications);
          //count = count + 1;
        }
      }
    });
  }

  static updateOnlineStatus(BuildContext context, String chatpartnerid) async {
    String isOnline = "";
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(chatpartnerid);
    await dbRef.child("connections").onValue.forEach((event) async {
      if(event.snapshot.exists){
        isOnline = "online";
        Provider.of<AppData>(context, listen: false).updateUserOnlineStatus(isOnline);
      }else{
        await dbRef.child("lastOnline").onValue.forEach((snap) {
          if(snap.snapshot.exists){
            isOnline = "last seen " + convertToHour24(snap.snapshot.value["last_seen"]);
            Provider.of<AppData>(context, listen: false).updateUserOnlineStatus(isOnline);
          }
        });
      }
    });
  }

  static getPostComments(BuildContext context, String postid){
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postid).child("comments");

  }

  static getUserFavoriteContacts(BuildContext context)  async {
    List<Users> contactList = [];
    await FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users")
        .onChildAdded.forEach((data) async {
          if(data.snapshot.exists){
            if(data.snapshot.value["user_id"] != userCurrentInfo!.user_id!){
              Users users = Users.fromSnapshot(data.snapshot);
              await FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(data.snapshot.value["user_id"]).
              child("connections").onValue.forEach((event) async {
                if(event.snapshot.exists){
                  users.isOnline = true;
                  contactList.add(users);
                  Provider.of<AppData>(context, listen: false).updateFavoriteContactsList(contactList.reversed.toSet().toList());
                }else{
                  users.isOnline = false;
                  contactList.add(users);
                  Provider.of<AppData>(context, listen: false).updateFavoriteContactsList(contactList.reversed.toSet().toList());
                }
              });
            }
          }
    });
  }

  static getPlacesVisited(BuildContext context, String userid) async {
    List<Posts> visistedPlacesList = [];
    final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts')
        .orderByChild('poster_id').equalTo(userid);
    await query.onChildAdded.forEach((event) async {
      if(event.snapshot.exists){
        final DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(event.snapshot.key!).child("post_location");
        await dbReference.once().then((DataSnapshot snapshot){
          if(snapshot.exists){
            Posts post = Posts();

            post.latitude = snapshot.value["latitude"];
            post.longitude = snapshot.value["longitude"];
            post.locationaddress = snapshot.value["locationaddress"];

            visistedPlacesList.add(post);
          }
        });
        Provider.of<AppData>(context, listen: false).updateVisitedPlaces(visistedPlacesList.reversed.toSet().toList());

      }
    });
  }

  static getChatMessages(BuildContext context, String chatid) async {
    List<Message> chatMessage = [];
    Query chatQuery = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatid).child("messages");
    await chatQuery.orderByKey().onChildAdded.forEach((event) {
      if(event.snapshot.exists){
        Message message = Message.fromSnapshot(event.snapshot);
        if(event.snapshot.value["message_media"] != ""){
          List<Media> listMedia = [];
          for(var i in event.snapshot.value["message_media"]){
            Media media = Media.fromJson(Map<String, dynamic>.from(i));
            listMedia.add(media);
          }
          message.messageMedia = listMedia.toSet().toList();
        }
        chatMessage.add(message);
        Provider.of<AppData>(context, listen: false).updateChatMessages(chatMessage.reversed.toList());
      }
    });
  }

  static getlatestMessage(BuildContext context, String chatid) async {
    Query chatQuery = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatid).child("messages");
    await chatQuery.orderByKey().limitToLast(1).onChildAdded.forEach((event) {
      if(event.snapshot.exists){
        Message message = Message.fromSnapshot(event.snapshot);
        Provider.of<AppData>(context, listen: false).updateMessage(message);
      }
    });
  }

  static Future<Chat> getSingleChat(String chatid) async{
    Chat chat = Chat();
    await FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatid)
    .once().then((DataSnapshot chatSnapshot) async {
      if(chatSnapshot.exists){
        chat.chat_createddate = chatSnapshot.value["chat_createddate"];
        chat.chat_id = chatSnapshot.value["chat_id"];
        chat.chat_creatorid = chatSnapshot.value["chat_creatorid"];
        chat.chat_partnerid = chatSnapshot.value["chat_partnerid"];
        await FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatid).child("members")
        .once().then((DataSnapshot snapshotMembers) async {
          var keys = snapshotMembers.value.keys;
          var values = snapshotMembers.value;
          for (var key in keys)
          {
            if(values[key]["member_id"] != userCurrentInfo!.user_id!){
              chat.chat_opponentid = values[key]["member_id"];
              chat.opponentUser = await AssistantMethods.getCurrentOnlineUser(values[key]["member_id"]);
            }
          }
        });
        /*await FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatid).child("members")
            .onChildAdded.forEach((memberEvent) async {
          if(memberEvent.snapshot.value["member_id"] != userCurrentInfo!.user_id!){
            // print("chat opponent found ::" + memberEvent.snapshot.value.toString());
            chat.chat_opponentid = memberEvent.snapshot.value["member_id"];
            Query chatQuery = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatid).child("messages");
            await chatQuery.orderByKey().limitToLast(1).onChildAdded.forEach((event) async {
              if(event.snapshot.exists){
                //print("chat messages found ::" + event.snapshot.value.toString());
                Message message = Message.fromSnapshot(event.snapshot);
                chat.message = message;

                if(event.snapshot.value["message_media"] != ""){
                  List<Media> listMedia = [];
                  for(var i in event.snapshot.value["message_media"]){
                    Media media = Media.fromJson(Map<String, dynamic>.from(i));
                    listMedia.add(media);
                  }
                  chat.message!.messageMedia = listMedia.toSet().toList();
                }
              }
              chat.opponentUser = await AssistantMethods.getCurrentOnlineUser(memberEvent.snapshot.value["member_id"]);
            });
          }
        });*/
      }
    });
    return chat;
  }

  static getReactions(BuildContext context, String postid) async {
      List<Likes> listLikes = [];
      DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postid);
      await dbRef.onChildAdded.forEach((likeEvent) {
        if(likeEvent.snapshot.exists){
          var keys = likeEvent.snapshot.value.keys;
          var values = likeEvent.snapshot.value;


          for (var key in keys)
          {

            Likes likes = Likes();
            likes.liker_id = values [key]["liker_id"];
            likes.like_type = values [key]["like_type"];
            listLikes.add(likes);
            Provider.of<AppData>(context, listen: false).updateLikes(listLikes.reversed.toSet().toList());
          }
        }
      });
  }

  static getChats(BuildContext context) async{
    List<Chat> userChatList = [];
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats");
    //userChatList.clear();
    await dbRef.onChildAdded.forEach((chatEvent) async {
      if(chatEvent.snapshot.exists){
        //IfuserChatList.clear();
        //print("chats found ::" + chatEvent.snapshot.value.toString());
        Chat chat = Chat();
        await FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatEvent.snapshot.value["chat_id"]).child("members").child(userCurrentInfo!.user_id!)
        .onChildAdded.forEach((element) async {
          if(element.snapshot.exists){
            //print("user chat found ::" + element.snapshot.value.toString());
            chat.chat_createddate = chatEvent.snapshot.value["chat_createddate"];
            chat.chat_id = chatEvent.snapshot.value["chat_id"];
            chat.chat_creatorid = chatEvent.snapshot.value["chat_creatorid"];
            chat.chat_partnerid = chatEvent.snapshot.value["chat_partnerid"];
            await FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatEvent.snapshot.value["chat_id"]).child("members")
            .onChildAdded.forEach((memberEvent) async {
              if(memberEvent.snapshot.value["member_id"] != userCurrentInfo!.user_id!){
               // print("chat opponent found ::" + memberEvent.snapshot.value.toString());
                chat.chat_opponentid = memberEvent.snapshot.value["member_id"];
                Query chatQuery = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatEvent.snapshot.value["chat_id"]).child("messages");
                await chatQuery.orderByKey().limitToLast(1).onChildAdded.forEach((event) async {
                  if(event.snapshot.exists){
                    //print("chat messages found ::" + event.snapshot.value.toString());
                    Message message = Message.fromSnapshot(event.snapshot);
                    chat.message = message;

                    if(event.snapshot.value["message_media"] != ""){
                      List<Media> listMedia = [];
                      for(var i in event.snapshot.value["message_media"]){
                        Media media = Media.fromJson(Map<String, dynamic>.from(i));
                        listMedia.add(media);
                      }
                      chat.message!.messageMedia = listMedia.toSet().toList();
                    }
                    /*List<Media> listMedia = [];
                    await FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chatEvent.snapshot.value["chat_id"]).child("messages").child(event.snapshot.value["message_id"]).child("message_media")
                        .onChildAdded.forEach((mediaEvent){
                      if(mediaEvent.snapshot.exists){

                          Media media = Media.fromSnapshot(mediaEvent.snapshot);
                          listMedia.add(media);
                          //print("message media" + media.url!);
                          chat.messageMedia = listMedia.toSet().toList();
                      }
                    });*/
                  }
                  chat.opponentUser = await AssistantMethods.getCurrentOnlineUser(memberEvent.snapshot.value["member_id"]);
                  userChatList.add(chat);
                  //print("chat list found ::" + chat.chat_opponentid!);
                  Provider.of<AppData>(context, listen: false).updateUserChats(userChatList.reversed.toSet().toList());

                });
              }
            });
          }
        });
      }
    });
  }

  static getUserChats(BuildContext context) async {
    int msgCount = 0;
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser!.uid;
    List<Chat> userCreatedChats = await getUserCreatedChats(userId);
    List<Chat> userPartnerChats = await getUserPartnerChats(userId);

    List<Chat> chatList = userCreatedChats + userPartnerChats;
    for(var i=0; i < chatList.length; i++){
      Chat chat = chatList[i];
      Query dbQuery = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(chat.chat_id!).child("messages");
      dbQuery.onChildAdded.forEach((event) {
        if(event.snapshot.exists){
          if(event.snapshot.value["sender_id"] != userId){
            if(event.snapshot.value["message_status"] == "0"){
              msgCount = msgCount + 1;
              userMessageCount = msgCount;
              Message message = Message();
              message.message_count = msgCount;
              Provider.of<AppData>(context, listen: false).updateMessageCount(message);
            }
          }
        }
      });

      dbQuery.onChildChanged.forEach((event) {
        if(event.snapshot.exists){
          if(event.snapshot.value["sender_id"] != userId){
            if(event.snapshot.value["message_status"] == "1"){
              userMessageCount = userMessageCount - 1;
              Message message = Message();
              message.message_count = userMessageCount;
              Provider.of<AppData>(context, listen: false).updateMessageCount(message);
            }
          }
        }
      });
    }
  }

  static getUserNotification(BuildContext context) async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser!.uid;

    int notifcount = 0;

    Query dbQuery = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Notifications").orderByChild("notification_recipient").equalTo(userId);
    await dbQuery.onChildAdded.forEach((event) {
      if(event.snapshot.exists){
       if(event.snapshot.value["notification_status"] == ""){
         notifcount = notifcount + 1;
         userNotificationsCount = notifcount;
         Notifications notifications = Notifications();
         notifications.notification_count = notifcount;
         Provider.of<AppData>(context, listen: false).updateNotification(notifications);
         //count = count + 1;
       }
      }else{
        notifcount = 0;

      }
    });

  }

  static Future<String> getTravelCategoryname(String categoryid) async {

    final dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("TravelCategories").child(categoryid).child("category_name");
    final snapshot = await dbRef.once();
    String categoryname = snapshot.value.toString();
    return categoryname;
  }

  static Future<String> getUserFieldname(String userid, String userfield) async {

    final dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(userid).child(userfield);
    final snapshot = await dbRef.once();
    String userfieldvalue = snapshot.value.toString();
    return userfieldvalue;
  }

  static Future<bool> checkUserIsMember(String type, String groupid, String userid) async {
    bool memberExists = false;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("KUUNGAA").child(type).child(groupid).child("members").child(userid);
    await reference.once().then((DataSnapshot snap)
    {
      if(snap.exists)
      {
        memberExists = true;
      }
    });
    return memberExists;
  }

  static Future<String> getFieldname(String path, String uid, String field) async {

    final dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child(path).child(uid).child(field);
    final snapshot = await dbRef.once();
    String fieldvalue = snapshot.value.toString();
    return fieldvalue;
  }

  static Future<void> getCurrentOnlineUserInfo() async
  {
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser!.uid;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users");

    reference.child(userId).once().then((DataSnapshot snap)
    {
      if(snap.value != null)
      {
        //print("User infodetails" + snap.value.toString());
        userCurrentInfo = Users.fromSnapshot(snap);
        //print("User infodetails:" + userCurrentInfo.toString());

      }else{

      }
    });
  }

  static getChatUsers(BuildContext context) async {
    List<Users> usersList = [];
    DatabaseReference mRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users");
    mRef.orderByKey().onChildAdded.forEach((data) {
      if(data.snapshot.exists){
        if(data.snapshot.value["user_id"] != userCurrentInfo!.user_id!){
          Users users = Users.fromSnapshot(data.snapshot);
          usersList.add(users);
          Provider.of<AppData>(context, listen: false).updateChatUsersList(usersList.reversed.toSet().toList());
        }
      }
    });
  }

  static Future<Users> getCurrentOnlineUser(String userId) async
  {
    Users? user;
    //firebaseUser = await FirebaseAuth.instance.currentUser;
    //String userId = firebaseUser!.uid;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users");

    await reference.child(userId).once().then((DataSnapshot snap)
    {
      if(snap.exists)
      {
        //print("User infodetails" + snap.value.toString());
        user = Users.fromSnapshot(snap);
        //print("User infodetails:" + userCurrentInfo.toString());

      }
    });
    return user!;
  }

  static Future<Group> getGroupInfo(String groupid) async
  {
    Group? groupInfo;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Groups");

    await reference.child(groupid).once().then((DataSnapshot snap)
    {
      if(snap.value != null)
      {
        //print("User infodetails" + snap.value.toString());
        Group group = Group.fromSnapshot(snap);
        groupInfo = group;

      }
    });
    return groupInfo!;
  }

}