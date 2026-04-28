# Ejercicio 13 Resuelto - Registro de retrasos operativos por segmento de vuelo

# Modelo de datos base del sistema

## 1. Descripción general del modelo
El modelo de datos corresponde a un sistema integral de aerolínea, diseñado para soportar de forma relacional los procesos principales del negocio: gestión geográfica, identidad de personas, seguridad, clientes, fidelización, aeropuertos, aeronaves, operación de vuelos, reservas, tiquetes, abordaje, pagos y facturación.

Se trata de un modelo amplio y normalizado, en el que las entidades están separadas por dominios funcionales y conectadas mediante llaves foráneas para garantizar trazabilidad, integridad y consistencia en todo el flujo operativo y comercial.

---

## 2. Resumen previo del análisis realizado
Como base de trabajo, previamente se identificó y organizó el script en dominios funcionales. A partir de esa revisión, se determinó que el modelo no corresponde a un caso pequeño o aislado, sino a una solución empresarial con múltiples áreas del negocio conectadas entre sí.

También se verificó que:
- el modelo contiene más de 60 entidades,
- las relaciones entre tablas siguen una estructura consistente,
- existen restricciones de integridad mediante `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE` y `CHECK`,
- el diseño soporta trazabilidad end-to-end desde la reserva hasta el pago, abordaje y facturación.

---

## 3. Dominios del modelo y propósito general

### GEOGRAPHY AND REFERENCE DATA
**Entidades:** `time_zone`, `continent`, `country`, `state_province`, `city`, `district`, `address`, `currency`  
**Resumen:** Centraliza información geográfica y de referencia para ubicar aeropuertos, personas, proveedores y definir monedas operativas del sistema.

### AIRLINE
**Entidades:** `airline`  
**Resumen:** Representa la aerolínea operadora del sistema, incluyendo sus códigos y país base.

### IDENTITY
**Entidades:** `person_type`, `document_type`, `contact_type`, `person`, `person_document`, `person_contact`  
**Resumen:** Permite modelar la identidad de las personas, sus documentos y medios de contacto.

### SECURITY
**Entidades:** `user_status`, `security_role`, `security_permission`, `user_account`, `user_role`, `role_permission`  
**Resumen:** Administra autenticación, autorización y control de acceso al sistema.

### CUSTOMER AND LOYALTY
**Entidades:** `customer_category`, `benefit_type`, `loyalty_program`, `loyalty_tier`, `customer`, `loyalty_account`, `loyalty_account_tier`, `miles_transaction`, `customer_benefit`  
**Resumen:** Gestiona clientes, programas de fidelización, acumulación de millas, beneficios y niveles.

### AIRPORT
**Entidades:** `airport`, `terminal`, `boarding_gate`, `runway`, `airport_regulation`  
**Resumen:** Modela la infraestructura aeroportuaria y las condiciones regulatorias asociadas a cada aeropuerto.

### AIRCRAFT
**Entidades:** `aircraft_manufacturer`, `aircraft_model`, `cabin_class`, `aircraft`, `aircraft_cabin`, `aircraft_seat`, `maintenance_provider`, `maintenance_type`, `maintenance_event`  
**Resumen:** Gestiona aeronaves, fabricantes, configuración interna y procesos de mantenimiento.

### FLIGHT OPERATIONS
**Entidades:** `flight_status`, `delay_reason_type`, `flight`, `flight_segment`, `flight_delay`  
**Resumen:** Controla la operación de vuelos, sus segmentos, estados y retrasos.

### SALES, RESERVATION, TICKETING
**Entidades:** `reservation_status`, `sale_channel`, `fare_class`, `fare`, `ticket_status`, `reservation`, `reservation_passenger`, `sale`, `ticket`, `ticket_segment`, `seat_assignment`, `baggage`  
**Resumen:** Gestiona el flujo comercial principal: reserva, pasajero, venta, emisión de tiquetes, asignación de asiento y equipaje.

### BOARDING
**Entidades:** `boarding_group`, `check_in_status`, `check_in`, `boarding_pass`, `boarding_validation`  
**Resumen:** Soporta el proceso de check-in, emisión de pase de abordar y validación final de embarque.

