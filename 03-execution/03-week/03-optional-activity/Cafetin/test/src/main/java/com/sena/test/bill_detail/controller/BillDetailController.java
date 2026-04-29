package com.sena.test.bill_detail.controller;

import com.sena.test.bill_detail.dto.request.BillDetailRequestDto;
import com.sena.test.bill_detail.dto.response.BillDetailResponseDto;
import com.sena.test.bill_detail.service.BillDetailService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bill-details")
public class BillDetailController {

    private final BillDetailService service;

    public BillDetailController(BillDetailService service) {
        this.service = service;
    }

    @PostMapping
    public BillDetailResponseDto create(@Valid @RequestBody BillDetailRequestDto dto) {
        return service.create(dto);
    }

    @GetMapping
    public List<BillDetailResponseDto> findAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public BillDetailResponseDto findById(@PathVariable Long id) {
        return service.findById(id);
    }

    @GetMapping("/bill/{billId}")
    public List<BillDetailResponseDto> findByBillId(@PathVariable Long billId) {
        return service.findByBillId(billId);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
