DO $$
DECLARE
    v_flight_segment_id uuid;
    v_delay_reason_type_id uuid;
BEGIN
    SELECT fs.flight_segment_id
    INTO v_flight_segment_id
    FROM flight_segment fs
    ORDER BY fs.created_at
    LIMIT 1;

    SELECT drt.delay_reason_type_id
    INTO v_delay_reason_type_id
    FROM delay_reason_type drt
    ORDER BY drt.created_at
    LIMIT 1;

    IF v_flight_segment_id IS NULL THEN
        RAISE EXCEPTION 'No existe flight_segment disponible.';
    END IF;

    IF v_delay_reason_type_id IS NULL THEN
        RAISE EXCEPTION 'No existe delay_reason_type disponible.';
    END IF;

    CALL sp_report_flight_delay(
        v_flight_segment_id,
        v_delay_reason_type_id,
        now(),
        25,
        'Demostracion de retraso reportado desde procedure'
    );
END;
$$;

SELECT
    f.flight_id,
    f.flight_number,
    f.updated_at,
    fd.flight_delay_id,
    fd.delay_minutes,
    fd.reported_at
FROM flight_delay fd
INNER JOIN flight_segment fs
    ON fs.flight_segment_id = fd.flight_segment_id
INNER JOIN flight f
    ON f.flight_id = fs.flight_id
ORDER BY fd.created_at DESC
LIMIT 5;
