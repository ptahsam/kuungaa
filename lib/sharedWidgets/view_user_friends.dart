import 'package:flutter/material.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/palette.dart';

import 'widgets.dart';
class ViewUserFriends extends StatefulWidget {
  final Users user;
  const ViewUserFriends({
    Key? key,
    required this.user
  }) : super(key: key);

  @override
  _ViewUserFriendsState createState() => _ViewUserFriendsState();
}

class _ViewUserFriendsState extends State<ViewUserFriends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white,),
          //iconSize: 36.0,
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.user.user_firstname! + " " + widget.user.user_lastname! + "friends",
          style: const TextStyle(
            color: Colors.white,
            //fontSize: 22.0,
            //fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            //iconSize: 36.0,
            color: Colors.white,
            onPressed: (){},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: UserFriendsContainer(userid: widget.user.user_id!),
          ),
        ],
      ),
    );
  }
}
