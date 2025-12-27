package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.destination.response.DestinationResponse;
import com.example.smart_travel_BE.entity.Destination;
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
                String detectedType = (String) aiResult.get("type");

                // Lấy List Entity từ DB
                List<Destination> rawDestinations = destinationRepository.findSuggestDestinations(detectedType);

                // 🔥 QUAN TRỌNG: Convert từ Entity sang DTO để tránh lỗi JSON/User ID 0
                List<DestinationResponse> dtoList = rawDestinations.stream()
                        .map(this::mapToDTO) // Gọi hàm map ở dưới
                        .collect(Collectors.toList());

                finalResult.put("success", true);
                finalResult.put("ai_detected", detectedType);
                finalResult.put("confidence", aiResult.get("confidence"));
                finalResult.put("data", dtoList); // Trả về DTO thay vì Entity
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

    // Hàm chuyển đổi thủ công để đảm bảo an toàn tuyệt đối
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

        // --- SỬA LỖI IMAGE TẠI ĐÂY ---
        // Logic: Tìm ảnh có isPrimary = true. Nếu không có thì lấy ảnh đầu tiên.
        if (entity.getImages() != null && !entity.getImages().isEmpty()) {
            String finalUrl = entity.getImages().stream()
                    .filter(img -> Boolean.TRUE.equals(img.getIsPrimary())) // Tìm ảnh chính
                    .findFirst()
                    .map(img -> img.getImageUrl()) // Lấy URL
                    .orElse(entity.getImages().get(0).getImageUrl()); // Fallback: lấy ảnh đầu tiên

            dto.setImageUrl(finalUrl);
        } else {
            dto.setImageUrl(null); // Hoặc set 1 ảnh default nếu muốn
        }
        // -----------------------------

        // Xử lý Province
        if (entity.getProvince() != null) {
            dto.setProvinceName(entity.getProvince().getName());
        } else {
            dto.setProvinceName("Chưa cập nhật");
        }

        return dto;
    }
}