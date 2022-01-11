import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/models/messageModel.dart';
import 'package:flutter_nearby_connections_example/services/service_locator.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'LocalStorageService.dart';
import 'package:rxdart/subjects.dart';

class P2P {
  P2P();
  //var devices=ReplaySubject<Device>();
  List<Device> devices = [];
  var nearbyService;
  var storage = getIt<Storage>();
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    nearbyService = NearbyService();
    String devInfo = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    AndroidDeviceInfo androidInfo;
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
      devInfo = androidInfo.androidId;
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devInfo = iosInfo.localizedModel;
    }
    await nearbyService.init(
        serviceType: 'mpconn',
        deviceName: devInfo,
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) async {
          if (isRunning) {
            await nearbyService.stopBrowsingForPeers();
            await nearbyService.stopAdvertisingPeer();
            await Future.delayed(Duration(microseconds: 200));
            nearbyService.startAdvertisingPeer();
            nearbyService.startBrowsingForPeers();
          }
        });


    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        devices.add(element);
        print(
            " deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            nearbyService.stopBrowsingForPeers();
          } else {
            nearbyService.invitePeer(
              deviceID: element.deviceId,
              deviceName: element.deviceName,
            );
            nearbyService.startBrowsingForPeers();
          }
        }
      });


      devices.clear();
      devices.addAll(devicesList);


    });

    receivedDataSubscription =
        nearbyService.dataReceivedSubscription(callback: (data) async {
      var message = data["message"];
      var messageparts = message.split("substringidentifyXYZ");

      messages m1 = new messages(
          sender: messageparts[2],
          message: messageparts[0],
          reciever: messageparts[1]);

      androidInfo = await deviceInfo.androidInfo;
      if (m1.reciever == androidInfo.androidId) {
        storage.insertMessage(m1);
      } else {
        storage.insertMessageinIntermediatetbl(m1);
      }
      print("dataReceivedSubscription: ${jsonEncode(data)}");
      showToast(jsonEncode(data),
          //context: context,
          axis: Axis.horizontal,
          alignment: Alignment.center,
          position: StyledToastPosition.bottom);
    });
    //return connectedDevices;
  }
}
