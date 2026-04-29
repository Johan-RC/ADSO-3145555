CREATE TABLE IF NOT EXISTS auditoria_productos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT NOT NULL,
    nombre_producto VARCHAR(100),
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    stock_anterior INT,
    stock_nuevo INT,
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_auditoria_productos;

DELIMITER //
CREATE TRIGGER trg_auditoria_productos
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_productos (
        producto_id,
        nombre_producto,
        precio_anterior,
        precio_nuevo,
        stock_anterior,
        stock_nuevo
    )
    VALUES (
        OLD.id,
        OLD.nombre,
        OLD.precio,
        NEW.precio,
        OLD.stock,
        NEW.stock
    );
END //
DELIMITER ;
