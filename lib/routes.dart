import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Screens/deviceListScreen.dart';
import 'main.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    //case '/':
      //return MaterialPageRoute(builder: (_) => Home());
    case 'browser':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen());
    case 'advertiser':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
                child: Text('No route defined for ${settings.name}')),
          ));
  }
}
