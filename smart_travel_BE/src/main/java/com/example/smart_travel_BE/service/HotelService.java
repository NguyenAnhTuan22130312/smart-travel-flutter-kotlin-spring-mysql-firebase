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
     * Trả về trang hotel theo filter request
     */
    public Page<HotelResponse> getHotels(HotelFilterRequest filter) {
        int page = filter.getPage() != null && filter.getPage() >= 0 ? filter.getPage() : 0;
        int size = filter.getSize() != null && filter.getSize() > 0 ? filter.getSize() : 10;

        // sort mặc định theo minPrice asc (bạn có thể expose sort param)
        Sort sort = Sort.by(Sort.Direction.ASC, "minPrice");
        Pageable pageable = PageRequest.of(page, size, sort);

        // --- Dùng Specification để build truy vấn động ---
        var spec = HotelSpecification.filter(filter);
        Page<Hotel> hotelPage = hotelRepository.findAll(spec, pageable);

        // map to HotelResponse
        return hotelPage.map(HotelMapper::toResponse);
    }

    /**
     * Lấy chi tiết khách sạn + phòng trống theo ngày check-in/check-out
     */
    @Transactional(readOnly = true)
    public HotelDetailResponse getHotelDetail(Long hotelId, LocalDate checkIn, LocalDate checkOut) {
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy khách sạn có id = " + hotelId));

        // Lấy danh sách phòng và số lượng còn trống
        List<Object[]> results = roomTypeRepository.findAvailableRoomsWithCount(hotelId, checkIn, checkOut);

        // --- Chuyển từng Object[] thành RoomTypeResponse ---
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

        // --- Build đối tượng phản hồi chứa toàn bộ thông tin khách sạn ---
        return HotelDetailResponse.builder()
                .id(hotel.getId())
                .name(hotel.getName())
                .address(hotel.getAddress())
                .stars(hotel.getStars())
                .rating(calcAverageRating(hotel)) // Tính điểm trung bình đánh giá
                .numOfReviews(hotel.getReviews() != null ? hotel.getReviews().size() : 0)
                .description(hotel.getDescription())
                // Ảnh đại diện của hotel
                .thumbnail(hotel.getImages() != null && !hotel.getImages().isEmpty()
                        ? hotel.getImages().get(0).getUrl() : null)
                // Lấy toàn bộ link ảnh (dạng list<String>)
                .images(hotel.getImages() != null
                        ? hotel.getImages().stream().map(img -> img.getUrl()).collect(Collectors.toList())
                        : null)
                .destinationName(hotel.getDestination() != null ? hotel.getDestination().getName() : null)
                .provinceName(hotel.getDestination() != null && hotel.getDestination().getProvince() != null
                        ? hotel.getDestination().getProvince().getName() : null)
                .rooms(roomResponses) // Danh sách loại phòng còn trống
                .build();
    }

    /**
     * Tính điểm trung bình đánh giá (nếu có review)
     */
    private Double calcAverageRating(Hotel hotel) {
        if (hotel.getReviews() == null || hotel.getReviews().isEmpty()) return null;
        return hotel.getReviews().stream()
                .mapToDouble(r -> r.getRating() != null ? r.getRating() : 0.0)
                .average()
                .orElse(0.0);
    }
}