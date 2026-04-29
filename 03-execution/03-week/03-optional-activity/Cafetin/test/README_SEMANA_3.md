# Semana 3 - Separación por dominios del CRUD básico

## Tema central
Separación por dominios funcionales del proyecto de cafetería.

## Dominios implementados

### security
Contiene la lógica relacionada con usuarios, personas y roles.

Incluye:
- Entidades: Person, User, Role, UserRole
- DTOs de request y response
- Repositorios
- Servicios
- Controladores REST

### bill
Contiene la lógica de los pedidos/facturas realizados por los usuarios.

Incluye:
- Entidad Bill
- DTOs BillRequestDto, BillStatusRequestDto y BillResponseDto
- Repositorio IBillRepository
- Servicio BillService
- Controlador BillController

Endpoints principales:
- POST /api/bills
- GET /api/bills
- GET /api/bills/{id}
- GET /api/bills/status/{status}
- GET /api/bills/user/{userId}
- PATCH /api/bills/{id}/status
- DELETE /api/bills/{id}

Ejemplo para crear un pedido:
```json
{
  "userId": 1,
  "status": "PENDIENTE",
  "total": 8500
}
```

Ejemplo para cambiar estado:
```json
{
  "status": "ENTREGADO"
}
```

### bill_detail
Contiene la lógica del detalle de cada pedido.

Incluye:
- Entidad BillDetail
- DTOs BillDetailRequestDto y BillDetailResponseDto
- Repositorio IBillDetailRepository
- Servicio BillDetailService
- Controlador BillDetailController

Endpoints principales:
- POST /api/bill-details
- GET /api/bill-details
- GET /api/bill-details/{id}
- GET /api/bill-details/bill/{billId}
- DELETE /api/bill-details/{id}

Ejemplo para agregar detalle a un pedido:
```json
{
  "billId": 1,
  "productName": "Empanada",
  "quantity": 2,
  "unitPrice": 2500
}
```

## Actividades desarrolladas
- Se tomó como base el CRUD básico de la semana 2.
- Se reorganizó el proyecto por dominios funcionales.
- Se separaron responsabilidades en los dominios security, bill y bill_detail.
- Se implementaron entidades, DTOs, repositorios, servicios y controladores para pedidos y detalle de pedidos.
- Se agregó cambio de estado para los pedidos.
- Se mantuvo la conexión a MySQL configurada en application.properties.

## Evidencias / entregables
- Proyecto organizado por dominios.
- CRUD básico con mejor estructura interna.
- Nuevos endpoints REST para pedidos y detalles.
- Código preparado para ejecutar con Swagger en:
  http://localhost:8085/swagger-ui/index.html
