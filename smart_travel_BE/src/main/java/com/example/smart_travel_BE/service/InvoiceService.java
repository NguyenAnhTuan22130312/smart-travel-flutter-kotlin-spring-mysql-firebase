// src/main/java/com/example/smart_travel_BE/service/InvoiceService.java

package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.invoice.request.CancelOrderRequest;
import com.example.smart_travel_BE.dto.invoice.request.CheckInRequest;
import com.example.smart_travel_BE.dto.invoice.request.CheckOutRequest;
import com.example.smart_travel_BE.dto.invoice.request.RefundApprovalRequest;
import com.example.smart_travel_BE.dto.invoice.response.ActiveInvoiceResponse;
import com.example.smart_travel_BE.dto.invoice.response.AdminInvoiceDetailResponse;
import com.example.smart_travel_BE.dto.invoice.response.AdminInvoiceResponse;
import com.example.smart_travel_BE.dto.invoice.response.InvoiceDetailResponse;
import com.example.smart_travel_BE.entity.*;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.mapper.InvoiceDetailMapper;
import com.example.smart_travel_BE.mapper.InvoiceMapper;
import com.example.smart_travel_BE.repository.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import java.util.List;
import java.math.BigDecimal;
import java.math.RoundingMode;  // ← THÊM IMPORT NÀY
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;        // ← vẫn tên cũ, nhưng query Booking
    private final BookingRepository bookingRepository;
    private final HotelRepository hotelRepository;
    private final TourRepository tourRepository;
    private final RoomTypeRepository roomTypeRepository;
    private final InvoiceMapper invoiceMapper;
    private final InvoiceDetailMapper invoiceDetailMapper;
    private final UserProfileRepository userProfileRepository;


    // 1. Lấy danh sách đơn ĐANG HOẠT ĐỘNG (giữ tên cũ)
    public List<ActiveInvoiceResponse> getActiveInvoices() {
        User curUser = getCurrentUser();
        List<Booking> bookings = invoiceRepository.findActiveInvoicesByUserId(curUser.getId());

        return bookings.stream()
                .map(invoiceMapper::toActiveResponse)
                .toList();
    }

    // 2. Lấy danh sách đơn đã HOÀN TIỀN (giữ tên cũ)
    public List<ActiveInvoiceResponse> getRefundedInvoices() {
        User curUser = getCurrentUser();
        List<Booking> bookings = invoiceRepository.findRefundedInvoices(curUser.getId());
        return bookings.stream().map(invoiceMapper::toActiveResponse).toList();
    }

    // 3. Lấy danh sách đơn có thể ĐÁNH GIÁ
    public List<ActiveInvoiceResponse> getReviewableInvoices() {
        User curUser = getCurrentUser();
        List<Booking> bookings = invoiceRepository.findReviewableInvoices(curUser.getId());
        return bookings.stream().map(invoiceMapper::toActiveResponse).toList();
    }

    // 4. Tìm kiếm đơn đang hoạt động
    public List<ActiveInvoiceResponse> searchActiveInvoices( String keyword) {
        User curUser = getCurrentUser();
        List<Booking> bookings = invoiceRepository.searchActiveInvoices(curUser.getId(), keyword);
        return bookings.stream().map(invoiceMapper::toActiveResponse).toList();
    }

    // 5. Tìm kiếm đơn đã hoàn tiền
    public List<ActiveInvoiceResponse> searchRefundedInvoices( String keyword) {
        User curUser = getCurrentUser();
        List<Booking> bookings = invoiceRepository.searchRefundedInvoices(curUser.getId(), keyword);
        return bookings.stream().map(invoiceMapper::toActiveResponse).toList();
    }

    // 6. Lấy chi tiết 1 đơn theo bookingId (dùng cho màn hình chi tiết)

    public InvoiceDetailResponse getInvoiceDetailFull(Long bookingId) {

        Booking booking = invoiceRepository.findFullBookingById(bookingId)
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        return invoiceDetailMapper.toDetailResponse(booking);
    }


