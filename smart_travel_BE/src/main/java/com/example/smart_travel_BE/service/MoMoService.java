package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.config.MoMoConfig;
import com.example.smart_travel_BE.entity.Payment;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class MoMoService { // Đây là class, không cần interface PaymentGatewayService nữa

    private final RestTemplate restTemplate; // Inject RestTemplate (cần tạo Bean nếu chưa có)
    private final ObjectMapper objectMapper; // Inject ObjectMapper (Spring Boot thường có sẵn)

    public String createPaymentUrl(Payment payment) { // Không cần HttpServletRequest
        String partnerCode = MoMoConfig.PARTNER_CODE;
        String accessKey = MoMoConfig.ACCESS_KEY;
        String secretKey = MoMoConfig.SECRET_KEY;
        String redirectUrl = MoMoConfig.REDIRECT_URL;
        String ipnUrl = MoMoConfig.IPN_URL;

        String requestId = partnerCode + System.currentTimeMillis();
        String orderId = payment.getId().toString(); // Dùng ID của Payment làm orderId MoMo
        String amount = payment.getAmount().toBigInteger().toString(); // MoMo dùng String
        String orderInfo = "Thanh toan don hang " + payment.getBooking().getId();
        String requestType = "captureWallet"; // Loại thanh toán qua ví MoMo
        String extraData = ""; // Dữ liệu thêm (nếu có)
        String lang = "vi"; // Ngôn ngữ hiển thị

        // Tạo raw signature string theo đúng thứ tự MoMo yêu cầu
        // accessKey=$accessKey&amount=$amount&extraData=$extraData&ipnUrl=$ipnUrl&orderId=$orderId&orderInfo=$orderInfo&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=$requestType
        String rawSignature = "accessKey=" + accessKey +
                "&amount=" + amount +
                "&extraData=" + extraData +
                "&ipnUrl=" + ipnUrl +
                "&orderId=" + orderId +
                "&orderInfo=" + orderInfo +
                "&partnerCode=" + partnerCode +
                "&redirectUrl=" + redirectUrl +
                "&requestId=" + requestId +
                "&requestType=" + requestType;

        log.debug("MoMo Raw Signature: {}", rawSignature);

        // Tạo signature
        String signature = MoMoConfig.signHmacSHA256(rawSignature, secretKey);
        log.debug("MoMo Signature: {}", signature);

        // Tạo JSON request body
        Map<String, String> requestBodyMap = new HashMap<>();
        requestBodyMap.put("partnerCode", partnerCode);
        requestBodyMap.put("accessKey", accessKey);
        requestBodyMap.put("requestId", requestId);
        requestBodyMap.put("amount", amount);
        requestBodyMap.put("orderId", orderId);
        requestBodyMap.put("orderInfo", orderInfo);
        requestBodyMap.put("redirectUrl", redirectUrl);
        requestBodyMap.put("ipnUrl", ipnUrl);
        requestBodyMap.put("extraData", extraData);
        requestBodyMap.put("requestType", requestType);
        requestBodyMap.put("signature", signature);
        requestBodyMap.put("lang", lang);

        try {
            String jsonRequestBody = objectMapper.writeValueAsString(requestBodyMap);
            log.debug("MoMo Request Body: {}", jsonRequestBody);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<String> entity = new HttpEntity<>(jsonRequestBody, headers);

            // Gọi API MoMo
            String result = restTemplate.postForObject(MoMoConfig.MOMO_API_URL, entity, String.class);
            log.info("MoMo API Response: {}", result);

            // Parse JSON response để lấy payUrl
            Map<String, Object> responseMap = objectMapper.readValue(result, Map.class);
            if (responseMap.containsKey("payUrl") && responseMap.get("resultCode").equals(0)) {
                return (String) responseMap.get("payUrl");
            } else {
                log.error("Failed to create MoMo payment URL. Response: {}", result);
                throw new RuntimeException("Lỗi khi tạo link thanh toán MoMo: " + responseMap.getOrDefault("message", "Unknown error"));
            }
        } catch (Exception e) {
            log.error("Exception during MoMo API call", e);
            throw new RuntimeException("Lỗi khi gọi API MoMo: " + e.getMessage());
        }
    }

    // TODO: Thêm hàm xử lý IPN (Instant Payment Notification) từ MoMo
    public void handleMomoIPN(Map<String, String> momoParams) {
        // 1. Lấy thông tin từ params (amount, orderId, resultCode, signature...)
        // 2. Tạo raw signature từ các tham số (trừ signature)
        // 3. So sánh signature tính được với signature MoMo gửi về
        // 4. Nếu khớp và resultCode = 0 -> Cập nhật trạng thái Payment và Booking
        // 5. Trả về response cho MoMo (HTTP 204 No Content nếu thành công)
        log.info("Received MoMo IPN: {}", momoParams);
    }
}