package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.entity.Booking;
import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.exception.ResourceNotFoundException;
import com.example.smart_travel_BE.dto.booking.request.BookingRequest;
import com.example.smart_travel_BE.dto.booking.respone.BookingResponse;
import com.example.smart_travel_BE.repository.BookingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingRepository bookingRepository;
    // (Giả định bạn có TourRepository và nó đã được @Autowired)
    // private final TourRepository tourRepository;

    @Transactional
    public BookingResponse createBooking(BookingRequest request, User currentUser) {

        // 1. Lấy User (từ token)
        if (currentUser == null) {
            throw new ResourceNotFoundException("User not found (null principal).");
        }

        // --- SỬA THEO Ý BẠN: Dùng tourId từ request ---
        // (Bỏ logic hardcode tourId = 1L)
        Long requestedTourId = request.getTourId();

        // (Bạn nên thêm logic kiểm tra xem Tour ID này có tồn tại không)
        // Tour tour = tourRepository.findById(requestedTourId)
        //        .orElseThrow(() -> new ResourceNotFoundException("Tour not found"));
        // -----------------------------------------

        // 3. Tin tưởng giá `totalPrice` mà Flutter gửi
        BigDecimal finalPrice = request.getTotalPrice();

        // 4. Tạo Booking entity mới
        Booking booking = Booking.builder()
                .user(currentUser)
                .bookingType("TOUR")
                .tourId(requestedTourId) // Dùng ID thật từ request
                .hotelId(null)
                .startDate(request.getStartDate())
                .endDate(request.getStartDate()) // Giả sử tour 1 ngày
                .numberOfPeople(request.getNumberOfPeople())
                .numberOfRooms(0)
                .totalPrice(finalPrice)
                .discountAmount(BigDecimal.ZERO)
                .finalPrice(finalPrice)
                .couponCode(request.getCouponCode())
                .status("PENDING")
                .build();

        // 5. Lưu vào DB
        Booking savedBooking = bookingRepository.save(booking);

        // 6. Trả về Response cho Flutter
        return new BookingResponse(
                savedBooking.getId(), // ID thật
                savedBooking.getFinalPrice(), // Số tiền thật
                "Booking (Tour) created successfully."
        );
    }
}
