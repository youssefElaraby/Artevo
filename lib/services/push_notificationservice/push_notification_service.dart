import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PushNotificationService {
  static const String _projectId = "artbyhager";
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _privateKey = """-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDZNZSXsnZGuUsC
CvZieo2/PKxfu2eZ/smTZuQsxPnPaA4ADbNbHDCBkSTXEQgetvkv63rAKXBoDrvJ
VoWPsbW2Jm93rQkRLqgRhosUycBhuk4sYd7N5W1ZSkeQynDQeAv+vZuumxso9YcN
7c+0YOaCBuEhkK1CvaIM3ZCvjqspiNdUj0kERzKTuGsq2txZ/KoWVVST+iPxY4xQ
o6OfDpw4a3FlTynr1yTFHTD/EVYYhIfvpj4Ynnka14oNG8e1h3zBCJubz5dTf3PY
1kzzINO7INVawKNjKU2d19Qe6QbfbK2loT9HgffbszLIEvTcXIJRp0zXXP6j1xmH
q7M4XIw5AgMBAAECggEACNpzfExooEDYsxRdzw1GPkt7jipeEmuNbU3mEoIT2ZWY
7n0geJ/5RSq0mPSHg3L7TK35MqBtxbwGAPKfHoiEitBdvj/GDRZ9ALveauI/Tmxw
18PEeFl338oUiS0LNKAUAxXY5ODLFlwNnW56RxSlCJs9rWfPfBctJf+Y8GLtDJQF
UzfUjK7mXTogKEcIvBetm9CIQ2vuUKNChzoRS8f4t4m9k/DApH50ZIXBVnS8tdzT
2zUUkgcfacJMDGG3rNuV8SwWv5cjnr+nzM0ObuPk2TTTwfrFGWNj04rmh1T55cl5
xiEAnAmILHbEXfx67tx5xRUe/I2j5AM7ab9izBmJAQKBgQDvRTBEVCMAOS2njdNf
H8yIxfxa5L1zOV2GUFe/ZAQkYLbdbG1am+klClJxpN6r4/fhK27TnLfrlLC1Bsra
5/oQ2L2ckdLSQiq1cGyI+fQqNQP0YAxuhdS5NZv6ShOTmLp+wv9KfRSxzBTB1Mbt
CLxrgUpsuQrmp3CM80haCHeFgQKBgQDoZYMfYHuwlJ6Ea1giJc6xvQLiQdiv/lXi
4PkckoNK6zxjs6hG19a4yi7uxUNAm/O5qqiSIB6riCTizs1QUhdxiXYCizVEuyYR
PNiHVrPKgWyLm8zmhyzuZyhp2Xs5LLyfk9qACR0QM7TiAwEw4iESIulQwZBeN/NQ
eApD45oSuQKBgQDYtSSTLlUJFcB42iZQKH/afN8j/7pqytEfHlNrIA30WLgm8dZV
U5KlHqUvErEuo+nVQb494NpffytQuhcujx5Y9cU+MoDsOEtwS6OxqBlxxNSRGBEK
ZSIWoSxlU4RJkPGQb9JCx+jfY8SFDc8hzmDBSbd7o1jxMUPqFUo5aSO/gQKBgQDG
4gkDEzkHd0jpnkwAfUaUiWMsapmclBbAYTQPpbtCpGo8EQZUCmcyIaVkpeDWLCC6
pjg5Rc+5kHuwtraypG53teIOb0AZH+iGHAJaYHLhPT29hIooR0rGg/XsEDkKRyTt
lEUMCcCbmwST32pngT44HTR67gw09cD+/pwaWXAD0QKBgQCpgb/Xr0STZQ2Eot8F
tc46U2q+kF6HMcgBz3/OvMtz8FBl6zn5jGTedvxOuRGtZyulzHrZoTol2OyB/Eb4
VFm6UQJPYvvmKxsrOUSx0ILUbjZ91hfgBisWp+SzRYTfDRmS1xGYQ1k3F0dgL3pS
l+JjlyfGoMzWPRz4Jhx1jbZNbg==
-----END PRIVATE KEY-----""";

  static Future<void> sendNotificationToAllAdmins({
    required String customerName,
    required String placeName,
    required String bookingTime,
  }) async {
    final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    try {
      final accountCredentials = ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": _projectId,
        "private_key_id": "dac4f6460eefb6f521aa3782d040626c4d9f0fb3",
        "private_key": _privateKey,
        "client_email":
            "firebase-adminsdk-fbsvc@artbyhager.iam.gserviceaccount.com",
        "client_id": "104488389991540019408",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/auth/firebase.messaging",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40artbyhager.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      });

      final authClient = await clientViaServiceAccount(
        accountCredentials,
        _scopes,
      );
      final String accessToken = authClient.credentials.accessToken.data;

      final String fcmUrl =
          'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

      final Map<String, dynamic> notificationPayload = {
        'message': {
          'topic': 'admin_notifications',
          'notification': {
            // عنوان جذاب ومختصر
            'title': '🔔 حجز جديد من : $customerName',
            // تنسيق احترافي للمحتوى باستخدام الرموز والمسافات
            'body':
                '📍 المكان: $placeName\n'
                '📅 الموعد: $bookingTime\n'
                'اضغط للتفاصيل وإدارة الحجز ✨',
          },
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': 'high_importance_channel',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'sound': 'default',
              'icon': 'ic_notification',
              'color': '#2F3E34',
            },
          },
          'data': {'customer': customerName, 'type': 'booking_alert'},
        },
      };

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(notificationPayload),
      );

      if (response.statusCode == 200) {
        print('✅ نجاح: تم إرسال الإشعار باللوجو الافتراضي.');
      } else {
        print('❌ فشل السيرفر: ${response.body}');
      }

      authClient.close();
    } catch (e) {
      print('🛑 خطأ حرج: ${e.toString()}');
    }
  }

  static Future<void> initialize() async {
    // 🚀 طلب الصلاحية (عشان رسالة الـ Allow تظهر)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("✅ تم تفعيل إشعارات اليوزر");
    }

    // إعداد القناة للصوت العالي
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'تحديثات الحجز',
      importance: Importance.max,
      playSound: true,
    );

    // تثبيت الإعدادات للأندرويد
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // الاستماع للإشعارات والتطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _localNotificationsPlugin.show(
          id: message.hashCode, // 👈 لازم تضيف كلمة "id:" هنا
          title: message.notification!.title, // 👈 وكلمة "title:" هنا
          body: message.notification!.body, // 👈 وكلمة "body:" هنا
          notificationDetails: NotificationDetails(
            // 👈 وكلمة "notificationDetails:" هنا
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'ic_notification',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }
}
