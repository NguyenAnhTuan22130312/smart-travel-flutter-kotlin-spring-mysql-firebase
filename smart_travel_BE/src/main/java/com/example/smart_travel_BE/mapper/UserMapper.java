package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.user.request.RegisterRequest;
import com.example.smart_travel_BE.dto.user.response.RegisterResponse;
import com.example.smart_travel_BE.dto.user.response.UserDetailResponse;
import com.example.smart_travel_BE.dto.user.response.UserSummaryResponse;
import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.entity.UserProfile;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UserMapper {
    User toUser(RegisterRequest request);

    RegisterResponse toRegisterResponse(User user);

    // Admin mapping methods - now includes full profile data
    @Mapping(target = "id", source = "user.id")
    @Mapping(target = "email", source = "user.email")
    @Mapping(target = "fullName", source = "user.fullName")
    @Mapping(target = "phone", source = "user.phone")
    @Mapping(target = "role", source = "user.role")
    @Mapping(target = "authProvider", source = "user.authProvider")
    @Mapping(target = "isActive", source = "user.isActive")
    @Mapping(target = "emailVerified", source = "user.emailVerified")
    @Mapping(target = "createdAt", source = "user.createdAt")
    @Mapping(target = "updatedAt", source = "user.updatedAt")
    @Mapping(target = "avatarUrl", source = "userProfile.avatarUrl")
    @Mapping(target = "bio", source = "userProfile.bio")
    @Mapping(target = "gender", source = "userProfile.gender")
    @Mapping(target = "dateOfBirth", source = "userProfile.dateOfBirth")
    @Mapping(target = "address", source = "userProfile.address")
    @Mapping(target = "city", source = "userProfile.city")
    @Mapping(target = "country", source = "userProfile.country")
    @Mapping(target = "currentLevel", source = "userProfile.currentLevel")
    @Mapping(target = "experiencePoints", source = "userProfile.experiencePoints")
    UserSummaryResponse toUserSummaryResponse(User user, UserProfile userProfile);

    @Mapping(target = "id", source = "user.id")
    @Mapping(target = "email", source = "user.email")
    @Mapping(target = "fullName", source = "user.fullName")
    @Mapping(target = "phone", source = "user.phone")
    @Mapping(target = "role", source = "user.role")
    @Mapping(target = "authProvider", source = "user.authProvider")
    @Mapping(target = "isActive", source = "user.isActive")
    @Mapping(target = "emailVerified", source = "user.emailVerified")
    @Mapping(target = "createdAt", source = "user.createdAt")
    @Mapping(target = "updatedAt", source = "user.updatedAt")
    @Mapping(target = "avatarUrl", source = "userProfile.avatarUrl")
    @Mapping(target = "bio", source = "userProfile.bio")
    @Mapping(target = "gender", source = "userProfile.gender")
    @Mapping(target = "dateOfBirth", source = "userProfile.dateOfBirth")
    @Mapping(target = "address", source = "userProfile.address")
    @Mapping(target = "city", source = "userProfile.city")
    @Mapping(target = "country", source = "userProfile.country")
    @Mapping(target = "currentLevel", source = "userProfile.currentLevel")
    @Mapping(target = "experiencePoints", source = "userProfile.experiencePoints")
    UserDetailResponse toUserDetailResponse(User user, UserProfile userProfile);
}
