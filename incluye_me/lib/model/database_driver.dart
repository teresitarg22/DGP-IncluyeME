import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:incluye_me/model/general_task.dart';
// -------------------------------------------------------------------------

class DataBaseDriver {
  // ----------------------------------------------------
  final PostgreSQLConnection? connection = PostgreSQLConnection(
    'flora.db.elephantsql.com', // host de la base de datos
    5432, // puerto de la base de datos
    'srvvjedp', // nombre de la base de datos
    username: 'srvvjedp', // nombre de usuario de la base de datos
    password:
        'tuZz6S15UozErJ7aROYQFR3ZcThFJ9MZ', // contraseña del usuario de la base de datos;
  ); // ;

  // Constructor

  connect() async {
    if (connection?.isClosed == true) await connection?.open();
  }

  // ----------------------------------------------------
  close() {
    connection?.close();
  }

  // ----------------------------------------------------
  // Función para hacer una petición a la BD.
  Future<List<Map<String, Map<String, dynamic>>>> request(String query) async {
    List<Map<String, Map<String, dynamic>>> results = [];
    await connect();

    try {
      results = await connection!.mappedResultsQuery(query);
    } catch (e) {
      print('Error: $e');
    } finally {
      // No cerrar la conexión aquí
      print('Query executed');
    }

    return results;
  }

  Future<List<Map<String, Map<String, dynamic>>>> requestStructure(
      String table) async {
    return await request(
        "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '$table'");
  }

  // ----------------------------------------------------
  // Obtener tablas.
  Future<List<Map<String, Map<String, dynamic>>>> requestTables() async {
    return await request(
        "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE'");
  }

  Future<List<Map<String, Map<String, dynamic>>>> requestDataFromPersonal(
      String email) async {
    return await request(
        "SELECT nombre,apellidos,correo,foto,es_admin FROM personal WHERE correo = '$email'");
  }

  // ----------------------------------------------------
  // Verificar contraseña.
  Future<bool> verifyPassword(String email, String password) async {
    var result = await request(
        "SELECT contrasenia FROM personal WHERE correo = '$email'");
    if (result.isEmpty) {
      return false;
    }
    var passwd = result[0]['personal']?["contrasenia"];
    return passwd == password;
  }

  // ----------------------------------------------------
  // Registrar estudiante en la base de datos.
  Future<void> registrarEstudiante(
      String nombre,
      String apellidos,
      String? imagenesContrasenia,
      String? correo,
      String? contrasena,
      var imageHex,
      String tipoLetra,
      String mayMin,
      var selectedOptions,
      bool sabeLeer) async {
    await request(
        "INSERT INTO estudiante (nombre, apellidos, contrasenia_iconos, contrasenia, correo, foto, tipo_letra, maymin, formato, sabe_leer) VALUES ('$nombre', '$apellidos', '$imagenesContrasenia', '$contrasena', '$correo',  E'\\\\x$imageHex',  '$tipoLetra', '$mayMin', '$selectedOptions', '$sabeLeer')");
  }

  // ----------------------------------------------------
  //Registrar profesor en la base de datos
  Future<void> registrarProfesor(String nombre, String apellidos, String correo,
      var contrasena, var foto, bool esAdmin) async {
    await request(
        "INSERT INTO personal (nombre, apellidos, contrasenia, correo, foto, es_admin) VALUES ('$nombre', '$apellidos', '$contrasena', '$correo', '$foto', '$esAdmin')");
  }

  // ----------------------------------------------------
  // Comprobar si estudiante ya existe por nombre y apellidos
  Future<List<Map<String, Map<String, dynamic>>>> comprobarEstudiante(
      String nombre, String apellidos) async {
    return await request(
        "SELECT * FROM estudiante WHERE nombre = '$nombre' AND apellidos = '$apellidos'");
  }

  // ----------------------------------------------------
  // Comprobar si existe personal por nombre y apellidos (profesor o administrador)
  Future<List<Map<String, Map<String, dynamic>>>> comprobarPersonal(
      String nombre, String apellidos) async {
    return await request(
        "SELECT * FROM personal WHERE nombre = '$nombre' AND apellidos = '$apellidos'");
  }

  // ----------------------------------------------------
  // Comprobar si existe personal por correo
  Future<List<Map<String, Map<String, dynamic>>>> comprobarPersonalCorreo(
      String correo) async {
    return await request("SELECT * FROM personal WHERE correo = '$correo'");
  }

  // ----------------------------------------------------
  // Comprobar si un aula ya existe por su nombre.
  Future<List<Map<String, Map<String, dynamic>>>> comprobarAula(
      String nombre) async {
    return await request("SELECT * FROM aula WHERE nombre = '$nombre'");
  }

