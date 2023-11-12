import 'package:flutter/material.dart';
//import 'package:inrix_hack/screens/home_page.dart';
import 'package:inrix_hack/screens/location_input.dart';
import 'package:inrix_hack/screens/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  ColorScheme colorScheme = ColorScheme.fromSeed(
    //brightness: Brightness.light,
    seedColor: Colors.green,
  );
  ColorScheme kDarkColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: Colors.green,
  );
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "Uber Gren",
      home: LocationInput(),
    );
  }
}
