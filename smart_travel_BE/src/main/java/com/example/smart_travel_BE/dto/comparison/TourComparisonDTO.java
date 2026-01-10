package com.example.smart_travel_BE.dto.comparison;
import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.util.List;


@Data
@Builder
public class TourComparisonDTO {
    private Long id;
    private String name;
    private String imageUrl; // Lấy ảnh đầu tiên
    private BigDecimal price;
    private Integer durationDays;
    private Integer durationNights;
    private Double rating;
    private Integer reviewCount;
    private String destinationName;


    // Các trường quan trọng để so sánh
    private List<String> included; // Đã parse từ JSON
    private List<String> excluded; // Đã parse từ JSON
    private Integer maxPeople;
}
