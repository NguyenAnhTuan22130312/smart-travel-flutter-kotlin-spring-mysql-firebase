package com.example.smart_travel_BE.dto.user.request;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SettingsRequest {

    @Size(max = 1000, message = "languageSettings không được quá 1000 ký tự")
    private String languageSettings;

    private Boolean darkModeEnabled;

    @Size(max = 2000, message = "notificationSettings không được quá 2000 ký tự")
    private String notificationSettings;
}

