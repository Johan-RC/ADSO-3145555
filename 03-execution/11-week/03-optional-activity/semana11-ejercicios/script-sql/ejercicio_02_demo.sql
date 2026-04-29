INSERT INTO clientes (nombre, documento, correo, telefono)
VALUES ('Cliente Prueba', '1000000001', 'cliente@correo.com', '3001234567');

INSERT INTO pedidos (cliente_id)
VALUES ((SELECT id FROM clientes ORDER BY id DESC LIMIT 1));

CALL sp_agregar_producto_pedido(
    (SELECT id FROM pedidos ORDER BY id DESC LIMIT 1),
    (SELECT id FROM productos WHERE nombre = 'Empanada' LIMIT 1),
    2
);

CALL sp_agregar_producto_pedido(
    (SELECT id FROM pedidos ORDER BY id DESC LIMIT 1),
    (SELECT id FROM productos WHERE nombre = 'Gaseosa' LIMIT 1),
    1
);

SELECT
    p.id AS pedido_id,
    c.nombre AS cliente,
    p.estado,
    p.total,
    p.fecha
FROM pedidos p
INNER JOIN clientes c ON p.cliente_id = c.id
ORDER BY p.id DESC;
