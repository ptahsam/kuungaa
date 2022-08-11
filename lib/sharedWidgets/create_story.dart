import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/MultiManager/flick_multimanager.dart';
import 'package:kuungaa/MultiManager/flick_multiplayer.dart';
import 'package:kuungaa/allScreens/screens.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';

import 'widgets.dart';

class CreateStory extends StatefulWidget {
  const CreateStory({Key? key}) : super(key: key);

  @override
  _CreateStoryState createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {

  List<AssetEntity> assets = [];



  File? userPickedFile;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPhotoPermission();

  }

  _fetchAssets() async {
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );

    // Update the state and notify UI
    setState(() => assets = recentAssets);
  }

  void requestPhotoPermission() async{
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps != PermissionState.authorized && ps != PermissionState.limited){
      _fetchAssets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.kuungaaDefault,
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
          "Create story",
          style: TextStyle(
            color: Colors.white,
            //fontSize: 22.0,
            //fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          /*IconButton(
            icon: const Icon(Icons.search),
            //iconSize: 36.0,
            color: Colors.white,
            onPressed: (){},
          ),*/
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
                color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    // A grid view with 3 items per row
                    crossAxisCount: 3,
                    crossAxisSpacing: 1.0,
                    mainAxisSpacing: 1.0,
                  ),
                  itemCount: assets.length,
                  itemBuilder: (_, index) {
                    return AssetThumbnail(asset: assets[index]);
                  },
                ),
            ),
          ),
          Container(
            height: 150.0,
            color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.white,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: const StatusTextEditor()));
                    },
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: Palette.createStoryTextGradient,
                        borderRadius: BorderRadius.circular(5.0)
                      ),
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                                ),
                                child: Icon(MdiIcons.text, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,),
                              ),
                              const Text(
                                "Text",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4.0,),
                Expanded(
                  child: InkWell(
                    onTap: () async {

                      final cameras = await availableCameras();

                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TakePhoto(cameras: cameras)));

                      if(result != null){
                        XFile xFile = result;
                        File file = File(xFile.path);
                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: ImageScreen(imgFile: file, source: "camera",)));

                      }

                    },
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: Palette.createStoryTextGradient,
                          borderRadius: BorderRadius.circular(5.0)
                      ),
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                                ),
                                child: Icon(MdiIcons.camera, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black),
                              ),
                              const Text(
                                "Photo",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4.0,),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final cameras = await availableCameras();

                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RecordVideo(cameras: cameras)));

                      if(result != null){
                        XFile xFile = result;
                        File file = File(xFile.path);
                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: VideoScreen(vidFile: file, source: "camera",)));

                      }
                    },
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: Palette.createStoryTextGradient,
                          borderRadius: BorderRadius.circular(5.0)
                      ),
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
                                ),
                                child: Icon(MdiIcons.video, color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black,),
                              ),
                              const Text(
                                "Video",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    // We're using a FutureBuilder since thumbData is a future
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return Align(
          alignment: Alignment.center,
          child: Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: const CircularProgressIndicator(),
              ),
          )
        );
        // If there's data, display it as an image
        return InkWell(
          onTap: () {
            if (asset.type == AssetType.image) {
              Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: ImageScreen(imageFile: asset.file, source: "gallery",)));
            }else{
              Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: VideoScreen(videoFile: asset.file, source: "gallery",)));
            }

            // TODO: navigate to Image/Video screen
          },
          child: Stack(
            children: [
              // Wrap the image in a Positioned.fill to fill the space
              Positioned.fill(
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
              // Display a Play icon if the asset is a video
              if (asset.type == AssetType.video)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 0.8,
                        color: Palette.kuungaaDefault
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Palette.kuungaaDefault,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

}


class ImageScreen extends StatefulWidget {
  final Future<File?>? imageFile;
  final File? imgFile;
  final String source;

  const ImageScreen({
    Key? key,
    this.imageFile,
    this.imgFile,
    required this.source
  }) : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {

  TextEditingController storyTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return widget.source == "gallery"?FutureBuilder<File?>(
      future: widget.imageFile!,
      builder: (_, snapshot) {
        final file = snapshot.data;
        if (file == null) return Container();
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Palette.kuungaaDefault,
            leading: IconButton(
              icon: const Icon(MdiIcons.arrowLeft),
              //iconSize: 36.0,
              color: Colors.white,
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            /*title: Text(
            "Create story",
            style: TextStyle(
              color: Colors.white,
              //fontSize: 22.0,
              //fontWeight: FontWeight.bold,
            ),
          ),*/
            //centerTitle: true,
            elevation: 0.0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 12.0),
                child: ElevatedButton(
                  onPressed: () => {

                    saveStory(storyTextEditingController.text, file, "image_story", context),
                  },
                  child: const Text("Post"),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                    gradient: Palette.createStoryTextGradient
                ),
                alignment: Alignment.center,
                child: Image.file(file),
              ),
              Container(
                decoration: const BoxDecoration(
                    gradient: Palette.storyGradient
                ),
              ),
              Positioned(
                bottom: 8.0,
                left: 8.0,
                right: 8.0,
                child: TextField(
                  onChanged: (value) {
                    //Do something with the user input.
                  },
                  controller: storyTextEditingController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write text here',
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.white, width: 0.8),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Palette.kuungaaDefault, width: 0.8),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ):Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leading: IconButton(
          icon: const Icon(MdiIcons.arrowLeft),
          //iconSize: 36.0,
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        /*title: Text(
            "Create story",
            style: TextStyle(
              color: Colors.white,
              //fontSize: 22.0,
              //fontWeight: FontWeight.bold,
            ),
          ),*/
        //centerTitle: true,
        elevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 12.0),
            child: ElevatedButton(
              onPressed: () => {

                saveStory(storyTextEditingController.text, widget.imgFile!, "image_story", context),
              },
              child: const Text("Post"),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: Palette.createStoryTextGradient
            ),
            alignment: Alignment.center,
            child: Image.file(widget.imgFile!),
          ),
          Container(
            decoration: const BoxDecoration(
                gradient: Palette.storyGradient
            ),
          ),
          Positioned(
            bottom: 8.0,
            left: 8.0,
            right: 8.0,
            child: TextField(
              onChanged: (value) {
                //Do something with the user input.
              },
              controller: storyTextEditingController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: 'Write text here',
                hintStyle: TextStyle(
                  color: Colors.white,
                ),
                contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.white, width: 0.8),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Palette.kuungaaDefault, width: 0.8),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({
    Key? key,
    this.videoFile,
    this.vidFile,
    required this.source
  }) : super(key: key);

  final Future<File?>? videoFile;
  final File? vidFile;
  final String source;

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  //VideoPlayerController? _controller;
  bool initialized = false;
  late FlickMultiManager flickMultiManager;


  @override
  void initState() {
    //_initVideo();
    super.initState();
    flickMultiManager = FlickMultiManager();
  }

  @override
  void dispose() {
    //_controller!.dispose();
   // _controller = null;
    //flickMultiManager.remove(flickManager)
    super.dispose();
  }

  /*_initVideo() async {
    final video = await widget.videoFile;
    _controller = VideoPlayerController.file(video!)
    // Play the video again when it ends
      ..setLooping(true)
    // initialize the controller and notify UI when done
      ..initialize().then((_) =>
        setState((){
          initialized = true;
          _controller!.setVolume(30.0);
          _controller!.play();
        }));

  }*/

  TextEditingController storyTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return widget.source == "gallery"?FutureBuilder<File?>(
      future: widget.videoFile,
        builder: (_, snapshot) {
          final file = snapshot.data;
          if(file == null){
            return Container();
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Palette.kuungaaDefault,
              leading: IconButton(
                icon: const Icon(MdiIcons.arrowLeft),
                //iconSize: 36.0,
                color: Colors.white,
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              /*title: Text(
            "Create story",
            style: TextStyle(
              color: Colors.white,
              //fontSize: 22.0,
              //fontWeight: FontWeight.bold,
            ),
          ),*/
              //centerTitle: true,
              elevation: 0.0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 12.0),
                  child: ElevatedButton(
                    onPressed: (){
                      saveStory(storyTextEditingController.text, file, "video_story", context);
                    },
                    child: const Text("Post"),
                  ),
                ),
              ],
            ),
            body:

            Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    //gradient: Palette.createStoryTextGradient,
                    color: Palette.kuungaaDefault,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.maxFinite,
                    margin: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: FlickMultiPlayer(
                        url: file.path,
                        flickMultiManager: flickMultiManager,
                        image: "images/video_thumbnail.png",
                      ),
                    ),
                  ),
                  /*floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Wrap the play or pause in a call to `setState`. This ensures the
                  // correct icon is shown.
                  setState(() {
                    // If the video is playing, pause it.
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      // If the video is paused, play it.
                      _controller!.play();
                    }
                  });
                },
                // Display the correct icon depending on the state of the player.
                child: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),*/
                ),
                Container(
                  decoration: const BoxDecoration(
                      gradient: Palette.storyGradient
                  ),
                ),
                Positioned(
                  bottom: 8.0,
                  left: 8.0,
                  right: 8.0,
                  child: TextField(
                    onChanged: (value) {
                      //Do something with the user input.
                    },
                    controller: storyTextEditingController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 1,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Write text here',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.white, width: 0.8),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Palette.kuungaaDefault, width: 0.8),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                    ),
                  ),
                ),
              ],
            )
            // If the video is not yet initialized, display a spinner

          );
        }
    ):Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.kuungaaDefault,
          leading: IconButton(
            icon: const Icon(MdiIcons.arrowLeft),
            //iconSize: 36.0,
            color: Colors.white,
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          /*title: Text(
            "Create story",
            style: TextStyle(
              color: Colors.white,
              //fontSize: 22.0,
              //fontWeight: FontWeight.bold,
            ),
          ),*/
          //centerTitle: true,
          elevation: 0.0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 12.0),
              child: ElevatedButton(
                onPressed: (){
                  saveStory(storyTextEditingController.text, widget.vidFile!, "video_story", context);
                },
                child: const Text("Post"),
              ),
            ),
          ],
        ),
        body:

        Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                //gradient: Palette.createStoryTextGradient,
                color: Palette.kuungaaDefault,
              ),
              child: Container(
                width: double.infinity,
                height: double.maxFinite,
                margin: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: FlickMultiPlayer(
                    url: widget.vidFile!.path,
                    flickMultiManager: flickMultiManager,
                    image: "images/video_thumbnail.png",
                  ),
                ),
              ),
              /*floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Wrap the play or pause in a call to `setState`. This ensures the
                  // correct icon is shown.
                  setState(() {
                    // If the video is playing, pause it.
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      // If the video is paused, play it.
                      _controller!.play();
                    }
                  });
                },
                // Display the correct icon depending on the state of the player.
                child: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),*/
            ),
            Container(
              decoration: const BoxDecoration(
                  gradient: Palette.storyGradient
              ),
            ),
            Positioned(
              bottom: 8.0,
              left: 8.0,
              right: 8.0,
              child: TextField(
                onChanged: (value) {
                  //Do something with the user input.
                },
                controller: storyTextEditingController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: 'Write text here',
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white, width: 0.8),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Palette.kuungaaDefault, width: 0.8),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              ),
            ),
          ],
        )
      // If the video is not yet initialized, display a spinner

    );
  }
}

