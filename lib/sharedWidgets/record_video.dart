
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/circle_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RecordVideo extends StatefulWidget {
  final List<CameraDescription> cameras;
  const RecordVideo({
    Key? key,
    required this.cameras
  }) : super(key: key);

  @override
  State<RecordVideo> createState() => _RecordVideoState();
}

class _RecordVideoState extends State<RecordVideo> {

  CameraController? _cameraController;
  Future<void>? _initializeCameraControllerFuture;
  int selectedCamera = 0;
  bool _isRecording = false;

  static const countdownDuration = Duration(minutes: 10);
  Duration duration = Duration();
  Timer? timer;

  bool countDown =true;

  @override
  void initState() {
    // TODO: implement initState
    initializeCamera(selectedCamera);
    reset();
    super.initState();
  }

  void reset(){
    if (countDown){
      setState(() =>
      duration = countdownDuration);
    } else{
      setState(() =>
      duration = Duration());
    }
  }

  void startTimer(){
    timer = Timer.periodic(Duration(seconds: 1),(_) => addTime());
  }

  void addTime(){
    final addSeconds = countDown ? -1 : 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0){
        timer?.cancel();
      } else{
        duration = Duration(seconds: seconds);

      }
    });
  }

  void stopTimer({bool resets = true}){
    if (resets){
      reset();
    }
    setState(() => timer?.cancel());
  }

  Widget buildTime(){
    String twoDigits(int n) => n.toString().padLeft(2,'0');
    final hours =twoDigits(duration.inHours);
    final minutes =twoDigits(duration.inMinutes.remainder(60));
    final seconds =twoDigits(duration.inSeconds.remainder(60));
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //buildTimeCard(time: hours, header:'HOURS'),
          //SizedBox(width: 8,),
          buildTimeCard(time: minutes, header:'MINUTES'),
          SizedBox(width: 8,),
          buildTimeCard(time: seconds, header:'SECONDS'),
        ]
    );
  }

  Widget buildTimeCard({required String time, required String header}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
            ),
            child: Text(
              time, style: TextStyle(fontWeight: FontWeight.w500,),),
          ),
          //SizedBox(height: 24,),
          //Text(header,style: TextStyle(color: Colors.black45)),
        ],
      );

  initializeCamera(int cameraIndex) async{
    _cameraController = CameraController(widget.cameras[cameraIndex], ResolutionPreset.medium);

    _initializeCameraControllerFuture = _cameraController!.initialize();
  }

  _recordVideo() async {
    if (_isRecording) {
      try {
        final file = await _cameraController!.stopVideoRecording();
        //setState(() => _isRecording = false);
        print("recorded video :: "+ file.path);
        stopTimer(resets: false);
        Navigator.pop(context, file);
      } catch (e) {
        print(e);
      }
    } else {
      try {
        await _cameraController!.prepareForVideoRecording();
        await _cameraController!.startVideoRecording();
        setState(() => _isRecording = true);
        startTimer();
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    _cameraController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [

            FutureBuilder(
              future: _initializeCameraControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: CameraPreview(_cameraController!),
                  );
                } else {
                  return const Center(
                      child: CircularProgressIndicator(),
                  );
                }
              },
            ),

            Positioned(
              top: 40.0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28.0,
                      ),
                    ),

                    buildTime(),

                    IconButton(
                      onPressed: () {
                        if (widget.cameras.length > 1) {
                          setState(() {
                            selectedCamera = selectedCamera == 0 ? 1 : 0;//Switch camera
                            initializeCamera(selectedCamera);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('No secondary camera found'),
                            duration: Duration(seconds: 2),
                          ));
                        }
                      },
                      icon: selectedCamera == 0?const Icon(MdiIcons.cameraFront,color: Colors.white, size: 28.0,):const Icon(MdiIcons.cameraRear,color: Colors.white, size: 28.0,),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 20.0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: Center(
                  child: CircleButton(
                    icon: _isRecording?MdiIcons.stop:MdiIcons.record,
                    iconSize: 18.0,
                    iconColor: _isRecording?Colors.red:Palette.kuungaaDefault,
                    onPressed: (){
                      _recordVideo();
                    },
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
