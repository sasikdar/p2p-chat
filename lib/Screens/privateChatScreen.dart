import 'dart:async';
import 'package:collection/collection.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/services/LocalStorageService.dart';
import 'package:flutter_nearby_connections_example/services/indentityService.dart';
import 'package:flutter_nearby_connections_example/services/service_locator.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import '../models/messageModel.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class privateChatScreen extends StatefulWidget {
  Device? _device;
  List<Device>? _devices;
  @override
  _privateChatScreenState createState() => _privateChatScreenState();
  privateChatScreen(Device device, List<Device> devices) {
    this._device = device;
    this._devices=devices;
  }
}

class _privateChatScreenState extends State<privateChatScreen> {
  TextEditingController _replyTextController = new TextEditingController();
  // ScrollController _scrollController = new ScrollController();
  Stream<messages> MessageList = Stream<messages>.empty();
  var storage = getIt<Storage>();
  late String messageText;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();



  @override
  void initState() {
    print(storage);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor:Colors.black87,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title:  FutureBuilder(
              future:getUserFromDeviceID(widget._device!.deviceName),
              builder:(context, AsyncSnapshot<String> snapshot){
                if(snapshot.hasData)
                {
                  return Text(snapshot.data!);
                }
                else
                  return CircularProgressIndicator();
              }),//Text(getUserfromdeviceID(widget._device!.deviceName)),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PrivateMessageWidget(widget._device!),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                  height: 80,
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  messageText = value;
                                },
                                controller: _replyTextController,
                                decoration: InputDecoration(

                                    hintText: "Write message...",
                                    hintStyle: TextStyle(color: Colors.black54),
                                    border: InputBorder.none),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            FloatingActionButton(
                              onPressed: () async {
                                var andriodInfo= await deviceInfo.androidInfo;
                                var Message = new messages(
                                    sender:andriodInfo.androidId,
                                    reciever:widget._device!.deviceName,
                                    message: messageText);

                                var sentMessagetext="PRI"+"substringidentifyXYZ"+Message.message+"substringidentifyXYZ"+Message.reciever+"substringidentifyXYZ"+Message.sender;
                                storage.insertMessage(Message);
                                if(widget._device!.deviceId=='XXX'){
                                  widget._devices!.forEach((element) {
                                    new NearbyService().sendMessage(element.deviceId,sentMessagetext);
                                  });

                                }else{
                                  new NearbyService().sendMessage(widget._device!.deviceId,sentMessagetext);
                                }
                                debugPrint(widget._device!.deviceId+await getUserFromDeviceID(widget._device!.deviceName));
                                _replyTextController.clear();
                                },
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 18,
                              ),
                              backgroundColor: Colors.cyan,
                              elevation: 0,
                            ),
                          ],
                        )
                      ]),
                ),
              )
            ]));
  }
}

class ViewState {
  final List<messages> Messages;
  final bool isLoading;
  final AsyncError? error;

  static const loading = ViewState._([], true, null);

  const ViewState._(this.Messages, this.isLoading, this.error);

  ViewState.success(List<messages> Messages) : this._(Messages, false, null);

  ViewState.failure(Object e, StackTrace s)
      : this._([], false, AsyncError(e, s));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewState &&
          runtimeType == other.runtimeType &&
          const ListEquality<messages>().equals(Messages, other.Messages) &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => Messages.hashCode ^ isLoading.hashCode ^ error.hashCode;

  @override
  String toString() =>
      'ViewState{items.length: ${Messages.length}, isLoading: $isLoading, error: $error}';
}
/*
 * PrivateMessageWidget displays the private messages to the user,
 * this widget gets the private messages from the database as a stream and displays them.
 * device: The device which will recieve the chat message
 */
class PrivateMessageWidget extends StatelessWidget {
  PrivateMessageWidget(this.device);
  final Device device;


  var storage = getIt<Storage>();
  final compositeSubscription = CompositeSubscription();
  late final StateStream<ViewState> messagesList = storage
      .getMessage(device.deviceName)
      .map((items) => ViewState.success(items))
      .onErrorReturnWith((e, s) => ViewState.failure(e, s))
      .debug(identifier: '<<STATE>>', log: debugPrint)
      .publishState(ViewState.loading)
    ..connect().addTo(compositeSubscription);
  @override
  void initState() {
    final _ = messagesList;
  }

  @override
  void dispose() {
    compositeSubscription.dispose();
    //super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ViewState>(
        stream: messagesList,
        initialData: messagesList.value,
        builder: (context, snapshot) {
          final state = snapshot.requireData;
          if (state.error != null) {
            debugPrint('Error: ${state.error!.error}');
            debugPrint('Stacktrace: ${state.error!.stackTrace}');

            return Center(
              child: Text(
                'Error: ${state.error!.error}',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var messagesList = state.Messages;
          List<MessageBubble> messageBubbles = [];
          for (var message in messagesList) {
            final messageText = message.message;
            final sender = message.sender;
            final reciever=message.reciever;


            final messageBubble =
                MessageBubble(Message: messageText,Sender:sender,Reciever: reciever,device:device);

            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: false,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        });
  }
}

// Widget which deals with the cosmetics of message bubble in the chat window.

class MessageBubble extends StatelessWidget {
  MessageBubble({required this.Message, required this.Sender,required this.Reciever,required this.device});
  final Device device;
  final String Message;
  final String Sender;
  final String Reciever;
  DeviceInfoPlugin deviceinfo=DeviceInfoPlugin();
  var andriodInfo;
  @override
  Future<void> initState() async {

  }



  @override
  Widget build(BuildContext context){

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(


        crossAxisAlignment: this.Reciever ==device.deviceName
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[

         // Text(
            this.Reciever== device.deviceName?
            Text(
              "you",
               style: TextStyle(
                 fontSize: 10.0,
                 color: Colors.black54,
            ),
          ):GetUserNameFromDeviceIDWidget(device:device),

          Material(
            borderRadius: this.Reciever ==device.deviceName
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: this.Reciever ==device.deviceName
                ? Colors.lightBlueAccent
                : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                this.Message,
                style: TextStyle(
                  color: this.Reciever ==device.deviceName
                      ? Colors.white
                      : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
