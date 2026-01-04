package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.review.response.ReviewResponse;
import com.example.smart_travel_BE.entity.Review;
import com.example.smart_travel_BE.entity.ReviewImage;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;
@Component
@RequiredArgsConstructor
public class ReviewMapper {


    public List<ReviewResponse> toReviewResponseList(List<Review> reviews) {
        return reviews.stream()
                .map(this::toReviewResponse)
                .collect(Collectors.toList());
    }

    private ReviewResponse toReviewResponse(Review review) {
        List<String> imageUrls = review.getImages() != null && !review.getImages().isEmpty()
                ? review.getImages().stream()
                .map(ReviewImage::getImageUrl)
                .collect(Collectors.toList())
                : null;

        return ReviewResponse.builder()
                .id(review.getId())
                .userFullName(review.getUser() != null ? review.getUser().getFullName() : "Anonymous")
                .rating(review.getRating())
                .comment(review.getComment())
                .likesCount(review.getLikesCount())
                .isApproved(review.getIsApproved())
                .createdAt(review.getCreatedAt())
                .images(imageUrls)
                .build();
    }
}
