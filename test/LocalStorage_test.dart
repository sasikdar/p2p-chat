import 'package:flutter_nearby_connections_example/services/LocalStorageService.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nearby_connections_example/models/messageModel.dart';


void main() {


  test('test db', () async {
    var sql = new Storage();
    sql.init();
    Stream<List<messages>> Messages; Messages = await sql.getMessage();

  });
}