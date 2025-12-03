// src/main/java/com/example/smart_travel_BE/service/InvoiceService.java

package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.invoice.response.ActiveInvoiceResponse;
import com.example.smart_travel_BE.dto.invoice.response.InvoiceDetailResponse;
import com.example.smart_travel_BE.entity.*;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.repository.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.temporal.ChronoUnit;
import java.util.List;

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

    // 1. Lấy danh sách đơn ĐANG HOẠT ĐỘNG (giữ tên cũ)
    public List<ActiveInvoiceResponse> getActiveInvoices(Long userId) {
        List<Booking> bookings = invoiceRepository.findActiveInvoicesByUserId(userId);

        return bookings.stream()
                .map(this::mapToResponse)
                .toList();
    }

    // 2. Lấy danh sách đơn đã HOÀN TIỀN (giữ tên cũ)
    public List<ActiveInvoiceResponse> getRefundedInvoices(Long userId) {
        List<Booking> bookings = invoiceRepository.findRefundedInvoices(userId);
        return bookings.stream().map(this::mapToResponse).toList();
    }

    // 3. Lấy danh sách đơn có thể ĐÁNH GIÁ
    public List<ActiveInvoiceResponse> getReviewableInvoices(Long userId) {
        List<Booking> bookings = invoiceRepository.findReviewableInvoices(userId);
        return bookings.stream().map(this::mapToResponse).toList();
    }

    // 4. Tìm kiếm đơn đang hoạt động
    public List<ActiveInvoiceResponse> searchActiveInvoices(Long userId, String keyword) {
        List<Booking> bookings = invoiceRepository.searchActiveInvoices(userId, keyword);
        return bookings.stream().map(this::mapToResponse).toList();
    }

    // 5. Tìm kiếm đơn đã hoàn tiền
    public List<ActiveInvoiceResponse> searchRefundedInvoices(Long userId, String keyword) {
        List<Booking> bookings = invoiceRepository.searchRefundedInvoices(userId, keyword);
        return bookings.stream().map(this::mapToResponse).toList();
    }

    // 6. Lấy chi tiết 1 đơn theo bookingId (dùng cho màn hình chi tiết)
    public InvoiceDetailResponse getInvoiceDetailFull(Long bookingId) {
        Booking booking = invoiceRepository.findFullBookingById(bookingId)
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        Invoice invoice = booking.getInvoice();
        Payment payment = booking.getPayment();
        User user = booking.getUser();

        // === Tên + ảnh + tiện nghi ===
        String itemName = "Dịch vụ không xác định";
        String thumbnailUrl = null;
        String amenitiesSummary = null;

        if ("HOTEL".equalsIgnoreCase(booking.getBookingType()) && booking.getHotelId() != null) {
            Hotel hotel = invoiceRepository.findHotelWithImagesById(booking.getHotelId()).orElse(null);
            if (hotel != null) {
                itemName = hotel.getName();
                thumbnailUrl = hotel.getThumbnail();
                if (booking.getRoomType() != null) {
                    itemName += " - " + booking.getRoomType().getName();
                    amenitiesSummary = formatAmenities(booking.getRoomType().getAmenities());
                }
                if (amenitiesSummary == null && hotel.getAmenities() != null) {
                    amenitiesSummary = formatAmenities(hotel.getAmenities());
                }
            }
        }
        else if ("TOUR".equalsIgnoreCase(booking.getBookingType()) && booking.getTourId() != null) {
            Tour tour = invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null);
            if (tour != null) {
                itemName = tour.getName();
                thumbnailUrl = tour.getImages().stream()
                        .filter(img -> Boolean.TRUE.equals(img.getIsPrimary()))
                        .findFirst()
                        .map(TourImage::getImageUrl)
                        .orElse(tour.getImages().isEmpty() ? null : tour.getImages().get(0).getImageUrl());
                amenitiesSummary = formatAmenities(tour.getIncluded());
            }
        }

        // === Tính nights ===
        Integer nights = 0;
        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            nights = (int) ChronoUnit.DAYS.between(booking.getStartDate(), booking.getEndDate());
        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType()) && booking.getTourId() != null) {
            Tour tour = invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null);
            nights = tour != null ? tour.getDurationNights() : 0;
        }

        return InvoiceDetailResponse.builder()
                .bookingId(booking.getId())
                .invoiceNumber(invoice != null ? invoice.getInvoiceNumber() : null)
                .bookingType(booking.getBookingType())
                .status(booking.getStatus())
                .createdAt(booking.getCreatedAt())

                .itemName(itemName)
                .thumbnailUrl(thumbnailUrl)
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .nights(nights)
                .numberOfPeople(booking.getNumberOfPeople())

                .totalPrice(booking.getTotalPrice())
                .discountAmount(booking.getDiscountAmount())
                .finalPrice(booking.getFinalPrice())

                .paymentStatus(payment != null ? payment.getStatus() : null)

                .taxAmount(invoice != null ? invoice.getTaxAmount() : BigDecimal.ZERO)
                .itemDetailsJson(invoice != null ? invoice.getItemDetails() : null)
                .issueDate(invoice != null ? invoice.getIssueDate() : null)

                .isReviewed(invoice != null && invoice.isReviewed())
                .cancelledAt("PENDING_REFUND".equals(booking.getStatus()) ? booking.getUpdatedAt() : null)

                .customerName(user != null ? user.getFullName() : "Khách lẻ")
                .customerPhone(user != null ? user.getPhone() : null)
                .customerEmail(user != null ? user.getEmail() : null)

                .amenitiesSummary(amenitiesSummary)
                .specialRequests(booking.getSpecialRequests())
                .build();
    }

    // Helper để chuyển JSON → "Wifi · Hồ bơi · ..."
    private String formatAmenities(String json) {
        if (json == null || json.trim().isEmpty() || "null".equals(json)) return null;
        try {
            String[] items = new ObjectMapper().readValue(json, String[].class);
            return String.join(" · ", items);
        } catch (Exception e) {
            return json.replace(",", " · ").replace("[", "").replace("]", "").replace("\"", "");
        }
    }

    // === Helper: Map Booking → ActiveInvoiceResponse ===
    private ActiveInvoiceResponse mapToResponse(Booking booking) {
        Invoice invoice = booking.getInvoice();
        String invoiceNumber = invoice != null ? invoice.getInvoiceNumber() : "Chưa tạo hóa đơn";

        return ActiveInvoiceResponse.builder()
                .bookingId(booking.getId())
                .invoiceNumber(invoiceNumber)
                .itemName(resolveItemName(booking))
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .nights(calculateNights(booking))
                .status(booking.getStatus())
                .isReviewed(invoice != null && invoice.isReviewed())  // ← ĐÚNG: lấy từ Invoice!
                .build();
    }

    private String resolveItemName(Booking booking) {
        System.out.println("=== DEBUG ITEM NAME ===");
        System.out.println("Booking ID: " + booking.getId());
        System.out.println("Booking Type: " + booking.getBookingType());
        System.out.println("Hotel ID: " + booking.getHotelId());     // ← In ra xem có null không
        System.out.println("Tour ID: " + booking.getTourId());       // ← In ra xem có null không
        System.out.println("========================");
        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            Hotel hotel = hotelRepository.findById(booking.getHotelId()).orElse(null);
            RoomType roomType = booking.getRoomType();
            String room = roomType != null ? " - " + roomType.getName() : "";
            return hotel != null ? hotel.getName() + room : "Khách sạn đã xóa";
        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            Tour tour = tourRepository.findById(booking.getTourId()).orElse(null);
            return tour != null ? tour.getName() : "Tour đã xóa";
        }
        return "Dịch vụ không xác định";
    }

    private Integer calculateNights(Booking booking) {
        if (booking.getStartDate() == null || booking.getEndDate() == null) return 0;

        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            return (int) ChronoUnit.DAYS.between(booking.getStartDate(), booking.getEndDate());
        } else { // TOUR
            Tour tour = tourRepository.findById(booking.getTourId()).orElse(null);
            return tour != null && tour.getDurationNights() != null
                    ? tour.getDurationNights()
                    : (int) ChronoUnit.DAYS.between(booking.getStartDate(), booking.getEndDate()) - 1;
        }
    }

    // === Hủy đơn / yêu cầu hoàn tiền ===
    @Transactional
    public void requestRefund(Long userId, Long bookingId, String reason) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        if (!booking.getUser().getId().equals(userId)) {
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
            Long userId,
            String typeFilter,     // "ALL", "TOUR", "HOTEL"
            String statusFilter) { // "PENDING", "ACTIVE", ...

        List<Booking> bookings = invoiceRepository.findTransactionHistory(
                userId,
                typeFilter != null && !typeFilter.isEmpty() ? typeFilter.toUpperCase() : null,
                statusFilter != null && !statusFilter.isEmpty() ? statusFilter : null
        );

        return bookings.stream()
                .map(this::mapToResponse)  // ← hàm bạn đã có sẵn
                .toList();
    }
}