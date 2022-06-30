import 'package:flutter/material.dart';
import 'package:mqtt_flutter_teste/ui/server.dart';

void main(){
  runApp(MaterialApp(
    title: "APS",
    home: Servidor(),
    debugShowCheckedModeBanner: false,
  ));
}