DROP TRIGGER IF EXISTS trg_ai_flight_delay_touch_flight ON flight_delay;
DROP FUNCTION IF EXISTS fn_ai_flight_delay_touch_flight();
DROP PROCEDURE IF EXISTS sp_report_flight_delay(uuid, uuid, timestamptz, integer, text);

CREATE OR REPLACE FUNCTION fn_ai_flight_delay_touch_flight()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE flight
    SET updated_at = now()
    WHERE flight_id = (
        SELECT fs.flight_id
        FROM flight_segment fs
        WHERE fs.flight_segment_id = NEW.flight_segment_id
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_flight_delay_touch_flight
AFTER INSERT ON flight_delay
FOR EACH ROW
EXECUTE FUNCTION fn_ai_flight_delay_touch_flight();

CREATE OR REPLACE PROCEDURE sp_report_flight_delay(
    p_flight_segment_id uuid,
    p_delay_reason_type_id uuid,
    p_reported_at timestamptz,
    p_delay_minutes integer,
    p_notes text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_delay_minutes <= 0 THEN
        RAISE EXCEPTION 'Los minutos de retraso deben ser mayores que cero.';
    END IF;

    INSERT INTO flight_delay (
        flight_segment_id,
        delay_reason_type_id,
        reported_at,
        delay_minutes,
        notes
    )
    VALUES (
        p_flight_segment_id,
        p_delay_reason_type_id,
        p_reported_at,
        p_delay_minutes,
        p_notes
    );
END;
$$;

-- Consulta resuelta: retrasos por segmento y ruta operativa
SELECT
    a.airline_name,
    f.flight_number,
    f.service_date,
    fs.segment_number,
    ao.airport_name AS origin_airport_name,
    ad.airport_name AS destination_airport_name,
    drt.reason_name,
    fd.delay_minutes,
    fd.reported_at
FROM flight_delay fd
INNER JOIN delay_reason_type drt
    ON drt.delay_reason_type_id = fd.delay_reason_type_id
INNER JOIN flight_segment fs
    ON fs.flight_segment_id = fd.flight_segment_id
INNER JOIN flight f
    ON f.flight_id = fs.flight_id
INNER JOIN airline a
    ON a.airline_id = f.airline_id
INNER JOIN airport ao
    ON ao.airport_id = fs.origin_airport_id
INNER JOIN airport ad
    ON ad.airport_id = fs.destination_airport_id
ORDER BY fd.reported_at DESC, f.service_date DESC;
