package com.example.smart_travel_BE.dto.user.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserListRequest {
    
    @Min(value = 0, message = "Page phải lớn hơn hoặc bằng 0")
    @Builder.Default
    private Integer page = 0;
    
    @Min(value = 1, message = "Size phải lớn hơn 0")
    @Max(value = 100, message = "Size không được vượt quá 100")
    @Builder.Default
    private Integer size = 10;
    
    // Tìm kiếm theo tên, email hoặc số điện thoại
    private String searchKeyword;
    
    // Lọc theo vai trò: USER, ADMIN (null = tất cả)
    private String role;
    
    // Sắp xếp theo field nào (mặc định: createdAt)
    @Builder.Default
    private String sortBy = "createdAt";
    
    // Hướng sắp xếp: ASC hoặc DESC
    @Builder.Default
    private String sortDirection = "DESC";
}
