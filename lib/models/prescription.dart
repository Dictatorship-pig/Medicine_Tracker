// 文件位置：lib/models/prescription.dart
import 'package:hive/hive.dart';

part 'prescription.g.dart';

@HiveType(typeId: 1)
class Prescription extends HiveObject {
  @HiveField(0)
  String id;

  // 就诊日期
  @HiveField(1)
  DateTime visitDate;

  // 复诊日期（可为空）
  @HiveField(2)
  DateTime? followUpDate;

  @HiveField(3)
  String hospital;

  @HiveField(4)
  String doctor;

  @HiveField(5)
  String diagnosis;

  @HiveField(6)
  String advice;

  @HiveField(7)
  String careNotes;

  @HiveField(8)
  List<PrescriptionItem> items;

  @HiveField(9)
  DateTime createdAt;

  Prescription({
    required this.id,
    required this.visitDate,
    this.followUpDate,
    this.hospital = '',
    this.doctor = '',
    this.diagnosis = '',
    this.advice = '',
    this.careNotes = '',
    this.items = const [],
    required this.createdAt,
  });
}

@HiveType(typeId: 2)
class PrescriptionItem {
  @HiveField(0)
  String medicineName;

  @HiveField(1)
  String dosage;

  @HiveField(2)
  String frequency;

  @HiveField(3)
  int days;

  @HiveField(4)
  String mealRelation;

  @HiveField(5)
  String remark;

  @HiveField(6)
  String scheduleType;

  @HiveField(7)
  List<int> weekDays;

  @HiveField(8)
  int durationCount;

  @HiveField(9)
  String durationUnit;

  @HiveField(10)
  List<String> completedDates;

  PrescriptionItem({
    required this.medicineName,
    this.dosage = '',
    this.frequency = '',
    this.days = 0,
    this.mealRelation = '',
    this.remark = '',
    this.scheduleType = 'daily',
    List<int>? weekDays,
    this.durationCount = 1,
    this.durationUnit = '天',
    List<String>? completedDates,
  }) : weekDays = weekDays ?? [],
       completedDates = completedDates ?? [];

  static String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool isCompletedOn(DateTime date) {
    return completedDates.contains(dateKey(date));
  }

  void toggleCompletion(DateTime date) {
    final key = dateKey(date);
    if (completedDates.contains(key)) {
      completedDates.remove(key);
    } else {
      completedDates.add(key);
    }
  }

  DateTime? _endDate(DateTime start) {
    if (durationUnit == '一直') return null;
    final count = durationCount <= 0 ? 1 : durationCount;
    switch (durationUnit) {
      case '天':
        return start.add(Duration(days: count - 1));
      case '周':
        return start.add(Duration(days: count * 7 - 1));
      case '月':
        return start.add(Duration(days: count * 30 - 1));
      default:
        return start.add(Duration(days: count - 1));
    }
  }

  bool isScheduledOn(DateTime date, DateTime startDate) {
    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = _endDate(start);
    if (target.isBefore(start)) return false;
    if (end != null && target.isAfter(end)) return false;

    if (scheduleType == 'weekly') {
      final weekday = target.weekday; // 1 = Monday, 7 = Sunday
      return weekDays.contains(weekday);
    }

    return true;
  }

  String scheduleText() {
    if (scheduleType == 'weekly') {
      if (weekDays.isEmpty) return '每周';
      final labels = weekDays
          .map((day) {
            const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
            return names[day - 1];
          })
          .join('、');
      return '每周$labels';
    }
    return '每日';
  }

  String durationText() {
    if (durationUnit == '一直') return '持续：一直';
    return '持续：$durationCount$durationUnit';
  }
}
