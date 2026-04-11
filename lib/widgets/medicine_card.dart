import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  final String name;
  final String type;
  final String expiryDate;
  // 👇 1. 变量升级：不再传 true/false，而是传“还剩多少天”
  final int daysToExpiry; 

  const MedicineCard({
    super.key,
    required this.name,
    required this.type,
    required this.expiryDate,
    required this.daysToExpiry, // 👈 记得这里也要改
  });

  @override
  Widget build(BuildContext context) {
    // 提前准备好三个空变量，用来装一会儿要变的颜色和文字
    Color statusColor;
    Color statusBgColor;
    String statusText;

    // 👇 2. 核心魔法：三重判断逻辑
    if (daysToExpiry < 0) {
      // 场景 A：小于 0 天，已经过期了
      statusColor = Colors.red;
      statusBgColor = Colors.red.shade100;
      statusText = '已过期';
    } else if (daysToExpiry == 0) {
      // 场景 B：刚好等于 0 天，就是今天！
      // 💡 产品小提示：手机屏幕上纯黄色的字非常刺眼且看不清，所以我帮你换成了带点橘色的深黄色 (orange.shade800)，背景用浅黄，既护眼又醒目。
      statusColor = Colors.orange.shade800; 
      statusBgColor = Colors.orange.shade100; 
      statusText = '今日过期';
    } else {
      // 场景 C：大于 0 天，正常
      statusColor = Colors.green;
      statusBgColor = Colors.green.shade100;
      statusText = '正常';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.medication, color: Theme.of(context).colorScheme.primary, size: 40),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('分类：$type\n保质期至：$expiryDate'),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusBgColor, // 应用上面算好的背景色
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)), // 应用颜色和文字
        ),
      ),
    );
  }
}