package com.example.smart_travel_BE.dto.chat.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @NoArgsConstructor @AllArgsConstructor public class ChatRequest {

    @NotBlank(message = "Tin nhắn không được để trống")
    private String message;
}