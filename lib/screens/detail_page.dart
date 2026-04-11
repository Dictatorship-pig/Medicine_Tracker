// 文件位置：lib/screens/detail_page.dart
import 'dart:io';
import 'package:flutter/foundation.dart'; // 用于 kIsWeb 判断
import 'package:flutter/material.dart';
import '../models/medicine.dart';

class MedicineDetailPage extends StatelessWidget {
  // 接收从首页传过来的“那一盒药”的具体数据
  final Medicine medicine;

  const MedicineDetailPage({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    // 算一下还有几天过期，用来给日期标红
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expDate = DateTime.parse(medicine.expiryDate);
    final expDateOnly = DateTime(expDate.year, expDate.month, expDate.day);
    final daysToExpiry = expDateOnly.difference(today).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('药品详情'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // SingleChildScrollView 允许页面上下滑动（万一内容太多屏幕装不下）
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // 1. 顶部照片展示区
            // ==========================================
            if (medicine.imagePath != null)
              SizedBox(
                height: 280, // 照片给个大尺寸
                child: kIsWeb
                    ? Image.network(medicine.imagePath!, fit: BoxFit.cover)
                    : Image.file(File(medicine.imagePath!), fit: BoxFit.cover),
              )
            else
              // 如果没拍照片，显示一个默认的绿色大图标背景
              Container(
                height: 200,
                color: Colors.teal.shade50,
                child: const Icon(Icons.medication, size: 80, color: Colors.teal),
              ),

            // ==========================================
            // 2. 详细信息卡片区
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 药名和分类
                  Text(medicine.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(medicine.type, style: const TextStyle(fontSize: 16, color: Colors.teal)),
                    backgroundColor: Colors.teal.shade50,
                    side: BorderSide.none,
                  ),
                  
                  const Divider(height: 40, thickness: 1),
                  
                  // 👇 核心用药指南（大字号，带图标）
                  _buildInfoRow(Icons.access_time_filled, '用药频率', '一天 ${medicine.frequency} 次'),
                  _buildInfoRow(Icons.local_pharmacy, '单次用量', '一次 ${medicine.dosage} 粒'),
                  _buildInfoRow(Icons.restaurant, '服用时机', medicine.mealRelation),
                  _buildInfoRow(Icons.inventory_2, '剩余总量', '共 ${medicine.totalCount} 粒'),
                  
                  const Divider(height: 40, thickness: 1),

                  // 保质期警告
                  _buildInfoRow(
                    Icons.event_busy, 
                    '保质期至', 
                    medicine.expiryDate,
                    // 如果过期了，字变成红色警告！
                    textColor: daysToExpiry <= 0 ? Colors.red : Colors.black87,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🛠️ 这是一个我自己封装的“小积木”，用来专门画这种带图标的一行字，避免代码重复
  Widget _buildInfoRow(IconData icon, String title, String value, {Color textColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 28),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const Spacer(), // Spacer 会自动把左边和右边的东西推向两端
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}