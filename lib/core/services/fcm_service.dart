import 'dart:convert';
import 'package:caritalent_mobile/core/network/api_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';

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
  final api = ref.watch(apiClientProvider);
  return FcmService(api, ref);
});

class FcmService {
  FcmService(this._api, this._ref);
  final ApiClient _api;
  final Ref _ref;

  /// Inisialisasi FCM — panggil sekali saat app startup setelah login
  Future<void> initialize() async {
    // 1. Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Setup local notifications plugin
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // 3. Buat channel notifikasi Android (wajib untuk Android 8+)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

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

  /// Kirim token ke backend Laravel
  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _api.put<void>(
        '/users/fcm-token',
        data: {'fcm_token': token},
        parser: (_) {},
      );
      debugPrint('[FCM] Token berhasil dikirim ke backend');
    } catch (e) {
      debugPrint('[FCM] Gagal mengirim token ke backend: $e');
    }
  }

  /// Tampilkan notifikasi lokal saat app sedang aktif (foreground)
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
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
      
      // Invalidate the provider so UI re-fetches the latest notification count
      _ref.invalidate(notificationsProvider);
    }
    debugPrint('[FCM] Foreground message: ${notification?.title}');
  }

  /// Handle ketika user menge-tap notifikasi
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notifikasi di-tap: ${message.data}');
    // Bisa tambahkan navigasi ke halaman notifikasi di sini
    // e.g., router.push('/notifications');
  }
}
