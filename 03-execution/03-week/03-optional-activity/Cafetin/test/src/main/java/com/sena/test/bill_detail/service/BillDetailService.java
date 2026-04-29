package com.sena.test.bill_detail.service;

import com.sena.test.bill.entity.Bill;
import com.sena.test.bill.repository.IBillRepository;
import com.sena.test.bill_detail.dto.request.BillDetailRequestDto;
import com.sena.test.bill_detail.dto.response.BillDetailResponseDto;
import com.sena.test.bill_detail.entity.BillDetail;
import com.sena.test.bill_detail.repository.IBillDetailRepository;
import com.sena.test.utils.DateUtils;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class BillDetailService {

    private final IBillDetailRepository detailRepository;
    private final IBillRepository billRepository;

    public BillDetailService(IBillDetailRepository detailRepository, IBillRepository billRepository) {
        this.detailRepository = detailRepository;
        this.billRepository = billRepository;
    }

    public BillDetailResponseDto create(BillDetailRequestDto dto) {
        Bill bill = billRepository.findById(dto.getBillId())
                .orElseThrow(() -> new RuntimeException("Pedido no encontrado"));

        BigDecimal subtotal = dto.getUnitPrice().multiply(BigDecimal.valueOf(dto.getQuantity()));

        BillDetail detail = BillDetail.builder()
                .bill(bill)
                .productName(dto.getProductName())
                .quantity(dto.getQuantity())
                .unitPrice(dto.getUnitPrice())
                .subtotal(subtotal)
                .active(true)
                .build();

        return toDto(detailRepository.save(detail));
    }

    public List<BillDetailResponseDto> findAll() {
        return detailRepository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    public BillDetailResponseDto findById(Long id) {
        return detailRepository.findById(id).map(this::toDto).orElse(null);
    }

    public List<BillDetailResponseDto> findByBillId(Long billId) {
        return detailRepository.findByBillId(billId).stream().map(this::toDto).collect(Collectors.toList());
    }

    public void delete(Long id) {
        detailRepository.deleteById(id);
    }

    private BillDetailResponseDto toDto(BillDetail detail) {
        if (detail == null) return null;
        return BillDetailResponseDto.builder()
                .id(detail.getId())
                .billId(detail.getBill() != null ? detail.getBill().getId() : null)
                .productName(detail.getProductName())
                .quantity(detail.getQuantity())
                .unitPrice(detail.getUnitPrice())
                .subtotal(detail.getSubtotal())
                .active(detail.getActive())
                .createdAt(DateUtils.format(detail.getCreatedAt()))
                .updatedAt(DateUtils.format(detail.getUpdatedAt()))
                .build();
    }
}
