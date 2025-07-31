import 'package:hive/hive.dart';

class ContractorProvider {
  static Future<List<String>> loadContractors() async {
    final box = Hive.box<String>('contractorsBox');
    return box.values.toList();
  }

  static Future<void> addContractor(String name) async {
    if (name == '') return;
    final box = Hive.box<String>('contractorsBox');
    box.put(name, name);
    box.compact();
  }
}
