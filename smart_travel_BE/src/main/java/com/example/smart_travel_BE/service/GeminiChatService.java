package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.chat.RecommendationDTO;
import com.example.smart_travel_BE.dto.chat.response.ChatResponse;
import com.example.smart_travel_BE.entity.Destination;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.Tour;
import com.example.smart_travel_BE.repository.DestinationRepository;
import com.example.smart_travel_BE.repository.HotelRepository;
import com.example.smart_travel_BE.repository.TourRepository;
import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class GeminiChatService {

    @Value("${gemini.api.key}")
    private String apiKey;

    private final TourRepository tourRepository;
    private final HotelRepository hotelRepository;
    private final DestinationRepository destinationRepository;

    private Client client;
    private static final String MODEL_ID = "gemini-2.5-pro";

    @PostConstruct
    public void init() {
        if (apiKey != null && !apiKey.isEmpty()) {
            this.client = Client.builder().apiKey(apiKey).build();
        }
    }

    @Transactional(readOnly = true)
    public ChatResponse processUserMessage(String userMessage) {
        String msgLower = userMessage.toLowerCase();

        if (msgLower.contains("giá rẻ") || msgLower.contains("rẻ nhất")) {
            return handleCheapSearch(msgLower);
        }

        Double priceLimit = extractPriceFromMessage(msgLower);
        if (priceLimit != null) {
            return handlePriceSearch(priceLimit, msgLower);
        }

        if (client != null) {
            try {
                String keyword = extractLocationAI(userMessage);

                if (keyword == null || keyword.length() < 2) {
                    return fallbackSearch(userMessage);
                }

                return findAndMapData(keyword, userMessage);
            } catch (Exception e) {
                System.err.println("Gemini Error: " + e.getMessage());
                return fallbackSearch(userMessage);
            }
        }

        return fallbackSearch(userMessage);
    }

    private ChatResponse handleCheapSearch(String message) {
        List<RecommendationDTO> recommendations = new ArrayList<>();
        String replyText = "Dưới đây là các gợi ý có giá tốt nhất:";

        boolean wantHotel = message.contains("khách sạn") || message.contains("hotel");
        boolean wantTour = message.contains("tour");

        if (!wantHotel && !wantTour) {
            wantHotel = true;
            wantTour = true;
        }

        if (wantHotel) {
            recommendations.addAll(hotelRepository.findTop5ByOrderByPricePerNightAsc()
                    .stream().map(this::mapHotelToDTO).toList());
        }
        if (wantTour) {
            recommendations.addAll(tourRepository.findTop5ByOrderByPricePerPersonAsc()
                    .stream().map(this::mapTourToDTO).toList());
        }

        if (recommendations.isEmpty()) {
            return new ChatResponse("Hiện tại hệ thống chưa có dữ liệu giá rẻ.", new ArrayList<>());
        }
        return new ChatResponse(replyText, recommendations);
    }

    private ChatResponse handlePriceSearch(Double priceLimit, String message) {
        BigDecimal priceBD = BigDecimal.valueOf(priceLimit);
        List<RecommendationDTO> recommendations = new ArrayList<>();

        boolean wantHotel = message.contains("khách sạn") || message.contains("hotel");
        boolean wantTour = message.contains("tour");
        if (!wantHotel && !wantTour) { wantHotel = true; wantTour = true; }

        if (wantTour) {
            recommendations.addAll(tourRepository.findByPricePerPersonLessThanEqual(priceBD)
                    .stream().map(this::mapTourToDTO).toList());
        }
        if (wantHotel) {
            recommendations.addAll(hotelRepository.findByPricePerNightBetween(BigDecimal.ZERO, priceBD)
                    .stream().map(this::mapHotelToDTO).toList());
        }

        if (recommendations.isEmpty()) {
            return new ChatResponse("Không tìm thấy dịch vụ nào dưới " + formatMoney(priceLimit), new ArrayList<>());
        }
        return new ChatResponse("Kết quả tìm kiếm dưới " + formatMoney(priceLimit) + ":", recommendations);
    }


    private ChatResponse findAndMapData(String keyword, String fullMessage) {
        List<RecommendationDTO> recommendations = new ArrayList<>();
        String msgLower = fullMessage.toLowerCase();

        boolean wantHotel = msgLower.contains("khách sạn") || msgLower.contains("hotel") || msgLower.contains("nghỉ");
        boolean wantTour = msgLower.contains("tour") || msgLower.contains("du lịch") || msgLower.contains("tham quan");
        if (!wantHotel && !wantTour) { wantHotel = true; wantTour = true; }

        List<Destination> destinations = destinationRepository.findByNameContainingIgnoreCase(keyword);

        if (!destinations.isEmpty()) {
            for (Destination dest : destinations) {
                if (wantHotel) {
                    List<Hotel> hotels = hotelRepository.findByDestinationOrderByPricePerNightAsc(dest);
                    recommendations.addAll(hotels.stream().map(this::mapHotelToDTO).toList());
                }
                if (wantTour) {
                    List<Tour> tours = tourRepository.findByDestination(dest);
                    recommendations.addAll(tours.stream().map(this::mapTourToDTO).toList());
                }
            }
        } else {
            if (wantHotel) {
                List<Hotel> hotels = hotelRepository.findByNameContainingIgnoreCase(keyword);
                recommendations.addAll(hotels.stream().map(this::mapHotelToDTO).toList());
            }
            if (wantTour) {
                List<Tour> tours = tourRepository.findByNameContainingIgnoreCase(keyword);
                recommendations.addAll(tours.stream().map(this::mapTourToDTO).toList());
            }
        }

        String replyText;
        if (recommendations.isEmpty()) {
            replyText = "Rất tiếc, tôi không tìm thấy thông tin nào liên quan đến '" + keyword + "'.";
        } else {
            boolean isDestination = !destinations.isEmpty();
            if (isDestination) {
                replyText = "Gợi ý tuyệt vời cho chuyến đi đến " + destinations.get(0).getName() + " của bạn:";
            } else {
                replyText = "Kết quả tìm kiếm cho \"" + keyword + "\":";
            }
        }

        return new ChatResponse(replyText, recommendations);
    }

    private ChatResponse fallbackSearch(String message) {
        String locationParams = extractLocationRegex(message);
        if (!locationParams.isEmpty()) {
            return findAndMapData(locationParams, message);
        }
        return new ChatResponse("Tôi chưa hiểu rõ ý bạn. Hãy thử: 'Khách sạn Đà Lạt', 'Tour giá rẻ', hoặc 'Dưới 2 triệu'.", new ArrayList<>());
    }


    private RecommendationDTO mapHotelToDTO(Hotel hotel) {
        String imgUrl = (hotel.getImages() != null && !hotel.getImages().isEmpty())
                ? hotel.getImages().get(0).getImageUrl() : null;

        return RecommendationDTO.builder()
                .id(hotel.getId())
                .name(hotel.getName())
                .imageUrl(imgUrl)
                .address(hotel.getAddress())
                .price(hotel.getPricePerNight().doubleValue())
                .rating(hotel.getStarRating() != null ? Double.valueOf(hotel.getStarRating()) : 0.0)
                .reviewCount(100)
                .type("HOTEL")
                .build();
    }

    private RecommendationDTO mapTourToDTO(Tour tour) {
        String imgUrl = (tour.getImages() != null && !tour.getImages().isEmpty())
                ? tour.getImages().get(0).getImageUrl() : null;

        return RecommendationDTO.builder()
                .id(tour.getId())
                .name(tour.getName())
                .imageUrl(imgUrl)
                .address(tour.getDestination() != null ? tour.getDestination().getName() : "Việt Nam")
                .price(tour.getPricePerPerson().doubleValue())
                .rating(4.5)
                .reviewCount(50)
                .type("TOUR")
                .build();
    }

    private String extractLocationAI(String userMessage) {
        try {
            String prompt = "Trích xuất tên địa danh từ câu: \"" + userMessage + "\". Chỉ trả về tên, không giải thích. Nếu không có địa danh cụ thể, trả về rỗng.";
            GenerateContentResponse response = client.models.generateContent(MODEL_ID, prompt, null);
            String result = response.text().trim().replace("\n", "").replace(".", "");
            if (result.toLowerCase().contains("không có") || result.toLowerCase().contains("rỗng")) {
                return "";
            }
            return result;
        } catch (Exception e) {
            return extractLocationRegex(userMessage);
        }
    }

    private String extractLocationRegex(String message) {
        Pattern pattern = Pattern.compile("(?:ở|tại|đến|đi|trong)\\s+([\\p{L}\\s]+)", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CHARACTER_CLASS);
        Matcher matcher = pattern.matcher(message);
        return matcher.find() ? matcher.group(1).trim() : "";
    }

    private Double extractPriceFromMessage(String message) {
        try {
            Pattern pK = Pattern.compile("(\\d+)[kK]");
            Matcher mK = pK.matcher(message);
            if (mK.find()) return Double.parseDouble(mK.group(1)) * 1000;

            Pattern pM = Pattern.compile("(\\d+(?:\\.\\d+)?)?\\s*triệu");
            Matcher mM = pM.matcher(message);
            if (mM.find()) return Double.parseDouble(mM.group(1)) * 1000000;

            Pattern pN = Pattern.compile("(\\d{3,})");
            Matcher mN = pN.matcher(message);
            if (mN.find()) return Double.parseDouble(mN.group(1));

            return null;
        } catch (Exception e) { return null; }
    }

    private String formatMoney(Double amount) {
        if (amount == null) return "0 đ";
        return NumberFormat.getCurrencyInstance(new Locale("vi", "VN")).format(amount);
    }
}