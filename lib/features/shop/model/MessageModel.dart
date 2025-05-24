// enum MessageType { text, image, map }

// class Message {
//   final String id;
//   final String text;
//   final bool isUser;
//   final MessageType type;

//   Message({
//     required this.id,
//     required this.text,
//     required this.isUser,
//     required this.type,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'text': text,
//       'isUser': isUser,
//       'type': type.toString(),
//     };
//   }

//   factory Message.fromJson(Map<String, dynamic> json) {
//     return Message(
//       id: json['id'],
//       text: json['text'],
//       isUser: json['isUser'],
//       type: MessageType.values.firstWhere((e) => e.toString() == json['type']),
//     );
//   }
// }
