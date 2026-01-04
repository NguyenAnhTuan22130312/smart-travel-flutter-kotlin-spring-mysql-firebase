package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.voucher.VoucherRequest;
import com.example.smart_travel_BE.entity.Voucher;
import com.example.smart_travel_BE.service.AdminVoucherService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/vouchers")
@RequiredArgsConstructor
public class AdminVoucherController {

    private final AdminVoucherService adminVoucherService;

    @GetMapping
    public ResponseEntity<List<Voucher>> getAllVouchers() {
        return ResponseEntity.ok(adminVoucherService.getAllVouchers());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Voucher> getVoucherById(@PathVariable Long id) {
        return ResponseEntity.ok(adminVoucherService.getVoucherById(id));
    }

    @PostMapping
    public ResponseEntity<Voucher> createVoucher(@RequestBody @Valid VoucherRequest request) {
        return ResponseEntity.ok(adminVoucherService.createVoucher(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Voucher> updateVoucher(@PathVariable Long id, @RequestBody @Valid VoucherRequest request) {
        return ResponseEntity.ok(adminVoucherService.updateVoucher(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteVoucher(@PathVariable Long id) {
        adminVoucherService.deleteVoucher(id);
        return ResponseEntity.ok("Xóa Voucher thành công");
    }
}