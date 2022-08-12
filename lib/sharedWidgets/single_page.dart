import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/page.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'widgets.dart';

class SinglePage extends StatefulWidget {
  final Kpage kpage;
  const SinglePage({
    Key? key,
    required this.kpage
  }) : super(key: key);

  @override
  _SinglePageState createState() => _SinglePageState();
}

class _SinglePageState extends State<SinglePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      body: DefaultTabController(
        length: 2,
        child:  NestedScrollView(
            scrollDirection: Axis.vertical,
            headerSliverBuilder: (context, bool s) => [

              SliverAppBar(
                systemOverlayStyle: SystemUiOverlayStyle.light,
                shadowColor: Colors.transparent,
                backgroundColor: Palette.kuungaaDefault,
                title: Text(widget.kpage.page_name!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    )
                ),
                centerTitle: false,
                floating: true,
                automaticallyImplyLeading: true,
                snap: true,
                elevation: 40.0,
                pinned: true,
                expandedHeight: 200.0,
                flexibleSpace: FlexibleSpaceBar(
                    background: ExtendedImage.network(
                      widget.kpage.page_icon!,
                      fit: BoxFit.cover,
                    )
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      //size: 28.0,
                    ),
                    iconSize: 22.0,
                    onPressed: () => {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                        ),
                        context: context,
                        builder: (context) => buildPagePostSheet(widget.kpage),
                      ),
                    },
                  )
                ],
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    padding: EdgeInsets.zero,
                    indicator: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white,
                          width: 3.0,

                        ),
                      ),
                      //borderRadius: BorderRadius.circular(5.0),
                    ),
                    tabs: [
                      Tab(
                        child: Center(
                          child: Text("Discussion", style: TextStyle(color: HexColor("#ffffff"),),),
                        ),

                      ),
                      /*Tab(
                        child: Center(
                          child: Text("Followers", style: TextStyle(color: HexColor("#ffffff"),),),
                        ),
                      ),*/
                      Tab(
                        child: Center(
                          child: Text("About", style: TextStyle(color: HexColor("#ffffff"),),),
                        ),
                      ),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ],
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CustomScrollView(
                  slivers: [

                    SliverList(
                      delegate: SliverChildListDelegate(
                          [
                            SinglePagePost(pageid: widget.kpage.page_id!,),
                          ]
                      ),
                    ),
                  ],
                ),

                /*const CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(top: 10.0),
                      sliver: SliverToBoxAdapter(
                        //child: GroupMembers(groupid: widget.groupid,),
                      ),
                    ),
                  ],
                ),*/
                CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(top: 10.0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            ListTile(
                              leading: ProfileAvatar(
                                imageUrl: widget.kpage.creator!.user_profileimage!,
                                radius: 10.0,
                              ),
                              title: Row(
                                children: [
                                  Text(widget.kpage.creator!.user_firstname! + " " + widget.kpage.creator!.user_lastname!),
                                ],
                              ),
                              subtitle: Text(
                                "Owner",
                                style: TextStyle(
                                  color: Palette.kuungaaDefault
                                ),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(
                                  MdiIcons.book
                              ),
                              title: const Text("Topic"),
                              subtitle: Text(widget.kpage.page_category!),
                            ),
                            ListTile(
                              leading: const Icon(
                                  MdiIcons.information
                              ),
                              title: const Text("Description"),
                              subtitle: Text(widget.kpage.page_description!),
                            ),
                            ListTile(
                              leading: const Icon(
                                  MdiIcons.history
                              ),
                              title: const Text("Page history"),
                              subtitle: Text("Created on " + convertToRealDate(widget.kpage.page_createddate!)),
                            ),
                          ],
                        ),
                        //child: GroupMembers(groupid: widget.groupid,),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ),
    );
  }

  Widget buildPagePostSheet(Kpage kpage) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.kpage.page_creator != userCurrentInfo!.user_id?FutureBuilder(
            future: checkPageUserIsMember(kpage.page_id!),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot){
              if(snapshot.hasData){
                return snapshot.data! == true? InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    DatabaseReference pRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Pages").child(widget.kpage.page_id!).child("members");
                    pRef.child(userCurrentInfo!.user_id!).remove().then((value){
                      displayToastMessage("You have unliked this page", context);
                      setState(() {

                      });
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.thumb_down_alt_outlined,
                            color: Colors.red,
                          ),
                          iconSize: 22.0,
                          onPressed: () => {},
                        ),
                      ),
                      SizedBox(width: 14.0,),
                      Text(
                        "Unlike page",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.red
                        ),
                      ),
                    ],
                  ),
                ) : InkWell(
                  onTap: () async {

                    Navigator.pop(context);
                    DatabaseReference pRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Pages").child(widget.kpage.page_id!).child("members");
                    pRef.child(userCurrentInfo!.user_id!).set(userCurrentInfo!.user_id!).then((onValue) {
                      displayToastMessage("You have liked this page", context);
                      setState(() {

                      });
                    }).catchError((onError) {
                      displayToastMessage("An error occurred. Please try again later", context);
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: ShaderMask(
                            shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                            child: Icon(
                              Icons.thumb_up_alt_outlined,
                              color: Colors.green,
                            ),
                          ),
                          iconSize: 22.0,
                          onPressed: () => {},
                        ),
                      ),
                      SizedBox(width: 14.0,),
                      Text(
                        "Like page",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.green
                        ),
                      ),
                    ],
                  ),
                );
              }else{
                return Center(child: CircularProgressIndicator());
              }
            },
          ):SizedBox.shrink(),
          widget.kpage.page_creator == userCurrentInfo!.user_id?InkWell(
            onTap: () async {
              Navigator.pop(context);
              var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreatePagePost(pagename: widget.kpage.page_name!, pageid: widget.kpage.page_id!,)));
              if(res != null){
                setState(() {
                  Navigator.pop(context);
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
                      Icons.add,
                      color: Colors.green,
                    ),
                    iconSize: 22.0,
                    onPressed: (){

                    },
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Create a page post",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ):SizedBox.shrink(),
          widget.kpage.page_creator == userCurrentInfo!.user_id?InkWell(
            onTap: () async {
              Navigator.pop(context);
              openDialog(context);
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
                  "Delete this page",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.red
                  ),
                ),
              ],
            ),
          ):SizedBox.shrink()
        ],
      ),
    );
  }

  Future<bool> checkPageUserIsMember(String pageid) async{
    bool userIsMember = await AssistantMethods.checkUserIsMember("Pages", pageid, userCurrentInfo!.user_id!);
    return userIsMember;
  }

  void openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete page"),
        content: Text(
            "Do you want to delete this page and all its data ?"
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deletePage();
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> deletePage() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Deleting page, Please wait...",);
        }
    );
    final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts')
        .orderByChild('post_id').equalTo(widget.kpage.page_id!);
    await query.once().then((event) async {
      if(event.exists){
        var keys = event.value.keys;
        for (var key in keys)
          {
            DatabaseReference hiddenRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Hidden");
            await hiddenRef.once().then((hiddenSnap) async {
              if(hiddenSnap.exists){
                var hiddenKeys = hiddenSnap.value.keys;
                for(var hiddenKey in hiddenKeys){
                  await hiddenRef.child(hiddenKey).child(key).once().then((hiddenPost) async {
                    if(hiddenPost.exists){
                      await hiddenRef.child(hiddenKey).child(key).remove();
                    }
                  });
                }
              }
            });

            DatabaseReference folderRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Folders");
            await folderRef.once().then((folderSnap) async {
              if(folderSnap.exists){
                var folderKeys = folderSnap.value.keys;
                for(var folderKey in folderKeys){
                  DatabaseReference saveRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Saves");
                  await saveRef.once().then((saveSnap) async {
                    if(saveSnap.exists){
                      var saveKeys = saveSnap.value.keys;
                      for(var saveKey in saveKeys){
                        await saveRef.child(saveKey).child(folderKey).child(key).once().then((savePost) async {
                          if(savePost.exists){
                            await saveRef.child(saveKey).child(folderKey).child(key).remove();
                          }
                        });
                      }
                    }
                  });
                }
              }
            });

            firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Posts").child(key);
            await ref.listAll().then((result) async {
              for (var file in result.items) {
                file.delete();
              }
              DatabaseReference postRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts').child(key);
              await postRef.remove();
            });
          }
      }
    });

    firebase_storage.Reference refPage = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Pages").child("icons").child(widget.kpage.page_id!);
    await refPage.listAll().then((result) async {
      for (var file in result.items) {
        file.delete();
      }
      DatabaseReference pageRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Pages').child(widget.kpage.page_id!);
      await pageRef.remove();
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Page deleted successfully'),
      duration: const Duration(seconds: 2),
    ));

    Navigator.pop(context);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Palette.kuungaaDefault,
        border: Border(
          bottom: BorderSide(
            color: Palette.kuungaaDefault,
            width: 0.2,

          ),
        ),
        //borderRadius: BorderRadius.circular(5.0),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
