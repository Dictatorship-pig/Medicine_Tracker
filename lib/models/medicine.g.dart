// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 0;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      name: fields[0] as String,
      type: fields[1] as String,
      expiryDate: fields[2] as String?,
      totalCount: fields[3] as int,
      frequency: fields[4] as int,
      dosage: fields[5] as int,
      mealRelation: fields[6] as String,
      imagePath: fields[7] as String?,
      lastUpdateDate: fields[8] as DateTime,
      unitPreset: fields[9] as String,
      unitCustom: fields[10] as String,
      usageInstruction: fields[11] as String,
      specification: fields[12] as String,
      note: fields[13] as String,
      batchNo: fields[14] as String,
      lowStockThreshold: fields[15] as int,
      trackInventory: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.expiryDate)
      ..writeByte(3)
      ..write(obj.totalCount)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.dosage)
      ..writeByte(6)
      ..write(obj.mealRelation)
      ..writeByte(7)
      ..write(obj.imagePath)
      ..writeByte(8)
      ..write(obj.lastUpdateDate)
      ..writeByte(9)
      ..write(obj.unitPreset)
      ..writeByte(10)
      ..write(obj.unitCustom)
      ..writeByte(11)
      ..write(obj.usageInstruction)
      ..writeByte(12)
      ..write(obj.specification)
      ..writeByte(13)
      ..write(obj.note)
      ..writeByte(14)
      ..write(obj.batchNo)
      ..writeByte(15)
      ..write(obj.lowStockThreshold)
      ..writeByte(16)
      ..write(obj.trackInventory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
