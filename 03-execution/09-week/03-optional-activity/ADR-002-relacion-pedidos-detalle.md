# ADR 002 - Separación entre pedidos y detalle de pedido

## Estado
Aceptado

## Contexto
Un usuario puede realizar un pedido con varios productos. Si todo se guarda en una sola tabla, el modelo se vuelve repetitivo.

## Decisión
Se separará la información en dos tablas: `pedidos` y `detalle_pedido`. La tabla `detalle_pedido` tendrá relación con `pedidos` y `productos`.

## Alternativas consideradas
- Guardar todo en una sola tabla.
- Guardar productos seleccionados como texto.
- Crear una tabla intermedia de detalle.

## Consecuencias
- Se mejora la normalización.
- Un pedido puede tener varios productos.
- Se facilita el cálculo de subtotales y total.
