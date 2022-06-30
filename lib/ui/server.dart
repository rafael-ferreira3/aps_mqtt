import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_flutter_teste/data/map.dart';
import 'package:mqtt_flutter_teste/data/server.dart';
import 'package:mqtt_flutter_teste/model/server.dart';
import 'package:mqtt_flutter_teste/ui/servidor_conectado.dart';
import 'editServer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Servidor extends StatefulWidget {
  @override
  _ServidorState createState() => _ServidorState();
}

class _ServidorState extends State<Servidor> {
  String error = "";

  bool isConnected = false;

  Server server;

  final slideController = SlidableController();
  final String clientID = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _getServer();
  }

  void _getServer() {
    ServerHelper.readServer().then((s) {
      server = ServerHelper.mapToServer(StringToMap.stringToMap(s));
      server.clienteID = clientID;
      testConnection(server);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Servidor"),
        centerTitle: false,
        backgroundColor: Colors.deepOrange,

        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
             testConnection(server);
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _showEditPage(server: server); testConnection(server);
            },
          ),
        ],
      ),
      body: GestureDetector(
      onTap: () {
        if(isConnected)
          _conectarServidor(server);
        else
          setState(() {
            error = "Falha ao Conectar!";
          });
      },
      onLongPress: () {
        //_showOptions();
      },
      child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Text(error,
                  style: TextStyle(fontSize: 15.0, color: Colors.red)),
              Card(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(Icons.wifi, color: Colors.black),
                        Text("Servidor APS",
                            style: TextStyle(fontSize: 20.0)),
                        isConnected
                            ? Icon(Icons.check,color:Colors.green)
                            : Icon(Icons.clear,color: Colors.red),
                      ],
                    )),
              ),
            ],
          )),
    ),
    );
  }

  void _showEditPage({Server server}) async {
    final servidor = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditServer(server: server)));
    if (servidor != null) {
      ServerHelper.saveServer(StringToMap.stringToMap(servidor.toString())).then((file){
        _getServer();
      });
    }
  }

  void _conectarServidor(Server server) async {

    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ServidorConectado(server)));
  }

  void testConnection(Server server) async{
    final MqttClient client = MqttClient(server.url, server.clienteID);
    client.port = server.port;
    client.secure = false;

    setState(() {
      //isConnected = false;
      error ="";
    });

      try{
        _disconnect(client);
        await client.connect(server.user, server.password);
        if(client.connectionStatus.state == MqttConnectionState.connected) {
          setState(() {
            isConnected = true;
          });
        }
      }catch(e){
        setState(() {
          isConnected = false;
        });
      }
  }

  void _disconnect(MqttClient client) {
    client.disconnect();
    setState(() {
      client = null;
    });
  }


}