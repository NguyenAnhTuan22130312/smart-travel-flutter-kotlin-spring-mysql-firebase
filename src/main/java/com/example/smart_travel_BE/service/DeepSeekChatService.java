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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
@RequiredArgsConstructor
public class DeepSeekChatService {

    @Value("${deepseek.api.key}")
    private String apiKey;

    private final TourRepository tourRepository;
    private final HotelRepository hotelRepository;
    private final DestinationRepository destinationRepository;

    private final RestTemplate restTemplate = new RestTemplate();

    private static final String DEEPSEEK_URL =
            "https://api.deepseek.com/v1/chat/completions";

    // ==============================
    // 1) LOGIC CHÍNH (GIỮ NGUYÊN)
    // ==============================
    @Transactional(readOnly = true)
    public String sendMessage(String userMessage) {
        try {
            // 1. Trích xuất địa điểm
            String keyword = extractLocation(userMessage);

            // 2. Lấy dữ liệu liên quan từ DB
            String contextData = findRelevantData(keyword);

            // 3. Tạo Prompt đầy đủ
            String prompt = String.format(
                    "Bạn là trợ lý du lịch Smart Travel. "
                            + "Hãy trả lời ngắn gọn bằng tiếng Việt dựa trên dữ liệu sau:\n\n"
                            + "DỮ LIỆU:\n%s\n\n"
                            + "CÂU HỎI: %s",
                    contextData, userMessage
            );

            // 4. Gọi DeepSeek
            return callDeepSeek(prompt);

        } catch (Exception e) {
            return "Xin lỗi, hệ thống đang bận. (" + e.getMessage() + ")";
        }
    }

    // ==============================
    // 2) TRÍCH XUẤT ĐỊA ĐIỂM (GIỮ NGUYÊN LOGIC)
    // ==============================
    private String extractLocation(String userMessage) {
        String prompt = String.format(
                "Chỉ trả về tên địa danh/tỉnh thành trong câu sau (không giải thích thêm).\n"
                        + "Ví dụ: 'Tìm khách sạn ở Đà Lạt' -> Đà Lạt\n"
                        + "Câu: %s", userMessage
        );

        try {
            String result = callDeepSeek(prompt);
            return result.trim();
        } catch (Exception e) {
            return userMessage; // fallback
        }
    }

    // ==============================
    // 3) GỌI API DEEPSEEK (CHỈ THAY ĐỔI PHẦN NÀY)
    // ==============================
    private String callDeepSeek(String prompt) {

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        Map<String, Object> body = new HashMap<>();
        body.put("model", "deepseek-chat");
        body.put("messages", List.of(
                Map.of("role", "user", "content", prompt)
        ));
        body.put("max_tokens", 300);

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);

        try {
            Map<String, Object> response =
                    restTemplate.postForObject(DEEPSEEK_URL, request, Map.class);

            List<Map<String, Object>> choices =
                    (List<Map<String, Object>>) response.get("choices");

            Map<String, Object> msg =
                    (Map<String, Object>) choices.get(0).get("message");

            return (String) msg.get("content");

        } catch (Exception e) {
            return "Lỗi gọi DeepSeek: " + e.getMessage();
        }
    }

    // ==============================
    // 4) LẤY DỮ LIỆU TỪ DB (GIỮ NGUYÊN)
    // ==============================
    private String findRelevantData(String keyword) {
        StringBuilder dataBuilder = new StringBuilder();
        Set<Hotel> foundHotels = new HashSet<>();
        Set<Tour> foundTours = new HashSet<>();

        List<Destination> destinations = destinationRepository
                .findByNameContainingIgnoreCase(keyword);

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
                dataBuilder.append(String.format(
                        "- %s (%s sao) | Giá: %.0f VND\n",
                        h.getName(), h.getStarRating(), h.getPricePerNight()));
            }
        }

        if (!foundTours.isEmpty()) {
            dataBuilder.append("=== TOUR ===\n");
            for (Tour t : foundTours) {
                dataBuilder.append(String.format(
                        "- %s | Giá: %.0f VND\n",
                        t.getName(), t.getPricePerPerson()));
            }
        }

        return dataBuilder.toString();
    }
}
