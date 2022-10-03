
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snippet_coder_utils/hex_color.dart';

import 'widgets.dart';

class CreatePostContainer extends StatefulWidget {
  const CreatePostContainer({Key? key}) : super(key: key);


  @override
  State<CreatePostContainer> createState() => _CreatePostContainerState();
}

Future<Users> getCurrentUserInfo() async {
  firebaseUser = FirebaseAuth.instance.currentUser;
  String userId = firebaseUser!.uid;
  Users currentUserInfo = await AssistantMethods.getCurrentOnlineUser(userId);
  return currentUserInfo;
}

class _CreatePostContainerState extends State<CreatePostContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      height: 120.0,
      color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      child: FutureBuilder(
        future: getCurrentUserInfo(),
        builder: (BuildContext context, AsyncSnapshot<Users> snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            Users user = snapshot.data!;
            return Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: user.user_id!,)));
                      },
                      child: CircleAvatar(
                        radius: 20.0,
                        backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                        backgroundImage: ExtendedNetworkImageProvider(
                          user.user_profileimage!,
                          cache: true,
                          cacheRawData: true,
                          cacheKey: user.user_id!
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0,),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.black,
                          backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#e9ecef"),
                          side: BorderSide(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:HexColor("#ced4da"), width: 0.3),
                          //shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),

                        ),

                        onPressed: () => Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const CreatePost(isSelectMedia: false,isSelectExpression: false))),
                        child: Text("Share your thoughts " + user.user_firstname!, style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                        ),
                          ),
                      ),

                      /*new InkWell(
                    onTap: ()
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CreatePost()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: HexColor("#e9ecef"),
                        border: Border.all(
                          width: 1.0,
                          color: HexColor("#dddddd"),
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: TextField(
                        decoration: InputDecoration.collapsed(
                            hintText: ("Post something "),
                          ),

                        readOnly: true,
                      ),
                    ),
                  ),*/
                    ),
                  ],
                ),
                const SizedBox(height: 8.0,),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            displayToastMessage("This feature is currently under development.", context);
                            //Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: AgoraLive()));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                              ShaderMask(
                                shaderCallback: (rect) => Palette.createStoryGradient.createShader(rect),
                                  child: const Icon(
                                    IconData(0xe924, fontFamily: "icomoon"),
                                    color: Colors.red,
                                    size: 18.0,
                                  ),
                                ),
                                const Text('Go live', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5.0,),
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const CreatePost(isSelectMedia: true, isSelectExpression: false)));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ShaderMask(
                                  shaderCallback: (rect) => Palette.createStoryGradient.createShader(rect),
                                  child: const Icon(
                                    IconData(0xe92e, fontFamily: "icomoon"),
                                    color: Colors.yellow,
                                    size: 18.0,
                                  ),
                                ),
                                const Text('Media', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5.0,),
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const CreatePost(isSelectMedia: false, isSelectExpression: true,)));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[100]!,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ShaderMask(
                                  shaderCallback: (rect) => Palette.createStoryGradient.createShader(rect),
                                  child: const Icon(
                                    IconData(0xe910, fontFamily: "icomoon"),
                                    color: Colors.blueGrey,
                                    size: 18.0,
                                  ),
                                ),
                                const Text('Expression', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }else{
            return Column(
              children: [
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                      highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                      child: CircleAvatar(
                        radius: 20.0,
                        backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                      ),
                    ),
                    const SizedBox(width: 8.0,),
                    Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                        child: Container(
                          height: 20.0,
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        ),
                      ),
                    ),
                  ],
                ),
                //const Divider(height: 10.0, thickness: 0.5,),
                const SizedBox(height: 8.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                        child: Container(
                          height: 30.0,
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0,),
                    Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                        child: Container(
                          height: 30.0,
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0,),
                    Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                        child: Container(
                          height: 30.0,
                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        }
      ),
    );
  }
}
