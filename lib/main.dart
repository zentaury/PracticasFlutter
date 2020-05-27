import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(TodoListApp());

class Todo {
  String job;
  bool done;
  Todo(this.job) : done = false;
  Todo.fromJson(Map<String, dynamic> json)
      : job = json['job'],
        done = json['done'];

  void toggleDone() =>
      done = !done; //cambia el estado del booleano para el checkbox del job

  Map<String, dynamic> toJson() => {
        'job': job,
        'done': done,
      };
}

class TodoListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoListPage(),
      routes: {
        'addTodo': (context) =>
            NewTodoPage(), //ruta hacia la pantalla de agregar una tarea
      },
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({
    Key key,
  }) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> _todos; //Se crea una lista de la clase Todo

  int get _doneCount =>
      _todos.where((todo) => todo.done).length; //verifica si hay todos marcados

  @override
  void initState() {
    _readTodos();
    super.initState();
  }

  _readTodos() async {
    try{
    Directory dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/todos.json');
    List json = jsonDecode(await file.readAsString());
    List<Todo> todos = [];
    for (var item in json) {
      todos.add(Todo.fromJson(item));
    }
    super.setState(() {
      _todos = todos;
    });
    }catch(e) {
      setState(() => _todos = []);
    }
  }

  _buildList() {
    if (_todos == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder(
      itemCount: _todos
          .length, //establece la cantidad de rows de acuerdo a la cantidad de tareas existentes
      itemBuilder: (context, index) {
        //dibuja las rows
        return InkWell(
          //hace cicleable la row de la tarea
          onTap: () {
            setState(() {
              _todos[index]
                  .toggleDone(); // toma el estado del booleano y lo convierte a su contrario.
            });
          },
          child: ListTile(
            title: Text(
              _todos[index].job,
              style: TextStyle(
                decoration: (_todos[index].done
                    ? TextDecoration
                        .lineThrough //pregunta si done=true entonces tacha
                    : TextDecoration.none), //si esta false lo deja sin tachar
              ),
            ),
            leading: Checkbox(
              value: _todos[index].done,
              onChanged: (checked) {
                setState(() {
                  _todos[index].done = checked;
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void setState(fn) {
    super.setState(fn);
    _writeTodos();
  }

  _writeTodos() async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/todos.json');
      String jsonText = jsonEncode(_todos);
      print(jsonText);
      await file.writeAsString(jsonText);
    } catch (e) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Error al grabar el fichero de datos')));
    }
  }

  _removeChecked() {
    //elimina los marcados
    List<Todo> pending = [];
    for (var todo in _todos) {
      //recorre la lista de tareas
      if (!todo.done)
        pending.add(
            todo); //verifica los que no estan marcados y los agrega a la lista pending
    }
    setState(() {
      _todos =
          pending; //reemplaza la lista anterior por la que solo tiene descarmados
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeRemoveChecked() {
      //Verifica si hay marcados para borrar
      if (_doneCount == 0) {
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirmación'),
          content: Text('Seguro que quieres borrar todos los marcados ?'),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Cancelar')),
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Borrar')),
          ],
        ),
      ).then((borrar) {
        if (borrar) {
          _removeChecked();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('TodoList'),
        actions: [
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: _maybeRemoveChecked), //boton de borrar
        ],
      ),
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed('addTodo').then((job) {
            //redirige a la pantalla addTodo
            setState(() {
              _todos.add(Todo(
                  job)); //recibe la tarea de la pantalla addTodo y la agrega a la lista _todo
            });
          });
        },
      ),
    );
  }
}

class NewTodoPage extends StatefulWidget {
  @override
  _NewTodoPageState createState() => _NewTodoPageState();
}

class _NewTodoPageState extends State<NewTodoPage> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose(); //limpia el estado del cuadro de texto
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Todo...'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              onSubmitted: (job) {
                Navigator.of(context).pop(
                    job); //Toma el texto  y lo envía como parametro con ENTER
              },
            ),
            RaisedButton(
              child: Text('Agregar'),
              onPressed: () {
                Navigator.of(context).pop(_controller
                    .text); //toma el texto y lo envía como parametro con el boton agregar
              },
            ),
          ],
        ),
      ),
    );
  }
}
