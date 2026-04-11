import 'dart:io'; // 👇 1. 用来处理本地文件 (照片)
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart'; // 👇 2. 引入相机相册工具
import '../models/medicine.dart';
import '../services/notification_service.dart';
class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  // 👇 3. 采用你精简后的 4 大分类！
  String selectedType = '处方药 (Rx)';
  final List<String> medicineTypes = ['处方药 (Rx)', '非处方药 (OTC)', '保健品', '其他'];
  
  String selectedMeal = '饭后';
  final List<String> mealTypes = ['饭前', '饭后', '随餐', '空腹'];

  DateTime? _selectedDate; 
  
  // --- 图片相关的变量和方法 ---
  File? _imageFile; // 用来存放选中的照片
  final ImagePicker _picker = ImagePicker();

  // 呼叫相机或相册的方法
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800, // 压缩一下图片，防止把手机内存撑爆
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // 把拍好的照片存起来，让屏幕刷新显示
      });
    }
  }

  // --- 输入框监听器 ---
  final TextEditingController _nameController = TextEditingController(); 
  final TextEditingController _totalCountController = TextEditingController(); 
  final TextEditingController _frequencyController = TextEditingController(); 
  final TextEditingController _dosageController = TextEditingController(); 

  @override
  void dispose() {
    _nameController.dispose();
    _totalCountController.dispose();
    _frequencyController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加新药品'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ==========================================
            // 👇 新增的 UI：照片展示与上传区域 (极其适合中老年人)
            // ==========================================
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              ),
              child: _imageFile != null
                  // 如果有照片，就铺满显示出来
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                    )
                  // 如果没照片，显示提示文字
                  : const Center(
                      child: Text('📷 拍一张药盒照片\n防止以后吃错药', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
            ),
            const SizedBox(height: 12),
            // 拍照和相册的两个大按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera), // 调起相机
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('拍照'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery), // 调起相册
                    icon: const Icon(Icons.photo_library),
                    label: const Text('相册'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
            const Divider(height: 40, thickness: 2),
            // ==========================================

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '药品名称 (必填)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.medical_information)),
            ),
            const SizedBox(height: 16),

            // 👇 这里已经自动变成了你的 4 大分类
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '药品分类', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
              value: selectedType,
              items: medicineTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (newValue) => setState(() => selectedType = newValue!),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: TextField(controller: _frequencyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '一天几次', border: OutlineInputBorder(), suffixText: '次'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _dosageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '一次几粒', border: OutlineInputBorder(), suffixText: '粒/片'))),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: TextField(controller: _totalCountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '药品总量', border: OutlineInputBorder(), suffixText: '粒/片'))),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '服用时机', border: OutlineInputBorder()),
                    value: selectedMeal,
                    items: mealTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (newValue) => setState(() => selectedMeal = newValue!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () async { 
                DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2050));
                if (pickedDate != null) setState(() => _selectedDate = pickedDate);
              },
              icon: const Padding(padding: EdgeInsets.only(left: 12.0), child: Icon(Icons.calendar_month)),
              label: Padding(
                padding: const EdgeInsets.only(left: 12.0), 
                child: Text(_selectedDate == null ? '点击选择保质期 (必填)' : '保质期至：${_selectedDate.toString().split(' ')[0]}', style: const TextStyle(fontSize: 16)),
              ),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), alignment: Alignment.centerLeft),
            ),
            const SizedBox(height: 40),

            FilledButton(
              onPressed: () async {
                if (_nameController.text.isEmpty || _selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ 请填写药品名称并选择保质期！')));
                  return; 
                }

                // 1. 打包药品数据
                final newMedicine = Medicine(
                  name: _nameController.text,
                  type: selectedType, 
                  expiryDate: _selectedDate.toString().split(' ')[0],
                  totalCount: int.tryParse(_totalCountController.text) ?? 0,
                  frequency: int.tryParse(_frequencyController.text) ?? 0,
                  dosage: int.tryParse(_dosageController.text) ?? 0,
                  mealRelation: selectedMeal,
                  imagePath: _imageFile?.path, 
                  lastUpdateDate: DateTime.now(), 
                );

                var box = Hive.box<Medicine>('medicines');
                await box.add(newMedicine); // 存入数据库

                // ==========================================
                // 👇 2. 极简逻辑：只要添加了药，就无脑开启全局提醒！
                // (如果之前已经开启过，系统会自动用同样的ID覆盖，不会重复)
                // ==========================================
                await NotificationService.enableGlobalReminders();

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ 药品添加成功，已为您开启每日用药提醒！')));
                Navigator.pop(context); 
              },
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('保存到我的药箱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}