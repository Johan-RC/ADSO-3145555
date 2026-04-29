# Ejercicio 02 - Registro de pedidos y cálculo automático del total

## Contexto
Un pedido puede contener varios productos. Cada producto agregado debe generar un subtotal y actualizar el total del pedido.

## Dominios involucrados
- Clientes
- Pedidos
- Detalle de pedido
- Productos

## Objetivo
Crear un trigger que actualice automáticamente el total del pedido cada vez que se agregue un detalle.

## Solución propuesta
Se crea el trigger `trg_actualizar_total_pedido`, que se ejecuta después de insertar en `detalle_pedido`.

## Resultado esperado
El campo `total` de la tabla `pedidos` se actualiza sin hacerlo manualmente.
