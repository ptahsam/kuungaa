import 'package:firebase_database/firebase_database.dart';
import 'package:kuungaa/Models/user.dart';

class Comments {
  String? comment_id;
  String? comment_text;
  int? comment_time;
  String? commenter_id;
  String? post_id;
  String? tag_id;
  Users? comment_user;
  Users? tagged_user;
  Users? replied_user;

  Comments({this.comment_id, this.comment_text, this.comment_time, this.commenter_id, this.post_id, this.tag_id, this.comment_user, this.tagged_user, this.replied_user});

  Comments.fromSnapshot(DataSnapshot snapshot)
  {
    comment_id = snapshot.value["comment_id"];
    comment_text = snapshot.value["comment_text"];
    comment_time = snapshot.value["comment_time"];
    commenter_id = snapshot.value["commenter_id"];
    post_id = snapshot.value["post_id"];
    tag_id = snapshot.value["tag_id"];
  }

  Comments.fromJson(Map<String, dynamic> json)
  {
    comment_id = json['comment_id'];
    comment_text = json['comment_text'];
    comment_time = json['comment_time'];
    commenter_id = json['commenter_id'];
    post_id = json['post_id'];
    tag_id = json["tag_id"];
  }
}