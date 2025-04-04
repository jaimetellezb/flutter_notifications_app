import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class LocalNotifications {


  static Future<void> requestPermissionLocalNotifications() async {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();       
  }


  static Future<void> initializeLocalNotifications() async {

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsDarwin = DarwinInitializationSettings(
      notificationCategories: [
      DarwinNotificationCategory(
        'demoCategory',
        actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
            'id_2',
            'Action 2',
            options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
            },
            ),
             DarwinNotificationAction.plain(
            'id_3',
            'Action 3',
            options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
            },
            ),
        ],
        options: const <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
    )]
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );


    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // ...
        
    },
    // onDidReceiveBackgroundNotificationResponse: onDidReceiveNotificationResponse,
    );

  }

  static void iosShowNotification(int id, String? title, String? body, String? data ) {
    showLocalNotification(id: id, title: title, body: body, data: data);
  }

  static void showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? data,
  }) {
      
    const androidDetails = AndroidNotificationDetails(
      'channelId', 
      'channelName',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentSound: true,
      )
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails, payload: data );
  }

}