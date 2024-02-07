import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'notification-screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();
    //notificationServices.isDeviceToken();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.getdevicetoken().then((value){
     if(kDebugMode){
       print('device token');
       print(value);
     }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // backgroundColor: Colors.amberAccent,
      body: Center(
          child: TextButton(
            onPressed: (){
            notificationServices.getdevicetoken().then((value) async{
              var data= {
                'to':  'dz1BGq5oR7OsoqdlASc_3D:APA91bHw5fGc-eTY1hZOOtfmGaR_bZ5dGmUo_DbLhIb5qTF9aPpeZIEAqmmwc8bKsiyPcRJqUfwdPK0DV_pynQj14pZ-MDck2zalfG0JumINDVAxFiJ46DHdG8D-gYoss-7VZYpJFnpB',
                'priority': 'high',
               'Notification': {
                 'title': 'Manor',
                 'body': 'Subscribe my channel'
               } ,
               'data': {
                  'type': 'msg',
                   'id': '123456',
               },
              };
              await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                body: jsonEncode(data),
                headers: {
                'Content-Type':'application/json: Charset-UTF-8',
                  'Authorization': 'AAAAx4zI938:APA91bFahBx4YFg56aNsYclYrM4_WstO7LWj6F0wbIubKy9qRWXBdOgLqF8Q_DZ57OZjnRZBuZDxWqo4399_Jz4MtbdSoI0XWzhvJPaHJdp_AHkmWDaGqTNS8U0JawiwKgTWVmFYKI-m'
                }
              );

            });
            },
            child: Text('Hello World',style: TextStyle(fontSize: 25),) ,
          )),
    );
  }
}