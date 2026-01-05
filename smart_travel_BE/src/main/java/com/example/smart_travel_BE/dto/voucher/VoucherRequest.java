package com.example.smart_travel_BE.dto.voucher;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class VoucherRequest {

    @NotBlank(message = "Mã voucher không được để trống")
    private String code;

    @NotNull(message = "Số tiền giảm không được để trống")
    @Min(value = 0, message = "Số tiền giảm phải lớn hơn hoặc bằng 0")
    private BigDecimal discountAmount;

    @NotNull(message = "Hạn sử dụng không được để trống")
    @Future(message = "Hạn sử dụng phải là ngày trong tương lai")
    private LocalDateTime expiryDate;

    @NotNull(message = "Trạng thái kích hoạt không được để trống")
    private Boolean isActive;

    @NotNull(message = "Giới hạn sử dụng không được để trống")
    @Min(value = 1, message = "Giới hạn sử dụng ít nhất là 1")
    private Integer usageLimit;
    private Long pointsRequired; // Thêm dòng này
    private String description;
    private String imageUrl;
}