import 'package:flutter/material.dart';

void main () => runApp(ColorEditApp());

class ColorEditApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: { //establece las rutas nombradas
        '/': (context) => ColorScreen(), // ruta principal o "home" donde comenzará la app
        '/edit': (context) => EditColorScreen(),
      },
    );
  }
}

class ColorScreen extends StatefulWidget {
  @override
  _ColorScreenState createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  Color _color = Color.fromARGB(255, 255, 0, 0); //Inicializa el estado de color en RGB


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _color,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RaisedButton(
            child: Text('Cambiar Color'),
            onPressed: () {
              Navigator.of(context).pushNamed( //Redirige a la pantalla /edit
                '/edit', 
                arguments: _color, //toma los valores de la variable _colors y los envía para utilizarlos
              ).then((result) {
                if (result != null){
                  setState(() { //Establece el estado de la pantalla al recibir los datos editados de otra ruta
                    _color = result;
                  });
                }
              });
            },
          ),
        ),
      ),
    );
  }
}

class EditColorScreen extends StatefulWidget {
  @override
  _EditColorScreenState createState() => _EditColorScreenState();
}

class _EditColorScreenState extends State<EditColorScreen> {

  List<TextEditingController> _controllers;

  
  @override
  void didChangeDependencies() { //permite tomar los datos de variables luego del estado Init
    final Color color = ModalRoute.of(context).settings.arguments; //toma los valores (argumentos) que enviaron desde otra pantalla en el contexto de Navigator
    final List<String> canales = [
      color.red.toString(),
      color.green.toString(),
      color.blue.toString(),
    ];
     _controllers = [
        for (var i = 0; i < 3; i++) TextEditingController(text: canales[i]),
      ];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    
    const List<String> colores = ['red', 'green', 'blue'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Color'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Row(
              children: [
                for (int i = 0; i<3; i++) 
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _controllers[i],
                        decoration: InputDecoration(
                          labelText: colores[i],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            RaisedButton(
              child: Text('Guardar'),
              onPressed: () {
                final int r = int.parse(_controllers[0].text);
                final int g = int.parse(_controllers[1].text);
                final int b = int.parse(_controllers[2].text);
                Navigator.of(context).pop(Color.fromARGB(255, r, g, b));
              },
            ),
          ],
        ),
      ),
    );
  }
}