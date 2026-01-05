package com.example.smart_travel_BE.util;

import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;

/**
 * Utility class để validate admin permissions
 */
public class AdminPermissionValidator {

    /**
     * Check if current admin có quyền modify target user
     * - ADMIN chỉ có thể modify USER
     * - ADMIN không thể modify ADMIN khác
     */
    public static void validateCanModifyUser(User currentAdmin, User targetUser) {
        String currentRole = currentAdmin.getRole();
        String targetRole = targetUser.getRole();

        // ADMINTOUR và ADMINHOTEL không được modify ai cả
        if ("ADMINTOUR".equals(currentRole) || "ADMINHOTEL".equals(currentRole)) {
            throw new AppException(ErrorCode.NO_WRITE_PERMISSION);
        }

        // ADMIN không được modify ADMIN khác
        if ("ADMIN".equals(currentRole) && "ADMIN".equals(targetRole)) {
            throw new AppException(ErrorCode.CANNOT_MODIFY_ADMIN_USER);
        }

        // Các role khác chỉ có thể modify USER
        if ("ADMIN".equals(currentRole) && "USER".equals(targetRole)) {
            return; // OK
        }

        // ADMIN có thể modify ADMINTOUR/ADMINHOTEL (nhưng không đổi role - check ở validateCanChangeRole)
        if ("ADMIN".equals(currentRole) && 
            ("ADMINTOUR".equals(targetRole) || "ADMINHOTEL".equals(targetRole))) {
            return; // OK
        }

        // Mặc định reject nếu không match các case trên
        throw new AppException(ErrorCode.CANNOT_MODIFY_HIGHER_ROLE);
    }

    /**
     * Check if current admin có quyền change role của target user
     * - ADMIN có thể change role của USER
     * - ADMIN KHÔNG thể change role của ADMINTOUR/ADMINHOTEL
     */
    public static void validateCanChangeRole(User currentAdmin, User targetUser, String newRole) {
        String currentRole = currentAdmin.getRole();
        String targetRole = targetUser.getRole();

        // ADMINTOUR và ADMINHOTEL không được change role
        if ("ADMINTOUR".equals(currentRole) || "ADMINHOTEL".equals(currentRole)) {
            throw new AppException(ErrorCode.NO_WRITE_PERMISSION);
        }

        // ADMIN không được change role của ADMIN khác
        if ("ADMIN".equals(currentRole) && "ADMIN".equals(targetRole)) {
            throw new AppException(ErrorCode.CANNOT_MODIFY_ADMIN_USER);
        }

        // ADMIN không được change role của ADMINTOUR/ADMINHOTEL
        if ("ADMIN".equals(currentRole) && 
            ("ADMINTOUR".equals(targetRole) || "ADMINHOTEL".equals(targetRole))) {
            throw new AppException(ErrorCode.CANNOT_CHANGE_ADMIN_ROLE);
        }

        // ADMIN có thể change role của USER
        if ("ADMIN".equals(currentRole) && "USER".equals(targetRole)) {
            return; // OK
        }

        // Default reject
        throw new AppException(ErrorCode.CANNOT_CHANGE_ADMIN_ROLE);
    }

    /**
     * Check if admin có write permission
     * ADMINTOUR và ADMINHOTEL chỉ có read permission
     */
    public static void validateHasWritePermission(User currentAdmin) {
        String currentRole = currentAdmin.getRole();
        
        if ("ADMINTOUR".equals(currentRole) || "ADMINHOTEL".equals(currentRole)) {
            throw new AppException(ErrorCode.NO_WRITE_PERMISSION);
        }
    }
}
