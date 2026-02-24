package com.sena.test.repository;

import com.sena.test.entity.Person;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface IPersonRepository extends JpaRepository<Person, Long> {
    // Aquí puedes agregar consultas personalizadas si lo necesitas
}