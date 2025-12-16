// src/main/java/com/example/smart_travel_BE/controller/InvoiceController.java

package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.invoice.request.RefundRequest;
import com.example.smart_travel_BE.dto.invoice.response.ActiveInvoiceResponse;
import com.example.smart_travel_BE.dto.invoice.response.InvoiceDetailResponse;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.service.InvoiceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/invoices")
@RequiredArgsConstructor
public class InvoiceController {

    private final InvoiceService invoiceService;

    // 1. Lấy danh sách đơn hàng đang hoạt động của user
    @GetMapping("/active/{userId}")
    public APIResponse<List<ActiveInvoiceResponse>> getActiveInvoices(
            @PathVariable("userId") Long userId) {
        System.out.println(userId);
        List<ActiveInvoiceResponse> result = invoiceService.getActiveInvoices(userId);

        return APIResponse.<List<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy danh sách đơn hàng thành công")
                .data(result)
                .build();
    }

    // 2. Lấy danh sách đơn đã hoàn tiền
    @GetMapping("/refunded/{userId}")
    public APIResponse<List<ActiveInvoiceResponse>> getRefundedInvoices(
            @PathVariable("userId") Long userId) {
        System.out.println(userId);
        List<ActiveInvoiceResponse> result = invoiceService.getRefundedInvoices(userId);

        return APIResponse.<List<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy danh sách đơn hàng đã hoàn tiền thành công")
                .data(result)
                .build();
    }

    // 3. Lấy danh sách đơn có thể đánh giá
    @GetMapping("/reviewable/{userId}")
    public APIResponse<List<ActiveInvoiceResponse>> getReviewableInvoices(
            @PathVariable("userId") Long userId) {
        System.out.println(userId);
        List<ActiveInvoiceResponse> result = invoiceService.getReviewableInvoices(userId);

        return APIResponse.<List<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy danh sách đơn hàng chờ đánh giá thành công")
                .data(result)
                .build();
    }

    // 4. Tìm kiếm đơn đang hoạt động
    @GetMapping("/active/search/{userId}")
    public APIResponse<List<ActiveInvoiceResponse>> searchActiveInvoices(
            @PathVariable("userId") Long userId,
            @RequestParam(required = false, defaultValue = "") String keyword) {

        List<ActiveInvoiceResponse> result = invoiceService.searchActiveInvoices(userId, keyword);

        return APIResponse.<List<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Tìm kiếm đơn hàng thành công")
                .data(result)
                .build();
    }

    // 5. Tìm kiếm đơn đã hoàn tiền
    @GetMapping("/refunded/search/{userId}")
    public APIResponse<List<ActiveInvoiceResponse>> searchRefundedInvoices(
            @PathVariable("userId") Long userId,
            @RequestParam(required = false, defaultValue = "") String keyword) {

        List<ActiveInvoiceResponse> result = invoiceService.searchRefundedInvoices(userId, keyword);

        return APIResponse.<List<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Tìm kiếm đơn hàng đã hoàn tiền thành công")
                .data(result)
                .build();
    }

    // 6. Chi tiết 1 đơn hàng theo bookingId
    @GetMapping("/detail/{bookingId}")
    public APIResponse<InvoiceDetailResponse> getInvoiceDetail(
            @PathVariable("bookingId") Long bookingId) {

        InvoiceDetailResponse result = invoiceService.getInvoiceDetailFull(bookingId);

        return APIResponse.<InvoiceDetailResponse>builder()
                .code(1000)
                .msg("Lấy chi tiết đơn hàng thành công")
                .data(result)
                .build();
    }

    // 7. Yêu cầu hoàn tiền (dùng bookingId thay vì invoiceNumber cho dễ)
    @PostMapping("/refund/{userId}")
    public APIResponse<Void> requestRefund(
            @PathVariable("userId") long userId,
            @RequestBody @Valid RefundRequest request) {

        // Không cần token → chỉ kiểm tra userId có hợp lệ không (đơn giản cho đồ án)
        if (userId <= 0) {
            return APIResponse.<Void>builder()
                    .code(1007)
                    .msg("User ID không hợp lệ")
                    .build();
        }

        invoiceService.requestRefund(userId, request.getBookingId(), request.getReason());

        return APIResponse.<Void>builder()
                .code(1000)
                .msg("Yêu cầu hoàn tiền đã được gửi thành công! Chúng tôi sẽ xử lý trong vòng 24-48h.")
                .build();
    }

    @GetMapping("/history/{userId}")
    public APIResponse<List<ActiveInvoiceResponse>> getTransactionHistory(
            @PathVariable("userId") long userId,
            @RequestParam(required = false, defaultValue = "ALL") String type,     // ALL, TOUR, HOTEL
            @RequestParam(required = false) String status) {                       // PENDING, ACTIVE, ...

        List<ActiveInvoiceResponse> result = invoiceService.getTransactionHistory(
                userId,
                "ALL".equalsIgnoreCase(type) ? null : type,
                status
        );

        return APIResponse.<List<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy lịch sử giao dịch thành công")
                .data(result)
                .build();
    }
}