import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/comment.dart';
import 'package:kuungaa/Models/like.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snippet_coder_utils/hex_color.dart';

import 'widgets.dart';
class PostStats extends StatefulWidget {
  final Posts? post;

  const PostStats({
    Key? key,
    required this.post
  }) : super(key: key);

  @override
  State<PostStats> createState() => PostStatsState();
}

class PostStatsState extends State<PostStats> {
  bool isVisible = false;
  bool reactionVisibilty = false;
  TextEditingController commentTextEditingController = TextEditingController();
  late FocusNode myFocusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFocusNode = FocusNode();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
          child: Row(
            children: [
              ReactionsStatsContainer(post: widget.post!,),
              SizedBox(width: 4.0,),
              PostReactionsContainer(post: widget.post!,),
              PostCommentsContainer(post: widget.post!,),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Divider(),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserReactionContainer(post: widget.post!,),
              SizedBox(width: MediaQuery.of(context).size.width * 0.15),
              TextButton(
                onPressed: (){
                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: PostComments(postid: widget.post!.post_id!, posterid: widget.post!.poster_id!,)));
                  //toggleCommentHeight();
                },
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.commentOutline,
                      color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                    ),
                    SizedBox(width: 4.0,),
                    Text(
                      'Comment',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<List> getUserLike(String postid, String userid) async {
    List<Likes> userLikeList = [];
    final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts').child(postid).child("likes")
        .orderByChild('liker_id').equalTo(userid);
    await query.once().then((event){
      var keys = event.value.keys;
      var values = event.value;

      for (var key in keys)
      {
        Likes likes = Likes();
        likes.liker_id = values [key]["liker_id"];
        userLikeList.add(likes);
      }
    });
    return userLikeList;
  }

  Future<String> getUserReaction(String postid) async {
    String userReaction = "";
    final DatabaseReference likesReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postid).child("likes").child(userCurrentInfo!.user_id!);
    await likesReference.once().then((DataSnapshot snapshot){
      if(snapshot.exists){
        userReaction = snapshot.value["like_type"];
      }
    });
    return userReaction;
  }

  Future<List<Likes>> getStats(String postid) async{
    List<Likes> likesList = [];
    final DatabaseReference likesReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postid).child("likes");
    //int i = 0;
    await likesReference.once().then((DataSnapshot snapshotPosts){
      likesList.clear();
      var keys = snapshotPosts.value.keys;
      var values = snapshotPosts.value;


      for (var key in keys)
      {

        Likes likes = Likes();
        likes.liker_id = values [key]["liker_id"];
        likes.like_type = values [key]["like_type"];
        likesList.add(likes);
      }
    });
    return likesList;
  }

  void toggleCommentHeight() {
    setState(() {
      if(isVisible){
        commentTextEditingController.clear();
        myFocusNode.unfocus();
        isVisible = false;

      }else{
        isVisible = true;
        myFocusNode.requestFocus();
      }
    });
  }

  Future<List> getPostComments(String postid) async{
    List<Comments> commentsList = [];
    final DatabaseReference commentsReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(postid).child("comments");
    //int i = 0;
    await commentsReference.once().then((DataSnapshot snapshotPosts){
      if(snapshotPosts.exists){
        commentsList.clear();
        var keys = snapshotPosts.value.keys;
        var values = snapshotPosts.value;

        //print("Post likes " + keys.toString());

        for (var key in keys)
        {

          Comments comments = Comments();
          comments.comment_id = values [key]["comment_id"];
          comments.comment_text = values [key]["comment_text"];
          comments.comment_time = values [key]["comment_time"];
          comments.commenter_id = values [key]["commenter_id"];
          comments.post_id = values [key]["post_id"];
          commentsList.add(comments);
        }
      }
    });
    return commentsList;
  }

  void saveComment(postid) {
    if(commentTextEditingController.text.isNotEmpty){
      DatabaseReference commentRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts').child(postid).child("comments").push();
      String refKey = commentRef.key;

      var offsetRef = FirebaseDatabase.instance.reference().child(".info/serverTimeOffset");
      offsetRef.onValue.listen((event){
        int offset = event.snapshot.value;
        var commenttime = ((DateTime.now().millisecondsSinceEpoch) + offset);

        Map commentDataMap = {
          "comment_id" : refKey,
          "comment_text" : commentTextEditingController.text,
          "comment_time" : commenttime,
          "commenter_id" : userCurrentInfo!.user_id!,
          "post_id" : postid,
        };

        commentRef.set(commentDataMap).then((onValue) {
          displayToastMessage("You have commented on this post", context);
          commentTextEditingController.clear();
          setState(() {

          });
        }).catchError((onError) {
          displayToastMessage("An error occurred. Please try again later", context);
        });

      });
    }
  }

  void onShare(BuildContext context, String text, String subject) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(text,
        subject: subject,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }



}

