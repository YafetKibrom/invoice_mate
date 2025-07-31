import 'package:hive/hive.dart';

part 'company_info.g.dart';

@HiveType(typeId: 0)
class CompanyInfo extends HiveObject {
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

  @HiveField(5)
  double defaultRate;

  @HiveField(6)
  String? logoPath = '';

  CompanyInfo({
    required this.name,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.phoneNumber,
    required this.defaultRate,
    this.logoPath,
  });
}
