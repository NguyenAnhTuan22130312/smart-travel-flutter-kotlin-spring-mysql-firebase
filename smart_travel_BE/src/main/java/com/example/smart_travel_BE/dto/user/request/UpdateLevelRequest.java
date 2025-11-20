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

}

