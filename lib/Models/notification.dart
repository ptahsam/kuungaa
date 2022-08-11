import 'package:firebase_database/firebase_database.dart';
import 'package:kuungaa/Models/user.dart';

class Notifications{
  String? notification_creator;
  String? notification_id;
  String? notification_actionid;
  String? notification_message;
  String? notification_recipient;
  String? notification_status;
  int? notification_time;
  String? notification_type;
  int? notification_count;
  Users? userCreator;

  Notifications({this.notification_creator, this.notification_id, this.notification_actionid, this.notification_message, this.notification_recipient, this.notification_status, this.notification_time, this.notification_type, this.notification_count, this.userCreator});

  Notifications.fromSnapshot(DataSnapshot snapshot){
    notification_creator = snapshot.value["notification_creator"];
    notification_id = snapshot.value["notification_id"];
    notification_actionid = snapshot.value["notification_actionid"];
    notification_message = snapshot.value["notification_message"];
    notification_recipient = snapshot.value["notification_recipient"];
    notification_status = snapshot.value["notification_status"];
    notification_time = snapshot.value["notification_time"];
    notification_type = snapshot.value["notification_type"];
  }
}