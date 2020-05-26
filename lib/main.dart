import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main () => runApp(UserListApp());

class UserListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('User List'),
        ),
        body: UserList(),
      ),
    );
  }
}

class User { //Se crea la clase User con sus atributos
  String fullname, username, photoUrl;
  User(this.fullname, this.username, this.photoUrl);
  User.fromJson(Map<String, dynamic> json) //constructor que permite darle un MAP y establece los datos deseados a utilizar
    : fullname = json['name']['first'] + ' ' + json['name']['last'],
     username = json['login']['username'],
     photoUrl = json['picture']['medium'];
}

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  bool loading;
  List <User> users; //Una lista de tipo User para utilizar sus atributos

  @override
  void initState() { 
    users = [];  //Se establecen los atributos fullname, username y photoUrl
    loading = true;
    _loadUsers();
    super.initState();
  }

  void _loadUsers() async { //Traer datos de la API randomusers.me
    final url = 'https://randomuser.me/api/?results=20'; //Se establece ls URL para hacer el metodo get
    final response = await http.get(url); //Guarda en response el arreglo obtenido de datos
    final json = jsonDecode(response.body); //se decodifica el String body del response en Json y se guarda en la variable
    List <User> _users = [];
    for (var jsonUser in json['results']) { //recorre todos los datos dentro del arreglo Results que devuelve la api y así recorre sus datos de los usuarios random
     _users.add(User.fromJson(jsonUser)); //inserta en la lista _users los datos desde el constructor de la clase User. 
    }
    setState(() {
      users = _users;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder( //Crea un vista de lista
      itemBuilder: (context, index) {
        return ListTile( //Establece el contenido de cada row
          title: Text(users[index].fullname), 
          subtitle: Text(users[index].username),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(users[index].photoUrl),
          ),
        );
      },
      itemCount: users.length, //establece la cantidad que existe de Usuarios, los cuenta y crea de acuerdo a cuantos existan en el arreglo con datos.
    );
  }
}