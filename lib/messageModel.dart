class messages{
   static int idcounter=0;

    final String messageType;
    final String message;
    messages({required this.message,required this.messageType});



   Map<String, dynamic> toMap() {
     return {
       'id': idcounter++,
       'message': message,
       'messageType': messageType,

     };
   }

   // Implement toString to make it easier to see information about
   // each dog when using the print statement.
   @override
   String toString() {
     return 'messages{messageType: $messageType, message: $message}';
   }
}
