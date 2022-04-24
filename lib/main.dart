import 'dart:async';
import 'package:flutter_nearby_connections_example/services/LocalStorageService.dart';
import 'package:flutter_nearby_connections_example/routes.dart';
import 'package:flutter_nearby_connections_example/services/service_locator.dart';
import 'package:flutter/material.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupGetIt();
  var storage = getIt<Storage>();
  await storage.init();
  runApp(MyApp());
}

/*
  *removed the content to route.dart, if there are problems replace this commented section with the code
  * from the routes.dart
 */
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: 'browser',
    );
  }
}

