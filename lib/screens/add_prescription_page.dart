import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/medicine.dart';
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
  final TextEditingController mealRelation = TextEditingController();
  final TextEditingController remark = TextEditingController();
  final TextEditingController unitCustom = TextEditingController();
  final TextEditingController instructionText = TextEditingController();

  String? medicineRefId;
  String unitPreset = '片';
  String scheduleType = 'daily';
  final Set<int> weekDays = <int>{};
  int durationCount = 1;
  String durationUnit = 'week';

  PrescriptionItem toItem() {
    final name = medicineName.text.trim();
    return PrescriptionItem(
      medicineName: name,
      medicineNameSnapshot: name,
      medicineRefId: medicineRefId,
      dosage: dosage.text.trim(),
      frequency: frequency.text.trim(),
      mealRelation: mealRelation.text.trim(),
      remark: remark.text.trim(),
      scheduleType: scheduleType,
      weekDays: weekDays.toList()..sort(),
      durationCount: durationCount,
      durationUnit: durationUnit,
      completedDates: const <String>[],
      days: 0,
      unitPreset: unitPreset,
      unitCustom: unitCustom.text.trim(),
      instructionText: instructionText.text.trim(),
    );
  }

  bool get isMeaningful => medicineName.text.trim().isNotEmpty;

  void dispose() {
    medicineName.dispose();
    frequency.dispose();
    dosage.dispose();
    mealRelation.dispose();
    remark.dispose();
    unitCustom.dispose();
    instructionText.dispose();
  }
}

class _AddPrescriptionPageState extends State<AddPrescriptionPage> {
  final _formKey = GlobalKey<FormState>();

  final _hospitalController = TextEditingController();
  final _doctorController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _adviceController = TextEditingController();
  final _careNotesController = TextEditingController();

  final List<String> _unitPresets = ['片', '粒', '包', '支', '瓶', '袋', 'ml', 'g', '次'];

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

  void _onSelectMedicine(_ItemDraft item, Medicine? medicine) {
    if (medicine == null) {
      setState(() {
        item.medicineRefId = null;
      });
      return;
    }

    setState(() {
      item.medicineRefId = medicine.key.toString();
      item.medicineName.text = medicine.name;
      item.unitPreset = medicine.unitPreset;
      item.unitCustom.text = medicine.unitCustom;
      if (item.mealRelation.text.trim().isEmpty && medicine.mealRelation.trim().isNotEmpty) {
        item.mealRelation.text = medicine.mealRelation;
      }
      if (item.frequency.text.trim().isEmpty && medicine.frequency > 0) {
        item.frequency.text = '每日${medicine.frequency}次';
      }
      if (item.dosage.text.trim().isEmpty && medicine.dosage > 0) {
        item.dosage.text = '${medicine.dosage}${medicine.displayUnit}';
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final validItems = _items.where((e) => e.isMeaningful).map((e) => e.toItem()).toList();
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少填写 1 个药品名称')),
      );
      return;
    }

    final invalidWeekly = validItems.any(
      (item) => item.scheduleType == 'weekly' && item.weekDays.isEmpty,
    );
    if (invalidWeekly) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('选择“每周几”时，至少勾选 1 天')),
      );
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('药方记录已保存')),
    );
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

  Widget _buildWeekdaySelector(_ItemDraft item) {
    const dayMap = <int, String>{
      1: '周一',
      2: '周二',
      3: '周三',
      4: '周四',
      5: '周五',
      6: '周六',
      7: '周日',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dayMap.entries.map((entry) {
        final selected = item.weekDays.contains(entry.key);
        return FilterChip(
          label: Text(entry.value),
          selected: selected,
          onSelected: (value) {
            setState(() {
              if (value) {
                item.weekDays.add(entry.key);
              } else {
                item.weekDays.remove(entry.key);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildItemCard(int index, Box<Medicine> medicineBox) {
    final item = _items[index];
    final medicines = medicineBox.values.toList();

    Medicine? linkedMedicine;
    if (item.medicineRefId != null) {
      linkedMedicine = medicines.cast<Medicine?>().firstWhere(
            (m) => m != null && m.key.toString() == item.medicineRefId,
            orElse: () => null,
          );
    }

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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    label: const Text('删除', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            DropdownButtonFormField<String?>(
              initialValue: item.medicineRefId,
              decoration: const InputDecoration(
                labelText: '关联药箱药品（可空）',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('不关联（仅保存快照）')),
                ...medicines.map(
                  (m) => DropdownMenuItem<String?>(
                    value: m.key.toString(),
                    child: Text(m.name),
                  ),
                ),
              ],
              onChanged: (refId) {
                if (refId == null) {
                  _onSelectMedicine(item, null);
                  return;
                }
                final found = medicines.firstWhere((m) => m.key.toString() == refId);
                _onSelectMedicine(item, found);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: item.medicineName,
              decoration: const InputDecoration(
                labelText: '药品名称快照（必填）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: item.unitPreset,
                    decoration: const InputDecoration(
                      labelText: '单位（预设）',
                      border: OutlineInputBorder(),
                    ),
                    items: _unitPresets
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => item.unitPreset = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: item.unitCustom,
                    decoration: const InputDecoration(
                      labelText: '自定义单位（可空）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.frequency,
                    decoration: const InputDecoration(
                      labelText: '服药频次（可空）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: item.dosage,
                    decoration: const InputDecoration(
                      labelText: '单次用量（可空）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: item.mealRelation,
              decoration: const InputDecoration(
                labelText: '服药时机（可空）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: item.instructionText,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '自由描述（可空）',
                hintText: '例如：晚饭后半包，温水冲服',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: item.scheduleType,
                    decoration: const InputDecoration(
                      labelText: '计划方式',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('每日')),
                      DropdownMenuItem(value: 'weekly', child: Text('每周几')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => item.scheduleType = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: item.durationCount.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '持续',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final parsed = int.tryParse(value.trim()) ?? 1;
                            item.durationCount = parsed <= 0 ? 1 : parsed;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: item.durationUnit,
                          decoration: const InputDecoration(
                            labelText: '单位',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'week', child: Text('周')),
                            DropdownMenuItem(value: 'month', child: Text('月')),
                            DropdownMenuItem(value: 'forever', child: Text('一直')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => item.durationUnit = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.scheduleType == 'weekly') ...[
              const SizedBox(height: 12),
              const Text('选择每周用药日：', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildWeekdaySelector(item),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: item.remark,
              decoration: const InputDecoration(
                labelText: '备注（可空）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
            if (linkedMedicine != null) ...[
              const SizedBox(height: 8),
              Text(
                '已关联药箱：${linkedMedicine.name}',
                style: TextStyle(color: Colors.teal.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Medicine>>(
      valueListenable: Hive.box<Medicine>('medicines').listenable(),
      builder: (context, medicineBox, _) {
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
                      labelText: '医院（可空）',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _doctorController,
                    decoration: const InputDecoration(
                      labelText: '医生（可空）',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _diagnosisController,
                    decoration: const InputDecoration(
                      labelText: '诊断（可空）',
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
                      labelText: '医嘱（可空）',
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
                      labelText: '其他护理方法（可空）',
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
                  ...List.generate(_items.length, (index) => _buildItemCard(index, medicineBox)),
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
      },
    );
  }
}
