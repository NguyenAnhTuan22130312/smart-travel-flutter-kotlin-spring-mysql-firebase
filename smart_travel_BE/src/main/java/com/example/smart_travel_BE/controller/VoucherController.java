package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.entity.Voucher;
import com.example.smart_travel_BE.repository.VoucherRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/vouchers")
@RequiredArgsConstructor
public class VoucherController {

    private final VoucherRepository voucherRepository;

    @GetMapping("/check")
    public ResponseEntity<?> checkVoucher(@RequestParam String code) {
        var voucherOpt = voucherRepository.findByCode(code);

        if (voucherOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Mã giảm giá không tồn tại!"));
        }

        Voucher voucher = voucherOpt.get();
        if (voucher.getExpiryDate().isBefore(LocalDateTime.now())) {
            return ResponseEntity.badRequest().body(Map.of("message", "Mã đã hết hạn!"));
        }

        if (!voucher.getIsActive() || voucher.getUsageLimit() <= 0) {
            return ResponseEntity.badRequest().body(Map.of("message", "Mã không khả dụng!"));
        }

        return ResponseEntity.ok(Map.of(
                "code", voucher.getCode(),
                "discountAmount", voucher.getDiscountAmount(),
                "message", "Áp dụng thành công!"
        ));
    }
}