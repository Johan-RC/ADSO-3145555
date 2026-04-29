# Diccionario de datos 3FN - SomnGuard

## Criterios generales
- Motor objetivo: PostgreSQL.
- Todas las tablas usan `UUID` como clave primaria.
- El auditoría sigue el mismo patrón en la mayoría de tablas: `created_at`, `updated_at`, `deleted_at`, `created_by`, `updated_by`, `deleted_by`.
- Las tablas puente usan restricciones `UNIQUE` para evitar duplicados funcionales.
- Los catálogos centralizan valores repetidos como estado, tipo de medio, severidad y categoría de evento.

## Tablas de catálogo

### status_catalog
Describe el estado lógico de los registros.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador del estado |
| code | varchar(50) | No | UK | Código funcional del estado |
| name | varchar(100) | No |  | Nombre legible |
| description | varchar(255) | Sí |  | Descripción adicional |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |

### media_type_catalog
Catálogo de tipos de evidencia multimedia.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador del tipo |
| code | varchar(50) | No | UK | Código del tipo de medio |
| name | varchar(100) | No |  | Nombre del tipo de medio |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |

### severity_catalog
Catálogo de severidad de eventos.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de severidad |
| code | varchar(50) | No | UK | Código funcional |
| name | varchar(100) | No |  | Nombre de severidad |
| rank | int | No | UK | Orden de criticidad |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |

### event_category_catalog
Catálogo de categorías de eventos.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de categoría |
| code | varchar(50) | No | UK | Código de categoría |
| name | varchar(100) | No |  | Nombre de categoría |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |

## Seguridad y acceso

### person
Persona física asociada al sistema.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de persona |
| first_name | varchar(100) | No |  | Nombre |
| last_name | varchar(100) | No |  | Apellido |
| phone | varchar(30) | Sí |  | Teléfono |
| status_id | UUID | No | FK | Estado de la persona |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### user
Cuenta de acceso del sistema.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de usuario |
| person_id | UUID | No | FK, UK | Persona asociada |
| email | varchar(255) | No | UK | Correo de acceso |
| password | varchar(255) | No |  | Contraseña cifrada o hash |
| status_id | UUID | No | FK | Estado del usuario |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### role
Rol de acceso.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador del rol |
| name | varchar(100) | No | UK | Nombre del rol |
| description | varchar(255) | Sí |  | Descripción |
| status_id | UUID | No | FK | Estado del rol |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### permission
Permiso funcional.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador del permiso |
| name | varchar(120) | No | UK | Nombre del permiso |
| status_id | UUID | No | FK | Estado del permiso |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### module
Módulo funcional del sistema.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador del módulo |
| name | varchar(120) | No | UK | Nombre del módulo |
| status_id | UUID | No | FK | Estado del módulo |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### form
Formulario o pantalla funcional.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador del formulario |
| name | varchar(120) | No | UK | Nombre del formulario |
| status_id | UUID | No | FK | Estado del formulario |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### form_module
Relación entre módulo y formulario.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de la relación |
| module_id | UUID | No | FK | Módulo asociado |
| form_id | UUID | No | FK | Formulario asociado |
| status_id | UUID | No | FK | Estado de la relación |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### role_user
Relación entre usuario y rol.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de la relación |
| user_id | UUID | No | FK | Usuario asociado |
| role_id | UUID | No | FK | Rol asociado |
| status_id | UUID | No | FK | Estado de la relación |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### role_form_permission
Permiso de un rol sobre un formulario.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de la relación |
| role_id | UUID | No | FK | Rol asociado |
| permission_id | UUID | No | FK | Permiso asociado |
| form_id | UUID | No | FK | Formulario asociado |
| status_id | UUID | No | FK | Estado de la relación |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

## Dispositivos

