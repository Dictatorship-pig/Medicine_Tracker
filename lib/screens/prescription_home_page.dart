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

class _ScheduleEntry {
  final Prescription prescription;
  final PrescriptionItem item;
  final DateTime date;

  _ScheduleEntry({
    required this.prescription,
    required this.item,
    required this.date,
  });

  bool get isCompleted => item.isCompletedOn(date);
}

class _PrescriptionHomePageState extends State<PrescriptionHomePage> {
  DateTime _selectedDate = DateTime.now();

  String _dateText(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  List<_ScheduleEntry> _scheduleEntriesForDate(
    DateTime date,
    List<Prescription> prescriptions,
  ) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final list = prescriptions.expand((prescription) {
      return prescription.items
          .where((item) => item.isScheduledOn(normalizedDate, prescription.visitDate))
          .map(
            (item) => _ScheduleEntry(
              prescription: prescription,
              item: item,
              date: normalizedDate,
            ),
          );
    }).toList();

    list.sort((a, b) => a.item.displayName.compareTo(b.item.displayName));
    return list;
  }

  Future<void> _showDailySchedule(
    BuildContext context,
    DateTime date,
    List<_ScheduleEntry> entries,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final doneCount = entries.where((e) => e.isCompleted).length;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_dateText(date)} 用药计划',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('完成：$doneCount/${entries.length}'),
                    const SizedBox(height: 8),
                    if (entries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('当天没有需要用药的项目。'),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final dosageText = entry.item.dosage.isEmpty ? '未填写' : entry.item.dosage;
                            final frequencyText =
                                entry.item.frequency.isEmpty ? '未填写' : entry.item.frequency;
                            final mealText =
                                entry.item.mealRelation.isEmpty ? '未填写' : entry.item.mealRelation;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: CheckboxListTile(
                                value: entry.isCompleted,
                                controlAffinity: ListTileControlAffinity.trailing,
                                title: Text(entry.item.displayName),
                                subtitle: Text(
                                  '${entry.item.scheduleText()} · ${entry.item.durationText()}\n'
                                  '单次：$dosageText  频次：$frequencyText  时机：$mealText',
                                ),
                                onChanged: (checked) async {
                                  if (checked == null) return;
                                  setModalState(() {
                                    entry.item.setCompletion(date, checked);
                                  });
                                  await entry.prescription.save();
                                  if (mounted) {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (mounted) {
      setState(() {});
    }
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
          final all = box.values.toList()..sort((a, b) => b.visitDate.compareTo(a.visitDate));
          final selectedEntries = _scheduleEntriesForDate(_selectedDate, all);
          final done = selectedEntries.where((e) => e.isCompleted).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                '用药打卡日历',
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
                      final entries = _scheduleEntriesForDate(date, all);
                      _showDailySchedule(context, date, entries);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_dateText(_selectedDate)} 完成情况：$done/${selectedEntries.length}',
                style: TextStyle(color: Colors.grey.shade700),
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

