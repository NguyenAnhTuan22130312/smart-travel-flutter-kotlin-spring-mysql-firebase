package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.hotel.request.HotelCreateRequest;
import com.example.smart_travel_BE.dto.hotel.request.HotelFilterRequest;
import com.example.smart_travel_BE.dto.hotel.response.HotelDetailResponse;
import com.example.smart_travel_BE.dto.hotel.response.HotelResponse;
import com.example.smart_travel_BE.service.HotelService;
import com.fasterxml.jackson.core.JsonProcessingException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/hotels")
public class HotelController {

    @Autowired
    private HotelService hotelService;

    /**
     * Tạo ra một khách sạn
     * PUT /api/v1/hotels/{id}
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMINHOTEL')")
    public ResponseEntity<HotelDetailResponse> createHotel(
            @RequestBody HotelCreateRequest request
    ) throws JsonProcessingException {
        HotelDetailResponse created = hotelService.createHotel(request);
        return ResponseEntity.ok(created);
    }

    /**
     * Cập nhật thông tin khách sạn
     * PUT /api/v1/hotels/{id}
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMINHOTEL')")
    public ResponseEntity<HotelDetailResponse> updateHotel(
            @PathVariable("id") Long hotelId,
            @RequestBody HotelCreateRequest request
    ) throws JsonProcessingException {
        HotelDetailResponse updated = hotelService.updateHotel(hotelId, request);
        return ResponseEntity.ok(updated);
    }

    /**
     * Xóa ẩn khách hạn
     * PUT /api/v1/hotels/{id}
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMINHOTEL')")
    public ResponseEntity<String> deleteHotel(@PathVariable("id") Long hotelId) {
        hotelService.deleteHotel(hotelId);
        return ResponseEntity.ok("Đã xóa khách sạn thành công.");
    }

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
            @RequestParam(required = false, defaultValue = "10") Integer size,
            @RequestParam(required = false, defaultValue = "pricePerNight") String sortBy,
            @RequestParam(required = false, defaultValue = "asc") String sortDir
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
        req.setSortBy(sortBy);
        req.setSortDir(sortDir);

        return hotelService.getHotels(req);
    }

    /**
     * Lấy thông tin chi tiết khách sạn + phòng trống theo ngày
     * Ví dụ: GET /api/hotels/5/detail?checkIn=2025-10-15&checkOut=2025-10-20
     */
    @GetMapping("/{id}/detail")
    public ResponseEntity<HotelDetailResponse> getHotelDetail(
            @PathVariable("id") Long hotelId,
            @RequestParam(value = "checkIn", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate checkIn,

            @RequestParam(value = "checkOut", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate checkOut
    ) {
        // Nếu không truyền → dùng ngày hôm nay và mai
        LocalDate in = (checkIn != null) ? checkIn : LocalDate.now();
        LocalDate out = (checkOut != null) ? checkOut : in.plusDays(1);

        // Đảm bảo checkOut > checkIn
        if (out.isBefore(in) || out.equals(in)) {
            out = in.plusDays(1);
        }
        HotelDetailResponse response = hotelService.getHotelDetail(hotelId, in, out);
        return ResponseEntity.ok(response);
    }
}