package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.hotel.request.HotelFilterRequest;
import com.example.smart_travel_BE.dto.hotel.response.HotelDetailResponse;
import com.example.smart_travel_BE.dto.hotel.response.HotelResponse;
import com.example.smart_travel_BE.service.HotelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/hotels")
public class HotelController {

    @Autowired
    private HotelService hotelService;

    @GetMapping
    // Lấy danh sách khách sạn theo địa điểm (destination)
    public Page<HotelResponse> getHotels(
            @RequestParam(required = false) Long destinationId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer minStars,
            @RequestParam(required = false) Integer maxStars,
            @RequestParam(required = false) Double minPrice,
            @RequestParam(required = false) Double maxPrice,
            @RequestParam(required = false) String city,
            @RequestParam(required = false, defaultValue = "0") Integer page,
            @RequestParam(required = false, defaultValue = "10") Integer size
    ) {
        HotelFilterRequest req = new HotelFilterRequest();
        req.setDestinationId(destinationId);
        req.setKeyword(keyword);
        req.setMinStars(minStars);
        req.setMaxStars(maxStars);
        if (minPrice != null) req.setMinPrice(BigDecimal.valueOf(minPrice));
        if (maxPrice != null) req.setMaxPrice(BigDecimal.valueOf(maxPrice));
        req.setCity(city);
        req.setPage(page);
        req.setSize(size);

        return hotelService.getHotels(req);
    }

    /**
     * Lấy thông tin chi tiết khách sạn + phòng trống theo ngày
     * Ví dụ: GET /api/hotels/5/detail?checkIn=2025-10-15&checkOut=2025-10-20
     */
    @GetMapping("/{id}/detail")
    public ResponseEntity<HotelDetailResponse> getHotelDetail(
            @PathVariable("id") Long hotelId,
            @RequestParam("checkIn") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate checkIn,
            @RequestParam("checkOut") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate checkOut
    ) {
        HotelDetailResponse response = hotelService.getHotelDetail(hotelId, checkIn, checkOut);
        return ResponseEntity.ok(response);
    }
}