package com.example.smart_travel_BE.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "invoices",
        indexes = {
                @Index(name = "idx_booking_id", columnList = "booking_id"),
                @Index(name = "idx_invoice_number", columnList = "invoice_number")
        })
public class Invoice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false)
    private Booking booking;

    @Column(name = "invoice_number", nullable = false, unique = true, length = 50)
    private String invoiceNumber;

    @Column(name = "total_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "tax_amount", precision = 12, scale = 2)
    private BigDecimal taxAmount = BigDecimal.ZERO;

    @Column(name = "item_details", nullable = false, columnDefinition = "JSON")
    private String itemDetails;

    @Column(name = "issue_date", nullable = false)
    private LocalDate issueDate;

    @Column(name = "is_reviewed", nullable = false)
    private boolean isReviewed = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
