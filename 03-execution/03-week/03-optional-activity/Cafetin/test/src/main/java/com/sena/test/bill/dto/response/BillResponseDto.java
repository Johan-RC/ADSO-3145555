package com.sena.test.bill.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BillResponseDto {
    private Long id;
    private Long userId;
    private String username;
    private String status;
    private String billDate;
    private BigDecimal total;
    private Boolean active;
    private String createdAt;
    private String updatedAt;
}
