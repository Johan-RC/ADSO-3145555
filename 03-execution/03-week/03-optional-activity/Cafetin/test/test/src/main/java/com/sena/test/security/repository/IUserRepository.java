package com.sena.test.security.repository;

import com.sena.test.security.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface IUserRepository extends JpaRepository<User, Long> {
    // Ejemplo de consulta personalizada
    User findByUsername(String username);
}