//    public InvoiceDetailResponse getInvoiceDetailFull(Long bookingId) {
//        Booking booking = invoiceRepository.findFullBookingById(bookingId)
//                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));
//
//        Invoice invoice = booking.getInvoice();
//        Payment payment = booking.getPayment();
//        User user = booking.getUser();
//
//        // === Tên dịch vụ chính + ảnh + tiện nghi ===
//        String serviceName = "Dịch vụ không xác định";
//        String thumbnailUrl = null;
//        String roomTypeName = null;
//        List<String> roomAmenities = null;
//        List<String> tourIncluded = null;
//
//        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
//            Long hotelId = booking.getHotelId();
//            if (hotelId != null && hotelId > 0) {
//                Hotel hotel = invoiceRepository.findHotelWithImagesById(hotelId).orElse(null);
//                if (hotel != null) {
//                    serviceName = hotel.getName();
//                    thumbnailUrl = hotel.getThumbnail();
//                }
//            }
//
//            RoomType roomType = booking.getRoomType();
//            if (roomType != null) {
//                roomTypeName = roomType.getName();
//                roomAmenities = parseAmenities(roomType.getAmenities());
//            }
//        }
//        else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
//            Long tourId = booking.getTourId();
//            if (tourId != null && tourId > 0) {
//                Tour tour = invoiceRepository.findTourWithImagesById(tourId).orElse(null);
//                if (tour != null) {
//                    serviceName = tour.getName();
//                    thumbnailUrl = tour.getImages().stream()
//                            .filter(img -> Boolean.TRUE.equals(img.getIsPrimary()))
//                            .findFirst()
//                            .map(TourImage::getImageUrl)
//                            .orElse(tour.getImages().isEmpty() ? null : tour.getImages().get(0).getImageUrl());
//                    tourIncluded = parseAmenities(tour.getIncluded());
//                }
//            }
//        }
//
//        // === Tính nights ===
//        Integer nights = 0;
//        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
//            nights = (int) ChronoUnit.DAYS.between(booking.getStartDate(), booking.getEndDate());
//        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
//            Tour tour = invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null);
//            nights = tour != null && tour.getDurationNights() != null ? tour.getDurationNights() : 0;
//        }
//
//        return InvoiceDetailResponse.builder()
//                .bookingId(booking.getId())
//                .invoiceNumber(invoice != null ? invoice.getInvoiceNumber() : null)
//                .bookingType(booking.getBookingType())
//                .status(booking.getStatus())
//                .createdAt(booking.getCreatedAt())
//                .updatedAt(booking.getUpdatedAt())  // ← Thay cho cancelledAt
//
//                .serviceName(serviceName)
//                .thumbnailUrl(thumbnailUrl)
//                .startDate(booking.getStartDate())
//                .endDate(booking.getEndDate())
//                .nights(nights)
//                .numberOfPeople(booking.getNumberOfPeople())
//                .specialRequests(booking.getSpecialRequests())
//
//                .roomTypeName(roomTypeName)          // null nếu là tour
//                .roomAmenities(roomAmenities)        // null nếu là tour
//                .tourIncluded(tourIncluded)          // null nếu là hotel
//
//                .totalPrice(booking.getTotalPrice())
//                .discountAmount(booking.getDiscountAmount())
//                .finalPrice(booking.getFinalPrice())
//
//                .paymentStatus(payment != null ? payment.getStatus() : null)
//
//                .taxAmount(invoice != null ? invoice.getTaxAmount() : BigDecimal.ZERO)
//
//                .customerName(user != null ? user.getFullName() : "Khách lẻ")
//                .customerPhone(user != null ? user.getPhone() : null)
//                .customerEmail(user != null ? user.getEmail() : null)
//                .build();
//    }
//
//    // Helper parse JSON amenities
//    private List<String> parseAmenities(String json) {
//        if (json == null || json.trim().isEmpty() || "null".equals(json)) {
//            return null;
//        }
//        try {
//            return new ObjectMapper().readValue(json, new TypeReference<List<String>>() {});
//        } catch (Exception e) {
//            // Nếu không phải JSON chuẩn → tách bằng dấu phẩy
//            return Arrays.stream(json.replaceAll("[\\[\\]\"]", "").split(","))
//                    .map(String::trim)
//                    .filter(s -> !s.isEmpty())
//                    .collect(Collectors.toList());
//        }
//    }

    //helper
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getPrincipal() == null) {
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }

        if (authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }

        throw new AppException(ErrorCode.UNAUTHENTICATED);
    }

