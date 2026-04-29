CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- =====================================================
-- Tabla: type_document
-- Entidad que guarda los tipos de documento de una persona.
-- =====================================================
CREATE TABLE type_document(
-- Parámetros / campos de la tabla:
-- id_type_document: Identificador único de la tabla.
id_type_document UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- name_document: Nombre o descripción principal del registro.
name_document VARCHAR(50),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla type_document


-- =====================================================
-- Tabla: files
-- Entidad para almacenar archivos o documentos asociados.
-- =====================================================
CREATE TABLE files(
-- Parámetros / campos de la tabla:
-- id_file: Identificador único de la tabla.
id_file UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- name_file: Nombre o descripción principal del registro.
name_file VARCHAR(100),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla files


-- =====================================================
-- Tabla: person
-- Entidad persona; aquí van los datos personales del usuario o cliente.
-- =====================================================
CREATE TABLE person(
-- Parámetros / campos de la tabla:
-- id_person: Relación con la entidad persona.
id_person UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- name_person: Nombre o descripción principal del registro.
name_person VARCHAR(100),
-- email: Correo electrónico de la persona.
email VARCHAR(100),
-- document_number: Número de documento de identificación.
document_number VARCHAR(50),
-- type_document_id: Llave foránea que relaciona esta tabla con otra entidad.
type_document_id UUID,
-- file_id: Llave foránea que relaciona esta tabla con otra entidad.
file_id UUID,
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla person


-- =====================================================
-- Tabla: users
-- Entidad usuario; guarda las credenciales de acceso al sistema.
-- =====================================================
CREATE TABLE users(
-- Parámetros / campos de la tabla:
-- id_users: Identificador único del usuario.
id_users UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- user_name: Nombre de usuario para iniciar sesión.
user_name VARCHAR(100),
-- password_user: Contraseña del usuario.
password_user VARCHAR(100),
-- id_person: Relación con la entidad persona.
id_person UUID,
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla users



-- =====================================================
-- Tabla: roles
-- Entidad rol; define los permisos o perfiles del sistema.
-- =====================================================
CREATE TABLE roles(
-- Parámetros / campos de la tabla:
-- id_role: Identificador único del rol.
id_role UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- name_role: Nombre o descripción principal del registro.
name_role VARCHAR(50),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla roles



-- =====================================================
-- Tabla: user_role
-- Tabla intermedia que relaciona usuarios con roles.
-- =====================================================
CREATE TABLE user_role(
-- Parámetros / campos de la tabla:
-- id_user_role: Identificador único de la tabla.
id_user_role UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- users_id: Llave foránea que relaciona esta tabla con otra entidad.
users_id UUID,
-- role_id: Llave foránea que relaciona esta tabla con otra entidad.
role_id UUID,
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla user_role



-- =====================================================
-- Tabla: modules
-- Entidad módulo; agrupa funcionalidades del sistema.
-- =====================================================
CREATE TABLE modules(
-- Parámetros / campos de la tabla:
-- id_module: Identificador único de la tabla.
id_module UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- name_modules: Nombre o descripción principal del registro.
name_modules VARCHAR(100),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla modules



-- =====================================================
-- Tabla: app_view
-- Entidad vista; guarda las rutas o pantallas del sistema.
-- =====================================================
CREATE TABLE app_view(
-- Parámetros / campos de la tabla:
-- id_view: Identificador único de la tabla.
id_view UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- name_view: Nombre o descripción principal del registro.
name_view VARCHAR(100),
-- rout: Ruta o dirección de acceso a la vista.
rout VARCHAR(150),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla app_view



-- =====================================================
-- Tabla: module_view
-- Tabla intermedia que relaciona módulos con vistas.
-- =====================================================
CREATE TABLE module_view(
-- Parámetros / campos de la tabla:
-- id_module_view: Identificador único de la tabla.
id_module_view UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- module_id: Llave foránea que relaciona esta tabla con otra entidad.
module_id UUID,
-- view_id: Llave foránea que relaciona esta tabla con otra entidad.
view_id UUID,
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla module_view



-- =====================================================
-- Tabla: category
-- Entidad categoría; clasifica los productos.
-- =====================================================
CREATE TABLE category(
-- Parámetros / campos de la tabla:
-- id_category: Identificador único de la tabla.
id_category UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- name_category: Nombre o descripción principal del registro.
name_category VARCHAR(100),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla category



-- =====================================================
-- Tabla: supplier
-- Entidad proveedor; almacena los proveedores de productos.
-- =====================================================
CREATE TABLE supplier(
-- Parámetros / campos de la tabla:
-- id_supplier: Identificador único de la tabla.
id_supplier UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- name_supplier: Nombre o descripción principal del registro.
name_supplier VARCHAR(100),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla supplier



-- =====================================================
-- Tabla: product
-- Entidad producto; aquí se registran los productos disponibles.
-- =====================================================
CREATE TABLE product(
-- Parámetros / campos de la tabla:
-- id_product: Identificador único de la tabla.
id_product UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- name_product: Nombre o descripción principal del registro.
name_product VARCHAR(100),
-- description: Campo o parámetro de la entidad.
description VARCHAR(100),
-- price: Precio del producto.
price NUMERIC(12,2),
-- supplier_id: Llave foránea que relaciona esta tabla con otra entidad.
supplier_id UUID,
-- category_id: Llave foránea que relaciona esta tabla con otra entidad.
category_id UUID,
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla product



-- =====================================================
-- Tabla: inventory
-- Entidad inventario; controla la cantidad disponible de cada producto.
-- =====================================================
CREATE TABLE inventory(
-- Parámetros / campos de la tabla:
-- id_inventory: Identificador único de la tabla.
id_inventory UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- quantity: Cantidad de productos.
quantity INTEGER,
-- product_id: Llave foránea que relaciona esta tabla con otra entidad.
product_id UUID,
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla inventory


-- =====================================================
-- Tabla: customer
-- Entidad cliente; relaciona una persona con el rol de cliente.
-- =====================================================
CREATE TABLE customer(
-- Parámetros / campos de la tabla:
-- id_customer: Identificador único de la tabla.
id_customer UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- person_id: Llave foránea que relaciona esta tabla con otra entidad.
person_id UUID,
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla customer



-- =====================================================
-- Tabla: app_order
-- Entidad pedido; almacena los pedidos realizados por los clientes.
-- =====================================================
CREATE TABLE app_order(
-- Parámetros / campos de la tabla:
-- id_order: Identificador único de la tabla.
id_order UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- order_date: Fecha en que se realiza el pedido.
order_date TIMESTAMPTZ DEFAULT NOW(),
-- order_status: Estado actual del pedido.
order_status VARCHAR(50),
-- total: Valor total.
total NUMERIC(12,2),
-- customer_id: Llave foránea que relaciona esta tabla con otra entidad.
customer_id UUID,
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla app_order



-- =====================================================
-- Tabla: order_item
-- Detalle del pedido; guarda los productos incluidos en cada pedido.
-- =====================================================
CREATE TABLE order_item(
-- Parámetros / campos de la tabla:
-- id_order_item: Identificador único de la tabla.
id_order_item UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- orden_id: Llave foránea que relaciona esta tabla con otra entidad.
orden_id UUID,
-- product_id: Llave foránea que relaciona esta tabla con otra entidad.
product_id UUID,
-- quantity: Cantidad de productos.
quantity INTEGER,
-- subtotal: Subtotal calculado para el detalle.
subtotal NUMERIC(12,2),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla order_item


-- =====================================================
-- Tabla: invoice
-- Entidad factura; registra la información de facturación del pedido.
-- =====================================================
CREATE TABLE invoice(
-- Parámetros / campos de la tabla:
-- id_invoice: Identificador único de la tabla.
id_invoice UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- order_id: Llave foránea que relaciona esta tabla con otra entidad.
order_id UUID,
-- invoice_number: Número de factura.
invoice_number VARCHAR(50),
-- issue_date: Fecha de emisión de la factura.
issue_date TIMESTAMPTZ,
-- total: Valor total.
total NUMERIC(10,2),
-- invoice_status: Estado de la factura.
invoice_status VARCHAR(50),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla invoice



-- =====================================================
-- Tabla: invoice_item
-- Detalle de factura; guarda los productos facturados.
-- =====================================================
CREATE TABLE invoice_item(
-- Parámetros / campos de la tabla:
-- id_invoice_item: Identificador único de la tabla.
id_invoice_item UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- invoice_id: Llave foránea que relaciona esta tabla con otra entidad.
invoice_id UUID,
-- product_id: Llave foránea que relaciona esta tabla con otra entidad.
product_id UUID,
-- quantity: Cantidad de productos.
quantity INTEGER,
-- unit_price: Campo o parámetro de la entidad.
unit_price NUMERIC(10,2),
-- subtotal: Subtotal calculado para el detalle.
subtotal NUMERIC(10,2),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla invoice_item



-- =====================================================
-- Tabla: method_payment
-- Entidad método de pago; almacena las formas de pago disponibles.
-- =====================================================
CREATE TABLE method_payment(
-- Parámetros / campos de la tabla:
-- id_method_payment: Identificador único de la tabla.
id_method_payment UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- name_method_payment: Nombre o descripción principal del registro.
name_method_payment VARCHAR(50),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla method_payment


-- =====================================================
-- Tabla: payment
-- Entidad pago; registra los pagos realizados por una factura.
-- =====================================================
CREATE TABLE payment(
-- Parámetros / campos de la tabla:
-- id: Campo o parámetro de la entidad.
id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
-- invoice_id: Llave foránea que relaciona esta tabla con otra entidad.
invoice_id UUID,
-- method_payment_id: Llave foránea que relaciona esta tabla con otra entidad.
method_payment_id UUID,
-- amount: Valor pagado.
amount NUMERIC(10,2),
-- payment_date: Fecha en que se realiza el pago.
payment_date TIMESTAMPTZ DEFAULT NOW(),
-- created_at: Fecha de creación del registro.
created_at TIMESTAMPTZ DEFAULT NOW(),
-- updated_at: Fecha de actualización del registro.
updated_at TIMESTAMPTZ,
-- deleted_at: Fecha de eliminación lógica del registro.
deleted_at TIMESTAMPTZ,
-- created_by: Usuario que creó el registro.
created_by UUID,
-- updated_by: Usuario que actualizó el registro.
updated_by UUID,
-- deleted_by: Usuario que eliminó el registro.
deleted_by UUID,
-- status: Estado lógico del registro: TRUE activo, FALSE inactivo.
status BOOLEAN DEFAULT TRUE
);
-- Fin de la tabla payment





-- =====================================================
-- Inserción de datos de prueba
-- En esta sección se agregan registros iniciales para probar la base de datos.
-- =====================================================
---INSERT



-- Insertar datos en la tabla type_document
INSERT INTO type_document (name_document) VALUES
('Cédula'),
('Pasaporte'),
('Tarjeta Identidad'),
('Licencia Conducción'),
('NIT'),
('Registro Civil'),
('PEP'),
('DNI'),
('Documento Militar'),
('Carnet Estudiantil');


-- Insertar datos en la tabla files
INSERT INTO files (name_file) VALUES
('doc1.pdf'),
('doc2.pdf'),
('doc3.pdf'),
('doc4.pdf'),
('doc5.pdf'),
('doc6.pdf'),
('doc7.pdf'),
('doc8.pdf'),
('doc9.pdf'),
('doc10.pdf');




-- Insertar datos en la tabla person
INSERT INTO person (name_person,email,document_number,type_document_id,file_id)
SELECT 
'Persona ' || g,
'persona'||g||'@mail.com',
1000+g,
(SELECT id_type_document FROM type_document ORDER BY RANDOM() LIMIT 1),
(SELECT id_file FROM files ORDER BY RANDOM() LIMIT 1)
FROM generate_series(1,10) g;


-- Insertar datos en la tabla users
INSERT INTO users (user_name,password_user,id_person)
SELECT 
name_person,
'123456',
id_person
FROM person
LIMIT 10;



-- Insertar datos en la tabla roles
INSERT INTO roles (name_role) VALUES
('Administrador'),
('Empleado'),
('Cliente'),
('Supervisor'),
('Vendedor'),
('Cajero'),
('Gerente'),
('Soporte'),
('Invitado'),
('Auditor');


-- Insertar datos en la tabla user_role
INSERT INTO user_role (users_id,role_id)
SELECT 
(SELECT id_users FROM users ORDER BY RANDOM() LIMIT 1),
(SELECT id_role FROM roles ORDER BY RANDOM() LIMIT 1)
FROM generate_series(1,10);


-- Insertar datos en la tabla supplier
INSERT INTO supplier (name_supplier) VALUES
('Proveedor nutresa'),
('Proveedor coca-cola'),
('Proveedor colanta'),
('Proveedor centrosur'),
('Proveedor superior'),
('Proveedor casaluker'),
('Proveedor roa'),
('Proveedor florhuila'),
('Proveedor soberana'),
('Proveedor bimbo');



-- Insertar datos en la tabla category
INSERT INTO category (name_category) VALUES
('Electrónica'),
('Ropa'),
('Hogar'),
('Deportes'),
('Tecnología'),
('Juguetes'),
('Alimentos'),
('Bebidas'),
('Libros'),
('Accesorios');


-- Insertar datos en la tabla product
INSERT INTO product (name_product,description,price,supplier_id,category_id)
SELECT
'Producto '||g,
'Descripción producto '||g,
(100*g),
(SELECT id_supplier FROM supplier ORDER BY RANDOM() LIMIT 1),
(SELECT id_category FROM category ORDER BY RANDOM() LIMIT 1)
FROM generate_series(1,10) g;


-- Insertar datos en la tabla inventory
INSERT INTO inventory (quantity, product_id)
SELECT
10,
id_product
FROM product
LIMIT 10;


-- Insertar datos en la tabla customer
INSERT INTO customer (person_id)
SELECT id_person
FROM person
LIMIT 10;


-- Insertar datos en la tabla app_order
INSERT INTO app_order (order_status,total,customer_id)
SELECT
'Pendiente',
(200*g),
(SELECT id_customer FROM customer ORDER BY RANDOM() LIMIT 1)
FROM generate_series(1,10) g;


-- Insertar datos en la tabla order_item
INSERT INTO order_item (orden_id,product_id,quantity,subtotal)
SELECT
(SELECT id_order FROM app_order ORDER BY RANDOM() LIMIT 1),
(SELECT id_product FROM product ORDER BY RANDOM() LIMIT 1),
(1+floor(random()*5)),
(100+floor(random()*500))
FROM generate_series(1,10);


-- Insertar datos en la tabla invoice
INSERT INTO invoice (order_id, invoice_number, total, invoice_status)
SELECT
id_order,
'F001',
500,
'Pagada'
FROM app_order
LIMIT 10;



-- Insertar datos en la tabla invoice_item
INSERT INTO invoice_item (invoice_id,product_id,quantity,unit_price,subtotal)
SELECT
(SELECT id_invoice FROM invoice ORDER BY RANDOM() LIMIT 1),
(SELECT id_product FROM product ORDER BY RANDOM() LIMIT 1),
(1+floor(random()*5)),
(100),
(200)
FROM generate_series(1,10);


-- Insertar datos en la tabla method_payment
INSERT INTO method_payment (name_method_payment) VALUES
('Efectivo'),
('Tarjeta Débito'),
('Tarjeta Crédito'),
('Transferencia'),
('Nequi'),
('Daviplata'),
('PayPal'),
('Consignación'),
('Cheque'),
('Crédito');


-- Insertar datos en la tabla payment
INSERT INTO payment (invoice_id,method_payment_id,amount)
SELECT
(SELECT id_invoice FROM invoice ORDER BY RANDOM() LIMIT 1),
(SELECT id_method_payment FROM method_payment ORDER BY RANDOM() LIMIT 1),
(100+floor(random()*900))
FROM generate_series(1,10);

-- =====================================================
-- Relaciones / llaves foraneas actualizadas
-- =====================================================
ALTER TABLE person ADD CONSTRAINT fk_person_type_document_id FOREIGN KEY (type_document_id) REFERENCES type_document(id_type_document);
ALTER TABLE person ADD CONSTRAINT fk_person_file_id FOREIGN KEY (file_id) REFERENCES files(id_file);
ALTER TABLE users ADD CONSTRAINT fk_users_id_person FOREIGN KEY (id_person) REFERENCES person(id_person);
ALTER TABLE user_role ADD CONSTRAINT fk_user_role_users_id FOREIGN KEY (users_id) REFERENCES users(id_users);
ALTER TABLE user_role ADD CONSTRAINT fk_user_role_role_id FOREIGN KEY (role_id) REFERENCES roles(id_role);
ALTER TABLE module_view ADD CONSTRAINT fk_module_view_module_id FOREIGN KEY (module_id) REFERENCES modules(id_module);
ALTER TABLE module_view ADD CONSTRAINT fk_module_view_view_id FOREIGN KEY (view_id) REFERENCES app_view(id_view);
ALTER TABLE product ADD CONSTRAINT fk_product_supplier_id FOREIGN KEY (supplier_id) REFERENCES supplier(id_supplier);
ALTER TABLE product ADD CONSTRAINT fk_product_category_id FOREIGN KEY (category_id) REFERENCES category(id_category);
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_product_id FOREIGN KEY (product_id) REFERENCES product(id_product);
ALTER TABLE customer ADD CONSTRAINT fk_customer_person_id FOREIGN KEY (person_id) REFERENCES person(id_person);
ALTER TABLE app_order ADD CONSTRAINT fk_app_order_customer_id FOREIGN KEY (customer_id) REFERENCES customer(id_customer);
ALTER TABLE order_item ADD CONSTRAINT fk_order_item_orden_id FOREIGN KEY (orden_id) REFERENCES app_order(id_order);
ALTER TABLE order_item ADD CONSTRAINT fk_order_item_product_id FOREIGN KEY (product_id) REFERENCES product(id_product);
ALTER TABLE invoice ADD CONSTRAINT fk_invoice_order_id FOREIGN KEY (order_id) REFERENCES app_order(id_order);
ALTER TABLE invoice_item ADD CONSTRAINT fk_invoice_item_invoice_id FOREIGN KEY (invoice_id) REFERENCES invoice(id_invoice);
ALTER TABLE invoice_item ADD CONSTRAINT fk_invoice_item_product_id FOREIGN KEY (product_id) REFERENCES product(id_product);
ALTER TABLE payment ADD CONSTRAINT fk_payment_invoice_id FOREIGN KEY (invoice_id) REFERENCES invoice(id_invoice);
ALTER TABLE payment ADD CONSTRAINT fk_payment_method_payment_id FOREIGN KEY (method_payment_id) REFERENCES method_payment(id_method_payment);

-- =====================================================
-- Datos iniciales para modulos, vistas y auditoria
-- =====================================================
INSERT INTO modules (name_modules) VALUES
('Usuarios'),
('Roles'),
('Productos'),
('Inventario'),
('Pedidos'),
('Facturacion'),
('Pagos'),
('Auditoria');

INSERT INTO app_view (name_view, rout) VALUES
('Gestion de usuarios', '/usuarios'),
('Gestion de roles', '/roles'),
('Catalogo de productos', '/productos'),
('Control de inventario', '/inventario'),
('Gestion de pedidos', '/pedidos'),
('Facturas', '/facturas'),
('Pagos', '/pagos'),
('Auditoria', '/auditoria');

INSERT INTO module_view (module_id, view_id)
SELECT m.id_module, v.id_view
FROM modules m
JOIN app_view v ON
    (m.name_modules = 'Usuarios' AND v.name_view = 'Gestion de usuarios') OR
    (m.name_modules = 'Roles' AND v.name_view = 'Gestion de roles') OR
    (m.name_modules = 'Productos' AND v.name_view = 'Catalogo de productos') OR
    (m.name_modules = 'Inventario' AND v.name_view = 'Control de inventario') OR
    (m.name_modules = 'Pedidos' AND v.name_view = 'Gestion de pedidos') OR
    (m.name_modules = 'Facturacion' AND v.name_view = 'Facturas') OR
    (m.name_modules = 'Pagos' AND v.name_view = 'Pagos') OR
    (m.name_modules = 'Auditoria' AND v.name_view = 'Auditoria');
