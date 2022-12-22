
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/Models/address.dart';
import 'package:kuungaa/Models/chat.dart';
import 'package:kuungaa/Models/group.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/notification.dart';
import 'package:kuungaa/Models/page.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/tagged.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:week_of_year/date_week_extensions.dart';

String mapKey = "AIzaSyC0f4vakJg3x1YrnrOZcFvOZibLPgXHfOk";

//String gitKey = "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";

const APP_ID = 'fb2bb17b111247ffa6fd0143a6886eeb';
const Token = '006fb2bb17b111247ffa6fd0143a6886eebIACIJTQqojJ95t9uNkHypDtQcXBhvmub4O9RJlFYEq2BPvq5A7wAAAAAEABHuwtvwXU9YgEAAQDAdT1i';

const String url = "ws://192.168.100.118:3000";

User? firebaseUser;

Users? userCurrentInfo;

Address? userCurrentLocation;

List<Tagged> taggedUsers = [];

List<XFile>? imageFileListAll = [];

final videoInfo = FlutterVideoInfo();

Image? logo;

int userNotificationsCount = 0;

int userMessageCount = 0;

int postCommentCount = 0;

class Configurations {
  static const _apiKey = "AIzaSyCXMb2aBc9g06wfan9VDEK2DUioxoehCDE";
  static const _authDomain = "kuungaa-42ba2.firebaseapp.com";
  static const _databaseUrl = "https://kuungaa-42ba2-default-rtdb.firebaseio.com/";
  static const _projectId = "kuungaa-42ba2";
  static const _storageBucket = "kuungaa-42ba2.appspot.com";
  static const _messagingSenderId ="1085640591847";
  static const _appId = "1:1085640591847:web:28a4aaa08a0e860c5a5542";

//Make some getter functions
  String get apiKey => _apiKey;
  String get authDomain => _authDomain;
  String get databaseUrl => _databaseUrl;
  String get projectId => _projectId;
  String get storageBucket => _storageBucket;
  String get messagingSenderId => _messagingSenderId;
  String get appId => _appId;
}

List<Chat> arrangeChats(List<Chat> chat){
  chat.sort((a, b){ //sorting in descending order
    return b.message!.time_created!.compareTo(a.message!.time_created!);
  });
  return chat;
}

List<Notifications> arrangeNotifications(List<Notifications> notifications){
  notifications.sort((a, b){
    //a.notification_time = a.notification_time! > 10?a.notification_time!:a.notification_time!*1000;
   // b.notification_time = b.notification_time! > 10?b.notification_time!:b.notification_time!*1000;
    return a.notification_time!.compareTo(b.notification_time!);
  });
  return notifications;
}

List<Posts> arrangePosts(List<Posts> posts){
  posts.sort((a, b){
    return a.post_time!.compareTo(b.post_time!);
  });
  return posts;
}

List<Posts> arrangeListPosts(List<Posts> posts){
  posts.sort((a, b){
    return b.post_time!.compareTo(a.post_time!);
  });
  return posts;
}

Future<List<Media>> getPostMediaData(String postid) async {
  List<Media> listImage = [];
  final DatabaseReference mediaReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postid).child("post_media");
  await mediaReference.once().then((DataSnapshot snapshotPosts){
    if(snapshotPosts.exists){
      listImage.clear();

      for(var i in snapshotPosts.value){
        Media media = Media.fromJson(Map<String, dynamic>.from(i));
        listImage.add(media);
      }

    }
  });
  return listImage;
}

Future<File> testCompressAndGetFile(File file, String targetPath) async {

  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path, targetPath,
    format: CompressFormat.jpeg
  );

  //print(file.lengthSync());
  //print(result!.lengthSync());

  return result!;
}

Future<List<Media>> getPostMediaImages(String postid) async {
  List<Media> listImage = [];
  final DatabaseReference mediaReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postid).child("post_media");
  await mediaReference.once().then((DataSnapshot snapshotPosts){
    if(snapshotPosts.exists){
      listImage.clear();

      for(var i in snapshotPosts.value){
        Media media = Media.fromJson(Map<String, dynamic>.from(i));
        if(media.type!.contains("image")){
          listImage.add(media);
        }
      }
    }
  });
  return listImage;
}

