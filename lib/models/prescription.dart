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

  // 手动停用
  @HiveField(10)
  bool isStopped;

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
    this.isStopped = false,
  });

  String treatmentStatusText({DateTime? now}) {
    if (isStopped) return '已停用';
    final ref = now ?? DateTime.now();
    if (items.isEmpty) return '进行中';

    final anyActive = items.any((item) => item.isScheduledOn(ref, visitDate));
    if (anyActive) return '进行中';

    final started = items.any((item) {
      final start = DateTime(visitDate.year, visitDate.month, visitDate.day);
      final day = DateTime(ref.year, ref.month, ref.day);
      return !day.isBefore(start);
    });

    return started ? '已结束' : '进行中';
  }
}

@HiveType(typeId: 2)
class PrescriptionItem {
  // 兼容旧数据（历史字段）
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

  // daily / weekly
  @HiveField(6)
  String scheduleType;

  // 1-7, Monday-Sunday
  @HiveField(7)
  List<int> weekDays;

  @HiveField(8)
  int durationCount;

  // day / week / month / forever
  @HiveField(9)
  String durationUnit;

  @HiveField(10)
  List<String> completedDates;

  // 可空：关联药箱ID
  @HiveField(11)
  String? medicineRefId;

  // 必存：药方快照名称
  @HiveField(12)
  String medicineNameSnapshot;

  // 单位：预设 + 自定义
  @HiveField(13)
  String unitPreset;

  @HiveField(14)
  String unitCustom;

  // 自由描述
  @HiveField(15)
  String instructionText;

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
    this.durationUnit = 'week',
    List<String>? completedDates,
    this.medicineRefId,
    String? medicineNameSnapshot,
    this.unitPreset = '片',
    this.unitCustom = '',
    this.instructionText = '',
  })  : weekDays = List<int>.from(weekDays ?? const <int>[]),
        completedDates = List<String>.from(completedDates ?? const <String>[]),
        medicineNameSnapshot =
            (medicineNameSnapshot == null || medicineNameSnapshot.trim().isEmpty)
                ? medicineName
                : medicineNameSnapshot;

  String get displayName =>
      medicineNameSnapshot.trim().isNotEmpty ? medicineNameSnapshot.trim() : medicineName;

  String get displayUnit => unitCustom.trim().isNotEmpty ? unitCustom.trim() : unitPreset;

  static String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool isCompletedOn(DateTime date) {
    return completedDates.contains(dateKey(date));
  }

  void setCompletion(DateTime date, bool completed) {
    final key = dateKey(date);
    if (completed) {
      if (!completedDates.contains(key)) {
        completedDates.add(key);
      }
    } else {
      completedDates.remove(key);
    }
  }

  String _normalizedDurationUnit() {
    switch (durationUnit) {
      case 'forever':
      case '一直':
        return 'forever';
      case 'month':
      case '月':
        return 'month';
      case 'week':
      case '周':
        return 'week';
      case 'day':
      case '天':
        return 'day';
      default:
        return 'day';
    }
  }

  DateTime? endDateFrom(DateTime start) {
    final unit = _normalizedDurationUnit();
    if (unit == 'forever') return null;

    final count = durationCount <= 0 ? 1 : durationCount;
    switch (unit) {
      case 'day':
        return start.add(Duration(days: count - 1));
      case 'week':
        return start.add(Duration(days: count * 7 - 1));
      case 'month':
        return start.add(Duration(days: count * 30 - 1));
      default:
        return start.add(Duration(days: count - 1));
    }
  }

  bool isScheduledOn(DateTime date, DateTime startDate) {
    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = endDateFrom(start);

    if (target.isBefore(start)) return false;
    if (end != null && target.isAfter(end)) return false;

    if (scheduleType == 'weekly') {
      if (weekDays.isEmpty) return false;
      return weekDays.contains(target.weekday);
    }

    return true;
  }

  String scheduleText() {
    if (scheduleType == 'weekly') {
      if (weekDays.isEmpty) return '每周';
      const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      final labels = weekDays.where((d) => d >= 1 && d <= 7).toList()..sort();
      final text = labels.map((d) => names[d - 1]).join('、');
      return '每周 $text';
    }
    return '每日';
  }

  String durationText() {
    final unit = _normalizedDurationUnit();
    if (unit == 'forever') return '持续：一直';

    final count = durationCount <= 0 ? 1 : durationCount;
    switch (unit) {
      case 'day':
        return '持续：$count 天';
      case 'week':
        return '持续：$count 周';
      case 'month':
        return '持续：$count 月';
      default:
        return '持续：$count 天';
    }
  }
}
