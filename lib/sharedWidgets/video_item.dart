import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class VideoItems extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;
  final bool autoplay;


  const VideoItems({
    required this.videoPlayerController,
    this.looping = false, this.autoplay = false,
    Key? key,
  }) : super(key: key);

  @override
  _VideoItemsState createState() => _VideoItemsState();
}

class _VideoItemsState extends State<VideoItems> {
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      autoInitialize: true,
      autoPlay: widget.autoplay,
      looping: widget.looping,
      aspectRatio: widget.videoPlayerController.value.aspectRatio,
      errorBuilder: (context, errorMessage) {
        return const Center(
          child: Text(
            //errorMessage,
            'There was an error playing this video. Please try again later',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }

}