Future<Posts> getPostFromID(postid) async {
  Posts post = Posts();
  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postid);
  await dbRef.once().then((DataSnapshot snapshot) async {
    if(snapshot.exists){
      post.post_id = snapshot.key!;
      post.pid = snapshot.value["post_id"];
      post.post_description = snapshot.value["post_description"];
      post.post_time = snapshot.value["post_time"];
      post.poster_id = snapshot.value["poster_id"];
      post.post_privacy = snapshot.value["post_privacy"];
      post.post_category = snapshot.value["post_category"];
      post.post_countrycode = snapshot.value["post_countrycode"];
      post.post_expression = snapshot.value["post_expression"];
      if(snapshot.value["post_category"] == "pagesfeed"){
        post.kpage = await getPageFromId(snapshot.value["post_id"]);
      }
      if(snapshot.value["post_category"] == "groupsfeed"){
        post.group = await getGroupFromId(snapshot.value["post_id"]);
      }
      DatabaseReference tagRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(snapshot.key!).child("post_tagged");
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
    }
  });
  return post;
}

Future<String> getShareMedia(key) async {
  String mediaUrl = "";
  List<Media> mediaList = [];
  final DatabaseReference mediaReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(key).child("post_media");
  await mediaReference.once().then((DataSnapshot snapshotPosts){
    if(snapshotPosts.value != ""){
      for(var i in snapshotPosts.value){
        Media media = Media.fromJson(Map<String, dynamic>.from(i));
        mediaList.add(media);
      }
    }
  });
  if(mediaList.isNotEmpty){
    mediaUrl = mediaList[0].url!;
  }
  return mediaUrl;
}

Future<String> getPostVideo(key) async {
  String videoUrl = "";
  final DatabaseReference mediaReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(key).child("post_media");

  await mediaReference.once().then((DataSnapshot snapshotPosts){
    if(snapshotPosts.value != ""){
      for(var i in snapshotPosts.value){
        Media media = Media.fromJson(Map<String, dynamic>.from(i));
        if(media.type!.contains("image")){
        }else{
          videoUrl = media.url!;
        }
      }
    }
  });
  return videoUrl;
}

Future<String> checkUserFriendStatus(String userid) async{
  String? status;
  final DatabaseReference statusRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(userCurrentInfo!.user_id!).child(userid);
  await statusRef.once().then((DataSnapshot snapshot){
    if(snapshot.exists){
      String data = snapshot.value["status"];
      if(data == "confirmed"){
        status = "is_friend";
      }else if(data == "unconfirmed"){
        if(snapshot.value["friendtype"] == "requester"){
          status = "requesting";
        }else{
          status = "requested";
        }
      }
    }else{
      status = "not_friends";
    }
  });
  //print("user_status ::" + status!);
  return status!;
}

unFriend(String friendid, Function stateSetter){

  DatabaseReference userDBRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(userCurrentInfo!.user_id!).child(friendid);
  DatabaseReference friendDBRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(friendid).child(userCurrentInfo!.user_id!);

  userDBRef.remove();
  friendDBRef.remove();

  stateSetter();
}

addFriend(String friendid, BuildContext context, Function stateSetter) async {

  DatabaseReference userDBRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(userCurrentInfo!.user_id!).child(friendid);
  DatabaseReference friendDBRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(friendid).child(userCurrentInfo!.user_id!);

  userDBRef.once().then((DataSnapshot snapshot){
    if(!snapshot.exists){

      Map userDBRefMap = {
        "friendid" : friendid,
        "friendtype" : "requester",
        "status" : "unconfirmed"
      };

      Map friendDBRefMap = {
        "friendid" : userCurrentInfo!.user_id!,
        "friendtype" : "acceptor",
        "status" : "unconfirmed"
      };

      userDBRef.set(userDBRefMap).then((onValue) {
        friendDBRef.set(friendDBRefMap);
        displayToastMessage("Your friend request was sent successfully.", context);
        saveGeneralNotification("send you a friend request", friendid, "friendsrequest", userCurrentInfo!.user_id!);

        stateSetter();

      }).catchError((onError) {
        displayToastMessage("An error occurred. Please try again later.", context);
      });
    }
  });
}

acceptFriend(String friendid, BuildContext context, Function stateSetter) async {

  DatabaseReference userDBRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(userCurrentInfo!.user_id!).child(friendid);
  DatabaseReference friendDBRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(friendid).child(userCurrentInfo!.user_id!);

  Map<String, dynamic> friendmap = {
    "status" : "confirmed",
  };

  userDBRef.update(friendmap).then((onValue) {
    friendDBRef.update(friendmap);
    saveGeneralNotification("accepted your friend request", friendid, "friendsrequest", userCurrentInfo!.user_id!);
    displayToastMessage("This user has been added to your friends list.", context);

    stateSetter();

  }).catchError((onError) {
    displayToastMessage("An error occurred. Please try again later.", context);
  });
}

