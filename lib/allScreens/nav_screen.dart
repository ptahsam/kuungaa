import 'package:flutter/material.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/allScreens/friendScreen.dart';
import 'package:kuungaa/allScreens/videosScreen.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

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

class _NavScreenState extends State<NavScreen> {

  final List<Widget> _screens = [
    MainPage(),
    const TravelPage(),
    DiscussionPage(),
    const VideosPage(),
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
      print("d-link in nav:: " + widget.postid!);
      navigateToPost();
    }
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
      child: Scaffold(
        appBar: Responsive.isDesktop(context) ?
          PreferredSize(
              child: CustomAppBar(
                icons: _icons,
                selectedIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
              ),
              preferredSize: Size(screenSize.width, 100.0),
          ) : null,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: !Responsive.isDesktop(context) ?
        Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: Container(
            color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,

            child: CustomTabBar(
              icons: _icons,
              selectedIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        ) : const SizedBox.shrink(),
      ),
    );
  }
}
