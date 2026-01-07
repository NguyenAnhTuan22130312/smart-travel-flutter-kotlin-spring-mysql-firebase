import 'dart:async';

class CooldownManager {
  // Singleton instance
  static final CooldownManager _instance = CooldownManager._internal();
  factory CooldownManager() => _instance;
  CooldownManager._internal();

  // Lưu trữ thời điểm nhận điểm: Map<destinationId, serverTime>
  final Map<int, DateTime> _lastEarnedMap = {};

  // Lưu trữ độ lệch thời gian với Server
  Duration serverTimeOffset = Duration.zero;

  void updateCooldown(int id, DateTime serverTime) {
    _lastEarnedMap[id] = serverTime;
    // Cập nhật offset mỗi khi có dữ liệu mới từ Server
    serverTimeOffset = serverTime.difference(DateTime.now());
  }

  DateTime? getLastEarned(int id) => _lastEarnedMap[id];

  int getRemainingSeconds(int id) {
    if (!_lastEarnedMap.containsKey(id)) return 0;

    final currentServerTime = DateTime.now().add(serverTimeOffset);
    final secondsPassed = currentServerTime.difference(_lastEarnedMap[id]!).inSeconds;
    return 180 - secondsPassed;
  }
}