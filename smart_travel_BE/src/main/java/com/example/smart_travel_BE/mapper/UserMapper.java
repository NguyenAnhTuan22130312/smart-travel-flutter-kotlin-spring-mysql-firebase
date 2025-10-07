package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.user.request.RegisterRequest;
import com.example.smart_travel_BE.dto.user.response.RegisterResponse;
import com.example.smart_travel_BE.entity.User;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface UserMapper {
    User toUser(RegisterRequest request);
    RegisterResponse toRegisterResponse(User user);
}
