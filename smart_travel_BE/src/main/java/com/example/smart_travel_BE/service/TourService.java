package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.tour.request.TourFilterRequest;
import com.example.smart_travel_BE.dto.tour.response.*;
import com.example.smart_travel_BE.entity.Tour;
import com.example.smart_travel_BE.entity.TourImage;
import com.example.smart_travel_BE.entity.TourSchedule;
import com.example.smart_travel_BE.mapper.TourMapper;
import com.example.smart_travel_BE.repository.TourImageRepository;
import com.example.smart_travel_BE.repository.TourRepository;
import com.example.smart_travel_BE.repository.TourScheduleRepository;
import com.example.smart_travel_BE.specification.TourSpecification;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    /**
     * Lấy danh sách tour (phân trang)
     */
    public Page<TourResponse> getAllTours(int page, int size, String sortBy, String sortDir) {
        Sort sort = Sort.by(Sort.Direction.fromString(Optional.ofNullable(sortDir).orElse("asc")), Optional.ofNullable(sortBy).orElse("id"));
        Pageable pageable = PageRequest.of(Math.max(0, page), Math.max(1, size), sort);

        Page<Tour> tours = tourRepository.findAll(pageable);
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
            int size
    ) {

        // BUILD SPEC
        Specification<Tour> spec = Specification.where(TourSpecification.nameContains(keyword))
                .and(TourSpecification.priceBetween(minPrice, maxPrice))
                .and(TourSpecification.daysBetween(minDays, maxDays))
                .and(TourSpecification.peopleMin(minPeople))
                .and(TourSpecification.ratingMin(minRating));

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

        // Parse included/excluded JSON string -> Map (nếu entity lưu string)
        try {
            if (tour.getIncluded() != null) {
                Map<String, Object> inc = objectMapper.readValue(tour.getIncluded(), new TypeReference<Map<String,Object>>(){});
                dto.setIncluded(inc);
            }
            if (tour.getExcluded() != null) {
                Map<String, Object> exc = objectMapper.readValue(tour.getExcluded(), new TypeReference<Map<String,Object>>(){});
                dto.setExcluded(exc);
            }
        } catch (Exception e) {
            // nếu parse lỗi thì để null hoặc log
        }

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
}
