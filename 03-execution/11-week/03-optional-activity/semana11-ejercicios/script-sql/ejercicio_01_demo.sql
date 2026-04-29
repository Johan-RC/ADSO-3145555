CALL sp_registrar_producto('Empanada', 'Empanada de carne', 2500, 30);
CALL sp_registrar_producto('Gaseosa', 'Bebida personal', 3000, 20);
CALL sp_registrar_producto('Cafe', 'Cafe caliente', 1500, 40);

SELECT
    id,
    nombre,
    descripcion,
    precio,
    stock,
    CASE
        WHEN stock > 0 THEN 'Disponible'
        ELSE 'Agotado'
    END AS disponibilidad
FROM productos;
