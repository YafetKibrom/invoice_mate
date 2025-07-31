// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClientInfoAdapter extends TypeAdapter<ClientInfo> {
  @override
  final int typeId = 1;

  @override
  ClientInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClientInfo(
      name: fields[0] as String,
      address: fields[1] as String,
      city: fields[2] as String,
      postalCode: fields[3] as String,
      phoneNumber: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClientInfo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.postalCode)
      ..writeByte(4)
      ..write(obj.phoneNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
