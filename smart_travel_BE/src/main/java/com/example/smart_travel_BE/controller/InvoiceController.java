// src/main/java/com/example/smart_travel_BE/controller/InvoiceController.java

package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.invoice.request.*;
import com.example.smart_travel_BE.dto.invoice.response.ActiveInvoiceResponse;
import com.example.smart_travel_BE.dto.invoice.response.AdminInvoiceDetailResponse;
import com.example.smart_travel_BE.dto.invoice.response.AdminInvoiceResponse;
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
//    @GetMapping("/active/{userId}")
//    public APIResponse<List<ActiveInvoiceResponse>> getActiveInvoices(
//            @PathVariable("userId") Long userId) {
//        System.out.println(userId);
//        List<ActiveInvoiceResponse> result = invoiceService.getActiveInvoices();
//
//        return APIResponse.<List<ActiveInvoiceResponse>>builder()
//                .code(1000)
//                .msg("Lấy danh sách đơn hàng thành công")
//                .data(result)
//                .build();
//    }

    @GetMapping("/active")
    public APIResponse<List<ActiveInvoiceResponse>> getActiveInvoices() {
        List<ActiveInvoiceResponse> result = invoiceService.getActiveInvoices();

        return APIResponse.<List<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy danh sách đơn hàng thành công")
                .data(result)
                .build();
    }

    // 2. Lấy danh sách đơn đã hoàn tiền
    @GetMapping("/refunded")
    public APIResponse<List<ActiveInvoiceResponse>> getRefundedInvoices() {
        List<ActiveInvoiceResponse> result = invoiceService.getRefundedInvoices();

        return APIResponse.<List<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy danh sách đơn hàng đã hoàn tiền thành công")
                .data(result)
                .build();
    }

    // 3. Lấy danh sách đơn có thể đánh giá
    @GetMapping("/reviewable")
    public APIResponse<List<ActiveInvoiceResponse>> getReviewableInvoices() {
        List<ActiveInvoiceResponse> result = invoiceService.getReviewableInvoices();

        return APIResponse.<List<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy danh sách đơn hàng chờ đánh giá thành công")
                .data(result)
                .build();
    }

    // 4. Tìm kiếm đơn đang hoạt động
    @GetMapping("/active/search")
    public APIResponse<List<ActiveInvoiceResponse>> searchActiveInvoices(
            @RequestParam(required = false, defaultValue = "") String keyword) {
        List<ActiveInvoiceResponse> result = invoiceService.searchActiveInvoices(keyword);

        return APIResponse.<List<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Tìm kiếm đơn hàng thành công")
                .data(result)
                .build();
    }

    // 5. Tìm kiếm đơn đã hoàn tiền
    @GetMapping("/refunded/search")
    public APIResponse<List<ActiveInvoiceResponse>> searchRefundedInvoices(
            @RequestParam(required = false, defaultValue = "") String keyword) {

        List<ActiveInvoiceResponse> result = invoiceService.searchRefundedInvoices(keyword);

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
    @PostMapping("/refund")
    public APIResponse<Void> requestRefund(
            @RequestBody @Valid RefundRequest request) {


        invoiceService.requestRefund(request.getBookingId(), request.getReason());

        return APIResponse.<Void>builder()
                .code(1000)
                .msg("Yêu cầu hoàn tiền đã được gửi thành công! Chúng tôi sẽ xử lý trong vòng 24-48h.")
                .build();
    }

    @GetMapping("/history")
    public APIResponse<List<ActiveInvoiceResponse>> getTransactionHistory(
            @RequestParam(required = false, defaultValue = "ALL") String type,     // ALL, TOUR, HOTEL
            @RequestParam(required = false) String status) {                       // PENDING, ACTIVE, ...

        List<ActiveInvoiceResponse> result = invoiceService.getTransactionHistory(
                "ALL".equalsIgnoreCase(type) ? null : type,
                status
        );

        return APIResponse.<List<ActiveInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy lịch sử giao dịch thành công")
                .data(result)
                .build();
    }

    @GetMapping("/admin-get-invoices")
    public APIResponse<List<AdminInvoiceResponse>> getAdminInvoices(
            @RequestParam(required = false) String invoiceNumber,
            @RequestParam(required = false) String status) {

        List<AdminInvoiceResponse> invoices = invoiceService.getAdminInvoices(invoiceNumber, status);

        return APIResponse.<List<AdminInvoiceResponse>>builder()
                .code(1000)
                .msg("Lấy danh sách đơn hàng thành công")
                .data(invoices)
                .build();
    }

    @GetMapping("/admin-get-detail-invoice/{bookingId}")
    public APIResponse<AdminInvoiceDetailResponse> getAdminInvoiceDetail(@PathVariable Long bookingId) {
        AdminInvoiceDetailResponse detail = invoiceService.getAdminInvoiceDetail(bookingId);

        return APIResponse.<AdminInvoiceDetailResponse>builder()
                .code(1000)
                .msg("Lấy chi tiết đơn hàng thành công")
                .data(detail)
                .build();
    }

    @PostMapping("/admin/approve-refund")
    public APIResponse<Void> approveRefund(@Valid @RequestBody RefundApprovalRequest request) {
        invoiceService.approveRefund(request);

        return APIResponse.<Void>builder()
                .code(1000)
                .msg("Duyệt hoàn tiền thành công. Đơn hàng đã được chuyển sang trạng thái REFUNDED.")
                .build();
    }

    @PostMapping("/admin/check-in")
    public APIResponse<Void> checkIn(@Valid @RequestBody CheckInRequest request) {
        invoiceService.checkIn(request);

        return APIResponse.<Void>builder()
                .code(1000)
                .msg("Check-in thành công. Đơn hàng đã được chuyển sang trạng thái CHECKED và cập nhật số phòng.")
                .build();
    }

    @PostMapping("/admin/check-out")
    public APIResponse<Void> checkOut(@Valid @RequestBody CheckOutRequest request) {
        invoiceService.checkOut(request);

        return APIResponse.<Void>builder()
                .code(1000)
                .msg("Check-out thành công. Đơn hàng đã được chuyển sang trạng thái COMPLETED.")
                .build();
    }

    @PostMapping("/admin/cancel-order")
    public APIResponse<Void> cancelOrder(@Valid @RequestBody CancelOrderRequest request) {
        invoiceService.cancelOrder(request);

        return APIResponse.<Void>builder()
                .code(1000)
                .msg("Hủy đơn hàng thành công. Đơn đã được chuyển sang trạng thái CANCELLED.")
                .build();
    }
}