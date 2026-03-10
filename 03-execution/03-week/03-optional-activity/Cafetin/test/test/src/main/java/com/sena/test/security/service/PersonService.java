package com.sena.test.security.service;

import com.sena.test.security.dto.request.PersonRequestDto;
import com.sena.test.security.dto.response.PersonResponseDto;
import com.sena.test.security.entity.Person;
import com.sena.test.utils.mapper.PersonMapper;
import com.sena.test.security.repository.IPersonRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PersonService {

    public final IPersonRepository repository;

    public PersonService(IPersonRepository repository) {
        this.repository = repository;
    }

    public PersonResponseDto create(PersonRequestDto dto) {
        Person entity = PersonMapper.toEntity(dto);
        return PersonMapper.toDto(repository.save(entity));
    }

    public List<PersonResponseDto> findAll() {
        return repository.findAll()
                .stream()
                .map(PersonMapper::toDto)
                .collect(Collectors.toList());
    }

    public PersonResponseDto findById(Long id) {
        return repository.findById(id)
                .map(PersonMapper::toDto)
                .orElse(null);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}