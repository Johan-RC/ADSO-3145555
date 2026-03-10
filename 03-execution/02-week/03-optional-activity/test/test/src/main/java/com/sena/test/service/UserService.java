package com.sena.test.service;

import com.sena.test.dto.request.UserRequestDto;
import com.sena.test.dto.response.UserResponseDto;
import com.sena.test.entity.Person;
import com.sena.test.entity.User;
import com.sena.test.mapper.UserMapper;
import com.sena.test.repository.IUserRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService {

    private final IUserRepository repository;

    public UserService(IUserRepository repository) {
        this.repository = repository;
    }

    public UserResponseDto create(UserRequestDto dto, Person person) {
        User entity = UserMapper.toEntity(dto, person);
        return UserMapper.toDto(repository.save(entity));
    }

    public List<UserResponseDto> findAll() {
        return repository.findAll()
                .stream()
                .map(UserMapper::toDto)
                .collect(Collectors.toList());
    }

    public UserResponseDto findById(Long id) {
        return repository.findById(id)
                .map(UserMapper::toDto)
                .orElse(null);
    }

    public UserResponseDto findByUsername(String username) {
        return UserMapper.toDto(repository.findByUsername(username));
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}