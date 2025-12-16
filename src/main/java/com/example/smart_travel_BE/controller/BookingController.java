package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.booking.request.BookingRequest;
import com.example.smart_travel_BE.dto.booking.respone.BookingResponse; // Giả định tên gói 'respone'
// --- SỬA IMPORT ---
import com.example.smart_travel_BE.entity.User; // Import entity User
// -----------------
import com.example.smart_travel_BE.service.BookingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    // Endpoint: POST /api/v1/bookings
    @PostMapping
//    // --- SỬA LỖI: Dùng hasAuthority thay vì hasRole ---
//    @PreAuthorize("hasAuthority('USER')")
//    // ------------------------------------------------
    public ResponseEntity<BookingResponse> createBooking(
            @Valid @RequestBody BookingRequest bookingRequest,
            @AuthenticationPrincipal User currentUser
    ) {
        // (Lưu ý: Đảm bảo file BookingService của bạn đã được cập nhật
        // để dùng 'currentUser' như tin nhắn trước)
        BookingResponse bookingResponse = bookingService.createBooking(bookingRequest, currentUser);
        return ResponseEntity.ok(bookingResponse);
    }
}

