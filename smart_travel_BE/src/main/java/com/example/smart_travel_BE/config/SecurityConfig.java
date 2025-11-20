package com.example.smart_travel_BE.config;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Configuration
@RequiredArgsConstructor
@EnableMethodSecurity
@EnableWebSecurity
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class SecurityConfig {
    String[] PUBLIC_ENDPOINTS = new String[]{"/api/v1/auth/register", "/api/v1/auth/verify-email",
            "/api/v1/auth/resend-verification", "/api/v1/auth/login","/api/v1/auth/login/admin", "/api/v1/auth/logout/admin", "/api/v1/auth/refresh", "/api/v1/auth/forgot-password",
            "/api/v1/auth/reset-password", "/api/v1/auth/check-reset-password", "/api/v1/destination/destination-featured",
            "/api/v1/destination/destination-all", "/api/v1/destination/destination-filter", "/api/v1/destination/detail/{id}",
            "/api/v1/province/popular", "/api/v1/payment/vnpay-return","/api/v1/payment/momo-return",
            "/api/v1/chat",
            "/api/v1/payment/momo-ipn", "/api/v1/hotels", "/api/v1/hotels/{id}/detail",
            "/api/v1/province/all", "/api/v1/province/detail/{provinceId}"
            ,"/api/v1/auth/google-login", "/api/v1/auth/facebook-login", "/api/v1/payment/vnpay-return",
            "/api/v1/hotels/{hotelId}/images", "/api/v1/hotels/{hotelId}/images/upload", "/api/v1/hotels/{hotelId}/images/upload-multiple",
    };

    CustomAuthEntryPoint customAuthEntryPoint;
    UserHeaderAuthenticationFilter userHeaderAuthenticationFilter;
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(PUBLIC_ENDPOINTS).permitAll()
                        .requestMatchers("/verify-success.html", "/verify-fail.html","/reset-password.html").permitAll()
                        .anyRequest().authenticated()
                )
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .addFilterBefore(userHeaderAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint(customAuthEntryPoint)
                )
                .build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    // Tạo CorsFilter
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();

        config.setAllowCredentials(true);
        config.setAllowedOriginPatterns(List.of("http://localhost:5173"));

        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));

        config.setExposedHeaders(List.of("Set-Cookie"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

}
