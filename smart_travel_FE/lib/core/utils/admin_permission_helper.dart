import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:get_it/get_it.dart';

/// Utility class để check quyền của admin hiện tại
class AdminPermissionHelper {
  static final _localDataSource = GetIt.instance.get<AuthLocalDataSource>();

  /// Get current admin role
  static Future<String?> getCurrentRole() async {
    return await _localDataSource.getRole();
  }

  /// Check if current admin có quyền modify target user
  static Future<bool> canModifyUser(String targetUserRole) async {
    final currentRole = await getCurrentRole();

    // ADMINTOUR và ADMINHOTEL không có quyền modify ai cả
    if (currentRole == 'ADMINTOUR' || currentRole == 'ADMINHOTEL') {
      return false;
    }

    // ADMIN không thể modify ADMIN khác
    if (currentRole == 'ADMIN' && targetUserRole == 'ADMIN') {
      return false;
    }

    // ADMIN có thể modify USER, ADMINTOUR, ADMINHOTEL
    if (currentRole == 'ADMIN') {
      return true;
    }

    return false;
  }

  /// Check if current admin có quyền change role của target user
  static Future<bool> canChangeRole(String targetUserRole) async {
    final currentRole = await getCurrentRole();

    // ADMINTOUR và ADMINHOTEL không có quyền change role
    if (currentRole == 'ADMINTOUR' || currentRole == 'ADMINHOTEL') {
      return false;
    }

    // ADMIN không được change role của ADMIN, ADMINTOUR, ADMINHOTEL
    if (currentRole == 'ADMIN') {
      if (targetUserRole == 'ADMIN' ||
          targetUserRole == 'ADMINTOUR' ||
          targetUserRole == 'ADMINHOTEL') {
        return false;
      }
      return true; // Chỉ được change role của USER
    }

    return false;
  }

  /// Check if current admin có write permission
  static Future<bool> hasWritePermission() async {
    final currentRole = await getCurrentRole();
    return currentRole == 'ADMIN';
  }
}
