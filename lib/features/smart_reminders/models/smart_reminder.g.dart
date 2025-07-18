// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SmartReminderAdapter extends TypeAdapter<SmartReminder> {
  @override
  final int typeId = 6;

  @override
  SmartReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmartReminder(
      id: fields[0] as String,
      type: fields[1] as SmartReminderType,
      title: fields[2] as String,
      message: fields[3] as String?,
      timeOfDay: fields[4] as TimeOfDay,
      weekDays: (fields[5] as List).cast<int>(),
      isActive: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      lastTriggered: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SmartReminder obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.timeOfDay)
      ..writeByte(5)
      ..write(obj.weekDays)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastTriggered);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SmartReminderTypeAdapter extends TypeAdapter<SmartReminderType> {
  @override
  final int typeId = 7;

  @override
  SmartReminderType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SmartReminderType.friendlyCheckin;
      case 1:
        return SmartReminderType.scheduleReminder;
      default:
        return SmartReminderType.friendlyCheckin;
    }
  }

  @override
  void write(BinaryWriter writer, SmartReminderType obj) {
    switch (obj) {
      case SmartReminderType.friendlyCheckin:
        writer.writeByte(0);
        break;
      case SmartReminderType.scheduleReminder:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartReminderTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
