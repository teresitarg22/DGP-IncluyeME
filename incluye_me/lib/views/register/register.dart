import 'package:flutter/material.dart';
import 'student_register.dart';
import 'staff_register.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selección de Rol'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              // --------------------------
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlumnoRegistration(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(
                      double.infinity, 100), // Ajusta la altura como desees
                ),
                // --------------------------
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school), // Icono de estudiante.
                    SizedBox(width: 8),
                    Text(
                      'Estudiante',
                      style: TextStyle(fontSize: 24),
                    ), // Texto del botón
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              // --------------------------
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfesorRegistration(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(
                      double.infinity, 100), // Ajusta la altura como desees
                ),
                // --------------------------
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work), // Icono de estudiante.
                    SizedBox(width: 8), // Espacio entre el icono y el texto
                    Text(
                      'Personal',
                      style: TextStyle(fontSize: 24),
                    ), // Texto del botón
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
