package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.config.MoMoConfig;
import com.example.smart_travel_BE.entity.Payment;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class MoMoService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public String createPaymentUrl(Payment payment, HttpServletRequest httpServletRequest) {
        long amount = payment.getAmount().longValue();
        String orderId = payment.getId().toString(); // Sử dụng Payment ID làm orderId
        String requestId = UUID.randomUUID().toString(); // Tạo requestId duy nhất

        String partnerCode = MoMoConfig.PARTNER_CODE;
        String accessKey = MoMoConfig.ACCESS_KEY;
        String secretKey = MoMoConfig.SECRET_KEY;
        String returnUrl = MoMoConfig.REDIRECT_URL;
        String ipnUrl = MoMoConfig.IPN_URL;
        String orderInfo = "Thanh toan don hang " + payment.getBooking().getId();
        String requestType = "captureWallet";
        String extraData = ""; // Có thể để trống hoặc thêm thông tin bổ sung

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
        requestBody.put("storeId", "SmartTravelBE"); // Thêm storeId nếu cần

        // 4. Gửi request đến MoMo API
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            String responseJson = restTemplate.postForObject(MoMoConfig.MOMO_API_URL, entity, String.class);

            // 5. Xử lý response từ MoMo
            Map<String, Object> responseMap = objectMapper.readValue(responseJson, Map.class);
            String payUrl = (String) responseMap.get("payUrl");
            String resultCode = String.valueOf(responseMap.get("resultCode"));

            if ("0".equals(resultCode) && payUrl != null) {
                return payUrl;
            } else {
                String message = (String) responseMap.getOrDefault("message", "Lỗi không xác định từ MoMo");
                throw new AppException(ErrorCode.MOMO_CREATE_PAYMENT_FAILED);

            }

        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to process JSON response from MoMo", e);
        } catch (Exception e) {
            // Bao gồm RestClientException
            throw new AppException(ErrorCode.MOMO_API_CALL_FAILED);
        }
    }

    /**
     * Xử lý kết quả trả về từ MoMo sau khi người dùng thanh toán (Redirect URL)
     * Đây là ví dụ đơn giản, bạn cần xử lý phức tạp hơn tùy thuộc vào luồng nghiệp vụ.
     */
    public String handleMoMoReturn(Map<String, String> params) {
        // TODO: Xác thực chữ ký (signature) của MoMo IPN/Return trước khi xử lý
        // Luôn luôn ưu tiên xác thực IPN (Instant Payment Notification) để đảm bảo an toàn

        String orderId = params.get("orderId");
        String resultCode = params.get("resultCode"); // 0: Thành công, > 0: Thất bại

        if (orderId == null || resultCode == null) {
            return "Dữ liệu trả về không hợp lệ.";
        }

        // Lấy Payment từ DB
        // ... (ví dụ tương tự VNPay)

        if ("0".equals(resultCode)) {
            // Cập nhật trạng thái Payment và Booking là COMPLETED/CONFIRMED
            // ... (ví dụ tương tự VNPay)
            return "Thanh toán MoMo thành công! Bạn có thể quay lại ứng dụng.";
        } else {
            // Cập nhật trạng thái Payment là FAILED
            // ... (ví dụ tương tự VNPay)
            String message = params.getOrDefault("message", "Thanh toán thất bại.");
            return "Thanh toán MoMo thất bại. Mã lỗi: " + resultCode + ". " + message;
        }
    }

    /**
     * Xử lý IPN (Instant Payment Notification) - MoMo gọi Server-to-Server
     * Luồng này quan trọng nhất để xác nhận giao dịch.
     */
    public void handleMoMoIpn(Map<String, Object> ipnData) {
        // 1. Lấy thông tin cần thiết
        String orderId = (String) ipnData.get("orderId");
        Long amount = (Long) ipnData.get("amount");
        String resultCode = String.valueOf(ipnData.get("resultCode"));
        String transId = (String) ipnData.get("transId"); // Mã giao dịch của MoMo
        String signature = (String) ipnData.get("signature");

        // 2. **Xác thực chữ ký (QUAN TRỌNG)**
        String partnerCode = (String) ipnData.get("partnerCode");
        String accessKey = (String) ipnData.get("accessKey");
        String orderInfo = (String) ipnData.get("orderInfo");
        String requestId = (String) ipnData.get("requestId");
        String extraData = (String) ipnData.get("extraData");

        String rawSignature = "accessKey=" + accessKey +
                "&amount=" + amount +
                "&extraData=" + extraData +
                "&orderId=" + orderId +
                "&orderInfo=" + orderInfo +
                "&partnerCode=" + partnerCode +
                "&message=" + ipnData.get("message") + // MoMo IPN có thêm message/localMessage
                "&localMessage=" + ipnData.get("localMessage") +
                "&responseTime=" + ipnData.get("responseTime") +
                "&errorCode=" + resultCode + // resultCode trong IPN chính là errorCode
                "&requestId=" + requestId +
                "&requestType=" + ipnData.get("requestType") +
                "&signature=" + signature + // MoMo IPN sử dụng signature trong rawData
                "&transId=" + transId;

        // Cần xem lại chi tiết tài liệu MoMo về chuỗi rawSignature cho IPN để đảm bảo đúng 100%
        // Ví dụ: MoMo sử dụng chuỗi rawSignature khác cho IPN so với API tạo thanh toán.
        // Bạn cần so sánh chữ ký nhận được với chữ ký bạn tự tạo.
        // String calculatedSignature = MoMoConfig.signHmacSHA256(rawSignatureCuaIPN, MoMoConfig.SECRET_KEY);
        // if (!signature.equals(calculatedSignature)) { /* log lỗi và return */ }

        // 3. Xử lý logic
        // Lấy Payment từ DB theo orderId
        // Cập nhật trạng thái dựa trên resultCode
        // Lưu transId
        // Cập nhật Booking status
    }
}