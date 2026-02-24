package com.sena.test.service;

import com.sena.test.dto.request.RoleRequestDto;
import com.sena.test.dto.response.RoleResponseDto;
import com.sena.test.entity.Role;
import com.sena.test.mapper.RoleMapper;
import com.sena.test.repository.IRoleRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class RoleService {

    private final IRoleRepository repository;

    public RoleService(IRoleRepository repository) {
        this.repository = repository;
    }

    public RoleResponseDto create(RoleRequestDto dto) {
        Role entity = RoleMapper.toEntity(dto);
        return RoleMapper.toDto(repository.save(entity));
    }

    public List<RoleResponseDto> findAll() {
        return repository.findAll()
                .stream()
                .map(RoleMapper::toDto)
                .collect(Collectors.toList());
    }

    public RoleResponseDto findById(Long id) {
        return repository.findById(id)
                .map(RoleMapper::toDto)
                .orElse(null);
    }

    public RoleResponseDto findByName(String name) {
        return RoleMapper.toDto(repository.findByName(name));
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}