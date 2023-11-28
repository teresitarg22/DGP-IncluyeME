import 'package:flutter/material.dart';
import 'package:incluye_me/views/task_view.dart';
import '../controllers/session_controller.dart';
import '../controllers/task_controller.dart';
import '../components/bottom_navigation_bar.dart';
import 'pedir_material.dart';
import '../views/add_general_task.dart';
import '../model/general_task.dart';

// --------------------------------------------
// Clase para la página de lista de usuarios
class TaskListPage extends StatefulWidget {
  final String userName;
  final String userSurname;

  const TaskListPage(
      {super.key, required this.userName, required this.userSurname});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

// ------------------------------------------------------------------

class _TaskListPageState extends State<TaskListPage> {
  bool isAdmin = false;
  var tareas = [];
  var material = [];
  String tipo = ""; // Variable para almacenar el tipo de tarea
  bool asignada = false; // Variable para almacenar si la tarea está asignada
  bool mostrarBoton = false;

  Controller controlador = Controller();

  SessionController sessionController = SessionController();
  //-------------------------------
  List<Tarea> tasks = []; // Lista de tareas

  void _addTask(Tarea tarea) {
    setState(() {
      tasks.add(tarea);
    });
  }

  // -----------------------------
  void userLogout() async {
    await sessionController.logout();
    Navigator.of(context).pushReplacementNamed('/');
  }

  // -----------------------------
  @override
  void initState() {
    super.initState();
    initializeData();
    mostrarBoton = false;
  }

  // -----------------------------
  Future<void> initializeData() async {
    await loadTaskIds();
    await initializeAdminStatus();
  }

  // -----------------------------
  Future<void> loadTaskIds() async {
    tareas = await controlador.listaTareas();
    //material = await controlador.listaTareasMaterial();
  }

  // -----------------------------
  Future<void> initializeAdminStatus() async {
    bool adminStatus =
        await controlador.esAdmin(widget.userName, widget.userSurname);
    setState(() => isAdmin = adminStatus);
  }

  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return isAdmin ? buildAdminUI() : buildNonAdminUI();
  }

  // ---------------------------------------------------------
  // Lógica para construir la interfaz de administrador.
  Widget buildAdminUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              // Abre un cuadro de diálogo para la búsqueda.
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String query =
                      ''; // Variable para almacenar la consulta de búsqueda.

