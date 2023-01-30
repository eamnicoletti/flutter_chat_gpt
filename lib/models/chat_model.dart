class ChatModel {
  final String message;
  final MessageFrom messengeFrom;

  ChatModel({
    required this.message,
    required this.messengeFrom,
  });
}

enum MessageFrom { me, bot }
