import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kuungaa/DataHandler/appData.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'widgets.dart';

class TermsAndCondition extends StatefulWidget {
  const TermsAndCondition({Key? key}) : super(key: key);

  @override
  State<TermsAndCondition> createState() => _TermsAndConditionState();
}

class _TermsAndConditionState extends State<TermsAndCondition> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<AppData>(context).darkTheme?Palette.lessDarker:Colors.white,
      body: SafeArea(
        child: WebView(
          onPageStarted: (String){
            displayToastMessage("Loading Web Page :: ${String}", context);
          },
          onPageFinished: (String){
            displayToastMessage("Loaded Web Page :: ${String}", context);
          },
          initialUrl: 'https://kuungaa.com/termsandconditions/',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
