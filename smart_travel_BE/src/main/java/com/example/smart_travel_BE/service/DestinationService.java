package com.example.smart_travel_BE.service;

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
     * Lấy danh sách địa điểm nổi bật
     */
    public List<DestinationResponse> getAllDestinationsFeatured() {
        List<Destination> destinations = destinationRepository.findByIsFeaturedTrue();
        return destinations.stream().map(destinationMapper::toDestinationResponse)
                .collect(Collectors.toList());
    }

}
