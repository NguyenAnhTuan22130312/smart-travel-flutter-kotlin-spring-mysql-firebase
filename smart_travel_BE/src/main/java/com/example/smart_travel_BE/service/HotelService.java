package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.hotel.request.HotelFilterRequest;
import com.example.smart_travel_BE.dto.hotel.response.HotelDetailResponse;
import com.example.smart_travel_BE.dto.hotel.response.HotelResponse;
import com.example.smart_travel_BE.dto.hotel.response.RoomTypeResponse;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.RoomType;
import com.example.smart_travel_BE.mapper.HotelMapper;
import com.example.smart_travel_BE.repository.HotelRepository;
import com.example.smart_travel_BE.repository.RoomTypeRepository;
import com.example.smart_travel_BE.specification.HotelSpecification;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class HotelService {

    @Autowired
    private HotelRepository hotelRepository;

    @Autowired
    private RoomTypeRepository roomTypeRepository;

        /**
         * Lấy danh sách khách sạn có phân trang + filter
         */
        public Page<HotelResponse> getHotels(HotelFilterRequest filter) {
            int page = (filter.getPage() != null && filter.getPage() >= 0) ? filter.getPage() : 0;
            int size = (filter.getSize() != null && filter.getSize() > 0) ? filter.getSize() : 10;

            Sort.Direction direction =
                    "desc".equalsIgnoreCase(filter.getSortDir())
                            ? Sort.Direction.DESC
                            : Sort.Direction.ASC;

            Sort sort = Sort.by(direction, filter.getSortBy());

            Pageable pageable = PageRequest.of(page, size, sort);

            // Specification filter
            var spec = HotelSpecification.filter(filter);
            Page<Hotel> hotelPage = hotelRepository.findAll(spec, pageable);

            // Map sang DTO
            return hotelPage.map(hotel -> HotelResponse.builder()
                    .id(hotel.getId())
                    .name(hotel.getName())
                    .address(hotel.getAddress())
                    .minPrice(hotel.getMinPrice())
                    .stars(hotel.getStarRating())
                    .rating(hotel.getAverageRating() != null ? hotel.getAverageRating().doubleValue() : null)
                    .numOfReviews(hotel.getReviewCount())
                    .thumbnail(hotel.getThumbnail())
                    .destinationId(hotel.getDestination() != null ? hotel.getDestination().getId() : null)
                    .destinationName(hotel.getDestination() != null ? hotel.getDestination().getName() : null)
                    .build());
        }

    /**
     * Lấy chi tiết khách sạn kèm danh sách phòng khả dụng
     */
    @Transactional(readOnly = true)
    public HotelDetailResponse getHotelDetail(Long hotelId, LocalDate checkIn, LocalDate checkOut) {
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy khách sạn có id = " + hotelId));

        // Lấy danh sách phòng và số lượng trống
        List<Object[]> results = roomTypeRepository.findAvailableRoomsWithCount(hotelId, checkIn, checkOut);

        List<RoomTypeResponse> roomResponses = results.stream().map(obj -> {
            RoomType rt = (RoomType) obj[0];
            int available = ((Number) obj[1]).intValue();
            return RoomTypeResponse.builder()
                    .id(rt.getId())
                    .name(rt.getName())
                    .capacity(rt.getCapacity())
                    .price(rt.getPrice())
                    .availableRooms(available)
                    .amenities(rt.getAmenities())
                    .build();
        }).collect(Collectors.toList());

        return HotelDetailResponse.builder()
                .id(hotel.getId())
                .name(hotel.getName())
                .address(hotel.getAddress())
                .description(hotel.getDescription())
                .stars(hotel.getStarRating())
                .rating(hotel.getAverageRating() != null ? hotel.getAverageRating().doubleValue() : null)
                .numOfReviews(hotel.getReviewCount())
                .thumbnail(hotel.getThumbnail())
                .images(hotel.getImages() != null
                        ? hotel.getImages().stream().map(img -> img.getImageUrl()).collect(Collectors.toList())
                        : null)
                .destinationName(hotel.getDestination() != null ? hotel.getDestination().getName() : null)
                .provinceName(
                        hotel.getDestination() != null && hotel.getDestination().getProvince() != null
                                ? hotel.getDestination().getProvince().getName()
                                : null
                )
                .latitude(hotel.getLatitude())
                .longitude(hotel.getLongitude())
                .rooms(roomResponses)
                .build();
    }
}
