package com.sena.test.bill.service;

import com.sena.test.bill.dto.request.BillRequestDto;
import com.sena.test.bill.dto.response.BillResponseDto;
import com.sena.test.bill.entity.Bill;
import com.sena.test.bill.repository.IBillRepository;
import com.sena.test.security.entity.User;
import com.sena.test.security.repository.IUserRepository;
import com.sena.test.utils.DateUtils;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class BillService {

    private final IBillRepository billRepository;
    private final IUserRepository userRepository;

    public BillService(IBillRepository billRepository, IUserRepository userRepository) {
        this.billRepository = billRepository;
        this.userRepository = userRepository;
    }

    public BillResponseDto create(BillRequestDto dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Bill bill = Bill.builder()
                .user(user)
                .status(dto.getStatus() == null || dto.getStatus().isBlank() ? "PENDIENTE" : dto.getStatus())
                .billDate(LocalDateTime.now())
                .total(dto.getTotal())
                .active(true)
                .build();

        return toDto(billRepository.save(bill));
    }

    public List<BillResponseDto> findAll() {
        return billRepository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    public BillResponseDto findById(Long id) {
        return billRepository.findById(id).map(this::toDto).orElse(null);
    }

    public List<BillResponseDto> findByStatus(String status) {
        return billRepository.findByStatus(status).stream().map(this::toDto).collect(Collectors.toList());
    }

    public List<BillResponseDto> findByUserId(Long userId) {
        return billRepository.findByUserId(userId).stream().map(this::toDto).collect(Collectors.toList());
    }

    public BillResponseDto updateStatus(Long id, String status) {
        Bill bill = billRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pedido no encontrado"));
        bill.setStatus(status);
        return toDto(billRepository.save(bill));
    }

    public void delete(Long id) {
        billRepository.deleteById(id);
    }

    public BillResponseDto toDto(Bill bill) {
        if (bill == null) return null;
        return BillResponseDto.builder()
                .id(bill.getId())
                .userId(bill.getUser() != null ? bill.getUser().getId() : null)
                .username(bill.getUser() != null ? bill.getUser().getUsername() : null)
                .status(bill.getStatus())
                .billDate(DateUtils.format(bill.getBillDate()))
                .total(bill.getTotal())
                .active(bill.getActive())
                .createdAt(DateUtils.format(bill.getCreatedAt()))
                .updatedAt(DateUtils.format(bill.getUpdatedAt()))
                .build();
    }
}
