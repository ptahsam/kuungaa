import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../config/palette.dart';
import 'create_post_container.dart';

class HomeTopAppBar extends StatefulWidget {
  const HomeTopAppBar({Key? key}) : super(key: key);

  @override
  State<HomeTopAppBar> createState() => _HomeTopAppBarState();
}

class _HomeTopAppBarState extends State<HomeTopAppBar> {

  Image? myImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,
      leadingWidth: 0.0,
      //expandedHeight : 200.0,
      floating : true,
      pinned : false,
      title:FutureBuilder(
          future: getCurrentUserInfo(),
          builder: (BuildContext context, AsyncSnapshot<Users> snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              return SizedBox(
                height: 35.0,
                child: myImage!,
              );
            }else{
              return Shimmer.fromColors(
                baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                child: Container(
                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                  height: 35.0,
                  width: MediaQuery.of(context).size.width * 0.45,
                ),
              );
            }
          }
      ),
      actions: [
        FutureBuilder(
          future: getCurrentUserInfo(),
          builder: (BuildContext context, AsyncSnapshot<Users> snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              return Stack(
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

        FutureBuilder(
          future: getCurrentUserInfo(),
          builder: (BuildContext context, AsyncSnapshot<Users> snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              return Stack(
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
      //systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }
}
