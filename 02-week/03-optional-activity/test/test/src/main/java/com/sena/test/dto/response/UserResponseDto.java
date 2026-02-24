package com.sena.test.dto.response;

import com.fasterxml.jackson.annotation.JsonView;
import com.sena.test.dto.view.Views;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserResponseDto {

    @JsonView(Views.Basic.class)
    private Long id;

    @JsonView(Views.Basic.class)
    private String username;

    @JsonView(Views.Detailed.class)
    private Boolean active;

    @JsonView(Views.Detailed.class)
    private String createdAt;

    @JsonView(Views.Detailed.class)
    private String updatedAt;

    @JsonView(Views.Detailed.class)
    private Long personId;
}