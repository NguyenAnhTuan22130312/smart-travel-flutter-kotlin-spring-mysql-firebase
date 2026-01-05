import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MessageType { text, destination, image }

class GroupMessageEntity extends Equatable {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final MessageType type;
  final String content; // Text hoặc JSON cho destination
  final Timestamp timestamp;
  final bool isRead;

  const GroupMessageEntity({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.type,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [
    id,
    groupId,
    senderId,
    senderName,
    senderAvatar,
    type,
    content,
    timestamp,
    isRead,
  ];
}