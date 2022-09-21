import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/comment.dart';
import 'package:kuungaa/Models/story.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/MultiManager/flick_multimanager.dart';
import 'package:kuungaa/MultiManager/flick_multiplayer.dart';
import 'package:kuungaa/allScreens/screens.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'dart:io';


class Stories extends StatefulWidget {
  const Stories({Key? key}) : super(key: key);


  @override
  State<Stories> createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {

  //final String img = "https://firebasestorage.googleapis.com/v0/b/kuungaa-42ba2.appspot.com/o/KUUNGAA%2Fimages%2Fprofile.jpg?alt=media&token=8426002b-381d-4dfb-98aa-b49570cd1303";
  late Future<List> getStories;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStories = getStoriesList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.0,
      color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      child: FutureBuilder<List>(
        future: getStories,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData){
              if(snapshot.data!.length > 0){
                List<Users> usersList = [];
                for(var i = 0; i < snapshot.data!.length; i++){
                  Story story = snapshot.data![i];
                  Users users = Users();
                  users.user_id = story.story_poster!;
                  usersList.add(users);
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 8.0,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: 1 + snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index)
                        {
                          if(index == 0)
                          {
                            return InkWell(
                              onTap: (){
                                Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const CreateStory()));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: _StoryCard(
                                  isAddStory: true,
                                  story: snapshot.data![0],
                                ),
                              ),
                            );
                          }
                          Story story = snapshot.data![index - 1];
                          return InkWell(
                            onTap: (){
                              Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: ViewStory(userid: story.story_poster!, usersList: usersList,)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: _StoryCard(story: snapshot.data![index - 1]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }else{
                return Row(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const CreateStory()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                userCurrentInfo!.user_profileimage!,
                                fit: BoxFit.cover,
                                width: 110.0,
                                height: double.infinity,
                                //cacheWidth: 110,
                                //cache: true,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (rect) => Palette.createStoryGradient.createShader(rect),
                              child: Container(
                                height: double.infinity,
                                //padding: EdgeInsets.all(2.0),
                                width: 110.0,
                                decoration: BoxDecoration(
                                  //color: Colors.transparent,
                                  gradient: Palette.storyGradient,
                                  border: Border.all(
                                    width: 0.2,
                                    color: Palette.kuungaaAccent,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),

                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: 8.0,
                              left: 8.0,
                              right: 8.0,
                              child: Text(
                                'Add to Story',
                                style: TextStyle(
                                  color: Palette.kuungaaDefault,
                                  fontWeight: FontWeight.w200,
                                  fontSize: 12.0,
                                ),
                                //maxLines: 2,
                                //overflow: TextOverflow.ellipsis,
                                //textAlign: TextAlign.center,
                              ),
                            ),
                            Positioned(
                              top: 8.0,
                              left: 8.0,
                              child: Container(
                                height: 40.0,
                                width: 40.0,
                                decoration: BoxDecoration(
                                  color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.add),
                                  iconSize: 30.0,
                                  color: Palette.kuungaaDefault,
                                  onPressed: () =>Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const CreateStory()))
                                  ,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const CreateStory()));
                        },
                        child: Container(
                          height: double.infinity,
                          margin: EdgeInsets.only(right: 12.0, top: 15.0, bottom: 15.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                            //gradient: Palette.storyGradient,
                            border: Border.all(
                              width: 0.2,
                              color: Palette.kuungaaAccent,
                            ),
                            borderRadius: BorderRadius.circular(10.0),

                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                MdiIcons.newspaperVariantMultipleOutline,
                                color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                              ),
                              SizedBox(height: 6.0,),
                              Text("No current stories. Be the first to add a story. ", textAlign: TextAlign.center,),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }else{
              return InkWell(
                onTap: (){
                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const CreateStory()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          userCurrentInfo!.user_profileimage!,
                          fit: BoxFit.cover,
                          width: 110.0,
                          height: double.infinity,
                          //cacheWidth: 110,
                          //cache: true,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (rect) => Palette.createStoryGradient.createShader(rect),
                        child: Container(
                          height: double.infinity,
                          //padding: EdgeInsets.all(2.0),
                          width: 110.0,
                          decoration: BoxDecoration(
                            //color: Colors.transparent,
                            gradient: Palette.storyGradient,
                            border: Border.all(
                              width: 0.2,
                              color: Palette.kuungaaAccent,
                            ),
                            borderRadius: BorderRadius.circular(10.0),

                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 8.0,
                        left: 8.0,
                        right: 8.0,
                        child: Text(
                          'Add to Story',
                          style: TextStyle(
                            color: Palette.kuungaaDefault,
                            fontWeight: FontWeight.w200,
                            fontSize: 12.0,
                          ),
                          //maxLines: 2,
                          //overflow: TextOverflow.ellipsis,
                          //textAlign: TextAlign.center,
                        ),
                      ),
                      Positioned(
                        top: 8.0,
                        left: 8.0,
                        child: Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: BoxDecoration(
                            color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add),
                            iconSize: 30.0,
                            color: Palette.kuungaaDefault,
                            onPressed: () =>Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const CreateStory()))
                            ,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
        }else{
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 8.0,
            ),
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (BuildContext context, int index){
              return Shimmer.fromColors(
                baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Stack(
                    children: [
                      Container(
                          height: double.infinity,
                          width: 110.0,
                          decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                         )
                      ),
                      Positioned(
                        top: 8.0,
                        left: 8.0,
                        child: Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: BoxDecoration(
                            color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
          }
        },
      ),
    );
  }

  Future<List> getStoriesList() async {
    List storiesList = [];
    DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Stories");
    await dbReference.once().then((DataSnapshot dataSnapshot) async {
      if(dataSnapshot.exists){
        storiesList.clear();
        var keys = dataSnapshot.value.keys;
        //var values = dataSnapshot.value;

        for (var key in keys)
        {
            String userid = key;
            DatabaseReference storyRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Stories");
            await storyRef.child(userid).orderByKey().limitToLast(1).once().then((DataSnapshot snapshot){
              var zees = snapshot.value.keys;
              var values = snapshot.value;
              for(var zee in zees){
                Story story = Story();
                story.story_id = zee;
                story.story_description = values [zee]["story_description"];
                story.story_time = values [zee]["story_time"];
                story.story_media = values [zee]["story_media"];
                story.story_poster = values [zee]["story_poster"];
                story.story_type = values [zee]["story_type"];
                story.story_duration = values [zee]["story_duration"];
                storiesList.add(story);
              }
            });
          }
      }
    });
    return storiesList.reversed.toList();
  }
}

class _StoryCard extends StatelessWidget{

  final bool isAddStory;
  final Story? story;

  const _StoryCard({
    Key? key,
    this.isAddStory = false,
    this.story
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        isAddStory ? ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: ExtendedImage.network(
            userCurrentInfo!.user_profileimage!,
            width: 110.0,
            //cacheWidth: 110,
            height: double.infinity,
            fit: BoxFit.cover,
           // cache: true,
            filterQuality: FilterQuality.high,
          ),
        ) : story!.story_type == "image_story"?  ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: ExtendedImage.network(
            story!.story_media!,
            height: double.infinity,
            width: 110.0,
           // cacheWidth: 110,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            //cache: true,
          ),
        ): Container(
          height: double.infinity,
          width: 110.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            //color: Palette.kuungaaDefault,
          ),
          child: FutureBuilder(
            future: generateVideoThumbnail(story!.story_media!),
            builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot){
              if(snapshot.hasData){
                final bytes = snapshot.data;
                return ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.memory(bytes!, fit: BoxFit.cover));
              }else{
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        ShaderMask(
          shaderCallback: (rect) => Palette.createStoryGradient.createShader(rect),
          child: Container(
            height: double.infinity,
            //padding: EdgeInsets.all(2.0),
            width: 110.0,
            decoration: BoxDecoration(
              //color: Colors.transparent,
              gradient: Palette.storyGradient,
              border: Border.all(
                width: 0.2,
                color: Palette.kuungaaAccent,
              ),
              borderRadius: BorderRadius.circular(10.0),

            ),
          ),
        ),
        Positioned(
            top: 8.0,
            left: 8.0,
            child: isAddStory
                ? Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
                      shape: BoxShape.circle,
                    ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add),
                iconSize: 30.0,
                color: Palette.kuungaaDefault,
                onPressed: () => Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const CreateStory()))
    ,
              ),
            )
            :
            FutureBuilder(
              future: getUserPostData(story!.story_poster!, "user_profileimage"),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                if(snapshot.hasData){
                  return ProfileAvatar(imageUrl: snapshot.data!, hasBorder: true, borderWidth: 18.0, backGroundColor: "#2dce89",);
                }else{
                  return const SizedBox.shrink();
                }
              },
            ),//(story!.user_profileimage != null? ProfileAvatar(imageUrl: story!.user_profileimage!) : ProfileAvatar(imageUrl: img) ),
        ),
        isAddStory ? const Positioned(
          bottom: 8.0,
          left: 8.0,
          right: 8.0,
          child: Text(
            'Add to Story',
            style: TextStyle(
              color: Palette.kuungaaDefault,
              fontWeight: FontWeight.w200,
              fontSize: 12.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ) :
        Positioned(
          bottom: 8.0,
          left: 8.0,
          right: 8.0,
          child: FutureBuilder(
            future: getUserPostData(story!.story_poster!, "user_firstname"),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot){
              if(snapshot.hasData){
                return Text(
                  snapshot.data!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                );
              }else{
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }

  Future<Uint8List> generateVideoThumbnail(String videoUrl) async{
    Uint8List bytes;
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      //maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 100,
    );

    File file = File(fileName!);
    bytes = await file.readAsBytes();
    return bytes;
  }
}

class ViewStory extends StatefulWidget {
  final List<Users> usersList;
  final String userid;
  const ViewStory({
    Key? key,
    required this.usersList,
    required this.userid
  }) : super(key: key);

  @override
  _ViewStoryState createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return FutureBuilder(
      future: getUserStories(widget.userid),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot){
        if(snapshot.hasData){
          List<Story> stories = [];
          for(var i = 0; i < snapshot.data!.length; i ++){
            Story story = snapshot.data![i];
            stories.add(story);
          }
          return StoryScreen(stories: stories, users: widget.usersList,);
        }else{
          return Scaffold(
            backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Future<List> getUserStories(String userid) async{
    List<Story> userStoryList = [];
    DatabaseReference storyRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Stories");
    await storyRef.child(userid).orderByKey().once().then((DataSnapshot snapshot) async {
      userStoryList.clear();
      var zees = snapshot.value.keys;
      var values = snapshot.value;
      for(var zee in zees){
        Story story = Story();
        story.story_id = zee;
        story.story_description = values [zee]["story_description"];
        story.story_time = values [zee]["story_time"];
        story.story_media = values [zee]["story_media"];
        story.story_poster = values [zee]["story_poster"];
        story.story_type = values [zee]["story_type"];
        story.storyUser = await AssistantMethods.getCurrentOnlineUser(story.story_poster!);
        userStoryList.add(story);
      }
    });
    return userStoryList.reversed.toList();
  }
}

class StoryScreen extends StatefulWidget {

  final List<Users> users;
  final List<Story> stories;
  const StoryScreen({required this.users, required this.stories});

  @override
  _StoryScreenState createState() => _StoryScreenState();

}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  PageController? _pageController;
  AnimationController? _animController;
  TextEditingController storyMainCommentContoller = TextEditingController();

  //VideoPlayerController? _videoController;

  final videoInfo = FlutterVideoInfo();
  final FlutterShareMe flutterShareMe = FlutterShareMe();
  late FlickMultiManager flickMultiManager;
  int _currentIndex = 0;
  bool imageHasLoaded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);
    flickMultiManager = FlickMultiManager();

    final Story firstStory = widget.stories.first;
    _loadStory(story: firstStory, animateToPage: false);

    _animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController!.stop();
        _animController!.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex += 1;
            _animController!.stop();
            _loadStory(story: widget.stories[_currentIndex]);

          } else {
            //int pos = widget.users.indexOf(widget.stories.first.storyUser! );
            widget.users.removeWhere((Users users) => users.user_id == widget.stories.first.story_poster!);
            if(widget.users.isNotEmpty){
              Users nextUser = widget.users.first;
              Navigator.pop(context);
              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewStory(userid: nextUser.user_id!, usersList: widget.users,)));
            }else{
              Navigator.pop(context);
            }
            // Out of bounds - loop story
            // You can also Navigator.of(context).pop() here
            //_currentIndex = 0;
            //Navigator.of(context).pop();
            //_loadStory(story: widget.stories[_currentIndex]);
          }
        });
      }
    });
    //_animController!.stop();
  }

  @override
  void dispose() {
    _pageController!.dispose();
    _animController!.dispose();
    //_videoController?.dispose();
    //_videoController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Story story = widget.stories[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details, story),
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              pageSnapping: true,
              itemBuilder: (context, i) {
                final Story story = widget.stories[i];
                addStoryViewers(story);
                if(story.story_type == "image_story"){
                  return ExtendedImage.network(
                    story.story_media!,
                    fit: BoxFit.cover,
                    enableMemoryCache: true,
                    cache: true,
                  );
                  //_animController!.stop();
                  /*return Image.network(
                    story.story_media!,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      _animController!.stop();
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  );*/
                }else if(story.story_type == "video_story"){
                  return Container(
                    width: double.infinity,
                    height: 350.0,
                    margin: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: FlickMultiPlayer(
                        url: story.story_media!,
                        flickMultiManager: flickMultiManager,
                        image: "images/video_thumbnail.png",
                      ),
                    ),
                  );
                }
               return const SizedBox.shrink();
              },
            ),
            Container(
              decoration: const BoxDecoration(
                  gradient: Palette.storyGradient
              ),
            ),
            Positioned(
              top: 40.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                children: <Widget>[
                  Row(
                    children: widget.stories
                        .asMap()
                        .map((i, e) {
                      return MapEntry(
                        i,
                        AnimatedBar(
                          animController: _animController!,
                          position: i,
                          currentIndex: _currentIndex,
                        ),
                      );
                    })
                        .values
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      //horizontal: 1.5,
                      //vertical: 10.0,
                    ),
                    child: Container(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 10.0, top: 10.0, left: 12.0, right: 12.0),
                        color: Colors.transparent,
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 20.0,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: NetworkImage(
                                story.storyUser!.user_profileimage!,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    story.storyUser!.user_firstname! + " " + story.storyUser!.user_lastname!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    convertToTimeAgo(story.story_time!),
                                    //'${post!.post_time!}',

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                  onPressed: (){
                                    _animController!.stop();
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      isDismissible: false,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                                      ),
                                      context: context,
                                      builder: (context) => buildSingleStorySheet(story),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            story.story_description != ""? Positioned(
              top: 130.0,
              left: 10.0,
              right: 10.0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: Center(
                  child: Text(
                    story.story_description!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ): const SizedBox.shrink(),

            Positioned(
              bottom: 20.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                children: [

                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        story.story_poster == userCurrentInfo!.user_id!?
                        InkWell(
                          onTap: (){
                            _animController!.stop();
                            showModalBottomSheet(
                              isScrollControlled: true,
                              isDismissible: false,
                              enableDrag: false,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                              ),
                              context: context,
                              builder: (context) => buildStoriesViewersSheet(story),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(MdiIcons.eye, color: Colors.white, size: 22.0,),

                              FutureBuilder(
                                future: getStoryViewers(story),
                                builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                                  if(snapshot.hasData){
                                    return Text(snapshot.data!.length.toString(), style: const TextStyle(color: Colors.white),);
                                  }else{
                                    return const Text("0", style: TextStyle(color: Colors.white),);
                                  }
                                },
                              ),
                            ],
                          ),
                        ): const SizedBox.shrink(),
                        story.story_poster == userCurrentInfo!.user_id!?
                        InkWell(
                          onTap: (){
                            _animController!.stop();
                            showModalBottomSheet(
                              isScrollControlled: true,
                              isDismissible: false,
                              enableDrag: false,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                              ),
                              context: context,
                              builder: (context) => buildStoriesCommentsSheet(story),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(MdiIcons.comment, color: Colors.white, size: 22.0,),
                              FutureBuilder(
                                future: getStoryComments(story),
                                builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                                  if(snapshot.hasData){
                                    return Text(snapshot.data!.length.toString(), style: const TextStyle(color: Colors.white),);
                                  }else{
                                    return const Text("0", style: TextStyle(color: Colors.white),);
                                  }
                                },
                              ),
                            ],
                          ),
                        ):const SizedBox.shrink(),
                        /*InkWell(
                          onTap: () {
                            setState(() {
                              _animController!.stop();
                            });
                            List<String> mediaPath = [];
                            //File filePath = File(story.story_media!);
                            //mediaPath.add(filePath.path);
                            onShare(context, mediaPath, story.story_description!, "");
                            //final box = context.findRenderObject() as RenderBox?;
                            /*await Share.share(story.story_description!,
                                subject: "",
                                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);*/
                            /*flutterShareMe.shareToWhatsApp(
                                imagePath: filePath.path,
                                fileType: FileType.image
                            );*/
                           /* await Share.shareFiles(mediaPath,
                                text: story.story_description,
                                subject: "",
                                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);*/
                            //flutterShareMe.shareToWhatsApp(msg: "Hello from kuungaa");
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(MdiIcons.share, color: Colors.white, size: 22.0,),
                              //Text("0", style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),*/
                      ],
                    ),
                  ),
                  story.story_poster != userCurrentInfo!.user_id!?const SizedBox(height: 40.0,):SizedBox.shrink(),
                  story.story_poster != userCurrentInfo!.user_id!?Row(
                    children: [
                      Expanded(
                        child: FocusScope(
                          onFocusChange: (focus){
                            if(focus){
                              _animController!.stop();
                            }
                          },
                          child: TextField(
                            onChanged: (value) {
                              //Do something with the user input.
                            },
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            controller: storyMainCommentContoller,
                            minLines: 1,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Write your comment',
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.white, width: 0.8),
                                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Palette.kuungaaDefault, width: 0.8),
                                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0,),
                      InkWell(
                        onTap: (){
                          saveStoryComment(story, storyMainCommentContoller.text);
                        },
                        child: const Icon(
                          Icons.send,
                          color: Palette.kuungaaDefault,
                          size: 30.0,
                        ),
                      ),
                    ],
                  ):SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (_currentIndex + 1 < widget.stories.length) {
          _currentIndex += 1;
          _loadStory(story: widget.stories[_currentIndex]);
        } else {
          // Out of bounds - loop story
          // You can also Navigator.of(context).pop() here
          _currentIndex = 0;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else {
      if (story.story_type == "video_story") {
        flickMultiManager.play();
       /* if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          _animController!.stop();
        } else {
          _videoController!.play();
          _animController!.forward();
        }*/
      }
    }
  }


  void onShare(BuildContext context, List<String> mediaPath, String text, String subject) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final box = context.findRenderObject() as RenderBox?;

    if (mediaPath.isNotEmpty) {
      await Share.shareFiles(mediaPath,
          text: text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
  }

  _loadStory({required Story story, bool animateToPage = true})  async{
    _animController!.stop();
    _animController!.reset();
    if(story.story_type == "image_story"){
        //print("story_duration ::" + story.story_duration!.toString());
      _animController!.duration = const Duration(seconds: 10);
      _animController!.forward();
      //print("story_duration ::" + story.story_duration!.toString());
    }else if(story.story_type == "video_story"){
      //var a = await videoInfo.getVideoInfo(story.story_media!);
      //print("video length :: " + a!.duration!.round().toString());
      _animController!.duration = const Duration(seconds: 30);
      flickMultiManager.play();
      _animController!.forward();
      /*_videoController?.dispose();
      _videoController = null;
      _videoController = VideoPlayerController.network(story.story_media!)
        ..initialize().then((_) {
          setState(() {});
          if (_videoController!.value.isInitialized) {
            _animController!.duration = _videoController!.value.duration;
            _videoController!.play();
            _animController!.forward();
          }
        });*/
    }

    if (animateToPage) {
      _pageController!.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<Duration> getVideoLength(String video) async{
    var a = await videoInfo.getVideoInfo(video);
    return Duration(seconds: a!.duration!.round());
  }

  void addStoryViewers(Story story) {
    DatabaseReference storyRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Stories').child(story.story_poster!).child(story.story_id!).child("Viewers");
    if(story.story_poster != userCurrentInfo!.user_id!){
      storyRef.child(userCurrentInfo!.user_id!).once().then((DataSnapshot snapshot){
        if(!snapshot.exists){
          var offsetRef = FirebaseDatabase.instance.reference().child(".info/serverTimeOffset");
          offsetRef.onValue.listen((event){
            int offset = event.snapshot.value;
            var viewtime = ((DateTime.now().millisecondsSinceEpoch) + offset);
            Map storyViewer = {
              "viewer_id" : userCurrentInfo!.user_id!,
              "view_time" : viewtime
            };

            storyRef.child(userCurrentInfo!.user_id!).set(storyViewer);
          });
        }
      });
    }
  }

  Future<List> getStoryViewers(Story story) async{
    List<Users> viewersList = [];
    DatabaseReference storyRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Stories').child(story.story_poster!).child(story.story_id!).child("Viewers");

    await storyRef.once().then((DataSnapshot snapshotPosts) async {
      if(snapshotPosts.exists){
        viewersList.clear();
        var keys = snapshotPosts.value.keys;
        var values = snapshotPosts.value;
        for (var key in keys)
        {
          String viewerid = values [key]["viewer_id"];
          final DatabaseReference friendInfoRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(viewerid);
          await friendInfoRef.once().then((DataSnapshot snapshot) {
            Users users = Users.fromSnapshot(snapshot);
            users.story_viewtime = values [key]["view_time"];
            viewersList.add(users);
          });
        }
      }
    });
    return viewersList.reversed.toList();
  }

  Future<List> getStoryComments(Story story) async{
    List<Comments> commentsList = [];

    DatabaseReference storyRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Stories').child(story.story_poster!).child(story.story_id!).child("Comments");
    await storyRef.once().then((DataSnapshot snapshotPosts) async {
      if(snapshotPosts.exists){
        commentsList.clear();
        var keys = snapshotPosts.value.keys;
        var values = snapshotPosts.value;
        for (var key in keys)
        {
          Comments comments = Comments();
          comments.comment_id = values [key]["comment_id"];
          comments.comment_text = values [key]["comment_text"];
          comments.comment_time = values [key]["comment_time"];
          comments.commenter_id = values [key]["commenter_id"];
          comments.post_id = values [key]["story_id"];
          commentsList.add(comments);
        }
      }
    });
    return commentsList.reversed.toList();
  }

  Widget buildStoriesCommentsSheet(Story story) {
    TextEditingController storyCommentContoller = TextEditingController();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 60.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold),),
              InkWell(
                onTap: (){
                  Navigator.of(context).pop();
                  _animController!.forward();
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200]!,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 25.0,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Stack(
            children: [
              FutureBuilder(
                future: getStoryComments(story),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.data!.isNotEmpty){
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
                        itemCount: snapshot.data!.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index){
                          final Comments comment = snapshot.data![index];
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    FutureBuilder(
                                      future: getUserPostData(comment.commenter_id!, "user_profileimage"),
                                      builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                                        if(snapshot.hasData){
                                          return ProfileAvatar(imageUrl: snapshot.data!, radius: 14.0,);
                                        }else{
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 4.0,),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            FutureBuilder(
                                              future: getUserPostData(comment.commenter_id!, "user_firstname"),
                                              builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                                                if(snapshot.hasData){
                                                  return Text(
                                                    snapshot.data!,
                                                    style: const TextStyle(
                                                      color: Colors.black87,
                                                    ),
                                                  );
                                                }else{
                                                  return const SizedBox.shrink();
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 4.0,),
                                            FutureBuilder(
                                              future: getUserPostData(comment.commenter_id!, "user_lastname"),
                                              builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                                                if(snapshot.hasData){
                                                  return Text(
                                                    snapshot.data!,
                                                    style: const TextStyle(
                                                      color: Colors.black87,
                                                    ),
                                                  );
                                                }else{
                                                  return const SizedBox.shrink();
                                                }
                                              },
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(20.0, 5.0, 0.0, 0.0),
                                  padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
                                  decoration: BoxDecoration(
                                    color: HexColor("#e9ecef"),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(comment.comment_text!),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }else{
                      return const Center(
                        child: Text("No comments yet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),),
                      );
                    }
                  }else{
                    return const Center(child: CircularProgressIndicator(),);
                  }
                },
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 20.0, right: 10.0, left: 10.0, top: 20.0),
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            //Do something with the user input.
                          },
                          //keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          minLines: 1,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          controller: storyCommentContoller,
                          decoration: const InputDecoration(
                            hintText: 'Write your comment',
                            hintStyle: TextStyle(
                              color: Colors.black,
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(25.0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.black, width: 0.8),
                              borderRadius: BorderRadius.all(Radius.circular(25.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Palette.kuungaaDefault, width: 0.8),
                              borderRadius: BorderRadius.all(Radius.circular(25.0)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0,),
                      InkWell(
                        onTap: (){
                          saveStoryComment(story, storyCommentContoller.text);
                        },
                        child: const Icon(
                          Icons.send,
                          color: Palette.kuungaaDefault,
                          size: 22.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> saveStoryComment(Story story, storyComment) async {
        DatabaseReference commentRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Stories').child(story.story_poster!).child(story.story_id!).child("Comments").push();
        String refKey = commentRef.key;

        var commenttime = DateTime.now().millisecondsSinceEpoch;;

          Map commentDataMap = {
            "comment_id" : refKey,
            "comment_text" : storyComment,
            "comment_time" : commenttime,
            "commenter_id" : userCurrentInfo!.user_id!,
            "post_id" : story.story_id,
          };

          commentRef.set(commentDataMap).then((onValue) {
            displayToastMessage("You have commented on this story", context);
          }).catchError((onError) {
            displayToastMessage("An error occurred. Please try again later", context);
          });

  }

  Widget buildStoriesViewersSheet(Story story) {
    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Viewers", style: TextStyle(fontWeight: FontWeight.bold),),
              InkWell(
                onTap: (){
                  Navigator.of(context).pop();
                  _animController!.forward();
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200]!,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 25.0,
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: FutureBuilder(
              future: getStoryViewers(story),
              builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                if(snapshot.hasData){
                  if(snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        Users users = snapshot.data![index];
                        return ListTile(
                          leading: ProfileAvatar(
                            imageUrl: users.user_profileimage!, radius: 20.0,),
                          title: Text(users.user_firstname! + " " +
                              users.user_lastname!),
                          trailing: Text(
                              convertToTimeAgo(users.story_viewtime!)),
                        );
                      },
                    );
                  }else{
                    return Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.13,
                        width: MediaQuery.of(context).size.width * 0.65,
                        decoration: BoxDecoration(
                          color: Colors.grey[100]!,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.remove_red_eye_sharp,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 6.0,),
                              Text("No viewers yet", textAlign: TextAlign.center,),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }else{
                  return const Center(child: CircularProgressIndicator(),);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSingleStorySheet(Story story) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                  _animController!.forward();
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200]!,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 25.0,
                  ),
                ),
              ),
            ],
          ),

          Row(
            children: [
              Container(
                margin: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    MdiIcons.share,
                    color: Palette.kuungaaDefault,
                  ),
                  iconSize: 22.0,
                  onPressed: (){

                  },
                ),
              ),
              const SizedBox(width: 14.0,),
              const Text(
                "Share this story",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Palette.kuungaaDefault,
                ),
              ),
            ],
          ),
          story.story_poster == userCurrentInfo!.user_id!?InkWell(
            onTap: () async {
              DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Stories").child(userCurrentInfo!.user_id!).child(story.story_id!);
              await dbRef.once().then((DataSnapshot snapshot) async {
                if(snapshot.exists){
                  firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Stories").child(story.story_id!);
                  await ref.listAll().then((result) async {
                    for (var file in result.items) {
                      file.delete();
                    }
                    dbRef.remove().then((value){
                      displayToastMessage("Your story was deleted successfully", context);
                      Navigator.pushNamedAndRemoveUntil(context, NavScreen.idScreen, (route) => false);
                    }).catchError((onError) {
                      Navigator.pop(context);
                      displayToastMessage("An error occurred. Please try again later", context);
                    });
                  });
                }
              });
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      MdiIcons.delete,
                      color: Colors.red,
                    ),
                    iconSize: 22.0,
                    onPressed: (){

                    },
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Delete this story",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.red
                  ),
                ),
              ],
            ),
          ):SizedBox.shrink(),
        ],
      ),
    );
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    Key? key,
    required this.animController,
    required this.position,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                _buildContainer(
                  double.infinity,
                  position < currentIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
                position == currentIndex
                    ? AnimatedBuilder(
                  animation: animController,
                  builder: (context, child) {
                    return _buildContainer(
                      constraints.maxWidth * animController.value,
                      Colors.white,
                    );
                  },
                )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 5.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}



