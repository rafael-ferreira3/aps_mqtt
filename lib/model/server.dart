class Server{
  String url;
  String user;
  String password;
  int    port;
  String clienteID;
  bool   isConnected;




  @override
  String toString() {
    return "Url:$url,User:$user,Password:$password,Port:$port";
  }


}