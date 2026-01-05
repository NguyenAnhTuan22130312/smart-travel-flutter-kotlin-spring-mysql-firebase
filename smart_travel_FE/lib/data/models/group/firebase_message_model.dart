import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_travel/domain/entities/group_message.dart';

class FirebaseMessageModel {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String type; // 'text', 'destination', 'image'
  final String content;
  final Timestamp timestamp;

  FirebaseMessageModel({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.type,
    required this.content,
    required this.timestamp,
  });

  factory FirebaseMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseMessageModel(
      id: doc.id,
      groupId: data['group_id'] ?? '',
      senderId: data['sender_id'] ?? '',
      senderName: data['sender_name'] ?? 'Unknown',
      senderAvatar: data['sender_avatar'],
      type: data['type'] ?? 'text',
      content: doc['content']?.toString() ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'group_id': groupId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'type': type,
      'content': content,
      'timestamp': timestamp,
    };
  }

  GroupMessageEntity toEntity() {
    MessageType msgType;
    switch (type) {
      case 'destination':
        msgType = MessageType.destination;
        break;
      case 'image':
        msgType = MessageType.image;
        break;
      default:
        msgType = MessageType.text;
    }

    return GroupMessageEntity(
      id: id,
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      type: msgType,
      content: content,
      timestamp: timestamp,
    );
  }
}
