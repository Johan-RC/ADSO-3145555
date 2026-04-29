CALL sp_cambiar_estado_pedido(
    (SELECT id FROM pedidos ORDER BY id DESC LIMIT 1),
    'EN_PREPARACION'
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
