import 'package:flutter/material.dart';

import '../../features/shop/model/message.dart';


class MessageTile extends StatelessWidget {
  final Message message;
  final bool isOutgoing;

  const MessageTile({
    super.key,
    required this.message,
    required this.isOutgoing,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isOutgoing ? Colors.blueAccent : Colors.grey[300],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.message,
                style: TextStyle(
                  color: isOutgoing ? Colors.white : Colors.black,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 10),
              message.imageUrl != null
                  ? Image.network(message.imageUrl!, height: 200, width: 200,)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
