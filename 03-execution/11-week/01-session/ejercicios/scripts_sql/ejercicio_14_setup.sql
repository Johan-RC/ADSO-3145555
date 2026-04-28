DROP TRIGGER IF EXISTS trg_ai_invoice_line_touch_invoice ON invoice_line;
DROP FUNCTION IF EXISTS fn_ai_invoice_line_touch_invoice();
DROP PROCEDURE IF EXISTS sp_add_invoice_line(uuid, uuid, varchar, numeric, numeric);

CREATE OR REPLACE FUNCTION fn_ai_invoice_line_touch_invoice()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE invoice
    SET updated_at = now()
    WHERE invoice_id = NEW.invoice_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_invoice_line_touch_invoice
AFTER INSERT ON invoice_line
FOR EACH ROW
EXECUTE FUNCTION fn_ai_invoice_line_touch_invoice();

CREATE OR REPLACE PROCEDURE sp_add_invoice_line(
    p_invoice_id uuid,
    p_tax_id uuid,
    p_line_description varchar(200),
    p_quantity numeric,
    p_unit_price numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_line_number integer;
BEGIN
    IF p_quantity <= 0 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor que cero.';
    END IF;

    IF p_unit_price < 0 THEN
        RAISE EXCEPTION 'El valor unitario no puede ser negativo.';
    END IF;

    SELECT COALESCE(MAX(il.line_number), 0) + 1
    INTO v_line_number
    FROM invoice_line il
    WHERE il.invoice_id = p_invoice_id;

    INSERT INTO invoice_line (
        invoice_id,
        tax_id,
        line_number,
        line_description,
        quantity,
        unit_price
    )
    VALUES (
        p_invoice_id,
        p_tax_id,
        v_line_number,
        p_line_description,
        p_quantity,
        p_unit_price
    );
END;
$$;

-- Consulta resuelta: detalle de factura por cliente y venta
SELECT
    i.invoice_number,
    i.issued_at,
    s.sale_code,
    r.reservation_code,
    pe.first_name,
    pe.last_name,
    il.line_number,
    il.line_description,
    il.quantity,
    il.unit_price,
    t.tax_name
FROM invoice_line il
INNER JOIN invoice i
    ON i.invoice_id = il.invoice_id
INNER JOIN sale s
    ON s.sale_id = i.sale_id
INNER JOIN reservation r
    ON r.reservation_id = s.reservation_id
INNER JOIN customer c
    ON c.customer_id = r.booked_by_customer_id
INNER JOIN person pe
    ON pe.person_id = c.person_id
LEFT JOIN tax t
    ON t.tax_id = il.tax_id
ORDER BY i.issued_at DESC, il.line_number ASC;
