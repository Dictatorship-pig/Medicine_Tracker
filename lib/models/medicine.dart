import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  // 允许为空：未设置保质期
  @HiveField(2)
  String? expiryDate;

  @HiveField(3)
  int totalCount;

  @HiveField(4)
  int frequency;

  @HiveField(5)
  int dosage;

  @HiveField(6)
  String mealRelation;

  @HiveField(7)
  String? imagePath;

  @HiveField(8)
  DateTime lastUpdateDate;

  // 预设单位（片/粒/包/支/ml/g/次...）
  @HiveField(9)
  String unitPreset;

  // 自定义单位（可空），展示时优先它
  @HiveField(10)
  String unitCustom;

  // 用法描述（可空）
  @HiveField(11)
  String usageInstruction;

  // 规格（可空）
  @HiveField(12)
  String specification;

  // 备注（可空）
  @HiveField(13)
  String note;

  // 批次（可空）
  @HiveField(14)
  String batchNo;

  // 余量低阈值
  @HiveField(15)
  int lowStockThreshold;

  // 是否按库存管理
  @HiveField(16)
  bool trackInventory;

  Medicine({
    required this.name,
    required this.type,
    this.expiryDate,
    this.totalCount = 0,
    this.frequency = 0,
    this.dosage = 0,
    this.mealRelation = '',
    this.imagePath,
    required this.lastUpdateDate,
    this.unitPreset = '片',
    this.unitCustom = '',
    this.usageInstruction = '',
    this.specification = '',
    this.note = '',
    this.batchNo = '',
    this.lowStockThreshold = 10,
    this.trackInventory = true,
  });

  String get displayUnit => unitCustom.trim().isNotEmpty ? unitCustom.trim() : unitPreset;

  DateTime? expiryDateValue() {
    if (expiryDate == null || expiryDate!.trim().isEmpty) return null;
    return DateTime.tryParse(expiryDate!);
  }

  int? daysToExpiry() {
    final exp = expiryDateValue();
    if (exp == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expDate = DateTime(exp.year, exp.month, exp.day);
    return expDate.difference(today).inDays;
  }

  String expiryStatusText() {
    final days = daysToExpiry();
    if (days == null) return '未设置效期';
    if (days < 0) return '已过期';
    if (days <= 30) return '即将过期';
    return '效期正常';
  }

  String stockStatusText() {
    if (!trackInventory) return '不计库存';
    if (totalCount <= 0) return '库存不足';
    if (totalCount <= lowStockThreshold) return '余量低';
    return '库存正常';
  }

  String overallStatusText() {
    final days = daysToExpiry();
    if (days != null && days < 0) return '已过期';
    if (trackInventory && totalCount <= 0) return '库存不足';
    if (days != null && days <= 30) return '即将过期';
    if (trackInventory && totalCount <= lowStockThreshold) return '余量低';
    return '正常';
  }
}
