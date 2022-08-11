import 'package:firebase_database/firebase_database.dart';

class Users {
  String? user_id;
  String? user_firstname;
  String? user_lastname;
  String? user_email;
  String? user_phone;
  String? user_gender;
  String? user_profileimage;
  String? user_status;
  String? user_nickname;
  String? user_bio;
  String? user_birthday;
  String? user_dateregistered;
  String? user_dateupdated;
  String? user_coverimage;
  String? user_statusinfo;
  int? friend_count;
  int? story_viewtime;
  bool isOnline = false;
  bool isTyping = false;

  Users({this.user_id, this.user_firstname, this.user_lastname, this.user_email, this.user_phone,
    this.user_gender, this.user_profileimage, this.user_status, this.user_nickname, this.user_bio,
    this.user_birthday, this.user_dateregistered, this.user_dateupdated, this.user_coverimage, this.user_statusinfo, this.friend_count, this.story_viewtime});

  Users.fromSnapshot(DataSnapshot snapshot)
  {
    user_id = snapshot.value["user_id"];
    user_firstname = snapshot.value["user_firstname"];
    user_lastname = snapshot.value["user_lastname"];
    user_email = snapshot.value["user_email"];
    user_phone = snapshot.value["user_mobilenumber"];
    user_gender = snapshot.value["user_gender"];
    user_profileimage = snapshot.value["user_profileimage"];
    user_status = snapshot.value["user_status"];
    user_nickname = snapshot.value["user_nickname"];
    user_bio = snapshot.value["user_bio"];
    user_birthday = snapshot.value["user_birthday"];
    //user_dateregistered = snapshot.value["time_created"];
    user_dateupdated = snapshot.value["time_updated"];
    user_coverimage = snapshot.value["user_coverimage"];
    user_statusinfo = snapshot.value["user_statusinfo"];
  }

}