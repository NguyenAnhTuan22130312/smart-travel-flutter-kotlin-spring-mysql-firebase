package com.example.smart_travel_BE.dto.comparison;


import lombok.AllArgsConstructor;
import lombok.Data;


@Data
@AllArgsConstructor
public class ComparisonResponse<T> {
    private T item1;
    private T item2;
}
