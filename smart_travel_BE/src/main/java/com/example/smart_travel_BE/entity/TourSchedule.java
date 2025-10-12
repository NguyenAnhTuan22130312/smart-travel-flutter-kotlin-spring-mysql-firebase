package com.example.smart_travel_BE.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "tour_schedules")
public class TourSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tour_id", nullable = false)
    private Tour tour;

    @Column(name = "day_number", nullable = false)
    private Integer dayNumber;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "activities", nullable = false, columnDefinition = "TEXT")
    private String activities;

    @Column(name = "accommodation", length = 100)
    private String accommodation;

    @Column(name = "meals", columnDefinition = "JSON")
    private String meals;
}