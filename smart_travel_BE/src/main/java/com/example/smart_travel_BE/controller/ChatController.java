package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.chat.request.ChatRequest;
import com.example.smart_travel_BE.dto.chat.response.ChatResponse;
import com.example.smart_travel_BE.service.GeminiChatService;
import jakarta.validation.Valid; import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController @RequestMapping("/api/v1/chat") @RequiredArgsConstructor public class ChatController {

    private final GeminiChatService geminiChatService;

    @PostMapping
    public ResponseEntity<ChatResponse> chat(@Valid @RequestBody ChatRequest request) {
        try {
            // 1. Gọi Service để xử lý tin nhắn với Gemini
            String reply = geminiChatService.sendMessage(request.getMessage());

            // 2. Trả về câu trả lời
            return ResponseEntity.ok(new ChatResponse(reply));

        } catch (Exception e) {
            // 3. Xử lý lỗi nếu có
            return ResponseEntity.internalServerError()
                    .body(new ChatResponse("Hệ thống đang bận: " + e.getMessage()));
        }
    }
}