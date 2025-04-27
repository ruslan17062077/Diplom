//ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

ThemeData themaDark = ThemeData(
  colorScheme: ColorScheme.dark(background: Color(0xFF202020)),
  scaffoldBackgroundColor: Color(0xFF202020),
  textTheme: ThemeData.dark().textTheme,
  appBarTheme: AppBarTheme(
    color: Color(0xFF202020),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontFamily: "Inter",
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Color(0xFF202020),
      textStyle: TextStyle(color: Colors.white),
      side: BorderSide(color: Colors.white),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      backgroundColor: MaterialStateProperty.all(Colors.white),
    ),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: Color(0xFF252525),
  ),
  listTileTheme: ListTileThemeData(
    textColor: Colors.white,
    iconColor: Colors.white,
    tileColor: Color(0xFF252525),
    titleTextStyle: TextStyle(color: Colors.black, fontFamily: "Intro"),
    
    
    style: ListTileStyle.drawer,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xff313131),
    hintStyle: TextStyle(color: Colors.white54),
    labelStyle: TextStyle(color: Colors.white),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: Colors.white, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: Colors.white, width: 2),
    ),
    iconColor: Colors.white,
  ),
  // Тема для карточек в тёмном режиме
  cardTheme: CardTheme(
    color: Color(0xFF313131), // Фон карточки
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shadowColor: Colors.black.withOpacity(0.5),
  ),
  iconTheme: IconThemeData(color: Colors.white),
  
  
);

const typeTheme = Typography.whiteMountainView;

ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.light(),
  scaffoldBackgroundColor: const Color.fromARGB(255, 198, 197, 197),
  textTheme: ThemeData.light().textTheme,
  appBarTheme: AppBarTheme(
    color:  const Color.fromARGB(255, 213, 209, 209),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontFamily: "Inter",
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Color(0xFF202020),
      textStyle: TextStyle(color: Colors.white),
      side: BorderSide(color: Colors.black),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.black),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      overlayColor: MaterialStateProperty.all(Colors.white),
    ),
  ),
  listTileTheme: ListTileThemeData(
    textColor: Colors.black,
    iconColor: Colors.black,
    tileColor: Colors.white,
    titleTextStyle: TextStyle(color: Colors.black, fontFamily: "Intro"),
    style: ListTileStyle.drawer,
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.white,
    filled: true,
    hintStyle: TextStyle(color: Colors.black54),
    labelStyle: TextStyle(color: Colors.black),
    floatingLabelStyle: TextStyle(color: Colors.black),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: Colors.black, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: Colors.black, width: 2),
    ),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: TextStyle(color: Colors.black),
  ),
  // Тема для карточек в светлом режиме
  cardTheme: CardTheme(
    color: Colors.white, // Фон карточки
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shadowColor: Colors.black54,
  ),
  iconTheme: IconThemeData(color: Colors.black),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor:  const Color.fromARGB(255, 213, 209, 209),),
  navigationBarTheme: NavigationBarThemeData(backgroundColor:  const Color.fromARGB(255, 213, 209, 209))
);

const typeThemelight = Typography.whiteMountainView;
