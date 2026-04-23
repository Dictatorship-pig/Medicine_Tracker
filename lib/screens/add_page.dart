import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../models/medicine.dart';
import '../services/notification_service.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final List<String> _medicineTypes = ['处方药 (Rx)', '非处方药 (OTC)', '保健品', '其他'];
  final List<String> _mealTypes = ['饭前', '饭后', '随餐', '空腹', '按需'];
  final List<String> _unitPresets = ['片', '粒', '包', '支', '瓶', '袋', 'ml', 'g', '次'];

  String _selectedType = '处方药 (Rx)';
  String _selectedMeal = '按需';
  String _selectedUnitPreset = '片';

  bool _trackInventory = true;
  DateTime? _selectedDate;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _totalCountController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _dosageController = TextEditingController();
  final _unitCustomController = TextEditingController();
  final _usageInstructionController = TextEditingController();
  final _specificationController = TextEditingController();
  final _noteController = TextEditingController();
  final _batchNoController = TextEditingController();
  final _lowStockThresholdController = TextEditingController(text: '10');

  @override
  void dispose() {
    _nameController.dispose();
    _totalCountController.dispose();
    _frequencyController.dispose();
    _dosageController.dispose();
    _unitCustomController.dispose();
    _usageInstructionController.dispose();
    _specificationController.dispose();
    _noteController.dispose();
    _batchNoController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1000,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  String _dateText(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少填写药品名称')),
      );
      return;
    }

    final medicine = Medicine(
      name: _nameController.text.trim(),
      type: _selectedType,
      expiryDate: _selectedDate == null ? null : _dateText(_selectedDate!),
      totalCount: _trackInventory ? (int.tryParse(_totalCountController.text.trim()) ?? 0) : 0,
      frequency: int.tryParse(_frequencyController.text.trim()) ?? 0,
      dosage: int.tryParse(_dosageController.text.trim()) ?? 0,
      mealRelation: _selectedMeal,
      imagePath: _imageFile?.path,
      lastUpdateDate: DateTime.now(),
      unitPreset: _selectedUnitPreset,
      unitCustom: _unitCustomController.text.trim(),
      usageInstruction: _usageInstructionController.text.trim(),
      specification: _specificationController.text.trim(),
      note: _noteController.text.trim(),
      batchNo: _batchNoController.text.trim(),
      lowStockThreshold: int.tryParse(_lowStockThresholdController.text.trim()) ?? 10,
      trackInventory: _trackInventory,
    );

    final box = Hive.box<Medicine>('medicines');
    await box.add(medicine);

    if (box.isNotEmpty) {
      await NotificationService.enableGlobalReminders();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('药品已保存')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增药品'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _imageFile == null
                  ? const Center(
                      child: Text('可选：拍照留存药盒外观'),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('拍照'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('相册'),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '药品名称（必填）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: '分类',
                border: OutlineInputBorder(),
              ),
              items: _medicineTypes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnitPreset,
                    decoration: const InputDecoration(
                      labelText: '单位（预设）',
                      border: OutlineInputBorder(),
                    ),
                    items: _unitPresets
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedUnitPreset = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _unitCustomController,
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
                    controller: _frequencyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '每日次数（可空）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _dosageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '每次量（可空）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedMeal,
              decoration: const InputDecoration(
                labelText: '服药时机（可空）',
                border: OutlineInputBorder(),
              ),
              items: _mealTypes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedMeal = value);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() => _selectedDate = pickedDate);
                }
              },
              icon: const Icon(Icons.calendar_month),
              label: Text(_selectedDate == null ? '保质期（可空）' : '保质期：${_dateText(_selectedDate!)}'),
            ),
            if (_selectedDate != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _selectedDate = null),
                  child: const Text('清空保质期'),
                ),
              ),
            const Divider(height: 28),
            SwitchListTile(
              title: const Text('按库存管理'),
              subtitle: const Text('关闭后不计算余量与低库存状态'),
              value: _trackInventory,
              onChanged: (value) => setState(() => _trackInventory = value),
            ),
            if (_trackInventory) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _totalCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '总量',
                        border: const OutlineInputBorder(),
                        suffixText: _unitCustomController.text.trim().isNotEmpty
                            ? _unitCustomController.text.trim()
                            : _selectedUnitPreset,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _lowStockThresholdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '低库存阈值',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _specificationController,
              decoration: const InputDecoration(
                labelText: '规格（可空）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usageInstructionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '用法描述（可空）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _batchNoController,
              decoration: const InputDecoration(
                labelText: '批次（可空）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '备注（可空）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('保存药品'),
            ),
          ],
        ),
      ),
    );
  }
}
