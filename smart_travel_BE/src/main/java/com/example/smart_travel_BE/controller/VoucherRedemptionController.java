package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.entity.UserVoucher;
import com.example.smart_travel_BE.entity.Voucher;
import com.example.smart_travel_BE.service.VoucherRedemptionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/rewards")
@RequiredArgsConstructor
public class VoucherRedemptionController {

    private final VoucherRedemptionService redemptionService;

    // 1. Lấy danh sách voucher có thể đổi (Cửa hàng quà tặng)
    @GetMapping("/available")
    public ResponseEntity<List<Voucher>> getAvailableRewards() {
        return ResponseEntity.ok(redemptionService.getRedeemableVouchers());
    }

    // 2. Thực hiện đổi điểm (Người dùng click nút "Đổi quà")
    // Giả sử lấy userId từ Token hoặc RequestParam (để test đơn giản dùng param)
    @PostMapping("/redeem")
    public ResponseEntity<?> redeemVoucher(@RequestParam Long userId, @RequestParam Long voucherId) {
        try {
            UserVoucher uv = redemptionService.redeemVoucher(userId, voucherId);
            return ResponseEntity.ok(Map.of(
                    "message", "Đổi quà thành công!",
                    "voucherCode", uv.getVoucher().getCode(),
                    "remainingPoints", "Xem lại profile để thấy điểm mới"
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    // 3. Xem danh sách voucher của tôi
    @GetMapping("/my-vouchers")
    public ResponseEntity<List<UserVoucher>> getMyVouchers(@RequestParam Long userId) {
        return ResponseEntity.ok(redemptionService.getMyVouchers(userId));
    }
}