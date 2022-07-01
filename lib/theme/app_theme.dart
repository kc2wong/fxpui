import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData light = _lightTheme;
  static ThemeData dark = _darkTheme;
}

ThemeData _lightTheme = ThemeData(
  primarySwatch: AppColor.primarySwatch,
  brightness: Brightness.light,
  backgroundColor: AppColor.bodyColor,
  disabledColor: Colors.grey.shade300,
  scaffoldBackgroundColor: AppColor.bodyColor,
  hintColor: AppColor.textColor,
  primaryColorLight: AppColor.buttonBackgroundColor,
  fontFamily: 'SegoeUI',
  textTheme: const TextTheme(
    headline1: TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold),
  ),
  buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary, buttonColor: Colors.black),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.all(AppColor.primarySwatch),
    checkColor: MaterialStateProperty.all(Colors.white),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    helperStyle: TextStyle(
      fontSize: 12,
    ),
  ),
  scrollbarTheme: ScrollbarThemeData(
    thumbVisibility: MaterialStateProperty.all(true),
    // isAlwaysShown: true,
  ),
);

ThemeData _darkTheme = ThemeData(
  primarySwatch: AppColor.primarySwatch,
  primaryColor: AppColor.primarySwatch,
  brightness: Brightness.dark,
  backgroundColor: AppColor.bodyColorDark,
  scaffoldBackgroundColor: AppColor.bodyColorDark,
  hintColor: AppColor.textColor,
  primaryColorLight: AppColor.buttonBackgroundColorDark,
  fontFamily: 'SegoeUI',
  textTheme: const TextTheme(
    headline1: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
  ),
  buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary, buttonColor: Colors.white),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.all(AppColor.primarySwatch),
    checkColor: MaterialStateProperty.all(Colors.black),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      side: MaterialStateProperty.resolveWith(
            (states) => BorderSide(color: states.contains(MaterialState.disabled) ? AppColor.textColor : Colors.white),
      ),
      backgroundColor: MaterialStateProperty.all(AppColor.buttonBackgroundColorDark),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.grey.shade900,
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
    helperStyle: const TextStyle(
      fontSize: 12,
    ),
  ),
);