declineFriend(String friendid, BuildContext context, Function stateSetter) async {

  DatabaseReference userDBRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(userCurrentInfo!.user_id!).child(friendid);
  DatabaseReference friendDBRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(friendid).child(userCurrentInfo!.user_id!);

  userDBRef.remove().then((onValue) {
    friendDBRef.remove();
    displayToastMessage("Friend request has been declined.", context);

    stateSetter();

  }).catchError((onError) {
    displayToastMessage("An error occurred. Please try again later.", context);
  });

}

saveGeneralNotification(String notifMessage, String notifRecip, String notifType, String actionid) async {

  var curTime = DateTime.now().millisecondsSinceEpoch;
  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Notifications").push();
  String notifKey = dbRef.key;
  String notificationstatus = "";

  Map notifMap = {
    "notification_id" : notifKey,
    "notification_time" : curTime,
    "notification_creator" : userCurrentInfo!.user_id!,
    "notification_message" : notifMessage,
    "notification_status" : notificationstatus,
    "notification_type" : notifType,
    "notification_recipient" : notifRecip,
    "notification_actionid" : actionid
  };

  dbRef.set(notifMap).then((onValue){
    sendUserNotification(notifRecip, notifRecip, "General");
  }).catchError((onError) {

  });

}

sendUserNotification(String notifMessage, String notifRecip, String type){
  DatabaseReference dbRefUser = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(notifRecip).child("user_tokenid");
  dbRefUser.once().then((DataSnapshot snapshot){
    if(snapshot.exists){
      if(type == "General") {
        sendFSM(snapshot.value.toString(),
            userCurrentInfo!.user_firstname! + " " +
                userCurrentInfo!.user_lastname! + " " + notifMessage);
      }

      if(type == "Chat"){
        FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(notifRecip)
        .once().then((DataSnapshot userSnapshot) async {
          Users user = await AssistantMethods.getCurrentOnlineUser(userSnapshot.value["user_id"]);
          sendChatFSM(snapshot.value.toString(), notifMessage, user);
        });
      }

      if(type == "Call"){
        FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(notifRecip)
            .once().then((DataSnapshot userSnapshot) async {
          Users user = await AssistantMethods.getCurrentOnlineUser(userSnapshot.value["user_id"]);
          sendCallFSM(snapshot.value.toString(), notifMessage, user);
        });
      }
    }
  });
}

Future<void> sendFcmNotif(String userToken, String notifMsg) async {

  String serverToken = "AAAA_MU4yec:APA91bGOaDzvHE-EQZiMMxQ7mahv1y0oG9ONCqIJCap_ktSBW1xg10PIt_KI4Q6DW6Zf6xL-yCEMNGpcpkAHtl-bSwHjM-TX_Ay0twQtpbB6qIl8L3gfhtXuriEPHKynOd8l7AmAzka9";
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': serverToken,
      },
      body: constructFCMPayload(userToken, notifMsg),
    );
    print('FCM request for device sent!');
    print("sending notif");
  } catch (e) {
    print(e);
  }

}

dynamic constructFCMPayload(String userToken, String notifMsg) {
  Map<String, dynamic> res = {
    'token': userToken,
    'notification': {
      "body" : notifMsg,
      "title": "Kuungaa Social Network"
    },
    "priority": "high",
    'data': {
      "click_action": "FLUTTER_NOTIFIATION_CLICK",
      "id": "1",
      "status": "done",
    },
    'to': userToken,

  };

  print(res.toString());
  return jsonEncode(res);
}

