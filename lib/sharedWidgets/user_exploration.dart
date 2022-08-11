import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:provider/provider.dart';
class UserExploration extends StatefulWidget {
  final Users user;
  const UserExploration({
    Key? key,
    required this.user
  }) : super(key: key);

  @override
  _UserExplorationState createState() => _UserExplorationState();
}

class _UserExplorationState extends State<UserExploration> {
  //initialize google map
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  //define location
  late Position currentPosition;

  //google map function to get your location coordinates
  var geoLocator = Geolocator();

  Set<Circle> circlesSet = {};

  Set<Marker> markersSet = {};

  //show your current location
  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 18);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));




    Circle locationCircle = Circle(
      fillColor: Colors.green,
      center: latLngPosition,
      radius: 20,
      strokeWidth: 2,
      strokeColor: Colors.greenAccent,
      circleId: const CircleId("Place visited"),
    );



     circlesSet.add(locationCircle);

    //address = await AssistantMethods.searchCoordinateAddress(position, context);
    //print("Your current address is ::"+ address);
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  int selectedIndex = 0;
  final List<String> places = ["Places visited", "Where you want to go"];

  String? _darkMapStyle;
  String? _lightMapStyle;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadMapStyles();
    //AssistantMethods.getPlacesVisited(context, widget.user.user_id!);
  }

  Future _setMapStyle() async {
    if (Provider.of<AppData>(context).darkTheme)
      newGoogleMapController.setMapStyle(_darkMapStyle);
    else
      newGoogleMapController.setMapStyle(_lightMapStyle);
  }

  Future _loadMapStyles() async {
    _darkMapStyle  = await rootBundle.loadString('map_styles/dark.json');
    _lightMapStyle = await rootBundle.loadString('map_styles/light.json');
    _setMapStyle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leading: IconButton(
          icon: const Icon(Icons.close),
          //iconSize: 36.0,
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Travel & Culture",
          style: TextStyle(
            color: Colors.white,
            //fontSize: 22.0,
            //fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            //iconSize: 36.0,
            color: Colors.white,
            onPressed: (){},
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(bottom: 150),
            mapType: MapType.normal,
            //myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            //zoomGesturesEnabled: true,
            //zoomControlsEnabled: true,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              locatePosition();

              setState(() {
                getVisitedPlacesLocation();
              });
            },

          ),
          Positioned(
            top: 15.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: 60.0,
              color: Colors.transparent,
              child: Center(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: places.length,
                  itemBuilder: (BuildContext context, int index){
                    return InkWell(
                      onTap: (){
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.only(right: 5.0),
                          decoration: Provider.of<AppData>(context).darkTheme?BoxDecoration(
                            color: index == selectedIndex ? Palette.kuungaaDefault : Palette.mediumDarker,
                            borderRadius: BorderRadius.circular(25.0),
                          ):BoxDecoration(
                            color: index == selectedIndex ? Palette.kuungaaDefault : Colors.white,
                            borderRadius: BorderRadius.circular(25.0),
                          ),

                          child: Text(
                            places[index],
                            style: Provider.of<AppData>(context).darkTheme?TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ):TextStyle(
                              color: index == selectedIndex ? Colors.white : Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: 170.0,
              decoration: BoxDecoration(
                color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
                boxShadow: [
                  BoxShadow(
                    color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: const Offset(0.7, 0.7),
                  )
                ],
              ),
              child: FutureBuilder(
                future: getVisitedPlaces(),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasData){
                      return ListView.builder(
                        /*addAutomaticKeepAlives: true,
                        addRepaintBoundaries: true,
                        addSemanticIndexes: true,*/
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index){
                          Posts post = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Container(
                              height: double.infinity,
                              width: 120.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Provider.of<AppData>(context).darkTheme?Palette.lessMediumDarker:Colors.grey[100]!,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Column(
                                  children: [
                                    ExtendedImage.asset(
                                      'icons/flags/png/' + post.post_countrycode!.toLowerCase() + '.png', package: 'country_icons',
                                      height: 60.0,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        topRight: Radius.circular(5.0),
                                      ),
                                    ),
                                    SizedBox(height: 4.0,),
                                    Center(
                                      child: Text(
                                        post.post_countryname!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 4.0,),
                                    Expanded(
                                      child: Center(
                                        child: Text("12 places"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //child: post.post_privacy == "off"? Text(post.post_city! + ", " + post.post_countryname!) : Text(post.post_finelocation!),
                            ),
                          );
                        },
                      );
                    }else{
                      return const Align(
                        alignment: Alignment.center,
                        child: Text("No posts yet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),),
                      );
                    }
                  }else{
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getVisitedPlacesLocation()  {
    final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts')
        .orderByChild('poster_id').equalTo(widget.user.user_id!);
    //allPosts.clear();
     query.once().then((event) async{

      if(event.exists){

        var keys = event.value.keys;

        for (var key in keys)
        {

          final DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(key).child("post_location");
           await dbReference.once().then((DataSnapshot snapshot){
            if(snapshot.exists){
              Posts post = Posts();

              post.latitude = snapshot.value["latitude"];
              post.longitude = snapshot.value["longitude"];
              post.locationaddress = snapshot.value["locationaddress"];

              var locationLatLng = LatLng(post.latitude!, post.longitude!);

              Circle locationCircle = Circle(
                fillColor: Palette.kuungaaAccent,
                center: locationLatLng,
                radius: 20,
                strokeWidth: 2,
                strokeColor: Palette.kuungaaDefault,
                circleId: const CircleId("Place visited"),
              );

              Marker locationMarker = Marker(
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                infoWindow: InfoWindow(title: post.locationaddress, snippet: "Place location"),
                position: locationLatLng,
                markerId: const MarkerId("Place visited"),
              );

              markersSet.add(locationMarker);
              circlesSet.add(locationCircle);


            }
          });
        }
      }
    });

  }

  Future<List> getVisitedPlaces() async{
    List<Posts> visitedPlaces = [];

    final Query query = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Posts')
        .orderByChild('poster_id').equalTo(widget.user.user_id);
    //allPosts.clear();
    await query.once().then((event) async{

      if(event.exists){
        
        var keys = event.value.keys;
        var values = event.value;
        //Posts post = Posts.fromSnapshot(event.snapshot);
        //allPosts.add(post);
        // servicesList.add(userServices!);
        for (var key in keys)
        {

          final DatabaseReference dbReference = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Posts").child(key).child("post_location");
          await dbReference.once().then((DataSnapshot snapshot){
            if(snapshot.exists){
              Posts post = Posts();
              post.post_id = values [key]["post_id"];
              post.post_description = values [key]["post_description"];
              post.post_time = values [key]["post_time"];
              post.poster_id = values [key]["poster_id"];
              post.post_privacy = values [key]["post_privacy"];
              post.post_city = values [key]["post_city"];
              post.post_countryname = values [key]["post_countryname"];
              post.post_countrycode = values [key]["post_countrycode"];
              post.post_finelocation = values [key]["post_finelocation"];
              post.post_travelcategory = values [key]["post_travelcategory"];

              post.latitude = snapshot.value["latitude"];
              post.longitude = snapshot.value["longitude"];
              post.locationaddress = snapshot.value["locationaddress"];

              visitedPlaces.add(post);
              //print("getting posts :: "+ post.post_time!.toString());
            }
          });
        }
      }
    });
    return visitedPlaces.reversed.toList();
  }
}
