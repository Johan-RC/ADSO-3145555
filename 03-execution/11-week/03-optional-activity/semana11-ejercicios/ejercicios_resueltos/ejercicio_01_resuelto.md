# Ejercicio 01 - Gestión de productos e inventario

## Contexto
La cafetería necesita consultar los productos disponibles y controlar el inventario cuando se agregan productos al sistema.

## Dominios involucrados
- Productos
- Inventario

## Objetivo
Crear una consulta principal para listar productos y un procedimiento almacenado para registrar productos nuevos.

## Solución propuesta
Se crea el procedimiento `sp_registrar_producto`, el cual permite insertar un producto con nombre, descripción, precio y stock inicial.

## Consulta principal
La consulta muestra los productos registrados, su precio, stock y disponibilidad.

## Resultado esperado
El sistema podrá registrar productos de forma controlada y consultar cuáles están disponibles para la venta.
