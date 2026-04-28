DO $$
DECLARE
    v_invoice_id uuid;
    v_tax_id uuid;
BEGIN
    SELECT i.invoice_id
    INTO v_invoice_id
    FROM invoice i
    ORDER BY i.created_at
    LIMIT 1;

    SELECT t.tax_id
    INTO v_tax_id
    FROM tax t
    ORDER BY t.created_at
    LIMIT 1;

    IF v_invoice_id IS NULL THEN
        RAISE EXCEPTION 'No existe invoice disponible.';
    END IF;

    CALL sp_add_invoice_line(
        v_invoice_id,
        v_tax_id,
        'Linea agregada desde procedure',
        1,
        150.00
    );
END;
$$;

SELECT
    i.invoice_number,
    i.updated_at,
    il.line_number,
    il.line_description,
    il.quantity,
    il.unit_price
FROM invoice_line il
INNER JOIN invoice i
    ON i.invoice_id = il.invoice_id
ORDER BY il.created_at DESC
LIMIT 5;
