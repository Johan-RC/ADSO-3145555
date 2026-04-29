# ADR 003 - Manejo de estados del pedido

## Estado
Aceptado

## Contexto
Los pedidos necesitan pasar por estados como pendiente, en preparación, entregado o cancelado.

## Decisión
Se agregará un campo `estado` en la tabla `pedidos`, inicialmente como `VARCHAR`.

## Alternativas consideradas
- No manejar estados.
- Usar un campo booleano.
- Crear una tabla catálogo.
- Usar un campo de texto.

## Consecuencias
- Se podrá hacer seguimiento básico del pedido.
- El sistema será más claro para usuarios y cafetería.
- En el futuro puede reemplazarse por una tabla catálogo.
