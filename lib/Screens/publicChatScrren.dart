import 'dart:async';
import 'package:collection/collection.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/models/publicMessageModel.dart';
import 'package:flutter_nearby_connections_example/services/LocalStorageService.dart';
import 'package:flutter_nearby_connections_example/services/service_locator.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import '../models/messageModel.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class publicChatScreen extends StatefulWidget {

  List<Device>? _devices;
  @override
  _publicChatScreenState createState() => _publicChatScreenState();
  publicChatScreen(List<Device> devices) {
    this._devices=devices;
  }
}

class _publicChatScreenState extends State<publicChatScreen> {
  TextEditingController _replyTextController = new TextEditingController();
  Stream<messages> MessageList = Stream<messages>.empty();
  var storage = getIt<Storage>();
  late String messageText;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  var AndriodInfo;
  var AndriodId;



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
          title:Text("Annoucements"),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              publicMessageWidget(),
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
                              width: 5,
                              height:30,
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

                            FloatingActionButton(
                              onPressed: () async {
                                var andriodInfo= await deviceInfo.androidInfo;
                                /*
                                 * Get the message from the input box
                                 * Format it with padding text and sender and message identifier
                                 * then flood it in the network
                                 */

                                    var Message = new publicmessages(
                                        sender:andriodInfo.androidId,
                                        message:messageText,
                                        messageIndetifier:andriodInfo.androidId+DateTime.now().millisecondsSinceEpoch.toString() );
                                    storage.insertPublicMessage(Message);
                                    var sentMessagetext="PUB"+"substringidentifyXYZ"+Message.message+"substringidentifyXYZ"+Message.messageIndetifier+"substringidentifyXYZ"+Message.sender;
                                widget._devices!.forEach((element) {
                                    new NearbyService().sendMessage(element.deviceId,sentMessagetext);
                                  });
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
  final List<publicmessages> Messages;
  final bool isLoading;
  final AsyncError? error;

  static const loading = ViewState._([], true, null);

  const ViewState._(this.Messages, this.isLoading, this.error);

  ViewState.success(List<publicmessages> Messages) : this._(Messages, false, null);

  ViewState.failure(Object e, StackTrace s)
      : this._([], false, AsyncError(e, s));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ViewState &&
              runtimeType == other.runtimeType &&
              const ListEquality<publicmessages>().equals(Messages, other.Messages) &&
              isLoading == other.isLoading &&
              error == other.error;

  @override
  int get hashCode => Messages.hashCode ^ isLoading.hashCode ^ error.hashCode;

  @override
  String toString() =>
      'ViewState{items.length: ${Messages.length}, isLoading: $isLoading, error: $error}';
}





/*
 * publicMessageWidget displays the public messages to the user,
 * this widget gets the public messages from the database as a stream and displays them.
 *
 */
class publicMessageWidget extends StatelessWidget {
  publicMessageWidget();



  var storage = getIt<Storage>();
  final compositeSubscription = CompositeSubscription();
  late final StateStream<ViewState> messagesList = storage
      .getPublicMessage() //replace with getPublicmessage function
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
            //final messageIndetifier=message.messageIndetifier;


            final messageBubble =
            MessageBubble(Message: messageText,Sender:sender);

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

class MessageBubble extends StatelessWidget {
  MessageBubble({required this.Message, required this.Sender});
  final String Message;
  final String Sender;
  DeviceInfoPlugin deviceinfo=DeviceInfoPlugin();
  var AndriodInfo;
  var AndriodId;
  @override
  Future<void> initState() async {

  }

  void getAndriodId() async{
    AndriodInfo= await deviceinfo.androidInfo;
    AndriodId=AndriodInfo.androidId;
  }




  @override
  Widget build(BuildContext context){

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(


        crossAxisAlignment: this.Sender ==AndriodId
            ? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: <Widget>[

          // Text(
          this.Sender== AndriodId?Text('you'):
          Text(
            this.Sender,
            style: TextStyle(
              fontSize: 10.0,
              color: Colors.black54,
            ),
          ),

          Material(
            borderRadius: this.Sender ==AndriodId
                ?BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)):BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: this.Sender ==AndriodId
                ?Colors.lightBlueAccent:Colors.white ,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                this.Message,
                style: TextStyle(
                  color: this.Sender ==AndriodId
                      ? Colors.white:Colors.black54
                  ,
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
