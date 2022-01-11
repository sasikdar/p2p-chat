import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/models/userModel.dart';
import 'package:flutter_nearby_connections_example/services/indentityService.dart';
import 'package:flutter_nearby_connections_example/services/service_locator.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import '../services/LocalStorageService.dart';
import 'privateChatScreen.dart';
import '../models/messageModel.dart';

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen();

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  List<String> deviceNames=[];
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  var storage = getIt<Storage>();
  var _device;
  // var p2p=getIt<P2P>();
  // List<User> userList=await storage.getAllUsers();
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  late AndroidDeviceInfo androidInfo;

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
        title: Text("Peepli"),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Connected Users',textAlign: TextAlign.start, style: TextStyle(color: Colors.green,fontSize: 20),),
          SizedBox(
            height: 8.0,
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: getItemCount(),
              itemBuilder: (context, index) {

                  _device=devices[index];
                  return Container(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                      children: [
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          onTap:() => _onTabItemListener(_device),
                          child: Column(
                            children: [
                              GetUserNameFromDeviceIDWidget(device: _device),
                              Text(getStateName(_device.state),
                                  style: TextStyle(
                                    color: getStateColor(_device.state),
                                  )),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),

                        )),
                        GestureDetector(
                          onTap:() => _onButtonClicked(_device),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            padding: EdgeInsets.all(8.0),
                            height: 35,
                            width: 100,
                            color: getButtonColor(_device.state),
                            child: Center(
                              child: Text(
                                'Chat',//getButtonStateName(_device.state),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey,
                    )
                  ]),
                );
              },
            ),
          ),
          Divider(
            height: 5,
            color: Colors.black87
          ),

          Expanded(
            flex: 2,
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text('Disconnected Users',textAlign: TextAlign.start, style: TextStyle(color: Colors.redAccent,fontSize: 20),),
                SizedBox(
                  height: 8.0,
                ),
                FutureBuilder(
                  future: storage.getUsersNotin(devices),
                  builder: (context, AsyncSnapshot<List<User>> snapshot) {
                    return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      if(snapshot.hasData)
                        {
                      //if(devices[index].deviceName!=androidInfo.androidId)
                      User _user=snapshot.data![index];
                      return Container(
                        margin: EdgeInsets.all(8.0),
                        child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: GestureDetector(
                                        onTap:() => _onTabItemListener(_device),
                                        child: Column(
                                          children: [
                                            Text(_user.name),
                                            Text('Disconnected',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                )),
                                          ],
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                        ),

                                      )),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                                      padding: EdgeInsets.all(8.0),
                                      height: 35,
                                      width: 100,
                                      color: Colors.greenAccent,
                                      child: Center(
                                        child: Text(
                                          'Connect',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Divider(
                                height: 1,
                                color: Colors.grey,
                              )
                            ]),
                      );}
                      else {
                        return CircularProgressIndicator();
                      }
                    },
              );
                  }
                )]
            ),
          ),
        ],
      ),
    );
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
  _onButtonClicked(Device device) {
    switch (device.state) {

        case SessionState.notConnected:
          nearbyService.invitePeer(
            deviceID: device.deviceId,
            deviceName: device.deviceName,
          );
          break;
        case SessionState.connecting:
        break;
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
    return devices.length;
  }


  void init() async {
    nearbyService = NearbyService();
    String devInfo = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    //AndroidDeviceInfo androidInfo;
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
        print(
            " deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            nearbyService.stopBrowsingForPeers();
          } else {
            nearbyService.startAdvertisingPeer();
            nearbyService.startBrowsingForPeers();
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
      if (m1.reciever == androidInfo.androidId) {
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
