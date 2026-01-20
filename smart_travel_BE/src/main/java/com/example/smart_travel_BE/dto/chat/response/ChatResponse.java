package com.example.smart_travel_BE.dto.chat.response;

import com.example.smart_travel_BE.dto.chat.RecommendationDTO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChatResponse {
    private String message;
    private List<RecommendationDTO> recommendations;
}