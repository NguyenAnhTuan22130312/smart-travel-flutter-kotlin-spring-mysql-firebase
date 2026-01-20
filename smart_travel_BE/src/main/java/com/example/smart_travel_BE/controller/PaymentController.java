package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.user.request.PaymentRequest;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.dto.user.response.PaymentUrlResponse;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.service.PaymentService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.Map;

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
    public void vnpayReturn(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String resultMsg = paymentService.handleVnPayReturn(request);

            String vnp_TxnRef = request.getParameter("vnp_TxnRef");

            String deepLink = "smarttravel://payment-result?status=success&paymentId=" + vnp_TxnRef;

            response.sendRedirect(deepLink);

        } catch (Exception e) {
            response.sendRedirect("smarttravel://payment-result?status=failed&msg=" + e.getMessage());
        }
    }

    @GetMapping("/momo-return")
    public ResponseEntity<String> momoReturn(@RequestParam Map<String, String> params) {
        log.info("KHÁCH HÀNG ĐÃ QUAY VỀ TỪ MOMO");
        try {
            String message = paymentService.handleMoMoReturn(params);
            return ResponseEntity.ok(message);
        } catch (AppException e) {
            log.error("Lỗi khi xử lý MoMo return: {}", e.getMessage());
            return ResponseEntity.status(e.getErrorCode().getStatusCode()).body(e.getMessage());
        }
    }

    @PostMapping("/momo-ipn")
    public ResponseEntity<?> momoIpn(@RequestBody Map<String, Object> ipnData) {
        try {
            log.info("MoMo IPN received: {}", ipnData);
            return null;
        } catch (Exception e) {
            log.error("Lỗi khi xử lý MoMo IPN: {}", e.getMessage());
            return ResponseEntity.status(500).body("Error processing IPN: " + e.getMessage());
        }
    }
}