sendCallFSM(String userToken, String notifMsg, Users user) async {
  const postUrl = 'https://fcm.googleapis.com/fcm/send';
  const server_key = "AAAA_MU4yec:APA91bGOaDzvHE-EQZiMMxQ7mahv1y0oG9ONCqIJCap_ktSBW1xg10PIt_KI4Q6DW6Zf6xL-yCEMNGpcpkAHtl-bSwHjM-TX_Ay0twQtpbB6qIl8L3gfhtXuriEPHKynOd8l7AmAzka9";
  Map<String, dynamic> data;
  data = {
    "registration_ids": [
      "${userToken}"
    ],
    "collapse_key": "type_a",
    "notification": {

    },
    'data': {
      "title": "Incoming Call",
      "body": user.user_firstname! + " " + user.user_lastname!,
      "channelKey": 'call',
      "icon": user.user_profileimage!,
    },
  };

  final response =
  await http.post(Uri.parse(postUrl), body: json.encode(data), headers: {
    'content-type': 'application/json',
    'Authorization': 'key='+server_key
  });

  print(response.body);
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

sendChatFSM(String userToken, String notifMsg, Users user) async {
  const postUrl = 'https://fcm.googleapis.com/fcm/send';
  const server_key = "AAAA_MU4yec:APA91bGOaDzvHE-EQZiMMxQ7mahv1y0oG9ONCqIJCap_ktSBW1xg10PIt_KI4Q6DW6Zf6xL-yCEMNGpcpkAHtl-bSwHjM-TX_Ay0twQtpbB6qIl8L3gfhtXuriEPHKynOd8l7AmAzka9";
  Map<String, dynamic> data;
  data = {
    "registration_ids": [
      "${userToken}"
    ],
    "collapse_key": "type_a",
    "notification": {

    },
    'data': {
      "title": user.user_firstname! + " " + user.user_lastname!,
      "body": notifMsg,
      "channelKey": 'chat',
      "icon": user.user_profileimage!,
    },
  };

  final response =
  await http.post(Uri.parse(postUrl), body: json.encode(data), headers: {
    'content-type': 'application/json',
    'Authorization': 'key='+server_key
  });

  print(response.body);
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

sendFSM(String userToken, String notifMsg) async {
  const postUrl = 'https://fcm.googleapis.com/fcm/send';
  const server_key = "AAAA_MU4yec:APA91bGOaDzvHE-EQZiMMxQ7mahv1y0oG9ONCqIJCap_ktSBW1xg10PIt_KI4Q6DW6Zf6xL-yCEMNGpcpkAHtl-bSwHjM-TX_Ay0twQtpbB6qIl8L3gfhtXuriEPHKynOd8l7AmAzka9";
  Map<String, dynamic> data;
  data = {
    "registration_ids": [
      "${userToken}"
    ],
    "collapse_key": "type_a",
    "notification": {

    },
    'data': {
      "title": "Kuungaa Social Network",
      "body": notifMsg,
    },
  };

  final response =
  await http.post(Uri.parse(postUrl), body: json.encode(data), headers: {
    'content-type': 'application/json',
    'Authorization': 'key='+server_key
  });

  print(response.body);
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

getFieldValue(String postid, String field) {
  return AssistantMethods.getFieldname("Groups", postid, field);
}

getPageFieldValue(String postid, String field) {
  return AssistantMethods.getFieldname("Pages", postid, field);
}

Future<String> getGroupUserPostData(String uid, String field) async {
  return AssistantMethods.getUserFieldname(uid, field);
}

Future<File> watermarkVideo(String waterMark, File video) async {

  final byteDataWatermark = await rootBundle.load('images/$waterMark');

  Uint8List bytes = video.readAsBytesSync();
  ByteData byteDataVideo = ByteData.view(bytes.buffer);

  String basename = path.basename(video.path);

  String outputpath = (await getTemporaryDirectory()).path;
  String outputname = DateTime.now().toString() + basename;

  File? videoW;

  final fileWaterMark = File('${(await getTemporaryDirectory()).path}/$waterMark');
  await fileWaterMark.writeAsBytes(byteDataWatermark.buffer.asUint8List(byteDataWatermark.offsetInBytes, byteDataWatermark.lengthInBytes));

  final fileVideo = File('${(await getTemporaryDirectory()).path}/$basename');
  await fileVideo.writeAsBytes(byteDataVideo.buffer.asUint8List(byteDataVideo.offsetInBytes, byteDataVideo.lengthInBytes));

  /*await FFmpegKit.executeAsync('-i ${fileVideo.path} -i ${fileWaterMark.path} -filter_complex overlay=W-w-5:H-h-5 -codec:a copy -preset ultrafast -async 1 $outputpath/$outputname').then((result) async {
    final output = await result.getAllStatistics();
    print("watermark video :: " + output.toString());
    videoW = File('$outputpath/$outputname');
  });*/

  return videoW!;

}

Future<File> getImageFileFromAssets(String path) async {

  final byteData = await rootBundle.load('images/$path');
  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;

}

Future<File> watermarkPicture(File picture, String fileName) async {

  File watermark = await getImageFileFromAssets('kuungaalogo.png');
  ui.Image originalImage = ui.decodeImage(picture.readAsBytesSync())!;
  ui.Image watermarkImage = ui.decodeImage((watermark.readAsBytesSync()))!;

  ui.Image image = ui.Image(originalImage.width, originalImage.height);
  ui.drawImage(image, watermarkImage);

  // Easy customisation for the position of the watermark in the next two lines
  final int positionX = (originalImage.width * 0.85 - watermarkImage.width / 2).toInt();
  final int positionY = (originalImage.height - watermarkImage.height * 1.75).toInt();

  ui.copyInto(
    originalImage,
    image,
    dstX: positionX,
    dstY: positionY,
  );

  final File watermarkedFile = File('${(await getTemporaryDirectory()).path}/$fileName');

  await watermarkedFile.writeAsBytes(ui.encodeJpg(originalImage));

  return watermarkedFile;
}

String convertToDate(int timestamp){

  var d = DateFormat.yMd().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  return d.toString();
}

String convertToFullDate(int timestamp){
  var d = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var m = DateFormat.M().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var y = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(timestamp));

  var day = d.length == 1? '0' + d:d;
  var month = m.length == 1? '0' + m:m;

  return day + '/' + month + '/' + y;
}

String convertToFullMonth(int timestamp){
  return DateFormat.yMMMMd().format(DateTime.fromMillisecondsSinceEpoch(timestamp));

}

String convertToWhenNotif(int timestamp) {
  var t = DateFormat('EEEE').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var d = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var e = DateFormat.E().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var m = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var y = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var cy = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cd = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cm = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  if(y == cy){
    if(cm == m){
      if(cd == d){
        return "Today";
      }
      if((int.parse(cd) - int.parse(d)) == 1){
        return "Yesterday";
      }else if((int.parse(cd) - int.parse(d)) < 3){
        return '${(int.parse(cd) - int.parse(d)).toString()} days ago';
      }else if(DateTime.now().weekOfYear == DateTime.fromMicrosecondsSinceEpoch(timestamp).weekOfYear){
        return "This week";
      }else{
        return "This month";
      }//return e + " " + d;
    }
    return "This year";
  }
  return "Earlier";
}

String convertToLastSeen(int timestamp){
  var t = DateFormat('EEEE').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var d = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var m = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var y = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var cy = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cd = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cm = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  if(y == cy){
    if(cm == m){
      if(cd == d){
        return "Today at " + convertToPMAM(timestamp);
      }
      if((int.parse(cd) - int.parse(d)) == 1){
        return "Yesterday at " + convertToPMAM(timestamp);
      }
      return convertToFullDate(timestamp) + " at " + convertToPMAM(timestamp);
    }
    return convertToFullDate(timestamp)  + " at " + convertToPMAM(timestamp);
  }
  return convertToFullDate(timestamp)  + " at " + convertToPMAM(timestamp);
}

String convertToChattime(int timestamp){
  var t = DateFormat('EEEE').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var d = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var m = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var y = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var cy = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cd = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cm = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  if(y == cy){
    if(cm == m){
      if(cd == d){
        return convertToPMAM(timestamp);
      }
      if((int.parse(cd) - int.parse(d)) == 1){
        return "Yesterday";
      }
      return convertToFullDate(timestamp);
    }
    return convertToFullDate(timestamp);
  }
  return convertToFullDate(timestamp);
}

String convertToWhen(int timestamp) {
  var t = DateFormat('EEEE').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var d = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var e = DateFormat.E().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var m = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var y = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var cy = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cd = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cm = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  if(y == cy){
    if(cm == m){
      if(cd == d){
        return "Today";
      }
      if((int.parse(cd) - int.parse(d)) == 1){
        return "Yesterday";
      }
      return convertToFullMonth(timestamp);
      //return e + " " + d;
    }
    return convertToFullMonth(timestamp);
  }
  return convertToFullMonth(timestamp);
}

String checkIsWhen(int timestamp) {
  var t = DateFormat('EEEE').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var d = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var e = DateFormat.E().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var m = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var y = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var cy = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cd = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cm = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  if(y == cy){
    if(cm == m){
      if(cd == d){
        return "Today";
      }
      if((int.parse(cd) - int.parse(d)) == 1){
        return "Yesterday";
      }
      return e + " " + d;
    }
    return convertToFullDate(timestamp);
  }
  return convertToFullDate(timestamp);
}

String convertToDay(int timestamp){

  var t = DateFormat('EEEE').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var d = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var m = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var y = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  var cy = DateFormat('y').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cd = DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  var cm = DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  if(y == cy){
    if(cm == m){
      if(cd == d){
        return "Today at " + convertToPMAM(timestamp);
      }
      return t.toString() + " " + d + " at " + convertToPMAM(timestamp);
    }
    return t.toString() + " " + m + ", " + d + " at " + convertToPMAM(timestamp);
  }
  return t.toString() + " " + d + ", " + m + " " + y + "\n at " + convertToPMAM(timestamp);
}

String convertToPMAM(int timestamp) {
  var date = DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  return date.toString();
}

String convertToRealDate(int timestamp) {
  var date = DateFormat.yMMMMd('en_US').add_jm().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  return date.toString();
}

String convertToHour24(int timestamp) {
  var date = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  return date.toString();
}

startMessegeUser(BuildContext context, String uid){
  String commonid = "";
  String userid = userCurrentInfo!.user_id!;

  if(uid.compareTo(userid) == -1 ){
    commonid = uid + userid;
  }else{
    commonid = userid + uid;
  }

  var ref = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(commonid);

    ref.once().then((DataSnapshot snapshot) async {
    if(snapshot.exists){
      selectChat(context, commonid);
    }else{
      var chattime = DateTime.now().millisecondsSinceEpoch;;
      Map membersMap = {};

      membersMap[userCurrentInfo!.user_id!] = {
        "member_id" : userCurrentInfo!.user_id!
      };
      membersMap[uid] = {
        "member_id" : uid
      };

      Map chatMap = {
        "chat_id" : commonid,
        "chat_creatorid" : userid,
        "chat_partnerid" : uid,
        "members" : membersMap,
        "chat_createdAt" : chattime
      };

      ref.set(chatMap).then((onValue) async {

        DatabaseReference msgRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats").child(commonid).child("messages").push();

        String msgkey = msgRef.key;
        var time = DateTime.now().millisecondsSinceEpoch;
        String status = "0";

        Map msgMap = {
          "message_id" : msgkey,
          "message" : "${userCurrentInfo!.user_firstname! + " " + userCurrentInfo!.user_lastname!} created this chat",
          "time_created" : time,
          "message_status" : status,
          "message_media" : "",
          "sender_id" : userCurrentInfo!.user_id!
        };

        msgRef.set(msgMap).then((onValue) {
          selectChat(context, commonid);
          //displayToastMessage("Your post was uploaded successfully", context);
        }).catchError((onError) {
          Navigator.pop(context);
          displayToastMessage("An error occurred. Please try again later", context);
        });
      }).catchError((onError) {
        Navigator.pop(context);
        displayToastMessage("An error occurred. Please try again later", context);
      });
    }
  });
}

Future<void> selectChat(BuildContext context, String commonid) async {
  print("chat ::" + commonid);
  Chat chat = await AssistantMethods.getSingleChat(commonid);
  print("chat ::" + chat.chat_id!);
  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ChatScreen(chat: chat,)));

}

