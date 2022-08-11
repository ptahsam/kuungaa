import 'package:kuungaa/Models/user.dart';

class Kpage{
  String? page_id;
  String? page_name;
  String? page_icon;
  String? page_description;
  String? page_creator;
  int? page_createddate;
  String? page_category;
  int? page_postscount;
  Users? creator;

  Kpage({this.page_id, this.page_name, this.page_icon, this.page_description, this.page_creator, this.page_createddate, this.page_category, this.page_postscount, this.creator});

}