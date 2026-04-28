# Ejercicio 03 - Facturación e integración entre venta, impuestos y detalle facturable

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

## 4. Enfoque de los ejercicios
Los ejercicios planteados sobre este modelo tendrán como propósito que el estudiante analice relaciones reales entre entidades y construya soluciones en PostgreSQL sin alterar la estructura base del sistema.

Cada ejercicio se formulará para que el estudiante:
- interprete correctamente los dominios involucrados,
- construya consultas con múltiples relaciones,
- diseñe automatizaciones con triggers,
- implemente lógica reutilizable mediante procedimientos almacenados,
- y demuestre técnicamente el funcionamiento con scripts de prueba.

---

## 5. Restricción general para todos los ejercicios
Todos los ejercicios deben resolverse respetando estrictamente el modelo entregado.

No está permitido:
- cambiar atributos existentes,
- renombrar tablas o columnas,
- alterar relaciones,
- inventar entidades fuera del script base,
- ni modificar la estructura general del modelo.

La solución deberá construirse únicamente sobre las entidades y relaciones reales definidas en el script.

---

## 6. Contexto del ejercicio
El área de facturación necesita relacionar ventas, facturas y líneas facturables con impuestos aplicados para validar la consistencia del flujo comercial y automatizar acciones posteriores sobre el detalle facturable.

---

## 7. Dominios involucrados en este ejercicio
### SALES, RESERVATION, TICKETING
**Entidades:** `sale`, `reservation`  
**Propósito:** Proveer el origen comercial de la facturación.

### BILLING
**Entidades:** `invoice`, `invoice_status`, `invoice_line`, `tax`, `exchange_rate`  
**Propósito:** Gestionar factura, estado, detalle facturable, impuestos y apoyo de conversión monetaria cuando aplique.

### GEOGRAPHY AND REFERENCE DATA
**Entidades:** `currency`  
**Propósito:** Normalizar la moneda de la venta y de la factura.

---

## 8. Planteamiento del problema
Se requiere consultar el detalle facturable derivado de una venta y definir una automatización posterior para mantener coherencia entre la cabecera de la factura y sus líneas asociadas.

---

## 9. Objetivo del ejercicio
Definir un caso de análisis y automatización sobre facturación que conecte venta, factura, líneas e impuestos, usando consultas multi-tabla, trigger posterior y procedimiento almacenado.

---

## 10. Requerimiento 1 - Consulta con `INNER JOIN` de al menos 5 tablas

### Enunciado
Construya una consulta SQL que muestre la relación entre venta, factura, estado de factura, líneas facturables, impuesto aplicado y moneda.

### Restricciones obligatorias
- Debe usar **`INNER JOIN`**
- Debe involucrar **mínimo 5 tablas**
- Debe usar únicamente entidades y atributos existentes en el modelo base
- No se permite cambiar nombres de tablas ni columnas
- La consulta debe ser coherente con las relaciones reales del modelo

### Tablas mínimas sugeridas
El estudiante deberá incluir, como mínimo, una combinación válida de tablas como:
- `sale`
- `invoice`
- `invoice_status`
- `invoice_line`
- `tax`
- `currency`

### Resultado esperado a nivel funcional
La consulta debe permitir responder una necesidad como esta: “Mostrar por cada factura el documento comercial de origen, su estado, las líneas facturables registradas y el impuesto aplicado en cada línea”.

### Campos esperados en el resultado
Como mínimo, el resultado debe exponer columnas equivalentes a:
- código de venta
- número de factura
- estado de factura
- línea facturable
- descripción de la línea
- cantidad
- precio unitario
- impuesto aplicado
- moneda

> El estudiante define la consulta exacta, pero debe respetar estrictamente el modelo base.

---

## 11. Requerimiento 2 - Trigger `AFTER`

### Enunciado
Diseñe un trigger `AFTER INSERT` sobre `invoice_line` que automatice una acción posterior relacionada con la tabla `invoice` o con la consistencia del flujo de facturación.

### Condición funcional del trigger
Cada vez que se registre una nueva línea facturable, el trigger deberá ejecutar una acción verificable sobre la factura asociada o sobre la trazabilidad del proceso definido por el estudiante.

### Restricciones del trigger
- Debe ser un trigger **`AFTER`**
- Debe operar sobre tablas reales del modelo
- No puede modificar atributos existentes del modelo base
- No puede cambiar la definición de las tablas originales
- La solución debe ser coherente con las relaciones reales entre las tablas involucradas

### Demostración obligatoria
El estudiante deberá entregar un **script de prueba** que dispare el trigger.

### Condición mínima de la demostración
El script de prueba debe:
1. Identificar o preparar los datos necesarios del modelo base
2. Ejecutar la operación que dispare el trigger
3. Verificar el efecto posterior generado por el trigger

> El estudiante deberá decidir cómo validar el resultado, siempre sobre entidades reales del modelo.

---

## 12. Requerimiento 3 - Procedimiento almacenado

### Enunciado
Diseñe un procedimiento almacenado que registre una nueva línea facturable sobre una factura existente.

### Propósito del procedimiento
Encapsular la creación del detalle facturable para asegurar consistencia y reutilización.

### Alcance funcional mínimo
El procedimiento debe permitir trabajar con información relacionada con:
- factura existente
- impuesto aplicado, si corresponde
- número de línea
- descripción
- cantidad
- precio unitario

### Restricciones obligatorias
- Debe implementarse como **procedimiento almacenado**
- Debe trabajar sobre tablas y atributos existentes
- No puede cambiar la estructura del modelo base
- Debe ser reutilizable
- Debe poder invocarse desde un script SQL independiente

### Integración esperada
La operación realizada por el procedimiento debe poder disparar el trigger y dejar evidencia verificable en la factura o en la lógica posterior seleccionada.

---

## 13. Script de uso del procedimiento

### Enunciado
El estudiante deberá entregar un script SQL que invoque el procedimiento almacenado desarrollado.

### Propósito del script
Demostrar que el procedimiento:
1. recibe los parámetros necesarios,
2. ejecuta la operación principal del ejercicio,
3. activa el trigger definido previamente o deja lista la evidencia para validarlo,
4. deja evidencia verificable del proceso.

### Contenido mínimo esperado
El script debe incluir:
- búsqueda o selección previa de identificadores necesarios
- invocación del procedimiento
- consulta posterior de validación

---

## 14. Entregables del estudiante
El estudiante deberá entregar:

1. **Consulta SQL** con `INNER JOIN` de mínimo 5 tablas  
2. **Trigger `AFTER`**  
3. **Función u objeto auxiliar necesario para el trigger**, si su diseño lo requiere  
4. **Procedimiento almacenado**  
5. **Script que dispare el trigger**  
6. **Script que invoque el procedimiento**  
7. **Consultas de validación** que demuestren el funcionamiento

---

## 15. Criterios de aceptación
La solución propuesta por el estudiante será válida si cumple con todo lo siguiente:

- La consulta utiliza `INNER JOIN`
- La consulta relaciona al menos 5 tablas reales del modelo
- El trigger es coherente con la necesidad del negocio
- El trigger produce un efecto verificable sobre tablas reales
- Existe un script que demuestra su ejecución
- El procedimiento almacenado encapsula una operación útil del negocio
- Existe un script que invoca el procedimiento
- La invocación del procedimiento permite evidenciar también el funcionamiento del trigger o del flujo solicitado
- No se alteró la estructura base del modelo

---

## 16. Observación final
Este ejercicio no solicita la solución final enunciada en el documento. El estudiante deberá diseñarla e implementarla respetando las restricciones técnicas del modelo base.
