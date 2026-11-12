
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

// Background handler harus berada di luar class.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Inisialisasi Firebase pada background isolate.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Notification received in background');
  debugPrint(
    'Title: ${message.notification?.title}',
  );
  debugPrint(
    'Body: ${message.notification?.body}',
  );
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  bool _isInitialized = false;

  /// Meminta izin notifikasi.
  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'Notification permission: '
      '${settings.authorizationStatus.name}',
    );

    return settings.authorizationStatus;
  }

  /// Mendapatkan FCM Token perangkat.
  Future<String?> getToken() async {
    final token = await _messaging.getToken();

    debugPrint('FCM Token: $token');

    return token;
  }

  /// Mendengarkan perubahan FCM Token.
  void listenTokenRefresh(
    void Function(String token) onRefresh,
  ) {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token diperbarui');
      onRefresh(newToken);
    });
  }

  /// Inisialisasi seluruh layanan notifikasi.
  Future<void> init() async {
    if (_isInitialized) return;

    _isInitialized = true;

    // Meminta izin notifikasi.
    await requestPermission();

    // Mendapatkan FCM Token.
    await getToken();

    // Mendengarkan perubahan FCM Token.
    listenTokenRefresh((token) {
      debugPrint('Token terbaru: $token');
    });

    // Pengaturan tampilan notifikasi saat aplikasi aktif.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Menerima notifikasi ketika aplikasi sedang terbuka.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notification received in foreground');

      debugPrint(
        'Title: ${message.notification?.title}',
      );

      debugPrint(
        'Body: ${message.notification?.body}',
      );

      debugPrint(
        'Data: ${message.data}',
      );
    });
  }
}
