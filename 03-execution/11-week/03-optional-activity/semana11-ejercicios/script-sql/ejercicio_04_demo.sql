SELECT
    c.nombre AS cliente,
    p.id AS pedido_id,
    p.estado,
    pr.nombre AS producto,
    dp.cantidad,
    dp.precio_unitario,
    dp.subtotal,
    p.total
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
INNER JOIN detalle_pedido dp ON p.id = dp.pedido_id
INNER JOIN productos pr ON dp.producto_id = pr.id
ORDER BY p.id DESC, pr.nombre;
