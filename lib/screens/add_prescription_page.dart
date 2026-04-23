import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/prescription.dart';

class AddPrescriptionPage extends StatefulWidget {
  const AddPrescriptionPage({super.key});

  @override
  State<AddPrescriptionPage> createState() => _AddPrescriptionPageState();
}

class _ItemDraft {
  final TextEditingController medicineName = TextEditingController();
  final TextEditingController frequency = TextEditingController();
  final TextEditingController dosage = TextEditingController();
  final TextEditingController days = TextEditingController();
  final TextEditingController mealRelation = TextEditingController();
  final TextEditingController remark = TextEditingController();

  PrescriptionItem toItem() {
    return PrescriptionItem(
      medicineName: medicineName.text.trim(),
      dosage: dosage.text.trim(),
      frequency: frequency.text.trim(),
      days: int.tryParse(days.text.trim()) ?? 1,
      mealRelation: mealRelation.text.trim(),
      remark: remark.text.trim(),
      scheduleType: 'daily',
      weekDays: const [],
      durationCount: int.tryParse(days.text.trim()) ?? 1,
      durationUnit: '天',
      completedDates: const [],
    );
  }

  bool get isMeaningful => medicineName.text.trim().isNotEmpty;

  void dispose() {
    medicineName.dispose();
    frequency.dispose();
    dosage.dispose();
    days.dispose();
    mealRelation.dispose();
    remark.dispose();
  }
}

class _AddPrescriptionPageState extends State<AddPrescriptionPage> {
  final _formKey = GlobalKey<FormState>();

  final _hospitalController = TextEditingController();
  final _doctorController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _adviceController = TextEditingController();
  final _careNotesController = TextEditingController();

  DateTime _visitDate = DateTime.now();
  DateTime? _followUpDate;
  final List<_ItemDraft> _items = [_ItemDraft()];

  @override
  void dispose() {
    _hospitalController.dispose();
    _doctorController.dispose();
    _diagnosisController.dispose();
    _adviceController.dispose();
    _careNotesController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  String _dateText(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _visitDate = picked);
    }
  }

  Future<void> _pickFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? _visitDate.add(const Duration(days: 7)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _followUpDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final validItems = _items
        .where((e) => e.isMeaningful)
        .map((e) => e.toItem())
        .toList();
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请至少填写 1 个药品名称')));
      return;
    }

    final prescription = Prescription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      visitDate: _visitDate,
      followUpDate: _followUpDate,
      hospital: _hospitalController.text.trim(),
      doctor: _doctorController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      advice: _adviceController.text.trim(),
      careNotes: _careNotesController.text.trim(),
      items: validItems,
      createdAt: DateTime.now(),
    );

    await Hive.box<Prescription>('prescriptions').add(prescription);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('药方记录已保存')));
    Navigator.pop(context);
  }

  Widget _buildDateButton({
    required String label,
    required String value,
    required VoidCallback onTap,
    IconData icon = Icons.calendar_month,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Padding(padding: const EdgeInsets.only(left: 8), child: Icon(icon)),
      label: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text('$label：$value', style: const TextStyle(fontSize: 16)),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = _items[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '药品 ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (_items.length > 1)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        final target = _items.removeAt(index);
                        target.dispose();
                      });
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      '删除',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: item.medicineName,
              decoration: const InputDecoration(
                labelText: '药品名称',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.frequency,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '一天几次',
                      border: OutlineInputBorder(),
                      suffixText: '次',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: item.dosage,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '一次几粒',
                      border: OutlineInputBorder(),
                      suffixText: '粒/片',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.days,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '服用几天',
                      border: OutlineInputBorder(),
                      suffixText: '天',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '服用时机',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '饭前', child: Text('饭前')),
                      DropdownMenuItem(value: '饭后', child: Text('饭后')),
                      DropdownMenuItem(value: '随餐', child: Text('随餐')),
                      DropdownMenuItem(value: '空腹', child: Text('空腹')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        item.mealRelation.text = value;
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: item.remark,
              decoration: const InputDecoration(
                labelText: '备注',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增药方'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildDateButton(
                label: '就诊日期',
                value: _dateText(_visitDate),
                onTap: _pickVisitDate,
              ),
              const SizedBox(height: 10),
              _buildDateButton(
                label: '复诊日期',
                value: _followUpDate == null
                    ? '未设置（可为空）'
                    : _dateText(_followUpDate!),
                onTap: _pickFollowUpDate,
              ),
              if (_followUpDate != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _followUpDate = null),
                    child: const Text('清空复诊日期'),
                  ),
                ),
              const Divider(height: 28, thickness: 1.5),
              TextField(
                controller: _hospitalController,
                decoration: const InputDecoration(
                  labelText: '医院',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: '医生',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: '诊断',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fact_check_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _adviceController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '医嘱',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _careNotesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '其他护理方法',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.health_and_safety_outlined),
                ),
              ),
              const Divider(height: 32, thickness: 1.5),
              const Text(
                '药品清单',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...List.generate(_items.length, _buildItemCard),
              OutlinedButton.icon(
                onPressed: () => setState(() => _items.add(_ItemDraft())),
                icon: const Icon(Icons.add),
                label: const Text('添加一个药品'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  '保存药方',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
