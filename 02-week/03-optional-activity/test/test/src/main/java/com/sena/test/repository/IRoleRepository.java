package com.sena.test.repository;

import com.sena.test.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface IRoleRepository extends JpaRepository<Role, Long> {
    // Ejemplo de consulta personalizada
    Role findByName(String name);
}