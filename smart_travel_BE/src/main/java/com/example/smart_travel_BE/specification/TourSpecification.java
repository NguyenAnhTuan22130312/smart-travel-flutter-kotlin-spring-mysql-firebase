package com.example.smart_travel_BE.specification;

import com.example.smart_travel_BE.entity.Tour;
import org.springframework.data.jpa.domain.Specification;

import jakarta.persistence.criteria.Predicate;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class TourSpecification {

    public static Specification<Tour> filter(Map<String, Object> filter) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (filter == null) return cb.and(predicates.toArray(new Predicate[0]));

            if (filter.get("destinationId") != null) {
                Long destId = Long.valueOf(filter.get("destinationId").toString());
                predicates.add(cb.equal(root.get("destination").get("id"), destId));
            }
            if (filter.get("minPrice") != null) {
                BigDecimal min = new BigDecimal(filter.get("minPrice").toString());
                predicates.add(cb.greaterThanOrEqualTo(root.get("pricePerPerson"), min));
            }
            if (filter.get("maxPrice") != null) {
                BigDecimal max = new BigDecimal(filter.get("maxPrice").toString());
                predicates.add(cb.lessThanOrEqualTo(root.get("pricePerPerson"), max));
            }
            if (filter.get("minDays") != null) {
                Integer minD = Integer.valueOf(filter.get("minDays").toString());
                predicates.add(cb.greaterThanOrEqualTo(root.get("durationDays"), minD));
            }
            if (filter.get("maxDays") != null) {
                Integer maxD = Integer.valueOf(filter.get("maxDays").toString());
                predicates.add(cb.lessThanOrEqualTo(root.get("durationDays"), maxD));
            }
            if (filter.get("isActive") != null) {
                Boolean isActive = Boolean.valueOf(filter.get("isActive").toString());
                predicates.add(cb.equal(root.get("isActive"), isActive));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
