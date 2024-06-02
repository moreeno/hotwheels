// Importar paquetes
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importar archivos
import 'auth_service.dart';

// Clase StatefulWidget llamada LoginPage.
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para el formulario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Función inicio de sesión al darle al botón Iniciar Sesión
  void _login() async {
    if (_formKey.currentState!.validate()) {
      // Inicia sesión llamando a la función de inicio de sesión
      // del servicio de autenticación.
      bool result = await AuthService.login(
          _emailController.text, _passwordController.text);
      EasyLoading.dismiss();
      if (result) {
        // Guardamos el email en SharedPreferences
        _saveEmail(_emailController.text);
        // Redirige a la página principal
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Si el inicio de sesión falla, muestra un diálogo de error.
        _showErrorDialog();
      }
    }
  }

  // Función para mostrar un diálogo de error.
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Correo electrónico o contraseña incorrectos."),
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                // Seierra el diálogo de error.
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  // Método para guardar el email en SharedPreferences
  Future<void> _saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  void _goToRegisterPage() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar sesión')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Correo electrónico'),
                validator: (value) => value!.isEmpty
                    ? 'Por favor ingrese su correo electrónico'
                    : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingrese su contraseña' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Iniciar sesión'),
              ),
              SizedBox(height: 10), // Añade espacio entre los botones
              TextButton(
                onPressed:
                    _goToRegisterPage, // Llama a la función para ir a la página de registro
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
