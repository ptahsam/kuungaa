import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MakeCall extends StatefulWidget {
  final Users user;
  const MakeCall({
    Key? key,
    required this.user
  }) : super(key: key);

  @override
  State<MakeCall> createState() => _MakeCallState();
}

class _MakeCallState extends State<MakeCall> {

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


  // Connecting with websocket Server
  void connectToServer() {
    try {
      channel = WebSocketChannel.connect(Uri.parse(url));

      channel.stream.listen(
              (message) async {
            Map<String, dynamic> decoded = jsonDecode(message);
            if (decoded["type"] == "answer") {
              // Set the offer SDP to remote description
              await peerConnection?.setRemoteDescription(
                RTCSessionDescription(
                  decoded["answer"]["sdp"],
                  decoded["answer"]["type"],
                ),
              );

              // Create an answer
              //RTCSessionDescription answer = await peerConnection!.createAnswer();

              // Set the answer as an local description
              //await peerConnection!.setLocalDescription(answer);

              // Send the answer to the other peer
              /*channel.sink.add(
                jsonEncode(
                  {
                    "type": "send_answer",
                    "answer": answer.toMap(),
                    "username": userCurrentInfo!.user_id!
                  },
                ),
              );*/
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

  // Help to debug our code
  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      channel.sink.add(
        jsonEncode({"type": "store_candidate", "candidate": candidate.toMap(), "username": userCurrentInfo!.user_id!}),
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
          "type": "store_user",
          "username": userCurrentInfo!.user_id!
        },
      ),
    );

    makeCall();
  }

  void saveCallDetails(){
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Calls").push();
    var callID = dbRef.key;
    dbRef.set({
      "callid" : callID,
      "calleeid" : widget.user.user_id!,
      "callerid": userCurrentInfo!.user_id!,
      "status": "unanswered"
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
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
