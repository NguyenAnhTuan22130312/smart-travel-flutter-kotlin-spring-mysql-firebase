package com.example.smart_travel_BE.dto.user.request;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateProfileRequest {
    
    @Size(min = 2, max = 100, message = "Tên phải từ 2-100 ký tự")
    private String fullName;
    
    @Pattern(regexp = "^[0-9]{10}$", message = "Số điện thoại phải đúng 10 số")
    private String phone;
    
    // Thông tin từ UserProfile
    private String avatarUrl;
    
    @Size(max = 1000, message = "Bio không được quá 1000 ký tự")
    private String bio;
    
    @Pattern(regexp = "^(MALE|FEMALE|OTHER)$", message = "Giới tính phải là MALE, FEMALE hoặc OTHER")
    private String gender;
    
    private LocalDate dateOfBirth;
    
    @Size(max = 100, message = "Địa chỉ không được quá 100 ký tự")
    private String address;
    
    @Size(max = 50, message = "Thành phố không được quá 50 ký tự")
    private String city;
    
    @Size(max = 50, message = "Quốc gia không được quá 50 ký tự")
    private String country;
    
    private String notificationSettings; // JSON string
    private String languageSettings; // JSON string
    private Boolean darkModeEnabled;
}

