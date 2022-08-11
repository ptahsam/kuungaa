import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kuungaa/Assistants/assistantMethods.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
class PostLocation extends StatefulWidget {
  const PostLocation({Key? key}) : super(key: key);

  @override
  _PostLocationState createState() => _PostLocationState();
}

class _PostLocationState extends State<PostLocation> {

  late Position currentPosition;
  var geoLocator = Geolocator();
  String address = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locatePosition();
  }

  //show your current location
  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    address = await AssistantMethods.searchCoordinateAddress(position, context);
  }

  bool toggleValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            flex: 2,
            child: Container(
              height: 100.0,
              decoration: BoxDecoration(
                color: Provider.of<AppData>(context).darkTheme?Palette.darker:Colors.white,
                /*boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 1.0,
                    spreadRadius: 0.1,
                    offset: Offset(0.1, 0.1),
                  ),
                ],*/
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 40.0, right: 12.0,bottom: 0.0),
                child: Column(
                  children: [
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap:()
                              {
                                Navigator.pop(context, toggleValue);
                              },
                              child: const Icon(
                                  Icons.arrow_back
                              ),
                            ),
                            const SizedBox(width: 10.0,),
                            const Text("Add post location", style: TextStyle(fontSize: 18.0,),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Show street address in your post", style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 12.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      MdiIcons.mapMarkerCheckOutline,
                    ),
                    Text(Provider.of<AppData>(context).userCurrentLocation != null?
                        Provider.of<AppData>(context).userCurrentLocation!.placeFormattedAddress! : ""
                    ),
                    const SizedBox(width: 8.0,),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(microseconds: 1000),
                        height: 40.0,
                        width: 90.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: toggleValue ? Colors.green[100] : Colors.blueAccent[100]!.withOpacity(0.5),
                         ),
                        child: Stack(
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeIn,
                              top: 3.0,
                              left: toggleValue ? 0.0 : 0.0,
                              right: toggleValue ? 0.0 : 0.0,
                              child: InkWell(
                                onTap: toggleButton,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 1000),
                                  transitionBuilder: (Widget child, Animation<double> animation){
                                    return ScaleTransition(
                                      child: child,
                                      scale: animation,
                                    );
                                  },
                                  child: toggleValue ? Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Row(
                                      children: [
                                        const Text("On", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                                        const SizedBox(width: 8.0,),
                                        Icon(MdiIcons.mapMarkerCheckOutline, color: Colors.green, size: 35.0, key: UniqueKey(),
                                        ),
                                      ],
                                    ),
                                  ) : Padding(
                                    padding: const EdgeInsets.only(left: 2.0),
                                    child: Row(
                                      children: [
                                        Icon(MdiIcons.mapMarkerOffOutline, color: Colors.red, size: 35.0, key: UniqueKey()),
                                        const SizedBox(width: 8.0,),
                                        const Expanded(child: Text("Off", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  toggleButton(){
    setState(() {
      toggleValue = !toggleValue;
    });
  }
}
