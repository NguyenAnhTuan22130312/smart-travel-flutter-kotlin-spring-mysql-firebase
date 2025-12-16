package com.example.smart_travel_BE.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDateTime;

@Entity
@Table(name = "refresh_tokens")
@FieldDefaults(level = AccessLevel.PRIVATE)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RefreshToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;

    @Column(nullable = false, unique = true)
    String token;

    @ManyToOne
    @JoinColumn(name = "userId", nullable = false)
    User user;

    @Column(nullable = false)
    LocalDateTime expiryDate;

    @Column(nullable = false)
    private boolean revoked = false;
}