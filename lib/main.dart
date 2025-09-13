import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart'; 
import 'providers/todo_provider.dart'; 
import 'screens/home_screen.dart'; 
 
void main() { 
  runApp( 
    ChangeNotifierProvider( 
      create: (_) => TodoProvider()..loadTodos(), 
      child: const MyApp(), 
    ), 
  ); 
} 
 
class MyApp extends StatelessWidget { 
  const MyApp({super.key}); 
  @override 
  Widget build(BuildContext context) { 
    return MaterialApp(
      title: 'Todo List App',
      locale: const Locale('th', 'TH'), // เพิ่มการรองรับภาษาไทย
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFB5C7E3), // Pastel Blue
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFB5C7E3),
          foregroundColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB5C7E3),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    ); 
  } 
} 