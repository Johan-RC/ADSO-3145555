# ADR 001 - Definición de la tabla productos

## Estado
Aceptado

## Contexto
El sistema de cafetería necesita mostrar productos disponibles para que los usuarios puedan agregarlos al carrito de compras.

## Decisión
Se creará una tabla llamada `productos` con los campos `id`, `nombre`, `descripcion`, `precio` y `stock`.

## Alternativas consideradas
- Guardar productos en una lista fija dentro del backend.
- Crear una tabla única para productos y pedidos.
- Crear una tabla independiente para productos.

## Consecuencias
- El catálogo será más fácil de consultar y actualizar.
- Se podrá controlar inventario mediante `stock`.
- La información de productos queda separada de los pedidos.
