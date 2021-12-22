import 'package:get_it/get_it.dart';

import 'package:flutter_nearby_connections_example/LocalStorage.dart';


final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  //Storage storage=new Storage();

  getIt.registerSingleton<Storage>(Storage());
}
