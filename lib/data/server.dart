import 'dart:convert';
import 'dart:io';
import 'package:mqtt_flutter_teste/model/server.dart';
import 'package:path_provider/path_provider.dart';

class ServerHelper{

  static Server mapToServer(Map m){
    Server s = Server();
    s.url = m["Url"];
    s.port = int.parse(m["Port"]);
    s.user = m["User"];
    s.password = m["Password"];
    return s;
  }

  static Future<File> _getServer() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/server.json");
  }

  static Future<File> saveServer(Map map) async {
    String data = json.encode(map);

    final file = await _getServer();
    return file.writeAsString(data);
  }

  static Future<String> readServer() async {
    try {
      final file = await _getServer();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}