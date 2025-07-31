import 'package:hive/hive.dart';
import '/models/client_info.dart';

class ClientsProvider {
  static Future<List<String>> loadClientNames() async {
    final box = Hive.box<ClientInfo>('clientsBox');
    List<String> names = [];
    for (var client in box.values) {
      names.add(client.name);
    }
    return names;
  }

  static Future<ClientInfo?> loadClientInfo(String name) async {
    final box = Hive.box<ClientInfo>('clientsBox');
    for (var client in box.values) {
      if (client.name == name) {
        return client;
      }
    }
    return null;
  }

  static Future<void> addClientInfo(ClientInfo info) async {
    final box = Hive.box<ClientInfo>('clientsBox');

    for (int i = 0; i < box.values.length; i++) {
      ClientInfo client = box.values.elementAt(i);
      if (client.name == info.name) {
        box.putAt(i, info);
        return;
      }
    }
    box.add(info);
    box.compact();
  }
}
