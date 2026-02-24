package com.sena.test.repository;

import com.sena.test.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface IUserRepository extends JpaRepository<User, Long> {
    // Ejemplo de consulta personalizada
    User findByUsername(String username);
}