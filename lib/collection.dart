import 'package:flutter/material.dart';
import 'package:hotwheels/wishlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_constants.dart';
import 'auth_service.dart';
import 'main.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({Key? key}) : super(key: key);

  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<dynamic> collectionList = [];
  Map<int, int> countMap = {};
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchCollection();
  }

  Future<void> fetchCollection() async {
    try {
      var data = await HotWheelsService.getCollection();
      setState(() {
        // Elimina los duplicados y conserva el recuento
        collectionList = _removeDuplicates(data);
        countMap = _calculateCountMap(data);
      });
    } catch (e) {
      print("Error fetching collection: $e");
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
        title: Text('Colección'),
      ),
      body: collectionList.isEmpty
          ? Center(
              child: Text('No hay coches en tu colección'),
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
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _showConfirmationDialog(hotwheel['id']),
                  ),
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

  void _showConfirmationDialog(int hotwheelId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar coche de la colección'),
          content: Text(
              '¿Estás seguro de que quieres eliminar este coche de tu colección?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                HotWheelsService.removeFromCollection(
                    hotwheelId); // Llama a la función para eliminar el coche
                fetchCollection();
              },
            ),
          ],
        );
      },
    );
  }
}
