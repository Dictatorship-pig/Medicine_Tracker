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

  PrescriptionItem({
    required this.medicineName,
    this.dosage = '',
    this.frequency = '',
    this.days = 0,
    this.mealRelation = '',
    this.remark = '',
  });
}
