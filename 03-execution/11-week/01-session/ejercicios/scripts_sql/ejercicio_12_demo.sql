DO $$
DECLARE
    v_payment_id uuid;
    v_refund_reference varchar(40);
BEGIN
    SELECT p.payment_id
    INTO v_payment_id
    FROM payment p
    ORDER BY p.created_at
    LIMIT 1;

    IF v_payment_id IS NULL THEN
        RAISE EXCEPTION 'No existe payment disponible para generar refund.';
    END IF;

    v_refund_reference := left('DEMO-REFUND-' || replace(gen_random_uuid()::text, '-', ''), 40);

    CALL sp_request_refund(
        v_payment_id,
        v_refund_reference,
        10.00,
        now(),
        now(),
        'Refund de demostracion generado desde procedure'
    );
END;
$$;

SELECT
    r.refund_reference,
    r.amount AS refund_amount,
    pt.transaction_reference,
    pt.transaction_type,
    pt.transaction_amount,
    pt.processed_at
FROM refund r
INNER JOIN payment_transaction pt
    ON pt.payment_id = r.payment_id
   AND pt.transaction_type = 'REFUND'
ORDER BY r.created_at DESC, pt.processed_at DESC
LIMIT 5;
