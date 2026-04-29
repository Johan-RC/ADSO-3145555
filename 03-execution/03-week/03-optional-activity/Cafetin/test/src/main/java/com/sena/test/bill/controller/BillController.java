package com.sena.test.bill.controller;

import com.sena.test.bill.dto.request.BillRequestDto;
import com.sena.test.bill.dto.request.BillStatusRequestDto;
import com.sena.test.bill.dto.response.BillResponseDto;
import com.sena.test.bill.service.BillService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bills")
public class BillController {

    private final BillService service;

    public BillController(BillService service) {
        this.service = service;
    }

    @PostMapping
    public BillResponseDto create(@Valid @RequestBody BillRequestDto dto) {
        return service.create(dto);
    }

    @GetMapping
    public List<BillResponseDto> findAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public BillResponseDto findById(@PathVariable Long id) {
        return service.findById(id);
    }

    @GetMapping("/status/{status}")
    public List<BillResponseDto> findByStatus(@PathVariable String status) {
        return service.findByStatus(status);
    }

    @GetMapping("/user/{userId}")
    public List<BillResponseDto> findByUserId(@PathVariable Long userId) {
        return service.findByUserId(userId);
    }

    @PatchMapping("/{id}/status")
    public BillResponseDto updateStatus(@PathVariable Long id, @Valid @RequestBody BillStatusRequestDto dto) {
        return service.updateStatus(id, dto.getStatus());
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
