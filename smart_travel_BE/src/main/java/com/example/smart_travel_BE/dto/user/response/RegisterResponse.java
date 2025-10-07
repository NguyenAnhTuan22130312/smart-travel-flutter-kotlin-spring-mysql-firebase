package com.example.smart_travel_BE.dto.user.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RegisterResponse {
    private Long id;
    private String email;
    private String fullName;
    private String message;
}
