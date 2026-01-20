package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.user.request.PaymentRequest;
import com.example.smart_travel_BE.dto.user.response.PaymentUrlResponse;
import com.example.smart_travel_BE.entity.Booking;
import com.example.smart_travel_BE.entity.Invoice;
import com.example.smart_travel_BE.entity.Payment;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.repository.BookingRepository;
import com.example.smart_travel_BE.repository.InvoiceRepository;
import com.example.smart_travel_BE.repository.PaymentRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final BookingRepository bookingRepository;
    private final PaymentRepository paymentRepository;
    private final VnPayService vnPayService;
    private final MoMoService moMoService;
    private final InvoiceRepository invoiceRepository;


    @Transactional
    public PaymentUrlResponse createOnlinePayment(PaymentRequest request, HttpServletRequest httpServletRequest) {

        Booking booking = bookingRepository.findById(Long.parseLong(request.getBookingId()))
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        if (booking.getFinalPrice().compareTo(request.getAmount()) != 0) {
            throw new AppException(ErrorCode.PAYMENT_AMOUNT_MISMATCH);
        }

        Payment payment = paymentRepository.findByBooking_Id(booking.getId()).orElse(null);
        if (payment == null) {
            payment = new Payment();
            payment.setBooking(booking);
            payment.setCreatedAt(LocalDateTime.now());
        }

        payment.setAmount(request.getAmount());
        payment.setPaymentMethod(request.getPaymentMethod().toUpperCase());
        payment.setStatus("PENDING");
        payment.setPayment_status("PENDING");
        payment.setUpdatedAt(LocalDateTime.now());
        Payment savedPayment = paymentRepository.save(payment);

        String paymentUrl;
        if ("VNPAY".equalsIgnoreCase(request.getPaymentMethod())) {
            paymentUrl = vnPayService.createPaymentUrl(savedPayment, httpServletRequest);
        } else if ("MOMO".equalsIgnoreCase(request.getPaymentMethod())) {
            paymentUrl = moMoService.createPaymentUrl(savedPayment, httpServletRequest);
        } else {
            throw new AppException(ErrorCode.PAYMENT_METHOD_NOT_SUPPORTED);
        }

        savedPayment.setStatus("COMPLETED");
        savedPayment.setPayment_status("DONE");
        savedPayment.setPaidAt(LocalDateTime.now());
        savedPayment.setTransactionId("AUTO_SUCCESS_" + System.currentTimeMillis());
        paymentRepository.save(savedPayment);

        booking.setStatus("ACTIVE");
        booking.setUpdatedAt(LocalDateTime.now());
        bookingRepository.save(booking);

        Invoice invoice = invoiceRepository.findByBooking_Id(booking.getId()).orElse(null);
        if (invoice == null) {
            invoice = new Invoice();
            invoice.setBooking(booking);
            invoice.setInvoiceNumber("INV-" + booking.getId() + "-" + System.currentTimeMillis());
            invoice.setTotalAmount(booking.getFinalPrice());
            invoice.setTaxAmount(BigDecimal.ZERO);
            invoice.setIssueDate(LocalDate.now());
            invoice.setItemDetails("{\"note\":\"Auto-created when payment link generated\"}");
            invoice.setReviewed(false);
            invoiceRepository.save(invoice);
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

        Payment payment = paymentRepository.findByBooking_Id(booking.getId()).orElse(new Payment());
        if (payment.getBooking() == null) {
            payment.setBooking(booking);
            payment.setCreatedAt(LocalDateTime.now());
        }
        payment.setAmount(request.getAmount());
        payment.setPaymentMethod("CASH");
        payment.setStatus("COMPLETED");
        payment.setPayment_status("DONE");
        payment.setPaidAt(LocalDateTime.now());
        payment.setUpdatedAt(LocalDateTime.now());
        paymentRepository.save(payment);


        booking.setStatus("ACTIVE");
        booking.setUpdatedAt(LocalDateTime.now());
        bookingRepository.save(booking);

        Invoice invoice = invoiceRepository.findByBooking_Id(booking.getId()).orElse(null);

        if (invoice == null) {
            invoice = new Invoice();
            invoice.setBooking(booking);
            invoice.setInvoiceNumber("INV-CASH-" + booking.getId() + "-" + System.currentTimeMillis());
            invoice.setTotalAmount(booking.getFinalPrice());
            invoice.setTaxAmount(BigDecimal.ZERO);
            invoice.setIssueDate(LocalDate.now());
            invoice.setItemDetails("{\"note\": \"Invoice created automatically at payment step\"}");
        }
        invoice.setReviewed(false);
        invoiceRepository.save(invoice);

        return booking.getId().toString();
    }

    @Transactional
    public String handleVnPayReturn(HttpServletRequest request) {
        String vnp_TxnRef = request.getParameter("vnp_TxnRef");

        if (vnp_TxnRef == null) {
            throw new AppException(ErrorCode.PAYMENT_NOT_FOUND); // Hoặc return lỗi
        }

        Payment payment = paymentRepository.findById(Long.parseLong(vnp_TxnRef))
                .orElseThrow(() -> new AppException(ErrorCode.PAYMENT_NOT_FOUND));

        if ("COMPLETED".equals(payment.getStatus())) {
            return "Giao dịch đã hoàn tất trước đó.";
        }

        payment.setStatus("COMPLETED");
        payment.setPayment_status("DONE");
        payment.setPaidAt(LocalDateTime.now());
        String transactionNo = request.getParameter("vnp_TransactionNo");
        payment.setTransactionId(transactionNo != null ? transactionNo : "TEST_TRANS_ID");

        paymentRepository.save(payment);
        Booking booking = payment.getBooking();
        booking.setStatus("ACTIVE");
        bookingRepository.save(booking);

        Invoice invoice = invoiceRepository.findByBooking_Id(booking.getId()).orElse(null);
        if (invoice == null) {
            invoice = new Invoice();
            invoice.setBooking(booking);
            invoice.setInvoiceNumber("INV-VNPAY-" + booking.getId() + "-" + System.currentTimeMillis());
            invoice.setTotalAmount(booking.getFinalPrice());
            invoice.setTaxAmount(BigDecimal.ZERO);
            invoice.setIssueDate(LocalDate.now());
            invoice.setItemDetails("{\"note\": \"Invoice created via VNPay Return (Auto-Success Mode)\"}");
            invoice.setReviewed(false);
            invoiceRepository.save(invoice);
        }

        return "Thanh toán VNPay thành công (Chế độ Test)!";
    }
    @Transactional
    public String handleMoMoReturn(Map<String, String> params) {
        return moMoService.handleMoMoReturn(params);
    }

}