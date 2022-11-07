import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/Models/media.dart';
import 'package:kuungaa/Models/post.dart';
import 'package:kuungaa/MultiManager/flick_multimanager.dart';
import 'package:kuungaa/MultiManager/flick_multiplayer.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';
class PostMedia extends StatefulWidget {
  final Posts post;
  const PostMedia({
    Key? key,
    required this.post
  }) : super(key: key);

  @override
  _PostMediaState createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia> {

  //late FlickMultiManager flickMultiManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //flickMultiManager = FlickMultiManager();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Media>>(
        future: getPostMediaData(widget.post.post_id!),
        builder: (BuildContext context, AsyncSnapshot<List<Media>> snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            //print("data length" + snapshot.data!.length.toString());
            if(snapshot.hasData){
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.60,
                width: MediaQuery.of(context).size.width,
                child: PhotoGrid(mediaList: snapshot.data!, post: widget.post,),
              );
              /*if(snapshot.data!.length == 1){
                List viewMedia = snapshot.data!;
                return SizedBox(
                  height: 350.0,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: 1 / 1,),
                    itemBuilder: (BuildContext context, int index){
                      Media media = snapshot.data![index];
                      if(media.type!.contains("image")){
                        return InkWell(
                          onTap: (){
                            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewPostImage(post: widget.post, media: viewMedia,)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),

                            child: ExtendedImage.network(
                              media.url!,
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: 400,
                              cacheWidth: ((MediaQuery.of(context).size.width) * 1.25).round().toInt() ,
                              cacheHeight: 1000,
                               enableMemoryCache: true,
                               //cacheWidth: 500,
                               // cache: true,
                               // cacheHeight: 350,
                              filterQuality: FilterQuality.high,
                              //cacheHeight: 200,
                              //cacheWidth: MediaQuery.of(context).size.width.round(),
                              //height: 200.0,
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
                            height: 500,
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
                );
              }
              else if(snapshot.data!.length > 1){
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: MediaQuery.of(context).size.width,
                  child: PhotoGrid(mediaList: snapshot.data!,),
                );
                return SizedBox(
                  height: 350.0,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 2, childAspectRatio: 1 / 2,),
                    itemBuilder: (BuildContext context, int index){
                      Media media = snapshot.data![index];
                      List doubleMedia = snapshot.data!;
                      return InkWell(
                        onTap: (){
                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewPostImage(post: widget.post, media: doubleMedia,)));
                        },
                        child: ExtendedImage.network(
                          media.url!,
                          fit: BoxFit.cover,
                          width: (MediaQuery.of(context).size.width),
                          height: 350,
                          cacheWidth: MediaQuery.of(context).size.width.toInt(),
                          cacheHeight: 1000,
                          //cache: true,
                          //cacheHeight: 350,
                          filterQuality: FilterQuality.high,
                           // cacheHeight: 200,
                           // cacheWidth: MediaQuery.of(context).size.width.round()
                          //height: 200.0,
                        ),
                      );
                    },
                  ),
                );
              }else if(snapshot.data!.length == 3){
                return SizedBox(
                  height: 400.0,
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 200.0,
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: snapshot.data!.length - 1,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 2, childAspectRatio: 1 / 2,),
                            itemBuilder: (BuildContext context, int index){
                              Media media = snapshot.data![index];
                              List doubleMedia = snapshot.data!;
                              return InkWell(
                                onTap: (){
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewPostImage(post: widget.post, media: doubleMedia,)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),

                                  child: ExtendedImage.network(
                                    media.url!,
                                    fit: BoxFit.cover,
                                    width: (MediaQuery.of(context).size.width) * 0.5,
                                    height: 200,
                                    cacheWidth: 600,
                                    cacheHeight: 1000,
                                    //cacheHeight: 200,
                                   // cache: true,
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
                      ),
                      const SizedBox(height: 2.0,),
                      SizedBox(
                        height: 200.0,
                        child: Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: 1,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: 1 / 1,),
                                itemBuilder: (BuildContext context, int index){
                                  Media media = snapshot.data![2];
                                  List doubleMedia = snapshot.data!;
                                  return InkWell(
                                    onTap: (){
                                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewPostImage(post: widget.post, media: doubleMedia,)));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),

                                      child: ExtendedImage.network(
                                        media.url!,
                                        fit: BoxFit.cover,
                                        width: (MediaQuery.of(context).size.width),
                                        height: 200,
                                        cacheWidth: 600,
                                        cacheHeight: 1000,
                                        //cache: true,
                                        //cacheHeight: 200,
                                        filterQuality: FilterQuality.high,
                                        //cacheHeight: 200,
                                        //cacheWidth: MediaQuery.of(context).size.width.round()
                                        //height: 200.0,
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
              }else if(snapshot.data!.length == 4){
                return SizedBox(
                  height: 500.0,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 2, mainAxisSpacing: 2,),
                    itemBuilder: (BuildContext context, int index){
                      Media media = snapshot.data![index];
                      List doubleMedia = snapshot.data!;
                      return InkWell(
                        onTap: (){
                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewPostImage(post: widget.post, media: doubleMedia,)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),

                          child: ExtendedImage.network(
                            media.url!,
                            fit: BoxFit.cover,
                            width: (MediaQuery.of(context).size.width),
                            height: 200,
                            cacheWidth: MediaQuery.of(context).size.width.toInt(),
                            cacheHeight: 500,
                           // cache: true,
                            //cacheHeight: 200,
                            filterQuality: FilterQuality.high,
                            //  cacheHeight: 200,
                             // cacheWidth: MediaQuery.of(context).size.width.round()
                            //height: 200.0,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }else if(snapshot.data!.length > 4){
                return SizedBox(
                  height: 400.0,
                  child: Column(
                    children: [

                      Expanded(

                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: 4,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 2, mainAxisSpacing: 2,),
                          itemBuilder: (BuildContext context, int index){
                            Media media = snapshot.data![index];
                            List doubleMedia = snapshot.data!;
                            if(index == 3){
                              return InkWell(
                                onTap: (){
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewPostImage(post: widget.post, media: doubleMedia,)));
                                },
                                child: Stack(
                                  children: [
                                    ExtendedImage.network(
                                      media.url!,
                                      fit: BoxFit.fill,
                                      width: (MediaQuery.of(context).size.width),
                                      height: 400,
                                      cacheWidth: MediaQuery.of(context).size.width.toInt(),
                                      cacheHeight: 400,
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
                                          (snapshot.data!.length - 4).toString() + " +",
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
                                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewPostImage(post: widget.post, media: doubleMedia,)));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: ExtendedImage.network(
                                  media.url!,
                                  fit: BoxFit.fill,
                                  //cache: true,
                                  width: (MediaQuery.of(context).size.width),
                                  height: 400,
                                  cacheWidth: MediaQuery.of(context).size.width.toInt(),
                                  cacheHeight: 400,
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
            }else{
              return const SizedBox(height: 8.0,);
            }
          }else{
            return Shimmer.fromColors(
              baseColor: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
              highlightColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.grey[100]!,
              child: Container(
                height: 350.0,
                color: Provider.of<AppData>(context).darkTheme?Palette.mediumDarker:Colors.grey[300]!,
              ),
            );
          }
        }
    );
  }
}

class PhotoGrid extends StatefulWidget {
  final List<Media> mediaList;
  final Posts post;
  const PhotoGrid({
    Key? key,
    required this.mediaList,
    required this.post
  }) : super(key: key);

  @override
  _PhotoGridState createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {

  late FlickMultiManager flickMultiManager;

  int _numPages = 0;
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true, i) : _indicator(false, i));
    }
    return list;
  }

  PageController? _pageController;

  Widget _indicator(bool isActive, int n) {
    if(_numPages > 10){
      if(n > 10 && !isActive){
        return SizedBox.shrink();
      }
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: isActive?8.0:8.0,
      width: isActive?12.0:8.0,
      decoration: Provider.of<AppData>(context).darkTheme?BoxDecoration(
        color: isActive ? Palette.kuungaaDefault : Colors.white,
        shape: BoxShape.circle,
        //borderRadius: const BorderRadius.all(Radius.circular(12)),
      ):BoxDecoration(
        color: isActive ? Palette.kuungaaDefault : Colors.black38,
        //shape: isActive?BoxShape.rectangle:BoxShape.circle,
        borderRadius: isActive?BorderRadius.circular(25.0):BorderRadius.circular(60.0),
        //borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
    _numPages = widget.mediaList.length;
    flickMultiManager = FlickMultiManager();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.mediaList.length,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, i) {
                    final Media media = widget.mediaList[i];
                    return media.type!.contains("image")?InkWell(
                      onTap: (){
                        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewPostImage(post: widget.post, media: widget.mediaList,)));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.55,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: ExtendedNetworkImageProvider(
                              media.url!,
                              cache: true,
                              cacheRawData: true,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: null /* add child content here */,
                      ),
                    ): VisibilityDetector(
                      key: ObjectKey(flickMultiManager),
                      onVisibilityChanged: (visibility) {
                        if (visibility.visibleFraction == 0 && mounted) {
                          flickMultiManager.pause();
                        }
                      },
                      child: Container(
                        height: 500,
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
                  },
                ),
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: widget.mediaList.length > 1? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text((_currentPage + 1).toString() + "/" + widget.mediaList.length.toString(), style: TextStyle(color: Colors.white),),
                  ):SizedBox.shrink(),
                ),
              ],
            ),
          ),
          widget.mediaList.length > 1?Container(
            padding: const EdgeInsets.only(top: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: _buildPageIndicator(),
            ),
          ):SizedBox.shrink(),
        ],
      ),
    );
  }
}

