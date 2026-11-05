// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskTagAdapter extends TypeAdapter<TaskTag> {
  @override
  final int typeId = 0;

  @override
  TaskTag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskTag(
      label: fields[0] as String,
      backgroundColorValue: fields[1] as int?,
      textColorValue: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskTag obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.backgroundColorValue)
      ..writeByte(2)
      ..write(obj.textColorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      title: fields[0] as String,
      tags: (fields[1] as List).cast<TaskTag>(),
      date: fields[2] as String,
      linksCount: fields[3] as int,
      commentsCount: fields[4] as int,
      isDarkText: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.tags)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.linksCount)
      ..writeByte(4)
      ..write(obj.commentsCount)
      ..writeByte(5)
      ..write(obj.backgroundColorValue)
      ..writeByte(6)
      ..write(obj.isDarkText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
