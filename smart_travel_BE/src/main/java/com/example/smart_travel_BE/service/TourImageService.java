package com.example.smart_travel_BE.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.example.smart_travel_BE.entity.Tour;
import com.example.smart_travel_BE.entity.TourImage;
import com.example.smart_travel_BE.repository.TourImageRepository;
import com.example.smart_travel_BE.repository.TourRepository;
import com.example.smart_travel_BE.mapper.TourMapper;
import com.example.smart_travel_BE.dto.tour.response.TourImageResponse;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class TourImageService {

    private final Cloudinary cloudinary;
    private final TourRepository tourRepository;
    private final TourImageRepository tourImageRepository;
    private final TourMapper tourMapper;

    // Upload single image
    @Transactional
    public TourImageResponse addImage(Long tourId, MultipartFile file, boolean isPrimary, int displayOrder) throws IOException {
        Tour tour = tourRepository.findById(tourId)
                .orElseThrow(() -> new RuntimeException("Tour not found"));

        Map uploadResult = cloudinary.uploader().upload(file.getBytes(),
                ObjectUtils.asMap(
                        "folder", "tours/" + tourId,
                        "resource_type", "auto"
                ));

        String imageUrl = uploadResult.get("secure_url").toString();

        TourImage img = new TourImage();
        img.setTour(tour);
        img.setImageUrl(imageUrl);
        img.setIsPrimary(isPrimary);
        img.setDisplayOrder(displayOrder);

        return tourMapper.toImageResponse(tourImageRepository.save(img));
    }

    // Update existing image
    @Transactional
    public TourImageResponse updateImage(Long imageId, MultipartFile file, Boolean isPrimary, Integer displayOrder) throws IOException {
        TourImage img = tourImageRepository.findById(imageId)
                .orElseThrow(() -> new RuntimeException("Image not found"));

        if (file != null) {
            Map uploadResult = cloudinary.uploader().upload(file.getBytes(),
                    ObjectUtils.asMap(
                            "folder", "tours/" + img.getTour().getId(),
                            "resource_type", "auto"
                    ));
            img.setImageUrl(uploadResult.get("secure_url").toString());
        }

        if (isPrimary != null) img.setIsPrimary(isPrimary);
        if (displayOrder != null) img.setDisplayOrder(displayOrder);

        return tourMapper.toImageResponse(tourImageRepository.save(img));
    }

    public void deleteImage(Long imageId) {
        tourImageRepository.deleteById(imageId);
    }

    public List<TourImageResponse> getImagesByTour(Long tourId) {
        List<TourImage> images = tourImageRepository.findByTourIdOrderByDisplayOrderAsc(tourId);
        return images.stream()
                .map(tourMapper::toImageResponse)
                .toList();
    }

    @Transactional
    public List<TourImageResponse> addImages(Long tourId, List<MultipartFile> files) throws IOException {
        Tour tour = tourRepository.findById(tourId)
                .orElseThrow(() -> new RuntimeException("Tour not found"));

        // Lấy số lượng ảnh hiện có để sắp xếp displayOrder
        int order = tourImageRepository.findByTourIdOrderByDisplayOrderAsc(tourId).size();

        List<TourImageResponse> savedImages = new ArrayList<>();

        for (MultipartFile file : files) {
            Map uploadResult = cloudinary.uploader().upload(file.getBytes(),
                    ObjectUtils.asMap(
                            "folder", "tours/" + tourId,
                            "resource_type", "auto"
                    ));

            TourImage img = new TourImage();
            img.setTour(tour);
            img.setImageUrl(uploadResult.get("secure_url").toString());
            img.setIsPrimary(false); // bulk upload mặc định không primary
            img.setDisplayOrder(order++);

            savedImages.add(tourMapper.toImageResponse(tourImageRepository.save(img)));
        }

        return savedImages;
    }

    @Transactional
    public TourImageResponse setPrimaryImage(Long imageId) {
        // 1. Lấy ảnh
        TourImage image = tourImageRepository.findById(imageId)
                .orElseThrow(() -> new RuntimeException("Image not found"));

        Long tourId = image.getTour().getId();

        // 2. Reset tất cả ảnh khác của tour
        List<TourImage> tourImages = tourImageRepository.findByTourIdOrderByDisplayOrderAsc(tourId);
        for (TourImage img : tourImages) {
            img.setIsPrimary(false);
        }
        tourImageRepository.saveAll(tourImages);

        // 3. Set ảnh này là primary
        image.setIsPrimary(true);
        tourImageRepository.save(image);

        // 4. Trả về DTO
        return tourMapper.toImageResponse(image);
    }


}

