package com.sena.test.dto.request;

import com.sena.test.utils.MessageUtils;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RoleRequestDto {

    @NotBlank(message = MessageUtils.NAME_REQUIRED)
    @Size(min = 3, max = 30, message = "El rol debe tener entre 3 y 30 caracteres")
    private String name;
}