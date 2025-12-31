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
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
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
    @Autowired
    private UserRepository userRepository;

    ObjectMapper mapper = new ObjectMapper();

    //Lấy danh sách khách sạn có phân trang + filter
    public Page<HotelResponse> getHotels(HotelFilterRequest filter) {
        int page = (filter.getPage() != null && filter.getPage() >= 0) ? filter.getPage() : 0;
        int size = (filter.getSize() != null && filter.getSize() > 0) ? filter.getSize() : 10;

        Sort.Direction direction = "desc".equalsIgnoreCase(filter.getSortDir()) ? Sort.Direction.DESC : Sort.Direction.ASC;

        Sort sort = Sort.by(direction, filter.getSortBy());
        Pageable pageable = PageRequest.of(page, size, sort);

        // 1. LẤY USER_ID TỪ SECURITY CONTEXT
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        Long currentUserId = null;
        boolean isHotelAdmin = false;

        if (auth != null && auth.isAuthenticated()) {
            if (auth.getPrincipal() instanceof com.example.smart_travel_BE.entity.User user) {
                currentUserId = user.getId();
            }
            System.out.println("Authorities thực tế: " + auth.getAuthorities());
            isHotelAdmin = auth.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMINHOTEL"));
        }

        // 2. Khởi tạo Spec
        Specification<Hotel> spec = HotelSpecification.filter(filter);

        // 3. ĐIỀU KIỆN CHUNG: isActive = true
        Specification<Hotel> activeSpec = (root, query, cb) -> cb.equal(root.get("isActive"), true);
        spec = (spec == null) ? activeSpec : spec.and(activeSpec);

        // 4. NẾU LÀ ADMIN_HOTEL: Ép lọc theo ownerId (Số Long)
        Specification<Hotel> ownerSpec = null;
        if (isHotelAdmin && currentUserId != null) {
            final Long finalUserId = currentUserId;

            ownerSpec = (root, query, cb) -> cb.equal(root.get("owner").get("id"), finalUserId);

            spec = spec.and(ownerSpec);
        }
        Page<Hotel> hotelPage = hotelRepository.findAll(spec, pageable);
        System.out.println("Final currentUserId: " + currentUserId);
        System.out.println("Is Hotel Admin: " + isHotelAdmin);

        // 5. Map sang DTO (Giữ nguyên logic của bạn)
        return hotelPage.map(hotel -> HotelResponse.builder().id(hotel.getId()).name(hotel.getName()).address(hotel.getAddress()).minPrice(hotel.getMinPrice()).stars(hotel.getStarRating()).rating(hotel.getAverageRating() != null ? hotel.getAverageRating().doubleValue() : null).numOfReviews(hotel.getReviewCount()).thumbnail(hotel.getThumbnail()).destinationId(hotel.getDestination() != null ? hotel.getDestination().getId() : null).destinationName(hotel.getDestination() != null ? hotel.getDestination().getName() : null).phone(hotel.getPhone()).email(hotel.getEmail()).description(hotel.getDescription()).amenities(convertAmenitiesToList(hotel.getAmenities())).totalRooms(hotel.getTotalRooms()).availableRooms(hotel.getAvailableRooms()).latitude(hotel.getLatitude()).longitude(hotel.getLongitude()).build());
    }

    // Lấy chi tiết khách sạn kèm danh sách phòng khả dụng
    @Transactional(readOnly = true)
    public HotelDetailResponse getHotelDetail(Long hotelId, LocalDate checkIn, LocalDate checkOut) {
        Hotel hotel = hotelRepository.findById(hotelId).orElseThrow(() -> new RuntimeException("Không tìm thấy khách sạn có id = " + hotelId));

        // Kiểm tra nếu khách sạn đã bị xóa mềm
        if (Boolean.FALSE.equals(hotel.getIsActive())) {
            throw new RuntimeException("Khách sạn này đã bị xóa và không còn tồn tại.");
        }
        // Lấy danh sách phòng và số lượng trống
        List<Object[]> results = roomTypeRepository.findAvailableRoomsWithCount(hotelId, checkIn, checkOut);

        List<RoomTypeResponse> roomResponses = results.stream().map(obj -> {
            RoomType rt = (RoomType) obj[0];
            int available = ((Number) obj[1]).intValue();
            return RoomTypeResponse.builder().id(rt.getId()).name(rt.getName()).capacity(rt.getCapacity()).price(rt.getPrice()).availableRooms(available).amenities(convertAmenitiesToList(rt.getAmenities())).build();
        }).collect(Collectors.toList());

        return HotelDetailResponse.builder().id(hotel.getId()).name(hotel.getName()).address(hotel.getAddress()).description(hotel.getDescription()).stars(hotel.getStarRating()).rating(hotel.getAverageRating() != null ? hotel.getAverageRating().doubleValue() : null).numOfReviews(hotel.getReviewCount()).thumbnail(hotel.getThumbnail()).images(hotel.getImages() != null ? hotel.getImages().stream().map(img -> img.getImageUrl()).collect(Collectors.toList()) : null).destinationName(hotel.getDestination() != null ? hotel.getDestination().getName() : null).provinceName(hotel.getDestination() != null && hotel.getDestination().getProvince() != null ? hotel.getDestination().getProvince().getName() : null).latitude(hotel.getLatitude()).longitude(hotel.getLongitude()).pricePerNight(hotel.getPricePerNight()).rooms(roomResponses).phone(hotel.getPhone()).email(hotel.getEmail()).amenities(convertAmenitiesToList(hotel.getAmenities())).destinationId(hotel.getDestination() != null ? hotel.getDestination().getId() : null).build();

    }

    @Transactional
    public HotelDetailResponse createHotel(HotelCreateRequest req) throws JsonProcessingException {
        // 1. Lấy email của User đang đăng nhập từ SecurityContext
        String currentUserEmail = getCurrentUserEmail();
        // 2. Tìm User trong DB
        User owner = userRepository.findByEmail(currentUserEmail).orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin người quản lý!"));

        if (req.getRoomTypes() == null || req.getRoomTypes().isEmpty()) {
            throw new RuntimeException("Khách sạn phải có ít nhất một loại phòng!");
        }
        Destination destination = destinationRepository.findById(req.getDestinationId()).orElseThrow(() -> new RuntimeException("Destination not found"));

        Hotel hotel = new Hotel();
        hotel.setOwner(owner);
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
        // ==== TỰ ĐỘNG TÍNH TOÁN GIÁ VÀ PHÒNG ====
        BigDecimal minPrice = null;
        int totalRoomsCounter = 0; // Biến đếm tổng số phòng

        for (RoomTypeCreateRequest rtReq : req.getRoomTypes()) {
            RoomType rt = new RoomType();
            rt.setHotel(hotel);
            rt.setName(rtReq.getName());
            rt.setCapacity(rtReq.getCapacity());
            rt.setPrice(rtReq.getPrice());
            rt.setTotalRooms(rtReq.getTotalRooms()); // Số lượng phòng của loại này
            rt.setAmenities(mapper.writeValueAsString(rtReq.getAmenities()));

            hotel.getRoomTypes().add(rt);

            // Cộng dồn tổng số phòng của khách sạn
            totalRoomsCounter += rtReq.getTotalRooms();

            // Tìm giá thấp nhất để làm "Giá từ..." (Price per night)
            if (minPrice == null || rtReq.getPrice().compareTo(minPrice) < 0) {
                minPrice = rtReq.getPrice();
            }
        }

        // Gán các giá trị đã tính toán vào Hotel
        hotel.setTotalRooms(totalRoomsCounter);
        hotel.setAvailableRooms(totalRoomsCounter); // Lúc mới tạo, tất cả phòng đều trống
        hotel.setPricePerNight(minPrice);

        hotelRepository.save(hotel);
        return HotelMapper.toDetailResponse(hotel);
    }

    @Transactional
    public HotelDetailResponse updateHotel(Long hotelId, HotelCreateRequest req) throws JsonProcessingException {
        Hotel hotel = hotelRepository.findById(hotelId).orElseThrow(() -> new RuntimeException("Hotel not found"));
        validateOwnership(hotel);
        // 1. Cập nhật thông tin cơ bản
        Destination destination = destinationRepository.findById(req.getDestinationId()).orElseThrow(() -> new RuntimeException("Destination not found"));
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

        // 2. Xử lý hình ảnh
        String newThumbnailUri = req.getThumbnail();
        List<String> newGalleryUrls = req.getImages() != null ? req.getImages() : new ArrayList<>();

        // Bước A: Hạ cấp tất cả ảnh hiện tại về isPrimary = false (Reset trạng thái)
        hotel.getImages().forEach(img -> img.setIsPrimary(false));

        // Bước B: Đồng bộ ảnh Thumbnail (Ảnh bìa)
        if (newThumbnailUri != null && !newThumbnailUri.isBlank()) {
            // Tìm xem URL này đã tồn tại trong danh sách ảnh của Hotel chưa
            HotelImage existingThumb = hotel.getImages().stream()
                    .filter(img -> img.getImageUrl().equals(newThumbnailUri))
                    .findFirst()
                    .orElse(null);

            if (existingThumb != null) {
                // Nếu có rồi, chỉ việc nâng nó lên làm Primary
                existingThumb.setIsPrimary(true);
            } else {
                // Nếu chưa có (ảnh mới hoàn toàn), tạo mới và add vào list
                HotelImage thumb = new HotelImage();
                thumb.setHotel(hotel);
                thumb.setImageUrl(newThumbnailUri);
                thumb.setIsPrimary(true);
                thumb.setDisplayOrder(0);
                hotel.getImages().add(thumb);
            }
        }

        // Bước C: Đồng bộ ảnh Gallery (Đảm bảo các ảnh trong req.getImages() đều có trong DB)
        for (String url : newGalleryUrls) {
            if (url == null || url.isBlank() || url.equals(newThumbnailUri)) continue;

            boolean exists = hotel.getImages().stream().anyMatch(img -> img.getImageUrl().equals(url));
            if (!exists) {
                HotelImage img = new HotelImage();
                img.setHotel(hotel);
                img.setImageUrl(url);
                img.setIsPrimary(false);
                img.setDisplayOrder(hotel.getImages().size());
                hotel.getImages().add(img);
            }
        }

        // === 3. Xử lý Room Types và TÍNH TOÁN LẠI DỮ LIỆU ===
        hotel.getRoomTypes().clear();
        BigDecimal minPrice = null;
        int totalRoomsCounter = 0; // Dùng để tính lại tổng số phòng mới

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
                // Cộng dồn tổng số phòng mới
                totalRoomsCounter += rtReq.getTotalRooms();

                // Cập nhật giá thấp nhất (giá "chỉ từ")
                if (minPrice == null || rtReq.getPrice().compareTo(minPrice) < 0) {
                    minPrice = rtReq.getPrice();
                }
            }
        }

        // === 4. Gán các giá trị đã tính toán chuẩn xác ===
        hotel.setPricePerNight(minPrice);
        hotel.setTotalRooms(totalRoomsCounter);
        hotel.setAvailableRooms(totalRoomsCounter);
        hotelRepository.save(hotel);
        return HotelMapper.toDetailResponse(hotel);
    }

    @Transactional
    public void deleteHotel(Long hotelId) {
        // 1. Dùng findById
        Hotel hotel = hotelRepository.findById(hotelId).orElseThrow(() -> new RuntimeException("Không tìm thấy khách sạn với id : " + hotelId + "này"));
        validateOwnership(hotel);
        // 2. Kiểm tra logic: Nếu đã bị xóa (isActive == false) thì báo lỗi
        if (Boolean.FALSE.equals(hotel.getIsActive())) {
            throw new RuntimeException("Khách sạn này đã bị xóa");
        }

        // 3. Set trạng thái active = false (Xóa ẩn)
        hotel.setIsActive(false);

        // 4. Lưu thay đổi
        hotelRepository.save(hotel);
    }

    // Hàm hỗ trợ convert
    private List<String> convertAmenitiesToList(String jsonAmenities) {
        if (jsonAmenities == null || jsonAmenities.isBlank()) {
            return new ArrayList<>();
        }
        try {
            // Parse chuỗi "['a','b']" thành List ["a","b"]
            return mapper.readValue(jsonAmenities, new TypeReference<List<String>>() {
            });
        } catch (JsonProcessingException e) {
            // Nếu lỗi (hoặc dữ liệu cũ không phải JSON), trả về list chứa chuỗi gốc
            return Collections.singletonList(jsonAmenities);
        }
    }

    // Hàm bổ trợ lấy Email người dùng đang đăng nhập
    private String getCurrentUserEmail() {
        Authentication authentication = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new RuntimeException("Người dùng chưa xác thực!");
        }
        Object principal = authentication.getPrincipal();
        if (principal instanceof User) {
            return ((User) principal).getEmail();
        }
        return authentication.getName();
    }

    private void validateOwnership(Hotel hotel) {
        String currentPrincipal = getCurrentUserEmail();
        boolean isOwner = hotel.getOwner().getEmail().equalsIgnoreCase(currentPrincipal) || hotel.getOwner().getId().toString().equals(currentPrincipal);

        if (!isOwner) {
            throw new RuntimeException("Bạn không có quyền thực hiện thao tác này trên khách sạn của owner khác!");
        }
    }
}