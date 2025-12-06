package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.service.GeminiChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
public class ChatController {

    private final GeminiChatService geminiChatService;

    // SỬA CHỖ NÀY:
    @PostMapping
    public ResponseEntity<String> askAI(@RequestBody String message) {
        // Khi nhận text/plain, biến 'message' sẽ chứa toàn bộ nội dung chuỗi gửi lên
        // Ví dụ: "Chào bạn"

        // Cần xử lý một chút nếu chuỗi bị dính dấu ngoặc kép thừa (do JSON stringify)
        String cleanMessage = message.replace("\"", "").trim();

        String response = geminiChatService.sendMessage(cleanMessage);
        return ResponseEntity.ok(response);
    }
}