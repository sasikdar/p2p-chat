import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/messageModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Storage{
  Storage();

var databasePath;
var dbDirectory;
var _database;

   Future<void> init() async {
     WidgetsFlutterBinding.ensureInitialized();
     dbDirectory = await getDatabasesPath();
     print("this is :"+ dbDirectory);
     var dbPath = join(dbDirectory, 'lokalfunk.db');
     if (await databaseExists(dbPath)) {
        deleteDatabase(dbPath);
     }

     _database = await openDatabase(
       dbPath,
       onCreate: (db, version) {
         return db.execute(
           'CREATE TABLE IF NOT EXISTS tbl_messages(id INTEGER PRIMARY KEY, message TEXT, messageType INTEGER)',
         );
       },
       version: 1,
     );

print("here i am ");
  }

Future<void> insertMessage(messages message) async {
  // Get a reference to the database.


  // Insert the Dog into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same dog is inserted twice.
  //
  // In this case, replace any previous data.
  await _database.insert(
    'tbl_messages',
    message.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Stream<dynamic> getMessage() async* {
  // Get a reference to the database.


  // Query the table for all The Dogs.
  //final List<Map<String, dynamic>> maps = await _database.query('tbl_messages');
  var maps=await _database.query('tbl_messages');

  // Convert the List<Map<String, dynamic> into a List<Dog>.

  var messageList= List.generate(maps.length, (i) {
    return messages(
      //id: maps[i]['id'],
      message: maps[i]['message'],
      messageType: maps[i]['messageType'],
    );
  });

  yield _database.query('tbl_messages');

   }
}