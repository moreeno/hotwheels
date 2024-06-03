import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'api_constants.dart';
import 'auth_service.dart';
import 'collection_friend.dart';
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
      _friendsFuture = _getFriends();
    
  }

  Future<List<Map<String, dynamic>>> _getFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? 'No Email Found';
    final response = await http.get(
      Uri.parse(
          '${APIConstants.apiBaseUrl}${APIConstants.getUserFriendsEndpoint}$email'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success']) {
        return List<Map<String, dynamic>>.from(
          data['friends'].map((friend) => {
            'usuario': friend['usuario'],
            'email': friend['email'],
          }),
        );
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Error: No se pudo conectar al servidor');
    }
  }

  void _showFriendCollection(String friendEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CollectionFriendPage(friendEmail: friendEmail)),
    );
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
            } else if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data!.isEmpty) {
                return Text('No se encontraron amigos');
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> friend = snapshot.data![index];
                  return ListTile(
                    title: Text(friend['usuario']),
                    subtitle: Text(friend['email']),
                    trailing: IconButton(
                      icon: Icon(Icons.collections),
                      onPressed: () {
                        _showFriendCollection(friend['email']);
                      },
                    ),
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