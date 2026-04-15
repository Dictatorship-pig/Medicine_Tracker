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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('药方记录已删除')));
    }
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value, {
    Color textColor = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 28),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部信息展示区
            Container(
              height: 200,
              color: Colors.blue.shade50,
              child: const Icon(
                Icons.receipt_long,
                size: 80,
                color: Colors.blue,
              ),
            ),

            // 详细信息区域
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  const Text(
                    '就诊信息',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: const Text(
                      '处方单',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide.none,
                  ),

                  const Divider(height: 40, thickness: 1),

                  // 就诊信息
                  _buildInfoRow(
                    Icons.calendar_today,
                    '就诊日期',
                    _dateText(prescription.visitDate),
                  ),
                  if (prescription.followUpDate != null)
                    _buildInfoRow(
                      Icons.event_repeat,
                      '复诊日期',
                      _dateText(prescription.followUpDate!),
                    ),
                  if (prescription.hospital.isNotEmpty)
                    _buildInfoRow(
                      Icons.local_hospital,
                      '医院',
                      prescription.hospital,
                    ),
                  if (prescription.doctor.isNotEmpty)
                    _buildInfoRow(Icons.person, '医生', prescription.doctor),

                  const Divider(height: 40, thickness: 1),

                  // 诊断信息
                  if (prescription.diagnosis.isNotEmpty) ...[
                    const Text(
                      '诊断结果',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        prescription.diagnosis,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 医嘱
                  if (prescription.advice.isNotEmpty) ...[
                    const Text(
                      '医嘱',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        prescription.advice,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 护理建议
                  if (prescription.careNotes.isNotEmpty) ...[
                    const Text(
                      '护理建议',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        prescription.careNotes,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 药品明细
                  const Text(
                    '药品明细',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  if (prescription.items.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          '未添加药品',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...prescription.items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${i + 1}. ${item.medicineName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.access_time,
                                '服用频次',
                                item.frequency,
                              ),
                              _buildInfoRow(
                                Icons.local_pharmacy,
                                '单次用量',
                                item.dosage,
                              ),
                              _buildInfoRow(
                                Icons.calendar_view_day,
                                '服用天数',
                                '${item.days} 天',
                              ),
                              if (item.mealRelation.isNotEmpty)
                                _buildInfoRow(
                                  Icons.restaurant,
                                  '服用时机',
                                  item.mealRelation,
                                ),
                              if (item.remark.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '备注',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.remark,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
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
          ],
        ),
      ),
    );
  }
}
