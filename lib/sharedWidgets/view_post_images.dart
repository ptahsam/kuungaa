import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
class ViewPostImage extends StatefulWidget {
  final Posts post;
  final List media;
  const ViewPostImage({
    Key? key,
    required this.post,
    required this.media
  }) : super(key: key);

  @override
  _ViewPostImageState createState() => _ViewPostImageState();
}

class _ViewPostImageState extends State<ViewPostImage> {

  PageController? _pageController;
  String urlImg = "";

  String _message = "";
  String _path = "";
  String _size = "";
  String _mimeType = "";
  File? _imageFile;
  int _progress = 0;

  bool isFirstContainerOPen = true;
  bool isSecondContainerOpen = false;

  final List<Widget> _taggedUserList = [];

  void _getTaggedList(){
    if(widget.post.taggedUsers != null){
      for(var i = 0; i < widget.post.taggedUsers!.length; i ++){
        Widget tagContainer = Container(
          padding: const EdgeInsets.all(2.0),
          child: InkWell(
            onTap: (){
              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post.taggedUsers![i].user_id!,)));
            },
            child: Text(
              "#" + widget.post.taggedUsers![i].user_firstname! + " " + widget.post.taggedUsers![i].user_lastname!,
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        );
        _taggedUserList.add(tagContainer);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
    Media media = widget.media[0];
    urlImg = media.url!;
    _getTaggedList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      //appBar: AppBar(),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.media.length,
            scrollDirection: Axis.horizontal,
            onPageChanged: (int page) {
              setState(() {
                //_currentPage = page;
                Media media = widget.media[page];
                urlImg = media.url!;
              });
            },
            itemBuilder: (context, i) {
              final Media media = widget.media[i];
              return InkWell(
                onTap: (){
                  setState(() {
                    if(isFirstContainerOPen){
                      isFirstContainerOPen = false;
                    }else{
                      isFirstContainerOPen = true;
                    }

                    if(isSecondContainerOpen){
                      isSecondContainerOpen = false;
                    }else{
                      isSecondContainerOpen = true;
                    }
                  });
                },
                child: Image.network(
                  media.url!,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            right: 0.0,
            left: 0.0,
            top: 0.0,
            child: Visibility(
              visible: isFirstContainerOPen,
              child: Container(
                //padding: EdgeInsets.only(top: 50.0),
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10.0, top: 50.0, left: 12.0, right: 12.0),
                  //color: Colors.black38,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Row(
                          children: [
                            if(widget.post.post_category == "pagesfeed")
                              SizedBox(
                                height: 35.0,
                                width: 35.0,
                                child: Stack(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SinglePage(kpage: widget.post.kpage!,)));
                                      },
                                      child: BoxAvatar(
                                        imageUrl: widget.post.kpage!.page_icon!,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0.0,
                                      right: 0.0,
                                      child: InkWell(
                                          onTap: (){
                                            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post.poster_id!,)));
                                          },
                                          child: ProfileAvatar(imageUrl: widget.post.postUser!.user_profileimage!, hasBorder: true, radius: 12.0, borderWidth: 11.0, backGroundColor: "#2dce89",)
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if(widget.post.post_category == "groupsfeed")
                              SizedBox(
                                height: 35.0,
                                width: 35.0,
                                child: Stack(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SingleGroup(group: widget.post.group!,)));
                                      },
                                      child: BoxAvatar(
                                          imageUrl: widget.post.group!.group_icon!
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0.0,
                                      right: 0.0,
                                      child: InkWell(
                                        onTap: (){
                                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post.poster_id!,)));
                                        },
                                        child: ProfileAvatar(imageUrl: widget.post.postUser!.user_profileimage!, hasBorder: true, radius: 12.0, borderWidth: 11.0, backGroundColor: "#2dce89",),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            //if(widget.post!.post_category == "groupsfeed")

                            if(widget.post.post_category == "newsfeed" || widget.post.post_category == "travelfeed")
                              InkWell(
                                onTap: (){
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post.poster_id!,)));
                                },
                                child: ProfileAvatar(imageUrl: widget.post.postUser!.user_profileimage!),
                              ),
                            const SizedBox(width: 8.0,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if(widget.post.post_category == "pagesfeed")
                                        InkWell(
                                          onTap: () async {
                                            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SinglePage(kpage: widget.post.kpage!,)));
                                          },
                                          child: Text(
                                            widget.post.kpage!.page_name!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: HexColor("#4285F4"),
                                            ),
                                          ),
                                        ),
                                      if(widget.post.post_category == "groupsfeed")
                                        InkWell(
                                          onTap: () async {
                                            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SingleGroup(group: widget.post.group!,)));
                                          },
                                          child: Text(
                                            widget.post.group!.group_name!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: HexColor("#4285F4"),
                                            ),
                                          ),
                                        ),
                                      if(widget.post.post_category == "newsfeed" || widget.post.post_category == "travelfeed")
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post.poster_id!,)));
                                              },
                                              child: Text(
                                                widget.post.postUser!.user_firstname! + " " + widget.post.postUser!.user_lastname!,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: HexColor("#4285F4"),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.fade,
                                              ),

                                            ),
                                            //widget.post!.post_expression != ""?const SizedBox(width: 4.0,):const SizedBox.shrink(),
                                            widget.post.post_expression != ""?Text(" — is feeling " + widget.post.post_expression!, maxLines: 1, overflow: TextOverflow.fade,):const SizedBox.shrink(),
                                          ],
                                        ),
                                      /*if(widget.post!.post_category == "newsfeed" || widget.post!.post_category == "travelfeed")
                                widget.post!.post_expression != ""?const SizedBox(width: 4.0,):const SizedBox.shrink(),
                                Expanded(child: widget.post!.post_expression != ""?Text(" — is feeling " + widget.post!.post_expression!, maxLines: 2, overflow: TextOverflow.fade,):const SizedBox.shrink()),
                                */
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      widget.post.post_category == "groupsfeed" || widget.post.post_category == "pagesfeed"?
                                      InkWell(
                                        onTap: (){
                                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UserProfile(userid: widget.post.poster_id!,)));
                                        },
                                        child: Text(
                                          widget.post.postUser!.user_firstname! + " " + widget.post.postUser!.user_lastname!,
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                          ),
                                        ),
                                      ):const SizedBox.shrink(),
                                      widget.post.post_category == "groupsfeed"?
                                      const Text(" . ")
                                          :const SizedBox.shrink(),
                                      widget.post.post_category == "travelfeed"?
                                      Row(
                                        children: [
                                          ExtendedImage.asset(
                                            'icons/flags/png/' + widget.post.post_countrycode!.toLowerCase() + '.png', package: 'country_icons',
                                            height: 20.0,
                                            width: 20.0,
                                            fit: BoxFit.cover,
                                            shape: BoxShape.circle,
                                          ),
                                          const SizedBox(width: 5.0,),
                                          Text(
                                            "Travel and Culture . ",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.normal,
                                              color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                            ),
                                          ),
                                        ],
                                      )
                                          :const SizedBox.shrink(),
                                      if(widget.post.post_privacy == "public")
                                        Icon(
                                          Icons.public,
                                          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                          size: 12.0,
                                        ),
                                      if(widget.post.post_privacy == "friends")
                                        Icon(
                                          FontAwesomeIcons.userFriends,
                                          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                          size: 12.0,
                                        ),
                                      if(widget.post.post_privacy == "onlyme")
                                        Icon(
                                          FontAwesomeIcons.userLock,
                                          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                          size: 12.0,
                                        ),
                                      const SizedBox(width: 8.0,),
                                      widget.post.post_time != null?Text(
                                        convertToTimeAgo(widget.post.post_time!),
                                        //'${post!.post_time!}',

                                        style: TextStyle(
                                          color: Provider.of<AppData>(context).darkTheme?Colors.white:Colors.black54,
                                          fontSize: 12.0,
                                        ),
                                      ):const SizedBox.shrink(),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            ContextMenu(post: widget.post),//context menu
                          ],
                        ),
                      ),

                      widget.post.taggedUsers != null?
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Wrap(
                          children: _taggedUserList,
                        ),
                      ):const SizedBox.shrink(),

                      widget.post.post_description != ''?Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Text(widget.post.post_description!),
                      ):const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Visibility(
              visible: isFirstContainerOPen,
              child: PostStats(post: widget.post),
            ),
          ),
          Positioned(
            bottom: 20.0,
            right: 10.0,
            child: Visibility(
              visible: isSecondContainerOpen,
              child: CircleButton(
                icon: Icons.download,
                iconSize: 22.0,
                onPressed: (){
                  _downloadImage(urlImg);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadImage(
      String url, {
        AndroidDestinationType? destination,
        bool whenError = false,
        String? outputMimeType,
      }) async {
    String? fileName;
    String? path;
    int? size;
    String? mimeType;

    try {
      String? imageId;

      if (whenError) {
        imageId = await ImageDownloader.downloadImage(url,
            outputMimeType: outputMimeType)
            .catchError((error) {
          if (error is PlatformException) {
            String? path = "";
            if (error.code == "404") {
              print("Not Found Error.");
            } else if (error.code == "unsupported_file") {
              print("UnSupported FIle Error.");
              path = error.details["unsupported_file_path"];
            }
            setState(() {
              _message = error.toString();
              _path = path ?? '';
            });
          }

          print(error);
        }).timeout(Duration(seconds: 10), onTimeout: () {
          print("timeout");
          return;
        });
      } else {
        if (destination == null) {
          imageId = await ImageDownloader.downloadImage(
            url,
            outputMimeType: outputMimeType,
          );
        } else {
          imageId = await ImageDownloader.downloadImage(
            url,
            destination: destination,
            outputMimeType: outputMimeType,
          );
        }
      }

      if (imageId == null) {
        return;
      }
      fileName = await ImageDownloader.findName(imageId);
      path = await ImageDownloader.findPath(imageId);
      size = await ImageDownloader.findByteSize(imageId);
      mimeType = await ImageDownloader.findMimeType(imageId);
    } on PlatformException catch (error) {
      setState(() {
        _message = error.message ?? '';
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      var location = Platform.isAndroid ? "Directory" : "Photo Library";
      _message = 'Saved as "$fileName" in $location.\n';
      _size = 'size:     $size';
      _mimeType = 'mimeType: $mimeType';
      _path = path ?? '';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$_message'),
        duration: const Duration(seconds: 2),
      ));

      if (!_mimeType.contains("video")) {
        _imageFile = File(path!);
      }
      return;
    });
  }

  /*Future<void> _download() async {
    /*final response = await http.get(Uri.parse(urlImg));

    // Get the image name
    final imageName = path.basename(urlImg);

    print("save img :: "+urlImg);
    // Get the document directory path
    final appDir = await path_provider.getApplicationDocumentsDirectory();

    print("save img dir ::"+appDir.path.toString());

    // This is the saved image path
    // You can use it to display the saved image later
    final localPath = path.join(appDir.path, imageName);

    print("save img localpath ::"+localPath);

    // Downloading
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);*/
  }*/

}