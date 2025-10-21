package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.config.VnPayConfig;
import com.example.smart_travel_BE.entity.Payment;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
public class VnPayService { // Đây là class, không phải interface

    public String createPaymentUrl(Payment payment, HttpServletRequest httpServletRequest) {
        long amount = payment.getAmount().longValue() * 100;
        String vnp_TxnRef = payment.getId().toString();
        String vnp_OrderInfo = "Thanh toan don hang " + payment.getBooking().getId();
        String vnp_IpAddr = VnPayConfig.getIpAddress(httpServletRequest);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String vnp_CreateDate = sdf.format(new Date());

        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", VnPayConfig.VNP_VERSION);
        vnp_Params.put("vnp_Command", VnPayConfig.VNP_COMMAND);
        vnp_Params.put("vnp_TmnCode", VnPayConfig.VNP_TMNCODE);
        vnp_Params.put("vnp_Amount", String.valueOf(amount));
        vnp_Params.put("vnp_CurrCode", VnPayConfig.VNP_CURRCODE);
        vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
        vnp_Params.put("vnp_OrderInfo", vnp_OrderInfo);
        vnp_Params.put("vnp_OrderType", "other");
        vnp_Params.put("vnp_Locale", VnPayConfig.VNP_LOCALE);
        vnp_Params.put("vnp_ReturnUrl", VnPayConfig.VNP_RETURNURL);
        vnp_Params.put("vnp_IpAddr", vnp_IpAddr);
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);

        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
        Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();

        try {
            for (String fieldName : fieldNames) {
                String fieldValue = vnp_Params.get(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    hashData.append(fieldName);
                    hashData.append('=');
                    hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()));
                    query.append('=');
                    query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));

                    if (fieldNames.indexOf(fieldName) < fieldNames.size() - 1) {
                        query.append('&');
                        hashData.append('&');
                    }
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to encode URL parameters", e);
        }

        String vnp_SecureHash = VnPayConfig.hmacSHA512(VnPayConfig.VNP_HASHSECRET, hashData.toString());
        return VnPayConfig.VNP_URL + "?" + query.toString() + "&vnp_SecureHash=" + vnp_SecureHash;
    }
}