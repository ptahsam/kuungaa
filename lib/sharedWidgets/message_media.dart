import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/MultiManager/flick_multimanager.dart';
import 'package:kuungaa/MultiManager/flick_multiplayer.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:page_transition/page_transition.dart';
import 'package:visibility_detector/visibility_detector.dart';
class MessageMedia extends StatefulWidget {
  final List<Media> messageMedia;
  const MessageMedia({
    Key? key,
    required this.messageMedia
  }) : super(key: key);

  @override
  _MessageMediaState createState() => _MessageMediaState();
}

class _MessageMediaState extends State<MessageMedia> {
  late FlickMultiManager flickMultiManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flickMultiManager = FlickMultiManager();
  }
  @override
  Widget build(BuildContext context) {
    Media media = widget.messageMedia[0];
    if(media.type!.contains("image")){
      return InkWell(
        onTap: (){
          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewMessageImages(messageMedia: widget.messageMedia,)));
        },
        child: Stack(
          children: [
            SizedBox(
              height: 200.0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: ExtendedNetworkImageProvider(
                      media.url!,
                      cache: true,
                      cacheRawData: true
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: null /* add child content here */,
              ),
            ),
            Positioned(
              top: 10.0,
              right: 10.0,
              child: widget.messageMedia.length > 1? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text("+"+(widget.messageMedia.length - 1).toString(), style: TextStyle(color: Colors.white),),
              ):SizedBox.shrink(),
            )
          ],
        ),
      );
    }else{
      return VisibilityDetector(
        key: ObjectKey(flickMultiManager),
        onVisibilityChanged: (visibility) {
          if (visibility.visibleFraction == 0 && mounted) {
            flickMultiManager.pause();
          }
        },
        child: Container(
          height: 200,
          margin: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: FlickMultiPlayer(
              url: media.url!,
              flickMultiManager: flickMultiManager,
              image: "images/video_thumbnail.png",
            ),
          ),
        ),
      );
    }

    /*if(widget.messageMedia.length == 1){
      return SizedBox(
        height: 200.0,
        child: Column(
          children: [

            Expanded(

              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.messageMedia.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: 1 / 1,),
                itemBuilder: (BuildContext context, int index){
                  Media media = widget.messageMedia[index];
                  if(media.type!.contains("image")){
                    return InkWell(
                      onTap: (){
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: ExtendedImage.network(
                            media.url!,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: 500,
                            cacheWidth: MediaQuery.of(context).size.width.toInt(),
                            cacheHeight: 500,
                            // cache: true,
                            // cacheHeight: 350,
                            filterQuality: FilterQuality.high,
                            //cacheHeight: 200,
                            //cacheWidth: MediaQuery.of(context).size.width.round(),
                            //height: 200.0,
                          ),
                        ),
                      ),
                    );
                  }else{
                    return VisibilityDetector(
                      key: ObjectKey(flickMultiManager),
                      onVisibilityChanged: (visibility) {
                        if (visibility.visibleFraction == 0 && mounted) {
                          flickMultiManager.pause();
                        }
                      },
                      child: Container(
                        height: 350,
                        margin: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: FlickMultiPlayer(
                            url: media.url!,
                            flickMultiManager: flickMultiManager,
                            image: "images/video_thumbnail.png",
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
    }
    else if(widget.messageMedia.length == 2){
      return SizedBox(
        height: 200.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          //mainAxisSize: MainAxisSize.max,
          children: [

            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.messageMedia.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 2, childAspectRatio: 1 / 2,),
                itemBuilder: (BuildContext context, int index){
                  Media media = widget.messageMedia[index];
                  return InkWell(
                    onTap: (){
                    },
                    child: ClipRRect(
                      borderRadius: index == 0? const BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        bottomLeft: Radius.circular(5.0),
                      ) :  const BorderRadius.only(
                        topRight: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0),
                      ),
                      child: ExtendedImage.network(
                        media.url!,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        width: MediaQuery.of(context).size.width,
                        height: 500,
                        cacheWidth: MediaQuery.of(context).size.width.toInt(),
                        cacheHeight: 500,
                        // cacheHeight: 200,
                        // cacheWidth: MediaQuery.of(context).size.width.round()
                        //height: 200.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }else if(widget.messageMedia.length == 3){
      return SizedBox(
        height: 200.0,
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: widget.messageMedia.length - 1,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 2, childAspectRatio: 1 / 2,),
                  itemBuilder: (BuildContext context, int index){
                    Media media = widget.messageMedia[index];
                    return InkWell(
                      onTap: (){
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),

                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            topRight: Radius.circular(5.0),
                          ),
                          child: ExtendedImage.network(
                            media.url!,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: 500,
                            cacheWidth: MediaQuery.of(context).size.width.toInt(),
                            cacheHeight: 500,
                            //cacheHeight: 200,
                            // cache: true,
                            filterQuality: FilterQuality.high,
                            // cacheHeight: 200,
                            // cacheWidth: MediaQuery.of(context).size.width.round()
                            //height: 200.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 2.0,),
            SizedBox(
              height: 100.0,
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 1,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: 1 / 1,),
                      itemBuilder: (BuildContext context, int index){
                        Media media = widget.messageMedia[2];
                        return InkWell(
                          onTap: (){
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(5.0),
                                bottomRight: Radius.circular(5.0),
                              ),
                              child: ExtendedImage.network(
                                media.url!,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: 500,
                                cacheWidth: MediaQuery.of(context).size.width.toInt(),
                                cacheHeight: 500,
                                //cache: true,
                                //cacheHeight: 200,
                                filterQuality: FilterQuality.high,
                                //cacheHeight: 200,
                                //cacheWidth: MediaQuery.of(context).size.width.round()
                                //height: 200.0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }else if(widget.messageMedia.length == 4){
      return SizedBox(
        height: 200.0,
        child: Column(
          children: [

            Expanded(

              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.messageMedia.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 2, mainAxisSpacing: 2,),
                itemBuilder: (BuildContext context, int index){
                  Media media = widget.messageMedia[index];
                  return InkWell(
                    onTap: (){
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),

                      child: ExtendedImage.network(
                        media.url!,
                        fit: BoxFit.cover,
                        // cache: true,
                        //cacheHeight: 200,
                        width: MediaQuery.of(context).size.width,
                        height: 500,
                        cacheWidth: MediaQuery.of(context).size.width.toInt(),
                        cacheHeight: 500,
                        filterQuality: FilterQuality.high,
                        //  cacheHeight: 200,
                        // cacheWidth: MediaQuery.of(context).size.width.round()
                        //height: 200.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }else if(widget.messageMedia.length > 4){
      return SizedBox(
        height: 200.0,
        child: Column(
          children: [

            Expanded(

              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: 4,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 2, mainAxisSpacing: 2,),
                itemBuilder: (BuildContext context, int index){
                  Media media = widget.messageMedia[index];
                  if(index == 3){
                    return InkWell(
                      onTap: (){
                      },
                      child: Stack(
                        children: [
                          ExtendedImage.network(
                            media.url!,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: 500,
                            cacheWidth: MediaQuery.of(context).size.width.toInt(),
                            cacheHeight: 500,
                            //cache: true,
                            //cacheHeight: 350,
                            filterQuality: FilterQuality.high,
                            // cacheHeight: 200,
                            // cacheWidth: MediaQuery.of(context).size.width.round()
                            //height: 200.0,
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: Palette.storyGradient,
                            ),
                            child: Center(
                              child: Text(
                                (widget.messageMedia.length - 4).toString() + " +",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return InkWell(
                    onTap: (){
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: ExtendedImage.network(
                        media.url!,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: 500,
                        cacheWidth: MediaQuery.of(context).size.width.toInt(),
                        cacheHeight: 500,
                        //cache: true,
                        //height: 200,
                        filterQuality: FilterQuality.high,
                        // cacheHeight: 200,
                        // cacheWidth: MediaQuery.of(context).size.width.round()
                        //height: 200.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }else{
      return const SizedBox.shrink();
    }*/
  }
}

class ViewMessageImages extends StatefulWidget {
  final List<Media> messageMedia;
  const ViewMessageImages({
    Key? key,
    required this.messageMedia
  }) : super(key: key);

  @override
  State<ViewMessageImages> createState() => _ViewMessageImagesState();
}

class _ViewMessageImagesState extends State<ViewMessageImages> {

  PageController? _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.messageMedia.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) {
              final Media media = widget.messageMedia[i];
              return Image.network(
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
              );
            },
          ),
        ],
      ),
    );
  }
}

