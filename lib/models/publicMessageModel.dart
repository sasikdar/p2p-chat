class publicmessages{
  static int idcounter=0;
  final String sender;
  final String message;
  final String messageIndetifier;
  publicmessages({required this.message,required this.messageIndetifier,required this.sender });


  factory publicmessages.fromMap(Map<String, dynamic> json) {
    return publicmessages(
        message:json['message'],
        sender:json['sender'],
        messageIndetifier:json['messageIndetifier']
    );
  }



  Map<String, dynamic> toMap() {
    return {
      'id': idcounter++,
      'message': message,
      //'messageType': messageType,
      'sender':sender,
      'messageIndetifier':messageIndetifier


    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'messages{message: $message,sender:$sender,messageIndetifier:$messageIndetifier}';
  }
}
