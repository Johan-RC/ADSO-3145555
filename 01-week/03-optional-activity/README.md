# Carrito de compras para la cafeteria del SENA

--- 1. Planteamiento del problema ---

- El problema con la cafetería del SENA es su sistema de atención a los usuarios,
puesto que este está hecho de forma manual, lo cual causa filas largas y demora en el tiempo de descanso de dichos usuarios.

--- 2. Objetivo general ---

- Desarrollar un sistema de carrito de compras que permita gestionar los pedidos de la cafeteria del SENA de manera más organizada
y eficiente, reduciendo los tiempos de espera de los usuarios.

--- 3. Objetivos específicos ---

- Permitir a los usuarios visualizar los productos disponibles y realizar pedidos de forma rápida.

- Facilitar la gestión y organización de los pedidos para el personal del cafetín.

- Reducir los tiempos de atención y los errores en la toma de pedidos.

--- 4. Alcance ---

Incluye:

- Visualización de productos del cafetín.

- Selección de productos mediante un carrito de compras.

- Confirmación de pedidos por parte del usuario.

- Visualización de pedidos para el personal del cafetín.

- Cambio de estado del pedido.

No incluye:

- Pagos en línea.

- Facturación electrónica.

- Notificaciones avanzadas.

- Integración con sistemas externos.

--- 5. Requerimientos ---
5.1 Requerimientos funcionales (RF)

- RF-01 El sistema debe permitir visualizar los productos del cafetín.

- RF-02 El sistema debe permitir agregar productos al carrito de compras.

- RF-03 El sistema debe permitir confirmar un pedido.

- RF-04 El sistema debe permitir al personal del cafetín visualizar los pedidos realizados.

- RF-05 El sistema debe permitir cambiar el estado de un pedido.

5.2 Requerimientos no funcionales (RNF)

- RNF-01 Usabilidad:
El sistema debe ser fácil de usar y comprensible para cualquier usuario sin necesidad de capacitación previa.

- RNF-02 Rendimiento:
El sistema debe responder a las acciones del usuario en un tiempo adecuado para evitar demoras en la realización de pedidos.

- RNF-03 Disponibilidad:
El sistema debe estar disponible durante el horario de atención del cafetín.

- RNF-04 Accesibilidad:
El sistema debe poder ser utilizado desde dispositivos comunes como computadores o teléfonos móviles.

- RNF-05 Confiabilidad:
El sistema debe asegurar que la información de los pedidos se registre correctamente sin pérdidas de datos.

5.3 Reglas de negocio (RN)

- RN-01 Un pedido confirmado no puede ser modificado.

- RN-02 Un producto sin disponibilidad no puede ser seleccionado.

- RN-03 Todo pedido debe tener un estado asignado.

--- 6. Priorización MoSCoW ---

- Must → obligatorio: Visualizar productos, carrito de compras, confirmación de pedidos, visualización de pedidos.

- Should → importante: Cambio de estado del pedido.

- Could → opcional: Historial de pedidos.

- Won’t → no ahora: Pagos en línea.

--- 7. Mockup inicial ---

- El mockup del MVP incluye las siguientes pantallas:

- Pantalla de listado de productos.

- Pantalla del carrito de compras.

- Pantalla de confirmación del pedido.

- Pantalla de gestión de pedidos del cafetín.

- Link: https://www.figma.com/design/w9WucEDEtq7OuWtFawl2v3/figma-de-proyecto?node-id=0-1&t=oFDzBUwgEJIR557R-1

--- 8. Backlog / Plan de trabajo ---

/Historias de usuario

- Como usuario quiero visualizar los productos para seleccionar mi pedido.

- Como usuario quiero confirmar un pedido para reducir el tiempo de espera.

- Como personal del cafetín quiero visualizar los pedidos para organizarlos correctamente.

- Todas las historias tienen prioridad alta.

--- 9. Modelo de datos ---

/Entidades:

- Usuario
id_usuario (PK)
nombre
correo

- Producto
id_producto (PK)
nombre
precio
disponibilidad

- Pedido
id_pedido (PK)
fecha
estado
id_usuario (FK)

- DetallePedido
id_detalle (PK)
cantidad
id_pedido (FK)
id_producto (FK)

/Relaciones (PK / FK)

- Un usuario puede tener muchos pedidos
(Usuario 1 — N Pedido)

- Un pedido pertenece a un usuario
(Pedido → Usuario mediante id_usuario)

- Un pedido puede tener muchos productos
(Pedido N — N Producto)

La relación muchos a muchos se resuelve con DetallePedido, usando:

- id_pedido como FK

- id_producto como FK
