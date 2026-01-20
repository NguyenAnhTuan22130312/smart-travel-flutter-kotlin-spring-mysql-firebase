package com.example.smart_travel_BE.config;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import jakarta.servlet.http.HttpServletRequest;
import java.nio.charset.StandardCharsets;
import java.util.Formatter;

public class VnPayConfig {

    public static final String VNP_TMNCODE = "8R491IOR";
    public static final String VNP_HASHSECRET = "7CKJLL1YUR6T5ROB5T7RPJ0S6AYNVJXE";
    public static final String VNP_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

    public static final String VNP_VERSION = "2.1.0";
    public static final String VNP_COMMAND = "pay";
    public static final String VNP_CURRCODE = "VND";
    public static final String VNP_LOCALE = "vn";

    public static final String VNP_RETURNURL = "http://10.0.2.2:8080/api/v1/payment/vnpay-return";

    public static String hmacSHA512(final String key, final String data) {
        try {
            if (key == null || data == null) throw new NullPointerException();
            final Mac hmac512 = Mac.getInstance("HmacSHA512");
            byte[] hmacKeyBytes = key.getBytes(StandardCharsets.UTF_8);
            final SecretKeySpec secretKey = new SecretKeySpec(hmacKeyBytes, "HmacSHA512");
            hmac512.init(secretKey);
            byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
            byte[] result = hmac512.doFinal(dataBytes);

            Formatter formatter = new Formatter();
            for (byte b : result) {
                formatter.format("%02x", b);
            }
            return formatter.toString();
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate HMAC-SHA512", e);
        }
    }

    public static String getIpAddress(HttpServletRequest request) {
        String ipAddress;
        try {
            ipAddress = request.getHeader("X-FORWARDED-FOR");
            if (ipAddress == null) {
                ipAddress = request.getRemoteAddr();
            }
        } catch (Exception e) {
            ipAddress = "Invalid IP:" + e.getMessage();
        }

        if ("0:0:0:0:0:0:0:1".equals(ipAddress) || "127.0.0.1".equals(ipAddress)) {
            ipAddress = "118.69.183.92";
        }
        return ipAddress;
    }
}