class StatusTextEditor extends StatefulWidget {
  const StatusTextEditor({Key? key}) : super(key: key);

  @override
  _StatusTextEditorState createState() => _StatusTextEditorState();
}

class _StatusTextEditorState extends State<StatusTextEditor> {

  Color pickColor = const Color.fromRGBO(0, 150, 250, 1);
  TextEditingController activityText = TextEditingController();
  bool isLoading = false;
  int _fontSizeController = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    activityText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leading: IconButton(
          icon: const Icon(MdiIcons.arrowLeft),
          //iconSize: 36.0,
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        /*title: Text(
          "Create story",
          style: TextStyle(
            color: Colors.white,
            //fontSize: 22.0,
            //fontWeight: FontWeight.bold,
          ),
        ),*/
        //centerTitle: true,
        elevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 12.0),
            child: ElevatedButton(
              onPressed: () => {

              },
              child: const Text("Post"),
            ),
          ),
        ],
      ),
      backgroundColor: pickColor,
      body: LoadingOverlay(
        isLoading: isLoading,
        color: const Color.fromRGBO(0, 0, 0, 1),
        progressIndicator: const CircularProgressIndicator(
          backgroundColor: Colors.black87,
        ),
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: pickColor,
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                height: MediaQuery.of(context).size.height / 1.5,
                child: Center(
                  child: Scrollbar(
                    showTrackOnHover: true,
                    thickness: 10.0,
                    radius: const Radius.circular(30.0),
                    child: TextField(
                      controller: activityText,
                      textAlign: TextAlign.center,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        fontSize: (_fontSizeController + 20).toDouble(),
                        color: Colors.white,
                        fontFamily: 'Lora',
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                      autofocus: true,
                      maxLines: null,
                      minLines: 1,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type Here",
                          hintStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: (_fontSizeController + 20).toDouble(),
                            fontFamily: 'Lora',
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.0,
                          )),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.maxFinite,
                child: Center(
                  child: ColorPicker(
                    labelTypes: const [],
                    pickerAreaHeightPercent: 0.05,
                    displayThumbColor: false,
                    pickerColor: pickColor,
                    paletteType: PaletteType.rgbWithGreen,
                    onColorChanged: (Color color) {
                      if (mounted) {
                        setState(() {
                          pickColor = color;
                        });
                      }
                    },
                  ),
                ),
              ),
              Container(
                  height: 10,
                  margin: const EdgeInsets.only(
                    left: 60.0,
                    right: 65.0,
                  ),
                  child: Slider(
                      value: _fontSizeController.toDouble(),
                      min: 1.0,
                      max: 20.0,
                      divisions: 10,
                      activeColor: Colors.amber,
                      inactiveColor: Colors.lightGreenAccent,
                      label: 'Set Font Size',
                      onChanged: (double newValue) {
                        setState(() {
                          _fontSizeController = newValue.round();
                        });
                      },
                      semanticFormatterCallback: (double newValue) {
                        return '${newValue.round()} dollars';
                      })),
            ],
          ),
        ),
      ),
    );
  }
}