Future<Group> getGroupFromId(String groupid) async {

  Group group = Group();

  DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Groups").child(groupid);
  await dbReference.once().then((DataSnapshot dataSnapshot){

    if (dataSnapshot.exists)
    {
      var values = dataSnapshot.value;
      group.group_id = values["group_id"];
      group.group_name = values["group_name"];
      group.group_icon = values["group_icon"];
      group.group_privacy = values["group_privacy"];
      group.group_creator = values["group_creator"];
      group.group_createddate = values["group_createddate"];

    }
  });

  return group;
}

Future<Kpage> getPageFromId(String pageid) async {

  Kpage kpage = Kpage();

  DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Pages").child(pageid);
  await dbReference.once().then((DataSnapshot dataSnapshot) async {

    if (dataSnapshot.exists)
    {
      var values = dataSnapshot.value;
      kpage.page_id = values["page_id"];
      kpage.page_name = values["page_name"];
      kpage.page_icon = values["page_icon"];
      kpage.page_description = values["page_description"];
      kpage.page_creator = values["page_creator"];
      kpage.page_createddate = values["page_createddate"];
      kpage.page_category = values["page_category"];

      Users users = await AssistantMethods.getCurrentOnlineUser(kpage.page_creator!);
      kpage.creator = users;
    }
  });

  return kpage;

}

