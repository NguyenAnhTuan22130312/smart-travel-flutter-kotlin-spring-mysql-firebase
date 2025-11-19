package com.example.smart_travel_BE.service;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

// --- IMPORT CHÍNH THỨC TỪ GOOGLE GEN AI SDK ---
import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;

// Import các Entity và Repository của bạn
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

    // Inject các Repository để lấy dữ liệu
    private final TourRepository tourRepository;
    private final HotelRepository hotelRepository;
    private final DestinationRepository destinationRepository;

    // Client của thư viện mới
    private Client client;

    @PostConstruct
    public void init() {
        // Khởi tạo Client.
        // Thư viện com.google.genai hỗ trợ Builder để truyền API Key
        this.client = Client.builder()
                .apiKey(apiKey)
                .build();
    }

    /**
     * Hàm xử lý chính: Nhận tin nhắn -> Tìm DB -> Gọi Gemini
     */
    @Transactional(readOnly = true)
    public String sendMessage(String userMessage) {
        try {
            // 1. Tìm kiếm dữ liệu liên quan trong Database (RAG)
            String contextData = findRelevantData(userMessage);

            // 2. Tạo System Prompt (Hướng dẫn hành vi cho Bot)
            String systemInstruction =
                    "Bạn là trợ lý AI của 'Smart Travel', chuyên tư vấn du lịch Việt Nam.\n" +
                            "NHIỆM VỤ: Tư vấn tour và khách sạn dựa trên [DỮ LIỆU HỆ THỐNG] được cung cấp dưới đây.\n" +
                            "QUY TẮC:\n" +
                            "1. CHỈ được gợi ý các dịch vụ có trong dữ liệu. KHÔNG được bịa ra tour/khách sạn không có thật.\n" +
                            "2. Nếu dữ liệu trống hoặc không liên quan, hãy nói: 'Hiện tôi chưa tìm thấy dịch vụ phù hợp trong hệ thống, bạn có thể thử tìm địa điểm khác'.\n" +
                            "3. Trả lời ngắn gọn, chuyên nghiệp, có kèm giá tiền (VND) và địa chỉ/thời gian.";

            // 3. Ghép toàn bộ thành một prompt hoàn chỉnh
            // (Thư viện mới này gọi kiểu REST, nên ta gửi context trong mỗi request)
            String fullPrompt = String.format(
                    "%s\n\n[DỮ LIỆU HỆ THỐNG]:\n%s\n\n[CÂU HỎI CỦA KHÁCH]:\n\"%s\"",
                    systemInstruction,
                    contextData,
                    userMessage
            );

            // 4. Gọi API Gemini (Sử dụng model Flash cho nhanh và rẻ)
            //https://ai.google.dev/gemini-api/docs/models?hl=vi#gemini-2.5-pro
            // Cú pháp chuẩn của thư viện com.google.genai
            GenerateContentResponse response = client.models.generateContent(
                    "gemini-2.5-pro", // Hoặc "gemini-2.0-flash" nếu bạn có quyền truy cập
                    fullPrompt,
                    null // Config (nếu muốn chỉnh temperature thì truyền vào đây)
            );

            // 5. Trả về kết quả text
            return response.text();

        } catch (Exception e) {
            e.printStackTrace();
            return "Hệ thống đang gặp sự cố kết nối với AI: " + e.getMessage();
        }
    }

    /**
     * Hàm tìm kiếm thông minh trong Database (Logic RAG)
     * Không thay đổi so với trước, vì nó hoạt động tốt với JPA
     */
    private String findRelevantData(String keyword) {
        StringBuilder dataBuilder = new StringBuilder();
        Set<Tour> foundTours = new HashSet<>();
        Set<Hotel> foundHotels = new HashSet<>();

        // A. Tìm theo Destination (Ví dụ khách chat "Đà Lạt")
        List<Destination> destinations = destinationRepository.findByNameContainingIgnoreCase(keyword);
        for (Destination dest : destinations) {
            foundTours.addAll(tourRepository.findByDestination(dest));
            foundHotels.addAll(hotelRepository.findByDestination(dest));
        }

        // B. Tìm theo tên trực tiếp (Ví dụ khách chat "Tour leo núi")
        foundTours.addAll(tourRepository.findByNameContainingIgnoreCase(keyword));
        foundHotels.addAll(hotelRepository.findByNameContainingIgnoreCase(keyword));

        // C. Format dữ liệu thành văn bản để gửi cho Gemini
        if (foundTours.isEmpty() && foundHotels.isEmpty()) {
            return "Không tìm thấy dữ liệu nào trong database khớp với từ khóa.";
        }

        if (!foundTours.isEmpty()) {
            dataBuilder.append("--- DANH SÁCH TOUR CÓ SẴN ---\n");
            for (Tour t : foundTours) {
                dataBuilder.append(String.format(
                        "- Tên: %s | Giá: %s VND | Thời gian: %d ngày %d đêm | Điểm đến: %s | Mô tả: %s\n",
                        t.getName(),
                        t.getPricePerPerson(),
                        t.getDurationDays(),
                        t.getDurationNights(),
                        t.getDestination().getName(),
                        t.getDescription() != null ? t.getDescription().substring(0, Math.min(t.getDescription().length(), 50)) + "..." : ""
                ));
            }
            dataBuilder.append("\n");
        }

        if (!foundHotels.isEmpty()) {
            dataBuilder.append("--- DANH SÁCH KHÁCH SẠN CÓ SẴN ---\n");
            for (Hotel h : foundHotels) {
                dataBuilder.append(String.format(
                        "- Tên: %s | Hạng: %d sao | Giá từ: %s VND | Địa chỉ: %s | Tiện ích: %s\n",
                        h.getName(),
                        h.getStarRating(),
                        h.getPricePerNight(),
                        h.getAddress(),
                        h.getAmenities() // Gửi kèm tiện ích (JSON string)
                ));
            }
        }

        return dataBuilder.toString();
    }
}