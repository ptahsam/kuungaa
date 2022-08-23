import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kuungaa/AllWidgets/progressDialog.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:path/path.dart' as path;

import 'widgets.dart';
class FileSelector extends StatefulWidget {
  final bool allowMultiple;
  final bool isUserPhoto;
  const FileSelector({
    Key? key,
    required this.allowMultiple,
    required this.isUserPhoto
  }) : super(key: key);

  @override
  _FileSelectorState createState() => _FileSelectorState();
}

class _FileSelectorState extends State<FileSelector> {
  bool _isButtonDisabled = false;

  bool isSelectMultiple = false;

  List<AssetEntity> assets = [];

  List<File> userSelectedFiles = [];

  final ImagePicker _picker = ImagePicker();

  String? _path;

  XFile? takenFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPhotoPermission();
    getLostData();
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
    if (ps == PermissionState.authorized && ps != PermissionState.limited){
      _fetchAssets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.kuungaaDefault,
        leading: IconButton(
          icon: const Icon(Icons.close),
          //iconSize: 36.0,
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context, "");
          },
        ),
        title: const Text(
          "Select files",
          style: TextStyle(
            color: Colors.white,
            //fontSize: 22.0,
            //fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0.0,
        actions: [
          Container(
            margin: const EdgeInsets.fromLTRB(0.0, 8.0, 12.0, 8.0),
            child: ElevatedButton(
              onPressed: (){
                showModalBottomSheet(
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                  ),
                  context: context,
                  builder: (context) => buildMediaSheet(),
                );
                //Navigator.push(context, MaterialPageRoute(builder: (context)=>const TakePhoto()));
              },
              child: const Icon(MdiIcons.camera, color: Colors.white,),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0.0, 8.0, 12.0, 8.0),
            child: ElevatedButton(
              onPressed: _isButtonDisabled? (){
                Navigator.pop(context, userSelectedFiles);
              } : null,
              child: const Text("Done"),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            height: 100.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Select files " + userSelectedFiles.length.toString()
                ),
                widget.allowMultiple?ElevatedButton(
                  onPressed: (){
                    setState(() {
                      if(isSelectMultiple){
                        isSelectMultiple = false;
                      }else{
                        isSelectMultiple = true;
                      }
                    });
                  },
                  child: const Text("Select multiple"),
                ):const SizedBox.shrink(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white ,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  // A grid view with 3 items per row
                  crossAxisCount: 3,
                  crossAxisSpacing: 1.0,
                  mainAxisSpacing: 1.0,
                ),
                itemCount: assets.length,
                itemBuilder: (_, index) {
                  final AssetEntity asset = assets[index];
                  bool fileExists = false;
                  return FutureBuilder<Uint8List?>(
                    future: asset.thumbnailData,
                    builder: (_, snapshot) {
                      final bytes = snapshot.data;
                      // If we have no data, display a spinner
                      if (bytes == null) return Align(
                          alignment: Alignment.center,
                          child: Center(
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: LoadingAnimationWidget.threeArchedCircle(
                                color: Palette.kuungaaDefault,
                                size: 40
                              ),
                            ),
                          )
                      );
                      // If there's data, display it as an image
                      return InkWell(
                        onTap: () async {
                          AssetEntity imageAsset = asset;
                          File? file = await asset.file;
                          if(isSelectMultiple && asset.type == AssetType.image){
                            setState(() {

                              bool exists = userSelectedFiles.any((File oldfile) => oldfile.path == file!.path);
                              if(exists){
                                userSelectedFiles.removeWhere((File oldfile) => oldfile.path== file!.path);
                              }else{
                                userSelectedFiles.add(file!);
                                fileExists = true;
                              }

                              if(userSelectedFiles.isNotEmpty){
                                _isButtonDisabled = true;
                              }else{
                                _isButtonDisabled = false;
                              }
                            });
                          }else if(widget.isUserPhoto){
                           if(imageAsset.type == AssetType.image){
                             Navigator.pop(context, imageAsset.file);
                           }else{
                             displayToastMessage("Select only image", context);
                           }
                          }else{
                            List<File> userSingleFileSelectedList = [];
                            userSingleFileSelectedList.add(file!);
                            Navigator.pop(context, userSingleFileSelectedList);
                          }

                            /*for(var i = 0; i < userSelectedFiles.length; i ++){
                              if(userSelectedFiles[i] == asset.file){
                                setState(() {
                                  userSelectedFiles.removeAt(i);
                                });
                              }else{

                              }
                            }*/

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
                              /*Center(
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
                              ),*/
                            Positioned(
                              left: 10.0,
                              bottom: 10.0,
                              child: Icon(
                                MdiIcons.video,
                                color: Palette.kuungaaDefault,
                              ),
                            ),
                            isSelectMultiple? Positioned(
                              top: 10.0,
                              right: 10.0,
                              child: fileExists? const Icon(
                                MdiIcons.checkboxMarked,
                                color: Palette.kuungaaDefault,
                              ): const Icon(
                                MdiIcons.checkboxBlankOutline,
                                color: Palette.kuungaaDefault,
                              ),
                            ): const SizedBox.shrink(),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMediaSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              Navigator.pop(context);
              _showCamera("Photo");
              //takenFile = await _picker.pickImage(source: ImageSource.camera);
             // print("MediaTaken photo: "+ takenFile!.name);
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  height: 60.0,
                  width: 60.0,

                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 26.0,
                        color: HexColor("#2dce89"),
                      )
                    ),
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Take a photo",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          widget.isUserPhoto?const SizedBox.shrink():InkWell(
            onTap: () async{
              Navigator.pop(context);
               _showCamera("Video");
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  height: 60.0,
                  width: 60.0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        MdiIcons.videoOutline,
                        size: 26.0,
                        color: HexColor("#2dce89"),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14.0,),
                const Text(
                  "Record a video",
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

  Future<void> getLostData() async {
    final LostDataResponse response =
    await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.files != null) {
      for (final XFile file in response.files!) {
        takenFile = file;
        //_handleFile(file);
      }
    } else {
      displayToastMessage(response.exception.toString(), context);
      //_handleError(response.exception);
    }
  }

  void _showCamera(String mediaType) async {

    final cameras = await availableCameras();
    //final camera = cameras.first;

    if(mediaType == "Photo"){
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TakePhoto(cameras: cameras)));

      if(result != null){

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context)
            {
              return ProgressDialog(message: "Preparing image, Please wait...",);
            }
        );

        XFile xFile = result;
        File file = File(xFile.path);
        String basename = path.basename(file.path);
        File waterMarkFile = await watermarkPicture(file, basename);
        //print("photo :: " + waterMarkFile.lengthSync().toString());
        //File compressedFile = await testCompressAndGetFile(file, file.path);
        //print("photo :: " + compressedFile.lengthSync().toString());

        Navigator.pop(context);
        if(isSelectMultiple){
          List<File> userSingleFileSelectedList = [];
          userSingleFileSelectedList.add(waterMarkFile);
          Navigator.pop(context, userSingleFileSelectedList);
        }else if(widget.isUserPhoto){
          Navigator.pop(context, waterMarkFile);
        }else{
          List<File> userSingleFileSelectedList = [];
          userSingleFileSelectedList.add(waterMarkFile);
          Navigator.pop(context, userSingleFileSelectedList);
        }

      }
    }else{
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RecordVideo(cameras: cameras)));
      if(result != null){
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context)
            {
              return ProgressDialog(message: "Preparing video, Please wait...",);
            }
        );
        XFile xFile = result;
        File file = File(xFile.path);
        //File waterMarkFile = await watermarkVideo('kuungaalogo.png', file);
        //print("watermark video :: " + waterMarkFile.path);
        Navigator.pop(context);
        if(isSelectMultiple){
          List<File> userSingleFileSelectedList = [];
          userSingleFileSelectedList.add(file);
          Navigator.pop(context, userSingleFileSelectedList);
        }else{
          List<File> userSingleFileSelectedList = [];
          userSingleFileSelectedList.add(file);
          Navigator.pop(context, userSingleFileSelectedList);
        }
      }
    }
  }
}

class AssetThumbnailClass extends StatelessWidget {
  const AssetThumbnailClass({
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
        if (bytes == null) return const CircularProgressIndicator();
        // If there's data, display it as an image
        return InkWell(
          onTap: () {
            /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  if (asset.type == AssetType.image) {
                    // If this is an image, navigate to ImageScreen
                    //return ImageScreen(imageFile: asset.file);
                  } else {
                    // if it's not, navigate to VideoScreen
                    //return VideoScreen(videoFile: asset.file);
                  }
                },
              ),
            );*/
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