Future<List> getUserFriends(String userid) async {

  List<Users> userFriendsList = [];

  final Query userFriendsRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(userid)
      .orderByChild("status").equalTo("confirmed");
  await userFriendsRef.once().then((DataSnapshot dataSnapshot) async {
    if(dataSnapshot.exists){
      userFriendsList.clear();
      var keys = dataSnapshot.value.keys;
      var values = dataSnapshot.value;

      for(var key in keys){
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
          userFriendsList.add(users);
        });
      }
    }
  });

  return userFriendsList.reversed.toList();

}

Future<List<Chat>> getUserCreatedChats(String userid) async {

  List<Chat> userCreatedChatsList = [];
  Query dbQuery = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats");
  await dbQuery.orderByChild("chat_creatorid").equalTo(userid).once().then((DataSnapshot snapshot){
    if(snapshot.exists){
      var keys = snapshot.value.keys;
      var values = snapshot.value;

      for(var key in keys){
        Chat chat = Chat();
        chat.chat_id = values[key]["chat_id"];
        chat.chat_createddate = values[key]["chat_createddate"];
        chat.chat_creatorid = values[key]["chat_creatorid"];
        chat.chat_partnerid = values[key]["chat_opponentid"];
        userCreatedChatsList.add(chat);
      }
    }
  });

  return userCreatedChatsList;

}

