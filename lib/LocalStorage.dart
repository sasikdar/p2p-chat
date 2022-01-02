import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/messageModel.dart';
import 'package:flutter_nearby_connections_example/userModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlbrite/sqlbrite.dart';

class Storage {
  Storage();

  var messagestbl = 'tbl_messages';
  var intermessagestbl = 'tbl_messages_inter';
  var usertbl = 'tbl_users';
  var databasePath;
  var dbDirectory;
  BriteDatabase? _database;

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    dbDirectory = await getDatabasesPath();
    print("this is :" + dbDirectory);
    var dbPath = join(dbDirectory, 'lokalfunk.db');
    if (await databaseExists(dbPath)) {
      deleteDatabase(dbPath);
    }

    _database = BriteDatabase(
        await openDatabase(
          dbPath,
          onCreate: (db, version) {
            createTables(db, version);
          },
          version: 1,
        ),
        logger: print);

    createUserdata();
    print("here i am ");
  }

  createUserdata() {
    User user1=new User(deviceId: '3c352e33c5c8fc16', name: 'pixel-A3c35');
    User user2=new User(deviceId: 'c16cf900be58fef9', name: 'pixel-Bc16c');
    insertUsers(user1);
    insertUsers(user2);
  }

  Future createTables(db, version) {
    Future f1 = db.execute(
        'CREATE TABLE IF NOT EXISTS $messagestbl(id INTEGER PRIMARY KEY, message TEXT,sender TEXT, reciever TEXT)');
    Future f2 = db.execute(
        'CREATE TABLE IF NOT EXISTS $usertbl(id INETEGER PRIMARY KEY, name TEXT, deviceId TEXT)');
    Future f3 = db.execute(
        'CREATE TABLE IF NOT EXISTS $intermessagestbl(id INTEGER PRIMARY KEY, message TEXT,sender TEXT,reciever TEXT )');
    //Future f4 = db.execute('CREATE TABLE IF NOT EXISTS ${PrivateMessage.localDbTableName}(messageId TEXT PRIMARY KEY, senderId TEXT, receiverId TEXT, text TEXT, timestamp INT)');
    //Future f5 = db.execute('CREATE TABLE IF NOT EXISTS ${Interchange.localDbTableName}(interchangeId TEXT PRIMARY KEY, messageId TEXT, messageType TEXT, interchangeState TEXT, interchangeTime INT)');
    return Future.wait([f1, f2, f3]);
  }

  Future<void> insertMessage(messages message) async {
    await _database!.insert(
      messagestbl,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

    Future<void> insertUsers(User user) async {
      await _database!.insert(
        usertbl,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    Stream<List<messages>> getMessage() async* {
      yield* await _database!
          .createQuery('tbl_messages')
          .mapToList((json) => messages.fromMap(json))
          .map((messageList) => messageList);
    }

    Future<User?> getUserwithdeviceID(String deviceID) async {
    List<Map<String,dynamic>> maps = await _database!.query(usertbl,
          columns: ['name','deviceId'],
          where: 'deviceId= ?',
          whereArgs:[deviceID]);
      if (maps.length > 0) {
        return User.fromMap(maps.first);
      }
      return null;

    }
}

