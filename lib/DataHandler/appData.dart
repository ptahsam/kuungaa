import 'package:flutter/cupertino.dart';
import 'package:kuungaa/Models/address.dart';
import 'package:kuungaa/Models/chat.dart';
import 'package:kuungaa/Models/like.dart';
import 'package:kuungaa/Models/message.dart';
import 'package:kuungaa/Models/notification.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/SharedPreferences.dart';

class AppData extends ChangeNotifier
{
  DarkThemePreference darkThemePreference = DarkThemePreference();

  Chat? currentChat;

  bool _darkTheme = true;

  bool isGettingHomeFeed = false;

  bool get darkTheme => _darkTheme;

  Address? userCurrentLocation;

  Notifications? userNotifications;

  Message? message;

  Message? messageCount;

  int? postCommentCount;

  List<Message>? chatMessages;

  String? userOnlineStatus;

  bool isTyping = false;

  List<Chat>? userChats;

  List<Posts>? visitedPlaces;

  List<Users>? chatUsersList;

  List<Users>? favoriteContacts;

  List<Posts>? feedPosts;

  List<Likes>? reactionsList;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }

  void updateCurrentChat(Chat cChat) {
    currentChat = cChat;
    notifyListeners();
  }

  void updateGettingHomeFeed(bool value) {
    isGettingHomeFeed = value;
    notifyListeners();
  }

  void updateUserCurrentLocationAddress(Address userCurrentLoc)
  {
    userCurrentLocation = userCurrentLoc;
    notifyListeners();
  }

  void updateNotification(Notifications newCount){
    userNotifications = newCount;
    notifyListeners();
  }

  void updateMessageCount(Message newCount){
    messageCount = newCount;
    notifyListeners();
  }

  void updateMessage(Message lastMessage)
  {
    message = lastMessage;
    notifyListeners();
  }

  void updateChatMessages(List<Message> chatMessage)
  {
    chatMessages = chatMessage;
    notifyListeners();
  }

  void updateUserOnlineStatus(String status)
  {
    userOnlineStatus = status;
    notifyListeners();
  }

  void updateUserTypingStatus(bool status)
  {
    isTyping = status;
    notifyListeners();
  }

  void updateUserChats(List<Chat> chatData)
  {
    userChats = chatData;
    notifyListeners();
  }

  void updateVisitedPlaces(List<Posts> postList)
  {
    visitedPlaces = postList;
    notifyListeners();
  }

  void updateChatUsersList(List<Users> userList)
  {
    chatUsersList = userList;
    notifyListeners();
  }

  void updateFavoriteContactsList(List<Users> userContactList)
  {
    favoriteContacts = userContactList;
    notifyListeners();
  }

  void updateFeedPosts(List<Posts> feedPost)
  {
    feedPosts = feedPost;
    notifyListeners();
  }

  void updateLikes(List<Likes> likes)
  {
    reactionsList = likes;
    notifyListeners();
  }

  void updatePostCommentCount(int count)
  {
    postCommentCount = count;
    notifyListeners();
  }

}