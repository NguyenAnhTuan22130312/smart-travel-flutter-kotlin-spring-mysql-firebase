package com.example.smart_travel_BE.config;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Formatter;

public class MoMoConfig {

    public static final String PARTNER_CODE = "MOMO";
    public static final String ACCESS_KEY = "F8BBA842ECF85";
    public static final String SECRET_KEY = "K951B6PE1waDMi640xX08PD3vg6EkVlz";
    public static final String MOMO_API_URL = "https://test-payment.momo.vn/v2/gateway/api/create"; // Endpoint Sandbox
    public static final String REDIRECT_URL = "http://10.0.2.2:8080/api/v1/payment/momo-return";
    public static final String IPN_URL = "https://google.com";

    public static String signHmacSHA256(String data, String secretKey) {
        try {
            Mac sha256_HMAC = Mac.getInstance("HmacSHA256");
            SecretKeySpec secret_key = new SecretKeySpec(secretKey.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            sha256_HMAC.init(secret_key);
            byte[] hash = sha256_HMAC.doFinal(data.getBytes(StandardCharsets.UTF_8));

            Formatter formatter = new Formatter();
            for (byte b : hash) {
                formatter.format("%02x", b);
            }
            return formatter.toString();
        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
            throw new RuntimeException("Failed to generate HMAC-SHA256 signature", e);
        }
    }
}