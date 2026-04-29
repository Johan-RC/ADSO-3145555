DROP PROCEDURE IF EXISTS sp_cambiar_estado_pedido;

DELIMITER //
CREATE PROCEDURE sp_cambiar_estado_pedido(
    IN p_pedido_id BIGINT,
    IN p_estado VARCHAR(50)
)
BEGIN
    UPDATE pedidos
    SET estado = p_estado
    WHERE id = p_pedido_id;
END //
DELIMITER ;
