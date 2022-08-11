import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/sharedWidgets/circle_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GoLive extends StatefulWidget {
  const GoLive({Key? key}) : super(key: key);

  @override
  _GoLiveState createState() => _GoLiveState();
}

class _GoLiveState extends State<GoLive> {
  RTCPeerConnection? _peerConnection;
  var peerConnections = {};
  var stream;
  MediaStream? _localStream;
  final _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool _isTorchOn = false;
  bool _isAudioOn = false;
  MediaRecorder? _mediaRecorder;
  bool get _isRec => _mediaRecorder != null;

  List<MediaDeviceInfo>? _mediaDevicesList;

  var configuration = <String, dynamic>{
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
    ],
    //'sdpSemantics': sdpSemantics
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initRenderers();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _hangUp();
    }
    _localRenderer.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
  }

  initServer(){
    print("connectingserver");
    // Configure socket transports must be sepecified
    Socket socket = io('http://192.168.100.211:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });

    socket.connect();

    socket.on('connect', (event){
      print('connectingserver: ${socket.id}');
      //socket.emit("watcher");
    });

    socket.on('answer', (event){
      print('connectingserver: ${socket.id}');
    });

    socket.on('watcher', (_) {
      print('connectingserver: ${socket.id}');
    });

    /*socket.on('answer', (event){
      print('connectingserver answer: ${event}');
      var id = event[0];
      //var type = event[1]["type"];
      //var sdp = event[1]["sdp"];
     // RTCSessionDescription description = RTCSessionDescription(sdp, type);
      peerConnections[id].setRemoteDescription(event[1]);
    });

    socket.on('watcher', (event) async{
      print('connectingserver watcher: ${event}');

      var id = event[0];
      _peerConnection = await createPeerConnection(configuration);
      peerConnections[id] = _peerConnection;

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, stream);
      });

      _peerConnection!.onIceCandidate = (event){
        print("connectingserver icecandidate: ${event}");
        if (event.candidate != null) {
          socket.emit("candidate", event.candidate);
        }
      };

      List d = [];
      d.add(id);

      _peerConnection!.createOffer().then((value){
        _peerConnection!.setLocalDescription(value);
        d.add(value);
      }).then((value){
        socket.emit("offer", d);
      });
    });

    socket.on("candidate", (event){
      print("connectingserver icecandidate: ${event}");
      var id = event[0];
      dynamic candidate = RTCIceCandidate(event[1]['candidate'], event[1]['sdpMid'], event[1]['sdpMlineIndex']);
      peerConnections[id].addIceCandidate(candidate);
    });

    socket.on("disconnectPeer", (event){
      print("connectingserver disconnectpeer: ${event}");
      var id = event[0];
      peerConnections[id].close();
      peerConnections.remove(id);
      //delete peerConnections[id];
    });*/
  }

  // Platform messages are asynchronous, so we initialize in an async method.
   void _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': _isAudioOn,
      'video': {
        'mandatory': {
          'minWidth':
          MediaQuery.of(context).size.width.round().toString(), // Provide your own width, height and frame rate here
          'minHeight': MediaQuery.of(context).size.height.round().toString(),
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    try {
      stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
      _localStream = stream;
      _localRenderer.srcObject = _localStream;

      initServer();

    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  void _hangUp() async {
    try {
      if (kIsWeb) {
        _localStream?.getTracks().forEach((track) => track.stop());
      }
      await _localStream?.dispose();
      _localRenderer.srcObject = null;
      setState(() {
        _inCalling = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _startRecording() async {
    if (_localStream == null) throw Exception('Stream is not initialized');
    if (Platform.isIOS) {
      print('Recording is not available on iOS');
      return;
    }
    // TODO(rostopira): request write storage permission
    final storagePath = await getExternalStorageDirectory();
    if (storagePath == null) throw Exception('Can\'t find storagePath');

    final filePath = storagePath.path + '/webrtc_sample/test.mp4';
    _mediaRecorder = MediaRecorder();
    setState(() {});

    final videoTrack = _localStream!
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
    if (_localStream == null) throw Exception('Stream is not initialized');

    final videoTrack = _localStream!
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

  void _toggleCamera() async {
    if (_localStream == null) throw Exception('Stream is not initialized');

    final videoTrack = _localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    await Helper.switchCamera(videoTrack);
  }

  void _captureFrame() async {
    if (_localStream == null) throw Exception('Stream is not initialized');

    final videoTrack = _localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    final frame = await videoTrack.captureFrame();
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content:
          Image.memory(frame.asUint8List(), height: 720, width: 1280),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(context, rootNavigator: true).pop,
              child: const Text('OK'),
            )
          ],
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          OrientationBuilder(
            builder: (context, orientation) {
              return Container(
                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                padding: EdgeInsets.zero,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: RTCVideoView(_localRenderer, mirror: true),
              );
            },
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: Palette.createLiveGradient,
            ),
            child: _inCalling?Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.userFriends),
                    onPressed: _toggleTorch,
                    color: Colors.white,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06,),
                  IconButton(
                    icon: const Icon(MdiIcons.messageOutline),
                    onPressed: _toggleTorch,
                    color: Colors.white,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06,),
                  IconButton(
                    icon: const Icon(MdiIcons.link),
                    onPressed: _toggleTorch,
                    color: Colors.white,
                  ),
                ],
              ),
            ):const SizedBox.shrink(),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 50.0, left: 12.0, right: 12.0),
                decoration: const BoxDecoration(
                  color: Colors.black54
                ),
                child: _inCalling?Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: Icon(_isTorchOn ? Icons.flash_off : Icons.flash_on),
                      onPressed: _toggleTorch,
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: const Icon(Icons.switch_video),
                      onPressed: _toggleCamera,
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera),
                      onPressed: _captureFrame,
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: Icon(_isRec ? Icons.stop : Icons.fiber_manual_record),
                      onPressed: _isRec ? _stopRecording : _startRecording,
                      color: Colors.white,
                    ),
                    /*PopupMenuButton<String>(
                      onSelected: _selectAudioOutput,
                      itemBuilder: (BuildContext context) {
                        if (_mediaDevicesList != null) {
                          return _mediaDevicesList!
                              .where((device) => device.kind == 'audiooutput')
                              .map((device) {
                            return PopupMenuItem<String>(
                              value: device.deviceId,
                              child: Text(device.label),
                            );
                          }).toList();
                        }
                        return [];
                      },
                    ),*/
                  ],
                ):const SizedBox.shrink(),
              ),
            ),
          ),

          Positioned(
            bottom: 20.0,
            right: 0.0,
            left: 0.0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _inCalling? CircleButton(
                    icon: _isAudioOn ? MdiIcons.microphoneOutline : MdiIcons.microphoneOff,
                    onPressed: (){
                      setState(() {
                        if(_isAudioOn){
                          _isAudioOn = false;
                        }else{
                          _isAudioOn = true;
                        }
                      });
                    },
                    iconSize: 24.0,
                  ):const SizedBox.shrink(),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.10,),
                  CircleButton(
                    icon: _inCalling ? Icons.close : Icons.fiber_manual_record,
                    onPressed: _inCalling ? _hangUp : _makeCall,
                    iconSize: 24.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAudioOutput(String deviceId) {
    _localRenderer.audioOutput(deviceId);
  }
}