### PAYMENT
**Entidades:** `payment_status`, `payment_method`, `payment`, `payment_transaction`, `refund`  
**Resumen:** Administra pagos, transacciones y devoluciones asociadas a las ventas.

### BILLING
**Entidades:** `tax`, `exchange_rate`, `invoice_status`, `invoice`, `invoice_line`  
**Resumen:** Gestiona impuestos, tasas de cambio, facturas y detalle facturable.

---

## 4. Restricción general para todos los ejercicios
Todos los ejercicios se resuelven respetando estrictamente el modelo entregado.

No se cambia:
- ningún atributo existente,
- nombres de tablas o columnas,
- relaciones del modelo,
- ni la estructura general del script base.


---

## 5. Contexto del ejercicio
La operación aérea necesita consolidar el reporte de retrasos a nivel de segmento. Además de guardar el retraso, se desea reflejar que el vuelo asociado fue impactado operativamente.

---

## 6. Dominios involucrados
### FLIGHT OPERATIONS
**Entidades:** `flight`, `flight_segment`, `flight_delay`, `delay_reason_type`  
**Propósito en este ejercicio:** registrar retrasos y conectarlos con la operación real del segmento.

### AIRLINE
**Entidades:** `airline`  
**Propósito en este ejercicio:** identificar la aerolínea operadora del vuelo afectado.

### AIRPORT
**Entidades:** `airport`  
**Propósito en este ejercicio:** mostrar el aeropuerto origen y destino del segmento.

---

## 7. Problema a resolver
El modelo ya permite almacenar retrasos en `flight_delay`, pero se busca una solución que:
1. consulte el retraso con toda su ruta operativa,
2. toque el vuelo padre cuando se registra un retraso,
3. centralice el alta del retraso en un procedimiento almacenado.

---

## 8. Solución propuesta

### 8.1 Consulta resuelta con `INNER JOIN`
```sql
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
```

### 8.2 Explicación paso a paso de la consulta
1. **`flight_delay`** contiene el evento de retraso.
2. **`delay_reason_type`** describe la causa.
3. **`flight_segment`** ubica el tramo afectado.
4. **`flight`** representa el vuelo padre.
5. **`airline`** identifica el operador.
6. **`airport` origen** y **`airport` destino** completan la ruta.

La consulta usa `INNER JOIN` en siete tablas porque la idea es mostrar únicamente retrasos correctamente trazados en el modelo.

---

## 9. Trigger resuelto

### 9.1 Decisión técnica
Se eligió un trigger `AFTER INSERT ON flight_delay` que actualiza el `updated_at` del `flight` padre. No se crea una nueva tabla porque el modelo ya tiene un campo de trazabilidad temporal suficiente en `flight.updated_at`.

### 9.2 Script del trigger
```sql
DROP TRIGGER IF EXISTS trg_ai_flight_delay_touch_flight ON flight_delay;
DROP FUNCTION IF EXISTS fn_ai_flight_delay_touch_flight();

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
```

### 9.3 Por qué esta solución es correcta
- Aprovecha una columna real del modelo.
- Refleja impacto operativo en el vuelo padre.
- No altera ninguna entidad.
- Mantiene una reacción simple y coherente después del reporte del retraso.

---

## 10. Procedimiento almacenado resuelto

### 10.1 Objetivo
Encapsular el reporte de retraso con validación mínima del número de minutos.

### 10.2 Script del procedimiento
```sql
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
```

### 10.3 Por qué esta solución es correcta
- valida una regla básica de negocio,
- centraliza la inserción,
- deja que el trigger marque el impacto sobre el vuelo.

---

## 11. Script de demostración del funcionamiento
```sql
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
```

### 11.1 Qué demuestra este script
1. Selecciona un segmento de vuelo y un tipo de retraso.
2. Llama al procedimiento almacenado.
3. Inserta el retraso.
4. El trigger actualiza el vuelo padre.
5. La consulta final muestra el retraso y el `updated_at` del vuelo.

---

## 12. Validación final
La solución es válida porque:
- la consulta une más de 5 tablas reales,
- el trigger es `AFTER INSERT`,
- el procedimiento es reutilizable,
- la demostración evidencia el retraso y el toque al vuelo.

---

## 13. Archivo SQL relacionado
- `scripts_sql/ejercicio_13_setup.sql`
- `scripts_sql/ejercicio_13_demo.sql`
