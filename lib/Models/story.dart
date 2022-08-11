import 'package:kuungaa/Models/user.dart';

class Story{
  String? story_id;
  String? story_description;
  int? story_time;
  String? story_media;
  String? story_poster;
  String? story_type;
  int? story_duration;
  Users? storyUser;

  Story({this.story_id, this.story_description, this.story_time, this.story_media, this.story_poster, this.story_type, this.story_duration, this.storyUser});

}