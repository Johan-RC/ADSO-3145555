package com.sena.test.utils.mapper;

import com.sena.test.security.dto.request.UserRequestDto;
import com.sena.test.security.dto.response.UserResponseDto;
import com.sena.test.security.entity.Person;
import com.sena.test.security.entity.User;
import com.sena.test.utils.DateUtils;

public class UserMapper {

    public static User toEntity(UserRequestDto dto, Person person) {
        if (dto == null || person == null) return null;

        return User.builder()
                .username(dto.getUsername())
                .password(dto.getPassword())
                .person(person)
                .active(true)
                .build();
    }

    public static UserResponseDto toDto(User entity) {
        if (entity == null) return null;

        return UserResponseDto.builder()
                .id(entity.getId())
                .username(entity.getUsername())
                .active(entity.getActive())
                .createdAt(DateUtils.format(entity.getCreatedAt()))
                .updatedAt(DateUtils.format(entity.getUpdatedAt()))
                .personId(entity.getPerson() != null ? entity.getPerson().getId() : null)
                .build();
    }
}