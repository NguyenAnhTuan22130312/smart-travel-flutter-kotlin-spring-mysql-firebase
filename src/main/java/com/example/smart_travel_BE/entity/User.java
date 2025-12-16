package com.example.smart_travel_BE.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "users",
        indexes = {
                @Index(name = "idx_email", columnList = "email"),
                @Index(name = "idx_phone", columnList = "phone")
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // tương ứng AUTO_INCREMENT trong MySQL
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Column(length = 255)
    private String password;

    @Column(name = "full_name", length = 100)
    private String fullName;

    @Column(length = 15)
    private String phone;

    @Column(nullable = false, length = 20)
    private String role;

    @Column(name = "auth_provider", length = 50)
    private String authProvider;

    @Column(name = "firebase_uid", length = 255)
    private String firebaseUid;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "email_verified", nullable = false)
    private Boolean emailVerified = false;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    /**
     * Tự động set thời gian tạo/cập nhật
     */
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
