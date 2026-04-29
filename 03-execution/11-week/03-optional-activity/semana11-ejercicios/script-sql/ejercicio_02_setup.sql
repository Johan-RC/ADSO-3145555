CREATE TABLE IF NOT EXISTS clientes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    documento VARCHAR(30) NOT NULL,
    correo VARCHAR(100),
    telefono VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS pedidos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50) DEFAULT 'PENDIENTE',
    total DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE IF NOT EXISTS detalle_pedido (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pedido_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

DROP TRIGGER IF EXISTS trg_actualizar_total_pedido;

DELIMITER //
CREATE TRIGGER trg_actualizar_total_pedido
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE pedidos
    SET total = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM detalle_pedido
        WHERE pedido_id = NEW.pedido_id
    )
    WHERE id = NEW.pedido_id;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_agregar_producto_pedido;

DELIMITER //
CREATE PROCEDURE sp_agregar_producto_pedido(
    IN p_pedido_id BIGINT,
    IN p_producto_id BIGINT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_precio DECIMAL(10,2);

    SELECT precio INTO v_precio
    FROM productos
    WHERE id = p_producto_id;

    INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (p_pedido_id, p_producto_id, p_cantidad, v_precio, p_cantidad * v_precio);
END //
DELIMITER ;