  // ----------------------------------------------------
  // Insertar Aula.
  Future<void> insertarAula(String nombre) async {
    await request("INSERT INTO aula (nombre) VALUES ('$nombre')");
  }

  // ----------------------------------------------------
  // Insertar en la tabla imparte_en el nombre y apeliidos  del profesor y el nombre del aula
  Future<void> insertarImparteEn(
      String nombre, String apellidos, String aula) async {
    await request(
        " INSERT INTO imparte_en (nombre_aula, nombre_personal, apellidos_personal) VALUES ('$aula', '$nombre', '$apellidos')");
  }

  // ----------------------------------------------------
  Future<List<Map<String, Map<String, dynamic>>>> Login(
      String email, String password) async {
    return await request(
        "SELECT * FROM personal WHERE correo = '$email' AND contrasenia = '$password'");
  }

  // ----------------------------------------------------
  //Funcion para sacar lista de estudiantes.
  Future<List<Map<String, Map<String, dynamic>>>> listaEstudiantes() async {
    return await request("SELECT * FROM estudiante");
  }

  // ----------------------------------------------------
  // Funcion para sacar lista de personal.
  Future<List<Map<String, Map<String, dynamic>>>> listaPersonal() async {
    return await request("SELECT * FROM personal");
  }

  // ----------------------------------------------------
  // Funcion para sacar lista de aulas.
  Future<List<Map<String, Map<String, dynamic>>>> listaAulas() async {
    return await request("SELECT * FROM aula");
  }

  // ----------------------------------------------------
  // Funcion para sacar foto del aula.
  Future<List<Map<String, Map<String, dynamic>>>> fotoAula(String aula) async {
    return await request(
        "SELECT * FROM personal, imparte_en WHERE personal.nombre = imparte_en.nombre_personal AND personal.apellidos = imparte_en.apellidos_personal AND imparte_en.nombre_aula='$aula'");
  }

  // ----------------------------------------------------
  // Funcion para elimiar estudiante.
  Future<void> eliminarEstudiante(String nombre, String apellidos) async {
    await request(
        "DELETE FROM estudiante WHERE nombre = '$nombre' AND apellidos = '$apellidos'");
  }

  // ----------------------------------------------------
  // Función para mostrar las tareas de comanda
  Future<List<Map<String, Map<String, dynamic>>>> listaTareasComanda() async {
    return await request("SELECT * FROM comanda");
  }

  // ----------------------------------------------------
  // Función para mostrar las tareas generales
  Future<List<Map<String, Map<String, dynamic>>>> listaTareasGenerales() async {
    return await request("SELECT * FROM tareas_generales");
  }

  // ----------------------------------------------------
  // Función para mostrar las tareas de material
  Future<List<Map<String, Map<String, dynamic>>>> listaTareasMaterial() async {
    return await request("SELECT * FROM material");
  }

  // ----------------------------------------------------
  // Función para eliminar una tarea
  Future<void> eliminarTarea(int id) async {
    await request("DELETE FROM tarea WHERE id = $id");
  }

  // ----------------------------------------------------
  // Funicón para saber el tipo de tarea
  Future<List<Map<String, Map<String, dynamic>>>> esTareaGeneral(int id) async {
    return await request("SELECT * FROM tareas_generales WHERE id = $id");
  }

  // ----------------------------------------------------
  // Función para saber el tipo de tarea
  Future<List<Map<String, Map<String, dynamic>>>> esTareaMaterial(
      int id) async {
    return await request("SELECT * FROM material WHERE id = $id ");
  }

  // ----------------------------------------------------
  // Función para saber el tipo de tarea
  Future<List<Map<String, Map<String, dynamic>>>> esTareaComanda(int id) async {
    return await request("SELECT * FROM comanda WHERE id = $id ");
  }

  // ----------------------------------------------------
  // Función para mostrar todas las tareas
  Future<List<Map<String, Map<String, dynamic>>>> listaTareas() async {
    return await request("SELECT * FROM tarea");
  }

  // ----------------------------------------------------
  // Función para obtener una tarea general
  Future<List<Map<String, Map<String, dynamic>>>> getTareaGeneral(
      int id) async {
    return await request("SELECT * FROM tareas_generales WHERE id = $id");
  }

  // ----------------------------------------------------
  // Función para obtener una tarea material
  Future<List<Map<String, Map<String, dynamic>>>> getTareaMaterial(
      int id) async {
    return await request("SELECT * FROM material WHERE id = $id");
  }

  // ----------------------------------------------------
  // Función para obtener una tarea comanda
  Future<List<Map<String, Map<String, dynamic>>>> getTareaComanda(
      int id) async {
    return await request("SELECT * FROM comanda WHERE id = $id");
  }

