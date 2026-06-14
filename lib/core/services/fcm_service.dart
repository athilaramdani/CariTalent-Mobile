import 'dart:convert';
import 'dart:io';
import 'package:caritalent_mobile/app/app.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── Background message handler (HARUS top-level function) ───────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Notif diterima saat app di background/terminated — ditangani otomatis oleh sistem
  debugPrint('[FCM] Background message: ${message.notification?.title}');
}

// ─── Local Notifications Channel ─────────────────────────────────────────────
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'caritalent_high_importance',
  'CariTalent Notifications',
  description: 'Notifikasi penting dari CariTalent',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

// ─── FCM Service Provider ─────────────────────────────────────────────────────
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(ref);
});

class FcmService {
  FcmService(this._ref);
  final Ref _ref;

  // Base URL backend — harus sama dengan ApiClient._defaultBaseUrl()
  static String get _baseUrl {
    return 'https://afternoon-testimonials-saskatchewan-nightlife.trycloudflare.com/api/v1';
  }
  static const _tokenKey = 'auth_token';
  final _secureStorage = const FlutterSecureStorage();

  /// Inisialisasi FCM — panggil sekali saat app startup setelah login
  Future<void> initialize() async {
    try {
      // 1. Register background handler
      // Only do this on Mobile (Android/iOS) — throws on Web without safe setup
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      }

      // 2. Setup local notifications plugin
      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );

      // 3. Buat channel notifikasi Android (wajib untuk Android 8+)
      if (!kIsWeb && Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }

      // 4. Minta izin notifikasi ke user (iOS & Android 13+)
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

      // 5. Kirim FCM token ke backend untuk disimpan
      await _registerToken();

      // 6. Handle refresh token (misal setelah reinstall)
      FirebaseMessaging.instance.onTokenRefresh.listen(_sendTokenToBackend);

      // 7. Handle notifikasi saat app foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 8. Handle tap notif saat app background (tapi belum terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    } catch (e) {
      debugPrint('[FCM] Initialization failed: $e');
    }
  }

  /// Ambil FCM token dan kirim ke backend
  Future<void> _registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        debugPrint('[FCM] Token: $token');
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('[FCM] Gagal mengambil token: $e');
    }
  }

  /// Kirim token ke backend Laravel — menggunakan raw HTTP agar bisa dipakai
  /// di background isolate tanpa bergantung pada Riverpod/ApiClient
  Future<void> _sendTokenToBackend(String fcmToken) async {
    try {
      // Baca Bearer token langsung dari secure storage
      final bearerToken = await _secureStorage.read(key: _tokenKey);

      if (bearerToken == null || bearerToken.isEmpty) {
        debugPrint('[FCM] ⚠️ Bearer token tidak ditemukan, skip kirim token');
        return;
      }

      debugPrint('[FCM] Mengirim token ke backend...');
      final client = HttpClient();
      final request = await client.putUrl(
        Uri.parse('$_baseUrl/users/fcm-token'),
      );
      request.headers.set('Accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $bearerToken');
      request.write(jsonEncode({'fcm_token': fcmToken}));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        debugPrint('[FCM] ✅ Token berhasil dikirim ke backend');
      } else {
        debugPrint('[FCM] ❌ Backend error ${response.statusCode}: $responseBody');
      }
      client.close();
    } catch (e) {
      debugPrint('[FCM] ❌ Gagal mengirim token ke backend: $e');
    }
  }

  /// Tampilkan notifikasi lokal saat app sedang aktif (foreground)
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground message received: ${message.data}');
    
    // SELALU invalidate provider supaya angka notif nambah walau popup gagal
    _ref.invalidate(notificationsProvider);

    final notification = message.notification;

    if (notification != null) {
      // Tampilkan Snackbar di dalam aplikasi
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title ?? 'Notifikasi Baru',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (notification.body != null)
                Text(notification.body!),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFFB500FF), // Tema warna aplikasi
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'LIHAT',
            textColor: Colors.white,
            onPressed: () {
              // Bisa ditambahkan aksi, misalnya pindah tab ke Notifikasi
            },
          ),
        ),
      );

      try {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: json.encode(message.data),
        );
      } catch (e) {
        debugPrint('[FCM] Gagal menampilkan local notification: $e');
      }
    }
  }

  /// Handle ketika user menge-tap notifikasi
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notifikasi di-tap: ${message.data}');
    // Bisa tambahkan navigasi ke halaman notifikasi di sini
    // e.g., router.push('/notifications');
  }
}
