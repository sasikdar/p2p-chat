import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/LocalStorage.dart';
import 'package:flutter_nearby_connections_example/service_locator.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'messageModel.dart';
import 'package:rxdart_ext/rxdart_ext.dart';





class ChatDetailPage extends StatefulWidget{
  Device? _device;
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
  ChatDetailPage(Device device){
    this._device=device;
  }
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  TextEditingController _replyTextController = new TextEditingController();
  // ScrollController _scrollController = new ScrollController();
  Stream<messages> MessageList = Stream<messages>.empty();
  var storage=getIt<Storage>();
  late String messageText;

  @override
  void initState() {
  print(storage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.black,),
          ),
          title: Text(widget._device!.deviceName.toString()),
        ),


        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              chatStream(),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                  height: 60,
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(Icons.add, color: Colors.white,
                                  size: 20,),
                              ),
                            ),
                            SizedBox(width: 15,),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  messageText = value;
                                },
                                controller: _replyTextController,
                                decoration: InputDecoration(
                                    hintText: "Write message...",
                                    hintStyle: TextStyle(color: Colors.black54),
                                    border: InputBorder.none
                                ),
                              ),
                            ),
                            SizedBox(width: 15,),
                            FloatingActionButton(
                              onPressed: () {
                                var Message = new messages(
                                    messageType: "sender",
                                    message: messageText);
                                storage.insertMessage(Message);
                                new NearbyService().sendMessage(widget._device!.deviceId,messageText);
                                    //                   device.deviceId, myController.text);
                                    //               myController.text = '';
                                    //             },
                                _replyTextController.clear();
                              },
                              child: Icon(
                                Icons.send, color: Colors.white, size: 18,),
                              backgroundColor: Colors.blue,
                              elevation: 0,
                            ),
                          ],

                        )
                      ]
                  )
                  ,
                ),
              )
            ])

    );
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


  class chatStream extends StatelessWidget {
    var storage=getIt<Storage>();
    final compositeSubscription = CompositeSubscription();
    late final StateStream<ViewState> messagesList =storage
        .getMessage()
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
      builder: (context,snapshot) {
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
            final messageType = message.messageType;

            final messageBubble = MessageBubble(
                Message: messageText,
                MessageType: messageType
            );

            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: false,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,

            ),
          );
        }

    );
    }
}



class MessageBubble extends StatelessWidget {
  MessageBubble({required this.Message, required this.MessageType});

  final String Message;
  final String MessageType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        this.MessageType.toLowerCase()=="sender"? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            this.MessageType.toLowerCase()=="sender"?"sender":"reciever",
            style: TextStyle(
              fontSize: 10.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: this.MessageType.toLowerCase()=="sender"
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
            color: this.MessageType.toLowerCase()=="sender"? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                this.Message,
                style: TextStyle(
                  color: this.MessageType.toLowerCase()=="sender"? Colors.white : Colors.black54,
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