void saveStory(String text, File? imageFile, String storyType, BuildContext context) async{
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)
      {
        return ProgressDialog(message: "Saving your story, Please wait...",);
      }
  );

  DatabaseReference storyRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Stories').child(userCurrentInfo!.user_id!).push();
  String storyKey = storyRef.key;
  if(imageFile != null){
    String basename = path.basename(imageFile.path);
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("KUUNGAA").child("Stories").child(storyKey).child(basename);
    //await ref.putFile(file).whenComplete((snapshot) => {});
    firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);

    String imageUrl = await(await uploadTask).ref.getDownloadURL();

    int storyDuration = 0;

    if(storyType == "video_story"){
      var a = await videoInfo.getVideoInfo(imageFile.path);
      storyDuration = ((a!.duration!) / 1000).round();
    }else{
      storyDuration = 10;
    }


    //List storyMedia = [];

    /*Map storymediadetails = {
      "url" : imageUrl,
      "type" : mimeType
    };*/

    //storyMedia.add(storymediadetails);

    var offsetRef = FirebaseDatabase.instance.reference().child(".info/serverTimeOffset");
    offsetRef.onValue.listen((event){
      int offset = event.snapshot.value;
      var storytime = ((DateTime.now().millisecondsSinceEpoch) + offset);

      Map storymediadetails = {
        "story_description" : text,
        "story_time" : storytime,
        "story_media" : imageUrl,
        "story_poster" : userCurrentInfo!.user_id!,
        "story_type": storyType,
        "story_duration": storyDuration,
      };

      storyRef.set(storymediadetails).then((onValue) {
        displayToastMessage("Your story was saved successfully", context);
        Navigator.pushNamedAndRemoveUntil(context, NavScreen.idScreen, (route) => false);
      }).catchError((onError) {
        Navigator.pop(context);
        displayToastMessage("An error occurred. Please try again later", context);
      });
    });
  }
}

