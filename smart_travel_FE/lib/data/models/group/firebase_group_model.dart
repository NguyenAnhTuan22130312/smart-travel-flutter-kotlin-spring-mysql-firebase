
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_travel/domain/entities/group.dart.dart';

class FirebaseGroupModel {
  final String id;
  final String name;
  final String? description;
  final String? avatar;
  final String inviteCode; // Mã mời để join
  final String creatorId;
  final List<String> memberIds;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  FirebaseGroupModel({
    required this.id,
    required this.name,
    this.description,
    this.avatar,
    required this.inviteCode,
    required this.creatorId,
    required this.memberIds,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert từ Firestore Document
  factory FirebaseGroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseGroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      avatar: data['avatar'],
      inviteCode: data['invite_code'] ?? '',
      creatorId: data['creator_id'] ?? '',
      memberIds: List<String>.from(data['member_ids'] ?? []),
      createdAt: data['created_at'] ?? DateTime.now(),
      updatedAt: data['updated_at'] ?? DateTime.now(),
    );
  }

  // Convert sang Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'avatar': avatar,
      'invite_code': inviteCode,
      'creator_id': creatorId,
      'member_ids': memberIds,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Convert sang Entity
  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: name,
      description: description,
      avatar: avatar,
      code: inviteCode,
      creatorId: creatorId,
      memberIds: memberIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}