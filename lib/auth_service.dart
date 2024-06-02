import 'dart:convert';
import 'package:hotwheels/collection.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Importar archivos
import 'api_constants.dart';

class AuthService {
  // Método estático para iniciar sesión.
  static Future<bool> login(String email, String password) async {
    try {
      // Intenta realizar la solicitud de inicio de sesión.
      var response = await http.post(
        Uri.parse('${APIConstants.apiBaseUrl}${APIConstants.loginEndpoint}'),
        body: {'email': email, 'password': password},
      );
      // Verifica si la solicitud fue exitosa
      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON recibida del servidor
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        // Verifica si el inicio de sesión fue exitoso
        if (data['success']) {
          // Se guardar el estado de inicio de sesión con SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          // Establece el estado de inicio de sesión como verdadero
          await prefs.setBool('is_logged_in', true);
          // Guardar el nombre del usuario obtenido del servidor
          await prefs.setString('username', data['usuario']);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  // Método estático para cerrar sesión
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Elimina la clave 'is_logged_in' para indicar que el usuario ha cerrado sesión
    await prefs.remove('is_logged_in');
  }
}

class HotWheelsService {
  static Future<List<dynamic>> getHotWheels() async {
    try {
      var response = await http.get(
        Uri.parse('${APIConstants.apiBaseUrl}${APIConstants.getAllHw}'),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('Error al obtener la lista de hotwheels');
      }
    } catch (e) {
      print('Error en getHotWheels: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getCollection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    final response = await http.get(
      Uri.parse(
          '${APIConstants.apiBaseUrl}${APIConstants.getCollection}$email'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load collection');
    }
  }

  static Future<List<dynamic>> getWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    final response = await http.get(
      Uri.parse('${APIConstants.apiBaseUrl}${APIConstants.getWishlist}$email'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

  static Future<void> addToWishlist(int hotwheelId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    final response = await http.post(
      Uri.parse('${APIConstants.apiBaseUrl}${APIConstants.addHwToWishlist}'),
      body: {'email': email, 'hotwheel_id': hotwheelId.toString()},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add to wishlist');
    }
  }

  static Future<void> addToCollection(int hotwheelId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    final response = await http.post(
      Uri.parse('${APIConstants.apiBaseUrl}${APIConstants.addHwToCollection}'),
      body: {'email': email, 'hotwheel_id': hotwheelId.toString()},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add to collection');
    }
  }

  static Future<bool> isInWishlist(int hotwheelId) async {
    // URL del endpoint para verificar si un HotWheel está en la wishlist
    String url =
        '${APIConstants.apiBaseUrl}${APIConstants.getUserCodeEndpoint}';

    try {
      // Obtener el correo electrónico del usuario de SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';

      // Realiza una solicitud HTTP al backend para verificar si el HotWheel está en la wishlist
      var response = await http.get(
        Uri.parse('$url/$email'),
      );

      // Verifica si la solicitud fue exitosa (código de respuesta 200)
      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        // Verifica si se encontró el código del usuario
        if (jsonData['success'] == true) {
          // Obtén el código del usuario
          int userCode = jsonData['code'];

          // Realiza una solicitud HTTP adicional para obtener la lista de HotWheels en la wishlist
          var wishlistResponse = await http.get(
            Uri.parse(
                '${APIConstants.apiBaseUrl}${APIConstants.getWishlist}$email'),
          );

          // Verifica si la solicitud fue exitosa
          if (wishlistResponse.statusCode == 200) {
            // Decodifica la respuesta JSON
            var wishlistData =
                json.decode(utf8.decode(wishlistResponse.bodyBytes));

            // Itera sobre la lista de HotWheels en la wishlist para verificar si el HotWheel está presente
            for (var item in wishlistData) {
              if (item['id'] == hotwheelId) {
                return true;
              }
            }

            // Si el HotWheel no está en la wishlist
            return false;
          } else {
            // Si la solicitud para obtener la lista de wishlist falla
            throw Exception('Error al obtener la lista de wishlist');
          }
        } else {
          // Si no se encontró el código del usuario
          throw Exception('Error: Usuario no encontrado');
        }
      } else {
        // Si la solicitud para obtener el código del usuario falla
        throw Exception('Error al obtener el código del usuario');
      }
    } catch (e) {
      // Captura cualquier error y lo imprime en la consola
      print('Error en la solicitud HTTP: $e');
      return false;
    }
  }

  static Future<void> removeFromCollection(int hotwheelId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';
      final response = await http.delete(
        Uri.parse(
            '${APIConstants.apiBaseUrl}${APIConstants.removeHwFromCollection}'),
        body: {
          'email': email,
          'hotwheel_id': hotwheelId.toString(),
        },
      );
    } catch (e) {
      print("Error removing hotwheel from collection: $e");
    }
  }

  static Future<void> removeFromWishlist(int hotwheelId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';
      final response = await http.post(
        Uri.parse(
            '${APIConstants.apiBaseUrl}${APIConstants.removeHwFromWishlist}'),
        body: {'email': email, 'hotwheel_id': hotwheelId.toString()},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to remove from wishlist');
      }
    } catch (e) {
      print("Error removing hotwheel from wishlist: $e");
    }
  }
}
