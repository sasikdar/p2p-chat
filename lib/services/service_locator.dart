import 'package:flutter_nearby_connections_example/services/P2PService.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter_nearby_connections_example/services/LocalStorageService.dart';


final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  getIt.registerSingleton<Storage>(Storage());
}


