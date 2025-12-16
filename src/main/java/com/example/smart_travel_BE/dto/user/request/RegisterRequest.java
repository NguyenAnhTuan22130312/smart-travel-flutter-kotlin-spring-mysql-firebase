package com.example.smart_travel_BE.dto.user.request;


import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequest {

    @NotBlank(message = "NOT_BLANK_FULL_NAME")
    @Size(min = 2, max = 100, message = "SIZE_NAME")
    private String fullName;

    @NotBlank(message = "EMAIL_NOT_NULL")
    @Email(message = "EMAIL_INVALID")
    private String email;

    @Pattern(regexp = "^[0-9]{10}$", message = "PHONE_ERROR")
    private String phone;

    @NotBlank(message = "PASS_NOT_NULL")
    @Size(min = 8, message = "PASS_INVALID")
    private String password;

    @NotBlank(message = "PASS_CONFIRM_NOT_NULL")
    private String confirmPassword;

}
