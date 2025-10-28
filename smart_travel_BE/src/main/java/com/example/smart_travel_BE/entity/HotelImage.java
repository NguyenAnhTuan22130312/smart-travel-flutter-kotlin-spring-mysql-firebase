package com.example.smart_travel_BE.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "hotel_images")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // URL ảnh (đường dẫn ảnh trên server hoặc CDN)
    @Column(nullable = false, length = 500)
    private String url;

    // Mỗi ảnh thuộc về một khách sạn
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hotel_id", nullable = false)
    private Hotel hotel;

    // Loại ảnh (thumbnail, room, outside...) — nếu bạn muốn phân loại
    @Column(length = 100)
    private String type;
}
