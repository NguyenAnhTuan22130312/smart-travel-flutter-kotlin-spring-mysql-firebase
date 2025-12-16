package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.RoomType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface RoomTypeRepository extends JpaRepository<RoomType, Long> {

    @Query("""

            SELECT rt, (rt.totalRooms - COALESCE(SUM(b.numberOfRooms), 0)) AS availableRooms
    FROM RoomType rt
    LEFT JOIN Booking b
        ON b.roomType = rt
        AND (b.startDate < :checkOut AND b.endDate > :checkIn)
    WHERE rt.hotel.id = :hotelId
    GROUP BY rt
    HAVING (rt.totalRooms - COALESCE(SUM(b.numberOfRooms), 0)) > 0
    """)
    List<Object[]> findAvailableRoomsWithCount(
            @Param("hotelId") Long hotelId,
            @Param("checkIn") LocalDate checkIn,
            @Param("checkOut") LocalDate checkOut
    );
}