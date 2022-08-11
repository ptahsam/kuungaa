import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class DiscussionPage extends StatefulWidget {
  static const String idScreen = "discussionPage";

  const DiscussionPage({Key? key}) : super(key: key);

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> with
AutomaticKeepAliveClientMixin<DiscussionPage> {

  @override
  bool get wantKeepAlive => true;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          scrollDirection: Axis.vertical,
          headerSliverBuilder: (context, bool s) => [
            SliverAppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,
              shadowColor: Colors.transparent,
              floating: true,
              leadingWidth: 0.0,
              //automaticallyImplyLeading: true,
              pinned: true,
              snap: true,
              elevation: 40.0,
              title: Text(
                "Discussion",
                style: TextStyle(
                  color: HexColor("#2dce89"),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              centerTitle: false,
              /*leading: Icon(
                const IconData(0xe90d, fontFamily: "icomoon"),
                size: 24.0,
                color: HexColor("#2dce89"),
              ),*/
              actions: [
                CircleButton(
                  icon: const IconData(0xe929, fontFamily: "icomoon"),
                  iconSize: 22.0,
                  onPressed: () => showModalBottomSheet(
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                    ),
                    context: context,
                    builder: (context) => buildDiscussionSheet(),
                  ),
                ),
                /*CircleButton(
                    icon: IconData(0xe908, fontFamily: "icomoon"),
                    iconSize: 22.0,
                    onPressed: () => print("Chat"),
                  ),
                  */
              ],
              bottom: TabBar(
                onTap: (index){
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                padding: const EdgeInsets.symmetric(horizontal: 10.0,),
                indicatorPadding: EdgeInsets.zero,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Provider.of<AppData>(context).darkTheme?Colors.white:HexColor("#2dce89"),
                      width: 3.0,

                    ),
                  ),
                  //borderRadius: BorderRadius.circular(5.0),
                ),
                tabs: [
                  Tab(icon: Provider.of<AppData>(context).darkTheme?Icon(
                    FontAwesomeIcons.userFriends, color: Colors.white, size: 18.0,
                  ):ShaderMask(
                      shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                      child: Icon(FontAwesomeIcons.userFriends, color: HexColor("#2dce89"),)),
                    child: Provider.of<AppData>(context).darkTheme?Text(
                      "Groups",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ):ShaderMask(
                        shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                        child: Text("Groups", style: TextStyle(color: HexColor("#2dce89"),),)),

                  ),
                  Tab(icon: Provider.of<AppData>(context).darkTheme?Icon(
                    FontAwesomeIcons.pager, color: Colors.white, size: 18.0,
                  ):ShaderMask(
                      shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                      child: Icon(FontAwesomeIcons.pager, color: HexColor("#2dce89"),)),
                    child: Provider.of<AppData>(context).darkTheme?Text(
                      "Pages",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ):ShaderMask(
                        shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                        child: Text("Pages", style: TextStyle(color: HexColor("#2dce89"),),)),
                  ),
                ],
              ),
            ),
          ],
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              CustomScrollView(
                slivers: [
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    sliver: SliverToBoxAdapter(
                      child: GroupMenu(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,)
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("Groups", style: TextStyle(fontWeight: FontWeight.bold),),
                            ),

                            Expanded(
                                child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!)
                            ),
                          ]
                      ),
                    ),
                  ),

                  const SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    sliver: SliverToBoxAdapter(
                      child: Groups(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Container(
                      height: 1.0,
                      width: MediaQuery.of(context).size.width,
                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildListDelegate([
                      const GroupContainer(),
                    ]),
                  ),
                ],

              ),
              CustomScrollView(
                slivers: [
                  const SliverPadding(
                    padding: EdgeInsets.only(top: 10.0),
                    sliver: SliverToBoxAdapter(
                      child: PagesMenu(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,)
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("Pages", style: TextStyle(fontWeight: FontWeight.bold),),
                            ),

                            Expanded(
                                child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!)
                            ),
                          ]
                      ),
                    ),
                  ),

                  const SliverPadding(
                    padding: EdgeInsets.only(top: 5.0),
                    sliver: SliverToBoxAdapter(
                      child: KPages(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Container(
                      height: 1.0,
                      width: MediaQuery.of(context).size.width,
                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildListDelegate([
                      const PageContainer(),]),
                  ),
                ],
              ),
            ],
          ),
          /*body: CustomScrollView(
          slivers: [


            /*SliverPadding(
              padding: const EdgeInsets.all(0.0),
              sliver: SliverToBoxAdapter(
                child: DiscussionMenu(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 0.0),
              sliver: SliverToBoxAdapter(
                child: GroupMenu(),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(top: 10.0),
              sliver: SliverToBoxAdapter(
                child: Groups(),
              ),
            ),*/

            SliverPadding(
              padding: EdgeInsets.zero,
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 900.0,
                  child: TabBarView(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: GroupMenu(),
                          ),
                          Groups(),
                          GroupContainer(),
                        ],
                      ),
                      Text("Pages"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),*/
        ),
      ),
    );
  }

  Widget buildDiscussionSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: ()  {
              if(userCurrentInfo != null){
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const CreateGroup())).then((value){
                  setState(() {

                  });
                });
               }
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
                      FontAwesomeIcons.userFriends,
                      color: Palette.kuungaaDefault,
                    ),
                    iconSize: 22.0,
                    onPressed: () => {},
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Create a group",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: (){
              if(userCurrentInfo != null){
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const CreatePage())).then((value){
                  setState(() {

                  });
                });

              }
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
                      FontAwesomeIcons.pager,
                      color: Palette.kuungaaDefault,
                      //size: 28.0,
                    ),
                    iconSize: 22.0,
                    onPressed: () => {},
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Create a page",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
