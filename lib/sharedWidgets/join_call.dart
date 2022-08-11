import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
class JoinCall extends StatefulWidget {
  const JoinCall({Key? key}) : super(key: key);

  @override
  State<JoinCall> createState() => _JoinCallState();
}

class _JoinCallState extends State<JoinCall> {

  IOWebSocketChannel? channel;

  @override
  void initState() {
    // TODO: implement initState
    connectToServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }

  void connectToServer() {
    try{
      channel = IOWebSocketChannel.connect("ws://192.168.100.118:3000");
      channel!.stream.listen((message) {
        print("connect channel ::" + message);
        /*setState(() {
          if(message == "connected"){
            //connected = true;
            setState(() { });
            print("Connection establised.");
          }else if(message == "send:success"){
            print("Message send success");
            setState(() {
             // msgtext.text = "";
            });
          }else if(message == "send:error"){
            print("Message send error");
          }else if (message.substring(0, 6) == "{'cmd'") {
            print("Message data");
            message = message.replaceAll(RegExp("'"), '"');
            var jsondata = json.decode(message);

            msglist.add(MessageData( //on message recieve, add data to model
              msgtext: jsondata["msgtext"],
              userid: jsondata["userid"],
              isme: false,
            )
            );
            setState(() { //update UI after adding data to message model

            });
          }
        });*/
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
        },);
    }catch (_){
      print(" connect channel :: error on connecting to websocket.");
    }
  }
}
