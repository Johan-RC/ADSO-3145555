# Ejercicio 14 Resuelto - Adición controlada de líneas de factura

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
Se requiere una forma controlada de agregar líneas a una factura existente. Además, cada vez que se agregue una nueva línea, la factura debe reflejar que fue modificada recientemente.

---

## 6. Dominios involucrados
### BILLING
**Entidades:** `invoice`, `invoice_line`, `tax`  
**Propósito en este ejercicio:** gestionar el encabezado de la factura y sus líneas de detalle.

### SALES, RESERVATION, TICKETING
**Entidades:** `sale`, `reservation`  
**Propósito en este ejercicio:** conectar la factura con la venta y la reserva que le dieron origen.

### CUSTOMER AND LOYALTY
**Entidades:** `customer`  
**Propósito en este ejercicio:** identificar el cliente facturado.

### IDENTITY
**Entidades:** `person`  
**Propósito en este ejercicio:** mostrar nombre y apellido del cliente.

---

## 7. Problema a resolver
El modelo almacena el detalle facturable en `invoice_line`. Como la numeración por línea es única dentro de cada factura, la solución debe calcular correctamente el siguiente número y, además, actualizar la marca temporal de la factura cuando se agregue una nueva línea.

---

## 8. Solución propuesta

### 8.1 Consulta resuelta con relaciones reales
```sql
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
```

### 8.2 Explicación paso a paso de la consulta
1. **`invoice_line`** contiene el detalle facturable.
2. **`invoice`** representa el encabezado de la factura.
3. **`sale`** conecta la factura con el negocio original.
4. **`reservation`** ubica la reserva de origen.
5. **`customer`** identifica el cliente.
6. **`person`** da el nombre legible del cliente.
7. **`tax`** completa la información tributaria cuando exista.

Se usó `LEFT JOIN` con `tax` porque `invoice_line.tax_id` puede ser nulo en el modelo. El requisito de más de 5 tablas con `INNER JOIN` se cumple en el resto de la ruta.

---

## 9. Trigger resuelto

### 9.1 Decisión técnica
Se eligió un trigger `AFTER INSERT ON invoice_line` que actualiza `invoice.updated_at`. La razón es simple: cuando cambia el detalle, el encabezado de la factura también debe reflejar modificación reciente.

### 9.2 Script del trigger
```sql
DROP TRIGGER IF EXISTS trg_ai_invoice_line_touch_invoice ON invoice_line;
DROP FUNCTION IF EXISTS fn_ai_invoice_line_touch_invoice();

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
```

### 9.3 Por qué esta solución es correcta
- usa una relación directa real,
- no necesita nuevas tablas,
- mejora trazabilidad del encabezado.

---

## 10. Procedimiento almacenado resuelto

### 10.1 Objetivo
Agregar una línea de factura calculando automáticamente el siguiente `line_number`.

### 10.2 Script del procedimiento
```sql
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
```

### 10.3 Por qué esta solución es correcta
- evita colisiones en la numeración de líneas,
- valida cantidad y valor,
- deja al trigger el ajuste temporal sobre la factura.

---

## 11. Script de demostración del funcionamiento
```sql
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
```

### 11.1 Qué demuestra este script
1. Busca una factura existente.
2. Busca un impuesto disponible, si existe.
3. Ejecuta el procedimiento.
4. Inserta una nueva línea en `invoice_line`.
5. El trigger actualiza `invoice.updated_at`.
6. La consulta final muestra la línea agregada y la marca de actualización del encabezado.

---

## 12. Validación final
La solución cumple porque:
- usa más de 5 tablas reales,
- el trigger es `AFTER INSERT`,
- el procedimiento maneja la numeración de líneas,
- la demostración evidencia el efecto sobre la factura.

---

## 13. Archivo SQL relacionado
- `scripts_sql/ejercicio_14_setup.sql`
- `scripts_sql/ejercicio_14_demo.sql`