Future<List<Chat>> getUserPartnerChats(String userid) async{
  List<Chat> userPartnerChatsList = [];
  Query dbQuery = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Chats");
  await dbQuery.orderByChild("chat_partnerid").equalTo(userid).once().then((DataSnapshot snapshot){
    if(snapshot.exists){
      var keys = snapshot.value.keys;
      var values = snapshot.value;

      for(var key in keys){
        Chat chat = Chat();
        chat.chat_id = values[key]["chat_id"];
        chat.chat_createddate = values[key]["chat_createddate"];
        chat.chat_creatorid = values[key]["chat_creatorid"];
        chat.chat_partnerid = values[key]["chat_opponentid"];
        userPartnerChatsList.add(chat);
      }
    }
  });
  return userPartnerChatsList;
}

final reactions = [
  Reaction<String>(
    value: 'Like',
    title: buildTitle('Like'),
    previewIcon: buildReactionsPreviewIcon('images/reactions_like.png'),
    icon: buildReactionsIcon(
      'images/reactions_like.png',
      Text(
        'Like',
        style: TextStyle(
          color: Color(0XFF3b5998),
        ),
      ),
    ),
  ),
  Reaction<String>(
    value: 'Haha',
    title: buildTitle('Haha'),
    previewIcon: buildReactionsPreviewIcon('images/reactions_haha.png'),
    icon: buildReactionsIcon(
      'images/reactions_haha.png',
      Text(
        'Haha',
        style: TextStyle(
          color: Color(0XFFed5168),
        ),
      ),
    ),
  ),
  Reaction<String>(
    value: 'Angry',
    title: buildTitle('Angry'),
    previewIcon: buildReactionsPreviewIcon('images/reactions_angry.png'),
    icon: buildReactionsIcon(
      'images/reactions_angry.png',
      Text(
        'Angry',
        style: TextStyle(
          color: Color(0XFFffda6b),
        ),
      ),
    ),
  ),
  Reaction<String>(
    value: 'Love',
    title: buildTitle('Love'),
    previewIcon: buildReactionsPreviewIcon('images/reactions_love.png'),
    icon: buildReactionsIcon(
      'images/reactions_love.png',
      Text(
        'Love',
        style: TextStyle(
          color: Color(0XFFffda6b),
        ),
      ),
    ),
  ),
  Reaction<String>(
    value: 'Sad',
    title: buildTitle('Sad'),
    previewIcon: buildReactionsPreviewIcon('images/reactions_sad.png'),
    icon: buildReactionsIcon(
      'images/reactions_sad.png',
      Text(
        'Sad',
        style: TextStyle(
          color: Color(0XFFffda6b),
        ),
      ),
    ),
  ),
  Reaction<String>(
    value: 'Wow',
    title: buildTitle('Wow'),
    previewIcon: buildReactionsPreviewIcon('images/reactions_wow.png'),
    icon: buildReactionsIcon(
      'images/reactions_wow.png',
      Text(
        'Wow',
        style: TextStyle(
          color: Color(0XFFf05766),
        ),
      ),
    ),
  ),
];

