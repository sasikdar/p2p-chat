

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/LocalStorage.dart';
import 'package:flutter_nearby_connections_example/service_locator.dart';
import 'package:flutter_nearby_connections_example/userModel.dart';

Future<String> getUserfromdeviceID(String deviceID) async {
  //Storage storage=new Storage();

  var storage = getIt<Storage>();
  User? user=await storage.getUserwithdeviceID(deviceID);
  return user!.name;
}

class UsernamefromDeviceWidget extends StatelessWidget {
  const UsernamefromDeviceWidget({
    Key? key,
    required this.device,
  }) : super(key: key);

  final Device device;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:getUserfromdeviceID(device.deviceName),
        builder:(context, AsyncSnapshot<String> snapshot){
          if(snapshot.hasData)
          {
            return Text(snapshot.data!,
              style: TextStyle(
              fontSize: 10.0,
              color: Colors.black54,
            ),);
          }
          else
            return Text(device.deviceName,
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.black54,
              ),);
        });
  }
}

