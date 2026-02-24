package com.sena.test.mapper;

import com.sena.test.dto.request.PersonRequestDto;
import com.sena.test.dto.response.PersonResponseDto;
import com.sena.test.entity.Person;
import com.sena.test.utils.DateUtils;

public class PersonMapper {

    public static Person toEntity(PersonRequestDto dto) {
        if (dto == null) return null;

        return Person.builder()
                .firstName(dto.getFirstName())
                .lastName(dto.getLastName())
                .email(dto.getEmail())
                .active(true)
                .build();
    }

    public static PersonResponseDto toDto(Person entity) {
        if (entity == null) return null;

        return PersonResponseDto.builder()
                .id(entity.getId())
                .firstName(entity.getFirstName())
                .lastName(entity.getLastName())
                .email(entity.getEmail())
                .active(entity.getActive())
                .createdAt(DateUtils.format(entity.getCreatedAt()))
                .updatedAt(DateUtils.format(entity.getUpdatedAt()))
                .build();
    }
}