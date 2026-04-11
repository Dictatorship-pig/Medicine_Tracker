# medicine_tracker

一个面向中文用户（含老年人使用场景）的 Flutter 药品管理应用。  
当前已包含药箱管理、药方记录基础模块，并预留后续“用药打卡日历”扩展能力。

## 项目入口

- 应用入口：`lib/main.dart`
- 首页（药箱）：`lib/screens/home_page.dart`
- 药方平行页面入口：药箱首页右上角 `药方记录` 图标按钮
- 药方主页：`lib/screens/prescription_home_page.dart`

## 当前页面结构

- 药品模块
- `lib/screens/home_page.dart`：药箱列表、删除药品、跳转详情、跳转新增
- `lib/screens/add_page.dart`：新增药品
- `lib/screens/detail_page.dart`：药品详情

- 药方模块
- `lib/screens/prescription_home_page.dart`：上方日历（打卡预留）、下方药方记录列表
- `lib/screens/add_prescription_page.dart`：新增药方（就诊日期、复诊日期、医嘱、药品清单）
- `lib/screens/prescription_detail_page.dart`：药方详情查看与删除

## 数据存储

- 本地数据库：Hive
- 已启用数据模型：
- `Medicine`：`lib/models/medicine.dart`
- `Prescription` / `PrescriptionItem`：`lib/models/prescription.dart`

## 运行与开发

1. 安装依赖

```bash
flutter pub get
```

2. 生成 Hive 代码（首次或模型变更后）

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. 运行项目

```bash
flutter run
```

## 提交前建议检查

```bash
flutter analyze
```

## 后续规划（已预留）

- 用药打卡日历（与日历组件联动）
- 过期提醒与复诊提醒强化
- OCR 识别处方单自动填充（后续接 API）

---

## 原始模板说明（保留）

A new Flutter project.

### Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

