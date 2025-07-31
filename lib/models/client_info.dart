import 'package:hive/hive.dart';

part 'client_info.g.dart';

@HiveType(typeId: 1)
class ClientInfo extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String address;

  @HiveField(2)
  String city;

  @HiveField(3)
  String postalCode;

  @HiveField(4)
  String phoneNumber;

  ClientInfo({
    required this.name,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.phoneNumber,
  });
}
