import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MessageHelper{


  static Future<File> _getMessage() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/lastMessage.json");
  }

  static Future<File> saveMessage(Map map) async {
    String data = json.encode(map);

    final file = await _getMessage();
    return file.writeAsString(data);
  }

  static Future<String> readMessage() async {
    try {
      final file = await _getMessage();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}