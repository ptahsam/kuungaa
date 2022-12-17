import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kuungaa/allScreens/forgotPasswordScreen.dart';
import 'package:kuungaa/allScreens/friendScreen.dart';
import 'package:kuungaa/allScreens/loginScreen.dart';
import 'package:kuungaa/allScreens/nav_screen.dart';
import 'package:kuungaa/allScreens/registrationScreen.dart';
import 'package:kuungaa/allScreens/travelScreen.dart';
import 'package:kuungaa/allScreens/videosScreen.dart';
import 'package:kuungaa/config/SharedPreferences.dart';
import 'package:kuungaa/config/config.dart';
import 'package:kuungaa/config/palette.dart';
import 'package:kuungaa/config/themedata.dart';
import 'package:kuungaa/sharedWidgets/receive_call.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'DataHandler/appData.dart';
import 'allScreens/discussionScreen.dart';
import 'allScreens/mainScreen.dart';

final configurations = Configurations();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  /*await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: configurations.apiKey,
      appId: configurations.appId,
      messagingSenderId: configurations.messagingSenderId,
      projectId: configurations.projectId,
      databaseURL: configurations.databaseUrl
  ));*/
  //print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(options: FirebaseOptions(
        apiKey: configurations.apiKey,
        appId: configurations.appId,
        messagingSenderId: configurations.messagingSenderId,
        projectId: configurations.projectId,
        databaseURL: configurations.databaseUrl
    ));
  }else{
    await Firebase.initializeApp();
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Palette.kuungaaDefault, // navigation bar color
    statusBarColor: Palette.kuungaaDefault, // status bar color

  ));

  if (defaultTargetPlatform == TargetPlatform.android)
  {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  AwesomeNotifications().initialize(
      'resource://drawable/ic_stat_notif',
      [            // notification icon
        NotificationChannel(
          channelGroupKey: 'basic_test',
          channelKey: 'basic',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          channelShowBadge: true,
          playSound: true,
          soundSource: 'resource://raw/ic_notif_sound',
          vibrationPattern: lowVibrationPattern,
          importance: NotificationImportance.High,
        ),
        //add more notification type with different configuration
        NotificationChannel(
          channelGroupKey: 'chat_s',
          channelKey: 'chat',
          channelName: 'Chat',
          channelDescription: 'Kuungaa chat',
          channelShowBadge: true,
          playSound: true,
          soundSource: 'resource://raw/ic_notif_sound',
          importance: NotificationImportance.High,
          vibrationPattern: lowVibrationPattern,
          ledColor: Colors.white,
          defaultColor: const Color(0xFF2dce89),
        ),
      ],

    channelGroups: [
      NotificationChannelGroup(channelGroupKey: 'chat_s', channelGroupName: 'Chat'),
    ],

  );


  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessage);

  /*await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);*/

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  runApp(MyApp(initialLink: initialLink,));

}

// Declared as global, outside of any class
Future<void> firebaseBackgroundMessage(RemoteMessage message) async {
  message.data["channelKey"] == "chat"?AwesomeNotifications().createNotification(
      content: NotificationContent( //with image from URL
          id: 1,
          channelKey: 'chat',
          groupKey: 'chat_s', //channel configuration key
          customSound: 'resource://raw/ic_notif_sound',
          title: message.data["title"],
          body: message.data["body"],
          notificationLayout: NotificationLayout.Inbox,
          largeIcon: 'asset://images/profile.jpg',
          roundedLargeIcon: true,
          hideLargeIconOnExpand: true
      ),
      actionButtons: [
        NotificationActionButton(
            key: 'REPLY',
            label: 'Reply',
            autoDismissible: true,
            requireInputText: true),
        NotificationActionButton(
            key: 'READ', label: 'Mark as read', autoDismissible: true),
        NotificationActionButton(
            key: 'ARCHIVE', label: 'Archive', autoDismissible: true)
      ]
  ):AwesomeNotifications().createNotification(
    content: NotificationContent( //with image from URL
        id: 1,
        channelKey: 'basic', //channel configuration key
        title: message.data["title"],
        body: message.data["body"],
        bigPicture: message.data["image"],
        notificationLayout: NotificationLayout.BigPicture,
        payload: {"name":"flutter"}
    )
  );
}

/*const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title// description
  importance: Importance.high,
);*/

//final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("KUUNGAA").child("Users");

class LoadingApp extends StatefulWidget {
  const LoadingApp({Key? key}) : super(key: key);

  @override
  State<LoadingApp> createState() => _LoadingAppState();
}

class _LoadingAppState extends State<LoadingApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: const Align(
          alignment: Alignment.center,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}


