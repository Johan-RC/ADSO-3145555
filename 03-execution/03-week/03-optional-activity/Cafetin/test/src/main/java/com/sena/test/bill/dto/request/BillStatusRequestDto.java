package com.sena.test.bill.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class BillStatusRequestDto {

    @NotBlank(message = "El estado es obligatorio")
    private String status;
}
