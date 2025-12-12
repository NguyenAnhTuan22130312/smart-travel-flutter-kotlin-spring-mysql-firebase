package com.example.smart_travel_BE.specification;

import com.example.smart_travel_BE.entity.User;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;

public class UserSpecification {

    /**
     * Tìm kiếm user theo keyword (tên, email, hoặc số điện thoại)
     * @param keyword từ khóa tìm kiếm
     * @return Specification để build query
     */
    public static Specification<User> searchByKeyword(String keyword) {
        return (root, query, criteriaBuilder) -> {
            if (keyword == null || keyword.trim().isEmpty()) {
                return criteriaBuilder.conjunction(); // Trả về true (không filter)
            }

            String likePattern = "%" + keyword.toLowerCase() + "%";
            List<Predicate> predicates = new ArrayList<>();

            // Tìm theo fullName
            predicates.add(criteriaBuilder.like(
                    criteriaBuilder.lower(root.get("fullName")), 
                    likePattern
            ));

            // Tìm theo email
            predicates.add(criteriaBuilder.like(
                    criteriaBuilder.lower(root.get("email")), 
                    likePattern
            ));

            // Tìm theo phone
            predicates.add(criteriaBuilder.like(
                    criteriaBuilder.lower(root.get("phone")), 
                    likePattern
            ));

            // OR: tìm theo bất kỳ field nào
            return criteriaBuilder.or(predicates.toArray(new Predicate[0]));
        };
    }
}
