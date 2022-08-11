import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/custom_tab_bar.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CustomAppBar extends StatelessWidget {

  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onTap;

  const CustomAppBar({
    Key? key,
    required this.icons,
    required this.selectedIndex,
    required this.onTap
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      height: 65.0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0,2),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 35.0,
            child: Image.asset(
              "images/klogo.png",
              fit: BoxFit.contain,
            ),
          ),
          Container(
            height: double.infinity,
            width: 600.0,
            child: CustomTabBar(
              icons: icons,
              selectedIndex: selectedIndex,
              onTap: onTap,
              isBottomIndicator: true
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
              )
            ],
          ),
        ],
      ),
    );
  }
}

