import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:medicine_tracker/main.dart';
import 'package:medicine_tracker/models/medicine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Hive.init('./test/hive_test_data');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicineAdapter());
    }
    await Hive.openBox<Medicine>('medicines');
  });

  tearDownAll(() async {
    await Hive.box<Medicine>('medicines').clear();
    await Hive.close();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MedicineApp());
    expect(find.byType(MedicineApp), findsOneWidget);
  });
}
