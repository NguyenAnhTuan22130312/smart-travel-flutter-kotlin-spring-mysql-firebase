package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.config.MoMoConfig;
import com.example.smart_travel_BE.entity.Booking;
import com.example.smart_travel_BE.entity.Invoice;
import com.example.smart_travel_BE.entity.Payment;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.repository.BookingRepository;
import com.example.smart_travel_BE.repository.InvoiceRepository;
import com.example.smart_travel_BE.repository.PaymentRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MoMoService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final PaymentRepository paymentRepository;
    private final BookingRepository bookingRepository;
    private final InvoiceRepository invoiceRepository;

    public String createPaymentUrl(Payment payment, HttpServletRequest httpServletRequest) {
        long amount = payment.getAmount().longValue();

        String orderId = payment.getId() + "_" + System.currentTimeMillis();

        String requestId = UUID.randomUUID().toString();

        String partnerCode = MoMoConfig.PARTNER_CODE;
        String accessKey = MoMoConfig.ACCESS_KEY;
        String secretKey = MoMoConfig.SECRET_KEY;
        String returnUrl = MoMoConfig.REDIRECT_URL;
        String ipnUrl = MoMoConfig.IPN_URL;
        String orderInfo = "Thanh toan don hang Booking " + payment.getBooking().getId();
        String requestType = "captureWallet";
        String extraData = "";

        // Tạo rawSignature
        String rawSignature = "accessKey=" + accessKey +
                "&amount=" + amount +
                "&extraData=" + extraData +
                "&ipnUrl=" + ipnUrl +
                "&orderId=" + orderId +
                "&orderInfo=" + orderInfo +
                "&partnerCode=" + partnerCode +
                "&redirectUrl=" + returnUrl +
                "&requestId=" + requestId +
                "&requestType=" + requestType;

        // Ký chữ ký
        String signature = MoMoConfig.signHmacSHA256(rawSignature, secretKey);

        // Tạo body request
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("partnerCode", partnerCode);
        requestBody.put("accessKey", accessKey);
        requestBody.put("requestId", requestId);
        requestBody.put("amount", amount);
        requestBody.put("orderId", orderId);
        requestBody.put("orderInfo", orderInfo);
        requestBody.put("redirectUrl", returnUrl);
        requestBody.put("ipnUrl", ipnUrl);
        requestBody.put("requestType", requestType);
        requestBody.put("extraData", extraData);
        requestBody.put("signature", signature);
        requestBody.put("lang", "vi");
        requestBody.put("storeId", "SmartTravelBE");

        // Gửi request
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            String responseJson = restTemplate.postForObject(MoMoConfig.MOMO_API_URL, entity, String.class);
            Map<String, Object> responseMap = objectMapper.readValue(responseJson, Map.class);

            System.out.println("MoMo Response: " + responseJson);

            String payUrl = (String) responseMap.get("payUrl");
            String resultCode = String.valueOf(responseMap.get("resultCode"));

            if ("0".equals(resultCode) && payUrl != null) {
                return payUrl;

            } else {
                throw new AppException(ErrorCode.MOMO_CREATE_PAYMENT_FAILED);
            }
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Lỗi xử lý JSON từ MoMo", e);
        } catch (Exception e) {
            throw new AppException(ErrorCode.MOMO_API_CALL_FAILED);
        }
    }

    @Transactional
    public String handleMoMoReturn(Map<String, String> params) {
        String orderId = params.get("orderId");

        long paymentId = Long.parseLong(orderId.split("_")[0]);
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new AppException(ErrorCode.PAYMENT_NOT_FOUND));

        if ("COMPLETED".equals(payment.getStatus())) {
            return "Giao dịch đã hoàn tất trước đó.";
        }

        payment.setStatus("COMPLETED");
        payment.setPayment_status("DONE");
        payment.setPaidAt(LocalDateTime.now());
        payment.setTransactionId(params.get("transId"));
        paymentRepository.save(payment);

        Booking booking = payment.getBooking();
        booking.setStatus("ACTIVE");
        bookingRepository.save(booking);

        Invoice invoice = new Invoice();
        invoice.setBooking(booking);
        invoice.setInvoiceNumber("INV-" + booking.getId() + "-" + System.currentTimeMillis());
        invoice.setTotalAmount(booking.getFinalPrice());
        invoice.setIssueDate(LocalDate.now());

        invoiceRepository.save(invoice);

        return "Success";
    }
}