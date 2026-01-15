package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.destination.request.DestinationCreateRequest;
import com.example.smart_travel_BE.dto.destination.request.DestinationImageRequest;
import com.example.smart_travel_BE.dto.destination.request.DestinationImageUploadRequest;
import com.example.smart_travel_BE.dto.destination.request.DestinationUpdateRequest;
import com.example.smart_travel_BE.dto.destination.response.DestinationDetailResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationFeaturedResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationImageResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationResponse;
import com.example.smart_travel_BE.dto.user.request.UpdateLevelRequest;
import com.example.smart_travel_BE.dto.user.response.LevelResponse;
import com.example.smart_travel_BE.entity.*;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.mapper.DestinationMapper;
import com.example.smart_travel_BE.repository.DestinationImageRepository;
import com.example.smart_travel_BE.repository.DestinationRepository;
import com.example.smart_travel_BE.repository.ProvinceRepository;
import com.example.smart_travel_BE.repository.UserProfileRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DestinationService {
    private final DestinationRepository destinationRepository;
    private final DestinationMapper destinationMapper;
    private final ProvinceRepository provinceRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final DestinationImageRepository imageRepository;
    private final CloudinaryService cloudinaryService;
    private final UserProfileRepository userProfileRepository;
    private final UserService userService;


    /**
     * Lấy tất cả danh sách địa điểm
     */
    public List<DestinationDetailResponse> getAllDestinations() {
        return destinationRepository.findByIsActiveTrue()
                .stream()
                .map(destinationMapper::toDestinationDetailResponse)
                .collect(Collectors.toList());
    }

    /**
     * Lấy danh sách địa điểm nổi bật
     */
    public List<DestinationDetailResponse> getAllDestinationsFeatured() {
        List<Destination> destinations = destinationRepository.findByIsFeaturedTrueAndIsActiveTrue();

        return destinations.stream().map(destinationMapper::toDestinationDetailResponse)
                .collect(Collectors.toList());
    }

    /**
     * Lấy danh sách địa điểm nổi bật
     */
    public List<DestinationDetailResponse> filterDestinationsByCategory(String category) {
        List<Destination> destinations = destinationRepository.findAll();
        // Lọc và map sang DTO
        return destinations.stream()
                .filter(d -> d.getCategory() != null &&
                        d.getCategory().equalsIgnoreCase(category))
                .map(destinationMapper::toDestinationDetailResponse)
                .collect(Collectors.toList());
    }

    /**
     * Xem chi tiết địa điểm
     */

    public DestinationDetailResponse getDestinationDetail(long id) {
        Destination destination = destinationRepository.findById(id).orElseThrow(
                () -> new AppException(ErrorCode.DESTINATION_NOT_EXISTED)
        );
        destination.setViewCount(destination.getViewCount() + 1);
        destinationRepository.save(destination);

        return destinationMapper.toDestinationDetailResponse(destination);
    }


    /**
     * ADMIN - Tạo mới địa điểm
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public DestinationDetailResponse createDestination(DestinationCreateRequest request, List<MultipartFile> images) {
        // Kiểm tra tỉnh/thành tồn tại
        Province province = provinceRepository.findById(request.getProvinceId())
                .orElseThrow(() -> new AppException(ErrorCode.PROVINCE_NOT_EXISTED));

        // Kiểm tra trùng tên trong cùng tỉnh
        boolean exists = destinationRepository.existsByNameAndProvinceId(
                request.getName().trim(), request.getProvinceId());
        if (exists) {
            throw new AppException(ErrorCode.DESTINATION_ALREADY_EXISTS);
        }

        // Validate openingHours là JSON hợp lệ (nếu có)
        validateOpeningHours(request.getOpeningHours());

        Destination destination = destinationMapper.toDestination(request);
        destination.setProvince(province);
        destination.setIsActive(true);
        destination.setViewCount(0L);
        destination.setReviewCount(0);
        destination.setAverageRating(BigDecimal.ZERO);

        destination = destinationRepository.save(destination);
        log.info("Admin created new destination: {} (ID: {})", destination.getName(), destination.getId());

        // Xử lý ảnh
        handleDestinationImageFiles(destination, images);
        return destinationMapper.toDestinationDetailResponse(destination);
    }


    /**
     * ADMIN - Cập nhật địa điểm
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public DestinationDetailResponse updateDestination(Long id, DestinationUpdateRequest request, List<MultipartFile> images) {
        log.info(request.toString());
        Destination destination = destinationRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.DESTINATION_NOT_EXISTED));

        // Kiểm tra tỉnh/thành tồn tại
        Province province = provinceRepository.findById(request.getProvinceId())
                .orElseThrow(() -> new AppException(ErrorCode.PROVINCE_NOT_EXISTED));

        // Kiểm tra trùng tên trong cùng tỉnh (trừ chính nó)
        boolean nameExists = destinationRepository.existsByNameAndProvinceIdAndIdNot(
                request.getName().trim(), request.getProvinceId(), id);
        if (nameExists) {
            throw new AppException(ErrorCode.DESTINATION_ALREADY_EXISTS);
        }

        // Validate JSON
        validateOpeningHours(request.getOpeningHours());

        // Cập nhật các trường
        destinationMapper.updateDestinationFromRequest(request, destination);
        destination.setProvince(province);

        destination = destinationRepository.save(destination);
        // xử lý xóa ảnh cũ theo imageIds
        if (request.getImageIds() != null && !request.getImageIds().isEmpty()) {
            List<DestinationImage> imagesToDelete = destination.getImages().stream()
                    .filter(img -> request.getImageIds().contains(img.getId().intValue()))
                    .toList();

            for (DestinationImage img : imagesToDelete) {
                try {
                    cloudinaryService.deleteFile(img.getImageUrl()); // xóa trên Cloudinary
                } catch (Exception e) {
                    log.warn("Cannot delete file on Cloudinary: {}", img.getImageUrl());
                }
                destination.getImages().remove(img);
                imageRepository.delete(img);
            }
            log.info("Deleted {} images by request", imagesToDelete.size());
        }

        // Cập nhật ảnh
        handleDestinationImageFiles(destination, images);
        return destinationMapper.toDestinationDetailResponse(destination);
    }

    /**
     * ADMIN - Xóa địa điểm
     * chuyển isActive = false
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void deleteDestination(Long id) {
        Destination destination = destinationRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.DESTINATION_NOT_EXISTED));

        // Soft delete
        destination.setIsActive(false);
        destinationRepository.save(destination);
        log.info("Admin soft-deleted destination ID: {}", id);
    }

    /**
     * ADMIN - Khôi phục địa điểm
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void restoreDestination(Long id) {
        Destination destination = destinationRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.DESTINATION_NOT_EXISTED));

        destination.setIsActive(true);
        destinationRepository.save(destination);
        log.info("Admin restored destination ID: {}", id);
    }

    /**
     * ADMIN - Đánh dấu địa điểm là nổi bật
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void toggleFeatured(Long id, boolean isFeatured) {
        Destination destination = destinationRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.DESTINATION_NOT_EXISTED));

        destination.setIsFeatured(isFeatured);
        destinationRepository.save(destination);
        log.info("Admin set destination ID: {} as featured: {}", id, isFeatured);
    }

    // === Helper: Validate JSON cho openingHours ===
    private void validateOpeningHours(String openingHours) {
        if (openingHours != null && !openingHours.trim().isEmpty()) {
            try {
                objectMapper.readTree(openingHours);
            } catch (JsonProcessingException e) {
                throw new AppException(ErrorCode.INVALID_JSON_FORMAT);
            }
        }
    }

    // === THÊM ẢNH RIÊNG ===
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public DestinationImageResponse uploadImageToDestination(Long destinationId, DestinationImageUploadRequest request, MultipartFile file) {
        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new AppException(ErrorCode.DESTINATION_NOT_EXISTED));

        String imageUrl;
        try {
            imageUrl = cloudinaryService.uploadFile(file, "destinations");
        } catch (IOException e) {
            throw new AppException(ErrorCode.IMAGE_UPLOAD_FAILED);
        }

        DestinationImage img = new DestinationImage();
        img.setImageUrl(imageUrl);
        img.setDestination(destination);
        img.setIsPrimary(Boolean.TRUE.equals(request.getIsPrimary()));

        // Xử lý primary
        if (img.getIsPrimary()) {
            imageRepository.findByDestinationIdAndIsPrimaryTrue(destinationId)
                    .ifPresent(old -> {
                        old.setIsPrimary(false);
                        imageRepository.save(old);
                    });
        }

        // displayOrder: max + 1
        int maxOrder = destination.getImages().stream()
                .mapToInt(DestinationImage::getDisplayOrder)
                .max()
                .orElse(-1);
        img.setDisplayOrder(request.getDisplayOrder() != null ? request.getDisplayOrder() : maxOrder + 1);

        img = imageRepository.save(img);
        return destinationMapper.toImageResponse(img);
    }

    // === XÓA ẢNH ===
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void deleteDestinationImage(Long destinationId, Long imageId) {
        DestinationImage image = imageRepository.findById(imageId)
                .orElseThrow(() -> new AppException(ErrorCode.IMAGE_NOT_FOUND));

        if (!image.getDestination().getId().equals(destinationId)) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        // Xóa trên Cloudinary
        cloudinaryService.deleteFile(image.getImageUrl());

        // Xóa trong DB
        imageRepository.delete(image);

        // Chuyển primary nếu cần
        if (image.getIsPrimary()) {
            imageRepository.findByDestinationIdOrderByDisplayOrderAsc(destinationId)
                    .stream()
                    .findFirst()
                    .ifPresent(newPrimary -> {
                        newPrimary.setIsPrimary(true);
                        imageRepository.save(newPrimary);
                    });
        }

        log.info("Deleted image ID: {} (Cloudinary + DB)", imageId);
    }


    private void handleDestinationImageFiles(Destination destination, List<MultipartFile> imageFiles) {

        // Nếu không upload ảnh mới → giữ nguyên ảnh cũ
        if (imageFiles == null || imageFiles.isEmpty()) {
            log.info("No new images uploaded. Keeping old images.");
            return;
        }

        // Lấy danh sách ảnh hiện tại
        List<DestinationImage> existingImages = destination.getImages();

        // Danh sách ảnh sẽ giữ lại (ảnh còn tồn tại)
        List<DestinationImage> keptImages = new ArrayList<>();

        // 1. Kiểm tra ảnh cũ còn tồn tại trên Cloudinary không
        for (DestinationImage img : existingImages) {
            boolean existsOnCloud = cloudinaryService.checkFileExists(img.getImageUrl());
            if (existsOnCloud) {
                keptImages.add(img); // giữ lại
            } else {
                cloudinaryService.deleteFile(img.getImageUrl()); // dọn rác DB
                imageRepository.delete(img);
            }
        }

        // 2. Thêm ảnh mới nếu có upload
        List<DestinationImage> newImages = new ArrayList<>();
        int startOrder = keptImages.size(); // ảnh mới xếp sau ảnh cũ

        for (int i = 0; i < imageFiles.size(); i++) {
            MultipartFile file = imageFiles.get(i);

            try {
                String imageUrl = cloudinaryService.uploadFile(file, "destinations");

                DestinationImage img = new DestinationImage();
                img.setImageUrl(imageUrl);
                img.setDestination(destination);
                img.setDisplayOrder(startOrder + i);
                img.setIsPrimary(false);

                newImages.add(img);
            } catch (IOException e) {
                throw new AppException(ErrorCode.IMAGE_UPLOAD_FAILED);
            }
        }

        // Lưu tất cả vào DB
        keptImages.addAll(newImages);
        destination.getImages().clear();
        destination.getImages().addAll(keptImages);

        imageRepository.saveAll(keptImages);

        log.info("Total images after update = {}", keptImages.size());
    }

    // voice guide
    @Transactional
    public LevelResponse completeVoiceGuide(Long destinationId) {
        // 1. Lấy thông tin User và Profile
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = (User) authentication.getPrincipal();

        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new AppException(ErrorCode.DESTINATION_NOT_EXISTED));

        UserProfile profile = userProfileRepository.findByUser(currentUser)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));

        // 2. KIỂM TRA COOLDOWN (3 phút)
        LocalDateTime now = LocalDateTime.now();
        // Khởi tạo Map nếu null (phòng trường hợp Builder không khởi tạo)
        if (profile.getLastEarnedAt() == null) profile.setLastEarnedAt(new HashMap<>());

        LocalDateTime lastEarned = profile.getLastEarnedAt().get(destinationId);

        if (lastEarned != null) {
            long secondsPassed = java.time.Duration.between(lastEarned, now).toSeconds();
            if (secondsPassed < 180) { // 3 phút = 180 giây
                long secondsRemaining = 180 - secondsPassed;
                log.warn("User {} bị chặn do cooldown. Còn lại {} giây.", currentUser.getEmail(), secondsRemaining);
                // Bạn có thể trả về lỗi hoặc thông báo thời gian còn lại
                throw new AppException(ErrorCode.COOLDOWN_ACTIVE);
            }
        }

        // 3. RANDOM EXP: [20, 50]
        long reward = 20 + (long) (Math.random() * (50 - 20 + 1));

        // 4. CẬP NHẬT DỮ LIỆU
        Long currentExp = (profile.getExperiencePoints() != null) ? profile.getExperiencePoints() : 0L;
        Long newTotalExp = currentExp + reward;

        profile.setExperiencePoints(newTotalExp);
        profile.getLastEarnedAt().put(destinationId, now); // Cập nhật thời điểm nhận điểm mới nhất

        // Vẫn lưu vào Listened (Thành tựu khám phá)
        profile.getListenedDestinationIds().add(destinationId);

        userProfileRepository.save(profile);

        // 5. Cập nhật Level
        UpdateLevelRequest updateLevelRequest = new UpdateLevelRequest();
        updateLevelRequest.setExperiencePoints(newTotalExp);

        LevelResponse response = userService.updateUserLevel(updateLevelRequest);
        response.setEarnedExp(reward); // GÁN CON SỐ RANDOM VÀO ĐÂY
        response.setServerTime(LocalDateTime.now());

        log.info("User {} nhận {} EXP tại {}. Tổng mới: {}",
                currentUser.getEmail(), reward, destination.getName(), newTotalExp);

        return response;
    }

    // ADMIN AUDIO GUIDE
    @Transactional
    public DestinationResponse updateAudioScript(Long destinationId, String newAudioScript) {
        // 1. Kiểm tra địa điểm có tồn tại không
        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new AppException(ErrorCode.DESTINATION_NOT_EXISTED));

        // 2. Cập nhật nội dung thuyết minh
        // Nếu newAudioScript là null hoặc rỗng, có thể hiểu là Admin muốn xóa audio
        destination.setAudioScript(newAudioScript);

        // 3. Lưu vào database
        destinationRepository.save(destination);

        log.info("Admin đã cập nhật Audio Script cho địa điểm: {} (ID: {})",
                destination.getName(), destinationId);

        // 4. Trả về kết quả (map qua DTO)
        return destinationMapper.toDestinationResponse(destination);
    }

    // ADMIN ADD AUDIO GUIDE
    @Transactional
    public DestinationResponse addAudioScript(Long destinationId, String audioScript) {
        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new AppException(ErrorCode.DESTINATION_NOT_EXISTED));

        // Kiểm tra nếu đã có audio rồi thì báo lỗi hoặc yêu cầu dùng chức năng Update
        if (destination.getAudioScript() != null && !destination.getAudioScript().isEmpty()) {
            throw new AppException(ErrorCode.AUDIO_ALREADY_EXISTS); // Bạn cần định nghĩa thêm ErrorCode này
        }

        destination.setAudioScript(audioScript);
        destinationRepository.save(destination);

        log.info("Admin đã thêm mới Audio cho: {}", destination.getName());
        return destinationMapper.toDestinationResponse(destination);
    }

    // ADMIN DELETE AUDIO GUIDE
    @Transactional
    public DestinationResponse deleteAudioScript(Long destinationId) {
        // 1. Kiểm tra địa điểm có tồn tại không
        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new AppException(ErrorCode.DESTINATION_NOT_EXISTED));

        // 2. Xóa nội dung thuyết minh (đặt về null)
        destination.setAudioScript(null);

        // 3. Lưu vào database
        destinationRepository.saveAndFlush(destination);

        log.info("Admin đã xóa Audio Script của địa điểm: {} (ID: {})",
                destination.getName(), destinationId);

        // 4. Trả về kết quả đã cập nhật
        return destinationMapper.toDestinationResponse(destination);
    }
}
