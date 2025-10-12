package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.destination.request.DestinationRequest;
import com.example.smart_travel_BE.dto.destination.response.DestinationResponse;
import com.example.smart_travel_BE.entity.Destination;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface DestinationMapper {
    Destination toDestination(DestinationRequest destinationRequest);
    DestinationResponse toDestinationResponse(Destination destination);
}
