import 'package:flutter/material.dart';

import '../models/medicine.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final statusText = medicine.overallStatusText();

    Color fg;
    Color bg;
    switch (statusText) {
      case '已过期':
      case '库存不足':
        fg = Colors.red.shade700;
        bg = Colors.red.shade100;
        break;
      case '即将过期':
      case '余量低':
        fg = Colors.orange.shade800;
        bg = Colors.orange.shade100;
        break;
      default:
        fg = Colors.green.shade700;
        bg = Colors.green.shade100;
    }

    final expiry = medicine.expiryDate == null || medicine.expiryDate!.isEmpty
        ? '未设置'
        : medicine.expiryDate!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.medication, color: Theme.of(context).colorScheme.primary, size: 38),
        title: Text(
          medicine.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          '分类：${medicine.type}\n保质期：$expiry',
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText,
            style: TextStyle(color: fg, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
