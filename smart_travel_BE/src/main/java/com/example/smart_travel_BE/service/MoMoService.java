package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.config.MoMoConfig;
import com.example.smart_travel_BE.entity.Booking;
import com.example.smart_travel_BE.entity.Payment;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.repository.BookingRepository;
import com.example.smart_travel_BE.repository.PaymentRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MoMoService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final PaymentRepository paymentRepository; // Cần inject để lưu kết quả trả về
    private final BookingRepository bookingRepository;

    public String createPaymentUrl(Payment payment, HttpServletRequest httpServletRequest) {
        long amount = payment.getAmount().longValue();

        // --- SỬA LỖI TRÙNG ĐƠN HÀNG TẠI ĐÂY ---
        // Format: PaymentID_Timestamp (Ví dụ: 15_170123456789)
        // Đảm bảo mỗi lần bấm thanh toán là một mã duy nhất trên hệ thống MoMo
        String orderId = payment.getId() + "_" + System.currentTimeMillis();
        // --------------------------------------

        String requestId = UUID.randomUUID().toString();

        String partnerCode = MoMoConfig.PARTNER_CODE;
        String accessKey = MoMoConfig.ACCESS_KEY;
        String secretKey = MoMoConfig.SECRET_KEY;
        String returnUrl = MoMoConfig.REDIRECT_URL;
        String ipnUrl = MoMoConfig.IPN_URL;
        String orderInfo = "Thanh toan don hang Booking " + payment.getBooking().getId();
        String requestType = "captureWallet";
        String extraData = "";

        // 1. Tạo rawSignature
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

        // 2. Ký chữ ký
        String signature = MoMoConfig.signHmacSHA256(rawSignature, secretKey);

        // 3. Tạo body request
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

        // 4. Gửi request
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            String responseJson = restTemplate.postForObject(MoMoConfig.MOMO_API_URL, entity, String.class);
            Map<String, Object> responseMap = objectMapper.readValue(responseJson, Map.class);

            // Log response để debug nếu cần
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

    /**
     * Xử lý khi người dùng thanh toán xong và quay lại App (Redirect)
     */
    public String handleMoMoReturn(Map<String, String> params) {
        String orderId = params.get("orderId");
        String resultCode = params.get("resultCode");

        if (orderId == null || resultCode == null) {
            return "Dữ liệu trả về không hợp lệ.";
        }

        // --- XỬ LÝ TÁCH CHUỖI ĐỂ LẤY ID GỐC ---
        // OrderId có dạng: 15_170123456789 -> Cần lấy số 15
        long paymentId;
        try {
            paymentId = Long.parseLong(orderId.split("_")[0]);
        } catch (Exception e) {
            return "Lỗi xử lý mã đơn hàng.";
        }
        // --------------------------------------

        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new AppException(ErrorCode.PAYMENT_NOT_FOUND));

        // Kiểm tra nếu đơn hàng đã hoàn thành rồi thì không xử lý lại
        if ("COMPLETED".equals(payment.getStatus())) {
            return "Giao dịch đã được xử lý trước đó.";
        }

        if ("0".equals(resultCode)) {
            payment.setStatus("COMPLETED");
            payment.setPaidAt(LocalDateTime.now());
            // MoMo trả về transId, lưu lại để đối soát
            if(params.containsKey("transId")) {
                payment.setTransactionId(params.get("transId"));
            }
            paymentRepository.save(payment);

            Booking booking = payment.getBooking();
            booking.setStatus("CONFIRMED");
            bookingRepository.save(booking);

            return "Thanh toán thành công! Bạn có thể quay lại ứng dụng.";
        } else {
            payment.setStatus("FAILED");
            paymentRepository.save(payment);
            return "Thanh toán thất bại. Mã lỗi MoMo: " + resultCode;
        }
    }

    /**
     * Xử lý IPN (Server gọi Server)
     */
    public void handleMoMoIpn(Map<String, Object> ipnData) {
        String orderId = (String) ipnData.get("orderId");
        String resultCode = String.valueOf(ipnData.get("resultCode"));
        String transId = (String) ipnData.get("transId");

        // Tách lấy Payment ID gốc
        long paymentId;
        try {
            paymentId = Long.parseLong(orderId.split("_")[0]);
        } catch (Exception e) {
            System.out.println("Lỗi parse OrderID IPN: " + orderId);
            return;
        }

        Payment payment = paymentRepository.findById(paymentId).orElse(null);
        if (payment == null) return;

        // Nếu đã hoàn thành thì bỏ qua
        if ("COMPLETED".equals(payment.getStatus())) return;

        if ("0".equals(resultCode)) {
            payment.setStatus("COMPLETED");
            payment.setPaidAt(LocalDateTime.now());
            payment.setTransactionId(transId);
            paymentRepository.save(payment);

            Booking booking = payment.getBooking();
            booking.setStatus("CONFIRMED");
            bookingRepository.save(booking);
        } else {
            payment.setStatus("FAILED");
            paymentRepository.save(payment);
        }
    }
}