  // ----------------------------------------------------
  // Función para saber si una tarea está asignada
  Future<List<Map<String, Map<String, dynamic>>>> esTareaAsignada(
      int id) async {
    return await request("SELECT * FROM asignada WHERE id_tarea = $id");
  }

  // ----------------------------------------------------
  // Función para obtener la infmación de una tarea asignada
  Future<List<Map<String, Map<String, dynamic>>>> getTareaAsignada(
      int id) async {
    return await request("SELECT * FROM asignada WHERE id_tarea = $id");
  }
  // ----------------------------------------------------
  // Funcion para añadir a la tabla tarea el nombre de la tarea la fecha de entrega

  Future<int> insertarTarea(String nombre, DateTime fecha) async {
    final results = await request(
        "INSERT INTO tarea (nombre, fecha_tarea) VALUES ('$nombre', '$fecha') RETURNING id");

    var primeraFila = results.first ;
    var id = primeraFila['tarea']!['id'] ;
    return int.parse(id.toString());
  }
  // ----------------------------------------------------
  // Funcion para añadir a la tabla asignada el nombre de la tarea la fecha de entrega

  // ----------------------------------------------------
  // Funcion para añadir a la tabla asignada el nombre de la tarea la fecha de entrega

  Future<void> insertarAsginada(String nombre, int id, String apellidos) async {
    await request(
        "INSERT INTO asignada (nombre_alumno, apellido_alumno, id_tarea) VALUES ('$nombre', '$apellidos', '$id')");
  }

  // ----------------------------------------------------
  // Función para obtener una tarea
  Future<List<Map<String, Map<String, dynamic>>>> getTarea(int id) async {
    return await request("SELECT * FROM tarea WHERE id = $id");
  }

  // ----------------------------------------------------
  // Funcion para añadir a la tabla de tarea_general el id de la tarea y los indices de los pasos
  Future<void> insertarTareaGeneral(List<int> indicesPasos, String nombre, String propietario) async {
    // Convertir la lista de enteros en una cadena con el formato de arreglo de PostgreSQL
    String indicesPasosFormatted = '{' + indicesPasos.join(',') + '}';

    try {
      await request(
          "INSERT INTO tareas_generales (indices_pasos, nombre, propietario) VALUES ('$indicesPasosFormatted', '$nombre', '$propietario')"
      );
    } catch (e) {
      print('Error al insertar tarea general: $e');
      throw Exception('No se pudo insertar la tarea general');
    }
  }

  Future<int> insertarPaso(Paso paso) async {
    try {
      var result = await request(
          "INSERT INTO pasos (descripcion, propietario, imagen) VALUES ('${paso.descripcion}', '${paso.propietario}', '${paso.imagen}') RETURNING id"
      );

      // Verificar si el resultado no está vacío y tiene la estructura esperada
      if (result.isNotEmpty && result[0].containsKey('pasos') && result[0]['pasos']!.containsKey('id')) {
        return result[0]['pasos']!['id'];
      } else {
        print('Resultado inesperado: $result');
        throw Exception('No se pudo insertar el paso');
      }
    } catch (e) {
      print('Error al insertar paso: $e');
    throw Exception('No se pudo insertar el paso');
    }
  }

  // SELECT * FROM tu_tabla LIMIT 1;
  // ----------------------------------------------------
  // Función para obtener una tarea
  Future<List<Map<String, Map<String, dynamic>>>> getTareaGeneralLimit1() async {
    return await request("SELECT * FROM tareas_generales LIMIT 1");
  }

  // ----------------------------------------------------
  // Función para eliminar todas las filas de la tabla tareas_generales
  Future<void> deleteAllTareasGenerales() async {
    await request("DELETE FROM tareas_generales");
  }

  // ----------------------------------------------------
  // Función para obtener todas las tareas generales
  Future<List<Map<String, Map<String, dynamic>>>> getAllTareasGenerales() async {
    return await request("SELECT * FROM tareas_generales");
  }

  // Obtener paso por id
  Future<Paso> getPaso(int id) async {
    List<Map<String, Map<String, dynamic>>> data = await request("SELECT * FROM pasos WHERE id = $id");
    return Paso.fromJson(data);
  }

  // Insertar tarea en la tabla tarea (nombre, completada: true/false, fecha_tarea)
  Future<void> insertarTarea2(String nombre, bool completada, DateTime fecha) async {
    try {
      await request(
          "INSERT INTO tarea (nombre, completada, fecha_tarea) VALUES ('$nombre', '$completada', '$fecha')");
    }
    catch (e) {
      print('Error al insertar tarea general: $e');
      throw Exception('No se pudo insertar la tarea general');
    }
  }

}


