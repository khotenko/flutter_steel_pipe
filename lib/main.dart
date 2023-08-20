import 'package:flutter/material.dart';
import 'pipe_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  final Map<int, Color> color = {
    50: const Color.fromRGBO(0, 0, 0, .1),
    100: const Color.fromRGBO(0, 0, 0, .2),
    200: const Color.fromRGBO(0, 0, 0, .3),
    300: const Color.fromRGBO(0, 0, 0, .4),
    400: const Color.fromRGBO(0, 0, 0, .5),
    500: const Color.fromRGBO(0, 0, 0, .6),
    600: const Color.fromRGBO(0, 0, 0, .7),
    700: const Color.fromRGBO(0, 0, 0, .8),
    800: const Color.fromRGBO(0, 0, 0, .9),
    900: const Color.fromRGBO(0, 0, 0, 1),
  };

  final Map<int, Color> colorWhite = {
    50: const Color.fromRGBO(255, 255, 255, .1),
    100: const Color.fromRGBO(255, 255, 255, .2),
    200: const Color.fromRGBO(255, 255, 255, .3),
    300: const Color.fromRGBO(255, 255, 255, .4),
    400: const Color.fromRGBO(255, 255, 255, .5),
    500: const Color.fromRGBO(255, 255, 255, .6),
    600: const Color.fromRGBO(255, 255, 255, .7),
    700: const Color.fromRGBO(255, 255, 255, .8),
    800: const Color.fromRGBO(255, 255, 255, .9),
    900: const Color.fromRGBO(255, 255, 255, 1),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          secondaryContainer: Colors.grey,
          primary: MaterialColor(0xFF000000, color),
          surface: MaterialColor(0xFFFFFFFF, colorWhite),
          surfaceVariant: MaterialColor(0xFFFFFFFF, colorWhite),
          onSurface: Colors.black,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: MaterialColor(0xFF000000, color),
        ),
        appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
              color: MaterialColor(0xFF000000, color),
            )),
        primarySwatch: MaterialColor(0xFF000000, color),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary:MaterialColor(0xFFFFFFFF, colorWhite),
          secondary:Colors.lightBlue,
          tertiary: Colors.lightBlue,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: MaterialColor(0xFFFFFFFF, colorWhite),
        ),
        appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
              color: MaterialColor(0xFFFFFFFF, colorWhite),
            )),
        primarySwatch: MaterialColor(0xFFFFFFFF, colorWhite),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: PriceScreen(),

    );
  }
}
