import 'dart:async';
import 'package:flutter_nearby_connections_example/services/LocalStorageService.dart';
import 'package:flutter_nearby_connections_example/routes.dart';
import 'package:flutter_nearby_connections_example/services/P2PService.dart';
import 'package:flutter_nearby_connections_example/services/service_locator.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'Screens/privateChatScreen.dart';
import 'models/messageModel.dart';
import 'package:get_it/get_it.dart';

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

/*class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'browser');
              },
              child: Container(
                color: Colors.red,
                child: Center(
                    child: Text(
                  'BROWSER',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                )),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'advertiser');
              },
              child: Container(
                color: Colors.green,
                child: Center(
                    child: Text(
                  'ADVERTISER',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/
