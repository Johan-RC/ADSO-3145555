package com.sena.test.security.repository;

import com.sena.test.security.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface IRoleRepository extends JpaRepository<Role, Long> {
    // Ejemplo de consulta personalizada
    Role findByName(String name);
}