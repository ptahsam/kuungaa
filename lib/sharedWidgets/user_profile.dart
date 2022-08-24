import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/allScreens/screens.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
class UserProfile extends StatefulWidget {
  final String userid;
  const UserProfile({
    Key? key,
    required this.userid
  }) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  //initialize google map
  //Completer<GoogleMapController> _controllerGoogleMap = Completer();
  //late GoogleMapController newGoogleMapController;


  //define location
  //late Position currentPosition;

  //google map function to get your location coordinates
  //var geoLocator = Geolocator();

  //show your current location
  /*void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 2);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //address = await AssistantMethods.searchCoordinateAddress(position, context);
    //print("Your current address is ::"+ address);
  }*/

  /*static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );*/

  stateSetter(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      body: FutureBuilder(
        future: getUserInfo(widget.userid),
        builder: (BuildContext context, AsyncSnapshot<Users> snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData){
              Users user = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    shadowColor: Colors.transparent,
                    backgroundColor: Palette.kuungaaDefault,
                    title: Text(user.user_firstname! + " " + user.user_lastname!,
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
                        background: user.user_coverimage != ""? Stack(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ExtendedImage.network(
                                user.user_coverimage!,
                                fit: BoxFit.cover,
                                height: 250.0,
                              ),
                            ),
                            Positioned(
                              bottom: 10.0,
                              right: 12.0,
                              child: user.user_id == userCurrentInfo!.user_id!? InkWell(
                                onTap: (){
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UploadUserPhoto(user: user, type: 'cover',)));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[300]!,
                                  ),
                                  child: Icon(
                                    MdiIcons.cameraImage,
                                    color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                                  ),
                                ),
                              ): const SizedBox.shrink(),
                            ),
                          ],
                        ) : //Image.asset("images/cover_bg.jpg", fit: BoxFit.cover,),
                      Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Palette.kuungaaDefault,
                            ),
                          ),
                          user.user_id == userCurrentInfo!.user_id!? Positioned(
                            bottom: 10.0,
                            right: 12.0,
                            child: InkWell(
                              onTap: (){
                                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UploadUserPhoto(user: user, type: 'cover',)));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[300]!,
                                ),
                                child: Icon(
                                  MdiIcons.cameraImage,
                                  color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                                ),
                              ),
                            ),
                          ): const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    leading: InkWell(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28.0,
                      ),
                    ),
                    actions: [
                      user.user_id == userCurrentInfo!.user_id!? InkWell(
                        onTap: (){
                           showModalBottomSheet(
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                            ),
                            context: context,
                            builder: (context) => buildMoreOptionsSheet(),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 28.0,
                          ),
                        ),
                      ) : const SizedBox.shrink(),
                    ],
                  ),
                  SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                        color: Palette.kuungaaDefault,
                        child: ListTile(
                          leading: SizedBox(
                            height: 60.0,
                            width: 60.0,
                            child: Stack(
                              children: [
                                ProfileAvatar(imageUrl: user.user_profileimage!, radius: 28.0,),
                                user.user_id == userCurrentInfo!.user_id!? Positioned(
                                  bottom: 0.0,
                                  right: 0.0,
                                  child: InkWell(
                                    onTap: (){
                                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UploadUserPhoto(user: user, type: 'profile',)));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[300]!,
                                      ),
                                      child: Icon(
                                        MdiIcons.cameraAccount,
                                        color:Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,
                                      ),
                                    ),
                                  ),
                                ) : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          title: Text(user.user_firstname! + " " + user.user_lastname!, style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          //subtitle: Text(user.friend_count == 0? "No friends" : user.friend_count!.toString() + " friends"),
                            trailing: user.user_id == userCurrentInfo!.user_id!? InkWell(
                              onTap: (){
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                                  ),
                                  context: context,
                                  builder: (context) => buildMoreOptionsSheet(),
                                );
                              },
                              child: const Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                          ),
                            ): const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  user.user_id == userCurrentInfo!.user_id!?
                   const SliverToBoxAdapter(child: SizedBox.shrink())
                   :
                  SliverToBoxAdapter(
                    child: FutureBuilder(
                      future: checkUserFriendStatus(user.user_id!),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                        if(snapshot.connectionState == ConnectionState.done){
                          if(snapshot.hasData){
                            String status = snapshot.data!;
                            if(status == "is_friend"){
                              return Container(
                                padding: const EdgeInsets.only(left: 12.0, top: 10.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            unFriend(widget.userid, stateSetter);
                                            // Respond to button press
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200]!,
                                          ),
                                          icon: Icon(FontAwesomeIcons.userMinus, size: 18, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,),
                                          label: Text("Unfriend", style: TextStyle(color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,),),
                                        ),
                                        const SizedBox(width: 6.0,),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            // Respond to button press
                                            startMessegeUser(context, user.user_id!);
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.green,

                                          ),
                                          icon: const Icon(MdiIcons.message, size: 18, color: Colors.white,),
                                          label: const Text("Message", style: TextStyle(color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                    /*Expanded(
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.more_horiz,
                                          color: Colors.black,
                                        ),
                                        onPressed: (){

                                        },
                                      ),
                                    ),*/
                                  ],
                                ),
                              );
                            }else if(status == "requesting"){
                              return Container(
                                padding: const EdgeInsets.only(left: 12.0, top: 10.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            declineFriend(widget.userid, context, stateSetter);
                                            // Respond to button press
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          icon: const Icon(FontAwesomeIcons.userSlash, size: 18, color: Colors.white,),
                                          label: const Text("Cancel", style: TextStyle(color: Colors.white,),),
                                        ),
                                        const SizedBox(width: 6.0,),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            // Respond to button press
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.green,

                                          ),
                                          icon: const Icon(MdiIcons.message, size: 18, color: Colors.white,),
                                          label: const Text("Message", style: TextStyle(color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                    /*Expanded(
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.more_horiz,
                                          color: Colors.black,
                                        ),
                                        onPressed: (){

                                        },
                                      ),
                                    ),*/
                                  ],
                                ),
                              );
                            }else if(status == "requested"){
                              return Container(
                                padding: const EdgeInsets.only(left: 12.0, top: 10.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            acceptFriend(widget.userid, context, stateSetter);
                                            // Respond to button press
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Palette.kuungaaDefault,
                                          ),
                                          icon: const Icon(FontAwesomeIcons.userPlus, size: 18, color: Colors.white,),
                                          label: const Text("Accept", style: TextStyle(color: Colors.white,),),
                                        ),
                                        const SizedBox(width: 6.0,),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            declineFriend(widget.userid, context, stateSetter);
                                            // Respond to button press
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          icon: const Icon(FontAwesomeIcons.userAltSlash, size: 18, color: Colors.white,),
                                          label: const Text("Decline", style: TextStyle(color: Colors.white,),),
                                        ),
                                        const SizedBox(width: 6.0,),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            // Respond to button press
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.green,

                                          ),
                                          icon: const Icon(MdiIcons.message, size: 18, color: Colors.white,),
                                          label: const Text("Message", style: TextStyle(color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                    /*Expanded(
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.more_horiz,
                                          color: Colors.black,
                                        ),
                                        onPressed: (){

                                        },
                                      ),
                                    ),*/
                                  ],
                                ),
                              );
                            }else{
                              return Container(
                                padding: const EdgeInsets.only(left: 12.0, top: 10.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            addFriend(widget.userid, context, stateSetter);
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                          ),
                                          icon: const Icon(Icons.add, size: 18, color: Colors.white,),
                                          label: const Text("Add Friend", style: TextStyle(color: Colors.white,),),
                                        ),
                                        const SizedBox(width: 6.0,),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            // Respond to button press
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.green,

                                          ),
                                          icon: const Icon(MdiIcons.message, size: 18, color: Colors.white,),
                                          label: const Text("Message", style: TextStyle(color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                    /*const Expanded(
                                      child: Icon(
                                        Icons.more_horiz,
                                        color: Colors.black,
                                      ),
                                    ),*/
                                  ],
                                ),
                              );
                            }
                          }else{
                            return const Center(
                              child: Text("An error occured.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),),
                            );
                          }
                        }else{
                          return Container(
                            padding: const EdgeInsets.only(left: 12.0, top: 10.0, bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
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
                                      const SizedBox(width: 6.0,),
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
                                ),
                                Expanded(
                                  child: Shimmer.fromColors(
                                    baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                    highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                    child: Container(
                                      height: 20.0,
                                      width: 40.0,
                                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 1.0,
                      width: MediaQuery.of(context).size.width,
                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserAbout(user: user,)));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: user.user_id == userCurrentInfo!.user_id!? Text("Learn more about yourself", style: TextStyle(color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54, fontSize: 16, ),) : Text("Learn more about "+ user.user_firstname!, style: TextStyle(color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54, fontSize: 16, )),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              size: 24.0,
                              color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child:  FutureBuilder(
                      future: getUserPhotos(user.user_id!),
                      builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                        if(snapshot.connectionState == ConnectionState.done){
                          if(snapshot.hasData){
                            if(snapshot.data!.isNotEmpty){
                              return Stack(
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    height: 200,
                                    margin: const EdgeInsets.fromLTRB(0.0, 20, 0.0, 10),
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                            width: 1
                                        ),
                                        bottom: BorderSide(
                                            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                            width: 1
                                        ),
                                      ),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                                      itemCount: snapshot.data!.length,
                                      scrollDirection: Axis.horizontal,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (BuildContext context, index){
                                        Media media = snapshot.data![index];
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 5.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(5.0),
                                            child: ExtendedImage.network(
                                              media.url!,
                                              height: double.infinity,
                                              width: 120.0,
                                              cache: true,
                                             // cacheWidth: 500,
                                              //cacheHeight: 500,
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.high,
                                              cacheRawData: true,
                                              enableMemoryCache: true,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                      left: 12,
                                      top: 12,
                                      child: Container(
                                        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                        color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                                        child: Text(user.user_id == userCurrentInfo!.user_id!?
                                        'Photos of you' : user.user_firstname! + "'" + "s" + " photos",
                                          style: TextStyle(color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black, fontSize: 14),
                                        ),
                                      )
                                  ),
                                  InkWell(
                                    onTap: (){
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: ViewUserPhotos(user: user, userMedia: snapshot.data!,)));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 200.0,
                                      margin: const EdgeInsets.fromLTRB(0.0, 20, 0.0, 10),
                                      padding: const EdgeInsets.only(bottom: 5.0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: const BorderSide(
                                              color: Colors.transparent,
                                              width: 1
                                          ),
                                          bottom: BorderSide(
                                              color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                              width: 1
                                          ),
                                        ),
                                        shape: BoxShape.rectangle,
                                        gradient: Palette.createPhotoGradient,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: Text("See more", style: TextStyle(color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black),),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }else{
                              return const SizedBox.shrink();
                            }
                          }else{
                            return const SizedBox.shrink();
                          }
                        }else{
                          return
                            SizedBox(
                              width: double.infinity,
                              height: 200,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                                itemCount: 12,
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, index){
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: Shimmer.fromColors(
                                      baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                      highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                      child: Container(
                                        height: double.infinity,
                                        width: 120.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5.0),
                                          color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          );
                        }
                      }
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                      child: FutureBuilder(
                        future: getUserFriends(user.user_id!),
                        builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                          if(snapshot.connectionState == ConnectionState.done){
                            if(snapshot.hasData){
                              if(snapshot.data!.isNotEmpty){
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Friends" " " + snapshot.data!.length.toString()),
                                          InkWell(
                                            onTap: (){
                                              if(user.user_id == userCurrentInfo!.user_id!){
                                                Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const NavScreen(isNavigate: true, sendIndex: 4,)));
                                              }else{
                                                Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: ViewUserFriends(user: user,)));
                                              }
                                            },
                                            child: const Text("View all"),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15.0,),
                                      SizedBox(
                                        height: 180.0,
                                        child: GridView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: snapshot.data!.length,
                                            physics: const NeverScrollableScrollPhysics(),
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, childAspectRatio: 1 / 3, mainAxisSpacing: 2.0),
                                            itemBuilder: (BuildContext context, int index){
                                              if(index < 3){
                                                Users user = snapshot.data![index];
                                                return InkWell(
                                                  onTap: (){
                                                    Navigator.pop(context);
                                                    Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: UserProfile(userid: user.user_id!,)));
                                                  },
                                                  child: SizedBox(
                                                    height: 150.0,
                                                    child: Column(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          child: ExtendedImage.network(
                                                            user.user_profileimage!,
                                                            height: 120.0,
                                                            cache: true,
                                                            enableMemoryCache: true,
                                                            cacheRawData: true,
                                                            //cacheHeight: 500,
                                                            //cacheWidth: 500,
                                                            width: double.infinity,
                                                            fit: BoxFit.cover,
                                                            filterQuality: FilterQuality.high,
                                                          ),
                                                        ),
                                                        ListTile(
                                                          title: Text(user.user_firstname! + " " + user.user_lastname!),
                                                          subtitle: Text("Friends" " " + user.friend_count!.toString()),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }else{
                                                return const SizedBox.shrink();
                                              }
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }else{
                                return const SizedBox.shrink();
                              }
                            }else{
                              return const Center(
                                child: Text("No friends yet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),),
                              );
                            }
                          }else{
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
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
                                      const SizedBox(width: 6.0,),
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
                                  const SizedBox(height: 15.0,),
                                  SizedBox(
                                    height: 180.0,
                                    child: GridView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: 3,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, childAspectRatio: 1 / 3, mainAxisSpacing: 2.0),
                                        itemBuilder: (BuildContext context, int index){

                                          return SizedBox(
                                            height: 150.0,
                                            child: Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  child: Shimmer.fromColors(
                                                    baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                                    highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                                    child: Container(
                                                      height: 120.0,
                                                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                                    ),
                                                  ),
                                                ),
                                                ListTile(
                                                  title: Shimmer.fromColors(
                                                    baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                                    highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                                    child: Container(
                                                      height: 20.0,
                                                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                                    ),
                                                  ),
                                                  subtitle: Shimmer.fromColors(
                                                    baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                                    highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
                                                    child: Container(
                                                      height: 15.0,
                                                      color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                        }
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        Container(
                          //height: 200.0,
                          margin: const EdgeInsets.fromLTRB(0.0, 20, 0.0, 10),
                          padding: const EdgeInsets.only(bottom: 5.0),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                  color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                                  width: 1
                              ),
                              bottom: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1
                              ),
                            ),
                            shape: BoxShape.rectangle,
                            //gradient: Palette.createPhotoGradient,
                          ),
                          child: Column(
                            children: [
                              const ListTile(
                                leading: Icon(MdiIcons.googleMaps, size: 26.0,),
                                title: Text('Explored places'),
                                /*subtitle: Text(
                                  'Secondary Text',
                                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                ),*/
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: user.user_id == userCurrentInfo!.user_id!?Text(
                                  'See places you have been and places you wish to go',
                                  style: TextStyle(color: Provider.of<AppData>(context).darkTheme?Colors.white.withOpacity(0.6):Colors.black.withOpacity(0.6)),
                                ): Text(
                                  'See ' + user.user_firstname! + "'" + "s" + " exploration",
                                  style: TextStyle(color: Provider.of<AppData>(context).darkTheme?Colors.white.withOpacity(0.6):Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              ButtonBar(
                                alignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FlatButton(
                                    textColor: Palette.kuungaaDefault,
                                    onPressed: () {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserExploration(user: user,)));
                                    },
                                    child: const Text('Start now'),
                                  ),
                                  FlatButton(
                                    textColor: Palette.kuungaaDefault,
                                    onPressed: () {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserExploration(user: user,)));
                                    },
                                    child: const Text('View map'),
                                  ),
                                ],
                              ),
                              //Image.asset('assets/card-sample-image.jpg'),
                              //Image.asset('assets/card-sample-image-2.jpg'),
                            ],
                          ),
                        ),
                        Positioned(
                            left: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                              color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                              child: Text("Travel & Culture",
                                style: TextStyle(color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black, fontSize: 14),
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                  /*SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Travel"),
                                ],
                              ),
                            ),
                            SizedBox(height: 15.0,),
                            Container(
                              height: 280.0,
                              child: GoogleMap(
                                //padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                                mapType: MapType.normal,
                                myLocationButtonEnabled: true,
                                initialCameraPosition: _kGooglePlex,
                                myLocationEnabled: true,
                                zoomGesturesEnabled: true,
                                zoomControlsEnabled: true,
                                //polylines: polylineSet,
                                //markers: markersSet,
                                //circles: circlesSet,
                                onMapCreated: (GoogleMapController controller)
                                {
                                  _controllerGoogleMap.complete(controller);
                                  newGoogleMapController = controller;
                                  locatePosition();
                                },

                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),*/
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,)
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(user.user_id == userCurrentInfo!.user_id!?
                              'Your posts' : user.user_firstname! + "'" + "s" + " posts", style: const TextStyle(fontWeight: FontWeight.bold),),
                            ),

                            Expanded(
                                child: Divider(color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!)
                            ),
                          ]
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                        [
                          Container(
                              constraints: BoxConstraints(
                                maxHeight: double.infinity,
                              ),
                              child: SingleUserPostContainer(user_id: user.user_id!),
                          ),
                        ]
                    ),
                  ),
                ],
              );
            }else{
              return const Center(
                child: Text("An error occured.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),),
              );
            }
          }else{
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

 Future<String> getUserFriendsNo(userid) async {
   String? countFriends;
   Query friendCountRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Friends").child(userid).orderByKey();
   await friendCountRef.once().then((DataSnapshot count){
     int friendCount = 0;
     if(count.exists){
       var zees = count.value.keys;
       var data = count.value;
       for(var zee in zees)
       {
         if(data [zee]["status"] == "confirmed"){
           friendCount = friendCount + 1;
         }
       }
     }
     countFriends = friendCount.toString();
   });
   return countFriends!;
 }

 Future<Users> getUserInfo(userid) async {
   Users userInfo = await AssistantMethods.getCurrentOnlineUser(userid);
   return userInfo;
 }

  Widget buildAccountSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ListTile(
              onTap: (){
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, LoginPage.idScreen, (route) => false);
                displayToastMessage("Logging you out....please wait.", context);
              },
              //tileColor: Colors.grey[300]!,
              leading: Container(
                margin: const EdgeInsets.all(6.0),
                decoration: const BoxDecoration(
                  //color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: ShaderMask(
                    shaderCallback: (rect) => Palette.createIconGradient.createShader(rect),
                    child: const Icon(
                      MdiIcons.account,
                      color: Colors.green,
                    ),
                  ),
                  iconSize: 22.0,
                  onPressed: () => {},
                ),
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: const Icon(
                Icons.keyboard_arrow_right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List> getUserPhotos(String userid) async{
    List<Media> photoMediaList = [];
    final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts')
        .orderByChild('poster_id').equalTo(userid);
    await query.once().then((event) async {
      if(event.exists){
        var keys = event.value.keys;
        for (var key in keys)
        {
          final DatabaseReference mediaReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(key).child("post_media");

          await mediaReference.once().then((DataSnapshot snapshotPosts){
            if(snapshotPosts.value != ""){
              for(var i in snapshotPosts.value){
                Media media = Media.fromJson(Map<String, dynamic>.from(i));
                if(media.type!.contains("image")){
                  photoMediaList.add(media);
                }
              }
            }
          });
        }
      }
    });
    return photoMediaList.reversed.toList();
  }

  Widget buildMoreOptionsSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          InkWell(
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const UserSaved()));

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
                      FontAwesomeIcons.folderOpen,
                      color: Colors.green,
                    ),
                    iconSize: 22.0,
                    onPressed: () => {},
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Saved Items",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: const UserSettings()));

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
                      FontAwesomeIcons.userCog,
                      color: Colors.green,
                    ),
                    iconSize: 22.0,
                    onPressed: () => {},
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, LoginPage.idScreen, (route) => false);
              displayToastMessage("Logging you out....please wait.", context);
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
                      MdiIcons.logout,
                      color: Colors.red,
                    ),
                    iconSize: 22.0,
                    onPressed: () => {},
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.red,
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

