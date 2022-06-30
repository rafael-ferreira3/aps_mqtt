class StringToMap{

  static Map stringToMap(String s) {
    s = s.replaceAll("\"", "");
    s = s.replaceAll("{", "");
    s = s.replaceAll("}", "");
    List<String> lista = s.split(",");
    Map retorno = Map();
    for (String str in lista) {
      str = str.replaceFirst(":","@");
      List<String> aux = str.split("@");
      retorno[aux[0]] = aux[1];
    }
    return retorno;
  }
}