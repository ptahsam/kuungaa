import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kuungaa/Models/user.dart';
import 'package:socket_io_client/socket_io_client.dart';
class JoinLive extends StatefulWidget {

  final Users liveUser;

  const JoinLive({
    Key? key,
    required this.liveUser
  }) : super(key: key);

  @override
  _JoinLiveState createState() => _JoinLiveState();
}

class _JoinLiveState extends State<JoinLive> {

  RTCPeerConnection? _peerConnection;
  final _remoteRenderer = RTCVideoRenderer();
  var peerConnections = {};

  var configuration = <String, dynamic>{
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
    ],
    //'sdpSemantics': sdpSemantics
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectToServer();
    initRenderers();
  }

  @override
  void deactivate() {
    super.deactivate();
    _remoteRenderer.dispose();
  }

  void initRenderers() async {
    await _remoteRenderer.initialize();
  }

  Future<void> connectToServer() async {
    try {

      print("connectingserver to server....");
      // Configure socket transports must be sepecified
      Socket socket = io('http://192.168.100.118:4000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false
      });

      socket.connect();

      _peerConnection = await createPeerConnection(configuration, offerSdpConstraints);

      _peerConnection!.onSignalingState = _onSignalingState;
      _peerConnection!.onIceGatheringState = _onIceGatheringState;
      _peerConnection!.onIceConnectionState = _onIceConnectionState;
      _peerConnection!.onConnectionState = _onPeerConnectionState;
      _peerConnection!.onIceCandidate = _onCandidate;
      _peerConnection!.onRenegotiationNeeded = _onRenegotiationNeeded;

      socket.on("offer", (data){
        print("connectingserver offer: ${data}");

        var id = data[0];
        var type = data[1]["type"];
        var sdp = data[1]["sdp"];

        RTCSessionDescription description = RTCSessionDescription(sdp, type);

          _peerConnection!
          .setRemoteDescription(description)
          .then((_) => _peerConnection!.createAnswer())
          .then((sdp) => _peerConnection!.setLocalDescription(sdp))
            .then((event) async{
            var desc = await _peerConnection!.createOffer(offerSdpConstraints);

            print("connectingserver desc: ${desc}");

            var sdp = desc.sdp;

            List d = [];

            Map a = {
              "type" : "answer",
              "sdp" : sdp
            };

            d.add(id);
            d.add(a);

            //print('connectingserver = $sdp');

         /* _peerConnection!.getLocalDescription().then((value){
            print("connectingserver: ${value}");
            socket.emit("answer", value);
          });*/



          socket.emit("answer", d);

        });

        _peerConnection!.onTrack = (event){
          _peerConnection!.addTrack(event.track);
        };

        _peerConnection!.onAddStream = (event){
          _peerConnection!.addStream(event);
        };


        _peerConnection!.onAddStream = _onAddStream;
        _peerConnection!.onTrack = _onTrack;
        _peerConnection!.onAddTrack = _onAddTrack;

        /*_peerConnection!.onAddStream = (event){
          setState(() {
            print("connectingserver stream: ${event}");
            _remoteRenderer.srcObject = event;
          });
        };*/

        /*_peerConnection!.onTrack = (event){
          setState(() {
            print("connectingserver track: ${event.streams[0]}");
            _remoteRenderer.srcObject = event.streams[0];
          });
          //print("connectingserver: ${event.streams[0]}");

        };*/
        _peerConnection!.onIceCandidate = (event){
          print("connectingserver ice candidate: ${event}");
          if (event.candidate != null) {
            List c = [];
            Map g = {
              "candidate" : event.candidate,
              "sdpMid" : event.sdpMid,
              "sdpMLineIndex" : event.sdpMLineIndex
            };
            c.add(id);
            c.add(g);
            socket.emit("candidate", c);
          }
        };
      });

    socket.on("candidate", (event){
      print("connectingserver candidate: ${event}");
      RTCIceCandidate candidate = RTCIceCandidate(event[1]['candidate'], event[1]['sdpMid'], event[1]['sdpMlineIndex']);
      _peerConnection!
          .addCandidate(candidate).catchError((e) => print(e));
      //print('connectingserver: ${candidate}');
    });

    socket.on("connect", (_){
      print('connectingserver id: ${socket.id}');
      socket.emit("watcher");
    });

    socket.on("broadcaster", (event){
      print('connectingserver broadcaster: ${event}');
      socket.emit("watcher");
    });

      /*socket.on('connect', (event){
        print('connectingserver: ${socket.id}');
        //socket.emit("watcher");
      });*/

      /*socket.on("offer", (data) => {
        print("connectingserver: ${data}")
      });

      socket.on('offer', (event) async{
        print("connectingserver: ${event[1]["type"]}");
        var id = event[0];
        var type = event[1]["type"];
        var sdp = event[1]["sdp"];

        _peerConnection = await createPeerConnection(configuration);

        RTCSessionDescription description = RTCSessionDescription(sdp, type);


        _peerConnection!.setRemoteDescription(description);
        RTCSessionDescription desc = await _peerConnection!.createAnswer();

        _peerConnection!.setLocalDescription(desc);

        List d = [];
        d.add(id);
        d.add(sdp);

        //print("connectingserver: ${newdescription}");
        
        socket.emit("answer", event);

        _peerConnection!.onAddStream = (stream) {
          print("connectingserver: ${stream}");
          try{
            setState(() {
              _remoteRenderer.srcObject = stream;
            });
          }catch(e) {
            print(e);
          }
        };

        _peerConnection!.onTrack = (event){
          print("connectingserver: ${event}");
          setState(() {
            _remoteRenderer.srcObject = event.streams[0];
          });
        };

        _peerConnection!.onIceCandidate = (event){
          print("connectingserver: ${event}");
          if (event.candidate != null) {
            socket.emit("candidate", event.candidate);
          }
        };

        //print("connectingserver ::" + description);
      });

      socket.on("candidate", (event){
        print("connectingserver: ${event[1]["candidate"]}");
        //var candidate = event[1]["candidate"];
        dynamic candidate = RTCIceCandidate(event[1]['candidate'], event[1]['sdpMid'], event[1]['sdpMlineIndex']);

        _peerConnection!.addCandidate(candidate).catchError((e) => {
          print(e)
        });
      });*/

      //_peerConnection = await createPeerConnection(configuration);
      /*socket.on("offer", (event) async {
        print('connectingserver: ${event}');

      });

      socket.on("candidate", (event){
        print('connectingserver: ${event}');
        //dynamic candidate = RTCIceCandidate(event[1]['candidate'], event[1]['sdpMid'], event[1]['sdpMlineIndex']);
        /*_peerConnection!.addCandidate(candidate).catchError((e) => {
          print(e)
        });*/
      });

      socket.on("broadcaster", (event){
        print('connectingserver: ${event}');
        socket.emit("watcher");
      });

      // Connect to websocket
      //socket.connect();

      // Handle socket events
      socket.on('connect', (event){
        print('connectingserver: ${socket.id}');
        socket.emit("watcher");
      });*/


      /*socket.on('connect', (_) =>
          print('connectingserver: ${socket.id}')
      );*/
      //socket.on('location', handleLocationListen);
      //socket.on('typing', handleTyping);
      //socket.on('message', handleMessage);
      /*socket.on("offer", (description) async{
        print("connectingserver: ${description}");
        _peerConnection = await createPeerConnection(configuration);
        //RTCSessionDescription description = RTCSessionDescription();
        _peerConnection!.setRemoteDescription(description).then((value){
          _peerConnection!.createAnswer();
        }).then((sdp) => _peerConnection!.setLocalDescription(description))
            .then((value){
          socket.emit("answer", _peerConnection!.getLocalDescription());
        });

        _peerConnection!.onTrack = (event) => {
        _remoteRenderer.srcObject = event.streams[0]
        };

        _peerConnection!.onIceCandidate = (event) => {
          if (event.candidate != null) {
            socket.emit("candidate", event.candidate)
          }
        };

        //print("connectingserver ::" + description);
      });*/



      /*socket.on("connect", (_) => {
        print("connectingserver: ${candidate}"),
        socket.emit("watcher")
      });*/
      //socket.on('disconnect', (event) => print('disconnect'));
      //socket.on('fromServer', (event) => print(event));

    } catch (e) {
      print("connectingserver errors ::" + e.toString());
    }
  }

  void _onSignalingState(RTCSignalingState state) {
    print("connectingserver RTCSignalingState:: ${state}");
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    print("connectingserver RTCIceGatheringState:: ${state}");
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    print("connectingserver RTCIceConnectionState:: ${state}");
  }

  void _onPeerConnectionState(RTCPeerConnectionState state) {
    print("connectingserver RTCPeerConnectionState:: ${state}");
  }

  void _onAddStream(MediaStream stream) {
    print('New stream: ' + stream.id);
    /*setState(() {
      //_remoteRenderer.srcObject = stream;
    });*/
  }

  void _onRemoveStream(MediaStream stream) {
    _remoteRenderer.srcObject = null;
  }

  void _onCandidate(RTCIceCandidate candidate) {
    print('connectingserver::onCandidate: ${candidate.candidate}');
    _peerConnection?.addCandidate(candidate);
  }

  void _onTrack(RTCTrackEvent event) {
    print(' connectingserver:: onTrack');
    if (event.track.kind == 'video') {
      print(' connectingserver:: onTrack is video');
      _remoteRenderer.srcObject = event.streams[0];
    }
  }

  void _onAddTrack(MediaStream stream, MediaStreamTrack track) {
    if (track.kind == 'video') {
      print(' connectingserver:: onTrack is video');
      _remoteRenderer.srcObject = stream;
    }
  }

  void _onRemoveTrack(MediaStream stream, MediaStreamTrack track) {
    if (track.kind == 'video') {
      _remoteRenderer.srcObject = null;
    }
  }

  void _onRenegotiationNeeded() {
    print('connectingserver:: RenegotiationNeeded');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey,
        child: RTCVideoView(_remoteRenderer),
      ),
    );
  }
}
