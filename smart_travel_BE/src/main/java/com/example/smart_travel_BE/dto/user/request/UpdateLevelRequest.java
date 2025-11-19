package com.example.smart_travel_BE.dto.user.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateLevelRequest {

    @Min(value = 0, message = "Điểm kinh nghiệm không được âm")
    private Long experiencePoints;

    @Size(max = 100, message = "Tên huy hiệu không được quá 100 ký tự")
    private String currentBadge;

    @Size(max = 2000, message = "Danh sách thành tích không được quá 2000 ký tự")
    private String achievements;
}

