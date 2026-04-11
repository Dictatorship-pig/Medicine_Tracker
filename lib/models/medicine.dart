// 文件位置：lib/models/medicine.dart
import 'package:hive/hive.dart';

// ⚠️ 核心魔法：这句话是告诉系统，一会儿会自动生成一个叫 medicine.g.dart 的文件来配合它
part 'medicine.g.dart';

// 给这个数据模型发一个身份证（typeId 必须是唯一的，我们从 0 开始）
@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  String expiryDate;

  @HiveField(3)
  int totalCount; 

  @HiveField(4)
  int frequency; 

  @HiveField(5)
  int dosage; 

  @HiveField(6)
  String mealRelation; 

  // 👇 新增第 7 号字段：用来保存图片的本地路径
  @HiveField(7)
  String? imagePath; 

  @HiveField(8)
  DateTime lastUpdateDate; // 记录上一次扣除库存的日期

  

  Medicine({
    required this.name,
    required this.type,
    required this.expiryDate,
    this.totalCount = 0,
    this.frequency = 0,
    this.dosage = 0,
    this.mealRelation = '饭后',
    this.imagePath, // 👈 构造函数里也加上它（允许为空）
    required this.lastUpdateDate,
   
  });
}