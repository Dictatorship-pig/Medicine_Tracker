// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrescriptionAdapter extends TypeAdapter<Prescription> {
  @override
  final int typeId = 1;

  @override
  Prescription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Prescription(
      id: fields[0] as String,
      visitDate: fields[1] as DateTime,
      followUpDate: fields[2] as DateTime?,
      hospital: fields[3] as String,
      doctor: fields[4] as String,
      diagnosis: fields[5] as String,
      advice: fields[6] as String,
      careNotes: fields[7] as String,
      items: (fields[8] as List).cast<PrescriptionItem>(),
      createdAt: fields[9] as DateTime,
      isStopped: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Prescription obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.visitDate)
      ..writeByte(2)
      ..write(obj.followUpDate)
      ..writeByte(3)
      ..write(obj.hospital)
      ..writeByte(4)
      ..write(obj.doctor)
      ..writeByte(5)
      ..write(obj.diagnosis)
      ..writeByte(6)
      ..write(obj.advice)
      ..writeByte(7)
      ..write(obj.careNotes)
      ..writeByte(8)
      ..write(obj.items)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.isStopped);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrescriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrescriptionItemAdapter extends TypeAdapter<PrescriptionItem> {
  @override
  final int typeId = 2;

  @override
  PrescriptionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrescriptionItem(
      medicineName: fields[0] as String,
      dosage: fields[1] as String,
      frequency: fields[2] as String,
      days: fields[3] as int,
      mealRelation: fields[4] as String,
      remark: fields[5] as String,
      scheduleType: fields[6] as String,
      weekDays: (fields[7] as List?)?.cast<int>(),
      durationCount: fields[8] as int,
      durationUnit: fields[9] as String,
      completedDates: (fields[10] as List?)?.cast<String>(),
      medicineRefId: fields[11] as String?,
      medicineNameSnapshot: fields[12] as String?,
      unitPreset: fields[13] as String,
      unitCustom: fields[14] as String,
      instructionText: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PrescriptionItem obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.medicineName)
      ..writeByte(1)
      ..write(obj.dosage)
      ..writeByte(2)
      ..write(obj.frequency)
      ..writeByte(3)
      ..write(obj.days)
      ..writeByte(4)
      ..write(obj.mealRelation)
      ..writeByte(5)
      ..write(obj.remark)
      ..writeByte(6)
      ..write(obj.scheduleType)
      ..writeByte(7)
      ..write(obj.weekDays)
      ..writeByte(8)
      ..write(obj.durationCount)
      ..writeByte(9)
      ..write(obj.durationUnit)
      ..writeByte(10)
      ..write(obj.completedDates)
      ..writeByte(11)
      ..write(obj.medicineRefId)
      ..writeByte(12)
      ..write(obj.medicineNameSnapshot)
      ..writeByte(13)
      ..write(obj.unitPreset)
      ..writeByte(14)
      ..write(obj.unitCustom)
      ..writeByte(15)
      ..write(obj.instructionText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrescriptionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
