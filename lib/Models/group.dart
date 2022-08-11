import 'package:firebase_database/firebase_database.dart';

class Group{
  String? group_id;
  String? group_name;
  String? group_icon;
  String? group_privacy;
  String? group_creator;
  String? group_createddate;

  Group({this.group_id, this.group_name, this.group_icon, this.group_privacy, this.group_creator, this.group_createddate});

  Group.fromSnapshot(DataSnapshot snapshot){
    group_id = snapshot.value["group_id"];
    group_name = snapshot.value["group_name"];
    group_icon = snapshot.value["group_icon"];
    group_privacy = snapshot.value["group_privacy"];
    group_creator = snapshot.value["group_creator"];
    group_createddate = snapshot.value["group_createddate"];
  }
}