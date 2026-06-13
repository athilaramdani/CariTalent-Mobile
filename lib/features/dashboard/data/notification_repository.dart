import 'package:caritalent_mobile/core/constants/api_endpoints.dart';
import 'package:caritalent_mobile/core/network/api_client.dart';
import 'package:caritalent_mobile/features/dashboard/domain/notification_model.dart';

class NotificationRepository {
  const NotificationRepository(this._api);
  final ApiClient _api;

  /// GET /notifications — get all notifications for the logged-in user
  Future<List<NotificationModel>> fetchNotifications() async {
    return _api.get<List<NotificationModel>>(
      ApiEndpoints.notifications,
      parser: (json) {
        if (json is List) {
          return json.map((e) => NotificationModel.fromJson(e)).toList();
        }
        if (json is Map<String, dynamic>) {
          final list =
              (json['notifications'] ?? json['data']) as List<dynamic>?;
          if (list != null) {
            return list.map((e) => NotificationModel.fromJson(e)).toList();
          }
        }
        return [];
      },
    );
  }

  /// PUT /notifications/{id}/read — mark a single notification as read
  Future<void> markAsRead(int id) async {
    await _api.put<void>(
      ApiEndpoints.markNotificationRead(id),
      parser: (_) {},
    );
  }

  /// PUT /notifications/read-all — mark all notifications as read
  Future<void> markAllAsRead() async {
    await _api.put<void>(
      ApiEndpoints.markAllNotificationsRead,
      parser: (_) {},
    );
  }
}
