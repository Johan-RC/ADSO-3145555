DROP TRIGGER IF EXISTS trg_ai_refund_create_payment_transaction ON refund;
DROP FUNCTION IF EXISTS fn_ai_refund_create_payment_transaction();
DROP PROCEDURE IF EXISTS sp_request_refund(uuid, varchar, numeric, timestamptz, timestamptz, text);

CREATE OR REPLACE FUNCTION fn_ai_refund_create_payment_transaction()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_transaction_reference varchar(60);
BEGIN
    v_transaction_reference := 'REF-' || replace(NEW.refund_id::text, '-', '');

    IF EXISTS (
        SELECT 1
        FROM payment_transaction pt
        WHERE pt.transaction_reference = v_transaction_reference
    ) THEN
        RETURN NEW;
    END IF;

    INSERT INTO payment_transaction (
        payment_id,
        transaction_reference,
        transaction_type,
        transaction_amount,
        processed_at,
        provider_message
    )
    VALUES (
        NEW.payment_id,
        v_transaction_reference,
        'REFUND',
        NEW.amount,
        COALESCE(NEW.processed_at, NEW.requested_at),
        COALESCE(NEW.refund_reason, 'Refund generated from trigger')
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_refund_create_payment_transaction
AFTER INSERT ON refund
FOR EACH ROW
EXECUTE FUNCTION fn_ai_refund_create_payment_transaction();

CREATE OR REPLACE PROCEDURE sp_request_refund(
    p_payment_id uuid,
    p_refund_reference varchar(40),
    p_amount numeric,
    p_requested_at timestamptz,
    p_processed_at timestamptz,
    p_refund_reason text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'El monto del refund debe ser mayor que cero.';
    END IF;

    INSERT INTO refund (
        payment_id,
        refund_reference,
        amount,
        requested_at,
        processed_at,
        refund_reason
    )
    VALUES (
        p_payment_id,
        p_refund_reference,
        p_amount,
        p_requested_at,
        p_processed_at,
        p_refund_reason
    );
END;
$$;

-- Consulta resuelta: trazabilidad de pagos por reserva y cliente
SELECT
    r.reservation_code,
    pe.first_name,
    pe.last_name,
    s.sale_code,
    p.payment_reference,
    ps.status_name AS payment_status_name,
    pm.method_name AS payment_method_name,
    pt.transaction_reference,
    pt.transaction_type,
    pt.transaction_amount,
    pt.processed_at
FROM reservation r
INNER JOIN customer c
    ON c.customer_id = r.booked_by_customer_id
INNER JOIN person pe
    ON pe.person_id = c.person_id
INNER JOIN sale s
    ON s.reservation_id = r.reservation_id
INNER JOIN payment p
    ON p.sale_id = s.sale_id
INNER JOIN payment_status ps
    ON ps.payment_status_id = p.payment_status_id
INNER JOIN payment_method pm
    ON pm.payment_method_id = p.payment_method_id
INNER JOIN payment_transaction pt
    ON pt.payment_id = p.payment_id
ORDER BY pt.processed_at DESC, s.sold_at DESC;
