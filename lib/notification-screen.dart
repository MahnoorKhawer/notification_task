import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'message-screen.dart';
class NotificationServices {

  FirebaseMessaging messaging=FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();
  void requestNotificationPermission() async{
    NotificationSettings settings= await messaging.requestPermission(
      alert: true,
      announcement: true,
      provisional: true,
      sound: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print("user ganted permission");
    }
    else if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print("user ganted proovision permission");
    }else{
      print("user denied permission");
    }
  }
  void initLocalNotification(BuildContext context, RemoteMessage message) async{
    var androidInitializationSettings= const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialization = const DarwinInitializationSettings();
    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitialization,
    );
    await _flutterLocalNotificationsPlugin.initialize(
        initializationSetting,
        onDidReceiveBackgroundNotificationResponse: (payload){
         handelMessage(context,message);
        }
    );
  }
  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
        print(message.data['type']);
        print(message.data['id']);

      }
      if(Platform.isAndroid){
        initLocalNotification(context,message);
        showNotification(message);
      } else{
        showNotification(message);
      }
    });
  }
  Future<void> showNotification(RemoteMessage message) async{
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(10000).toString(),
      'It is important message',
      importance: Importance.max,
    );
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    DarwinNotificationDetails darwinNotificationDetails =
     DarwinNotificationDetails(
       presentSound: true,
       presentAlert: true,
       presentBadge: true,
       presentBanner: true,
       presentList: true,
       );
    NotificationDetails notificationDetails =NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
    Future.delayed(Duration.zero,(){
      _flutterLocalNotificationsPlugin.show(
          1,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);

    }
    );
  }
  Future<String>getdevicetoken()async{
    String? token = await messaging.getToken();
    return token!;
  }
  void isDeviceToken()async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('refresh');
    });
  }

  void  handelMessage(BuildContext context,RemoteMessage message){
    if(message.data['type']=='msg'){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> MessageScreen(id: message.data['id'])));
    }

  }

  Future<void> setupInteractMessage(BuildContext context)async{
    //when app is terminated navigation
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage!=null){
      handelMessage(context, initialMessage);
    }

    //when app is in background navigation
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handelMessage(context, event);
    });
  }
}