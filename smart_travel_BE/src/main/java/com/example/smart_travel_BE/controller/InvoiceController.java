// src/main/java/com/example/smart_travel_BE/controller/InvoiceController.java

package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.invoice.response.ActiveInvoiceResponse;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.service.InvoiceService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/invoices")
@RequiredArgsConstructor
public class InvoiceController {

    private final InvoiceService invoiceService;

    @GetMapping("/active")
    public APIResponse<Page<ActiveInvoiceResponse>> getActiveInvoices(
            @AuthenticationPrincipal User user, // ← đổi từ UserDetails thành entity User
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Long userId = user.getId();

        var pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());

        Page<ActiveInvoiceResponse> result = invoiceService.getActiveInvoices(userId, pageable);

        return APIResponse.<Page<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy danh sách đơn hàng thành công")
                .data(result)
                .build();
    }

    /**
     * Lấy danh sách đơn hàng đã được HOÀN TIỀN (chỉ REFUNDED, không lấy CANCELLED)
     */
    @GetMapping("/refunded")
    public APIResponse<Page<ActiveInvoiceResponse>> getRefundedInvoices(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        if (user == null) {
            return APIResponse.<Page<ActiveInvoiceResponse>>builder()
                    .code(1007)
                    .msg("Unauthorized")
                    .build();
        }

        var pageable = PageRequest.of(page, size, Sort.by("booking.createdAt").descending());

        Page<ActiveInvoiceResponse> result = invoiceService.getInvoicesByStatus(
                user.getId(), List.of("REFUNDED"), pageable);

        return APIResponse.<Page<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy danh sách đơn hàng đã hoàn tiền thành công")
                .data(result)
                .build();
    }

    @GetMapping("/reviewable")
    public APIResponse<Page<ActiveInvoiceResponse>> getReviewableInvoices(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        if (user == null) { /* ... */ }

        var pageable = PageRequest.of(page, size, Sort.by("booking.createdAt").descending());

        Page<ActiveInvoiceResponse> result = invoiceService.getReviewableInvoices(user.getId(), pageable);

        return APIResponse.<Page<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy danh sách đơn hàng chờ đánh giá thành công")
                .data(result)
                .build();
    }
}