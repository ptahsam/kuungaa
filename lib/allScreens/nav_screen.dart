import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/allScreens/friendScreen.dart';
import 'package:kuungaa/allScreens/videosScreen.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snippet_coder_utils/hex_color.dart';

import 'screens.dart';

class NavScreen extends StatefulWidget {
  static const String idScreen = "NavScreen";

  final String? postid;

  final int sendIndex;

  final bool isNavigate;

  const NavScreen({Key? key, this.postid, this.sendIndex = 0, this.isNavigate = false}) : super(key: key);



  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> with RestorationMixin {

  Image? myImage;

  final List<Widget> _screens = [
    MainPage(),
    TravelPage(),
    DiscussionPage(),
    VideosPage(),
    FriendsPage(),
  ];

  final List<IconData> _icons = const [
    IconData(0xe91f, fontFamily: "icomoon"),
    IconData(0xe900, fontFamily: "icomoon"),
    IconData(0xe90d, fontFamily: "icomoon"),
    IconData(0xe93d, fontFamily: "icomoon"),
    IconData(0xe91b, fontFamily: "icomoon"),
  ];

  int _selectedIndex = 0;
  final RestorableInt _index = RestorableInt(0);

  @override
  // The restoration bucket id for this page,
  // let's give it the name of our page!
  String get restorationId => 'home_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // Register our property to be saved every time it changes,
    // and to be restored every time our app is killed by the OS!
    registerForRestoration(_index, 'nav_bar_index');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethods.userOnline();
    if(widget.isNavigate){
      setState(() {
        _selectedIndex = widget.sendIndex;
      });
    }
    if(widget.postid != null && widget.postid != ""){
      //print("d-link in nav:: " + widget.postid!);
      navigateToPost();
    }
    myImage= Image.asset(
      "images/klogo.png",
      fit: BoxFit.contain,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(myImage!.image, context);
  }

  navigateToPost(){
    Future.delayed(Duration.zero,()
    async{
      Posts post = await getPostFromID(widget.postid!);
      List<Media> mediaList = await getPostMediaImages(widget.postid!);
      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewPostImage(post: post, media: mediaList,)));

    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: _icons.length,
      child: Platform.isIOS?Scaffold(
        appBar: PreferredSize(
          child: Container(
            padding: EdgeInsets.only(top: 50.0),
            decoration: BoxDecoration(
              color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:HexColor("#dddddd"),
                  width: 1.0,
                ),
              ),
            ),
            child: Container(
              padding: _selectedIndex == 0?EdgeInsets.only(left: 12.0, right: 12.0):EdgeInsets.zero,
              child: Column(
                children: [
                  _selectedIndex == 0?Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 35.0,
                        child: myImage!,
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              CircleButton(
                                icon: const IconData(0xe903, fontFamily: "icomoon"),
                                iconSize: 22.0,
                                onPressed: (){
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: const UserNotification()));
                                },
                              ),
                              Provider.of<AppData>(context).userNotifications != null && userNotificationsCount > 0? Positioned(
                                top: 5.0,
                                right: 5.0,
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(Provider.of<AppData>(context).userNotifications!.notification_count!.toString(), style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.white
                                  ),),
                                ),
                              ) : const SizedBox.shrink(),
                            ],
                          ),
                          SizedBox(width: 6.0,),
                          Stack(
                            children: [
                              CircleButton(
                                icon: const IconData(0xe908, fontFamily: "icomoon"),
                                iconSize: 22.0,
                                onPressed: (){
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: const KuungaaChat()));
                                },
                              ),
                              Provider.of<AppData>(context).messageCount != null && userMessageCount > 0?Positioned(
                                top: 5.0,
                                right: 5.0,
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(Provider.of<AppData>(context).messageCount!.message_count!.toString(), style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.white
                                  ),),
                                ),
                              ): const SizedBox.shrink(),
                            ],
                          ),
                          SizedBox(width: 6.0,),
                          FutureBuilder(
                            future: getCurrentUserInfo(),
                            builder: (BuildContext context, AsyncSnapshot<Users> snapshot){
                              if(snapshot.connectionState == ConnectionState.done){
                                Users user = snapshot.data!;
                                return InkWell(
                                  onTap: (){
                                    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: user.user_id!,)));
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(6.0),
                                      child: ProfileAvatar(imageUrl: user.user_profileimage!, hasBorder: true, radius: 22.0, borderWidth: 21.0,)
                                  ),
                                );
                              }else{
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Shimmer.fromColors(
                                    baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                    highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                    child: CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ):SizedBox.shrink(),
                  Expanded(
                    child: CustomTabBar(
                      icons: _icons,
                      selectedIndex: _selectedIndex,
                      onTap: (index) => setState(() => _selectedIndex = index),
                    ),
                  ),
                ],
              ),
            ),
          ),
          preferredSize: _selectedIndex == 0?Size(screenSize.width, 120.0):Size(screenSize.width, 50.0),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ):Scaffold(
        appBar: Responsive.isDesktop(context) ?
          PreferredSize(
              child: CustomAppBar(
                icons: _icons,
                selectedIndex: _selectedIndex,
                onTap: (index) => setState((){
                  _selectedIndex = index;
                  _index.value = index;
                }),
              ),
              preferredSize: Size(screenSize.width, 100.0),
          ) : null,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: !Responsive.isDesktop(context) && Platform.isAndroid ?
        Container(
          padding: const EdgeInsets.only(bottom: 0.0),
            decoration: BoxDecoration(
              color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,
              border: Border(
                top: BorderSide(
                  color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:HexColor("#dddddd"),
                  width: 1.0,
                ),
              ),
            ),
          child: CustomTabBar(
            icons: _icons,
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        ) : const SizedBox.shrink(),
      ),
    );
  }
}
