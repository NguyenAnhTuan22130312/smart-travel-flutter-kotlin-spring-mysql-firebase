
package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.Invoice;
import com.example.smart_travel_BE.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    @Query("""
    SELECT COUNT(r) > 0 FROM Review r
    WHERE r.user.id = :userId
          AND r.destination.id = :destinationId
      AND DATE(r.createdAt) = CURRENT_DATE
    """)
    boolean existsByUserIdAndDestinationIdAndToday(
            @Param("userId") Long userId,
            @Param("destinationId") Long destinationId);

    // src/main/java/com/example/smart_travel_BE/repository/ReviewRepository.java

// ... các method cũ

    // API 1: Lấy đánh giá Hotel
    @Query("""
    SELECT r FROM Review r
    LEFT JOIN FETCH r.images i
    WHERE r.hotelId = :hotelId
      AND r.isApproved = true
      AND (:rating IS NULL OR r.rating = :rating)
      AND (:hasImage IS NULL 
           OR (:hasImage = true AND EXISTS (SELECT 1 FROM ReviewImage ri WHERE ri.review = r))
           OR (:hasImage = false AND NOT EXISTS (SELECT 1 FROM ReviewImage ri WHERE ri.review = r)))
    ORDER BY r.createdAt DESC
    """)
    List<Review> findApprovedHotelReviews(
            @Param("hotelId") Long hotelId,
            @Param("rating") Integer rating,
            @Param("hasImage") Boolean hasImage);

    // API 2: Lấy đánh giá Tour
    @Query("""
    SELECT r FROM Review r
    LEFT JOIN FETCH r.images i
    WHERE r.tourId = :tourId
      AND r.isApproved = true
      AND (:rating IS NULL OR r.rating = :rating)
      AND (:hasImage IS NULL 
           OR (:hasImage = true AND EXISTS (SELECT 1 FROM ReviewImage ri WHERE ri.review = r))
           OR (:hasImage = false AND NOT EXISTS (SELECT 1 FROM ReviewImage ri WHERE ri.review = r)))
    ORDER BY r.createdAt DESC
    """)
    List<Review> findApprovedTourReviews(
            @Param("tourId") Long tourId,
            @Param("rating") Integer rating,
            @Param("hasImage") Boolean hasImage);

    // API 3: Lấy đánh giá Destination
    @Query("""
    SELECT r FROM Review r
    LEFT JOIN FETCH r.images i
    WHERE r.destination.id = :destinationId
      AND r.isApproved = true
      AND (:rating IS NULL OR r.rating = :rating)
      AND (:hasImage IS NULL 
           OR (:hasImage = true AND EXISTS (SELECT 1 FROM ReviewImage ri WHERE ri.review = r))
           OR (:hasImage = false AND NOT EXISTS (SELECT 1 FROM ReviewImage ri WHERE ri.review = r)))
    ORDER BY r.createdAt DESC
    """)
    List<Review> findApprovedDestinationReviews(
            @Param("destinationId") Long destinationId,
            @Param("rating") Integer rating,
            @Param("hasImage") Boolean hasImage);
}