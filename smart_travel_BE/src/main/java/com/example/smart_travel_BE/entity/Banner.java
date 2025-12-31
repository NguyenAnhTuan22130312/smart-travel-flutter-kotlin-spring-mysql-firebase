package com.example.smart_travel_BE.entity;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Entity
@Table(name = "banners")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Banner {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    String title;       // Tiêu đề banner
    String imageUrl;    // Link ảnh banner
    String linkUrl;     // Link điều hướng khi click vào banner
    String description; // Mô tả ngắn về chương trình du lịch
    boolean active;     // Trạng thái hiển thị
}