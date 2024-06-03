import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
    String email = prefs.getString('email') ??
        'No Email Found';
    var url = Uri.parse(
        '${APIConstants.apiBaseUrl}${APIConstants.getUserCodeEndpoint}$email');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['success']) {
          setState(() {
            _codigo = json['code']
                .toString();
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

  void _confirmSend() {
    // La lógica para enviar el código del amigo
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
              leading: Icon(Icons.keyboard, color: Theme.of(context).primaryColor),
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
                  SizedBox(
                      width:
                          20),
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
              leading: Icon(Icons.hourglass_empty, color: Theme.of(context).primaryColor),
              title: Text('3. Esperar a que tu amigo te acepte'),
            ),
         
          SizedBox(height: 20), 
          _isLoading
              ? CircularProgressIndicator()
              : Text('Tu código es: $_codigo',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
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
