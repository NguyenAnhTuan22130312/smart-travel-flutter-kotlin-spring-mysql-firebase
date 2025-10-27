package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.user.request.PaymentRequest;
import com.example.smart_travel_BE.dto.user.response.PaymentUrlResponse;
import com.example.smart_travel_BE.entity.Booking;
import com.example.smart_travel_BE.entity.Payment;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.repository.BookingRepository;
import com.example.smart_travel_BE.repository.PaymentRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j; // THÊM IMPORT NÀY
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;

@Service
@RequiredArgsConstructor // Tự động inject các dependency (final)
@Slf4j // THÊM ANNOTATION NÀY ĐỂ DÙNG 'log'
public class PaymentService { // Đây là class, không phải interface

    private final BookingRepository bookingRepository;
    private final PaymentRepository paymentRepository;
    private final VnPayService vnPayService;
    private final MoMoService moMoService; // Inject MoMoService

    @Transactional
    public PaymentUrlResponse createOnlinePayment(PaymentRequest request, HttpServletRequest httpServletRequest) {
        Booking booking = bookingRepository.findById(Long.parseLong(request.getBookingId()))
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        if (booking.getFinalPrice().compareTo(request.getAmount()) != 0) {
            throw new AppException(ErrorCode.PAYMENT_AMOUNT_MISMATCH);
        }

        Payment payment = new Payment();
        payment.setBooking(booking);
        payment.setAmount(request.getAmount());
        payment.setPaymentMethod(request.getPaymentMethod().toUpperCase());
        payment.setStatus("PENDING");
        payment.setCreatedAt(LocalDateTime.now());
        payment.setUpdatedAt(LocalDateTime.now());
        Payment savedPayment = paymentRepository.save(payment);

        String paymentUrl;
        if ("VNPAY".equalsIgnoreCase(request.getPaymentMethod())) {
            paymentUrl = vnPayService.createPaymentUrl(savedPayment, httpServletRequest);
        } else if ("MOMO".equalsIgnoreCase(request.getPaymentMethod())) {

            // --- SỬA LẠI CHỖ NÀY ---
            // Bỏ comment và gọi MoMoService
            paymentUrl = moMoService.createPaymentUrl(savedPayment);
            // ---------------------

        } else {
            throw new AppException(ErrorCode.PAYMENT_METHOD_NOT_SUPPORTED);
        }

        return new PaymentUrlResponse(paymentUrl);
    }

    @Transactional
    public String confirmCashPayment(PaymentRequest request) {
        Booking booking = bookingRepository.findById(Long.parseLong(request.getBookingId()))
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        if (booking.getFinalPrice().compareTo(request.getAmount()) != 0) {
            throw new AppException(ErrorCode.PAYMENT_AMOUNT_MISMATCH);
        }

        Payment payment = new Payment();
        payment.setBooking(booking);
        payment.setAmount(request.getAmount());
        payment.setPaymentMethod("CASH");
        payment.setStatus("COMPLETED");
        payment.setPaidAt(LocalDateTime.now());
        payment.setCreatedAt(LocalDateTime.now());
        payment.setUpdatedAt(LocalDateTime.now());
        paymentRepository.save(payment);

        booking.setStatus("CONFIRMED");
        booking.setUpdatedAt(LocalDateTime.now());
        bookingRepository.save(booking);

        return booking.getId().toString();
    }

    @Transactional
    public String handleVnPayReturn(HttpServletRequest request) {
        String vnp_TxnRef = request.getParameter("vnp_TxnRef");
        String vnp_ResponseCode = request.getParameter("vnp_ResponseCode");
        String vnp_SecureHash = request.getParameter("vnp_SecureHash");

        // TODO: Xác thực chữ ký (vnp_SecureHash)

        Payment payment = paymentRepository.findById(Long.parseLong(vnp_TxnRef))
                .orElseThrow(() -> new AppException(ErrorCode.PAYMENT_NOT_FOUND));

        if ("00".equals(vnp_ResponseCode)) {
            payment.setStatus("COMPLETED");
            payment.setPaidAt(LocalDateTime.now());
            payment.setTransactionId(request.getParameter("vnp_TransactionNo"));
            paymentRepository.save(payment);

            Booking booking = payment.getBooking();
            booking.setStatus("CONFIRMED");
            bookingRepository.save(booking);

            return "Thanh toán thành công! Bạn có thể quay lại ứng dụng.";
        } else {
            payment.setStatus("FAILED");
            paymentRepository.save(payment);
            return "Thanh toán thất bại. Mã lỗi: " + vnp_ResponseCode;
        }
    }

    // --- THÊM CÁC HÀM XỬ LÝ MOMO CÒN THIẾU ---

    /**
     * Xử lý MoMo IPN (Server-to-Server)
     */
    @Transactional
    public void handleMomoIPN(Map<String, String> momoParams) {
        log.info("Received MoMo IPN: {}", momoParams);

        String orderId = momoParams.get("orderId"); // Đây là Payment ID
        String resultCode = momoParams.get("resultCode");
        String signature = momoParams.get("signature");

        // TODO: 1. Tạo rawSignature từ momoParams (trừ 'signature')
        // TODO: 2. Tính toán signature của riêng bạn
        // TODO: 3. So sánh 2 signature

        // Giả sử signature hợp lệ
        Payment payment = paymentRepository.findById(Long.parseLong(orderId))
                .orElseThrow(() -> new AppException(ErrorCode.PAYMENT_NOT_FOUND));

        if ("0".equals(resultCode)) {
            payment.setStatus("COMPLETED");
            payment.setPaidAt(LocalDateTime.now());
            payment.setTransactionId(momoParams.get("transId")); // Lưu mã GD của MoMo
            paymentRepository.save(payment);

            Booking booking = payment.getBooking();
            booking.setStatus("CONFIRMED");
            bookingRepository.save(booking);

            log.info("MoMo IPN: Payment {} completed successfully.", orderId);
        } else {
            payment.setStatus("FAILED");
            paymentRepository.save(payment);
            log.warn("MoMo IPN: Payment {} failed with resultCode {}", orderId, resultCode);
        }
    }

    /**
     * Xử lý MoMo Redirect URL (Client)
     */
    public String handleMomoReturn(Map<String, String> momoParams) {
        log.info("Received MoMo Return: {}", momoParams);
        String resultCode = momoParams.get("resultCode");

        // TODO: Xác thực chữ ký (giống IPN) để tăng bảo mật

        if ("0".equals(resultCode)) {
            return "Giao dịch MoMo thành công!";
        } else {
            return "Giao dịch MoMo thất bại: " + momoParams.get("message");
        }
    }
}