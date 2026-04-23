import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/medicine.dart';

class MedicineDetailPage extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailPage({super.key, required this.medicine});

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 24),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expiryText = medicine.expiryDate == null || medicine.expiryDate!.isEmpty
        ? '未设置'
        : medicine.expiryDate!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('药品详情'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (medicine.imagePath != null)
              SizedBox(
                height: 260,
                child: kIsWeb
                    ? Image.network(medicine.imagePath!, fit: BoxFit.cover)
                    : Image.file(File(medicine.imagePath!), fit: BoxFit.cover),
              )
            else
              Container(
                height: 180,
                color: Colors.teal.shade50,
                child: const Icon(Icons.medication, size: 80, color: Colors.teal),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(medicine.type)),
                      Chip(label: Text('状态：${medicine.overallStatusText()}')),
                    ],
                  ),
                  const Divider(height: 28),
                  _buildInfoRow(Icons.straighten, '单位', medicine.displayUnit),
                  _buildInfoRow(Icons.inventory_2_outlined, '库存状态', medicine.stockStatusText()),
                  _buildInfoRow(Icons.event_outlined, '效期状态', medicine.expiryStatusText()),
                  _buildInfoRow(Icons.calendar_today, '保质期', expiryText),
                  _buildInfoRow(Icons.all_inbox, '总量', medicine.trackInventory ? '${medicine.totalCount} ${medicine.displayUnit}' : '不计库存'),
                  _buildInfoRow(Icons.warning_amber_outlined, '低库存阈值', medicine.trackInventory ? '${medicine.lowStockThreshold} ${medicine.displayUnit}' : '不计库存'),
                  _buildInfoRow(Icons.local_hospital_outlined, '规格', medicine.specification.isEmpty ? '未填写' : medicine.specification),
                  _buildInfoRow(Icons.medication_liquid_outlined, '用法', medicine.usageInstruction.isEmpty ? '未填写' : medicine.usageInstruction),
                  _buildInfoRow(Icons.schedule, '每日次数', medicine.frequency == 0 ? '未填写' : '${medicine.frequency} 次'),
                  _buildInfoRow(Icons.exposure, '每次用量', medicine.dosage == 0 ? '未填写' : '${medicine.dosage} ${medicine.displayUnit}'),
                  _buildInfoRow(Icons.restaurant, '服药时机', medicine.mealRelation.isEmpty ? '未填写' : medicine.mealRelation),
                  _buildInfoRow(Icons.qr_code, '批次', medicine.batchNo.isEmpty ? '未填写' : medicine.batchNo),
                  const SizedBox(height: 8),
                  const Text('备注', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(medicine.note.isEmpty ? '未填写' : medicine.note),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
