package com.example.smart_travel_BE.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "vouchers")
@Data
public class Voucher {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String code;

    private BigDecimal discountAmount; // Số tiền giảm

    private LocalDateTime expiryDate;
    private Boolean isActive;
    private Integer usageLimit; // Giới hạn số lần dùng
    @Column(name = "points_required")
    private Long pointsRequired;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "image_url")
    private String imageUrl;
}