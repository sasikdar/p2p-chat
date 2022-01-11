

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/services/LocalStorageService.dart';
import 'package:flutter_nearby_connections_example/services/service_locator.dart';
import 'package:flutter_nearby_connections_example/models/userModel.dart';

Future<String> getUserFromDeviceID(String deviceID) async {
  var storage = getIt<Storage>();
  User? user=await storage.getUserwithdeviceID(deviceID);

  if(user!=null)
    return user.name;
  else
    return 'Unknown User' ;

}

/*
 * the function getUserFromDeviceID return a future, so Texts need to be wrapped into
 * future builder, this is a reusable widget which is used multiple times in privateChatScreen
 * takes a deviceID and returns a widget which displays the user to which the device belongs to.
 */

class GetUserNameFromDeviceIDWidget extends StatelessWidget {
  const GetUserNameFromDeviceIDWidget({
    Key? key,
    required this.device,
  }) : super(key: key);

  final Device device;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:getUserFromDeviceID(device.deviceName),
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

