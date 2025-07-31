// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanyInfoAdapter extends TypeAdapter<CompanyInfo> {
  @override
  final int typeId = 0;

  @override
  CompanyInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanyInfo(
      name: fields[0] as String,
      address: fields[1] as String,
      city: fields[2] as String,
      postalCode: fields[3] as String,
      phoneNumber: fields[4] as String,
      defaultRate: fields[5] as double,
      logoPath: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CompanyInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.postalCode)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.defaultRate)
      ..writeByte(6)
      ..write(obj.logoPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
