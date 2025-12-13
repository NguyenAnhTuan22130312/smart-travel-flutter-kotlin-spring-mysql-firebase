package com.example.smart_travel_BE.dto.tour.request;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class TourFilterRequest {

    private String keyword;

    private Double minPrice;
    private Double maxPrice;

    private Integer minDays;
    private Integer maxDays;

    private Integer minPeople;

    private Double minRating;

    // sort = price_asc, price_desc, rating_desc, popular_desc, newest, oldest
    private String sort;

    private Integer page = 0;
    private Integer size = 10;
}
