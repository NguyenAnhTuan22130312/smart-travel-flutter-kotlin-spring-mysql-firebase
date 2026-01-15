package com.example.smart_travel_BE.entity;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

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
    @JsonIgnore
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

    @Column(columnDefinition = "TEXT")
    private String notificationSettings;

    @Column(columnDefinition = "TEXT")
    private String languageSettings;

    @Builder.Default
    private Boolean darkModeEnabled = false;

    @Builder.Default
    @Column(name = "experience_points")
    private Long experiencePoints = 0L;

    @Builder.Default
    @Column(name = "current_level", length = 50)
    private String currentLevel = "Đồng";

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @ElementCollection
    @CollectionTable(name = "user_listened_destinations", joinColumns = @JoinColumn(name = "user_profile_id"))
    @Column(name = "destination_id")
    private Set<Long> listenedDestinationIds = new HashSet<>();

    @Builder.Default
    @ElementCollection
    @CollectionTable(name = "user_destination_cooldowns",
            joinColumns = @JoinColumn(name = "user_profile_id"))
    @MapKeyColumn(name = "destination_id")
    @Column(name = "last_earned_at")
    private Map<Long, LocalDateTime> lastEarnedAt = new HashMap<>();

    @PrePersist
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}