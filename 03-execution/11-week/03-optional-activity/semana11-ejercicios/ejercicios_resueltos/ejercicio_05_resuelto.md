# Ejercicio 05 - Auditoría básica de cambios en productos

## Contexto
Cuando se modifica el precio o stock de un producto, es importante dejar evidencia del cambio.

## Dominios involucrados
- Productos
- Auditoría

## Objetivo
Crear una tabla de auditoría y un trigger que registre cambios realizados sobre productos.

## Solución propuesta
Se crea la tabla `auditoria_productos` y el trigger `trg_auditoria_productos`.

## Resultado esperado
Cada vez que se actualice un producto, se registrará el precio y stock anterior y nuevo.
