import 'package:kuungaa/Models/user.dart';

class Likes {
  String? like_id;
  String? liker_id;
  String? like_type;
  Users? liker;

  Likes({this.like_id, this.liker_id, this.like_type, this.liker});
}