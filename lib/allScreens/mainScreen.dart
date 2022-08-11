
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/live.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/kuungaa_chat.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snippet_coder_utils/hex_color.dart';


class MainPage extends StatefulWidget {

  static const String idScreen = "mainPage";

  const MainPage({Key? key}) : super(key: key);



  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{

  bool refresh = false;

  bool getMore = false;

  ScrollController? postScrollController;

  _scrollListener() {
    if (postScrollController!.offset >= postScrollController!.position.maxScrollExtent &&
        !postScrollController!.position.outOfRange) {
      setState(() {
        getMore = true;
        //print("scroll :: => reach the bottom");
      });
    }
    if (postScrollController!.offset <= postScrollController!.position.minScrollExtent &&
        !postScrollController!.position.outOfRange) {
      setState(() {
        print("scroll :: => reach the top");
      });
    }
  }

  @override
  void initState() {
    super.initState();
   // postScrollController = ScrollController();
    //postScrollController!.addListener(_scrollListener);
      setState(() {
        AssistantMethods.getCurrentOnlineUserInfo();
        AssistantMethods.getUserNotification(context);
        AssistantMethods.updateUserNotification(context);
        AssistantMethods.getUserChats(context);
      });
    //logo = Image.asset(AppImages.logo);
    //getCurrentUserInfo();
  }


  Future<Users> getCurrentUserInfo() async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser!.uid;
    Users currentUserInfo = await AssistantMethods.getCurrentOnlineUser(userId);
    return currentUserInfo;
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
        body: Responsive(
          mobile: _HomescreenMobile(),
          desktop: _HomeScreenDesktop(),
        ),
      ),
    );
  }

  Future<List> getLiveUsers() async{
    List<Live> liveUsers = [];
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Live");
    await dbRef.once().then((DataSnapshot snapshot) async {
      if(snapshot.exists){
        var keys = snapshot.value.keys;
        var values = snapshot.value;

        for(var key in keys){
          String id = key;
          Live live = Live();
          live.live_id = values [key]["live_id"];
          live.start_time = values [key]["started_at"];
          DatabaseReference userRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users").child(id);
          await userRef.once().then((DataSnapshot dataSnapshot){
            Users user = Users.fromSnapshot(dataSnapshot);
            live.user_data = user;
            liveUsers.add(live);
          });
        }
      }
    });
    return liveUsers.reversed.toList();
  }
}

class _HomescreenMobile extends StatelessWidget {
  const _HomescreenMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      //controller: postScrollController!,
      slivers: [
        SliverAppBar(
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
                    child: Image.asset(
                      "images/klogo.png",
                      fit: BoxFit.contain,
                    ),
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
          /*
              title: Text(
                "KUUNGAA",
                style: TextStyle(
                  color: HexColor("#2dce89"),
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.2,
                ),
                textAlign: TextAlign.start,
              ),
              centerTitle: false,
               */
          /*leading: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  "images/kuungaaboxlogo.png",
                  fit: BoxFit.cover,
                ),
              ),*/
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
        ),
        const SliverToBoxAdapter(
          child: CreatePostContainer(),

        ),
        SliverToBoxAdapter(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //child: Text("Stories", style: TextStyle(fontWeight: FontWeight.bold),) ,
                    child: InkWell(
                      onTap: (){
                        /*setState(() {
                              refresh = true;
                            });*/
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Palette.kuungaaDefault,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.arrow_upward_outlined,
                              color: Colors.white,
                              size: 14.0,
                            ),
                            SizedBox(width: 3.0,),
                            Text(
                              "New posts",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                      child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!)
                  ),
                ]
            ),
          ),
        ),
        /*SliverToBoxAdapter(
              child: FutureBuilder(
                future: getLiveUsers(),
                builder: (context, AsyncSnapshot<List> snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasData){
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        height: 60.0,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, int index){
                            Live live = snapshot.data![index];
                            return InkWell(
                              onTap: (){
                                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: GoLive()));
                              },
                              child: ProfileAvatar(imageUrl: live.user_data!.user_profileimage!, isActive: true, radius: 25.0,),
                            );
                          },
                        ),
                      );
                    }else{
                      return const SizedBox.shrink();
                    }
                  }else{
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),*/
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
            child: const Stories(),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 1.0,
            width: MediaQuery.of(context).size.width,
            color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: double.infinity,
            ),
            child: PostContainer(),
          ),
        ),
      ],
    );
  }
}

class _HomeScreenDesktop extends StatelessWidget {
  const _HomeScreenDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Container(
            color: Colors.orange,
          ),
        ),
        Spacer(),
        Container(
          width: 600.0,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                    child: const Stories(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: CreatePostContainer(),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 1.0,
                  width: MediaQuery.of(context).size.width,
                  color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.grey[300]!,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: double.infinity,
                  ),
                  child: PostContainer(),
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        Flexible(
          flex: 2,
          child: Container(
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}








