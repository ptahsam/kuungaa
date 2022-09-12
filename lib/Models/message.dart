import 'package:firebase_database/firebase_database.dart';
import 'package:kuungaa/Models/media.dart';

class Message{
  String? message_id;
  String? message;
  String? message_status;
  String? sender_id;
  String? group_date;
  String? origin;
  int? time_created;
  List<Media>? messageMedia;
  int? message_count;

  Message({this.message_id, this.message, this.message_status, this.sender_id, this.group_date, this.origin, this.time_created, this.messageMedia, this.message_count});

  Message.fromSnapshot(DataSnapshot snapshot){
    message_id = snapshot.value["message_id"];
    message = snapshot.value["message"];
    message_status = snapshot.value["message_status"];
    sender_id = snapshot.value["sender_id"];
    time_created = snapshot.value["time_created"];
  }
}