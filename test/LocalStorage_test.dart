import 'package:flutter_nearby_connections_example/LocalStorage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nearby_connections_example/messageModel.dart';


void main() {


  test('test db', () async {
    var Message1 = new messages(message: "Hello", messageType: "sender");
   var  Message2 = new messages(message: "Hello", messageType: "reciever");
    var sql = new Storage();
    sql.init();
    sql.insertMessage(Message1);
    sql.insertMessage(Message2);
    List<messages> Messages; Messages = await sql.getMessage();
    expect(Messages.contains(Message1), true);
    expect(Messages.contains(Message2), true);
  });
}