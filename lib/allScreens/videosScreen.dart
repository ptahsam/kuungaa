import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class VideosPage extends StatefulWidget {
  static const String idScreen = "videoPage";

  const VideosPage({Key? key}) : super(key: key);

  @override
  _VideosPageState createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {

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
              snap: true,
              elevation: 40.0,
              pinned: true,
              title: Text(
                "Watch",
                style: TextStyle(
                  color: HexColor("#2dce89"),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              centerTitle: false,
              /*leading: Icon(
                const IconData(0xe93d, fontFamily: "icomoon"),
                size: 24.0,
                color: HexColor("#2dce89"),
              ),*/
              actions: const [
                /*CircleButton(
                  icon: IconData(0xe929, fontFamily: "icomoon"),
                  iconSize: 22.0,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateTravelPost())),
                ),*/
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Provider.of<AppData>(context).darkTheme?Icon(
                          FontAwesomeIcons.tv,
                          color: Colors.white,
                          size: 18.0,
                        ):ShaderMask(
                            shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                            child: Icon(FontAwesomeIcons.tv, color: HexColor("#2dce89"), size: 18.0,)),
                        const SizedBox(width: 6.0,),
                        Provider.of<AppData>(context).darkTheme?Text(
                          "Watch",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ):ShaderMask(
                            shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                            child: Text("Watch", style: TextStyle(color: HexColor("#2dce89"),),)),
                      ],
                    ),

                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Provider.of<AppData>(context).darkTheme?Icon(
                          FontAwesomeIcons.video,
                          color: Colors.white,
                          size: 18.0,
                        ):ShaderMask(
                            shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                            child: Icon(FontAwesomeIcons.video, color: HexColor("#2dce89"), size: 18.0,)),
                        const SizedBox(width: 6.0,),
                        Provider.of<AppData>(context).darkTheme?Text(
                          "Live",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ):ShaderMask(
                            shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                            child: Text("Live", style: TextStyle(color: HexColor("#2dce89"),),)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Provider.of<AppData>(context).darkTheme?Icon(
                          FontAwesomeIcons.save,
                          color: Colors.white,
                          size: 18.0,
                        ):ShaderMask(
                            shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                            child: Icon(FontAwesomeIcons.save, color: HexColor("#2dce89"), size: 18.0,)),
                        const SizedBox(width: 6.0,),
                        Provider.of<AppData>(context).darkTheme?Text(
                          "Saved",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ):ShaderMask(
                            shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                            child: Text("Saved", style: TextStyle(color: HexColor("#2dce89"),),)),
                      ],
                    ),
                  ),
                ],
              ), systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
          ],
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              CustomScrollView(
                slivers: [
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
                                child: Text("Watch videos", style: TextStyle(fontWeight: FontWeight.bold),),
                              ),

                              Expanded(
                                  child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!)
                              ),
                            ]
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      const VideosPostContainer(),]),
                  ),
                ],
              ),
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.13,
                          width: MediaQuery.of(context).size.width * 0.65,
                          decoration: BoxDecoration(
                            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  MdiIcons.progressAlert,
                                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.grey,
                                ),
                                SizedBox(height: 6.0,),
                                Text("This feature is currently under development", textAlign: TextAlign.center,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      CustomScrollView(
        slivers: [
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
                        child: Text("Saved Videos", style: TextStyle(fontWeight: FontWeight.bold),),
                      ),

                      Expanded(
                          child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!)
                      ),
                    ]
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SavedVideosPostContainer(),]),
          ),
        ],
      ),
            ],
          ),
        ),
      ),
    );
  }
}
