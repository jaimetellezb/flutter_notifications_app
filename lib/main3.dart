import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialized in the `main` function
final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';


@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el plugin de notificaciones
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    notificationCategories: darwinNotificationCategories,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print('Notificación tocada: ${response.payload}');
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // Inicializar timezone para notificaciones programadas
  // tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notificaciones Locales',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotificationDemo(),
    );
  }
}

class NotificationDemo extends StatefulWidget {
  const NotificationDemo({super.key});

  @override
  State<NotificationDemo> createState() => _NotificationDemoState();
}

class _NotificationDemoState extends State<NotificationDemo> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _isAndroidPermissionGranted();
    _requestPermissions();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      // setState(() {
      //   _notificationsEnabled = granted;
      // });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          print('Permisos $result' );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      
          await androidImplementation?.requestNotificationsPermission();
      // setState(() {
      //   _notificationsEnabled = grantedNotificationPermission ?? false;
      // });
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }

  // Future<void> _requestPermissions() async {
  //   await _notificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //   AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  //   await _notificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //         IOSFlutterLocalNotificationsPlugin
  //       >()
  //       ?.requestPermissions(alert: true, badge: true, sound: true);
  // }

  // Future<void> _showSimpleNotification() async {
  //   const AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //         'channel_id',
  //         'Notificaciones simples',
  //         channelDescription: 'Canal para notificaciones simples',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       );

  //   const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );

  //   const NotificationDetails platformDetails = NotificationDetails(
  //     android: androidDetails,
  //     iOS: iosDetails,
  //   );

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Hola Flutter!',
  //     'Esta es una notificación simple',
  //     platformDetails,
  //     payload: 'simple_notification',
  //   );
  // }

  // Future<void> _showScheduledNotification() async {
  //   await _notificationsPlugin.zonedSchedule(
  //     1,
  //     'Notificación programada',
  //     'Esta notificación fue programada para mostrarse después de 5 segundos',
  //     tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'channel_id_scheduled',
  //         'Notificaciones programadas',
  //         channelDescription: 'Canal para notificaciones programadas',
  //       ),
  //       iOS: DarwinNotificationDetails(),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     payload: 'scheduled_notification',
  //   );
  // }

  // Future<void> _showBigPictureNotification() async {
  //   const String largeIconPath =
  //       'https://flutter.dev/images/flutter-logo-sharing.png';
  //   const String bigPicturePath =
  //       'https://storage.googleapis.com/cms-storage-bucket/6a07d8a62f4308d2b854.png';

  //   final BigPictureStyleInformation bigPictureStyleInformation =
  //       BigPictureStyleInformation(
  //     const UriAndroidBitmap(bigPicturePath),
  //     largeIcon: const UriAndroidBitmap(largeIconPath),
  //     contentTitle: 'Notificación con imagen grande',
  //     summaryText: 'Resumen de la notificación',
  //   );

  //   final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  //     'channel_id_big_picture',
  //     'Notificaciones con imagen',
  //     channelDescription: 'Canal para notificaciones con imagen grande',
  //     styleInformation: bigPictureStyleInformation,
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );

  //   final NotificationDetails platformDetails = NotificationDetails(
  //     android: androidDetails,
  //     iOS: const DarwinNotificationDetails(),
  //   );

  //   await _notificationsPlugin.show(
  //     2,
  //     'Notificación con imagen',
  //     'Esta notificación muestra una imagen grande',
  //     platformDetails,
  //     payload: 'big_picture_notification',
  //   );
  // }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones Locales')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showNotification,
              child: const Text('Mostrar notificación simple'),
            ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _showScheduledNotification,
            //   child: const Text('Programar notificación (5 segundos)'),
            // ),
            // const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _showBigPictureNotification,
            //   child: const Text('Mostrar notificación con imagen'),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cancelAllNotifications,
              child: const Text('Cancelar todas las notificaciones'),
            ),
          ],
        ),
      ),
    );
  }
}
