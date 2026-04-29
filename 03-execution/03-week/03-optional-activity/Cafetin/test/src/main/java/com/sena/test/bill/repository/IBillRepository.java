package com.sena.test.bill.repository;

import com.sena.test.bill.entity.Bill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IBillRepository extends JpaRepository<Bill, Long> {
    List<Bill> findByStatus(String status);
    List<Bill> findByUserId(Long userId);
}
