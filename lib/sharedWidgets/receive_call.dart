import 'dart:convert';
import 'dart:io';

import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ReceiveCall extends StatefulWidget {
  const ReceiveCall({Key? key}) : super(key: key);

  static const String idScreen = "callPage";

  @override
  State<ReceiveCall> createState() => _ReceiveCallState();
}

class _ReceiveCallState extends State<ReceiveCall> {

  static const String url = "ws://192.168.100.118:3000";
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
  String cameraMode = 'user';

  void setLoudSpeaker(){
    remoteStream!.getAudioTracks()[0].enableSpeakerphone(loudSpeaker);
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
          'audio': false,
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
        {"event": "offer", "data": offer.toMap()},
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

    final filePath = dir.path + '/kuungaa/${userCurrentInfo!.user_firstname!}.mp4';
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
    connectToServer();
    localVideo.initialize();
    remoteVideo.initialize();
    initialization();
    super.initState();
  }

  @override
  void dispose() {
    peerConnection?.close();
    localVideo.dispose();
    remoteVideo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.kuungaaDefault,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        //title: const Text("Flutter webrtc websocket"),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_off : Icons.flash_on),
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: Icon(_isRec ? Icons.stop : Icons.fiber_manual_record),
            onPressed: _isRec ? _stopRecording : _startRecording,
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: RTCVideoView(
              showOnScreen?localVideo:remoteVideo,
              mirror: false,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: InkWell(
              onTap: (){
                setState(() {
                  showOnScreen = !showOnScreen;
                });
              },
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    width: 1.0,
                    color: Palette.kuungaaDefault,
                  ),
                ),
                child: RTCVideoView(
                  showOnScreen?remoteVideo:localVideo,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.amberAccent,
            //onPressed: () => registerPeerConnectionListeners(),
            onPressed: () => {
              registerPeerConnectionListeners(),
            },
            child: const Icon(
              Icons.settings_applications_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.blueGrey,
            onPressed: (){
              _toggleCamera();
            },
            child: const Icon(
              Icons.cameraswitch,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.redAccent,
            onPressed: (){
              Navigator.of(context).pop();
            },
            //onPressed: () => {makeCall()},
            child: const Icon(
              Icons.call_end_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              setState(() {
                loudSpeaker = !loudSpeaker;
              });
              /*channel.sink.add(
                jsonEncode(
                  {
                    "event": "msg",
                    "data": "Hi this is an offer",
                  },
                ),
              );*/
            },
            child: Icon(
              MdiIcons.microphone,
              color: loudSpeaker?Palette.kuungaaDefault:Colors.black,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
