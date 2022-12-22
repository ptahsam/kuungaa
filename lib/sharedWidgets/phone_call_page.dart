import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/android_foreground_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PhoneCallPage extends StatefulWidget {

  final ReceivedAction? receivedAction;

  const PhoneCallPage({
    Key? key, this.receivedAction,
  }) : super(key: key);

  @override
  State<PhoneCallPage> createState() => _PhoneCallPageState();
}

class _PhoneCallPageState extends State<PhoneCallPage> {
  final RTCVideoRenderer localVideo = RTCVideoRenderer();
  final RTCVideoRenderer remoteVideo = RTCVideoRenderer();
  late final MediaStream localStream;
  late final WebSocketChannel channel;
  MediaStream? remoteStream;
  RTCPeerConnection? peerConnection;
  MediaRecorder? _mediaRecorder;
  bool get _isRec => _mediaRecorder != null;

  bool _isTorchOn = false;
  bool showOnScreen = false;
  bool loudSpeaker = false;
  bool isSound = false;
  bool videoReady = false;
  String cameraMode = 'user';

  Timer? _timer;
  Duration _secondsElapsed = Duration.zero;

  void startCallingTimer() {
    const oneSec = Duration(seconds: 1);
    cancelNotification(widget.receivedAction!.id!);
    AndroidForegroundService.stopForeground(widget.receivedAction!.id!);

    _timer = Timer.periodic(
      oneSec, (Timer timer) {
      setState(() {
        _secondsElapsed += oneSec;
      });
    },
    );
  }

  void finishCall(){
    Vibration.vibrate(duration: 100);
    cancelNotification(widget.receivedAction!.id!);
    AndroidForegroundService.stopForeground(widget.receivedAction!.id!);
    Navigator.pop(context);
  }

  // Connecting with websocket Server
  void connectToServer() {
    try {
      channel = WebSocketChannel.connect(Uri.parse(url));

      channel.stream.listen(
              (message) async {
            Map<String, dynamic> decoded = jsonDecode(message);
            print("peter connect ::" + message.toString());
            if (decoded["type"] == "offer") {
              // Set the offer SDP to remote description
              await peerConnection?.setRemoteDescription(
                RTCSessionDescription(
                  decoded["offer"]["sdp"],
                  decoded["offer"]["type"],
                ),
              );

              // Create an answer
              RTCSessionDescription answer = await peerConnection!.createAnswer();

              // Set the answer as an local description
              await peerConnection!.setLocalDescription(answer);

              // Send the answer to the other peer
              channel.sink.add(
                jsonEncode(
                  {
                    "type": "send_answer",
                    "answer": answer.toMap(),
                    "username": userCurrentInfo!.user_id!
                  },
                ),
              );
            }
            // If client receive an Ice candidate from the peer
            else if (decoded["type"] == "candidate") {
              // It add to the RTC peer connection
              peerConnection?.addCandidate(RTCIceCandidate(
                  decoded["candidate"]["candidate"],
                  decoded["candidate"]["sdpMid"],
                  decoded["candidate"]["sdpMLineIndex"]));
            }
            // If Client recive an reply of their offer as answer

            else if (decoded["event"] == "answer") {
              await peerConnection?.setRemoteDescription(RTCSessionDescription(
                  decoded["data"]["sdp"], decoded["data"]["type"]));
            }
            // If no condition fulfilled? printout the message
            else {
              print(decoded);
            }
          }
      );
    }
    catch (e) {
      throw "ERROR $e";
    }
  }

