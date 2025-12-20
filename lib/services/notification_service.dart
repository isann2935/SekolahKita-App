import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola notifikasi pengingat streak
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  static const int _streakReminderId = 1;
  static const String _lastActivityDateKey = 'last_activity_completed_date';

  /// Inisialisasi notification service
  Future<void> initialize() async {
    // Inisialisasi timezone
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Request permission untuk Android 13+
    await _requestPermissions();
    
    // Schedule notifikasi harian
    await scheduleDailyReminder();
  }

  /// Request permissions untuk notifikasi
  Future<void> _requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
    
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Handler ketika notifikasi di-tap
  void _onNotificationTapped(NotificationResponse response) {
    // Bisa navigasi ke halaman tertentu jika diperlukan
  }

  /// Jadwalkan notifikasi pengingat harian
  /// Notifikasi akan muncul setiap hari pukul 17:00
  Future<void> scheduleDailyReminder() async {
    // Cancel notifikasi sebelumnya
    await _notifications.cancel(_streakReminderId);
    
    // Buat waktu untuk notifikasi (17:00 setiap hari)
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      17, // Jam 17:00
      0,
    );
    
    // Jika sudah lewat jam 17:00 hari ini, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'streak_reminder',
      'Pengingat Streak',
      channelDescription: 'Pengingat untuk belajar agar streak tidak reset',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        'Jangan sampai streak-mu hilang! 🔥 Yuk selesaikan 1 latihan hari ini untuk menjaga streak 7 hari berturut-turutmu.',
        contentTitle: 'Waktunya Belajar! 📚',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _streakReminderId,
      'Waktunya Belajar! 📚',
      'Jangan sampai streak-mu hilang! 🔥 Yuk selesaikan 1 latihan hari ini.',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Ulangi setiap hari pada jam yang sama
    );
  }

  /// Tandai bahwa user sudah menyelesaikan aktivitas hari ini
  /// Panggil ini setelah user menyelesaikan kuis/latihan
  Future<void> markActivityCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    await prefs.setString(_lastActivityDateKey, todayStr);
    
    // Cancel notifikasi hari ini karena sudah belajar
    await cancelTodayReminder();
    
    // Schedule ulang untuk besok
    await scheduleDailyReminder();
  }

  /// Cancel notifikasi pengingat hari ini
  Future<void> cancelTodayReminder() async {
    await _notifications.cancel(_streakReminderId);
  }

  /// Cek apakah user sudah menyelesaikan aktivitas hari ini
  Future<bool> hasCompletedActivityToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastActivityDate = prefs.getString(_lastActivityDateKey);
    return lastActivityDate == todayStr;
  }

  /// Tampilkan notifikasi test (untuk debugging)
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel untuk testing',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'Test Notifikasi 🔔',
      'Ini adalah test notifikasi dari SekolahKita!',
      notificationDetails,
    );
  }
}
