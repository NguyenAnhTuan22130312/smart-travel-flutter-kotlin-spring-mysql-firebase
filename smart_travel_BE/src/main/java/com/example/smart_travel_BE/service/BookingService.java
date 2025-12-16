package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.entity.Booking;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.Tour;
import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.entity.Voucher; // Import Voucher
import com.example.smart_travel_BE.dto.booking.request.BookingRequest;
import com.example.smart_travel_BE.dto.booking.respone.BookingResponse;
import com.example.smart_travel_BE.repository.BookingRepository;
import com.example.smart_travel_BE.repository.HotelRepository;
import com.example.smart_travel_BE.repository.TourRepository;
import com.example.smart_travel_BE.repository.VoucherRepository; // Import Repo
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
    private final HotelRepository hotelRepository;
    private final VoucherRepository voucherRepository; // Inject thêm cái này

    @Transactional
    public BookingResponse createBooking(BookingRequest request, User currentUser) {
        Booking booking = new Booking();
        booking.setUser(currentUser);
        booking.setStartDate(request.getStartDate());
        booking.setNumberOfPeople(request.getNumberOfPeople());
        booking.setStatus("PENDING");
        booking.setCreatedAt(LocalDateTime.now());

        BigDecimal totalPrice = BigDecimal.ZERO;

        // 1. TÍNH GIÁ GỐC (Logic cũ giữ nguyên)
        if ("TOUR".equalsIgnoreCase(request.getBookingType())) {
            Tour tour = tourRepository.findById(request.getTourId())
                    .orElseThrow(() -> new RuntimeException("Tour not found"));
            booking.setBookingType("TOUR");
            booking.setTourId(tour.getId());
            booking.setHotelId(null);
            booking.setNumberOfRooms(0);
            LocalDate endDate = request.getStartDate().plusDays(tour.getDurationDays());
            booking.setEndDate(endDate);
            totalPrice = tour.getPricePerPerson().multiply(BigDecimal.valueOf(request.getNumberOfPeople()));
        }
        else if ("HOTEL".equalsIgnoreCase(request.getBookingType())) {
            Hotel hotel = hotelRepository.findById(request.getHotelId())
                    .orElseThrow(() -> new RuntimeException("Hotel not found"));
            booking.setBookingType("HOTEL");
            booking.setTourId(null);
            booking.setHotelId(hotel.getId());
            booking.setNumberOfRooms(request.getNumberOfRooms());
            booking.setEndDate(request.getEndDate());
            long nights = java.time.temporal.ChronoUnit.DAYS.between(request.getStartDate(), request.getEndDate());
            if (nights <= 0) nights = 1;
            // Lưu ý: Lấy giá minPrice cho demo, thực tế nên lấy theo RoomType
            BigDecimal roomPrice = hotel.getMinPrice() != null ? hotel.getMinPrice() : BigDecimal.valueOf(500000);
            totalPrice = roomPrice.multiply(BigDecimal.valueOf(request.getNumberOfRooms())).multiply(BigDecimal.valueOf(nights));
        } else {
            throw new RuntimeException("Invalid booking type");
        }

        booking.setTotalPrice(totalPrice); // Giá trước khi giảm

        // 2. XỬ LÝ VOUCHER (Logic MỚI thêm vào)
        BigDecimal discountAmount = BigDecimal.ZERO;
        if (request.getCouponCode() != null && !request.getCouponCode().isEmpty()) {
            Voucher voucher = voucherRepository.findByCode(request.getCouponCode())
                    .orElseThrow(() -> new RuntimeException("Voucher invalid"));

            // Validate lại lần nữa cho chắc
            if(voucher.getIsActive() && voucher.getUsageLimit() > 0) {
                discountAmount = voucher.getDiscountAmount();

                // Trừ số lượng voucher
                voucher.setUsageLimit(voucher.getUsageLimit() - 1);
                voucherRepository.save(voucher);

                booking.setCouponCode(request.getCouponCode());
            }
        }

        booking.setDiscountAmount(discountAmount);

        // 3. TÍNH GIÁ CUỐI CÙNG (Không để âm tiền)
        BigDecimal finalPrice = totalPrice.subtract(discountAmount);
        if (finalPrice.compareTo(BigDecimal.ZERO) < 0) finalPrice = BigDecimal.ZERO;

        booking.setFinalPrice(finalPrice);

        Booking savedBooking = bookingRepository.save(booking);
        return new BookingResponse(savedBooking.getId(), savedBooking.getFinalPrice(), "Booking success!");
    }
}