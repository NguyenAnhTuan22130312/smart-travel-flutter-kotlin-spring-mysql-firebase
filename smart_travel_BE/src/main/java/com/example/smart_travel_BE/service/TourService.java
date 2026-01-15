package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.tour.response.*;
import com.example.smart_travel_BE.entity.*;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.mapper.TourMapper;
import com.example.smart_travel_BE.dto.tour.request.*;
import com.example.smart_travel_BE.repository.*;
import com.example.smart_travel_BE.specification.TourSpecification;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.api.gax.rpc.NotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class TourService {

    @Autowired
    private TourRepository tourRepository;

    @Autowired
    private TourImageRepository tourImageRepository;

    @Autowired
    private TourScheduleRepository tourScheduleRepository;

    @Autowired
    private TourMapper tourMapper;

    private final ObjectMapper objectMapper = new ObjectMapper();
    @Autowired
    private DestinationRepository destinationRepository;
    @Autowired
    private UserRepository userRepository;

    /**
     * Lấy danh sách tour (phân trang)
     */
    public Page<TourResponse> getAllTours(int page, int size, String sortBy, String sortDir) {
        Sort sort = Sort.by(Sort.Direction.fromString(Optional.ofNullable(sortDir).orElse("asc")), Optional.ofNullable(sortBy).orElse("id"));
        Pageable pageable = PageRequest.of(Math.max(0, page), Math.max(1, size), sort);

        Page<Tour> tours = tourRepository.findByIsActive(true, pageable);
        return tours.map(tourMapper::toSummary);
    }

    /**
     * Lọc tours theo filter request, sort
     */
    public Page<TourResponse> filterTours(
            String keyword,
            Double minPrice,
            Double maxPrice,
            Integer minDays,
            Integer maxDays,
            Integer minPeople,
            Double minRating,
            String sort,
            int page,
            int size,
            Boolean isActive
    ) {

        // BUILD SPEC
        Specification<Tour> spec = Specification.where(TourSpecification.nameContains(keyword))
                .and(TourSpecification.priceBetween(minPrice, maxPrice))
                .and(TourSpecification.daysBetween(minDays, maxDays))
                .and(TourSpecification.peopleMin(minPeople))
                .and(TourSpecification.ratingMin(minRating))
                .and(TourSpecification.isActive(isActive));

        Sort sortOption = Sort.by(Sort.Direction.DESC, "updatedAt")
                .and(Sort.by(Sort.Direction.DESC, "createdAt"));

        if (sort != null) {
            switch (sort) {

                case "price_asc":
                    sortOption = Sort.by(Sort.Direction.ASC, "pricePerPerson");
                    break;

                case "price_desc":
                    sortOption = Sort.by(Sort.Direction.DESC, "pricePerPerson");
                    break;

                case "rating_desc":
                    sortOption = Sort.by(Sort.Direction.DESC, "averageRating");
                    break;

                case "popular_desc":
                    sortOption = Sort.by(Sort.Direction.DESC, "bookingCount");
                    break;

                case "newest":
                    sortOption = Sort.by(Sort.Direction.DESC, "updatedAt")
                            .and(Sort.by(Sort.Direction.DESC, "createdAt"));
                    break;

                case "oldest":
                    sortOption = Sort.by(Sort.Direction.ASC, "createdAt");
                    break;
            }
        }
        Pageable pageable = PageRequest.of(page, size, sortOption);

        try {
            Page<Tour> tours = tourRepository.findAll(spec, pageable);
            return tours.map(tourMapper::toSummary);
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

    }

    /**
     * Lấy chi tiết tour (kèm images + schedules)
     */
    @Transactional(readOnly = true)
    public TourDetailResponse getTourDetail(Long id) {
        Tour tour = tourRepository.findById(id).orElseThrow(() -> new NoSuchElementException("Tour not found id=" + id));

        // Map Tour -> DTO (MapStruct)
        TourDetailResponse dto = tourMapper.toDetail(tour);

//        // Parse included/excluded JSON string -> Map (nếu entity lưu string)
//        try {
//            if (tour.getIncluded() != null) {
//                Map<String, Object> inc = objectMapper.readValue(tour.getIncluded(), new TypeReference<Map<String,Object>>(){});
//                dto.setIncluded(inc);
//            }
//            if (tour.getExcluded() != null) {
//                Map<String, Object> exc = objectMapper.readValue(tour.getExcluded(), new TypeReference<Map<String,Object>>(){});
//                dto.setExcluded(exc);
//            }
//        } catch (Exception e) {
//            // nếu parse lỗi thì để null hoặc log
//            e.printStackTrace();
//        }

        // images: lấy từ tourImageRepository (theo displayOrder)
        List<TourImage> images = tourImageRepository.findByTourIdOrderByDisplayOrder(id);
        dto.setImages(tourMapper.toImageResponses(images));

        // schedules: từ tourScheduleRepository
        List<TourSchedule> schedules = tourScheduleRepository.findByTourIdOrderByDayNumber(id);
        dto.setSchedules(tourMapper.toScheduleResponses(schedules));

        return dto;
    }

    /**
     * Lấy ảnh tour
     */
    public List<TourImageResponse> getImages(Long tourId) {
        return tourMapper.toImageResponses(tourImageRepository.findByTourIdOrderByDisplayOrder(tourId));
    }

    /**
     * Lấy lịch trình 1 ngày cụ thể
     */
    public TourScheduleResponse getScheduleByDay(Long tourId, Integer dayNumber) {
        List<TourSchedule> schedules = tourScheduleRepository.findByTourIdOrderByDayNumber(tourId);
        return schedules.stream()
                .filter(s -> Objects.equals(s.getDayNumber(), dayNumber))
                .findFirst()
                .map(tourMapper::toScheduleResponse)
                .orElseThrow(() -> new NoSuchElementException("Schedule not found day=" + dayNumber));
    }

    /**
     * Lấy danh sách tour theo destination (dùng cho màn destination -> xem tất cả tour)
     */
    public List<TourResponse> getToursByDestination(Long destinationId) {
        List<Tour> tours = tourRepository.findByDestinationId(destinationId);
        return tours.stream().map(tourMapper::toSummary).collect(Collectors.toList());
    }

    // Admin methods (nếu cần) để thêm xóa sửa ảnh / lịch (ví dụ - cần quyền)
    public TourImageResponse addImageToTour(Long tourId, String imageUrl, Boolean isPrimary, Integer displayOrder) {
        Tour tour = tourRepository.findById(tourId).orElseThrow(() -> new NoSuchElementException("Tour not found"));
        TourImage img = new TourImage();
        img.setTour(tour);
        img.setImageUrl(imageUrl);
        img.setIsPrimary(isPrimary != null ? isPrimary : false);
        img.setDisplayOrder(displayOrder != null ? displayOrder : 0);
        TourImage saved = tourImageRepository.save(img);
        return tourMapper.toImageResponse(saved);
    }
    /**
     * (ADMIN) Lấy ra tất cả Tour + sreach+ phân trang
     */
    public Page<TourSummaryResponse> getTours(
            String keyword, Long destinationId, Boolean isActive,
            int page, int size, String sortBy, String sortDir
    ) {
        // 1. Lấy thông tin user hiện tại từ SecurityContext
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        Long currentUserId = null;
        boolean isTourAdmin = false;

        if (auth != null && auth.getPrincipal() instanceof User user) {
            currentUserId = user.getId();
            // Kiểm tra xem có phải là ADMINTOUR không
            isTourAdmin = auth.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ROLE_ADMINTOUR"));
        }

        // 2. Tạo Specification cơ bản
        Specification<Tour> spec = Specification.where(TourSpecification.nameContains(keyword))
                .and(TourSpecification.byDestination(destinationId))
                .and(TourSpecification.isActive(isActive));

        // 3. NẾU LÀ ADMINTOUR: Chỉ cho phép thấy Tour do mình tạo (Owner)
        if (isTourAdmin && currentUserId != null) {
            final Long finalId = currentUserId;
            spec = spec.and((root, query, cb) -> cb.equal(root.get("owner").get("id"), finalId));
        }

        Sort sort = Sort.by("desc".equalsIgnoreCase(sortDir) ? Sort.Direction.DESC : Sort.Direction.ASC,
                sortBy == null ? "createdAt" : sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        return tourRepository.findAll(spec, pageable).map(tourMapper::toAdminSummary);
    }

    /**
     * (ADMIN) Tạo tour
     */
    @Transactional
    public TourDetailResponse createTour(CreateTourRequest req) {
        User owner = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        Tour tour = new Tour();
        mapRequestToEntity(req, tour); // Dùng hàm dùng chung để tránh lặp code
        tour.setOwner(owner);
        tour.setIsActive(true);

        // Xử lý Destination
        Destination dest = destinationRepository.findById(req.getDestinationId())
                .orElseThrow(() -> new NoSuchElementException("Không tìm thấy điểm đến"));
        tour.setDestination(dest);

        // Lưu Tour trước để lấy ID cho Images và Schedules
        Tour savedTour = tourRepository.save(tour);

        // Lưu Images & Schedules bằng cách gán List để tận dụng Cascade.ALL
        if (req.getImages() != null) {
            List<TourImage> images = req.getImages().stream().map(imgReq -> {
                TourImage img = new TourImage();
                img.setTour(savedTour);
                img.setImageUrl(imgReq.getImageUrl());
                img.setIsPrimary(Boolean.TRUE.equals(imgReq.getIsPrimary()));
                img.setDisplayOrder(imgReq.getDisplayOrder());
                return img;
            }).toList();
            tourImageRepository.saveAll(images);
        }

        if (req.getSchedules() != null) {
            List<TourSchedule> schedules = req.getSchedules().stream().map(sReq -> {
                TourSchedule s = new TourSchedule();
                s.setTour(savedTour);
                s.setDayNumber(sReq.getDayNumber());
                s.setTitle(sReq.getTitle());
                s.setActivities(sReq.getActivities());
                s.setMeals(sReq.getMeals());
                s.setAccommodation(sReq.getAccommodation());
                return s;
            }).toList();
            tourScheduleRepository.saveAll(schedules);
        }

        return tourMapper.toDetail(savedTour);
    }

    @Transactional(readOnly = true)
    public TourDetailResponse getDetail(Long id) {
        Tour tour = tourRepository.findWithDetailById(id)
                .orElseThrow(() -> new RuntimeException("Tour not found"));

        TourDetailResponse dto = tourMapper.toDetail(tour);

        dto.setImages(
                tourMapper.toImageResponses(
                        tourImageRepository.findByTourIdOrderByDisplayOrder(id)
                )
        );

        dto.setSchedules(
                tourMapper.toScheduleResponses(
                        tourScheduleRepository.findByTourIdOrderByDayNumber(id)
                )
        );

        return dto;
    }

    // ================= UPDATE =================
    @Transactional
    public TourDetailResponse updateTour(Long id, UpdateTourRequest req) {
        Tour tour = tourRepository.findWithDetailById(id)
                .orElseThrow(() -> new NoSuchElementException("Tour not found"));

        // 1. Kiểm tra quyền sở hữu
        validateTourOwnership(tour);

        // 2. Cập nhật thông tin cơ bản
        if (req.getName() != null) tour.setName(req.getName());
        if (req.getDescription() != null) tour.setDescription(req.getDescription());
        if (req.getPricePerPerson() != null)
            tour.setPricePerPerson(BigDecimal.valueOf(req.getPricePerPerson()));
        if (req.getDurationDays() != null) tour.setDurationDays(req.getDurationDays());
        if (req.getDurationNights() != null) tour.setDurationNights(req.getDurationNights());

        // Đảm bảo có 2 dòng này để cập nhật số lượng khách
        if (req.getMinPeople() != null) tour.setMinPeople(req.getMinPeople());
        if (req.getMaxPeople() != null) tour.setMaxPeople(req.getMaxPeople());

        if (req.getIsActive() != null) tour.setIsActive(req.getIsActive());

        // 3. Cập nhật HÌNH ẢNH (Update Images)
        if (req.getImages() != null && !req.getImages().isEmpty()) {
            // Xóa sạch list ảnh cũ (Hibernate sẽ xóa các bản ghi này trong DB nhờ orphanRemoval)
            tour.getImages().clear();

            // Thêm list ảnh mới từ Request
            req.getImages().forEach(imgReq -> {
                TourImage img = new TourImage();
                img.setTour(tour);
                img.setImageUrl(imgReq.getImageUrl());
                img.setIsPrimary(Boolean.TRUE.equals(imgReq.getIsPrimary()));
                img.setDisplayOrder(imgReq.getDisplayOrder());
                tour.getImages().add(img);
            });
        }

        // 4. Cập nhật LỊCH TRÌNH (Update Schedules)
        if (req.getSchedules() != null && !req.getSchedules().isEmpty()) {
            tour.getSchedules().clear();
            req.getSchedules().forEach(sReq -> {
                TourSchedule s = new TourSchedule();
                s.setTour(tour);
                s.setDayNumber(sReq.getDayNumber());
                s.setTitle(sReq.getTitle());
                s.setActivities(sReq.getActivities());
                s.setMeals(sReq.getMeals());
                s.setAccommodation(sReq.getAccommodation());
                tour.getSchedules().add(s);
            });
        }

        // 5. Cập nhật JSON (Included/Excluded)
        if (req.getIncluded() != null) tour.setIncluded(toJson(req.getIncluded()));
        if (req.getExcluded() != null) tour.setExcluded(toJson(req.getExcluded()));

        return tourMapper.toDetail(tour);
    }

    public void updateStatus(Long id, Boolean isActive) {
        Tour tour = tourRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tour not found"));

        tour.setIsActive(isActive);
    }

    // ================= DELETE =================
    @Transactional
    public void deleteTour(Long id) {
        try {
            tourImageRepository.deleteByTourId(id);
            tourScheduleRepository.deleteByTourId(id);
            tourRepository.deleteById(id);
        } catch (Exception e) {
            throw e;
        }
    }

    // ================= IMAGE =================
    public TourImageResponse addImage(Long tourId, TourImageRequest req) {
        Tour tour = tourRepository.findById(tourId)
                .orElseThrow(() -> new NoSuchElementException("Tour not found"));

        TourImage img = new TourImage();
        img.setTour(tour);
        img.setImageUrl(req.getImageUrl());
        img.setIsPrimary(Boolean.TRUE.equals(req.getIsPrimary()));
        img.setDisplayOrder(req.getDisplayOrder());

        return tourMapper.toImageResponse(tourImageRepository.save(img));
    }

    // Upload 1 ảnh
    public TourImageResponse updateImage(Long imageId, TourImageRequest req) {
        TourImage img = tourImageRepository.findById(imageId)
                .orElseThrow(() -> new NoSuchElementException("Image not found"));

        if (req.getImageUrl() != null) img.setImageUrl(req.getImageUrl());
        if (req.getIsPrimary() != null) img.setIsPrimary(req.getIsPrimary());
        if (req.getDisplayOrder() != null) img.setDisplayOrder(req.getDisplayOrder());

        return tourMapper.toImageResponse(tourImageRepository.save(img));
    }

    public void deleteImage(Long imageId) {
        tourImageRepository.deleteById(imageId);
    }

    // Upload nhiều ảnh
    public List<TourImageResponse> addImages(Long tourId, List<TourImageRequest> requests) {
        Tour tour = tourRepository.findById(tourId)
                .orElseThrow(() -> new RuntimeException("Tour not found"));

        boolean hasPrimary = tourImageRepository.existsPrimaryByTourId(tourId);

        List<TourImage> images = new ArrayList<>();

        for (TourImageRequest req : requests) {
            TourImage img = new TourImage();
            img.setTour(tour);
            img.setImageUrl(req.getImageUrl());
            img.setIsPrimary(!hasPrimary && Boolean.TRUE.equals(req.getIsPrimary()));
            img.setDisplayOrder(req.getDisplayOrder());

            images.add(img);
            hasPrimary = true;
        }

        return tourMapper.toImageResponses(tourImageRepository.saveAll(images));
    }

    // Set ảnh Primary
    @Transactional
    public void setPrimaryImage(Long imageId) {
        TourImage image = tourImageRepository.findById(imageId)
                .orElseThrow(() -> new RuntimeException("Image not found"));

        Long tourId = image.getTour().getId();

        // reset tất cả ảnh khác
        tourImageRepository.resetPrimary(tourId);

        // set ảnh này là primary
        image.setIsPrimary(true);

        // save lại
        tourImageRepository.save(image);
    }


    public void reorderImages(List<TourImageRequest> requests) {
        for (TourImageRequest req : requests) {
            TourImage img = tourImageRepository.findById(Long.valueOf(req.getId()))
                    .orElseThrow(() -> new RuntimeException("Image not found"));
            img.setDisplayOrder(req.getDisplayOrder());
        }
    }

    // ================= SCHEDULE =================
    public TourScheduleResponse addSchedule(Long tourId, TourScheduleRequest req) {
        Tour tour = tourRepository.findById(tourId)
                .orElseThrow(() -> new NoSuchElementException("Tour not found"));

        TourSchedule s = new TourSchedule();
        s.setTour(tour);
        s.setDayNumber(req.getDayNumber());
        s.setTitle(req.getTitle());
        s.setActivities(req.getActivities());
        s.setMeals(req.getMeals());
        s.setAccommodation(req.getAccommodation());

        return tourMapper.toScheduleResponse(tourScheduleRepository.save(s));
    }

    public TourScheduleResponse updateSchedule(Long scheduleId, TourScheduleRequest req) {
        TourSchedule s = tourScheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new NoSuchElementException("Schedule not found"));

        if (req.getDayNumber() != null) s.setDayNumber(req.getDayNumber());
        if (req.getTitle() != null) s.setTitle(req.getTitle());
        if (req.getActivities() != null) s.setActivities(req.getActivities());
        if (req.getMeals() != null) s.setMeals(req.getMeals());
        if (req.getAccommodation() != null) s.setAccommodation(req.getAccommodation());

        return tourMapper.toScheduleResponse(tourScheduleRepository.save(s));
    }

    public void deleteSchedule(Long scheduleId) {
        tourScheduleRepository.deleteById(scheduleId);
    }

    // ================= UTIL =================
    private void saveImages(Tour tour, List<TourImageRequest> images) {
        if (images == null) return;
        for (TourImageRequest req : images) {
            addImage(tour.getId(), req);
        }
    }

    private void saveSchedules(Tour tour, List<TourScheduleRequest> schedules) {
        if (schedules == null) return;
        for (TourScheduleRequest req : schedules) {
            addSchedule(tour.getId(), req);
        }
    }

    private String toJson(Object obj) {
        try {
            return new ObjectMapper().writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }

    private void validateTourOwnership(Tour tour) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = (User) auth.getPrincipal();

        boolean isOwner = tour.getOwner().getId().equals(currentUser.getId());
        boolean isSuperAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMINTOUR"));

        if (!isOwner && !isSuperAdmin) {
            throw new RuntimeException("Bạn không có quyền thao tác trên Tour này!");
        }
    }

    private void mapRequestToEntity(CreateTourRequest req, Tour tour) {
        tour.setName(req.getName());
        tour.setDescription(req.getDescription());
        tour.setPricePerPerson(req.getPricePerPerson());
        tour.setDurationDays(req.getDurationDays());
        tour.setDurationNights(req.getDurationNights());
        tour.setMinPeople(req.getMinPeople());
        tour.setMaxPeople(req.getMaxPeople());
        tour.setIncluded(toJson(req.getIncluded()));
        tour.setExcluded(toJson(req.getExcluded()));
    }

}
