package com.example.smart_travel_BE.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Quan hệ 1-1 với bảng users
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "avatar_url", length = 500)
    private String avatarUrl;

    @Column(columnDefinition = "TEXT")
    private String bio;

    @Column(length = 10)
    private String gender;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(length = 100)
    private String address;

    @Column(length = 50)
    private String city;

    @Column(length = 50)
    private String country;

    // JSON lưu dưới dạng chuỗi (Spring JPA không có kiểu JSON native)
    @Column(columnDefinition = "JSON")
    private String preferences;

    @Column(name = "language_settings", columnDefinition = "JSON")
    private String languageSettings;

    @Column(name = "dark_mode_enabled", nullable = false)
    private Boolean darkModeEnabled = false;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}