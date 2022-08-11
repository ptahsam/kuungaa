import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class ProgressDialog extends StatelessWidget {

  String message;
  ProgressDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HexColor("#2dce89"),
      child: Container(
        margin: const EdgeInsets.all(1.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              const SizedBox(width: 6.0,),
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(HexColor("#2dce89")),),
              const SizedBox(width: 15.0,),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: HexColor("#2dce89"),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
