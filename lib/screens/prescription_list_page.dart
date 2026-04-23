import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/prescription.dart';
import 'add_prescription_page.dart';
import 'prescription_detail_page.dart';

class PrescriptionListPage extends StatelessWidget {
  const PrescriptionListPage({super.key});

  String _dateText(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('药方记录'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder<Box<Prescription>>(
        valueListenable: Hive.box<Prescription>('prescriptions').listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('暂无药方记录，点击下方 + 添加'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final prescription = box.getAt(index);
              if (prescription == null) return const SizedBox.shrink();

              final followUpText = prescription.followUpDate == null
                  ? '无复诊日期'
                  : '复诊：${_dateText(prescription.followUpDate!)}';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(
                    prescription.diagnosis.isEmpty ? '未填写诊断' : prescription.diagnosis,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '就诊：${_dateText(prescription.visitDate)}\n'
                    '药品：${prescription.items.length} 项  |  状态：${prescription.treatmentStatusText()}  |  $followUpText',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrescriptionDetailPage(prescription: prescription),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPrescriptionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