  // STUN server configuration
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  // This must be done as soon as app loads
  void initialization() async {
    // Getting video feed from the user camera
    localStream = await navigator.mediaDevices
        .getUserMedia({
      'audio': isSound,
      'video': {
        'mandatory': {
          'minWidth':
          '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': cameraMode,
        'optional': [],
      }
    });

    // Set the local video to display
    localVideo.srcObject = localStream;
    // Initializing the peer connecion
    peerConnection = await createPeerConnection(configuration);
    setState(() {});
    // Adding the local media to peer connection
    // When connection establish, it send to the remote peer
    localStream.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream);
    });
  }

  void makeCall() async {
    // Creating a offer for remote peer
    RTCSessionDescription offer = await peerConnection!.createOffer();

    // Setting own SDP as local description
    await peerConnection?.setLocalDescription(offer);

    // Sending the offer
    channel.sink.add(
      jsonEncode(
        {
          "type": "store_offer",
          "offer": offer.toMap(),
          "username": userCurrentInfo!.user_id!
        },
      ),
    );
  }

  // Help to debug our code
  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      channel.sink.add(
        jsonEncode({"type": "send_candidate", "candidate": candidate.toMap(), "username": userCurrentInfo!.user_id!}),
      );
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onTrack = ((tracks) {
      tracks.streams[0].getTracks().forEach((track) {
        remoteStream?.addTrack(track);
      });
    });

    // When stream is added from the remote peer
    peerConnection?.onAddStream = (MediaStream stream) {
      remoteVideo.srcObject = stream;
      videoReady = true;
      setState(() {});
    };

    channel.sink.add(
      jsonEncode(
        {
          "type": "join_call",
          "username": userCurrentInfo!.user_id!
        },
      ),
    );
  }

  void _toggleCamera() async {
    if (localStream == null) throw Exception('Stream is not initialized');

    final videoTrack = localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    await Helper.switchCamera(videoTrack);
  }

  void _startRecording() async {
    if (localStream == null) throw Exception('Stream is not initialized');
    if (Platform.isIOS) {
      print('Recording is not available on iOS');
      return;
    }
    // TODO(rostopira): request write storage permission
    final storagePath = await getExternalStorageDirectory();
    Directory dir = Directory('/storage/emulated/0/Download');
    if (dir.path == null) throw Exception('Can\'t find storagePath');

    final filePath = dir.path + '/kuungaa/${DateTime.now().millisecondsSinceEpoch}.mp4';
    _mediaRecorder = MediaRecorder();
    setState(() {});

    final videoTrack = localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    await _mediaRecorder!.start(
      filePath,
      videoTrack: videoTrack,
    );
  }

  void _stopRecording() async {
    await _mediaRecorder?.stop();
    setState(() {
      _mediaRecorder = null;
    });
  }

  void _toggleTorch() async {
    if (localStream == null) throw Exception('Stream is not initialized');

    final videoTrack = localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    final has = await videoTrack.hasTorch();
    if (has) {
      print('[TORCH] Current camera supports torch mode');
      setState(() => _isTorchOn = !_isTorchOn);
      await videoTrack.setTorch(_isTorchOn);
      print('[TORCH] Torch state is now ${_isTorchOn ? 'on' : 'off'}');
    } else {
      print('[TORCH] Current camera does not support torch mode');
    }
  }

  @override
  void initState() {
    lockScreenPortrait();
    connectToServer();
    localVideo.initialize();
    remoteVideo.initialize();
    initialization();
    super.initState();
    if(widget.receivedAction!.buttonKeyPressed == 'ACCEPT') {
      //startCallingTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    unlockScreenPortrait();
    cancelNotification(widget.receivedAction!.id!);
    AndroidForegroundService.stopForeground(widget.receivedAction!.id!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    ThemeData themeData = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image(
            image: widget.receivedAction!.largeIconImage!,
            fit: BoxFit.cover,
          ),
          // Black Layer
          const DecoratedBox(
            decoration: BoxDecoration(color: Colors.black45),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: RTCVideoView(
              remoteVideo,
              mirror: false,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: _timer != null?Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receivedAction!.payload?['username']?.replaceAll(r'\s+', r'\n')
                      ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.black54.withOpacity(0.5),
                  ),
                  child: Text(
                    printDuration(_secondsElapsed),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                        decoration: TextDecoration.none
                    ),
                  ),
                )
              ],
            ):SizedBox.shrink(),
          ),
          Positioned(
            right: 20,
            bottom: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RoundedButton(
                  press: _toggleTorch,
                  color: Colors.blueAccent,
                  icon: Icon(_isTorchOn ? Icons.flash_off : Icons.flash_on),
                ),
                Spacer(),
                RoundedButton(
                  press: _isRec ? _stopRecording : _startRecording,
                  color: Palette.kuungaaDefault,
                  icon: Icon(_isRec ? Icons.stop : Icons.fiber_manual_record, color: _isRec?Colors.red:Colors.white,),
                ),
                Spacer(),
                RoundedButton(
                  press: _toggleCamera,
                  color: Colors.grey,
                  icon: Icon(Icons.cameraswitch,),
                ),
              ],
            ),
          ),
          Positioned(
            top: 70,
            right: 20,
            child: _timer!=null?Container(
              height: 120,
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: RTCVideoView(
                  localVideo,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ):SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _timer == null?Text(
                    widget.receivedAction!.payload?['username']?.replaceAll(r'\s+', r'\n')
                        ?? 'Unknown',
                    maxLines: 4,
                    style: themeData
                        .textTheme
                        .headline3
                        ?.copyWith(color: Colors.white),
                  ):SizedBox.shrink(),
                  _timer == null?Text(
                    'Incoming call',
                    style: themeData
                        .textTheme
                        .headline6
                        ?.copyWith(color: Colors.white54, fontSize: _timer == null ? 20 : 12),
                  ):SizedBox.shrink(),
                  const SizedBox(height: 50),
                  _timer == null ?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: (){},
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all<Color>(Colors.white12),
                          ),
                          child: Column(
                            children: [
                              const Icon(FontAwesomeIcons.solidClock, color: Colors.white54),
                              Text('Reminder me', style:  themeData
                                  .textTheme
                                  .headline6
                                  ?.copyWith(color: Colors.white54, fontSize: 12, height: 2))
                            ],
                          )
                      ),
                      const SizedBox(),
                      TextButton(
                        onPressed: (){},
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all<Color>(Colors.white12),
                        ),
                        child: Column(
                          children: [
                            const Icon(FontAwesomeIcons.solidEnvelope, color: Colors.white54),
                            Text('Message', style:  themeData
                                .textTheme
                                .headline6
                                ?.copyWith(color: Colors.white54, fontSize: 12, height: 2))
                          ],
                        ),
                      )
                    ],
                  ) : const SizedBox(),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(45)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _timer == null ?
                      [
                        RoundedButton(
                          press: finishCall,
                          color: Colors.red,
                          icon: const Icon(FontAwesomeIcons.phoneAlt, color: Colors.white),
                        ),
                        SingleSliderToConfirm(
                          onConfirmation: (){
                            Vibration.vibrate(duration: 100);
                            startCallingTimer();
                            registerPeerConnectionListeners();
                          },
                          width: mediaQueryData.size.width * 0.55,
                          backgroundColor: Colors.white60,
                          text: 'Slide to Talk',
                          stickToEnd: true,
                          textStyle: Theme.of(context)
                              .textTheme
                              .headline6
                              ?.copyWith(color: Colors.white, fontSize: mediaQueryData.size.width * 0.05),
                          sliderButtonContent: RoundedButton(
                            press: (){},
                            color: Colors.white,
                            icon: const Icon(FontAwesomeIcons.phoneAlt, color: Colors.green),
                          ),
                        )
                      ] :
                      [
                        RoundedButton(
                          press: (){
                            setState(() {
                              isSound = !isSound;
                            });
                          },
                          color: Colors.white,
                          icon: Icon(
                            isSound?FontAwesomeIcons.microphone:FontAwesomeIcons.volumeMute,
                            color: Colors.black,
                          ),
                        ),
                        RoundedButton(
                          press: finishCall,
                          color: Colors.red,
                          icon: const Icon(FontAwesomeIcons.phoneAlt, color: Colors.white),
                        ),
                        RoundedButton(
                          press: (){},
                          color: Colors.white,
                          icon: const Icon(FontAwesomeIcons.volumeUp, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    Key? key,
    this.size = 64,
    required this.icon,
    this.color = Colors.white,
    required this.press,
  }) : super(key: key);

  final double size;
  final Icon icon;
  final Color color;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      // ignore: deprecated_member_use
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.all(15 / 64 * size),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
        ),
        onPressed: press,
        child: icon,
      ),
    );
  }
}