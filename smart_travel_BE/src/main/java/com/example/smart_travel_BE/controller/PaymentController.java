package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.user.request.PaymentRequest;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.dto.user.response.PaymentUrlResponse;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.service.PaymentService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/payment")
@RequiredArgsConstructor
@Slf4j
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/create-online-payment")
    public ResponseEntity<APIResponse<PaymentUrlResponse>> createOnlinePayment(
            @Valid @RequestBody PaymentRequest request,
            HttpServletRequest httpServletRequest) {

        try {
            PaymentUrlResponse response = paymentService.createOnlinePayment(request, httpServletRequest);
            return ResponseEntity.ok(APIResponse.<PaymentUrlResponse>builder()
                    .msg("Tạo link thanh toán thành công")
                    .data(response)
                    .build());
        } catch (AppException e) {
            log.error("Tạo link thanh toán thất bại: {}", e.getMessage());
            return ResponseEntity.status(e.getErrorCode().getStatusCode()).body(
                    APIResponse.<PaymentUrlResponse>builder()
                            .msg(e.getMessage())
                            .build());
        }
    }

    @PostMapping("/confirm-cash-payment")
    public ResponseEntity<APIResponse<String>> confirmCashPayment(
            @Valid @RequestBody PaymentRequest request) {

        try {
            String bookingId = paymentService.confirmCashPayment(request);
            return ResponseEntity.ok(APIResponse.<String>builder()
                    .msg("Xác nhận thanh toán tiền mặt thành công")
                    .data("Đơn hàng ID: " + bookingId)
                    .build());
        } catch (AppException e) {
            log.error("Xác nhận thanh toán tiền mặt thất bại: {}", e.getMessage());
            return ResponseEntity.status(e.getErrorCode().getStatusCode()).body(
                    APIResponse.<String>builder()
                            .msg(e.getMessage())
                            .build());
        }
    }

    @GetMapping("/vnpay-return")
    public ResponseEntity<String> vnpayReturn(HttpServletRequest request) {
        try {
            String message = paymentService.handleVnPayReturn(request);
            return ResponseEntity.ok(message);
        } catch (AppException e) {
            log.error("Lỗi khi xử lý VNPay return: {}", e.getMessage());
            return ResponseEntity.status(e.getErrorCode().getStatusCode()).body(e.getMessage());
        }
    }
}