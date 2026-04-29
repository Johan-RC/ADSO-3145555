package com.sena.test.bill_detail.repository;

import com.sena.test.bill_detail.entity.BillDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IBillDetailRepository extends JpaRepository<BillDetail, Long> {
    List<BillDetail> findByBillId(Long billId);
}
