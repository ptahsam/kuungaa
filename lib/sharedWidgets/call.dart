import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
class Call extends StatefulWidget {
  const Call({Key? key}) : super(key: key);

  @override
  _CallState createState() => _CallState();
}

class _CallState extends State<Call> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectToServer();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void connectToServer() {
    Socket socket = io('ws://192.168.100.211:3000', <String, dynamic>{
      'transports': ['websocket', 'polling']
      //'autoConnect': false,
    });

    socket.connect();

    socket.on("connect", (_){
      print('connectingserver: ${socket.id}');
      socket.emit("watcher");
    });
  }


}
