import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/medicine.dart';
import '../models/prescription.dart';

class PrescriptionDetailPage extends StatefulWidget {
  final Prescription prescription;

  const PrescriptionDetailPage({super.key, required this.prescription});

  @override
  State<PrescriptionDetailPage> createState() => _PrescriptionDetailPageState();
}

class _PrescriptionDetailPageState extends State<PrescriptionDetailPage> {
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

    await widget.prescription.delete();
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('药方记录已删除')),
      );
    }
  }

  Future<void> _toggleStopped() async {
    setState(() {
      widget.prescription.isStopped = !widget.prescription.isStopped;
    });
    await widget.prescription.save();
  }

  Future<void> _addToMedicineBox(PrescriptionItem item) async {
    final totalController = TextEditingController(text: '1');
    DateTime? expiryDate;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('加入药箱：${item.displayName}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: totalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '初始总量',
                        suffixText: item.displayUnit,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() => expiryDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        expiryDate == null
                            ? '保质期（可空）'
                            : '保质期：${_dateText(expiryDate!)}',
                      ),
                    ),
                    if (expiryDate != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setStateDialog(() => expiryDate = null),
                          child: const Text('清空保质期'),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('加入药箱'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    final total = int.tryParse(totalController.text.trim()) ?? 1;
    final medicine = Medicine(
      name: item.displayName,
      type: '处方药 (Rx)',
      expiryDate: expiryDate == null ? null : _dateText(expiryDate!),
      totalCount: total <= 0 ? 1 : total,
      frequency: 0,
      dosage: 0,
      mealRelation: item.mealRelation,
      lastUpdateDate: DateTime.now(),
      unitPreset: item.unitPreset,
      unitCustom: item.unitCustom,
      usageInstruction: item.instructionText,
      specification: '',
      note: item.remark,
      batchNo: '',
      lowStockThreshold: 10,
      trackInventory: true,
    );

    await Hive.box<Medicine>('medicines').add(medicine);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已加入药箱：${item.displayName}')),
    );
  }

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
    final prescription = widget.prescription;

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, size: 26, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text('就诊信息', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Chip(label: Text('状态：${prescription.treatmentStatusText()}')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _toggleStopped,
                    icon: Icon(prescription.isStopped ? Icons.play_arrow : Icons.stop),
                    label: Text(prescription.isStopped ? '恢复进行中' : '标记已停用'),
                  ),
                ],
              ),
              const Divider(height: 22),
              _buildInfoRow(Icons.calendar_today, '就诊日期', _dateText(prescription.visitDate)),
              _buildInfoRow(
                Icons.event_repeat,
                '复诊日期',
                prescription.followUpDate == null ? '未填写' : _dateText(prescription.followUpDate!),
              ),
              _buildInfoRow(Icons.local_hospital, '医院', prescription.hospital.isEmpty ? '未填写' : prescription.hospital),
              _buildInfoRow(Icons.person, '医生', prescription.doctor.isEmpty ? '未填写' : prescription.doctor),
              _buildInfoRow(Icons.fact_check, '诊断', prescription.diagnosis.isEmpty ? '未填写' : prescription.diagnosis),
              _buildInfoRow(Icons.medical_services, '医嘱', prescription.advice.isEmpty ? '未填写' : prescription.advice),
              _buildInfoRow(Icons.health_and_safety, '护理建议', prescription.careNotes.isEmpty ? '未填写' : prescription.careNotes),
              const Divider(height: 28),
              const Text('药品明细', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (prescription.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('未添加药品'),
                )
              else
                ...prescription.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${index + 1}. ${item.displayName}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (item.medicineRefId != null)
                                const Chip(label: Text('已关联药箱')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.straighten, '单位', item.displayUnit),
                          _buildInfoRow(Icons.access_time, '服药频次', item.frequency.isEmpty ? '未填写' : item.frequency),
                          _buildInfoRow(Icons.local_pharmacy, '单次用量', item.dosage.isEmpty ? '未填写' : item.dosage),
                          _buildInfoRow(Icons.restaurant, '服药时机', item.mealRelation.isEmpty ? '未填写' : item.mealRelation),
                          _buildInfoRow(Icons.repeat, '计划方式', '${item.scheduleText()} · ${item.durationText()}'),
                          _buildInfoRow(Icons.description, '自由描述', item.instructionText.isEmpty ? '未填写' : item.instructionText),
                          _buildInfoRow(Icons.note_alt, '备注', item.remark.isEmpty ? '未填写' : item.remark),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () => _addToMedicineBox(item),
                              icon: const Icon(Icons.inventory_2_outlined),
                              label: const Text('加入药箱'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
