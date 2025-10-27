package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.destination.response.DestinationFeaturedResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationResponse;
import com.example.smart_travel_BE.entity.Destination;
import com.example.smart_travel_BE.mapper.DestinationMapper;
import com.example.smart_travel_BE.repository.DestinationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DestinationService {
    private final DestinationRepository destinationRepository;
    private final DestinationMapper destinationMapper;


    /**
     * Lấy tất cả danh sách địa điểm
     */
    public List<DestinationResponse> getAllDestinations() {
        List<Destination> destinations = destinationRepository.findAll();

        return destinations.stream().map(destinationMapper::toDestinationResponse)
                .collect(Collectors.toList());
    }
    /**
     * Lấy danh sách địa điểm nổi bật
     */
    public List<DestinationFeaturedResponse> getAllDestinationsFeatured() {
        List<Destination> destinations = destinationRepository.findByIsFeaturedTrue();

        return destinations.stream().map(destinationMapper::toDestinationFeaturedResponse)
                .collect(Collectors.toList());
    }
    /**
     * Lấy danh sách địa điểm nổi bật
     */
    public List<DestinationResponse> filterDestinationsByCategory(String category) {
        List<Destination> destinations = destinationRepository.findAll();
        // Lọc và map sang DTO
        return destinations.stream()
                .filter(d -> d.getCategory() != null &&
                        d.getCategory().equalsIgnoreCase(category))
                .map(destinationMapper::toDestinationResponse)
                .collect(Collectors.toList());
    }

}
