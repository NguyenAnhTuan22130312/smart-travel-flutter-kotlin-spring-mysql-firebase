package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.review.request.DestinationReviewRequest;
import com.example.smart_travel_BE.dto.review.request.ReviewRequest;
import com.example.smart_travel_BE.dto.review.response.ReviewResponse;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.entity.Review;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.service.ReviewService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/v1/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping("/invoice-review")
    public APIResponse<Review> createInvoiceReview(
            @Valid @ModelAttribute ReviewRequest request,  // ← Dùng @ModelAttribute
            @RequestParam(value = "images", required = false) List<MultipartFile> images) {  // ← ảnh optional

        // Gán images vào request nếu có
        request.setImages(images);
        Review review = reviewService.createInvoiceReview(request);

        return APIResponse.<Review>builder()
                .code(1000)
                .msg("Gửi đánh giá thành công. Đánh giá sẽ được hiển thị sau khi admin phê duyệt.")
                .data(review)
                .build();
    }
    @PostMapping("/destination-review")
    public APIResponse<Review> createDestinationReview(
            @Valid @ModelAttribute DestinationReviewRequest request,
            @RequestParam(value = "images", required = false) List<MultipartFile> images) {

        request.setImages(images);

        Review review = reviewService.createDestinationReview(request);

        return APIResponse.<Review>builder()
                .code(1000)
                .msg("Gửi đánh giá điểm đến thành công. Đánh giá sẽ được hiển thị sau khi admin phê duyệt.")
                .data(review)
                .build();
    }



    @GetMapping("/hotel/{hotelId}")
    public APIResponse<List<ReviewResponse>> getHotelReviews(
            @PathVariable Long hotelId,
            @RequestParam(required = false) Integer rating,
            @RequestParam(required = false) Boolean hasImage) {

        List<ReviewResponse> reviews = reviewService.getHotelReviews(hotelId, rating, hasImage);
        return APIResponse.<List<ReviewResponse>>builder()
                .code(1000)
                .msg("Lấy đánh giá khách sạn thành công")
                .data(reviews)
                .build();
    }

    @GetMapping("/tour/{tourId}")
    public APIResponse<List<ReviewResponse>> getTourReviews(
            @PathVariable Long tourId,
            @RequestParam(required = false) Integer rating,
            @RequestParam(required = false) Boolean hasImage) {

        List<ReviewResponse> reviews = reviewService.getTourReviews(tourId, rating, hasImage);
        return APIResponse.<List<ReviewResponse>>builder()
                .code(1000)
                .msg("Lấy đánh giá tour thành công")
                .data(reviews)
                .build();
    }

    @GetMapping("/destination/{destinationId}")
    public APIResponse<List<ReviewResponse>> getDestinationReviews(
            @PathVariable Long destinationId,
            @RequestParam(required = false) Integer rating,
            @RequestParam(required = false) Boolean hasImage) {

        List<ReviewResponse> reviews = reviewService.getDestinationReviews(destinationId, rating, hasImage);
        return APIResponse.<List<ReviewResponse>>builder()
                .code(1000)
                .msg("Lấy đánh giá điểm đến thành công")
                .data(reviews)
                .build();
    }

    // src/main/java/com/example/smart_travel_BE/controller/ReviewController.java

    @GetMapping("/get-reviews")
    public APIResponse<List<ReviewResponse>> getReviews(
            @RequestParam String type,
            @RequestParam Long serviceId,
            @RequestParam(required = false) Integer rating,
            @RequestParam(required = false) Boolean hasImage) {

        List<ReviewResponse> reviews;

        switch (type.toUpperCase()) {
            case "HOTEL":
                reviews = reviewService.getHotelReviews(serviceId, rating, hasImage);
                break;
            case "TOUR":
                reviews = reviewService.getTourReviews(serviceId, rating, hasImage);
                break;
            case "DESTINATION":
                reviews = reviewService.getDestinationReviews(serviceId, rating, hasImage);
                break;
            default:
                throw new AppException(ErrorCode.INVALID_TYPE);
        }

        return APIResponse.<List<ReviewResponse>>builder()
                .code(1000)
                .msg("Lấy danh sách đánh giá thành công")
                .data(reviews)
                .build();
    }
}