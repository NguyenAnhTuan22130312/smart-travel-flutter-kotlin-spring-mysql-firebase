import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? avatar;
  final String code; // Mã mời để join nhóm
  final String creatorId;
  final List<String> memberIds;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const GroupEntity({
    required this.id,
    required this.name,
    this.description,
    this.avatar,
    required this.code,
    required this.creatorId,
    required this.memberIds,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    avatar,
    code,
    creatorId,
    memberIds,
    createdAt,
    updatedAt,
  ];
}
