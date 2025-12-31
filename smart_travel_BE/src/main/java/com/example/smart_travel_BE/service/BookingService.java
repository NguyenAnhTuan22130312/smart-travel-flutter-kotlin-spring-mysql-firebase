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
    private final RoomTypeRepository roomTypeRepository; // Cần inject repo này

    @Transactional
    public BookingResponse createBooking(BookingRequest request, User currentUser) {
        Booking booking = new Booking();
        booking.setUser(currentUser);
        booking.setStartDate(request.getStartDate());
        booking.setNumberOfPeople(request.getNumberOfPeople());
        booking.setStatus("PENDING");
        booking.setCreatedAt(LocalDateTime.now());
        booking.setUpdatedAt(LocalDateTime.now()); // Thêm dòng này để không null

        BigDecimal totalPrice = BigDecimal.ZERO;

        // ==========================================
        // 1. XỬ LÝ ĐẶT TOUR
        // ==========================================
        if ("TOUR".equalsIgnoreCase(request.getBookingType())) {
            Tour tour = tourRepository.findById(request.getTourId())
                    .orElseThrow(() -> new RuntimeException("Tour not found"));

            booking.setBookingType("TOUR");
            booking.setTourId(tour.getId());
            // Hotel fields null
            booking.setHotelId(null);
            booking.setNumberOfRooms(0);
            booking.setRoomType(null);

            // Tính ngày kết thúc dựa trên duration của tour
            LocalDate endDate = request.getStartDate().plusDays(tour.getDurationDays());
            booking.setEndDate(endDate);

            // Giá = Giá tour * Số người
            totalPrice = tour.getPricePerPerson().multiply(BigDecimal.valueOf(request.getNumberOfPeople()));
        }
        // ==========================================
        // 2. XỬ LÝ ĐẶT HOTEL (Logic quan trọng)
        // ==========================================
        else if ("HOTEL".equalsIgnoreCase(request.getBookingType())) {
            Hotel hotel = hotelRepository.findById(request.getHotelId())
                    .orElseThrow(() -> new RuntimeException("Hotel not found"));

            booking.setBookingType("HOTEL");
            booking.setTourId(null);
            booking.setHotelId(hotel.getId());
            booking.setNumberOfRooms(request.getNumberOfRooms());
            booking.setEndDate(request.getEndDate());

            // Tính số đêm
            long nights = java.time.temporal.ChronoUnit.DAYS.between(request.getStartDate(), request.getEndDate());
            if (nights <= 0) nights = 1;

            BigDecimal roomPrice;

            // --- KIỂM TRA & LẤY THÔNG TIN ROOM TYPE ---
            if (request.getRoomTypeId() != null) {
                // 1. Tìm loại phòng trong DB
                RoomType roomType = roomTypeRepository.findById(request.getRoomTypeId())
                        .orElseThrow(() -> new RuntimeException("Loại phòng không tồn tại (ID: " + request.getRoomTypeId() + ")"));

                // 2. Validate: Phòng này có thuộc khách sạn đang chọn không?
                if (!roomType.getHotel().getId().equals(hotel.getId())) {
                    throw new RuntimeException("Dữ liệu không hợp lệ: Loại phòng không thuộc khách sạn này!");
                }

                // 3. Check Inventory: Còn phòng trống không?
                if (roomType.getAvailableRooms() < request.getNumberOfRooms()) {
                    throw new RuntimeException("Loại phòng '" + roomType.getName() + "' chỉ còn " + roomType.getAvailableRooms() + " phòng trống!");
                }

                // 4. Lấy giá chính xác của phòng
                roomPrice = roomType.getPrice();

                // 5. Set quan hệ (Quan trọng: set Entity chứ không phải set ID)
                booking.setRoomType(roomType);

                // 6. Trừ kho (Giảm số lượng phòng trống)
                roomType.setAvailableRooms(roomType.getAvailableRooms() - request.getNumberOfRooms());
                roomTypeRepository.save(roomType); // Lưu lại số lượng mới

            } else {
                // Trường hợp fallback (ít khi xảy ra nếu FE code đúng)
                // Lấy giá Min làm mặc định
                roomPrice = hotel.getMinPrice() != null ? hotel.getMinPrice() : BigDecimal.valueOf(500000);
            }

            // Tính tổng tiền: Giá phòng * Số phòng * Số đêm
            totalPrice = roomPrice.multiply(BigDecimal.valueOf(request.getNumberOfRooms()))
                    .multiply(BigDecimal.valueOf(nights));

        } else {
            throw new RuntimeException("Invalid booking type: " + request.getBookingType());
        }

        booking.setTotalPrice(totalPrice); // Giá gốc trước khi giảm

        // ==========================================
        // 3. XỬ LÝ VOUCHER (MÃ GIẢM GIÁ)
        // ==========================================
        BigDecimal discountAmount = BigDecimal.ZERO;
        if (request.getCouponCode() != null && !request.getCouponCode().isEmpty()) {
            Voucher voucher = voucherRepository.findByCode(request.getCouponCode())
                    .orElseThrow(() -> new RuntimeException("Mã giảm giá không hợp lệ"));

            // Check hạn sử dụng & số lượng
            if(voucher.getIsActive() && voucher.getUsageLimit() > 0) {
                if(voucher.getExpiryDate().isAfter(LocalDateTime.now())) {
                    discountAmount = voucher.getDiscountAmount();

                    // Trừ số lượng voucher
                    voucher.setUsageLimit(voucher.getUsageLimit() - 1);
                    voucherRepository.save(voucher);

                    booking.setCouponCode(request.getCouponCode());
                } else {
                    throw new RuntimeException("Mã giảm giá đã hết hạn");
                }
            } else {
                throw new RuntimeException("Mã giảm giá không khả dụng hoặc đã hết lượt dùng");
            }
        }

        booking.setDiscountAmount(discountAmount);

        // ==========================================
        // 4. TÍNH GIÁ CUỐI CÙNG (FINAL PRICE)
        // ==========================================
        BigDecimal finalPrice = totalPrice.subtract(discountAmount);
        // Đảm bảo không âm tiền
        if (finalPrice.compareTo(BigDecimal.ZERO) < 0) finalPrice = BigDecimal.ZERO;

        booking.setFinalPrice(finalPrice);

        // Lưu Booking xuống DB
        Booking savedBooking = bookingRepository.save(booking);

        return new BookingResponse(savedBooking.getId(), savedBooking.getFinalPrice(), "Booking created successfully!");
    }
}