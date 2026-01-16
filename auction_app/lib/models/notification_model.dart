import 'dart:convert';

class AppNotification {
  final String message;
  final String type;

  AppNotification({required this.message, this.type = 'general'});

  factory AppNotification.fromRedis(dynamic data) {
    // Jika data dari Redis sudah dalam bentuk String
    String rawData = data.toString();

    // Cek apakah datanya JSON (diawali '{')
    if (rawData.startsWith('{')) {
      try {
        final Map<String, dynamic> decoded = json.decode(rawData);
        return AppNotification(
          message: decoded['message'] ?? rawData,
          type: decoded['type'] ?? 'general',
        );
      } catch (e) {
        return AppNotification(message: rawData, type: 'general');
      }
    }

    // Jika bukan JSON, kembalikan sebagai pesan biasa
    return AppNotification(message: rawData, type: 'general');
  }
}