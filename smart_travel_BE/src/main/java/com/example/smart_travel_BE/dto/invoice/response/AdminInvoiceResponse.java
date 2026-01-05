package com.example.smart_travel_BE.dto.invoice.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class AdminInvoiceResponse {
    private Long bookingId;
    private String invoiceNumber;
    private String itemName;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;
}