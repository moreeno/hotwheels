import 'package:flutter/material.dart';
import 'package:hotwheels/collection.dart';

import 'auth_service.dart';
import 'main.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<dynamic> wishlist = [];
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    try {
      var data = await HotWheelsService.getWishlist();
      setState(() {
        wishlist = data;
      });
    } catch (e) {
      print("Error fetching wishlist: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: wishlist.isEmpty
          ? Center(
              child: Text('No hay coches en tu wishlist'),
            )
          : ListView.builder(
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                var hotwheel = wishlist[index];
                return ListTile(
                  title: Text(hotwheel['nombre']),
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
            label: 'Colección', // Cambia el texto según prefieras
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
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CollectionPage()),
      );
    }
    // Si el índice es 0 (Inicio), simplemente actualiza el estado del índice seleccionado
    setState(() {
      _selectedIndex = index;
    });
  }
}
