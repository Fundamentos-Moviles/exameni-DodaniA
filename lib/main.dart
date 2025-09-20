import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memorama',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Memorama'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int rows = 4;
  final int cols = 5;


  late List<Color> _colores;
  late List<Color> _pantalla;  // Almacena los colores de los cuadros
  late List<bool> _descubierto;  // Si la carta está descubierta o no
  late List<int> _abiertas;    // Cartas actualmente abiertas
  bool _bloquear = false;         // Para bloquear la selección mientras se comparan cartas

  @override
  void initState() {
    super.initState();
    _generarCuadros();
  }

  //colores para los cuadros
  void _generarCuadros() {
    final List<Color> palette = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.yellow, Colors.teal, Colors.deepOrange, Colors.pink, Colors.indigo
    ];
    _descubierto = [];
    _abiertas = [];
    _colores = [];
   _pantalla = [];

    // Duplicar los colores para formar los pares
    for (var i = 0; i < palette.length; i++) {
      _colores.add(palette[i]);
      _colores.add(palette[i]); // Duplicamos los colores
    }

    _colores.shuffle(Random());  // Mezclar los colores

    // Crear el dgv con los colores mezclados
    _pantalla = List.generate(rows * cols, (index) => _colores[index]);
    _descubierto = List.filled(rows * cols, false);
  }

  void _clickCuadro(int index) {
    if (_bloquear || _descubierto[index]) return;

    setState(() {
      _abiertas.add(index);
      _descubierto[index] = true;  // Revelar la carta
    });

    if (_abiertas.length == 2) {
      _bloquear = true;
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          if (_pantalla[_abiertas[0]] == _pantalla[_abiertas[1]]) {
            _abiertas.clear();
            _bloquear = false;
            if(_descubierto.every((carta) => carta)) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¡Felicidades!'),
                  content: const Text('Has ganado el juego.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        
                        setState(() {
                          _generarCuadros();
                        });
                      },
                      child: const Text('Reiniciar'),
                    ),
                  ],
                ),
              );
            }

          }else if (_pantalla[_abiertas[0]] != _pantalla[_abiertas[1]]) {
            // No son iguales, ocultar las cartas
            _descubierto[_abiertas[0]] = false;
            _descubierto[_abiertas[1]] = false;
          }
          _abiertas.clear();
          _bloquear = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Alex Dodani Martínez Pérez'
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: rows * cols,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _clickCuadro(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _descubierto[index]
                          ? _pantalla[index] 
                          : const Color.fromARGB(255, 0, 0, 0),  // Color inactivo
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _generarCuadros();
          });
        },
        hoverColor: Colors.purple,
        tooltip: 'Reiniciar',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