                  return AlertDialog(
                    title: const Text('Buscar por Nombre'),
                    content: TextField(
                      onChanged: (text) {
                        query =
                            text; // Almacena la consulta a medida que se escribe.
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Cierra el cuadro de diálogo y realiza la búsqueda
                          // Navigator.of(context).pop();
                          // // Lógica de búsqueda con "query".
                          // var searchResults = tareas.where((user) {
                          //   final estudianteNombre =
                          //       user['estudiante']?['nombre']?.toLowerCase() ??
                          //           '';
                          //   final personalNombre =
                          //       user['personal']?['nombre']?.toLowerCase() ??
                          //           '';

                          //   return estudianteNombre
                          //           .contains(query.toLowerCase()) ||
                          //       personalNombre.contains(query.toLowerCase());
                          // }).toList();

                          // // Filtra la lista de usuarios según "query".
                          // setState(() {
                          //   // Actualiza la lista de usuarios para mostrar los resultados de la búsqueda.
                          //   tareas.clear();
                          //   tareas.addAll(searchResults
                          //       .cast<Map<String, Map<String, dynamic>>>());
                          // });
                        },
                        child: const Text('Buscar'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.search), // Icono de lupa.
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (BuildContext context, int index) {
                      controlador
                          .tipoTarea(tareas[index]['tarea']['id'])
                          .then((resultado) {
                        tipo = resultado;
                      });
                      // controlador
                      //     .esTareaAsignada(tareas[index]['tarea']['id'])
                      //     .then((resultado) {
                      //   asignada = resultado;
                      // });
                      return InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return TaskDetailsPage(
                              taskID: tareas[index]['id'],
                              tipo: tipo,
                              userName: widget.userName,
                              userSurname: widget.userSurname,
                            );
                          }));
                        },
                        // ---------------------------------------
                        child: Card(
                          color: tipo == "material"
                              ? const Color.fromARGB(255, 223, 205, 255)
                              : tipo == "general"
                                  ? Colors.blue[100]
                                  : Colors.green[100],
                          margin: const EdgeInsets.only(
                              top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                          child: ListTile(
                            title: GestureDetector(
                              // ----------------------
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    "${tareas[index]?['tarea']?['nombre']}",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 76, 76, 76),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            // -----------------------
                            subtitle: Text(tipo),
                            leading: const Icon(
                              Icons.task_rounded,
                              size: 45,
                            ),
                            // -----------------------
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    tareas[index]['tarea']['completada'] == true
                                        ? "Completada"
                                        : asignada
                                            ? "Asignada"
                                            : "No asignada"),
                                // ------------------------------------
                                IconButton(
                                  icon: const Icon(Icons.people_alt_rounded,
                                      color: Color.fromARGB(255, 76, 76, 76)),
                                  onPressed: () {
                                    // Nos dirigimos a la interfaz de edición:
                                  },
                                ),
                                // -----------------
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color.fromARGB(255, 76, 76, 76)),
                                  onPressed: () {
                                    // Nos dirigimos a la interfaz de edición:
                                  },
                                ),
                                // -----------------
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Color.fromARGB(255, 76, 76, 76)),
                                    onPressed: () async {
                                      // Mostrar un diálogo de confirmación
                                      bool confirmar = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Confirmar Eliminación'),
                                            content: const Text(
                                                '¿Seguro que quiere eliminar la tarea?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Sí'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      true); // Confirma la eliminación
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('No'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      false); // Cancela la eliminación
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmar) {
                                        // Actualización en la base de datos:
                                        controlador.eliminarTarea(
                                            tareas[index]['tarea']['id']);

                                        // Actualizar la vista:
                                        setState(() {
                                          tareas.removeAt(index);
                                        });
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // ---------------------------------------------------------------------
                Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 0,
                      child: Container(
                        margin: const EdgeInsets.only(top: 16.0, bottom: 30.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                          onSelected: (String value) {
                            if (value == 'PedirMaterial') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PedirMaterial(
                                      userName: widget.userName,
                                      userSurname: widget.userSurname),
                                ),
                              );
                            } else if (value == 'TareaGeneral') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddTaskView(onAddTask: _addTask),
                                ),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'PedirMaterial',
                                child: Row(
                                  children: [
                                    Icon(Icons.inventory),
                                    SizedBox(width: 8.0),
                                    Text('Petición de materiales'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'TareaGeneral',
                                child: Row(
                                  children: [
                                    Icon(Icons.assignment),
                                    SizedBox(width: 8.0),
                                    Text('Tarea General'),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
          userName: widget.userName, userSurname: widget.userSurname),
    );
  }

  // -------------------------------------------------------------------------
  // Lógica para construir la interfaz no administrador
  Widget buildNonAdminUI() {
    //var tareas = material;
    tipo = "material";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              // Abre un cuadro de diálogo para la búsqueda.
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String query =
                      ''; // Variable para almacenar la consulta de búsqueda.

                  return AlertDialog(
                    title: const Text('Buscar por Nombre'),
                    content: TextField(
                      onChanged: (text) {
                        query =
                            text; // Almacena la consulta a medida que se escribe.
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Cierra el cuadro de diálogo y realiza la búsqueda.
                          // Navigator.of(context).pop();
                          // // Lógica de búsqueda con "query".
                          // var searchResults = estudiantes
                          //     .where((user) =>
                          //         user['nombre'] != null &&
                          //         user['nombre']
                          //             .toLowerCase()
                          //             .contains(query.toLowerCase()))
                          //     .toList();
                          // // Filtra la lista de usuarios según "query".
                          // setState(() {
                          //   // Actualiza la lista de usuarios para mostrar los resultados de la búsqueda.
                          //   tareas.clear();
                          //   tareas.addAll(searchResults
                          //       .cast<Map<String, Map<String, dynamic>>>());
                          // });
                        },
                        child: const Text('Buscar'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.search), // Icono de lupa
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return TaskDetailsPage(
                              taskID: tareas[index][tipo]['id'],
                              tipo: tipo,
                              userName: widget.userName,
                              userSurname: widget.userSurname,
                            );
                          }));
                        },
                        child: Card(
                          color: Color.fromARGB(255, 223, 205, 255),
                          margin: const EdgeInsets.only(
                              top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                          child: ListTile(
                            title: GestureDetector(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "${tareas[index]?['tarea']?['nombre']}",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 76, 76, 76),
                                      fontSize:
                                          18, // Tamaño de fuente más grande.
                                      fontWeight:
                                          FontWeight.bold, // Texto en negrita.
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                            subtitle: Text(tipo),
                            leading: const Icon(
                              Icons.person,
                              size: 45,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    tareas[index]['tarea']['completada'] == true
                                        ? "Completada"
                                        : asignada
                                            ? "Asignada"
                                            : "No asignada"),
                                // ------------------------------------
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color.fromARGB(255, 76, 76, 76)),
                                  onPressed: () {
                                    // Nos dirigimos a la interfaz de edición de usuario:
                                  },
                                ),
                                // -----------------
                                const SizedBox(width: 30.0),
                                // -----------------
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Color.fromARGB(255, 76, 76, 76)),
                                    onPressed: () async {
                                      // Hacer la función asíncrona

                                      // Mostrar un diálogo de confirmación
                                      bool confirmar = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Confirmar Eliminación'),
                                            content: const Text(
                                                '¿Seguro que quiere eliminar la tarea?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Sí'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      true); // Confirma la eliminación
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('No'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      false); // Cancela la eliminación
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmar) {
                                        // Realizar la actualización en la base de datos
                                        controlador.eliminarTarea(
                                            tareas[index]['tarea']['id']);

                                        //Actualizar la vista
                                        setState(() {
                                          // Aquí puedes realizar las actualizaciones necesarias para refrescar la página.
                                          // Por ejemplo, podrías eliminar el usuario de la lista de usuarios filtrados:
                                          tareas.removeAt(index);
                                        });
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16.0, bottom: 30.0),
                  child: ElevatedButton(
                    // --------------------------
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PedirMaterial(
                                userName: widget.userName,
                                userSurname: widget.userSurname),
                          ));
                    },
                    // --------------------------
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                    ),
                    // --------------------------
                    child: const Row(
                      // Usamos un Row para colocar el icono y el texto horizontalmente.
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8.0),
                        Text('Nueva Tarea Reparto Material',
                            style:
                                TextStyle(fontSize: 16)), // El texto del botón.
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
          userName: widget.userName, userSurname: widget.userSurname),
    );
  }
}
