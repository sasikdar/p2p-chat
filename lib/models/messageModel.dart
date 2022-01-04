class messages{
   static int idcounter=0;
    final String sender;
    final String reciever;
    final String message;
    messages({required this.message,required this.reciever,required this.sender });


   factory messages.fromMap(Map<String, dynamic> json) {
     return messages(
       message:json['message'],
       sender:json['sender'],
       reciever:json['reciever']
     );
   }



   Map<String, dynamic> toMap() {
     return {
       'id': idcounter++,
       'message': message,
       //'messageType': messageType,
       'sender':sender,
       'reciever':reciever


     };
   }

   // Implement toString to make it easier to see information about
   // each dog when using the print statement.
   @override
   String toString() {
     return 'messages{message: $message,sender:$sender,receiver:$reciever}';
   }
}
