import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class FriendsPage extends StatefulWidget {
  static const String idScreen = "friendPage";

  const FriendsPage({Key? key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          scrollDirection: Axis.vertical,
          headerSliverBuilder: (context, bool s) => [
            SliverAppBar(
              backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,
              floating: true,
              leadingWidth: 0.0,
              //automaticallyImplyLeading: true,
              shadowColor: Colors.transparent,
              snap: true,
              elevation: 40.0,
              pinned: true,
              title: Text(
                "Friends",
                style: TextStyle(
                  color: HexColor("#2dce89"),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              centerTitle: false,
              /*leading: Icon(
                const IconData(0xe91b, fontFamily: "icomoon"),
                size: 24.0,
                color: HexColor("#2dce89"),
              ),*/

              bottom: TabBar(
                onTap: (index){
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                padding: const EdgeInsets.only(left: 10.0, top: 5.0, right: 10.0),
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
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Provider.of<AppData>(context).darkTheme?Icon(
                          FontAwesomeIcons.home,
                          color: Colors.white,
                          size: 18.0,
                        ):ShaderMask(
                            shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                            child: Icon(FontAwesomeIcons.home, color: HexColor("#2dce89"), size: 18.0,)),
                        const SizedBox(height: 6.0,),
                        Expanded(
                          child: Provider.of<AppData>(context).darkTheme?Text(
                            "Suggestions",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ):ShaderMask(
                              shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                              child: Text("Suggestions", style: TextStyle(color: HexColor("#2dce89"),),)),
                        ),
                      ],
                    ),

                  ),
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Provider.of<AppData>(context).darkTheme?Icon(
                          FontAwesomeIcons.userPlus,
                          color: Colors.white,
                          size: 18.0,
                        ):ShaderMask(
                            shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                            child: Icon(FontAwesomeIcons.userPlus, color: HexColor("#2dce89"), size: 18.0,)),
                        const SizedBox(height: 6.0,),
                        Expanded(
                          child: Provider.of<AppData>(context).darkTheme?Text(
                            "Requests",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ):ShaderMask(
                              shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                              child: Text("Requests", style: TextStyle(color: HexColor("#2dce89"),),)),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Provider.of<AppData>(context).darkTheme?Icon(
                          FontAwesomeIcons.userFriends,
                          color: Colors.white,
                          size: 18.0,
                        ):ShaderMask(
                            shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                            child: Icon(FontAwesomeIcons.userFriends, color: HexColor("#2dce89"), size: 18.0,)),
                        const SizedBox(height: 6.0,),
                        Expanded(
                          child: Provider.of<AppData>(context).darkTheme?Text(
                            "Friends",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ):ShaderMask(
                              shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                              child: Text("Friends", style: TextStyle(color: HexColor("#2dce89"),),)),
                        ),
                      ],
                    ),
                  ),
                ],
              ), systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
          ],
          body: IndexedStack(
            index: _selectedIndex,
            //physics: const NeverScrollableScrollPhysics(),
            children: [
              FriendsContainer(),
              CustomScrollView(
                slivers: [
                  /*SliverToBoxAdapter(
                    child: Container(
                      color: Colors.transparent,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                              ),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  minLines: 1,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding:
                                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                      hintText: "Search friend requests ...",
                                    hintStyle: TextStyle(
                                      color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                                    ),
                                  ),

                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),*/
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,)
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text("Your friend requests", style: TextStyle(fontWeight: FontWeight.bold),),
                              ),

                              Expanded(
                                  child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!)
                              ),
                            ]
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: FriendsRequestContainer(),
                  ),
                ],
              ),
              UserFriendsContainer(),
            ],
          ),
        ),
      ),
    );
  }
}
