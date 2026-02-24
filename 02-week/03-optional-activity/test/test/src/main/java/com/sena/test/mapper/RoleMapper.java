package com.sena.test.mapper;

import com.sena.test.dto.request.RoleRequestDto;
import com.sena.test.dto.response.RoleResponseDto;
import com.sena.test.entity.Role;
import com.sena.test.utils.DateUtils;

public class RoleMapper {

    public static Role toEntity(RoleRequestDto dto) {
        if (dto == null) return null;

        return Role.builder()
                .name(dto.getName())
                .active(true)
                .build();
    }

    public static RoleResponseDto toDto(Role entity) {
        if (entity == null) return null;

        return RoleResponseDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .active(entity.getActive())
                .createdAt(DateUtils.format(entity.getCreatedAt()))
                .updatedAt(DateUtils.format(entity.getUpdatedAt()))
                .build();
    }
}