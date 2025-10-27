package com.example.smart_travel_BE.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
public class WebConfig { // Hoặc tên file Config khác của bạn

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    // ... các Bean khác của bạn
}