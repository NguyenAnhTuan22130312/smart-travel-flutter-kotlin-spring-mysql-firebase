package com.example.smart_travel_BE.dto.user.request;

import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateUserAdminRequest {
    
    private String fullName;
    
    @Pattern(regexp = "^(\\+84|0)[0-9]{9,10}$", message = "Số điện thoại không hợp lệ")
    private String phone;
    
    @Pattern(regexp = "^(USER|ADMIN|ADMINTOUR|ADMINHOTEL)$", message = "Role chỉ được là USER, ADMIN, ADMINTOUR hoặc ADMINHOTEL")
    private String role;
}
