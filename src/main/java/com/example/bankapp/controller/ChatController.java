package com.example.bankapp.controller;

import com.example.bankapp.security.AuthenticatedUser;
import com.example.bankapp.service.ChatService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class ChatController {

    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @PostMapping("/chat")
    public Map<String, String> chat(@AuthenticationPrincipal AuthenticatedUser user,
                                    @Valid @RequestBody ChatRequest request) {
        String reply = chatService.chat(user.getUsername(), request.message().trim());
        return Map.of("reply", reply);
    }

    public record ChatRequest(
        @NotBlank(message = "Message is required")
        @Size(max = 1000, message = "Message must be at most 1000 characters")
        String message
    ) {
    }
}
