package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.booking.request.BookingRequest;
import com.example.smart_travel_BE.dto.booking.respone.BookingResponse;
import com.example.smart_travel_BE.entity.*;
import com.example.smart_travel_BE.repository.*;
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
    private final VoucherRepository voucherRepository;
    private final RoomTypeRepository roomTypeRepository;
    private final UserVoucherRepository userVoucherRepository;
    @Transactional
    public BookingResponse createBooking(BookingRequest request, User currentUser) {
        Booking booking = new Booking();
        booking.setUser(currentUser);
        booking.setStartDate(request.getStartDate());
        booking.setNumberOfPeople(request.getNumberOfPeople());
        booking.setStatus("ACTIVE");
        booking.setCreatedAt(LocalDateTime.now());
        booking.setUpdatedAt(LocalDateTime.now());

        BigDecimal totalPrice = BigDecimal.ZERO;

        if ("TOUR".equalsIgnoreCase(request.getBookingType())) {
            Tour tour = tourRepository.findById(request.getTourId())
                    .orElseThrow(() -> new RuntimeException("Tour not found"));

            booking.setBookingType("TOUR");
            booking.setTourId(tour.getId());
            booking.setHotelId(null);
            booking.setNumberOfRooms(0);
            booking.setRoomType(null);

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
            booking.setNumberOfRooms(0);
            booking.setEndDate(request.getEndDate());

            long nights = java.time.temporal.ChronoUnit.DAYS.between(request.getStartDate(), request.getEndDate());
            if (nights <= 0) nights = 1;

            BigDecimal roomPrice;

            if (request.getRoomTypeId() != null) {
                RoomType roomType = roomTypeRepository.findById(request.getRoomTypeId())
                        .orElseThrow(() -> new RuntimeException("Loại phòng không tồn tại (ID: " + request.getRoomTypeId() + ")"));

                if (!roomType.getHotel().getId().equals(hotel.getId())) {
                    throw new RuntimeException("Dữ liệu không hợp lệ: Loại phòng không thuộc khách sạn này!");
                }

                if (roomType.getAvailableRooms() < request.getNumberOfRooms()) {
                    throw new RuntimeException("Loại phòng '" + roomType.getName() + "' chỉ còn " + roomType.getAvailableRooms() + " phòng trống!");
                }

                roomPrice = roomType.getPrice();

                booking.setRoomType(roomType);

                roomType.setAvailableRooms(roomType.getAvailableRooms() - request.getNumberOfRooms());
                roomTypeRepository.save(roomType);

            } else {
                roomPrice = hotel.getMinPrice() != null ? hotel.getMinPrice() : BigDecimal.valueOf(500000);
            }

            totalPrice = roomPrice.multiply(BigDecimal.valueOf(request.getNumberOfRooms()))
                    .multiply(BigDecimal.valueOf(nights));

        } else {
            throw new RuntimeException("Invalid booking type: " + request.getBookingType());
        }

        booking.setTotalPrice(totalPrice);

        BigDecimal discountAmount = BigDecimal.ZERO;
        if (request.getCouponCode() != null && !request.getCouponCode().isEmpty()) {
            Voucher voucher = voucherRepository.findByCode(request.getCouponCode())
                    .orElseThrow(() -> new RuntimeException("Mã giảm giá không hợp lệ"));

            if(voucher.getIsActive() && voucher.getUsageLimit() > 0) {
                if(voucher.getExpiryDate().isAfter(LocalDateTime.now())) {
                    discountAmount = voucher.getDiscountAmount();

                    voucher.setUsageLimit(voucher.getUsageLimit() - 1);
                    voucherRepository.save(voucher);
                    UserVoucher userVoucher = userVoucherRepository
                            .findValidVoucher(currentUser.getId(), request.getCouponCode())
                            .orElseThrow(() -> new RuntimeException("Mã giảm giá không hợp lệ hoặc bạn đã sử dụng rồi!"));

                    userVoucher.setIsUsed(true);
                    userVoucherRepository.save(userVoucher);

                    booking.setCouponCode(request.getCouponCode());
                } else {
                    throw new RuntimeException("Mã giảm giá đã hết hạn");
                }
            } else {
                throw new RuntimeException("Mã giảm giá không khả dụng hoặc đã hết lượt dùng");
            }
        }

        booking.setDiscountAmount(discountAmount);

        BigDecimal finalPrice = totalPrice.subtract(discountAmount);
        if (finalPrice.compareTo(BigDecimal.ZERO) < 0) finalPrice = BigDecimal.ZERO;

        booking.setFinalPrice(finalPrice);
        Booking savedBooking = bookingRepository.save(booking);

        return new BookingResponse(savedBooking.getId(), savedBooking.getFinalPrice(), "Booking created successfully!");
    }
}