Container buildTitle(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Padding buildReactionsPreviewIcon(String path) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 5),
    child: Image.asset(path, height: 40),
  );
}

Container buildReactionsIcon(String path, Text text) {
  return Container(
    color: Colors.transparent,
    child: Row(
      children: <Widget>[
        Image.asset(path, height: 20),
        const SizedBox(width: 5),
        text,
      ],
    ),
  );
}

Container reactionIcon(String path) {
  return Container(
    color: Colors.transparent,
    child: Row(
      children: <Widget>[
        Image.asset(path, height: 20),
      ],
    ),
  );
}

String convertToTimeAgo(int time){

  var posttime = time > 10?time:time*1000;

  var date = DateTime.fromMillisecondsSinceEpoch(posttime);
  Duration def = DateTime.now().difference(date);

  String msgtime = "";

  int diff = def.inSeconds.toInt();

  // Time difference in seconds
  var sec	 = diff;

  // Convert time difference in minutes
  var min	 = (diff / 60 ).round();
  //console.log(min);

  // Convert time difference in hours
  var hrs	 = (diff / 3600).round();

  // Convert time difference in days
  var days  = (diff / 86400).round();

  // Convert time difference in weeks
  var weeks  = (diff / 604800).round();

  // Convert time difference in months
  var mnths  = (diff / 2600640).round();

  // Convert time difference in years
  var yrs	 = (diff / 31207680).round();

  // Check for seconds
  if(sec <= 60) {
    msgtime = "now";
  }

  // Check for minutes
  else if(min <= 60) {
    if(min==1) {
      msgtime = "1 m";
    }
    else {
      msgtime =  min.toString() + " m";
      //msgtime = new Date(time).toLocaleTimeString();
    }
  }

  // Check for hours
  else if(hrs <= 24) {
    if(hrs == 1) {
      msgtime = "1 h";
    }
    else {
      msgtime = hrs.toString() + " h";
      //msgtime = new Date(time).toLocaleTimeString() + "last seen, Today";
    }
  }

  // Check for days
  else if(days <= 7) {
    if(days == 1) {
      msgtime = "1 d";
      //msgtime = new Date(time).toLocaleTimeString() + "last seen, Yesterday";
    }
    else {
      msgtime = days.toString() + " d";
      //msgtime = new Date(time).toLocaleTimeString() + "last seen, " + days + " days ago";
    }
  }

  // Check for weeks
  else if(weeks <= 4.3) {
    if(weeks == 1) {
      msgtime = "1 w";
    }
    else {
      msgtime = weeks.toString() + " w";
    }
  }

  // Check for months
  else if(mnths <= 12) {
    if(mnths == 1) {
      msgtime = "1 month";
    }
    else {
      msgtime = mnths.toString() + " months";
    }
  }

  // Check for years
  else {
    if(yrs == 1) {
      msgtime = "1 y";
    }
    else {
      msgtime = yrs.toString() + " y";
    }
  }
  return msgtime;

}

void loadSingletonPage(NavigatorState? navigatorState,
    {required String targetPage, required ReceivedAction receivedAction}) {
  // Avoid to open the notification details page over another details page already opened
  // Navigate into pages, avoiding to open the notification details page over another details page already opened
  /*navigatorState?.pushNamedAndRemoveUntil(targetPage,
          (route) {
        return (route.settings.name != targetPage) || route.isFirst;
      },
      arguments: receivedAction);*/

  navigatorState?.pushNamed(targetPage, arguments: receivedAction);
}

Future<File> convertUriToFile(String strURL) async{
  final http.Response responseData = await http.get(Uri.parse(strURL));
  Uint8List uint8list = responseData.bodyBytes;
  var buffer = uint8list.buffer;
  ByteData byteData = ByteData.view(buffer);
  var tempDir = await getTemporaryDirectory();
  File file = await File('${tempDir.path}/files').writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  return file;
}

String uProfile = "https://firebasestorage.googleapis.com/v0/b/kuungaa-42ba2.appspot.com/o/KUUNGAA%2Fimages%2Fprofile.jpg?alt=media&token=8426002b-381d-4dfb-98aa-b49570cd1303";