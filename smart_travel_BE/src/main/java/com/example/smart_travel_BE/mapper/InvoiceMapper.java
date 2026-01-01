package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.invoice.response.ActiveInvoiceResponse;
import com.example.smart_travel_BE.entity.*;
import com.example.smart_travel_BE.repository.HotelRepository;
import com.example.smart_travel_BE.repository.TourRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.temporal.ChronoUnit;

@Component
@RequiredArgsConstructor
public class InvoiceMapper {

    private final HotelRepository hotelRepository;
    private final TourRepository tourRepository;

    /**
     * Booking → ActiveInvoiceResponse
     */
    public ActiveInvoiceResponse toActiveResponse(Booking booking) {
        Invoice invoice = booking.getInvoice();

        return ActiveInvoiceResponse.builder()
                .bookingId(booking.getId())
                .invoiceNumber(invoice != null ? invoice.getInvoiceNumber() : "Chưa tạo hóa đơn")
                .itemName(resolveItemName(booking))
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .nights(calculateNights(booking))
                .status(booking.getStatus())
                .isReviewed(invoice != null && invoice.isReviewed())
                .build();
    }

    /**
     * Resolve tên hiển thị: Hotel / Tour
     */
    private String resolveItemName(Booking booking) {
        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            Hotel hotel = booking.getHotelId() != null
                    ? hotelRepository.findById(booking.getHotelId()).orElse(null)
                    : null;

            RoomType roomType = booking.getRoomType();
            String room = roomType != null ? " - " + roomType.getName() : "";

            return hotel != null
                    ? hotel.getName() + room
                    : "Khách sạn đã xóa";
        }

        if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            Tour tour = booking.getTourId() != null
                    ? tourRepository.findById(booking.getTourId()).orElse(null)
                    : null;

            return tour != null
                    ? tour.getName()
                    : "Tour đã xóa";
        }

        return "Dịch vụ không xác định";
    }

    /**
     * Tính số đêm
     */
    private Integer calculateNights(Booking booking) {
        if (booking.getStartDate() == null || booking.getEndDate() == null) {
            return 0;
        }

        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            return (int) ChronoUnit.DAYS.between(
                    booking.getStartDate(),
                    booking.getEndDate()
            );
        }

        // TOUR
        Tour tour = booking.getTourId() != null
                ? tourRepository.findById(booking.getTourId()).orElse(null)
                : null;

        if (tour != null && tour.getDurationNights() != null) {
            return tour.getDurationNights();
        }

        // fallback
        return Math.max(
                0,
                (int) ChronoUnit.DAYS.between(
                        booking.getStartDate(),
                        booking.getEndDate()
                ) - 1
        );
    }
}
