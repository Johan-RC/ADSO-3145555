package com.sena.test.dto.request;

import com.sena.test.utils.MessageUtils;
import jakarta.validation.constraints.Email;
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
public class PersonRequestDto {

    @NotBlank(message = MessageUtils.NAME_REQUIRED)
    @Size(min = 2, max = 50, message = "El nombre debe tener entre 2 y 50 caracteres")
    private String firstName;

    @NotBlank(message = MessageUtils.NAME_REQUIRED)
    @Size(min = 2, max = 50, message = "El apellido debe tener entre 2 y 50 caracteres")
    private String lastName;

    @NotBlank(message = MessageUtils.EMAIL_REQUIRED)
    @Email(message = MessageUtils.INVALID_EMAIL)
    @Size(max = 100, message = "El correo no puede superar los 100 caracteres")
    private String email;
}