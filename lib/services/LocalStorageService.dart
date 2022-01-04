import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/models/messageModel.dart';
import 'package:flutter_nearby_connections_example/models/userModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlbrite/sqlbrite.dart';

class Storage {
  Storage();
  //Todo 04/01: Rename tbl_users to tbl_devices
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
    User user1 = new User(deviceId: '3c352e33c5c8fc16', name: 'pixel-A3c35');
    User user2 = new User(deviceId: 'c16cf900be58fef9', name: 'pixel-Bc16c');
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
    return Future.wait([f1, f2, f3]);
  }

  Future<void> insertMessage(messages message) async {
    await _database!.insert(
      messagestbl,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  /*
   *There is a table which is used to store messages which are intended for third party users
   * when a message is recived whose reciever id is not the devices id, it is stored in intermediatetable
   *
   * insertMessageinIntermediatetbl:inserts message into the intermessagestbl
   */
  Future<void> insertMessageinIntermediatetbl(messages message) async {
    await _database!.insert(
      intermessagestbl,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
 //Todo 04/01: rename it to insert devices, and also make sure that devices can have null in user field.
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
    List<Map<String, dynamic>> maps = await _database!.query(usertbl,
        columns: ['name', 'deviceId'],
        where: 'deviceId= ?',
        whereArgs: [deviceID]);
    if (maps.length > 0) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}
