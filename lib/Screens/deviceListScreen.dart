import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/services/indentityService.dart';
import 'package:flutter_nearby_connections_example/services/service_locator.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import '../services/LocalStorageService.dart';
import 'privateChatScreen.dart';
import '../models/messageModel.dart';

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({required this.deviceType});

  final DeviceType deviceType;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  var storage = getIt<Storage>();

  bool isInit = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    subscription.cancel();
    receivedDataSubscription.cancel();
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //title: Text(widget.deviceType.toString().substring(11).toUpperCase()),
          backgroundColor: Colors.black87,
          title: Text("Connected Devices"),
        ),
        backgroundColor: Colors.white,
        body: ListView.builder(
            itemCount: getItemCount(),
            itemBuilder: (context, index) {
              /*   final device = widget.deviceType == DeviceType.advertiser
                  ? connectedDevices[index]
                  : devices[index];*/
              //Todo 04/01: instead of getting devices from device list it should be fetched from devicetbl
              //Todo 04/01: devices state should be checked from the devices list and all devices can be chatted with, currently only online devices can be chatted
              //Todo 04/01: with which are connected, unconnected devices will be delivered messages via relay devices.

              final device = devices[index];
              return Container(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          onTap: () => _onTabItemListener(device),
                          child: Column(
                            children: [
                              //Text(device.deviceName),
                              GetUserNameFromDeviceIDWidget(device: device),

                              Text(
                                getStateName(device.state),
                                style: TextStyle(
                                    color: getStateColor(device.state)),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        )),
                        // Request connect
                        GestureDetector(
                          onTap: () => _onButtonClicked(device),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            padding: EdgeInsets.all(8.0),
                            height: 35,
                            width: 100,
                            color: getButtonColor(device.state),
                            child: Center(
                              child: Text(
                                getButtonStateName(device.state),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey,
                    )
                  ],
                ),
              );
            }));
  }
  //getStateName returns device state @param state is a device state.
  String getStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return "disconnected";
      case SessionState.connecting:
        return "waiting";
      default:
        return "connected";
    }
  }

  String getButtonStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return "Connect";
      default:
        return "Disconnect";
    }
  }

  Color getStateColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return Colors.black;
      case SessionState.connecting:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  Color getButtonColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return Colors.greenAccent;
      default:
        return Colors.pinkAccent;
    }
  }

  _onTabItemListener(Device device) {
    if (device.state == SessionState.connected) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return privateChatScreen(device);
      }));
    }
  }

  int getItemCount() {
    if (widget.deviceType == DeviceType.advertiser) {
      return connectedDevices.length;
    } else {
      return devices.length;
    }
  }

  _onButtonClicked(Device device) {
    switch (device.state) {
      case SessionState.notConnected:
        nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
        );
        break;
      case SessionState.connected:
        nearbyService.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
    }
  }

  void init() async {
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
    //Todo 04/01 when the state changes to connected, the device should be stored in the device table,
    //Todo 04/01 before putting the device in device table we should check if the device already exists
    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
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

      setState(() {
        devices.clear();
        devices.addAll(devicesList);
        connectedDevices.clear();
        connectedDevices.addAll(devicesList
            .where((d) => d.state == SessionState.connected)
            .toList());
      });
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
      if (m1.reciever == androidInfo!.androidId) {
        storage.insertMessage(m1);
      } else {
        storage.insertMessageinIntermediatetbl(m1);
      }
      print("dataReceivedSubscription: ${jsonEncode(data)}");
      showToast(jsonEncode(data),
          context: context,
          axis: Axis.horizontal,
          alignment: Alignment.center,
          position: StyledToastPosition.bottom);
    });
  }
}
