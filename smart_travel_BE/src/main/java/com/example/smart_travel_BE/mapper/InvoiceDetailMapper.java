package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.invoice.response.InvoiceDetailResponse;
import com.example.smart_travel_BE.entity.*;
import com.example.smart_travel_BE.repository.InvoiceRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class InvoiceDetailMapper {

    private final InvoiceRepository invoiceRepository;

    public InvoiceDetailResponse toDetailResponse(Booking booking) {

        Invoice invoice = booking.getInvoice();
        Payment payment = booking.getPayment();
        User user = booking.getUser();

        ServiceInfo serviceInfo = resolveServiceInfo(booking);
        Integer nights = calculateNights(booking);

        return InvoiceDetailResponse.builder()
                .bookingId(booking.getId())
                .invoiceNumber(invoice != null ? invoice.getInvoiceNumber() : null)
                .bookingType(booking.getBookingType())
                .status(booking.getStatus())
                .createdAt(booking.getCreatedAt())
                .updatedAt(booking.getUpdatedAt())

                .hotelId("HOTEL".equalsIgnoreCase(booking.getBookingType()) ? booking.getHotelId() : null)
                .tourId("TOUR".equalsIgnoreCase(booking.getBookingType()) ? booking.getTourId() : null)

                .serviceName(serviceInfo.serviceName())
                .thumbnailUrl(serviceInfo.thumbnailUrl())
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .nights(nights)
                .numberOfPeople(booking.getNumberOfPeople())
                .specialRequests(booking.getSpecialRequests())

                .roomTypeName(serviceInfo.roomTypeName())
                .roomAmenities(serviceInfo.roomAmenities())

                .totalPrice(booking.getTotalPrice())
                .discountAmount(booking.getDiscountAmount())
                .finalPrice(booking.getFinalPrice())

                .paymentStatus(payment != null ? payment.getStatus() : null)
                .taxAmount(invoice != null ? invoice.getTaxAmount() : BigDecimal.ZERO)

                .customerName(user != null ? user.getFullName() : "Khách lẻ")
                .customerPhone(user != null ? user.getPhone() : null)
                .customerEmail(user != null ? user.getEmail() : null)
                .build();
    }

    /* ================= PRIVATE METHODS ================= */

    private ServiceInfo resolveServiceInfo(Booking booking) {

        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            Hotel hotel = booking.getHotelId() != null
                    ? invoiceRepository.findHotelWithImagesById(booking.getHotelId()).orElse(null)
                    : null;

            RoomType roomType = booking.getRoomType();

            return new ServiceInfo(
                    hotel != null ? hotel.getName() : "Khách sạn đã xóa",
                    hotel != null ? hotel.getThumbnail() : null,
                    roomType != null ? roomType.getName() : null,
                    roomType != null ? parseAmenities(roomType.getAmenities()) : null,
                    null
            );
        }

        if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            Tour tour = booking.getTourId() != null
                    ? invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null)
                    : null;

            String thumbnail = null;
            if (tour != null && tour.getImages() != null) {
                thumbnail = tour.getImages().stream()
                        .filter(img -> Boolean.TRUE.equals(img.getIsPrimary()))
                        .findFirst()
                        .map(TourImage::getImageUrl)
                        .orElse(
                                tour.getImages().isEmpty()
                                        ? null
                                        : tour.getImages().get(0).getImageUrl()
                        );
            }

            return new ServiceInfo(
                    tour != null ? tour.getName() : "Tour đã xóa",
                    thumbnail,
                    null,
                    null,
                    tour != null ? parseAmenities(tour.getIncluded()) : null
            );
        }

        return new ServiceInfo("Dịch vụ không xác định", null, null, null, null);
    }

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

        if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            Tour tour = booking.getTourId() != null
                    ? invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null)
                    : null;

            return tour != null && tour.getDurationNights() != null
                    ? tour.getDurationNights()
                    : 0;
        }

        return 0;
    }

    // Helper parse amenities – PHIÊN BẢN HOÀN HẢO, KHÔNG LỖI
    private List<String> parseAmenities(String amenitiesJson) {
        if (amenitiesJson == null || amenitiesJson.trim().isEmpty() || "null".equals(amenitiesJson.trim())) {
            return null; // hoặc return List.of() nếu muốn mảng rỗng
        }

        try {
            // Cách chuẩn nhất: dùng ObjectMapper parse JSON array → List<String>
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(amenitiesJson, new TypeReference<List<String>>() {});
        } catch (JsonProcessingException e) {
            // Nếu JSON sai định dạng → fallback: tách bằng dấu phẩy + loại bỏ ký tự thừa
            return Arrays.stream(amenitiesJson
                            .replaceAll("[\\[\\]\"]", "")  // bỏ [, ], "
                            .split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toList());
        }
    }

    /* ================= INNER RECORD ================= */

    private record ServiceInfo(
            String serviceName,
            String thumbnailUrl,
            String roomTypeName,
            List<String> roomAmenities,
            List<String> tourIncluded
    ) {}
}
