import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/prescription.dart';

class MedicationPlanPage extends StatelessWidget {
  const MedicationPlanPage({super.key});

  String _dateText(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<_ScheduleEntry> _scheduleEntriesForDate(
    DateTime date,
    List<Prescription> prescriptions,
  ) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return prescriptions.expand((prescription) {
      return prescription.items
          .where((item) {
            return item.isScheduledOn(normalizedDate, prescription.visitDate);
          })
          .map((item) {
            return _ScheduleEntry(
              prescription: prescription,
              item: item,
              date: normalizedDate,
            );
          });
    }).toList();
  }

  Widget _buildDaySection(DateTime date, List<Prescription> prescriptions) {
    final entries = _scheduleEntriesForDate(date, prescriptions);
    final completedCount = entries
        .where((entry) => entry.item.isCompletedOn(date))
        .length;
    return ExpansionTile(
      title: Text('${_dateText(date)} (${entries.length} 条计划)'),
      subtitle: Text('已完成 $completedCount / ${entries.length}'),
      children: entries.isEmpty
          ? [const Padding(padding: EdgeInsets.all(16), child: Text('该日无计划'))]
          : entries.map((entry) {
              return ListTile(
                title: Text(entry.item.medicineName),
                subtitle: Text(
                  '${entry.item.scheduleText()} · ${entry.item.durationText()}\n'
                  '单次：${entry.item.dosage.isEmpty ? '未填写' : entry.item.dosage}，频次：${entry.item.frequency.isEmpty ? '未填写' : entry.item.frequency}',
                ),
                trailing: Icon(
                  entry.item.isCompletedOn(date)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: entry.item.isCompletedOn(date)
                      ? Colors.green
                      : Colors.grey,
                ),
              );
            }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史 / 未来用药计划'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder<Box<Prescription>>(
        valueListenable: Hive.box<Prescription>('prescriptions').listenable(),
        builder: (context, box, _) {
          final prescriptions = box.values.toList();
          final today = DateTime.now();
          final currentDay = DateTime(today.year, today.month, today.day);
          final historyDates = List.generate(
            7,
            (index) => currentDay.subtract(Duration(days: 6 - index)),
          );
          final futureDates = List.generate(
            7,
            (index) => currentDay.add(Duration(days: index)),
          );

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: '历史记录'),
                    Tab(text: '未来计划'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView(
                        children: historyDates
                            .map(
                              (date) => _buildDaySection(date, prescriptions),
                            )
                            .toList(),
                      ),
                      ListView(
                        children: futureDates
                            .map(
                              (date) => _buildDaySection(date, prescriptions),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
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
}
