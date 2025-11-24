package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.invoice.response.ActiveInvoiceResponse;
import com.example.smart_travel_BE.entity.*;
import com.example.smart_travel_BE.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final BookingRepository bookingRepository;
    private final HotelRepository hotelRepository;
    private final TourRepository tourRepository; // bạn cần tạo repo này nếu chưa có
    private final RoomTypeRepository roomTypeRepository;

    public Page<ActiveInvoiceResponse> getActiveInvoices(Long userId, Pageable pageable) {
        Page<Invoice> invoicePage = invoiceRepository.findActiveInvoicesByUserId(userId, pageable);

        return invoicePage.map(invoice -> {
            Booking booking = invoice.getBooking();

            String itemName = resolveItemName(booking);
            String thumbnailUrl = resolveThumbnail(booking);
            Integer nights = calculateNights(booking);

            return ActiveInvoiceResponse.builder()
                    .invoiceId(invoice.getId())
                    .invoiceNumber(invoice.getInvoiceNumber())
                    .itemName(itemName)
                    .startDate(booking.getStartDate())
                    .endDate(booking.getEndDate())
                    .nights(nights)
                    .status(booking.getStatus())
                    .isReviewed(invoice.isReviewed())
                    .build();
        });
    }

    private String resolveItemName(Booking booking) {
        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            Hotel hotel = hotelRepository.findById(booking.getHotelId()).orElse(null);
            RoomType roomType = booking.getRoomType();
            String room = roomType != null ? " - " + roomType.getName() : "";
            return hotel != null ? hotel.getName() + room : "Khách sạn đã xóa";
        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            Tour tour = tourRepository.findById(booking.getTourId()).orElse(null);
            return tour != null ? tour.getName() : "Tour đã xóa";
        }
        return "Không xác định";
    }

    private String resolveThumbnail(Booking booking) {
        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            Hotel hotel = hotelRepository.findById(booking.getHotelId()).orElse(null);
            return hotel != null ? hotel.getThumbnail() : null;
        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            Tour tour = tourRepository.findById(booking.getTourId()).orElse(null);
            if (tour != null && !tour.getImages().isEmpty()) {
                return tour.getImages().stream()
                        .filter(TourImage::getIsPrimary)
                        .findFirst()
                        .map(TourImage::getImageUrl)
                        .orElse(tour.getImages().get(0).getImageUrl());
            }
        }
        return null;
    }

    private Integer calculateNights(Booking booking) {
        if (booking.getEndDate() == null || booking.getStartDate() == null) return 0;

        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            return (int) ChronoUnit.DAYS.between(booking.getStartDate(), booking.getEndDate());
        } else { // TOUR
            Tour tour = tourRepository.findById(booking.getTourId()).orElse(null);
            return tour != null ? tour.getDurationNights() : 0;
        }
    }

    public Page<ActiveInvoiceResponse> getInvoicesByStatus(Long userId, List<String> statuses, Pageable pageable) {
        Page<Invoice> invoicePage = invoiceRepository.findRefundedInvoices(userId,  pageable);

        return invoicePage.map(this::mapToActiveResponse);
    }

    public Page<ActiveInvoiceResponse> getReviewableInvoices(Long userId, Pageable pageable) {
        Page<Invoice> invoicePage = invoiceRepository.findReviewableInvoices(userId, pageable);
        return invoicePage.map(this::mapToActiveResponse);
    }

    // Helper chung để map (tránh lặp code)
    private ActiveInvoiceResponse mapToActiveResponse(Invoice invoice) {
        Booking booking = invoice.getBooking();
        String itemName = resolveItemName(booking);
        Integer nights = calculateNights(booking);

        return ActiveInvoiceResponse.builder()
                .invoiceId(invoice.getId())
                .invoiceNumber(invoice.getInvoiceNumber())
                .itemName(itemName)
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .nights(nights)
                .status(booking.getStatus())
                .isReviewed(invoice.isReviewed())
                .build();
    }
}