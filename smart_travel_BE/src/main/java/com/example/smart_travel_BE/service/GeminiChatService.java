package com.example.smart_travel_BE.service;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;

import com.example.smart_travel_BE.entity.Tour;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.Destination;
import com.example.smart_travel_BE.repository.TourRepository;
import com.example.smart_travel_BE.repository.HotelRepository;
import com.example.smart_travel_BE.repository.DestinationRepository;

@Service
@RequiredArgsConstructor
public class GeminiChatService {

    @Value("${gemini.api.key}")
    private String apiKey;

    private final TourRepository tourRepository;
    private final HotelRepository hotelRepository;
    private final DestinationRepository destinationRepository;

    private Client client;

    // Dùng model nhẹ để trích xuất từ khóa cho nhanh
    private static final String MODEL_ID = "gemini-2.5-pro";

    @PostConstruct
    public void init() {
        this.client = Client.builder().apiKey(apiKey).build();
    }

    @Transactional(readOnly = true)
    public String sendMessage(String userMessage) {
        try {
            // BƯỚC 1: TRÍCH XUẤT TỪ KHÓA (Quan trọng nhất)
            // "Tìm khách sạn ở Bà Nà Hills" -> "Bà Nà Hills"
            String keyword = extractLocation(userMessage);

            // BƯỚC 2: Tìm dữ liệu bằng từ khóa sạch
            String contextData = findRelevantData(keyword);

            // BƯỚC 3: Tạo Prompt trả lời
            String fullPrompt = String.format(
                    "Bạn là trợ lý du lịch Smart Travel. Dựa vào dữ liệu sau để trả lời.\n" +
                            "Câu hỏi: \"%s\"\n" +
                            "Dữ liệu hệ thống:\n%s\n" +
                            "Yêu cầu: Trả lời ngắn gọn, thân thiện. Nếu có khách sạn/tour, hãy nêu tên và giá.",
                    userMessage,
                    contextData
            );

            GenerateContentResponse response = client.models.generateContent(MODEL_ID, fullPrompt, null);
            return response.text();

        } catch (Exception e) {
            e.printStackTrace(); // Xem log lỗi nếu có
            return "Lỗi hệ thống: " + e.getMessage();
        }
    }

    /**
     * Dùng AI để lọc ra tên địa điểm từ câu nói tự nhiên
     */
    private String extractLocation(String userMessage) {
        try {
            String prompt = "Nhiệm vụ: Trích xuất duy nhất tên địa danh/tỉnh thành từ câu sau. Không giải thích.\n" +
                    "Ví dụ: 'Tìm khách sạn ở Đà Lạt' -> 'Đà Lạt'\n" +
                    "Câu: \"" + userMessage + "\"";

            GenerateContentResponse response = client.models.generateContent(MODEL_ID, prompt, null);
            String extracted = response.text().trim().replace("\n", "").replace(".", "");

            System.out.println("DEBUG - User: " + userMessage + " -> Extracted: " + extracted);
            return extracted;
        } catch (Exception e) {
            return userMessage; // Nếu lỗi thì tìm nguyên câu
        }
    }

    private String findRelevantData(String keyword) {
        StringBuilder dataBuilder = new StringBuilder();
        Set<Hotel> foundHotels = new HashSet<>();
        Set<Tour> foundTours = new HashSet<>(); // Lưu ý: Bảng Tour có thể chưa có dữ liệu

        // 1. Tìm Destination trước
        List<Destination> destinations = destinationRepository.findByNameContainingIgnoreCase(keyword);

        // 2. Nếu tìm thấy địa điểm, lấy hotel/tour của địa điểm đó
        for (Destination dest : destinations) {
            foundHotels.addAll(hotelRepository.findByDestination(dest));
            foundTours.addAll(tourRepository.findByDestination(dest));
        }

        // 3. Tìm fallback (tìm trực tiếp trong tên Hotel/Tour)
        if (destinations.isEmpty()) {
            foundHotels.addAll(hotelRepository.findByNameContainingIgnoreCase(keyword));
            foundTours.addAll(tourRepository.findByNameContainingIgnoreCase(keyword));
        }

        // 4. Build String kết quả
        if (foundHotels.isEmpty() && foundTours.isEmpty()) {
            return "Không tìm thấy dữ liệu về '" + keyword + "' trong hệ thống.";
        }

        if (!foundHotels.isEmpty()) {
            dataBuilder.append("=== KHÁCH SẠN ===\n");
            for (Hotel h : foundHotels) {
                dataBuilder.append(String.format("- %s (%s sao) | Giá: %.0f VND | ĐC: %s\n",
                        h.getName(), h.getStarRating(), h.getPricePerNight(), h.getAddress()));
            }
        }

        // Lưu ý: SQL Dump của bạn chưa có bảng Tours, nên phần này có thể sẽ trống
        if (!foundTours.isEmpty()) {
            dataBuilder.append("=== TOUR ===\n");
            for (Tour t : foundTours) {
                dataBuilder.append(String.format("- %s | Giá: %.0f VND\n", t.getName(), t.getPricePerPerson()));
            }
        }

        return dataBuilder.toString();
    }
}