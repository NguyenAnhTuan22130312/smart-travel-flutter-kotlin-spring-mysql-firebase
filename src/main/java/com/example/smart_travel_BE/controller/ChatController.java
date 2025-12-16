package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.chat.request.ChatRequest;
import com.example.smart_travel_BE.dto.chat.response.ChatResponse;
import com.example.smart_travel_BE.service.DeepSeekChatService;
import com.example.smart_travel_BE.service.GeminiChatService;
import com.example.smart_travel_BE.service.HuggingFaceChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
public class ChatController {

    private final GeminiChatService geminiChatService;
    private final HuggingFaceChatService chatService; // Thêm cái mới
    private final DeepSeekChatService deepSeekChatService;

    // SỬA CHỖ NÀY:
    @PostMapping
    public ResponseEntity<ChatResponse> askAI(@RequestBody ChatRequest request) {
        // Lấy message từ object ChatRequest
        String reply = chatService.sendMessage(request.getMessage());

        // Trả về object ChatResponse chuẩn JSON
        return ResponseEntity.ok(new ChatResponse(reply));
    }
}