import 'package:flutter/material.dart';

final ThemeData redBlackTheme = ThemeData(
  primarySwatch: Colors.red,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Color.fromARGB(255, 48, 48, 48),  // Fondo
  colorScheme: ColorScheme.light(
    primary: Colors.red[400]!,                              // Iconos y algunos text fields
    secondary: Color.fromARGB(255, 52, 56, 63),             // Negro
    surface: Color.fromARGB(255, 48, 48, 48),               // App Bar otras pestañas
    background: Color.fromARGB(255, 48, 48, 48),            //BottomNavigationBar
    error: Colors.red,                                      // Error
    onPrimary: Color.fromARGB(255, 37, 37, 37),             // App Bar MAIN
    onSecondary: Colors.red,                                // No Se
    onSurface: Colors.red[50]!,                            // Texto
    onBackground: const Color.fromARGB(255, 0, 0, 0),       // Detalles  (borde TextField)
    onError: Colors.white,                                  // Errores
  ),
  dialogBackgroundColor: Colors.red[300]!,                  // Rojo claro
);
