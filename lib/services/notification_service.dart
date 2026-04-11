// 文件位置：lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // 创建一个全局唯一的通知插件实例
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // ==========================================
  // 1. 初始化通知服务 (App启动时调用)
  // ==========================================
  static Future<void> init() async {
    tz.initializeTimeZones(); // 初始化时区

    // 安卓图标配置
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 权限配置
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings, 
      iOS: iosSettings
    );

    // 调用最新版的初始化方法 (使用 settings 命名参数)
    await _notificationsPlugin.initialize(settings: initSettings);
  }

  // ==========================================
  // 2. 开启全局用药提醒 (每天 12点 和 18点)
  // ==========================================
  static Future<void> enableGlobalReminders() async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'global_medicine_channel', 
        '全局用药提醒', 
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    // 设定中午 12 点的全局提醒 (固定 ID: 1001)
    await _notificationsPlugin.zonedSchedule(
      id: 1001,
      title: '💊 用药时间到了',
      body: '中午好！快打开药箱看看现在该吃什么药吧。',
      scheduledDate: _nextInstanceOfTime(12), 
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
      matchDateTimeComponents: DateTimeComponents.time, // 每天定时重复
    );

    // 设定下午 18 点的全局提醒 (固定 ID: 1002)
    await _notificationsPlugin.zonedSchedule(
      id: 1002,
      title: '💊 用药时间到了',
      body: '傍晚好！快打开药箱看看现在该吃什么药吧。',
      scheduledDate: _nextInstanceOfTime(18), 
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
      matchDateTimeComponents: DateTimeComponents.time, // 每天定时重复
    );
  }

  // ==========================================
  // 3. 药箱空了，一键关闭所有提醒！
  // ==========================================
  static Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }

  // ==========================================
  // 内部工具：计算下一个指定整点的时间
  // ==========================================
  static tz.TZDateTime _nextInstanceOfTime(int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    // 如果今天这个时间已经过了，就定在明天的这个时间
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}