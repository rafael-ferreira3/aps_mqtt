import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_flutter_teste/data/map.dart';
import 'package:mqtt_flutter_teste/data/message.dart';
import 'package:mqtt_flutter_teste/model/msg.dart';
import 'package:mqtt_flutter_teste/model/server.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_flutter_teste/custom_icon/icons.dart' as customicon;

class ServidorConectado extends StatefulWidget {
  final Server server;

  ServidorConectado(this.server);

  @override
  _ServidorConectadoState createState() => _ServidorConectadoState();
}

class _ServidorConectadoState extends State<ServidorConectado> {
  final slideController = SlidableController();

  List<Message> messageList = List();
  Map messageMaps = Map();

  List<String> local = List();

  MqttClient client;

  StreamSubscription subscription;

  DateTime dateTemp;
  DateTime dateHumi;

  @override
  void initState() {
    super.initState();
    MessageHelper.readMessage().then((string) {
      setState(() {
        messageMaps = StringToMap.stringToMap(string);
      });
    });

    client = MqttClient(widget.server.url, widget.server.clienteID);
    client.keepAlivePeriod = 5;
    client.port = widget.server.port;
    client.secure = false;
    this.connect(widget.server);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text("Sensor"),
            centerTitle: true,
            backgroundColor: Colors.deepOrange,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Card(
                        child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 30.0),
                                child: Icon(
                                  Icons.brightness_high,
                                  color: Colors.deepOrangeAccent,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 5.0),
                                    child: Text("Temperatura",
                                        style: TextStyle(fontSize: 20.0)),
                                  ),
                                  messageMaps["APS/Temperatura"] != null
                                      ? Text(
                                          "${messageMaps["APS/Temperatura"]}ºC",
                                          style: TextStyle(fontSize: 30.0))
                                      : Text("Sem Leitura",
                                          style: TextStyle(fontSize: 25.0)),
                                ],
                              ),
                            ],
                          ),
                          Divider(color: Colors.transparent),
                          messageMaps["APS/Temperatura/date"] != null
                              ? Text(messageMaps["APS/Temperatura/date"],
                              style: TextStyle(fontSize: 17.0))
                              : Text(""),
                        ],
                      ),
                    )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 30.0),
                                  child: Icon(
                                    customicon.MyFlutterApp.droplet,
                                    //IconData(0xe800, fontFamily: 'MyFlutterApp'),
                                    color: Colors.lightBlueAccent,
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 5.0),
                                      child: Text("Umidade",
                                          style: TextStyle(fontSize: 20.0)),
                                    ),
                                    messageMaps["APS/Humidade"] != null
                                        ? Text(
                                            "${messageMaps["APS/Humidade"]}%",
                                            style: TextStyle(fontSize: 30.0))
                                        : Text("Sem Leitura",
                                            style: TextStyle(fontSize: 25.0)),
                                  ],
                                )
                              ],
                            ),
                            Divider(color: Colors.transparent),
                            messageMaps["APS/Humidade/date"] != null
                                ? Text(messageMaps["APS/Humidade/date"],
                                    style: TextStyle(fontSize: 17.0))
                                : Text(""),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  void connect(Server server) async{
    try{
      await client.connect(server.user, server.password);
    }catch(e){
      client.disconnect();
      Navigator.pop(context);
    }

    if (client.connectionStatus.state == MqttConnectionState.connected) {
      String topic = 'APS/Temperatura';
      client.subscribe(topic, MqttQos.exactlyOnce);
      String topic2 = 'APS/Humidade';
      client.subscribe(topic2, MqttQos.exactlyOnce);

      subscription =
          client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
            final MqttPublishMessage recMess = c[0].payload;
            final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
            setState(() {
              DateTime now = DateTime.now();
              messageMaps[c[0].topic] = pt;
              messageMaps["${c[0].topic}/date"] =
                  DateFormat('dd-MM-yyyy – kk:mm:ss').format(now);
              MessageHelper.saveMessage(messageMaps);
            });
          });
    }else{
      client.disconnect();
      Navigator.pop(context);
    }

  }

  void _disconnect() {
    client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    setState(() {
      subscription.cancel();
      subscription = null;
    });
  }

}
