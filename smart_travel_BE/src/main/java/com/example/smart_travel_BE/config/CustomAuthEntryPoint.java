package com.example.smart_travel_BE.config;

import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class CustomAuthEntryPoint implements AuthenticationEntryPoint {
    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException) throws IOException, ServletException {
        ErrorCode errorCode = ErrorCode.UNAUTHORIZED;
        response.setStatus(errorCode.getStatusCode().value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");
        APIResponse<?> apiResponse = APIResponse.builder()
                .code(errorCode.getCode())
                .msg(errorCode.getMessage())
                .build();

        ObjectMapper objectMapper = new ObjectMapper(); // là một công cụ từ thư viện Jackson, được sử dụng để chuyển đổi đối tượng Java sang chuỗi JSON.
        response.getWriter().write(objectMapper.writeValueAsString(apiResponse)); //ApiResponse thành chuỗi JSON và ghi nó vào phản hồi HTTP.
        response.flushBuffer();
    }
}