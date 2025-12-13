package com.example.smart_travel_BE.specification;

import com.example.smart_travel_BE.entity.Tour;
import org.springframework.data.jpa.domain.Specification;

import java.math.BigDecimal;

public class TourSpecification {

    public static Specification<Tour> nameContains(String keyword) {
        return (root, query, cb) -> {
            if (keyword == null || keyword.isBlank()) return null;
            return cb.like(cb.lower(root.get("name")), "%" + keyword.toLowerCase() + "%");
        };
    }

    public static Specification<Tour> priceBetween(Double min, Double max) {
        return (root, query, cb) -> {

            if (min == null && max == null) return null;

            if (min != null && max != null) {
                return cb.between(root.get("pricePerPerson"),
                        BigDecimal.valueOf(min),
                        BigDecimal.valueOf(max));
            }

            if (min != null) {
                return cb.greaterThanOrEqualTo(root.get("pricePerPerson"), BigDecimal.valueOf(min));
            }

            return cb.lessThanOrEqualTo(root.get("pricePerPerson"), BigDecimal.valueOf(max));
        };
    }

    public static Specification<Tour> daysBetween(Integer min, Integer max) {
        return (root, query, cb) -> {
            if (min == null && max == null) return null;

            if (min != null && max != null) {
                return cb.between(root.get("durationDays"), min, max);
            }

            if (min != null) {
                return cb.greaterThanOrEqualTo(root.get("durationDays"), min);
            }

            return cb.lessThanOrEqualTo(root.get("durationDays"), max);
        };
    }

    public static Specification<Tour> peopleMin(Integer minPeople) {
        return (root, query, cb) -> {
            if (minPeople == null) return null;
            return cb.greaterThanOrEqualTo(root.get("maxPeople"), minPeople);
        };
    }

    public static Specification<Tour> ratingMin(Double minRating) {
        return (root, query, cb) -> {
            if (minRating == null) return null;
            return cb.greaterThanOrEqualTo(
                    root.get("averageRating"),
                    BigDecimal.valueOf(minRating)
            );
        };
    }
}
