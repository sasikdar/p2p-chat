class User{
static int idcounter=0;
final String name;
final String deviceId;

User({required this.name,required this.deviceId });


factory User.fromMap(Map<String, dynamic> json) {
return User(
name:json['name'], deviceId:json['deviceId'],

);
}



Map<String, dynamic> toMap() {
  return {
    'id': idcounter++,
    'name': name,
    'deviceId': deviceId
  };
}

// Implement toString to make it easier to see information about
// each dog when using the print statement.
@override
String toString() {
  return 'messages{name: $name,deviceId:$deviceId}';
}
}
