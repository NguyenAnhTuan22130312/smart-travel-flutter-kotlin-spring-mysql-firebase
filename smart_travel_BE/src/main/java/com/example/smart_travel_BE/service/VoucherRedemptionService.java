package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.entity.UserProfile;
import com.example.smart_travel_BE.entity.UserVoucher;
import com.example.smart_travel_BE.entity.Voucher;
import com.example.smart_travel_BE.repository.UserProfileRepository;
import com.example.smart_travel_BE.repository.UserRepository;
import com.example.smart_travel_BE.repository.UserVoucherRepository;
import com.example.smart_travel_BE.repository.VoucherRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class VoucherRedemptionService {

    private final VoucherRepository voucherRepository;
    private final UserProfileRepository userProfileRepository;
    private final UserVoucherRepository userVoucherRepository;
    private final UserRepository userRepository;

    // 1. Lấy danh sách các voucher CÓ THỂ ĐỔI (đang active, còn hạn)
    public List<Voucher> getRedeemableVouchers() {
        // Bạn có thể thêm điều kiện filter expiryDate > now() trong Repository
        return voucherRepository.findAll().stream()
                .filter(v -> v.getIsActive() && v.getExpiryDate().isAfter(LocalDateTime.now()))
                .toList();
    }

    // 2. Logic Đổi điểm (Redeem)
    @Transactional
    public UserVoucher redeemVoucher(Long userId, Long voucherId) {
        // a. Tìm UserProfile để lấy điểm
        UserProfile userProfile = userProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy hồ sơ người dùng!"));

        // b. Tìm Voucher muốn đổi
        Voucher voucher = voucherRepository.findById(voucherId)
                .orElseThrow(() -> new RuntimeException("Voucher không tồn tại!"));

        // c. Validate (Kiểm tra hợp lệ)
        if (!voucher.getIsActive()) {
            throw new RuntimeException("Voucher này hiện không khả dụng!");
        }
        if (voucher.getExpiryDate().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Voucher đã hết hạn!");
        }

        // d. Kiểm tra điểm tích lũy
        Long currentPoints = userProfile.getExperiencePoints();
        Long pointsCost = voucher.getPointsRequired();

        if (pointsCost == null) {
            throw new RuntimeException("Voucher này không hỗ trợ đổi điểm!");
        }

        if (currentPoints < pointsCost) {
            throw new RuntimeException("Bạn không đủ điểm để đổi voucher này! (Cần: "
                    + pointsCost + ", Có: " + currentPoints + ")");
        }

        // e. Trừ điểm người dùng
        userProfile.setExperiencePoints(currentPoints - pointsCost);
        userProfileRepository.save(userProfile);

        // f. Lưu vào kho voucher của người dùng (UserVoucher)
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        UserVoucher userVoucher = UserVoucher.builder()
                .user(user)
                .voucher(voucher)
                .isUsed(false)
                .build();

        return userVoucherRepository.save(userVoucher);
    }

    // 3. Lấy danh sách voucher người dùng đã sở hữu
    public List<UserVoucher> getMyVouchers(Long userId) {
        return userVoucherRepository.findByUserId(userId);
    }
}