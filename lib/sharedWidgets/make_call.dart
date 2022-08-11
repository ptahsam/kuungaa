import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kuungaa/config/config.dart';
import 'package:web_socket_channel/io.dart';
class MakeCall extends StatefulWidget {
  final String username;
  const MakeCall({
    Key? key,
    required this.username
  }) : super(key: key);

  @override
  State<MakeCall> createState() => _MakeCallState();
}

class _MakeCallState extends State<MakeCall> {

  IOWebSocketChannel? channel;

  RTCPeerConnection? _peerConnection;

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  Timer? _timer;
  var _counter = 0;

  @override
  void initState() {
    // TODO: implement initState
    initRenderers();
    super.initState();
    connectToServer();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _stop();
    }
    _timer?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void handleTimer(Timer timer) async {
    setState(() {
      _counter++;
    });
  }

  void _onAddStream(MediaStream stream) {
    print("connect channel :: adding remote stream");
    print('New stream: ' + stream.id);
    _remoteRenderer.srcObject = stream;
  }

  void _onCandidate(RTCIceCandidate candidate) {
    print("connect channel :: getting candidate");
    print('onCandidate: ${candidate.candidate}');
    _peerConnection?.addCandidate(candidate);
      Map data = {
        "type" : "store_candidate",
        "candidate" : candidate,
        "username" : widget.username
      };
      channel!.sink.add(jsonEncode(data));
  }

  void createAndSendOffer() async{
    //print("connect channel :: creating offer");
    var desc = await _peerConnection!.createOffer();
    print("connect channel :: creating offer ${desc}");
    var sdp = desc.sdp;

    Map a = {
      "sdp" : sdp,
      "type" : "offer"
    };

    Map data = {
      "username" : widget.username,
      "type" : "store_offer",
      "offer" : a
    };
    channel!.sink.add(jsonEncode(data));
    _peerConnection!.setLocalDescription(desc);
  }

  Future<void> _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '480',
          'idealWidth' : '720',
          'maxWidth' : '1280',// Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
          'aspectRatio' : '1.33333',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    var configuration = <String, dynamic>{
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ],
      //'sdpSemantics': sdpSemantics
    };

    try {
      var stream =
      await navigator.mediaDevices.getUserMedia(mediaConstraints);
      stream.getVideoTracks()[0].onEnded = () {
        print(
            'By adding a listener on onEnded you can: 1) catch stop video sharing on Web');
      };

      _localStream = stream;
      _localRenderer.srcObject = _localStream;

      _peerConnection = await createPeerConnection(configuration);
      _peerConnection!.addStream(_localStream!);

      _peerConnection!.onAddStream = _onAddStream;

      //_peerConnection!.onIceCandidate = _onCandidate;
      _peerConnection!.onIceCandidate = (event){
        if (event.candidate != null) {
          print("connect channel :: getting candidate");
          print('onCandidate: ${event.candidate}');
          //_peerConnection?.addCandidate(event);
          Map g = {
            "candidate" : event.candidate,
            "sdpMid" : event.sdpMid,
            "sdpMLineIndex" : event.sdpMLineIndex
          };

          Map data = {
            "type" : "store_candidate",
            "candidate" : g,
            "username" : widget.username
          };
          channel!.sink.add(jsonEncode(data));
        }
      };

      createAndSendOffer();

      saveCallDetails();

    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1000), handleTimer);
  }

  Future<void> _stop() async {
    try {
      if (kIsWeb) {
        _localStream?.getTracks().forEach((track) => track.stop());
      }
      await _localStream?.dispose();
      _localStream = null;
      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _hangUp() async {
    await _stop();
    setState(() {
      _inCalling = false;
    });
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Stack(children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(color: Colors.black54),
                child: RTCVideoView(_remoteRenderer),
              ),
              Positioned(
                child: Text('counter: ' + _counter.toString()),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: RTCVideoView(_localRenderer),
                  ),
                ),
              ),
            ]),
          );
        },
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),*/
    );
  }

  void connectToServer() {

    print("connect channel ::");
    channel = IOWebSocketChannel.connect(Uri.parse("ws://192.168.100.118:3000"));
    sendUsername();
    channel!.stream.listen((event) {
      print("connect channel signalling data ::" + event[1]);
      print("connect channel signalling data ::" + event[0]["type"]);
      //handleSignallingServer(jsonDecode(event));
    },

      onDone: () {
        //if WebSocket is disconnected
        print("connect channel :: Web socket is closed");
        setState(() {
          //connected = false;
        });
      },

      onError: (error) {
        print("connect channel ::" + error.toString());
      },
    );
    _makeCall();
  }

  void handleSignallingServer(data) {
    print("connect channel :: signalling ${data}");
    switch (data.type) {
      case "answer":
        _peerConnection!.setRemoteDescription(data.answer);
        break;
      case "candidate":
        _peerConnection!.addCandidate(data.candidate);
    }
  }

  void sendUsername() {
    print("connect channel :: sending username");
    Map data = {
      "username" : widget.username,
      "type" : "store_user"
    };
    channel!.sink.add(jsonEncode(data));
  }

  void saveCallDetails() {
    DatabaseReference callRef = FirebaseDatabase.instance.reference().child('KUUNGAA').child('Calls').push();
    String groupKey = callRef.key;

    Map callMap = {
      "callid" : groupKey,
      "calleeid" : widget.username,
      "callerid" : userCurrentInfo!.user_id!,
      "status" : "unanswered"
    };
    callRef.set(callMap);
  }

}