class UserReactionContainer extends StatefulWidget {
  final Posts post;
  const UserReactionContainer({
    Key? key,
    required this.post
  }) : super(key: key);

  @override
  State<UserReactionContainer> createState() => _UserReactionContainerState();
}

class _UserReactionContainerState extends State<UserReactionContainer> {

  Likes likes = Likes();
  Query? itemRefLike;
  bool isLike = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefLike = database.reference().child("KUUNGAA").child("Posts").child(widget.post.post_id!).child("likes").orderByChild("liker_id").equalTo(userCurrentInfo!.user_id!);
    itemRefLike!.onChildAdded.listen(_onEntryAddedLike);
    itemRefLike!.onChildChanged.listen(_onEntryChangedLike);
    itemRefLike!.onChildRemoved.listen(_onEntryRemovedLike);
  }

  _onEntryAddedLike(Event event) async {
    if(mounted) {
      setState(() {
        likes.like_id = event.snapshot.key;
        likes.liker_id = event.snapshot.value["liker_id"];
        likes.like_type = event.snapshot.value["like_type"];
        isLike = true;
      });
    }
  }

  _onEntryChangedLike(Event event) async {
    if(mounted) {
      setState(() {
        likes.like_id = event.snapshot.key;
        likes.liker_id = event.snapshot.value["liker_id"];
        likes.like_type = event.snapshot.value["like_type"];
        isLike = true;
      });
    }
  }

  _onEntryRemovedLike(Event event) async {
    if(mounted) {
      setState(() {
        isLike = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Reaction defaultInitialReaction = Reaction<String>(
      value: 'Like',
      title: buildTitle('Like'),
      previewIcon: buildReactionsPreviewIcon('images/reactions_like.png'),
      icon: buildReactionsIcon(
        'images/reactions_like.png',
        Text(
          'Like',
          style: TextStyle(
            color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
          ),
        ),
      ),
    );
    if(isLike){

      if(likes.like_type == ""){
        defaultInitialReaction = Reaction<String>(
          value: 'Like',
          title: buildTitle('Like'),
          previewIcon: buildReactionsPreviewIcon('images/reactions_like.png'),
          icon: buildReactionsIcon(
            'images/reactions_like.png',
            Text(
              'Like',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        );
      }

      if(likes.like_type == "Like"){
        defaultInitialReaction = Reaction<String>(
          value: 'Like',
          title: buildTitle('Like'),
          previewIcon: buildReactionsPreviewIcon('images/reactions_like.png'),
          icon: buildReactionsIcon(
            'images/reactions_like.png',
            Text(
              'Like',
              style: TextStyle(
                color: Color(0XFF3b5998),
              ),
            ),
          ),
        );
      }

      if(likes.like_type == "Haha"){
        defaultInitialReaction = Reaction<String>(
          value: 'Haha',
          title: buildTitle('Haha'),
          previewIcon: buildReactionsPreviewIcon('images/reactions_haha.png'),
          icon: buildReactionsIcon(
            'images/reactions_haha.png',
            Text(
              'Haha',
              style: TextStyle(
                color: Color(0XFFffda6b),
              ),
            ),
          ),
        );
      }

      if(likes.like_type == "Angry"){
        defaultInitialReaction = Reaction<String>(
          value: 'Angry',
          title: buildTitle('Angry'),
          previewIcon: buildReactionsPreviewIcon('images/reactions_angry.png'),
          icon: buildReactionsIcon(
            'images/reactions_angry.png',
            Text(
              'Angry',
              style: TextStyle(
                color: Color(0XFFffda6b),
              ),
            ),
          ),
        );
      }

      if(likes.like_type == "Love"){
        defaultInitialReaction = Reaction<String>(
          value: 'Love',
          title: buildTitle('Love'),
          previewIcon: buildReactionsPreviewIcon('images/reactions_love.png'),
          icon: buildReactionsIcon(
            'images/reactions_love.png',
            Text(
              'Love',
              style: TextStyle(
                color: Color(0XFFed5168),
              ),
            ),
          ),
        );
      }

      if(likes.like_type == "Sad"){
        defaultInitialReaction = Reaction<String>(
          value: 'Sad',
          title: buildTitle('Sad'),
          previewIcon: buildReactionsPreviewIcon('images/reactions_sad.png'),
          icon: buildReactionsIcon(
            'images/reactions_sad.png',
            Text(
              'Sad',
              style: TextStyle(
                color: Color(0XFFffda6b),
              ),
            ),
          ),
        );
      }

      if(likes.like_type == "Wow"){
        defaultInitialReaction = Reaction<String>(
          value: 'Wow',
          title: buildTitle('Wow'),
          previewIcon: buildReactionsPreviewIcon('images/reactions_wow.png'),
          icon: buildReactionsIcon(
            'images/reactions_wow.png',
            Text(
              'Wow',
              style: TextStyle(
                color: Color(0XFFf05766),
              ),
            ),
          ),
        );
      }

      return Builder(
        builder: (ctx){
          return ReactionButton(
            onReactionChanged: (dynamic value){
              saveUserReaction(value);
            },
            reactions: reactions,
            initialReaction: defaultInitialReaction,
            boxPadding: EdgeInsets.symmetric(horizontal: 5.0),
            boxDuration: Duration(milliseconds: 1),
            boxColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
          );
        },
      );
    }else{
      return Builder(
        builder: (ctx){
          return ReactionButton(
            onReactionChanged: (dynamic value){
              saveUserReaction(value);
            },
            reactions: reactions,
            initialReaction: defaultInitialReaction,
            boxPadding: EdgeInsets.symmetric(horizontal: 5.0),
            boxDuration: Duration(milliseconds: 1),
            boxColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
          );
        },
      );
    }
  }

  void saveUserReaction(String? value) {
    final DatabaseReference userReactionRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(widget.post.post_id!).child("likes").child(userCurrentInfo!.user_id!);
    userReactionRef.once().then((DataSnapshot snapshot){
      if(snapshot.exists){
        if(snapshot.value["like_type"] == value){
          userReactionRef.remove();
        }else{
          Map<String, dynamic> likeDataMap = {
            "liker_id" : userCurrentInfo!.user_id!,
            "like_type" : value!
          };
          userReactionRef.update(likeDataMap);
        }
      }else{
        Map likeDataMap = {
          "liker_id" : userCurrentInfo!.user_id!,
          "like_type" : value!
        };
        userReactionRef.set(likeDataMap).then((onValue) {
          if(widget.post.poster_id != userCurrentInfo!.user_id!){
            saveGeneralNotification("likes your post", widget.post.poster_id!, "likes", widget.post.post_id!);
          }
          displayToastMessage("You reacted to this post", context);
        }).catchError((onError) {
          displayToastMessage("An error occurred. Please try again later", context);
        });
      }
    });
  }
}


class ReactionsStatsContainer extends StatefulWidget {
  final Posts post;
  const ReactionsStatsContainer({
    Key? key,
    required this.post
  }) : super(key: key);

  @override
  State<ReactionsStatsContainer> createState() => _ReactionsStatsContainerState();
}

class _ReactionsStatsContainerState extends State<ReactionsStatsContainer> {

  List<Likes> listLikes = [];
  DatabaseReference? itemRefLikes;

  int selectedIndex = 0;
  final List<String> reactionsMenu = ["All", "Like", "Haha", "Angry", "Love", "Sad", "Wow"];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefLikes = database.reference().child('KUUNGAA').child("Posts").child(widget.post.post_id!).child("likes");
    itemRefLikes!.onChildAdded.listen(_onEntryAddedLikes);
    itemRefLikes!.onChildChanged.listen(_onEntryChangedLikes);
    itemRefLikes!.onChildRemoved.listen(_onEntryRemovedLikes);
  }

  _onEntryAddedLikes(Event event) async {
    Likes likes = Likes();
    likes.like_id = event.snapshot.key;
    likes.liker_id = event.snapshot.value["liker_id"];
    likes.like_type = event.snapshot.value["like_type"];

    likes.liker = await AssistantMethods.getCurrentOnlineUser(likes.liker_id!);

    setState(() {
      listLikes.add(likes);
    });
  }

  _onEntryChangedLikes(Event event) async {
    var old = listLikes.singleWhere((entry) {
      return entry.like_id == event.snapshot.key;
    });
    Likes likes = Likes();
    likes.like_id = event.snapshot.key;
    likes.liker_id = event.snapshot.value["liker_id"];
    likes.like_type = event.snapshot.value["like_type"];
    likes.liker = await AssistantMethods.getCurrentOnlineUser(likes.liker_id!);

    setState(() {
      listLikes[listLikes.indexOf(old)] = likes;
    });
  }

  _onEntryRemovedLikes(Event event) async {
    var removed = listLikes.singleWhere((entry) {
      return entry.like_id == event.snapshot.key;
    });

    setState(() {
      listLikes.removeWhere((Likes likes) => likes.like_id == removed.like_id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(listLikes.isNotEmpty){
      bool isLike = false;
      bool isHaha = false;
      bool isAngry = false;
      bool isLove = false;
      bool isSad = false;
      bool isWow = false;
      List<Widget> reactionWidgets = [];

      for(var i = 0; i < listLikes.length; i ++){
        if(listLikes[i].like_type == "Like"){
          isLike = true;
        }
      }

      for(var i = 0; i < listLikes.length; i ++){
        if(listLikes[i].like_type == "Haha"){
          isHaha = true;
        }
      }

      for(var i = 0; i < listLikes.length; i ++){
        if(listLikes[i].like_type == "Angry"){
          isAngry = true;
        }
      }

      for(var i = 0; i < listLikes.length; i ++){
        if(listLikes[i].like_type == "Love"){
          isLove = true;
        }
      }

      for(var i = 0; i < listLikes.length; i ++){
        if(listLikes[i].like_type == "Sad"){
          isSad = true;
        }
      }

      for(var i = 0; i < listLikes.length; i ++){
        if(listLikes[i].like_type == "Wow"){
          isWow = true;
        }
      }

      if(isLike){
        reactionWidgets.add(reactionIcon(
          'images/reactions_like.png',
        ));
      }

      if(isHaha){
        reactionWidgets.add(reactionIcon(
          'images/reactions_haha.png',
        ));
      }

      if(isAngry){
        reactionWidgets.add(reactionIcon(
          'images/reactions_angry.png',
        ));
      }

      if(isLove){
        reactionWidgets.add(reactionIcon(
          'images/reactions_love.png',
        ));
      }

      if(isSad){
        reactionWidgets.add(reactionIcon(
          'images/reactions_sad.png',
        ));
      }

      if(isWow){
        reactionWidgets.add(reactionIcon(
          'images/reactions_wow.png',
        ));
      }

      return InkWell(
        onTap: (){
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                contentPadding: EdgeInsets.zero,
                contentTextStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
                content: FittedBox(
                  child: Container(
                    padding: EdgeInsets.zero,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.65,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: listLikes.isNotEmpty?ListView.builder(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            itemCount: listLikes.length,
                            itemBuilder: (ctx, int index){
                              Likes like = listLikes[index];
                              return InkWell(
                                onTap: (){
                                  Navigator.pop(context);
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: like.liker!.user_id!,)));
                                },
                                child: ListTile(
                                  leading: Container(
                                    margin: EdgeInsets.only(bottom: 10.0),
                                    height: 80,
                                    width: 80,
                                    child: Stack(
                                      children: [
                                        ProfileAvatar(imageUrl: like.liker!.user_profileimage!, radius: 75,),
                                        Positioned(
                                          bottom: 0,
                                          right: 5.0,
                                          child: like.like_type == "Like"?Image.asset('images/reactions_like.png'):
                                                 like.like_type == "Haha"?Image.asset('images/reactions_haha.png'):
                                                 like.like_type == "Angry"?Image.asset('images/reactions_angry.png'):
                                                 like.like_type == "Love"?Image.asset('images/reactions_love.png'):
                                                 like.like_type == "Sad"?Image.asset('images/reactions_sad.png'):
                                                 like.like_type == "Wow"?Image.asset('images/reactions_wow.png'):
                                                 SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    like.liker!.user_firstname! + " " + like.liker!.user_lastname!,
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w700
                                    ),
                                  ),
                                ),
                              );
                            },
                          ): Center(
                            child: LoadingAnimationWidget.flickr(
                                leftDotColor: Palette.kuungaaDefault,
                                rightDotColor: Colors.black,
                                size: 40
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          );
        },
        child: Row(
          children: reactionWidgets,
        ),
      );
    }else{
      return Container(
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.thumb_up,
          size: 12.0,
          color: Colors.white,
        ),
      );
    }
  }
}


class PostReactionsContainer extends StatefulWidget {
  final Posts post;
  const PostReactionsContainer({
    Key? key,
    required this.post
  }) : super(key: key);

  @override
  State<PostReactionsContainer> createState() => _PostReactionsContainerState();
}

class _PostReactionsContainerState extends State<PostReactionsContainer> {

  int likeCount = 0;
  DatabaseReference? itemRefLike;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefLike = database.reference().child('KUUNGAA').child("Posts").child(widget.post.post_id!).child("likes");
    itemRefLike!.onChildAdded.listen(_onEntryAddedLike);
    itemRefLike!.onChildRemoved.listen(_onEntryRemovedLike);
  }

  _onEntryAddedLike(Event event) async {
    setState(() {
      likeCount = likeCount + 1;
    });
  }

  _onEntryRemovedLike(Event event) async {
    setState(() {
      likeCount = likeCount - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        likeCount.toString(),
        style: TextStyle(
          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
        ),
      ),
    );

  }
}


class PostCommentsContainer extends StatefulWidget {
  final Posts post;
  const PostCommentsContainer({
    Key? key,
    required this.post
  }) : super(key: key);

  @override
  State<PostCommentsContainer> createState() => _PostCommentsContainerState();
}

class _PostCommentsContainerState extends State<PostCommentsContainer> {

  int commentCount = 0;
  DatabaseReference? itemRefComment;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRefComment = database.reference().child('KUUNGAA').child("Posts").child(widget.post.post_id!).child("comments");
    itemRefComment!.onChildAdded.listen(_onEntryAddedComment);
    itemRefComment!.onChildRemoved.listen(_onEntryRemovedComment);
    countSubComments();
  }

  _onEntryAddedComment(Event event) async {
    setState(() {
      commentCount = commentCount + 1;
    });
  }

  _onEntryRemovedComment(Event event) async {
    setState(() {
      commentCount = commentCount - 1;
    });
  }

  countSubComments(){
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(widget.post.post_id!).child("comments");
    dbRef.once().then((DataSnapshot snapshot){
      if(snapshot.exists){
        var keys = snapshot.value.keys;
        var values = snapshot.value;

        for(var key in keys){
          getSubComment(key);
          removeSubComment(key);
        }
      }
    });
  }

  getSubComment(String key){
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(widget.post.post_id!).child("comments").child(key).child("comments");
    dbRef.onChildAdded.listen(_onEntryAddedComment);
  }

  removeSubComment(String key){
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(widget.post.post_id!).child("comments").child(key).child("comments");
    dbRef.onChildRemoved.listen(_onEntryRemovedComment);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: PostComments(postid: widget.post.post_id!, posterid: widget.post.poster_id!,)));
      },
      child: Text(commentCount.toString() + " " + 'Comments',
        style: TextStyle(
          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
        ),
      ),
    );
  }
}

