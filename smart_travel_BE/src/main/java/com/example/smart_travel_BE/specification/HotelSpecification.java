package com.example.smart_travel_BE.specification;

import com.example.smart_travel_BE.dto.hotel.request.HotelFilterRequest;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.Destination;
import com.example.smart_travel_BE.entity.Province;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.math.BigDecimal;

public class HotelSpecification {

    public static Specification<Hotel> filter(HotelFilterRequest req) {
        // cb là CriteriaBuilder : xây dựng truy vấn động (WHERE, LIKE, AND, OR,..)
        return (root, query, cb) -> {
            if (Hotel.class.equals(query.getResultType())) {
                // could fetch images or whatever if needed for performance
            }
            // cb.conjunction() tạo một "predicate" mặc định là TRUE (điều kiện ban đầu)
            Predicate predicate = cb.conjunction();

            // --- 1. Lọc theo destinationId ---
            if (req.getDestinationId() != null) {
                // So sánh id của destination trong entity Hotel
                predicate = cb.and(predicate, cb.equal(root.get("destination").get("id"), req.getDestinationId()));
            }

            // --- 2. Lọc theo keyword ---
            if (req.getKeyword() != null && !req.getKeyword().isBlank()) {
                //keyword
                String kw = "%" + req.getKeyword().trim().toLowerCase() + "%";

                // join để truy cập destination và province
                Join<Hotel, Destination> destJoin = root.join("destination", JoinType.LEFT);
                Join<Destination, Province> provJoin = destJoin.join("province", JoinType.LEFT);

                // Tạo điều kiện: tìm trong name, address của Hotel, hoặc name của Destination, Province
                predicate = cb.and(predicate, cb.or(cb.like(cb.lower(root.get("name")), kw), cb.like(cb.lower(root.get("address")), kw), cb.like(cb.lower(destJoin.get("name")), kw), cb.like(cb.lower(provJoin.get("name")), kw)));
            }

            // --- 3. Lọc theo số sao (stars) ---
            if (req.getMinStars() != null) {
                predicate = cb.and(predicate, cb.ge(root.get("stars"), req.getMinStars()));
            }
            if (req.getMaxStars() != null) {
                predicate = cb.and(predicate, cb.le(root.get("stars"), req.getMaxStars()));
            }

            // --- 4. Lọc theo khoảng giá ---
            // minPrice trong entity là BigDecimal, nên phải convert
            if (req.getMinPrice() != null) {
                predicate = cb.and(predicate, cb.ge(root.get("minPrice"), BigDecimal.valueOf(req.getMinPrice())));
            }
            if (req.getMaxPrice() != null) {
                predicate = cb.and(predicate, cb.le(root.get("minPrice"), BigDecimal.valueOf(req.getMaxPrice())));
            }

            // --- 5. Lọc theo tên thành phố ---
            // thành phố nằm trong province của destination
            if (req.getCity() != null && !req.getCity().isBlank()) {
                Join<Hotel, Destination> destJoin = root.join("destination", JoinType.LEFT);
                Join<Destination, Province> provJoin = destJoin.join("province", JoinType.LEFT);
                String cityKw = "%" + req.getCity().trim().toLowerCase() + "%";
                predicate = cb.and(predicate, cb.like(cb.lower(provJoin.get("name")), cityKw));
            }
            // Trả về tất cả điều kiện kết hợp bằng AND
            return predicate;
        };
    }
}
