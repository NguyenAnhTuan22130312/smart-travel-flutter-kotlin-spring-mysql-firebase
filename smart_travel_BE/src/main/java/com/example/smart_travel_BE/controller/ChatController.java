package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.chat.request.ChatRequest;
import com.example.smart_travel_BE.dto.chat.response.ChatResponse;
import com.example.smart_travel_BE.service.GeminiChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
public class ChatController {

    private final GeminiChatService geminiChatService;

    @PostMapping
    public ResponseEntity<ChatResponse> askAI(@RequestBody ChatRequest request) {
        ChatResponse response = geminiChatService.processUserMessage(request.getMessage());
        return ResponseEntity.ok(response);
    }
}