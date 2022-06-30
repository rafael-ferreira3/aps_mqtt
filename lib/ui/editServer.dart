import 'package:flutter/material.dart';
import 'package:mqtt_flutter_teste/model/server.dart';


class EditServer extends StatefulWidget {

  final Server server;
  EditServer({this.server});

  @override
  _EditServerState createState() => _EditServerState();
}

class _EditServerState extends State<EditServer> {

  final _urlController      = TextEditingController();
  final _portController     = TextEditingController();
  final _userController     = TextEditingController();
  final _passwordController = TextEditingController();


  Server _serverEdited;
  bool _edited = false;

  String error = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      error = "";
    });
    if(widget.server == null){
      _serverEdited = Server();
    }else{
      setState(() {
        _serverEdited = widget.server;
        _urlController.text      = _serverEdited.url;
        _portController.text     = _serverEdited.port.toString();
        _userController.text     = _serverEdited.user;
        _passwordController.text = _serverEdited.password;
      });
      print(_serverEdited.toString());
    }
  }


  void _urlChange(String s){
    _serverEdited.url = s;
    _edited = true;
  }

  void _portChange(String s){
    if(s.contains(".")||s.contains("-")){
      String aux = s.replaceAll(".", "");
      aux = aux.replaceAll("-", "");
      setState(() {
        _portController.text = aux;
      });
    }
    if(s.isEmpty){
      _serverEdited.port = 0;
    }
    print(s);
    _serverEdited.port = int.parse(s);
    _edited = true;
  }

  void _userChange(String s){
    _serverEdited.user = s;
    _edited = true;
  }

  void _passwordChange(String s){
    _serverEdited.password = s;
    _edited = true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Configurações"),
          centerTitle: true,
          backgroundColor: Colors.deepOrange,
        ),
        floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.save,color: Colors.white,),
        onPressed: () {
          if(_urlController.text.isNotEmpty &&
          _portController.text.isNotEmpty &&
          _userController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
              _serverEdited.port > 0){
            Navigator.pop(context,_serverEdited);
          }else{
            setState(() {
              error = "Preencha Todos os Campos!";
            });
          }
        },
      ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Divider(color: Colors.transparent),
              Text(error,
              style: TextStyle(fontSize: 15.0,color: Colors.red)),
              Divider(color: Colors.transparent),
              buildTextField("Url", _urlController,_urlChange,link: true),
              Divider(color: Colors.transparent),
              buildTextField("Port", _portController,_portChange, number: true),
              Divider(color: Colors.transparent),
              buildTextField("User", _userController,_userChange),
              Divider(color: Colors.transparent),
              buildTextField("Password", _passwordController,_passwordChange,pass: true),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildTextField(String label, TextEditingController c, Function function,
      {bool number=false, bool link=false,bool pass=false}){
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      style: TextStyle(
          color: Colors.black,
          fontSize: 25.0
      ),
      onChanged: function,
      keyboardType: number
          ? TextInputType.numberWithOptions(signed: false,decimal: false)
          : link
          ? TextInputType.url
          : TextInputType.text,

    );
  }

  Future<bool> _requestPop(){
    if(_edited){
      showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Sair"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Continuar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }
      );
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }

}
