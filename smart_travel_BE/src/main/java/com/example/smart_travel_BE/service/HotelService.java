package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.hotel.request.HotelCreateRequest;
import com.example.smart_travel_BE.dto.hotel.request.HotelFilterRequest;
import com.example.smart_travel_BE.dto.hotel.request.RoomTypeCreateRequest;
import com.example.smart_travel_BE.dto.hotel.response.HotelDetailResponse;
import com.example.smart_travel_BE.dto.hotel.response.HotelResponse;
import com.example.smart_travel_BE.dto.hotel.response.RoomTypeResponse;
import com.example.smart_travel_BE.entity.*;
import com.example.smart_travel_BE.mapper.HotelMapper;
import com.example.smart_travel_BE.repository.*;
import com.example.smart_travel_BE.specification.HotelSpecification;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class HotelService {

    @Autowired
    private HotelRepository hotelRepository;

    @Autowired
    private RoomTypeRepository roomTypeRepository;
    @Autowired
    private DestinationRepository destinationRepository;
    @Autowired
    private ProvinceRepository provinceRepository;
    @Autowired
    private HotelImageRepository hotelImageRepository;
    ObjectMapper mapper = new ObjectMapper();

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
        Specification<Hotel> spec = HotelSpecification.filter(filter);
        // Tạo điều kiện bắt buộc: isActive phải là true
        Specification<Hotel> activeSpec = (root, query, cb) -> cb.equal(root.get("isActive"), true);

        // Gộp điều kiện: (Filter cũ) AND (isActive == true)
        spec = (spec == null) ? activeSpec : spec.and(activeSpec);

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
                .phone(hotel.getPhone())
                .email(hotel.getEmail())
                .description(hotel.getDescription())
                .amenities(convertAmenitiesToList(hotel.getAmenities()))
                .totalRooms(hotel.getTotalRooms())
                .availableRooms(hotel.getAvailableRooms())
                .latitude(hotel.getLatitude())
                .longitude(hotel.getLongitude())
                .build());
    }

    /**
     * Lấy chi tiết khách sạn kèm danh sách phòng khả dụng
     */
    @Transactional(readOnly = true)
    public HotelDetailResponse getHotelDetail(Long hotelId, LocalDate checkIn, LocalDate checkOut) {
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy khách sạn có id = " + hotelId));

        // Kiểm tra nếu khách sạn đã bị xóa mềm
        if (Boolean.FALSE.equals(hotel.getIsActive())) {
            throw new RuntimeException("Khách sạn này đã bị xóa và không còn tồn tại.");
        }
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
                    .amenities(convertAmenitiesToList(rt.getAmenities()))
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
                .pricePerNight(hotel.getPricePerNight())
                .rooms(roomResponses)
                .phone(hotel.getPhone())
                .email(hotel.getEmail())
                .amenities(convertAmenitiesToList(hotel.getAmenities()))
                .destinationId(hotel.getDestination() != null ? hotel.getDestination().getId() : null)
                .build();

    }

    @Transactional
    public HotelDetailResponse createHotel(HotelCreateRequest req) throws JsonProcessingException {

        Destination destination = destinationRepository.findById(req.getDestinationId())
                .orElseThrow(() -> new RuntimeException("Destination not found"));

        Hotel hotel = new Hotel();
        hotel.setName(req.getName());
        hotel.setAddress(req.getAddress());
        hotel.setDescription(req.getDescription());
        hotel.setLatitude(req.getLatitude());
        hotel.setLongitude(req.getLongitude());
        hotel.setStarRating(req.getStars());
        hotel.setDestination(destination);

        hotel.setPhone(req.getPhone());
        hotel.setEmail(req.getEmail());
        hotel.setAmenities(mapper.writeValueAsString(req.getAmenities()));
        hotel.setTotalRooms(req.getTotalRooms());
        hotel.setAvailableRooms(req.getAvailableRooms());

        // [FIX] Set mặc định là ACTIVE khi tạo mới
        hotel.setIsActive(true);

        hotel.setImages(new ArrayList<>());
        hotel.setRoomTypes(new ArrayList<>());

        // ==== Images ====
        int order = 0;

        if (req.getThumbnail() != null && !req.getThumbnail().isBlank()) {
            HotelImage thumb = new HotelImage();
            thumb.setHotel(hotel);
            thumb.setImageUrl(req.getThumbnail());
            thumb.setIsPrimary(true);
            thumb.setDisplayOrder(order++);
            hotel.getImages().add(thumb);
        }

        if (req.getImages() != null) {
            for (String url : req.getImages()) {
                if (url == null || url.isBlank()) continue;

                HotelImage img = new HotelImage();
                img.setHotel(hotel);
                img.setImageUrl(url);
                img.setIsPrimary(false);
                img.setDisplayOrder(order++);
                hotel.getImages().add(img);
            }
        }

        // ==== Room Types ====
        BigDecimal minPrice = null;

        if (req.getRoomTypes() != null) {
            for (RoomTypeCreateRequest rtReq : req.getRoomTypes()) {

                RoomType rt = new RoomType();
                rt.setHotel(hotel);
                rt.setName(rtReq.getName());
                rt.setCapacity(rtReq.getCapacity());
                rt.setPrice(rtReq.getPrice());
                rt.setTotalRooms(rtReq.getTotalRooms());
                rt.setAmenities(mapper.writeValueAsString(rtReq.getAmenities()));
                hotel.getRoomTypes().add(rt);

                if (minPrice == null || rtReq.getPrice().compareTo(minPrice) < 0) {
                    minPrice = rtReq.getPrice();
                }
            }
        }

        hotel.setPricePerNight(minPrice);
        hotelRepository.save(hotel);
        return HotelMapper.toDetailResponse(hotel);
    }

    @Transactional
    public HotelDetailResponse updateHotel(Long hotelId, HotelCreateRequest req) throws JsonProcessingException {
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new RuntimeException("Hotel not found"));

        Destination destination = destinationRepository.findById(req.getDestinationId())
                .orElseThrow(() -> new RuntimeException("Destination not found"));

        // === Cập nhật thông tin cơ bản ===
        hotel.setName(req.getName());
        hotel.setAddress(req.getAddress());
        hotel.setDescription(req.getDescription());
        hotel.setLatitude(req.getLatitude());
        hotel.setLongitude(req.getLongitude());
        hotel.setStarRating(req.getStars());
        hotel.setDestination(destination);
        hotel.setPhone(req.getPhone());
        hotel.setEmail(req.getEmail());
        hotel.setAmenities(mapper.writeValueAsString(req.getAmenities()));
        hotel.setTotalRooms(req.getTotalRooms());
        hotel.setAvailableRooms(req.getAvailableRooms());

        // === Xử lý hình ảnh ===
        hotel.getImages().clear();
        int order = 0;
        if (req.getThumbnail() != null && !req.getThumbnail().isBlank()) {
            HotelImage thumb = new HotelImage();
            thumb.setHotel(hotel);
            thumb.setImageUrl(req.getThumbnail());
            thumb.setIsPrimary(true);
            thumb.setDisplayOrder(order++);
            hotel.getImages().add(thumb);
        }
        if (req.getImages() != null) {
            for (String url : req.getImages()) {
                if (url == null || url.isBlank()) continue;
                HotelImage img = new HotelImage();
                img.setHotel(hotel);
                img.setImageUrl(url);
                img.setIsPrimary(false);
                img.setDisplayOrder(order++);
                hotel.getImages().add(img);
            }
        }

        // === Xử lý Room Types ===
        hotel.getRoomTypes().clear();
        BigDecimal minPrice = null;
        if (req.getRoomTypes() != null) {
            for (RoomTypeCreateRequest rtReq : req.getRoomTypes()) {
                RoomType rt = new RoomType();
                rt.setHotel(hotel);
                rt.setName(rtReq.getName());
                rt.setCapacity(rtReq.getCapacity());
                rt.setPrice(rtReq.getPrice());
                rt.setTotalRooms(rtReq.getTotalRooms());
                rt.setAmenities(mapper.writeValueAsString(rtReq.getAmenities()));
                hotel.getRoomTypes().add(rt);

                if (minPrice == null || rtReq.getPrice().compareTo(minPrice) < 0) {
                    minPrice = rtReq.getPrice();
                }
            }
        }
        hotel.setPricePerNight(minPrice);

        hotelRepository.save(hotel);

        return HotelMapper.toDetailResponse(hotel);
    }

    @Transactional
    public void deleteHotel(Long hotelId) {
        // 1. Dùng findById
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new RuntimeException("Hotel not found with id: " + hotelId));

        // 2. Kiểm tra logic: Nếu đã bị xóa (isActive == false) thì báo lỗi
        if (Boolean.FALSE.equals(hotel.getIsActive())) {
            throw new RuntimeException("Hotel is already deleted");
        }

        // 3. Set trạng thái active = false (Xóa ẩn)
        hotel.setIsActive(false);

        // 4. Lưu thay đổi
        hotelRepository.save(hotel);
    }

    private List<String> convertAmenitiesToList(String jsonAmenities) {
        if (jsonAmenities == null || jsonAmenities.isBlank()) {
            return new ArrayList<>();
        }
        try {
            // Parse chuỗi "['a','b']" thành List ["a","b"]
            return mapper.readValue(jsonAmenities, new TypeReference<List<String>>() {});
        } catch (JsonProcessingException e) {
            // Nếu lỗi (hoặc dữ liệu cũ không phải JSON), trả về list chứa chuỗi gốc
            return Collections.singletonList(jsonAmenities);
        }
    }
}