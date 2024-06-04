// Importar paquetes
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importar archivos
import 'LoginPage.dart';
import 'amigos.dart';
import 'api_constants.dart';
import 'peticiones.dart';
import 'register_page.dart';
import 'auth_service.dart';
import 'collection.dart';
import 'wishlist.dart';
import 'codigo_page.dart';
import 'colores_theme.dart';

void main() async {
  // Asegura que la inicialización de WidgetsFlutterBinding esté completa.
  // Asegura que todos los widgets estén inicializados antes de la ejecución de la aplicación.
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Inicializa flutter_easyloading para el indicador de carga
  EasyLoading.init();

  // Comprobación del estado de inicio de sesión
  bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  // Ejecuta la aplicación con el estado de inicio de sesión.
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  // Indica si el usuario ha iniciado sesión o no
  final bool isLoggedIn;

  // Constructor que recibe el parametro isLoggedIn
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 835),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        title: 'HotWheels App',
        theme: redBlackTheme,
        debugShowCheckedModeBanner: false,
        home: isLoggedIn ? MyHomePage() : LoginPage(),
        routes: {
          '/home': (context) => MyHomePage(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/collection': (context) => CollectionPage(),
          '/wishlist': (context) => WishlistPage(),
          '/codigo': (context) => CodigoPage(),
        },
      ),
    );
  }
}

// Página principal de la aplicación
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _establecimientoController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String username = "";
  int _selectedIndex = 0;
  List<dynamic> hotwheelsList = [];
  List<dynamic> wishlist = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    fetchHotWheels();
    fetchWishlist();
    getAmigosNumber();
  }

  // Se carga el nombre de usuario desde SharedPreferences y lo asigna al controlador _idController
  void _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "Invitado";
      // Asigna el nombre de usuario al controlador de ID
      _idController.text = username;
    });
  }

  Future<void> fetchHotWheels() async {
    try {
      var data = await HotWheelsService.getHotWheels();
      setState(() {
        hotwheelsList = data;
      });
    } catch (e) {
      print("Error fetching hotwheels: $e");
    }
  }

  Future<void> fetchWishlist() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? 'No Email Found';
      final response = await http
          .get(Uri.parse('${APIConstants.apiBaseUrl}/wishlist?email=$email'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          wishlist = data;
        });
      } else {
        print("Error fetching wishlist: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching wishlist: $e");
    }
  }

  @override
  void dispose() {
    // Limpiar el controlador cuando el widget se elimine del árbol de widgets
    _establecimientoController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void showLoadingDialog(BuildContext context, {bool show = true}) {
    if (show) {
      showDialog(
        context: context,
        barrierDismissible:
            false, // Impide que se cierre el diálogo al tocar fuera
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Cargando..."),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.of(context, rootNavigator: true)
          .pop(); // Cierra el diálogo de carga
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: Text('Cerrar Sesión'),
              onPressed: () {
                _logout(); // Llama al método de cierre de sesión
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    // Cierra el diálogo y redirige al usuario a la página de login
    Navigator.of(context).pop(); // Cierra el diálogo de alerta
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _showHotWheelDetails(BuildContext context, dynamic hotwheel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(hotwheel['nombre']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(hotwheel['image']),
              SizedBox(height: 20),
              Text('Año: ${hotwheel['anio']}'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        _showLoadingDialog(context);
                        // Llamar al servicio para añadir a la colección
                        await HotWheelsService.addToCollection(hotwheel['id']);
                        Navigator.of(context).pop(); // Cierra el loading dialog
                        Navigator.of(context).pop(); // Cierra el AlertDialog
                      },
                      child: Text('Añadir a Colección'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Cargando..."),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> getAmigosNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? 'No Email Found';
    final String apiUrl =
        '${APIConstants.apiBaseUrl}${APIConstants.getUserNumber}$email';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('Error al obtener el número de empleados');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = ScreenUtil().screenHeight;
    double screenWidth = ScreenUtil().screenWidth;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(
              math.pi), // Rotar 180 grados (pi radianes) horizontalmente
          child: IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ),
        title: Row(
          children: [
            Text('HotWheels App'),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.task_alt),
                onPressed: () {
                  // Abre la página de peticiones utilizando Navigator.pushReplacement
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PeticionesPage()),
                  );
                },
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: FutureBuilder(
                    future:
                        getAmigosNumber(), // Aquí llamas al endpoint para obtener el número
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error',
                          style: TextStyle(color: Colors.white),
                        );
                      } else {
                        // Aquí manejas el número devuelto por el endpoint
                        int? numberOfRequest = snapshot.data?['numero'] as int?;
                        return Text(
                          '$numberOfRequest',
                          style: TextStyle(color: Colors.white),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.supervised_user_circle),
            onPressed: () {
              // Agrega aquí la acción que deseas realizar al presionar el icono supervised_user_circle
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AmigosPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CodigoPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Form(
          key:
              _formKey, // Asegúrate de que el Form está envolviendo los TextFormField
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Bienvenido $username', // Muestra el nombre del usuario
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.05),
              Expanded(
                child: ListView.builder(
                  itemCount: hotwheelsList.length,
                  itemBuilder: (context, index) {
                    var hotwheel = hotwheelsList[index];
                    // Comprueba si el id del coche está en la wishlist
                    bool isInWishlist = wishlist
                        .any((element) => element['id'] == hotwheel['id']);
                    return ListTile(
                      title: Text(hotwheel['nombre']),
                      subtitle: Text('Año: ${hotwheel['anio']}'),
                      leading: Image.network(hotwheel['image']),
                      trailing: IconButton(
                        icon: isInWishlist
                            ? Icon(Icons.favorite)
                            : Icon(Icons.favorite_border),
                        onPressed: () async {
                          if (isInWishlist) {
                            // Eliminar de la wishlist si ya está en la wishlist
                            await HotWheelsService.removeFromWishlist(
                                hotwheel['id']);
                          } else {
                            // Agregar a la wishlist si no está en la wishlist
                            await HotWheelsService.addToWishlist(
                                hotwheel['id']);
                          }
                          await fetchWishlist(); // Actualizar la lista de deseos después de cambiar
                        },
                      ),
                      onTap: () => _showHotWheelDetails(context, hotwheel),
                    );
                  },
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HotWheels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Colección',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CollectionPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WishlistPage()),
      );
    }
  }
}