//    // === Helper: Map Booking → ActiveInvoiceResponse ===
//    private ActiveInvoiceResponse mapToResponse(Booking booking) {
//        Invoice invoice = booking.getInvoice();
//        String invoiceNumber = invoice != null ? invoice.getInvoiceNumber() : "Chưa tạo hóa đơn";
//
//        return ActiveInvoiceResponse.builder()
//                .bookingId(booking.getId())
//                .invoiceNumber(invoiceNumber)
//                .itemName(resolveItemName(booking))
//                .startDate(booking.getStartDate())
//                .endDate(booking.getEndDate())
//                .nights(calculateNights(booking))
//                .status(booking.getStatus())
//                .isReviewed(invoice != null && invoice.isReviewed())  // ← ĐÚNG: lấy từ Invoice!
//                .build();
//    }
//
//    private String resolveItemName(Booking booking) {
//        System.out.println("=== DEBUG ITEM NAME ===");
//        System.out.println("Booking ID: " + booking.getId());
//        System.out.println("Booking Type: " + booking.getBookingType());
//        System.out.println("Hotel ID: " + booking.getHotelId());     // ← In ra xem có null không
//        System.out.println("Tour ID: " + booking.getTourId());       // ← In ra xem có null không
//        System.out.println("========================");
//        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
//            Hotel hotel = hotelRepository.findById(booking.getHotelId()).orElse(null);
//            RoomType roomType = booking.getRoomType();
//            String room = roomType != null ? " - " + roomType.getName() : "";
//            return hotel != null ? hotel.getName() + room : "Khách sạn đã xóa";
//        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
//            Tour tour = tourRepository.findById(booking.getTourId()).orElse(null);
//            return tour != null ? tour.getName() : "Tour đã xóa";
//        }
//        return "Dịch vụ không xác định";
//    }
//
//    private Integer calculateNights(Booking booking) {
//        if (booking.getStartDate() == null || booking.getEndDate() == null) return 0;
//
//        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
//            return (int) ChronoUnit.DAYS.between(booking.getStartDate(), booking.getEndDate());
//        } else { // TOUR
//            Tour tour = tourRepository.findById(booking.getTourId()).orElse(null);
//            return tour != null && tour.getDurationNights() != null
//                    ? tour.getDurationNights()
//                    : (int) ChronoUnit.DAYS.between(booking.getStartDate(), booking.getEndDate()) - 1;
//        }
//    }

    // === Hủy đơn / yêu cầu hoàn tiền ===
    @Transactional
    public void requestRefund( Long bookingId, String reason) {
        User curUser = getCurrentUser();
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        if (!booking.getUser().getId().equals(curUser.getId())) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }
        if (!List.of("ACTIVE").contains(booking.getStatus())) {
            throw new AppException(ErrorCode.REFUND_NOT_ALLOWED);
        }
        if ("PENDING_REFUND".equals(booking.getStatus())) {
            throw new AppException(ErrorCode.REFUND_ALREADY_REQUESTED);
        }

        booking.setStatus("PENDING_REFUND");
        booking.setCancellationReason(reason);
        bookingRepository.save(booking);
    }

    public List<ActiveInvoiceResponse> getTransactionHistory(
            String typeFilter,
            String statusFilter) {

        User curUser = getCurrentUser();

        List<Booking> bookings = invoiceRepository.findTransactionHistory(
                curUser.getId(),
                typeFilter != null && !typeFilter.isEmpty() ? typeFilter.toUpperCase() : null,
                statusFilter != null && !statusFilter.isEmpty() ? statusFilter : null
        );

        return bookings.stream()
                .map(invoiceMapper::toActiveResponse)  // ← hàm bạn đã có sẵn
                .toList();
    }

    public List<AdminInvoiceResponse> getAdminInvoices(String invoiceNumber, String status) {
        User currentUser = getCurrentUser();
        String role = currentUser.getRole();

        List<Booking> bookings = invoiceRepository.findAdminInvoices(
                currentUser.getId(),
                role,
                invoiceNumber,
                status
        );

        return bookings.stream()
                .map(this::mapToAdminResponse)
                .toList();
    }

    private AdminInvoiceResponse mapToAdminResponse(Booking booking) {
        String itemName = "Dịch vụ không xác định";

        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            Hotel hotel = invoiceRepository.findHotelWithImagesById(booking.getHotelId()).orElse(null);
            String hotelName = hotel != null ? hotel.getName() : "Khách sạn đã xóa";
            String roomName = booking.getRoomType() != null ? " - " + booking.getRoomType().getName() : "";
            itemName = hotelName + roomName;
        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            Tour tour = invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null);
            itemName = tour != null ? tour.getName() : "Tour đã xóa";
        }

        Invoice invoice = booking.getInvoice();

        return AdminInvoiceResponse.builder()
                .bookingId(booking.getId())
                .invoiceNumber(invoice != null ? invoice.getInvoiceNumber() : null)
                .itemName(itemName)
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .status(booking.getStatus())
                .build();
    }

    public AdminInvoiceDetailResponse getAdminInvoiceDetail(Long bookingId) {
        User currentUser = getCurrentUser();
        String role = currentUser.getRole();

        // Lấy booking + eager load cần thiết
        Booking booking = invoiceRepository.findFullBookingById(bookingId)
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        Invoice invoice = booking.getInvoice();
        Payment payment = booking.getPayment();

        // KIỂM TRA QUYỀN XEM CHI TIẾT
        if (!role.equals("ADMIN")) {
            if (role.equals("ADMINHOTEL") && "HOTEL".equalsIgnoreCase(booking.getBookingType())) {
                Hotel hotel = invoiceRepository.findHotelWithImagesById(booking.getHotelId()).orElse(null);
                if (hotel == null || !currentUser.getId().equals(hotel.getOwner().getId())) {
                    throw new AppException(ErrorCode.UNAUTHORIZED);
                }
            } else if (role.equals("ADMINTOUR") && "TOUR".equalsIgnoreCase(booking.getBookingType())) {
                Tour tour = invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null);
                if (tour == null || !currentUser.getId().equals(tour.getOwner().getId())) {
                    throw new AppException(ErrorCode.UNAUTHORIZED);
                }
            } else {
                throw new AppException(ErrorCode.UNAUTHORIZED);
            }
        }


        String serviceName = "Dịch vụ không xác định";
        String roomTypeName = null;

        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            Hotel hotel = invoiceRepository.findHotelWithImagesById(booking.getHotelId()).orElse(null);
            serviceName = hotel != null ? hotel.getName() : "Khách sạn đã xóa";
            if (booking.getRoomType() != null) {
                roomTypeName = booking.getRoomType().getName();
            }
        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            Tour tour = invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null);
            serviceName = tour != null ? tour.getName() : "Tour đã xóa";
        }

        User customer = booking.getUser();

        return AdminInvoiceDetailResponse.builder()
                .bookingId(booking.getId())
                .invoiceNumber(invoice != null ? invoice.getInvoiceNumber() : null)
                .status(booking.getStatus())
                .createdAt(booking.getCreatedAt())
                .updatedAt(booking.getUpdatedAt())

                .hotelId(booking.getHotelId())
                .tourId(booking.getTourId())

                .serviceName(serviceName)
                .roomTypeName(roomTypeName)

                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .numberOfPeople(booking.getNumberOfPeople())
                .numberOfRooms(booking.getNumberOfRooms())
                .specialRequests(booking.getSpecialRequests())
                .cancellationReason(booking.getCancellationReason())

                .totalPrice(booking.getTotalPrice())
                .discountAmount(booking.getDiscountAmount())
                .finalPrice(booking.getFinalPrice())

                .paymentStatus(payment != null ? payment.getPayment_status() : null)

                .taxAmount(invoice != null ? invoice.getTaxAmount() : BigDecimal.ZERO)

                .customerName(customer != null ? customer.getFullName() : "Khách lẻ")
                .customerPhone(customer != null ? customer.getPhone() : null)
                .customerEmail(customer != null ? customer.getEmail() : null)
                .build();
    }

    private void validateOwnerPermission(Booking booking, User currentUser) {
        String role = currentUser.getRole();

        // ADMIN không được phép thao tác với hotel/tour
        if ("ADMIN".equals(role)) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        // Chỉ ADMINHOTEL hoặc ADMINTOUR mới được phép
        if (!"ADMINHOTEL".equals(role) && !"ADMINTOUR".equals(role)) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        boolean isOwner = false;

        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            Hotel hotel = invoiceRepository.findHotelWithImagesById(booking.getHotelId()).orElse(null);
            if (hotel != null && currentUser.getId().equals(hotel.getOwner().getId())) {
                isOwner = true;
            }
        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            Tour tour = invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null);
            if (tour != null && currentUser.getId().equals(tour.getOwner().getId())) {
                isOwner = true;
            }
        }

        if (!isOwner) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }
    }

    @Transactional
    public void approveRefund(RefundApprovalRequest request) {
        User currentUser = getCurrentUser();

        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        if (!"PENDING_REFUND".equals(booking.getStatus())) {
            throw new AppException(ErrorCode.REFUND_NOT_PENDING);
        }

        validateOwnerPermission(booking, currentUser);

        booking.setStatus("REFUNDED");
        bookingRepository.save(booking);
    }

    @Transactional
    public void checkIn(CheckInRequest request) {
        User currentUser = getCurrentUser();

        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        // Kiểm tra trạng thái hiện tại phải là ACTIVE
        if (!"ACTIVE".equals(booking.getStatus())) {
            throw new AppException(ErrorCode.INVALID_STATUS); // "Đơn hàng phải ở trạng thái ACTIVE để check-in"
        }

        // KIỂM TRA QUYỀN: Chỉ chủ (owner) của hotel/tour mới được check-in (ADMIN không được)
        boolean isOwner = false;

        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            Hotel hotel = invoiceRepository.findHotelWithImagesById(booking.getHotelId()).orElse(null);
            if (hotel != null && currentUser.getId().equals(hotel.getOwner().getId())) {
                isOwner = true;
            }
        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            Tour tour = invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null);
            if (tour != null && currentUser.getId().equals(tour.getOwner().getId())) {
                isOwner = true;
            }
        }

        if (!isOwner) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        // Cập nhật
        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            booking.setNumberOfRooms(request.getNumberOfRooms());
        }
        booking.setStatus("CHECKED");  // chung cho cả hotel (nhận phòng) và tour (điểm danh/nhận vé)

        bookingRepository.save(booking);
    }

    @Transactional
    public void checkOut(CheckOutRequest request) {
        User currentUser = getCurrentUser();

        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        if (!"CHECKED".equals(booking.getStatus())) {
            throw new AppException(ErrorCode.INVALID_STATUS);
        }

        validateOwnerPermission(booking, currentUser);

        // Chuyển trạng thái sang COMPLETED
        booking.setStatus("COMPLETED");
        bookingRepository.save(booking);

        // === TÍNH EXP CHO KHÁCH HÀNG (NGƯỜI ĐẶT ĐƠN) ===
        User customer = booking.getUser();
        if (customer != null) {
            BigDecimal finalPrice = booking.getFinalPrice();
            long expEarned = finalPrice != null
                    ? finalPrice.divide(new BigDecimal("100000"), RoundingMode.FLOOR).longValue() * 100
                    : 0;

            if (expEarned > 0) {
                // Dùng repository của bạn bè bạn: findByUser
                Optional<UserProfile> profileOpt = userProfileRepository.findByUser(customer);

                UserProfile profile = profileOpt.orElseGet(() -> {
                    UserProfile newProfile = UserProfile.builder()
                            .user(customer)
                            .experiencePoints(0L)
                            .darkModeEnabled(false)
                            .updatedAt(LocalDateTime.now())
                            .build();
                    return userProfileRepository.save(newProfile);
                });

                // Chỉ cộng exp – KHÔNG cập nhật level (bạn bè bạn xử lý ở Flutter)
                profile.setExperiencePoints(profile.getExperiencePoints() + expEarned);
                profile.setUpdatedAt(LocalDateTime.now());

                userProfileRepository.save(profile);
            }
        }
    }

    @Transactional
    public void cancelOrder(CancelOrderRequest request) {
        User currentUser = getCurrentUser();
        String role = currentUser.getRole();
        String fullName = currentUser.getFullName() != null ? currentUser.getFullName() : "Admin";

        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        // Kiểm tra trạng thái hiện tại phải là ACTIVE
        if (!"ACTIVE".equals(booking.getStatus())) {
            throw new AppException(ErrorCode.INVALID_STATUS); // "Chỉ hủy được đơn ở trạng thái ACTIVE"
        }

        // KIỂM TRA QUYỀN HỦY
        boolean canCancel = false;

        if ("ADMIN".equals(role)) {
            canCancel = true;  // ADMIN hủy được mọi đơn
        } else if ("ADMINHOTEL".equals(role) || "ADMINTOUR".equals(role)) {
            // Kiểm tra có phải chủ của hotel/tour không
            if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
                Hotel hotel = invoiceRepository.findHotelWithImagesById(booking.getHotelId()).orElse(null);
                if (hotel != null && currentUser.getId().equals(hotel.getOwner().getId())) {
                    canCancel = true;
                }
            } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
                Tour tour = invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null);
                if (tour != null && currentUser.getId().equals(tour.getOwner().getId())) {
                    canCancel = true;
                }
            }
        }

        if (!canCancel) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        // Tạo cancellationReason theo format
        String cancellationReason = String.format("%s - %s - %s", role, fullName, request.getCancelMessage());

        // Hủy đơn
        booking.setStatus("CANCELLED");
        booking.setCancellationReason(cancellationReason);
        bookingRepository.save(booking);
    }
}