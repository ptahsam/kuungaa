import 'package:firebase_database/firebase_database.dart';

class Media {
  String? type;
  String? url;

  Media({this.type, this.url});

  Media.fromSnapshot(DataSnapshot snapshot){
    type = snapshot.value["type"];
    url = snapshot.value["url"];
  }

  Media.fromJson(Map<String, dynamic> json){
    type = json['type'];
    url = json['url'];
  }

}