package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.destination.response.DestinationResponse;
import com.example.smart_travel_BE.entity.Destination;
import com.example.smart_travel_BE.entity.DestinationImage;
import com.example.smart_travel_BE.repository.DestinationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@PreAuthorize("permitAll()")
public class AIService {

    private final DestinationRepository destinationRepository;
    private final RestTemplate restTemplate;

    @Value("${ai.service.url}")
    private String pythonServiceUrl;

    private static final Map<String, String> CATEGORY_MAP = new HashMap<>();

    static {
        // Key (Python trả về)  ->  Value (Database tiếng Việt)
        CATEGORY_MAP.put("BEACH", "Biển");
        CATEGORY_MAP.put("NATURE", "Thiên nhiên"); // Núi, Rừng, Thác...
        CATEGORY_MAP.put("LAKE", "Hồ");
        CATEGORY_MAP.put("CULTURE", "Văn hóa");    // Chợ nổi, Làng nghề

        // Nhóm này bạn có thể map về "Di tích lịch sử" hoặc "Tôn giáo" tùy ý
        CATEGORY_MAP.put("HISTORY", "Di tích lịch sử");

        CATEGORY_MAP.put("ENTERTAINMENT", "Khu vui chơi");
    }

    public Map<String, Object> suggestFromImage(MultipartFile imageFile) {
        Map<String, Object> finalResult = new HashMap<>();

        try {
            // 1. Tạo Header
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            // 2. Đóng gói ảnh
            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("file", new ByteArrayResource(imageFile.getBytes()) {
                @Override
                public String getFilename() {
                    return imageFile.getOriginalFilename();
                }
            });

            HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);

            // 3. Gọi sang Python
            ResponseEntity<Map> response = restTemplate.postForEntity(pythonServiceUrl, requestEntity, Map.class);
            Map<String, Object> aiResult = response.getBody();

            // 4. Xử lý kết quả
            if (aiResult != null && aiResult.containsKey("type")) {
                String aiType = (String) aiResult.get("type"); // Ví dụ: BEACH

                // 🔥 2. DỊCH TỪ KHÓA: Tiếng Anh -> Tiếng Việt
                String dbCategory = CATEGORY_MAP.getOrDefault(aiType, aiType);

                System.out.println("AI tìm thấy: " + aiType + " -> Đang tìm trong DB category: " + dbCategory);

                // Tìm trong DB bằng từ khóa Tiếng Việt
                List<Destination> rawDestinations = destinationRepository.findSuggestDestinations(dbCategory);

                // Convert sang DTO để tránh lỗi User ID 0
                List<DestinationResponse> dtoList = rawDestinations.stream()
                        .map(this::mapToDTO)
                        .collect(Collectors.toList());

                finalResult.put("success", true);
                finalResult.put("ai_detected", aiType);       // Loại AI nhìn thấy
                finalResult.put("mapped_category", dbCategory); // Loại tìm trong DB
                finalResult.put("confidence", aiResult.get("confidence"));
                finalResult.put("data", dtoList);
            } else {
                finalResult.put("success", false);
                finalResult.put("message", "AI không nhận diện được.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            finalResult.put("success", false);
            finalResult.put("error", "Lỗi Server: " + e.getMessage());
        }
        return finalResult;
    }

    // Hàm chuyển đổi DTO (Đã sửa lỗi ImageUrl và Province)
    private DestinationResponse mapToDTO(Destination entity) {
        DestinationResponse dto = new DestinationResponse();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setCategory(entity.getCategory());
        dto.setAddress(entity.getAddress());
        dto.setAverageRating(entity.getAverageRating());
        dto.setReviewCount(entity.getReviewCount());
        dto.setViewCount(entity.getViewCount());
        dto.setIsActive(entity.getIsActive());
        dto.setIsFeatured(entity.getIsFeatured());
        dto.setEntryFee(entity.getEntryFee());

        // Xử lý Image: Lấy ảnh Primary, nếu không có lấy ảnh đầu tiên
        if (entity.getImages() != null && !entity.getImages().isEmpty()) {
            String finalUrl = entity.getImages().stream()
                    .filter(img -> Boolean.TRUE.equals(img.getIsPrimary()))
                    .findFirst()
                    .map(DestinationImage::getImageUrl) // Method reference gọn hơn
                    .orElse(entity.getImages().get(0).getImageUrl());

            dto.setImageUrl(finalUrl);
        } else {
            dto.setImageUrl(null);
        }

        // Xử lý Province (tránh NullPointer)
        if (entity.getProvince() != null) {
            dto.setProvinceName(entity.getProvince().getName());
        } else {
            dto.setProvinceName("Chưa cập nhật");
        }

        return dto;
    }
}