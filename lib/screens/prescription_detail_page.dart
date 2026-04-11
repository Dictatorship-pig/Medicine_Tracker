import 'package:flutter/material.dart';

import '../models/prescription.dart';

class PrescriptionDetailPage extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionDetailPage({super.key, required this.prescription});

  String _dateText(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteRecord(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除药方记录'),
        content: const Text('确定删除这条药方记录吗？删除后不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    await prescription.delete();
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('药方记录已删除')),
      );
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('药方详情'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: '删除',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteRecord(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('就诊日期：${_dateText(prescription.visitDate)}'),
                    const SizedBox(height: 6),
                    Text(
                      prescription.followUpDate == null
                          ? '复诊日期：未填写'
                          : '复诊日期：${_dateText(prescription.followUpDate!)}',
                    ),
                    const SizedBox(height: 6),
                    Text('医院：${prescription.hospital.isEmpty ? '未填写' : prescription.hospital}'),
                    const SizedBox(height: 6),
                    Text('医生：${prescription.doctor.isEmpty ? '未填写' : prescription.doctor}'),
                  ],
                ),
              ),
            ),
            _sectionTitle('诊断'),
            Text(prescription.diagnosis.isEmpty ? '未填写' : prescription.diagnosis),
            _sectionTitle('医嘱'),
            Text(prescription.advice.isEmpty ? '未填写' : prescription.advice),
            _sectionTitle('护理建议'),
            Text(prescription.careNotes.isEmpty ? '未填写' : prescription.careNotes),
            _sectionTitle('药品明细'),
            if (prescription.items.isEmpty)
              const Text('未添加药品')
            else
              ...prescription.items.asMap().entries.map(
                (entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final daysText = item.days > 0 ? '${item.days} 天' : '未填写';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${i + 1}. ${item.medicineName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('单次用量：${item.dosage.isEmpty ? '未填写' : item.dosage}'),
                          Text('服用频次：${item.frequency.isEmpty ? '未填写' : item.frequency}'),
                          Text('用药天数：$daysText'),
                          Text('服药时机：${item.mealRelation.isEmpty ? '未填写' : item.mealRelation}'),
                          Text('备注：${item.remark.isEmpty ? '无' : item.remark}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
