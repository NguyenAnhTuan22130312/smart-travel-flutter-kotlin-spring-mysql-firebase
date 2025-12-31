package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.entity.Destination;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.Tour;
import com.example.smart_travel_BE.repository.DestinationRepository;
import com.example.smart_travel_BE.repository.HotelRepository;
import com.example.smart_travel_BE.repository.TourRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
@RequiredArgsConstructor
public class HuggingFaceChatService { // Bạn có thể giữ tên cũ GeminiChatService nếu lười sửa Controller

    @Value("${huggingface.api.key}")
    private String apiKey;

    private final TourRepository tourRepository;
    private final HotelRepository hotelRepository;
    private final DestinationRepository destinationRepository;

    // Sử dụng RestTemplate có sẵn của Spring để gọi API
    private final RestTemplate restTemplate = new RestTemplate();

    // Model Mistral-7B cực ngon, nhanh và miễn phí trên HF
    private static final String HF_API_URL =
            "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2";


    @Transactional(readOnly = true)
    public String sendMessage(String userMessage) {
        try {
            // 1. Trích xuất địa điểm
            String keyword = extractLocation(userMessage);

            // 2. Tìm dữ liệu DB
            String contextData = findRelevantData(keyword);

            // 3. Tạo Prompt
            String prompt = String.format(
                    "[INST] Bạn là trợ lý du lịch Smart Travel. " +
                            "Hãy trả lời câu hỏi dựa trên dữ liệu sau. Trả lời ngắn gọn bằng Tiếng Việt.\n" +
                            "Dữ liệu: %s\n" +
                            "Câu hỏi: %s [/INST]",
                    contextData, userMessage
            );

            // 4. Gọi Hugging Face
            return callHuggingFaceAI(prompt);

        } catch (Exception e) {
            e.printStackTrace();
            return "Xin lỗi, hệ thống đang bận. (" + e.getMessage() + ")";
        }
    }

    private String extractLocation(String userMessage) {
        // Prompt đặc biệt để trích xuất từ khóa
        String prompt = String.format(
                "[INST] Nhiệm vụ: Chỉ trả về tên địa danh/tỉnh thành trong câu sau. Không giải thích thêm.\n" +
                        "Ví dụ: 'Tìm khách sạn ở Đà Lạt' -> Đà Lạt\n" +
                        "Câu: '%s' [/INST]",
                userMessage
        );
        try {
            String result = callHuggingFaceAI(prompt);
            // Làm sạch kết quả (xóa dấu chấm, xuống dòng thừa)
            return result.replace("Example:", "").trim();
        } catch (Exception e) {
            return userMessage;
        }
    }

    // Hàm gọi API chung
    private String callHuggingFaceAI(String prompt) {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(apiKey);
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> body = new HashMap<>();
        body.put("inputs", prompt);
        body.put("parameters", Map.of(
                "max_new_tokens", 300,
                "return_full_text", false
        ));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<List> response =
                    restTemplate.postForEntity(HF_API_URL, entity, List.class);

            if (response.getBody() != null && !response.getBody().isEmpty()) {
                Map<String, Object> first = (Map<String, Object>) response.getBody().get(0);
                return (String) first.get("generated_text");
            }
            return "Không có phản hồi.";
        } catch (Exception e) {
            return "Lỗi kết nối HuggingFace: " + e.getMessage();
        }
    }

    private String findRelevantData(String keyword) {
        // (Giữ nguyên logic cũ của bạn, không thay đổi gì ở đây)
        StringBuilder dataBuilder = new StringBuilder();
        Set<Hotel> foundHotels = new HashSet<>();
        Set<Tour> foundTours = new HashSet<>();

        List<Destination> destinations = destinationRepository.findByNameContainingIgnoreCase(keyword);

        for (Destination dest : destinations) {
            foundHotels.addAll(hotelRepository.findByDestination(dest));
            foundTours.addAll(tourRepository.findByDestination(dest));
        }

        if (destinations.isEmpty()) {
            foundHotels.addAll(hotelRepository.findByNameContainingIgnoreCase(keyword));
            foundTours.addAll(tourRepository.findByNameContainingIgnoreCase(keyword));
        }

        if (foundHotels.isEmpty() && foundTours.isEmpty()) {
            return "Không tìm thấy dữ liệu về '" + keyword + "'.";
        }

        if (!foundHotels.isEmpty()) {
            dataBuilder.append("=== KHÁCH SẠN ===\n");
            for (Hotel h : foundHotels) {
                dataBuilder.append(String.format("- %s (%s sao) | Giá: %.0f VND\n",
                        h.getName(), h.getStarRating(), h.getPricePerNight()));
            }
        }

        if (!foundTours.isEmpty()) {
            dataBuilder.append("=== TOUR ===\n");
            for (Tour t : foundTours) {
                dataBuilder.append(String.format("- %s | Giá: %.0f VND\n", t.getName(), t.getPricePerPerson()));
            }
        }

        return dataBuilder.toString();
    }
}