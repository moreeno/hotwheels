import 'package:flutter/material.dart';
import 'package:hotwheels/wishlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_constants.dart';
import 'auth_service.dart';
import 'main.dart';

class CollectionFriendPage extends StatefulWidget {
  final String friendEmail;

  const CollectionFriendPage({Key? key, required this.friendEmail}) : super(key: key);

  @override
  _CollectionFriendPageState createState() => _CollectionFriendPageState();
}

class _CollectionFriendPageState extends State<CollectionFriendPage> {
  List<dynamic> collectionList = [];
  Map<int, int> countMap = {};
  int _selectedIndex = 1;
  String friendName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCollection();
    fetchName();
  }

  Future<void> fetchCollection() async {
    try {
      final response = await http.get(
        Uri.parse('${APIConstants.apiBaseUrl}${APIConstants.getCollection}${widget.friendEmail}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          // Elimina los duplicados y conserva el recuento
          collectionList = _removeDuplicates(data);
          countMap = _calculateCountMap(data);
          isLoading = false;
        });
      } else {
        throw Exception('Error: No se pudo conectar al servidor');
      }
    } catch (e) {
      print("Error fetching friend collection: $e");
    }
  }

  Future<void> fetchName() async {
    try {
      final response = await http.get(
        Uri.parse('${APIConstants.apiBaseUrl}${APIConstants.getUserNameEndpoint}${widget.friendEmail}'),
      );
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['success']) {
          setState(() {
            friendName = json['usuario  '].toString();
          });
        } else {
          setState(() {
            friendName = 'Usuario no encontrado';
          });
        }
      } else {
        throw Exception('Failed to load user name');
      }
    } catch (e) {
      print("Error fetching friend name: $e");
    }
  }

  List<dynamic> _removeDuplicates(List<dynamic> list) {
    Map<int, dynamic> uniqueMap = {};
    for (var item in list) {
      int id = item['id'];
      if (!uniqueMap.containsKey(id)) {
        uniqueMap[id] = item;
      }
    }
    return uniqueMap.values.toList();
  }

  Map<int, int> _calculateCountMap(List<dynamic> list) {
    Map<int, int> map = {};
    for (var item in list) {
      int id = item['id'];
      map[id] = (map[id] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Colección de ${friendName.isEmpty ? widget.friendEmail : friendName}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : collectionList.isEmpty
              ? Center(
                  child: Text('No hay coches en la colección de ${friendName.isEmpty ? widget.friendEmail : friendName}'),
                )
              : ListView.builder(
                  itemCount: collectionList.length,
                  itemBuilder: (context, index) {
                    var hotwheel = collectionList[index];
                    int id = hotwheel['id'];
                    int count = countMap[id] ?? 0;
                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(hotwheel['nombre']),
                          ),
                          if (count > 1) Text('$count')
                        ],
                      ),
                      subtitle: Text('Año: ${hotwheel['anio']}'),
                      leading: Image.network(hotwheel['image']),
                    );
                  },
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
        currentIndex: _selectedIndex,
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
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WishlistPage()),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }
}
