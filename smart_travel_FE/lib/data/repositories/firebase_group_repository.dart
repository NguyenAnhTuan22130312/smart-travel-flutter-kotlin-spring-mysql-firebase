import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_travel/data/models/group/firebase_group_model.dart';
import 'package:smart_travel/data/models/group/firebase_message_model.dart';
import 'package:smart_travel/domain/entities/group.dart.dart';
import 'package:smart_travel/domain/entities/group_message.dart';

class FirebaseGroupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _groupsCollection => _firestore.collection('groups');
  CollectionReference _messagesCollection(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('messages');

  // ===== GROUP OPERATIONS =====

  /// Tạo nhóm mới
  Future<GroupEntity> createGroup({
    required String name,
    required String creatorId,
    String? description,
    String? avatar,
  }) async {
    final inviteCode = _generateInviteCode();
    final now = Timestamp.now();

    final docRef = await _groupsCollection.add({
      'name': name,
      'description': description,
      'avatar': avatar,
      'invite_code': inviteCode,
      'creator_id': creatorId,
      'member_ids': [creatorId],
      'created_at': now,
      'updated_at': now,
    });

    final doc = await docRef.get();
    return FirebaseGroupModel.fromFirestore(doc).toEntity();
  }

  /// Lấy danh sách nhóm của user
  Stream<List<GroupEntity>> getUserGroups(String userId) {
    return _groupsCollection
        .where('member_ids', arrayContains: userId)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirebaseGroupModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }

  /// Tìm nhóm theo mã mời
  Future<GroupEntity?> findGroupByInviteCode(String inviteCode) async {
    final querySnapshot = await _groupsCollection
        .where('invite_code', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return FirebaseGroupModel.fromFirestore(querySnapshot.docs.first).toEntity();
  }

  /// Join nhóm bằng mã mời
  Future<void> joinGroup(String groupId, String userId) async {
    await _groupsCollection.doc(groupId).update({
      'member_ids': FieldValue.arrayUnion([userId]),
      'updated_at': Timestamp.now(),
    });
  }

  /// Rời nhóm
  Future<void> leaveGroup(String groupId, String userId) async {
    await _groupsCollection.doc(groupId).update({
      'member_ids': FieldValue.arrayRemove([userId]),
      'updated_at': Timestamp.now(),
    });
  }

  /// Lấy thông tin chi tiết nhóm
  Future<GroupEntity> getGroupById(String groupId) async {
    final doc = await _groupsCollection.doc(groupId).get();
    return FirebaseGroupModel.fromFirestore(doc).toEntity();
  }

  // ===== MESSAGE OPERATIONS =====

  /// Gửi tin nhắn text
  Future<void> sendTextMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String content,
  }) async {
    await _messagesCollection(groupId).add({
      'group_id': groupId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'type': 'text',
      'content': content,
      'timestamp': Timestamp.now(),
    });

    // Update last activity
    await _groupsCollection.doc(groupId).update({
      'updated_at': Timestamp.now(),
    });
  }

  void _validateDestination(Map<String, dynamic> destination) {
    if (destination['destination_id'] == null) {
      throw Exception('vui lòng chọn ịa điểm để chia sẻ');
    }
  }

  /// Chia sẻ destination vào nhóm
  Future<void> shareDestination({
    required String groupId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required Map<String, dynamic>? destinationData,
  }) async {
    if (destinationData == null) {
      throw Exception('Destination null');
    }

    _validateDestination(destinationData);

    await _messagesCollection(groupId).add({
      'group_id': groupId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'type': 'destination',
      'content': jsonEncode(destinationData),
      'timestamp': Timestamp.now(),
    });

    await _groupsCollection.doc(groupId).update({
      'updated_at': Timestamp.now(),
    });
  }

  /// Lấy tin nhắn realtime
  Stream<List<GroupMessageEntity>> getMessagesStream(String groupId) {
    return _messagesCollection(groupId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirebaseMessageModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }

  /// Xóa tin nhắn
  Future<void> deleteMessage(String groupId, String messageId) async {
    await _messagesCollection(groupId).doc(messageId).delete();
  }

  // ===== HELPER =====
  /// Tạo mã mời ngẫu nhiên (8 ký tự)
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      8,
          (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}