package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.entity.Booking;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.Tour;
import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.exception.ResourceNotFoundException;
import com.example.smart_travel_BE.dto.booking.request.BookingRequest;
import com.example.smart_travel_BE.dto.booking.respone.BookingResponse;
import com.example.smart_travel_BE.repository.BookingRepository;
import com.example.smart_travel_BE.repository.HotelRepository;
import com.example.smart_travel_BE.repository.TourRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingRepository bookingRepository;
    private final TourRepository tourRepository;
    private final HotelRepository hotelRepository; // Nhớ @Autowired thêm cái này

    @Transactional
    public BookingResponse createBooking(BookingRequest request, User currentUser) {
        Booking booking = new Booking();
        booking.setUser(currentUser);
        booking.setStartDate(request.getStartDate());
        booking.setNumberOfPeople(request.getNumberOfPeople());
        booking.setStatus("PENDING");
        booking.setCreatedAt(LocalDateTime.now());

        BigDecimal finalPrice = BigDecimal.ZERO;

        // --- TRƯỜNG HỢP 1: ĐẶT TOUR ---
        if ("TOUR".equalsIgnoreCase(request.getBookingType())) {
            Tour tour = tourRepository.findById(request.getTourId())
                    .orElseThrow(() -> new RuntimeException("Tour not found"));

            booking.setBookingType("TOUR");
            booking.setTourId(tour.getId());
            booking.setHotelId(null); // Ksan null
            booking.setNumberOfRooms(0);

            // Tự tính ngày kết thúc dựa trên duration của tour
            LocalDate endDate = request.getStartDate().plusDays(tour.getDurationDays());
            booking.setEndDate(endDate);

            // Tính tiền: Giá tour * Số người
            finalPrice = tour.getPricePerPerson().multiply(BigDecimal.valueOf(request.getNumberOfPeople()));
        }

        // --- TRƯỜNG HỢP 2: ĐẶT KHÁCH SẠN ---
        else if ("HOTEL".equalsIgnoreCase(request.getBookingType())) {
            Hotel hotel = hotelRepository.findById(request.getHotelId())
                    .orElseThrow(() -> new RuntimeException("Hotel not found"));

            booking.setBookingType("HOTEL");
            booking.setTourId(null); // Tour null
            booking.setHotelId(hotel.getId());
            booking.setNumberOfRooms(request.getNumberOfRooms());
            booking.setEndDate(request.getEndDate()); // Hotel phải có ngày checkout

            // Tính số đêm
            long nights = java.time.temporal.ChronoUnit.DAYS.between(request.getStartDate(), request.getEndDate());
            if (nights <= 0) nights = 1; // Tối thiểu 1 đêm

            // Giả sử Hotel có field price (hoặc bạn lấy minPrice của RoomType)
            // Ở đây mình ví dụ lấy giá trung bình, thực tế bạn nên chọn RoomType cụ thể
            BigDecimal roomPrice = hotel.getMinPrice();

            // Tính tiền: Giá phòng * Số phòng * Số đêm
            finalPrice = roomPrice
                    .multiply(BigDecimal.valueOf(request.getNumberOfRooms()))
                    .multiply(BigDecimal.valueOf(nights));
        } else {
            throw new RuntimeException("Invalid booking type");
        }

        booking.setTotalPrice(finalPrice);
        booking.setFinalPrice(finalPrice); // Có thể trừ coupon ở đây sau

        Booking savedBooking = bookingRepository.save(booking);

        return new BookingResponse(savedBooking.getId(), savedBooking.getFinalPrice(), "Booking success!");
    }
}