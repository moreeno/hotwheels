import 'package:flutter/material.dart';

final ThemeData redBlackTheme = ThemeData(
  primarySwatch: Colors.red,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Color.fromARGB(255, 211, 211, 211), // Gris pastel
  colorScheme: ColorScheme.light(
    primary: Colors.red, // Rojo
    secondary: Colors.black, // Negro
    surface: Colors.red[400]!, // Rojo claro
    background: Colors.red[50]!, // Rojo claro
    error: Colors.red,
    onPrimary: Colors.red[400]!, // Detalles en negro
    onSecondary: Colors.red, // Detalles en rojo
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
  ),
  dialogBackgroundColor: Colors.red[100]!, // Rojo claro
);
