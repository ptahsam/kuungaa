import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/message.dart';
import 'package:kuungaa/Models/user.dart';

class Chat{
  String? chat_id;
  String? chat_createddate;
  String? chat_creatorid;
  String? chat_partnerid;
  String? chat_opponentid;
  Users? opponentUser;
  Message? message;
  int? chatCount;
  bool chatIsOpen;

  Chat({this.chat_id, this.chat_createddate, this.chat_creatorid, this.chat_partnerid, this.chat_opponentid, this.opponentUser, this.message, this.chatCount, this.chatIsOpen = false});
}