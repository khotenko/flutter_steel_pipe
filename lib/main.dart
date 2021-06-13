import 'package:flutter/material.dart';
import 'price_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(), //or create your own lightTheme
      darkTheme: ThemeData.dark(), //or create your own darkTheme
      // themeMode:
      // ThemeMode.system, //this should be enough for most updated devices
      // theme: ThemeData.dark().copyWith(
      //     primaryColor: Colors.lightBlue,
      //     scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: PriceScreen(),
    );
  }
}
