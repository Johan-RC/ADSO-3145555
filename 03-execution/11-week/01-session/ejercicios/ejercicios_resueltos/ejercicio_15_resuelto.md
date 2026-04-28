# Ejercicio 15 Resuelto - Asignación controlada de roles a usuarios

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
Se necesita una forma segura y reutilizable de asignar roles a usuarios del sistema. Además, cuando un rol nuevo queda asignado, el registro del usuario debe reflejar que fue actualizado.

---

## 6. Dominios involucrados
### SECURITY
**Entidades:** `user_account`, `user_status`, `security_role`, `security_permission`, `user_role`, `role_permission`  
**Propósito en este ejercicio:** modelar el acceso del usuario, sus roles y los permisos derivados.

### IDENTITY
**Entidades:** `person`  
**Propósito en este ejercicio:** mostrar la identidad de la persona detrás de la cuenta de usuario.

---

## 7. Problema a resolver
La tabla `user_role` es la relación de asignación entre usuarios y roles. Como existe una restricción de unicidad sobre `(user_account_id, security_role_id)`, la lógica debe evitar duplicados y, a la vez, dejar traza temporal en `user_account`.

---

## 8. Solución propuesta

### 8.1 Consulta resuelta con `INNER JOIN`
```sql
SELECT
    ua.username,
    us.status_name AS user_status_name,
    p.first_name,
    p.last_name,
    sr.role_name,
    sp.permission_name,
    ur.assigned_at
FROM user_account ua
INNER JOIN user_status us
    ON us.user_status_id = ua.user_status_id
INNER JOIN person p
    ON p.person_id = ua.person_id
INNER JOIN user_role ur
    ON ur.user_account_id = ua.user_account_id
INNER JOIN security_role sr
    ON sr.security_role_id = ur.security_role_id
INNER JOIN role_permission rp
    ON rp.security_role_id = sr.security_role_id
INNER JOIN security_permission sp
    ON sp.security_permission_id = rp.security_permission_id
ORDER BY ua.username, sr.role_name, sp.permission_name;
```

### 8.2 Explicación paso a paso de la consulta
1. **`user_account`** representa la cuenta.
2. **`user_status`** aporta el estado actual.
3. **`person`** muestra la identidad.
4. **`user_role`** conecta usuario y rol.
5. **`security_role`** nombra el rol asignado.
6. **`role_permission`** enlaza el rol con sus permisos.
7. **`security_permission`** expone el permiso concreto.

Esta consulta es útil para auditar qué puede hacer cada usuario a partir de sus roles activos.

---

## 9. Trigger resuelto

### 9.1 Decisión técnica
Se eligió un trigger `AFTER INSERT ON user_role` para actualizar `user_account.updated_at`. El motivo es que la asignación de un nuevo rol cambia el perfil operativo del usuario.

### 9.2 Script del trigger
```sql
DROP TRIGGER IF EXISTS trg_ai_user_role_touch_user_account ON user_role;
DROP FUNCTION IF EXISTS fn_ai_user_role_touch_user_account();

CREATE OR REPLACE FUNCTION fn_ai_user_role_touch_user_account()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE user_account
    SET updated_at = now()
    WHERE user_account_id = NEW.user_account_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_user_role_touch_user_account
AFTER INSERT ON user_role
FOR EACH ROW
EXECUTE FUNCTION fn_ai_user_role_touch_user_account();
```

### 9.3 Por qué esta solución es correcta
- se apoya en una relación directa real,
- no inventa auditorías paralelas,
- actualiza el usuario cuando cambia su perfil de acceso.

---

## 10. Procedimiento almacenado resuelto

### 10.1 Objetivo
Asignar un rol a un usuario evitando duplicados.

### 10.2 Script del procedimiento
```sql
CREATE OR REPLACE PROCEDURE sp_assign_user_role(
    p_user_account_id uuid,
    p_security_role_id uuid,
    p_assigned_by_user_id uuid
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM user_role ur
        WHERE ur.user_account_id = p_user_account_id
          AND ur.security_role_id = p_security_role_id
    ) THEN
        RAISE NOTICE 'La asignacion ya existe para el usuario % y rol %.', p_user_account_id, p_security_role_id;
        RETURN;
    END IF;

    INSERT INTO user_role (
        user_account_id,
        security_role_id,
        assigned_by_user_id
    )
    VALUES (
        p_user_account_id,
        p_security_role_id,
        p_assigned_by_user_id
    );
END;
$$;
```

### 10.3 Por qué esta solución es correcta
- respeta la restricción única del modelo,
- centraliza la asignación,
- deja al trigger el ajuste de trazabilidad temporal.

---

## 11. Script de demostración del funcionamiento
```sql
DO $$
DECLARE
    v_user_account_id uuid;
    v_security_role_id uuid;
    v_assigned_by_user_id uuid;
BEGIN
    SELECT ua.user_account_id
    INTO v_user_account_id
    FROM user_account ua
    ORDER BY ua.created_at
    LIMIT 1;

    SELECT ua.user_account_id
    INTO v_assigned_by_user_id
    FROM user_account ua
    ORDER BY ua.created_at
    LIMIT 1;

    SELECT sr.security_role_id
    INTO v_security_role_id
    FROM security_role sr
    LEFT JOIN user_role ur
        ON ur.security_role_id = sr.security_role_id
       AND ur.user_account_id = v_user_account_id
    WHERE ur.user_role_id IS NULL
    ORDER BY sr.created_at
    LIMIT 1;

    IF v_user_account_id IS NULL THEN
        RAISE EXCEPTION 'No existe user_account disponible.';
    END IF;

    IF v_security_role_id IS NULL THEN
        RAISE EXCEPTION 'No existe security_role disponible para asignar al usuario seleccionado.';
    END IF;

    CALL sp_assign_user_role(
        v_user_account_id,
        v_security_role_id,
        v_assigned_by_user_id
    );
END;
$$;

SELECT
    ua.username,
    ua.updated_at,
    sr.role_name,
    ur.assigned_at
FROM user_role ur
INNER JOIN user_account ua
    ON ua.user_account_id = ur.user_account_id
INNER JOIN security_role sr
    ON sr.security_role_id = ur.security_role_id
ORDER BY ur.created_at DESC
LIMIT 5;
```

### 11.1 Qué demuestra este script
1. selecciona un usuario existente,
2. busca un rol que todavía no esté asignado a ese usuario,
3. invoca el procedimiento,
4. inserta la relación en `user_role`,
5. el trigger actualiza el `updated_at` del usuario,
6. la consulta final muestra la nueva asignación.

---

## 12. Validación final
La solución es válida porque:
- la consulta une más de 5 tablas reales,
- el trigger es `AFTER INSERT`,
- el procedimiento evita duplicados,
- la demostración evidencia la asignación y la actualización temporal del usuario.

---

## 13. Archivo SQL relacionado
- `scripts_sql/ejercicio_15_setup.sql`
- `scripts_sql/ejercicio_15_demo.sql`
