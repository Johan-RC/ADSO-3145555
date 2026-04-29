UPDATE productos
SET precio = precio + 500,
    stock = stock + 10
WHERE nombre = 'Empanada';

SELECT
    producto_id,
    nombre_producto,
    precio_anterior,
    precio_nuevo,
    stock_anterior,
    stock_nuevo,
    fecha_cambio
FROM auditoria_productos
ORDER BY fecha_cambio DESC;
