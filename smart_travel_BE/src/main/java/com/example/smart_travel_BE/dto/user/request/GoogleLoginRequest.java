package com.example.smart_travel_BE.dto.user.request;

import lombok.Data;

@Data
public class GoogleLoginRequest {
    private String idToken;
    private String email;
    private String displayName;


}