class MyApp extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;
  const MyApp({
    Key? key,
    this.initialLink
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{

  AppData appData = AppData();
  Timer? _timerLink;
  bool onCall = false;

  Future<void> _retrieveDynamicLink() async {
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    if(data != null){
      //final Uri deepLink = data.link;
      //print("d-link in res:: " + deepLink.toString());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = Timer(const Duration(milliseconds: 1000), () {
        _retrieveDynamicLink();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink!.cancel();
    }
    super.dispose();
  }

  getIncomingCalls(){
    FirebaseDatabase.instance.reference().child("KUUNGAA").child("Calls").orderByChild("calleeid")
        .equalTo(FirebaseAuth.instance.currentUser!.uid).onChildAdded.listen((event) {
          if(event.snapshot.exists){
            var data = event.snapshot.value;
            if(data["status"] == "unanswered"){
              setState(() {
                onCall = true;
              });
            }
          }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DarkThemePreference darkThemePreference = DarkThemePreference();
    darkThemePreference.setDarkTheme(true);
    getCurrentAppTheme();
    //var initializationSettingsAndroid = new AndroidInitializationSettings('ic_launcher');
    //var initialzationSettingsAndroid = const AndroidInitializationSettings('@drawable/ic_stat_notif');
    //var initialzationSettingsIos = const IOSInitializationSettings();
    //var initializationSettings = InitializationSettings(android: initialzationSettingsAndroid, iOS: initialzationSettingsIos);
    //flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen(firebaseBackgroundMessage);

    /*FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;
      /*if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: HexColor("#2dce89"),
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: "@drawable/ic_stat_notif",
              ),
            )
        );
      }*/

      /*if (notification != null && apple != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: HexColor("#2dce89"),
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: "@drawable/ic_stat_notif",
              ),
            )
        );
      }*/

    });*/

    //getIncomingCalls();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
          // context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(notification.title!),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(notification.body!)],
                ),
              ),
            );
          }, context: context);
      }
    });

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      //displayToastMessage(dynamicLinkData.link.path.toString(), context);
      //print("d-link :: " + dynamicLinkData.link.path);
      //Navigator.pushNamed(context, dynamicLinkData.link.path);
      /*showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Link"),
            content: Text(dynamicLinkData.link.path.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok"),
              )
            ],
          )
      );*/
    }).onError((error) {
      // Handle errors
    });

    getToken();

    if(widget.initialLink != null){
      final Uri deepLink = widget.initialLink!.link;
      //displayToastMessage(deepLink.path.toString(), context);
     // print("d-link :: " + deepLink.toString());
      //print("d-link :: " + deepLink.path);
      //print("d-link :: " + deepLink.host);
      //print("d-link :: " + deepLink.data.toString());
      //print("d-link :: " + deepLink.queryParameters['pid']!);
      /*showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Link"),
          content: Text(deepLink.path.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Ok"),
            )
          ],
        )
      );*/
    }
  }

  String? token;
  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    //print("token ::" + token!);
    if(token != null || token != ""){
      usersRef.child(FirebaseAuth.instance.currentUser!.uid).child("user_tokenid").set(token!);
    }
  }

  void getCurrentAppTheme() async {
    appData.darkTheme =
    await appData.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context){
        return appData;
      },
      child: Consumer<AppData>(
        builder: (BuildContext context, value, Widget? child) {
          return MaterialApp(
            restorationScopeId: 'root',
            title: 'KUUNGAA',
            theme: Styles.themeData(appData.darkTheme, context),
            /*theme: ThemeData(
                fontFamily: "Sen Regular",
                primarySwatch: Colors.green,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),*/
            //initialRoute: FirebaseAuth.instance.currentUser == null? LoginPage.idScreen : NavScreen.idScreen,
            home: FirebaseAuth.instance.currentUser == null?onCall?ReceiveCall():LoginPage():NavScreen(postid: widget.initialLink != null?widget.initialLink!.link.queryParameters["pid"]:"",),
            routes: {
              '/register': (context) => const RegisterScreen(),
              '/login': (context) => const LoginPage(),
              '/forgotpassword': (context) => const ForgotpasswordScreen(),
              '/receivecall': (context) => const ReceiveCall(),
              LoginPage.idScreen: (context) => const LoginPage(),
              MainPage.idScreen: (context) => const MainPage(),
              NavScreen.idScreen: (context) => const NavScreen(),
              TravelPage.idScreen: (context) => const TravelPage(),
              DiscussionPage.idScreen: (context) => const DiscussionPage(),
              VideosPage.idScreen: (context) => const VideosPage(),
              FriendsPage.idScreen: (context) => const FriendsPage(),
              ReceiveCall.idScreen: (context) => const ReceiveCall(),
            },
            /*routes: {
              '/': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/mainpage': (context) => MainPage(),
            },*/
            debugShowCheckedModeBanner: false,
          );
        }
      ),
    );
  }
}


