import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'api_constants.dart';
import 'main.dart';

class AmigosPage extends StatefulWidget {
  @override
  _AmigosPageState createState() => _AmigosPageState();
}

class _AmigosPageState extends State<AmigosPage> {
  late Future<List<Map<String, dynamic>>> _friendsFuture;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _getUserEmail().then((email) {
      setState(() {
        userEmail = email;
      });
      _friendsFuture = _getFriends();
    });
  }

  Future<String?> _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<List<Map<String, dynamic>>> _getFriends() async {
    final response = await http.get(
      Uri.parse(
          '${APIConstants.apiBaseUrl}${APIConstants.getUserRequests}?email=$userEmail'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success']) {
        // Filtrar amigos que están validados
        return List<Map<String, dynamic>>.from(
          data['usuarios'].where((user) => user['is_validated'] == true),
        );
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Error: No se pudo conectar al servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amigos'),
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _friendsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Text('No se encontraron amigos');
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> friend = snapshot.data![index];
                  return ListTile(
                    title: Text(friend['nombre']),
                    subtitle: Text(friend['email']),
                  );
                },
              );
            } else {
              return Text('No se encontraron amigos');
            }
          },
        ),
      ),
    );
  }
}
