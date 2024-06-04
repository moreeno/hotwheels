import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';

import 'api_constants.dart';
import 'collection.dart';
import 'main.dart';
import 'wishlist.dart';

class CodigoPage extends StatefulWidget {
  const CodigoPage({Key? key}) : super(key: key);

  @override
  _CodigoPageState createState() => _CodigoPageState();
}

class _CodigoPageState extends State<CodigoPage> {
  String _codigo = '';
  bool _isLoading = true;
  TextEditingController _codigoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserCode();
  }

  fetchUserCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? 'No Email Found';
    var url = Uri.parse(
        '${APIConstants.apiBaseUrl}${APIConstants.getUserCodeEndpoint}$email');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['success']) {
          setState(() {
            _codigo = json['code'].toString();
            _isLoading = false;
          });
        } else {
          setState(() {
            _codigo = 'Usuario no encontrado';
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load user code');
      }
    } catch (e) {
      setState(() {
        _codigo = 'Error fetching code: $e';
        _isLoading = false;
      });
    }
  }

  void _confirmSend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    String friendCode = _codigoController.text;

    if (friendCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingrese el código de su amigo')),
      );
      return;
    }

    var url =
        Uri.parse('${APIConstants.apiBaseUrl}/send-friend-request-by-code');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'email': email,
          'friend_code': friendCode,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Solicitud de amistad enviada')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${jsonResponse['message']}')),
          );
        }
      } else {
        throw Exception('Failed to send friend request');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tu Código'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            leading: Icon(Icons.vpn_key, color: Theme.of(context).primaryColor),
            title: Text('1. Conseguir el código de tu amigo'),
            subtitle: Text('Pide a tu amigo su código de referencia.'),
          ),
          ListTile(
            leading:
                Icon(Icons.keyboard, color: Theme.of(context).primaryColor),
            title: Text('2. Añadir el código de tu amigo abajo'),
            subtitle: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codigoController,
                    decoration: InputDecoration(
                      hintText: 'Ingresa el código aquí',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: _confirmSend,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color.fromRGBO(110, 105, 105, 1),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.498),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.hourglass_empty,
                color: Theme.of(context).primaryColor),
            title: Text('3. Esperar a que tu amigo te acepte'),
          ),
          SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : Text('Tu código es: $_codigo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _copyToClipboard,
                icon: Icon(Icons.content_copy),
              ),
              IconButton(
                onPressed: () {
                  Share.share(
                      '¡Hola! Éste es mi código de invitación para My HotWheels : $_codigo \nAñádelo en el apartado de "Código" y te agregaré \n\nDescárgate la aplicación para Android: https://play.google.com/ \n\nO para IOS: www.apple.com');
                },
                icon: Icon(Icons.share),
              ),
            ],
          ),
        ],
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
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _codigo));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Código copiado')));
  }

  void _onItemTapped(int index) {
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
