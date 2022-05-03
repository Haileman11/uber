import 'dart:convert';
import 'dart:io';
import 'package:common/services/navigator_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }
  String? token;
  Map? bookingRequestJson;
  Map? ongoingRideJson;
  Map? completeRideJson;
  NotificationService._internal();
  late NavigationService _navigationService;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  void onData(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    print(message.data);
    if (message.data["bookingRequestId"] != null) {
      bookingRequestJson = message.data;
      notifyListeners();
    }
    if (message.data["bookedRideId"] != null) {
      if (message.data['rideStatus'] == "complete") {
        completeRideJson = message.data;
      } else {
        ongoingRideJson = message.data;
      }
      notifyListeners();
    }

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'launch_background',
          ),
        ),
        payload: json.encode(bookingRequestJson),
      );
    }
  }

  Future<void> init(WidgetRef ref) async {
    if (Platform.isAndroid) {
      _navigationService = ref.read(navigationProvider);
      FirebaseMessaging.instance.requestPermission();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('launch_background');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        selectNotification(json.encode(initialMessage.data), ref);
      }
      FirebaseMessaging.onMessageOpenedApp.listen(onData);
      FirebaseMessaging.onMessage.listen(onData);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: (payload) => selectNotification(payload!, ref));

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      token = await FirebaseMessaging.instance.getToken();
      print('FCM token\n ${token}');
    }
  }

  Future selectNotification(String payload, WidgetRef ref) async {
    Map data = json.decode(payload); //Handle notification tapped logic here
    if (data['id'] != null) {
      // var booking = bookings.firstWhere((element) => element.id == data['id']);
      // context.read(navigationProvider).navigateTo(MaterialPageRoute(
      //     builder: (_) => BookingDetail(
      //           booking: booking,
      //         )));
      // Navigator.pushNamed(context, '/home/booking', arguments: booking);
    }
  }
}

final notificationProvider =
    ChangeNotifierProvider((ref) => NotificationService());
