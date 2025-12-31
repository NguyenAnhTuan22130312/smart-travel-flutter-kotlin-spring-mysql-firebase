package com.example.smart_travel_BE.dto.user.request;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateUserRequest {
    
    @NotBlank(message = "Tên không được để trống")
    private String fullName;
    
    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không hợp lệ")
    private String email;
    
    @NotBlank(message = "Mật khẩu không được để trống")
    @Size(min = 6, message = "Mật khẩu phải có ít nhất 6 ký tự")
    private String password;
    
    @Pattern(regexp = "^[0-9]{10,11}$", message = "Số điện thoại phải có 10-11 chữ số")
    private String phone;
    
    @Min(value = 1900, message = "Năm sinh không hợp lệ")
    @Max(value = 2024, message = "Năm sinh không hợp lệ")
    private Integer birthYear;
    
    @Pattern(regexp = "^(USER|ADMIN|ADMINTOUR|ADMINHOTEL)$", message = "Role phải là USER, ADMIN, ADMINTOUR hoặc ADMINHOTEL")
    @Builder.Default
    private String role = "USER";
    
    // Optional profile fields
    @Pattern(regexp = "^(Nam|Nữ|Khác)?$", message = "Giới tính không hợp lệ")
    private String gender;
    
    private String dateOfBirth; // Format: yyyy-MM-dd
    
    private String address;
    
    private String city;
    
    private String country;
    
    private String bio;
}
