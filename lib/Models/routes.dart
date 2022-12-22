import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:kuungaa/Models/notification_controller.dart';
import 'package:kuungaa/sharedWidgets/widgets.dart';

const String PAGE_HOME = '/';
const String PAGE_MEDIA_DETAILS = '/media-details';
const String PAGE_NOTIFICATION_DETAILS = '/notification-details';
const String PAGE_FIREBASE_TESTS = '/firebase-tests';
const String PAGE_PHONE_CALL = '/phone-call';

Map<String, WidgetBuilder> materialRoutes = {
  /*PAGE_HOME: (context) => const HomePage(),
  PAGE_MEDIA_DETAILS: (context) => MediaDetailsPage(),
  PAGE_NOTIFICATION_DETAILS: (context) => NotificationDetailsPage(
    ModalRoute.of(context)!.settings.arguments as ReceivedNotification,
  ),*/
  PAGE_PHONE_CALL: (context) {
    ReceivedAction? receivedAction =
    ModalRoute.of(context)!.settings.arguments == null
        ? NotificationsController.initialCallAction
        : ModalRoute.of(context)!.settings.arguments as ReceivedAction;

    return ReceiveCall(receivedAction: receivedAction!);
  }
};