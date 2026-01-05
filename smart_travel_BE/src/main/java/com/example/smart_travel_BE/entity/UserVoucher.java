package com.example.smart_travel_BE.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_vouchers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserVoucher {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Người sở hữu
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Voucher đã đổi
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "voucher_id", nullable = false)
    private Voucher voucher;

    @Column(name = "is_used")
    private Boolean isUsed = false;

    @Column(name = "redeemed_at")
    private LocalDateTime redeemedAt;

    @PrePersist
    protected void onCreate() {
        redeemedAt = LocalDateTime.now();
        isUsed = false;
    }
}