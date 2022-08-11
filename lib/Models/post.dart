
import 'package:firebase_database/firebase_database.dart';
import 'package:kuungaa/Models/group.dart';
import 'package:kuungaa/Models/page.dart';
import 'package:kuungaa/Models/user.dart';

class Posts{
  String? pid;
  String? post_id;
  String? post_description;
  int? post_time;
  String? poster_id;
  String? post_privacy;
  String? post_countryname;
  String? post_countrycode;
  String? post_finelocation;
  String? post_city;
  String? post_category;
  String? post_travelcategory;
  String? video_url;
  double? latitude;
  double? longitude;
  String? locationaddress;
  String? post_expression;
  List<Users>? taggedUsers;
  Users? postUser;
  Kpage? kpage;
  Group? group;

  Posts({this.pid, this.post_id, this.post_description, this.post_time, this.poster_id, this.post_privacy, this.post_countryname, this.post_countrycode, this.post_finelocation, this.post_city, this.post_category, this.post_travelcategory, this.video_url, this.latitude, this.longitude, this.locationaddress, this.post_expression, this.taggedUsers, this.postUser, this.kpage, this.group});

  Posts.fromSnapshot(DataSnapshot snapshot)
  {
    post_id = snapshot.key;
    pid = snapshot.value["post_id"];
    post_description = snapshot.value["post_description"];
    post_time = snapshot.value["post_time"];
    poster_id = snapshot.value["poster_id"];
    post_privacy = snapshot.value["post_privacy"];
    post_countryname = snapshot.value["post_countryname"];
    post_city = snapshot.value["post_city"];
    post_category = snapshot.value["post_category"];
    //post_media = snapshot.value["post_media"];

  }
}