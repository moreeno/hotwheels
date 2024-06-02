import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_constants.dart';
import 'main.dart';

class PeticionesPage extends StatefulWidget {
  @override
  _PeticionesPageState createState() => _PeticionesPageState();
}

class _PeticionesPageState extends State<PeticionesPage> {
  late Future<List<Map<String, dynamic>>> _userRequestsFuture;

  @override
  void initState() {
    super.initState();
    _userRequestsFuture = _getUserRequests();
  }

  Future<List<Map<String, dynamic>>> _getUserRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? 'No Email Found';
    final response = await http.get(Uri.parse(
        '${APIConstants.apiBaseUrl}${APIConstants.getUserRequests}?email=$email'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success']) {
        List<Map<String, dynamic>> requests =
            List<Map<String, dynamic>>.from(data['usuarios'].map((user) => {
                  'id': user['id'],
                  'nombre': user['nombre'],
                  'isValidated': user['is_validated'] ?? false,
                }));
        return requests;
      } else {
        return Future.error('${data['message']}');
      }
    } else {
      throw Exception('Error: No se pudo conectar al servidor');
    }
  }

  Future<void> _acceptRequest(int friendCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? 'No Email Found';
    final response = await http.post(
      Uri.parse('${APIConstants.apiBaseUrl}${APIConstants.acceptRequest}'),
      body: {'email': email, 'friend_code': friendCode.toString()},
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success']) {
        print('Solicitud aceptada');
      } else {
        throw Exception('Error: ${data['message']}');
      }
    } else {
      throw Exception('Error: No se pudo conectar al servidor');
    }
  }

  Future<void> _rejectRequest(int friendCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? 'No Email Found';
    final response = await http.post(
      Uri.parse('${APIConstants.apiBaseUrl}${APIConstants.rejectRequest}'),
      body: {'email': email, 'friend_code': friendCode.toString()},
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success']) {
        print('Solicitud rechazada');
      } else {
        throw Exception('Error: ${data['message']}');
      }
    } else {
      throw Exception('Error: No se pudo conectar al servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peticiones'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navega de regreso a la página principal
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: _userRequestsFuture,
          builder:
              (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Text('Usuarios no encontrados');
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> request = snapshot.data![index];
                  return ListTile(
                    title: Text(request['nombre']),
                    subtitle: request['isValidated']
                        ? Text('Solicitud ya validada')
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: request['isValidated']
                              ? null
                              : () async {
                                  await _acceptRequest(request['id']);
                                  setState(() {
                                    _userRequestsFuture = _getUserRequests();
                                  });
                                },
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: request['isValidated']
                              ? null
                              : () async {
                                  await _rejectRequest(request['id']);
                                  setState(() {
                                    _userRequestsFuture = _getUserRequests();
                                  });
                                },
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Text('No se encontraron solicitudes');
            }
          },
        ),
      ),
    );
  }
}