### device
Dispositivo IoT o hardware asociado al sistema.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador del dispositivo |
| serial_number | varchar(100) | No | UK | Número de serie |
| api_key_hash | varchar(255) | No |  | Hash de autenticación |
| firmware_version | varchar(50) | Sí |  | Versión de firmware |
| status_id | UUID | No | FK | Estado del dispositivo |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### device_assignment
Historial de asignación de dispositivo a usuario.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de la asignación |
| device_id | UUID | No | FK | Dispositivo asignado |
| user_id | UUID | No | FK | Usuario receptor |
| assigned_at | timestamptz | No |  | Fecha de asignación |
| unassigned_at | timestamptz | Sí |  | Fecha de desasignación |
| status_id | UUID | No | FK | Estado de la asignación |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### device_config
Configuración actual del dispositivo.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de la configuración |
| device_id | UUID | No | FK, UK | Dispositivo configurado |
| config_data | jsonb | No |  | Configuración serializada |
| status_id | UUID | No | FK | Estado de la configuración |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### sound_pattern
Patrón de sonido asociado a alertas o eventos.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador del patrón |
| code | varchar(50) | No | UK | Código del patrón |
| description | varchar(255) | Sí |  | Descripción |
| frequency_hz | int | No |  | Frecuencia en Hz |
| duration | int | No |  | Duración en segundos |
| status_id | UUID | No | FK | Estado del patrón |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

## Eventos y monitoreo

### event_type
Tipo de evento observado.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador del tipo de evento |
| code | varchar(50) | No | UK | Código del evento |
| name | varchar(120) | No |  | Nombre del evento |
| category_id | UUID | No | FK | Categoría del evento |
| default_severity_id | UUID | No | FK | Severidad por defecto |
| default_sound_pattern_id | UUID | Sí | FK | Patrón de sonido por defecto |
| status_id | UUID | No | FK | Estado del tipo de evento |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### event
Evento capturado por el sistema.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador del evento |
| device_id | UUID | No | FK | Dispositivo generador |
| event_type_id | UUID | No | FK | Tipo de evento |
| occurred_at | timestamptz | No |  | Fecha/hora de ocurrencia |
| is_offline_sync | boolean | No |  | Indica sincronización offline |
| status_id | UUID | No | FK | Estado del evento |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### alert
Alerta generada por un evento.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de la alerta |
| event_id | UUID | No | FK | Evento origen |
| sound_pattern_id | UUID | No | FK | Patrón reproducido |
| status_id | UUID | No | FK | Estado de la alerta |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### evidence
Evidencia adjunta a un evento.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de la evidencia |
| event_id | UUID | No | FK | Evento asociado |
| media_type_id | UUID | No | FK | Tipo de medio |
| file_url | varchar(500) | No |  | URL del archivo |
| status_id | UUID | No | FK | Estado de la evidencia |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

### notification
Notificación enviada a un usuario.

| Campo | Tipo | Nulo | Clave | Descripción |
|---|---|---:|---|---|
| id | UUID | No | PK | Identificador de la notificación |
| user_id | UUID | No | FK | Usuario destinatario |
| event_id | UUID | No | FK | Evento que la originó |
| title | varchar(150) | No |  | Título |
| message | varchar(500) | No |  | Mensaje |
| status_id | UUID | No | FK | Estado de la notificación |
| created_at | timestamptz | No |  | Fecha de creación |
| updated_at | timestamptz | Sí |  | Fecha de actualización |
| deleted_at | timestamptz | Sí |  | Fecha de eliminación lógica |
| created_by | UUID | Sí |  | Usuario que creó el registro |
| updated_by | UUID | Sí |  | Usuario que actualizó el registro |
| deleted_by | UUID | Sí |  | Usuario que eliminó el registro |

## Relaciones principales
- `person` 1:1 `user`
- `user` N:M `role` mediante `role_user`
- `module` N:M `form` mediante `form_module`
- `role` N:M `permission` sobre `form` mediante `role_form_permission`
- `device` 1:N `device_assignment`
- `device` 1:1 `device_config`
- `device` 1:N `event`
- `event_type` 1:N `event`
- `event` 1:N `alert`
- `event` 1:N `evidence`
- `event` 1:N `notification`
- `status_catalog` referencia a la mayoría de entidades transaccionales

## Observaciones
- `user.password` debe almacenarse como hash.
- `device.api_key_hash` debe almacenarse como hash.
- `device_config.config_data` se mantiene en `jsonb` para parámetros flexibles.
- Las tablas puente tienen clave sustituta y unicidad funcional para facilitar auditoría.
