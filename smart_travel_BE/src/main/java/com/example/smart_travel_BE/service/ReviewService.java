
package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.review.request.DestinationReviewRequest;
import com.example.smart_travel_BE.dto.review.request.ReviewRequest;
import com.example.smart_travel_BE.dto.review.response.ReviewResponse;
import com.example.smart_travel_BE.entity.*;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.mapper.ReviewMapper;
import com.example.smart_travel_BE.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final ReviewImageRepository reviewImageRepository;
    private final UserRepository userRepository;
    private final CloudinaryService cloudinaryService;
    private final InvoiceRepository invoiceRepository;
    private  final DestinationRepository destinationRepository;
    private final ReviewMapper reviewMapper;

//    @Transactional
//    public Review createInvoiceReview(ReviewRequest request) {
//
//        User user = getCurrentUser();
//        // Tìm Invoice theo invoiceNumber
//        Invoice invoice = invoiceRepository.findByInvoiceNumber(request.getInvoiceNumber())
//                .orElseThrow(() -> new AppException(ErrorCode.INVOICE_NOT_FOUND));
//
//        Booking booking = invoice.getBooking();
//
//        // Tạo Review
//        Review review = Review.builder()
//                .user(user)  // lấy từ booking
//                .rating(request.getRating())
//                .comment(request.getComment())
//                .isApproved(false)
//                .likesCount(0)
//                .createdAt(LocalDateTime.now())
//                .updatedAt(LocalDateTime.now())
//                .build();
//
//        // Set id theo bookingType
//        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
//            review.setHotelId(booking.getHotelId());
//        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
//            review.setTourId(booking.getTourId());
//        }
//
//        review = reviewRepository.save(review);
//        if (review.getImages() != null) {
//            review.getImages().size();
//        }
//
//        // Upload ảnh nếu có
//        if (request.getImages() != null && !request.getImages().isEmpty()) {
//            List<ReviewImage> images = new ArrayList<>();
//            for (MultipartFile file : request.getImages()) {
//                try {
//                    String imageUrl = cloudinaryService.uploadFile(file, "reviews");
//                    ReviewImage image = ReviewImage.builder()
//                            .review(review)
//                            .imageUrl(imageUrl)
//                            .uploadedAt(LocalDateTime.now())
//                            .build();
//                    images.add(image);
//                } catch (IOException e) {
//                    throw new AppException(ErrorCode.IMAGE_UPLOAD_FAILED);
//                }
//            }
//            reviewImageRepository.saveAll(images);
//        }
//
//        invoice.setReviewed(true);
//        invoiceRepository.save(invoice);
//
//
//        return review;
//    }

    @Transactional
    public Review createInvoiceReview(ReviewRequest request) {
        User currentUser = getCurrentUser();

        Invoice invoice = invoiceRepository.findByInvoiceNumber(request.getInvoiceNumber())
                .orElseThrow(() -> new AppException(ErrorCode.INVOICE_NOT_FOUND));

        Booking booking = invoice.getBooking();

        if (!currentUser.getId().equals(booking.getUser().getId())) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        Destination destination = null;

        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            Hotel hotel = invoiceRepository.findHotelWithImagesById(booking.getHotelId()).orElse(null);
            if (hotel != null) {
                destination = hotel.getDestination();
            }
        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            Tour tour = invoiceRepository.findTourWithImagesById(booking.getTourId()).orElse(null);
            if (tour != null) {
                destination = tour.getDestination();
            }
        }

        if (destination == null) {
            throw new AppException(ErrorCode.DESTINATION_NOT_FOUND);  // nếu không lấy được destination
        }

        Review review = Review.builder()
                .user(currentUser)
                .destination(destination)  // ← THÊM DESTINATION TỪ HOTEL/TOUR
                .rating(request.getRating())
                .comment(request.getComment())
                .isApproved(false)
                .likesCount(0)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        if ("HOTEL".equalsIgnoreCase(booking.getBookingType())) {
            review.setHotelId(booking.getHotelId());
        } else if ("TOUR".equalsIgnoreCase(booking.getBookingType())) {
            review.setTourId(booking.getTourId());
        }

        review = reviewRepository.save(review);

        if (request.getImages() != null && !request.getImages().isEmpty()) {
            List<ReviewImage> images = new ArrayList<>();
            for (MultipartFile file : request.getImages()) {
                try {
                    String imageUrl = cloudinaryService.uploadFile(file, "reviews");
                    ReviewImage image = ReviewImage.builder()
                            .review(review)
                            .imageUrl(imageUrl)
                            .uploadedAt(LocalDateTime.now())
                            .build();
                    images.add(image);
                } catch (IOException e) {
                    throw new AppException(ErrorCode.IMAGE_UPLOAD_FAILED);
                }
            }
            reviewImageRepository.saveAll(images);
        }

        invoice.setReviewed(true);
        invoiceRepository.save(invoice);

        return review;
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getPrincipal() == null) {
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }

        if (authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }

        throw new AppException(ErrorCode.UNAUTHENTICATED);
    }

    @Transactional
    public Review createDestinationReview(DestinationReviewRequest request) {
        User currentUser = getCurrentUser();

        Long userId = currentUser.getId();
        Long destinationId = request.getDestinationId();


        if (reviewRepository.existsByUserIdAndDestinationIdAndToday(userId, destinationId)) {
            throw new AppException(ErrorCode.REVIEW_SPAM_DETECTED);  // bạn tạo ErrorCode này
        }

        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new AppException(ErrorCode.DESTINATION_NOT_FOUND));

        // Tạo Review
        Review review = Review.builder()
                .user(currentUser)
                .rating(request.getRating())
                .comment(request.getComment())
                .destination(destination)
                .isApproved(true)
                .likesCount(0)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        review = reviewRepository.save(review);

        // Upload ảnh nếu có
        if (request.getImages() != null && !request.getImages().isEmpty()) {
            List<ReviewImage> images = new ArrayList<>();
            for (MultipartFile file : request.getImages()) {
                try {
                    String imageUrl = cloudinaryService.uploadFile(file, "reviews");
                    ReviewImage image = ReviewImage.builder()
                            .review(review)
                            .imageUrl(imageUrl)
                            .uploadedAt(LocalDateTime.now())
                            .build();
                    images.add(image);
                } catch (IOException e) {
                    throw new AppException(ErrorCode.IMAGE_UPLOAD_FAILED);
                }
            }
            reviewImageRepository.saveAll(images);
        }

        // Force load images để trả về
        if (review.getImages() != null) {
            review.getImages().size();
        }

        return review;
    }

    public List<ReviewResponse> getHotelReviews(Long hotelId, Integer rating, Boolean hasImage) {
        List<Review> reviews = reviewRepository.findApprovedHotelReviews(hotelId, rating, hasImage);
        return reviewMapper.toReviewResponseList(reviews);
    }

    public List<ReviewResponse> getTourReviews(Long tourId, Integer rating, Boolean hasImage) {
        List<Review> reviews = reviewRepository.findApprovedTourReviews(tourId, rating, hasImage);
        return reviewMapper.toReviewResponseList(reviews);
    }

    public List<ReviewResponse> getDestinationReviews(Long destinationId, Integer rating, Boolean hasImage) {
        List<Review> reviews = reviewRepository.findApprovedDestinationReviews(destinationId, rating, hasImage);
        return reviewMapper.toReviewResponseList(reviews);
    }

}