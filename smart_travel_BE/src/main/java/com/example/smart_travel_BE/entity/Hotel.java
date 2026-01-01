package com.example.smart_travel_BE.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@Entity
@Table(name = "hotels",
        indexes = {
                @Index(name = "idx_destination_id", columnList = "destination_id"),
                @Index(name = "idx_star_rating", columnList = "star_rating DESC"),
                @Index(name = "idx_owner_id", columnList = "owner_id")
        })
public class Hotel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "destination_id", nullable = false)
    @JsonIgnore
    private Destination destination;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "address", nullable = false, length = 255)
    private String address;

    @Column(name = "latitude", nullable = false)
    private Double latitude;

    @Column(name = "longitude", nullable = false)
    private Double longitude;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "star_rating", nullable = false)
    private Integer starRating = 0; // tương ứng HotelResponse.stars

    @Column(name = "price_per_night", precision = 10, scale = 2)
    private BigDecimal pricePerNight; // giá mặc định / hiển thị

    @Column(name = "average_rating", precision = 3, scale = 2)
    private BigDecimal averageRating = BigDecimal.ZERO;

    @Column(name = "review_count", nullable = false)
    private Integer reviewCount = 0;

    @Column(name = "total_rooms", nullable = false)
    private Integer totalRooms = 0;

    @Column(name = "available_rooms", nullable = false)
    private Integer availableRooms = 0;

    @Column(name = "amenities", columnDefinition = "JSON")
    private String amenities;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @OneToMany(mappedBy = "hotel", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<HotelImage> images = new ArrayList<>();

    @OneToMany(mappedBy = "hotel", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RoomType> roomTypes = new ArrayList<>();

    /**
     * Lấy ảnh chính làm thumbnail
     */
    public String getThumbnail() {
        return images.stream()
                .filter(HotelImage::getIsPrimary)
                .findFirst()
                .map(HotelImage::getImageUrl)
                .orElse(images.isEmpty() ? null : images.get(0).getImageUrl());
    }

    /**
     * Lấy giá rẻ nhất trong các RoomType
     */
    public BigDecimal getMinPrice() {
        return roomTypes.stream()
                .map(RoomType::getPrice)
                .filter(p -> p != null)
                .min(BigDecimal::compareTo)
                .orElse(pricePerNight);
    }
}