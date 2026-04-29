# Ejercicio 04 - Trazabilidad de compras por cliente

## Contexto
La cafetería necesita consultar qué clientes han realizado pedidos y qué productos compraron.

## Dominios involucrados
- Clientes
- Pedidos
- Detalle de pedido
- Productos

## Objetivo
Crear una consulta con múltiples relaciones para mostrar la trazabilidad del pedido.

## Solución propuesta
Se usa una consulta `INNER JOIN` entre clientes, pedidos, detalle de pedido y productos.

## Resultado esperado
Se obtiene una vista clara del cliente, pedido, producto, cantidad y subtotal.
