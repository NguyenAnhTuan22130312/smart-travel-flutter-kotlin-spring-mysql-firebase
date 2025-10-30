package com.example.smart_travel_BE.specification;

import com.example.smart_travel_BE.dto.hotel.request.HotelFilterRequest;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.Destination;
import com.example.smart_travel_BE.entity.Province;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.math.BigDecimal;

public class HotelSpecification {

    public static Specification<Hotel> filter(HotelFilterRequest req) {
        return (root, query, cb) -> {
            Predicate predicate = cb.conjunction();

            // 1. Lọc theo destinationId
            if (req.getDestinationId() != null) {
                predicate = cb.and(predicate,
                        cb.equal(root.get("destination").get("id"), req.getDestinationId()));
            }

            // 2. Lọc theo keyword (tìm trong tên, địa chỉ, tên điểm đến, tên tỉnh)
            if (req.getKeyword() != null && !req.getKeyword().isBlank()) {
                String kw = "%" + req.getKeyword().trim().toLowerCase() + "%";
                Join<Hotel, Destination> destJoin = root.join("destination", JoinType.LEFT);
                Join<Destination, Province> provJoin = destJoin.join("province", JoinType.LEFT);

                predicate = cb.and(predicate, cb.or(
                        cb.like(cb.lower(root.get("name")), kw),
                        cb.like(cb.lower(root.get("address")), kw),
                        cb.like(cb.lower(destJoin.get("name")), kw),
                        cb.like(cb.lower(provJoin.get("name")), kw)
                ));
            }

            // 3. Lọc theo số sao (starRating)
            if (req.getMinStars() != null) {
                predicate = cb.and(predicate,
                        cb.ge(root.get("starRating"), req.getMinStars()));
            }
            if (req.getMaxStars() != null) {
                predicate = cb.and(predicate,
                        cb.le(root.get("starRating"), req.getMaxStars()));
            }

            // 4. Lọc theo khoảng giá — dùng pricePerNight
            if (req.getMinPrice() != null) {
                predicate = cb.and(predicate,
                        cb.ge(root.get("pricePerNight"), req.getMinPrice()));
            }
            if (req.getMaxPrice() != null) {
                predicate = cb.and(predicate,
                        cb.le(root.get("pricePerNight"), req.getMaxPrice()));
            }

            // 5. Lọc theo tên thành phố (province.name)
            if (req.getCity() != null && !req.getCity().isBlank()) {
                Join<Hotel, Destination> destJoin = root.join("destination", JoinType.LEFT);
                Join<Destination, Province> provJoin = destJoin.join("province", JoinType.LEFT);
                String cityKw = "%" + req.getCity().trim().toLowerCase() + "%";
                predicate = cb.and(predicate, cb.like(cb.lower(provJoin.get("name")), cityKw));
            }

            return predicate;
        };
    }
}
