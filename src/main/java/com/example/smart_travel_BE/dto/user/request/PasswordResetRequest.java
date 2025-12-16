package com.example.smart_travel_BE.dto.user.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PasswordResetRequest {
    private String token;

    @NotBlank(message = "PASS_NOT_NULL")
    @Size(min = 8, message = "PASS_INVALID")
    private String password;

    @NotBlank(message = "PASS_CONFIRM_NOT_NULL")
    private  String passwordConfirm;
}
