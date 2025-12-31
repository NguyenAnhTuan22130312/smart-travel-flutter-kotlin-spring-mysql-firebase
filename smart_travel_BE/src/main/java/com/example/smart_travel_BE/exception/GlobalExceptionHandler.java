package com.example.smart_travel_BE.exception;

import com.example.smart_travel_BE.dto.user.response.APIResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;


@ControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(value = AppException.class)
    ResponseEntity<APIResponse> handleAppException(AppException e) {
        ErrorCode errorCode = e.getErrorCode();
        return ResponseEntity.status(errorCode.getStatusCode()).body(APIResponse.builder()
                .code(errorCode.getCode())
                .msg(errorCode.getMessage())
                .build());
    }

    @ExceptionHandler(value = MethodArgumentNotValidException.class)
    ResponseEntity<APIResponse> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        String enumKey = e.getFieldError().getDefaultMessage();

        ErrorCode errorCode;
        try {
            errorCode = ErrorCode.valueOf(enumKey);
        } catch (IllegalArgumentException ex) {
            errorCode = ErrorCode.INVALID_KEY;
        }

        return ResponseEntity.status(errorCode.getStatusCode()).body(APIResponse.builder()
                .code(errorCode.getCode())
                .msg(errorCode.getMessage())
                .build());

    }

    @ExceptionHandler(value = IllegalArgumentException.class)
    ResponseEntity<APIResponse> handleIllegalArgumentException(IllegalArgumentException e) {
        log.info("Lỗi xảy ra:" + e.getMessage());
        ErrorCode errorCode = ErrorCode.INVALID_KEY;
        return ResponseEntity.status(errorCode.getStatusCode()).body(APIResponse.builder()
                .code(errorCode.getCode())
                .msg(errorCode.getMessage())
                .build());

    }

    @ExceptionHandler(value = AccessDeniedException.class)
    ResponseEntity<APIResponse> handleAccessDeniedException(AccessDeniedException e) {
        ErrorCode errorCode = ErrorCode.UNAUTHORIZED;
        return ResponseEntity.status(errorCode.getStatusCode()).body(APIResponse.builder()
                .code(errorCode.getCode())
                .msg(errorCode.getMessage())
                .build());
    }

    @ExceptionHandler(HttpMediaTypeNotSupportedException.class)
    public ResponseEntity<APIResponse<?>> handleMediaTypeNotSupported(HttpMediaTypeNotSupportedException ex) {
        log.error("Media type not supported: {}", ex.getMessage(), ex);
        log.error("Supported media types: {}", ex.getSupportedMediaTypes());
        return ResponseEntity
                .status(HttpStatus.UNSUPPORTED_MEDIA_TYPE)
                .body(APIResponse.builder()
                        .code(1008)
                        .msg("Unsupported media type: " + ex.getMessage())
                        .build());
    }
}
