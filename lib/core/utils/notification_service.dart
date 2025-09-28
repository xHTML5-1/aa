import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService(this._messaging);

  final FirebaseMessaging _messaging;

  Future<void> initialize() async {
    await _messaging.requestPermission();
    await _messaging.subscribeToTopic('site-updates');
  }

  Future<void> sendLocalLog(String message) async {
    // In a real app this would show a local notification. Here we log the intent.
    // ignore: avoid_print
    print('Bildirim gönderildi: $message');
  }
}
