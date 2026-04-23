import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/medicine.dart';
import '../services/notification_service.dart';
import '../widgets/medicine_card.dart';
import 'add_page.dart';
import 'detail_page.dart';

class MedicineBoxPage extends StatefulWidget {
  const MedicineBoxPage({super.key});

  @override
  State<MedicineBoxPage> createState() => _MedicineBoxPageState();
}

class _MedicineBoxPageState extends State<MedicineBoxPage> {
  @override
  void initState() {
    super.initState();
    syncMedicineStock();
  }

  void syncMedicineStock() {
    final box = Hive.box<Medicine>('medicines');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var i = 0; i < box.length; i++) {
      final medicine = box.getAt(i);
      if (medicine == null || !medicine.trackInventory) continue;

      final lastUpdate = DateTime(
        medicine.lastUpdateDate.year,
        medicine.lastUpdateDate.month,
        medicine.lastUpdateDate.day,
      );

      final daysPassed = today.difference(lastUpdate).inDays;
      if (daysPassed <= 0) continue;

      final dailyDose = medicine.frequency * medicine.dosage;
      medicine.totalCount -= (daysPassed * dailyDose);
      if (medicine.totalCount < 0) medicine.totalCount = 0;

      medicine.lastUpdateDate = today;
      medicine.save();
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, Medicine medicine) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认移除？'),
        content: Text('确定要把“${medicine.name}”从药箱中删除吗？'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的药箱', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder<Box<Medicine>>(
        valueListenable: Hive.box<Medicine>('medicines').listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('药箱还是空的，点击下方 + 添加药品', style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final medicine = box.getAt(index);
              if (medicine == null) return const SizedBox.shrink();

              return Dismissible(
                key: Key(medicine.key.toString()),
                direction: DismissDirection.startToEnd,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
                ),
                confirmDismiss: (_) => _confirmDelete(context, medicine),
                onDismissed: (_) async {
                  await box.deleteAt(index);
                  if (box.isEmpty) {
                    await NotificationService.cancelAllReminders();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('药箱已清空，已关闭全局提醒')),
                      );
                    }
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已移除：${medicine.name}')),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MedicineDetailPage(medicine: medicine),
                        ),
                      );
                    },
                    child: MedicineCard(medicine: medicine),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicinePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
