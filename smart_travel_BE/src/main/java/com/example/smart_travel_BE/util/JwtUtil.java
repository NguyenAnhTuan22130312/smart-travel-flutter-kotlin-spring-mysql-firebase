package com.example.smart_travel_BE.util;

import com.example.smart_travel_BE.entity.RefreshToken;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.repository.RefreshTokenRepository;
import com.example.smart_travel_BE.repository.UserRepository;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;


import java.security.Key;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;


@Component
@Slf4j
@RequiredArgsConstructor
public class JwtUtil {


    @NonFinal
    @Value("${jwt.signerKey}")
    private String signerKey;

    @NonFinal
    @Value("${jwt.valid-duration}")
    private Long ACCESS_TOKEN_VALIDITY;

    @NonFinal
    @Value("${jwt.refreshable-duration}")
    private Long REFRESH_TOKEN_VALIDITY;

    private final RefreshTokenRepository refreshTokenRepository;
    private final UserRepository userRepository;


    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(signerKey.getBytes());
    }

    public String generateToken(Long userID, Map<String, Object> claims) {
        return createToken(claims, userID, ACCESS_TOKEN_VALIDITY);
    }

    public String generateRefreshToken(Long userID) {
        String refreshToken = createToken(new HashMap<>(), userID, REFRESH_TOKEN_VALIDITY);
        LocalDateTime expiryDate = LocalDateTime.now().plusSeconds(REFRESH_TOKEN_VALIDITY);
        // Tìm user theo USERID
        var user = userRepository.findById(userID)
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        refreshTokenRepository.save(RefreshToken.builder()
                .expiryDate(expiryDate)
                .token(refreshToken)
                .user(user)
                .build());

        return refreshToken;
    }

    private String createToken(Map<String, Object> claims, long subject, long validity) {

        return Jwts.builder()
                .setClaims(claims)
                .setSubject(String.valueOf(subject))
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + validity * 1000))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }


    public String extractSubjectAsUserId(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    public Claims extractAllClaims(String token) {
        return Jwts
                .parser()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token.trim())
                .getBody();

    }

    public Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }
}