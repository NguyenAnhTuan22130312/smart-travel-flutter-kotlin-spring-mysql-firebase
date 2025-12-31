import 'dart:io';

abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String message;

  SendMessageEvent(this.message);
}

class SendImageEvent extends ChatEvent {
  final File imageFile;
  SendImageEvent(this.imageFile);
}