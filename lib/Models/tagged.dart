class Tagged {
  String? userid;

  Tagged({this.userid});

  Tagged.fromJson(Map<String, dynamic> json){
    userid = json['userid'];
  }
}