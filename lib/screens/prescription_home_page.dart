import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/prescription.dart';
import 'add_prescription_page.dart';
import 'prescription_detail_page.dart';

class PrescriptionHomePage extends StatefulWidget {
  const PrescriptionHomePage({super.key});

  @override
  State<PrescriptionHomePage> createState() => _PrescriptionHomePageState();
}

class _PrescriptionHomePageState extends State<PrescriptionHomePage> {
  DateTime _selectedDate = DateTime.now();

  String _dateText(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Widget _buildRecordCard(BuildContext context, Prescription prescription) {
    final followUpText = prescription.followUpDate == null
        ? '无复诊日期'
        : '复诊：${_dateText(prescription.followUpDate!)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(
          prescription.diagnosis.isEmpty ? '未填写诊断' : prescription.diagnosis,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '就诊：${_dateText(prescription.visitDate)}\n'
          '药品：${prescription.items.length} 项  |  $followUpText',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('药方页面'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder<Box<Prescription>>(
        valueListenable: Hive.box<Prescription>('prescriptions').listenable(),
        builder: (context, box, _) {
          final all = box.values.toList()
            ..sort((a, b) => b.visitDate.compareTo(a.visitDate));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                '用药打卡日历（预留）',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (date) {
                      setState(() => _selectedDate = date);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '当前选择日期：${_dateText(_selectedDate)}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Text(
                '药方记录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (all.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('暂无药方记录，点击右下角 + 添加'),
                  ),
                )
              else
                ...all.map((p) => _buildRecordCard(context, p)),
            ],
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
