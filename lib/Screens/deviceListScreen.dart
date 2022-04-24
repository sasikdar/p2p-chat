import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/Screens/publicChatScrren.dart';
import 'package:flutter_nearby_connections_example/models/publicMessageModel.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
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
                          onTap:() => _onTabItemListener(devices[index],devices),
                          child: Column(
                            children: [
                              GetUserNameFromDeviceIDWidget(device: devices[index]),
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
                                        onTap:() => _onTabItemListener(Device("XXX",_user.deviceId,0),devices),
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
                             /*     GestureDetector(
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
                                  ),*/
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
          Divider(
              height: 5,
              color: Colors.black87
          ),
          Expanded(
            flex:2,

              child:Container(
                padding: EdgeInsets.all(30),
                alignment: Alignment.bottomRight,
                child:
                  Column(
                    children: [
                      Text('Annoucement'),
                      ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return publicChatScreen(devices);}));
                        },
                      child: Icon(Icons.add, color: Colors.white,semanticLabel: 'Annouce',),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(30),
                        primary: Colors.blue, // <-- Button color
                        onPrimary: Colors.red,
                        // <-- Splash color
                      )
                ),
                    ],
                  ),
              )
          )
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

  // Changes the state of the device, if the device is nearby but not connected,
  // clicking the chat button connects the devices
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

  _onTabItemListener(Device device,List<Device> _devices) {

    if (device.state == SessionState.connected) {

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return privateChatScreen(device,_devices);
      }));
    }
    else{
      if(device.deviceId=='XXX'){
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return privateChatScreen(device,_devices);
        }));

      }
    }
  }

  int getItemCount() {
    return devices.length;
  }


  void init() async {
    nearbyService = NearbyService();
    String devInfo = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    List<messages> intermidiateMessages= await storage.getMessagefromIntermediatetbl();
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
    //call back function which checks if any of the devices have changed the connection state
    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        print(" deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            //intermidiateMessages List of messages fetched from tbl_intermidateMessages
            intermidiateMessages.forEach((Message) {
              print("will try to transmit message now");
              var sentText=Message.message+"substringidentifyXYZ"+Message.reciever+"substringidentifyXYZ"+Message.sender;
              nearbyService.sendMessage(element.deviceId, sentText);
              print("transmitted message now");
            });

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

    //call back function which deals with the data recieved and how to deal with them.

    receivedDataSubscription =
        nearbyService.dataReceivedSubscription(callback: (data) async {
      var message = data["message"];
      var messageparts = message.split("substringidentifyXYZ");
      if(messageparts[0]=='PRI') {
        messages m1 = new messages(
            sender: messageparts[3],
            message: messageparts[1],
            reciever: messageparts[2]);

        androidInfo = await deviceInfo.androidInfo;
        if (m1.reciever == androidInfo.androidId) {
          storage.insertMessage(m1);
        } else {
          storage.insertMessageinIntermediatetbl(m1);
        }
      }else if(messageparts[0]=='PUB')
        {
          publicmessages m1 = new publicmessages(
              sender: messageparts[3],
              message: messageparts[1],
              messageIndetifier: messageparts[2],);
          List<String> messageIDlist=await storage.getPublicMessageasIDList();

          if(!messageIDlist.contains(m1.messageIndetifier))
            {
              storage.insertPublicMessage(m1);
              devices.forEach((device) {
               if( device .deviceName!=m1.sender && device.deviceName!=androidInfo.androidId)
                 nearbyService.sendMessage(device.deviceId, 'PUB'+"substringidentifyXYZ"+m1.message+"substringidentifyXYZ"+m1.messageIndetifier+"substringidentifyXYZ"+m1.sender);

              });
            }

          //public message recieving code
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
