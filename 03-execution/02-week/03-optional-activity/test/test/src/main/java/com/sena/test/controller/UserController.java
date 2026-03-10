package com.sena.test.controller;

import com.sena.test.dto.request.UserRequestDto;
import com.sena.test.dto.response.UserResponseDto;
import com.sena.test.entity.Person;
import com.sena.test.service.UserService;
import com.sena.test.service.PersonService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;
    private final PersonService personService;

    public UserController(UserService userService, PersonService personService) {
        this.userService = userService;
        this.personService = personService;
    }

    @PostMapping
    public UserResponseDto create(@RequestBody UserRequestDto dto) {
        Person person = personService.findById(dto.getPersonId()) != null
                ? personService.repository.findById(dto.getPersonId()).orElse(null)
                : null;
        return userService.create(dto, person);
    }

    @GetMapping
    public List<UserResponseDto> findAll() {
        return userService.findAll();
    }

    @GetMapping("/{id}")
    public UserResponseDto findById(@PathVariable Long id) {
        return userService.findById(id);
    }

    @GetMapping("/username/{username}")
    public UserResponseDto findByUsername(@PathVariable String username) {
        return userService.findByUsername(username);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        userService.delete(id);
    }
}