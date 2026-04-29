# ADR 004 - Registro de fechas de creación y actualización

## Estado
Aceptado

## Contexto
Es importante conocer cuándo fue creado o actualizado un registro.

## Decisión
Se agregarán los campos `created_at` y `updated_at` en las tablas principales.

## Alternativas consideradas
- No guardar fechas.
- Registrar fechas desde el backend.
- Manejar fechas desde la base de datos.

## Consecuencias
- Se mejora la trazabilidad.
- Se puede saber cuándo se creó o modificó un pedido.
- El sistema queda preparado para auditoría básica.
