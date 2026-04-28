# Ejercicio 12 Resuelto - Registro de refund y trazabilidad de transacciones de pago

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
La aerolínea necesita que toda devolución registrada quede reflejada de forma consistente en el historial transaccional del pago. En otras palabras, cuando exista un `refund`, también debe existir una transacción financiera que lo represente.

---

## 6. Dominios involucrados
### SALES, RESERVATION, TICKETING
**Entidades:** `reservation`, `sale`  
**Propósito en este ejercicio:** ubicar el pago dentro del flujo comercial original.

### CUSTOMER AND LOYALTY
**Entidades:** `customer`  
**Propósito en este ejercicio:** identificar al cliente asociado a la reserva.

### IDENTITY
**Entidades:** `person`  
**Propósito en este ejercicio:** mostrar el nombre de la persona dueña de la reserva.

### PAYMENT
**Entidades:** `payment`, `payment_status`, `payment_method`, `payment_transaction`, `refund`  
**Propósito en este ejercicio:** representar el flujo financiero de pago, transacción y devolución.

---

## 7. Problema a resolver
El modelo tiene separadas las tablas `refund` y `payment_transaction`. Eso es correcto desde normalización, pero implica que la aplicación debe garantizar consistencia entre ambas. Si se inserta un `refund` y se olvida la transacción, el historial financiero queda incompleto.

La solución propuesta es:
1. una consulta consolidada para trazabilidad,
2. un trigger `AFTER INSERT` sobre `refund`,
3. un procedimiento almacenado para registrar devoluciones.

---

## 8. Solución propuesta

### 8.1 Consulta resuelta con `INNER JOIN`
```sql
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
```

### 8.2 Explicación paso a paso de la consulta
1. **`reservation`** ubica el negocio original.
2. **`customer`** identifica el cliente que hizo la reserva.
3. **`person`** muestra la identidad legible del cliente.
4. **`sale`** conecta la reserva con el acto comercial.
5. **`payment`** representa el pago registrado.
6. **`payment_status`** indica el estado del pago.
7. **`payment_method`** explica el medio usado.
8. **`payment_transaction`** detalla el evento financiero puntual.

La consulta usa `INNER JOIN` porque el objetivo es mostrar solo pagos que sí tienen trazabilidad transaccional.

---

## 9. Trigger resuelto

### 9.1 Decisión técnica
Se eligió un trigger `AFTER INSERT ON refund` porque el `refund` es el hecho de negocio que origina la transacción financiera tipo `REFUND`.

### 9.2 Script del trigger
```sql
DROP TRIGGER IF EXISTS trg_ai_refund_create_payment_transaction ON refund;
DROP FUNCTION IF EXISTS fn_ai_refund_create_payment_transaction();

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
```

### 9.3 Por qué esta solución es correcta
- No altera el modelo base.
- Usa las columnas reales `payment_id`, `amount`, `requested_at`, `processed_at`, `refund_reason`.
- Mantiene trazabilidad entre refund y transacción financiera.
- Evita duplicidad por `transaction_reference`.

---

## 10. Procedimiento almacenado resuelto

### 10.1 Objetivo
Encapsular la solicitud de devolución y validar el monto antes de insertar.

### 10.2 Script del procedimiento
```sql
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
```

### 10.3 Por qué esta solución es correcta
- centraliza la inserción,
- agrega validación de negocio mínima,
- deja al trigger la responsabilidad de crear la transacción de tipo `REFUND`.

---

## 11. Script de demostración del funcionamiento
```sql
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
```

### 11.1 Qué demuestra este script
1. Localiza un pago existente.
2. Ejecuta el procedimiento.
3. Inserta un `refund`.
4. El trigger genera automáticamente la fila en `payment_transaction`.
5. La consulta final valida que el refund quedó representado como transacción.

---

## 12. Validación final
La solución es consistente porque:
- la consulta usa más de 5 tablas con `INNER JOIN`,
- el trigger es `AFTER INSERT`,
- el procedimiento encapsula la operación,
- la evidencia final valida tanto el refund como la transacción creada.

---

## 13. Archivo SQL relacionado
- `scripts_sql/ejercicio_12_setup.sql`
- `scripts_sql/ejercicio_12_demo.sql`
