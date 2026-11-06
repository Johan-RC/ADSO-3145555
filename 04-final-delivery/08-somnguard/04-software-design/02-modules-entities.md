<div style="display:flex; align-items:center; justify-content:space-between;">

<div>
<img src="../assets/icons/logo-somnguard.png" width="140"/>
</div>

<div align="right">

# SOMNGUARD

## Módulos y entidades

**Estado:** Estable
**Fecha:** 2026-08-19

</div>

</div>

> **Proyecto:** SomnGuard
> **Versión:** 1.0
> **Convención:** Todos los nombres de entidades y atributos se encuentran en inglés.

---

# Convenciones generales

## Identificador

Todas las entidades utilizan:

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| id | UUID | Identificador único (generado en app, UUID v7). |

---

## Auditoría

### Base (todas las tablas)
| Campo | Tipo |
| ----- | ---- |
| created_at | TIMESTAMPTZ NOT NULL |
| created_by | UUID NULL |

### Extendida (tablas con UPDATE real: user, device, device_config, notification, device_assignment, event_type)
| Campo | Tipo |
| ----- | ---- |
| updated_at | TIMESTAMPTZ NOT NULL |
| updated_by | UUID NULL |
| version | INTEGER NOT NULL DEFAULT 1 (optimistic locking) |

### Soft delete (tablas transaccionales principales)
| Campo | Tipo |
| ----- | ---- |
| deleted_at | TIMESTAMPTZ NULL |
| deleted_by | UUID NULL |

> **Nota:** `is_active` BOOLEAN es el campo de soft delete por defecto TRUE (ausente en `module`, `feature`, `status_*` y `device_config_history`). El control de eliminación lógica es `is_active = FALSE` (o `deleted_at IS NULL` para compatibilidad con vistas).

---

## Estados de negocio (ADR-009 — 5 core + `event_type`)

Las siguientes tablas usan `status` + `status_category` (FK a `parameterization.status` / `status_category`):
- `security.user`
- `device_management.device`
- `telemetry_service.event`
- `device_management.device_config`
- `monitoring.notification`
- `parameterization.event_type` (workflow de catálogo: `DRAFT/PUBLISHED/DEPRECATED`)

`device_assignment` no tiene estado. Catálogos inmutables y tablas append-only **no** llevan estados parametrizados.

---

# Modulos

# security

## Responsabilidad

Gestiona la autenticación, autorización y auditoría de usuarios.

---

## user

Representa a los usuarios del sistema.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| email | VARCHAR(255) |
| password_hash | TEXT |
| first_name | VARCHAR(100) |
| last_name | VARCHAR(100) |
| phone | VARCHAR(30) |
| is_active | BOOLEAN |
| email_verified_at | TIMESTAMPTZ |
| last_login_at | TIMESTAMPTZ |
| failed_login_attempts | SMALLINT |
| locked_until | TIMESTAMPTZ |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| deleted_at | TIMESTAMPTZ |
| deleted_by | UUID |
| version | INTEGER |
| status | VARCHAR(50) |
| status_category | VARCHAR(30) |

---

## role

Define los roles del sistema.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| code | VARCHAR(50) |
| name | VARCHAR(100) |
| description | TEXT |
| is_active | BOOLEAN |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |

---

## module

Agrupa funcionalidades del sistema.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| code | VARCHAR(50) |
| name | VARCHAR(100) |
| description | TEXT |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |

---

## feature

Representa una funcionalidad protegida del sistema.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| module_id | UUID |
| code | VARCHAR(50) |
| name | VARCHAR(100) |
| description | TEXT |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |

---

## role_feature

Relaciona roles con funcionalidades.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| role_id | UUID |
| feature_id | UUID |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| deleted_at | TIMESTAMPTZ |
| deleted_by | UUID |
| version | INTEGER |
| is_active | BOOLEAN |

---

## user_role

Asigna roles a los usuarios.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| user_id | UUID |
| role_id | UUID |
| assigned_at | TIMESTAMPTZ |
| expires_at | TIMESTAMPTZ |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| deleted_at | TIMESTAMPTZ |
| deleted_by | UUID |
| version | INTEGER |
| is_active | BOOLEAN |

---

## password_reset_request

Solicitudes de recuperación de contraseña.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| user_id | UUID |
| token_hash | TEXT |
| expires_at | TIMESTAMPTZ |
| is_used | BOOLEAN |
| used_at | TIMESTAMPTZ |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| is_active | BOOLEAN |

---

## audit_login

Registro de intentos de autenticación.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| user_id | UUID |
| email_attempted | VARCHAR(255) |
| outcome | VARCHAR(50) |
| ip_address | VARCHAR(45) |
| user_agent | TEXT |
| attempted_at | TIMESTAMPTZ |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| is_active | BOOLEAN |

---

# parameterization

## Responsabilidad

Gestiona los catálogos configurables del sistema.

---

## event_category

Clasificación de eventos.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| code | VARCHAR(30) |
| name | VARCHAR(100) |
| description | TEXT |
| sort_order | INTEGER |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| is_active | BOOLEAN |

---

## severity

Define los niveles de severidad.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| code | VARCHAR(20) |
| name | VARCHAR(50) |
| priority | SMALLINT |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| is_active | BOOLEAN |

---

## media_type

Tipos de evidencia multimedia.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| code | VARCHAR(20) |
| name | VARCHAR(50) |
| mime_type | VARCHAR(50) |
| max_size_mb | INTEGER |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| is_active | BOOLEAN |

---

## sound_pattern

Patrones de sonido utilizados por el dispositivo.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| code | VARCHAR(30) |
| description | TEXT |
| frequency_hz | INTEGER |
| duration_ms | INTEGER |
| repetitions | SMALLINT |
| pattern_type | VARCHAR(20) |
| interval_ms | INTEGER |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| is_active | BOOLEAN |

---

## event_type

Tipos de eventos detectados por el sistema.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| code | VARCHAR(30) |
| name | VARCHAR(100) |
| event_category_id | UUID |
| default_severity_id | UUID |
| default_sound_pattern_id | UUID |
| threshold_config | JSONB |
| is_active | BOOLEAN |
| status | VARCHAR(50) |
| status_category | VARCHAR(30) |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| deleted_at | TIMESTAMPTZ |
| deleted_by | UUID |
| version | INTEGER |

---

## global_config

Versión global de configuración (ADR-011, singleton, bump en API Java por cambios en `sound_pattern`/`event_type`).

| Campo | Tipo |
| ----- | ---- |
| id | SMALLINT (=1) |
| version | INTEGER |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |

---

## global_config_history

Historial append-only de versiones globales (snapshot completo por versión).

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| version | INTEGER UNIQUE |
| snapshot_json | JSONB |
| created_at | TIMESTAMPTZ |
| created_by | UUID |

---

# device-management

## Responsabilidad

Gestiona dispositivos, asignaciones y configuración global versionada (ADR-011 enmendada; `device_config*` = registro del pull).

---

## device

Representa un dispositivo físico.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| serial_number | VARCHAR(100) |
| api_key_hash | TEXT |
| firmware_version | VARCHAR(50) |
| is_active | BOOLEAN |
| last_heartbeat_at | TIMESTAMPTZ |
| last_sync_at | TIMESTAMPTZ |
| last_config_pull_at | TIMESTAMPTZ |
| applied_config_version | INTEGER |
| pending_config_update | BOOLEAN |
| last_seen_ip | VARCHAR(45) |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| deleted_at | TIMESTAMPTZ |
| deleted_by | UUID |
| version | INTEGER |
| status | VARCHAR(50) |
| status_category | VARCHAR(30) |
| claim_code | VARCHAR(20) UNIQUE |
| claimed_at | TIMESTAMPTZ |
| provisioning_token_id | UUID |

---

## device_assignment

Historial de asignación de dispositivos.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| device_id | UUID |
| user_id | UUID |
| assigned_at | TIMESTAMPTZ |
| unassigned_at | TIMESTAMPTZ |
| assigned_by | UUID |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| deleted_at | TIMESTAMPTZ |
| deleted_by | UUID |
| version | INTEGER |
| is_active | BOOLEAN |

---

## device_config

> Registro del pull (ADR-011 enmendada; ver `parameterization.global_config`).

Snapshot global aplicado por device (upsert en cada `GET /config` con API Key).

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| device_id | UUID |
| configuration | JSONB |
| is_active | BOOLEAN |
| version | INTEGER |
| published_at | TIMESTAMPTZ |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| deleted_at | TIMESTAMPTZ |
| deleted_by | UUID |
| status | VARCHAR(50) |
| status_category | VARCHAR(30) |

---

## device_config_history

> Historial de pulls (ADR-011 enmendada; ver `global_config_history`).

Historial de snapshots aplicados por device (INSERT por pull).

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| device_config_id | UUID |
| configuration | JSONB |
| changed_by | UUID |
| change_reason | VARCHAR(200) |
| created_at | TIMESTAMPTZ |
| created_by | UUID |

---

# telemetry-service

## Responsabilidad

Recibe y almacena la información generada por los dispositivos.

---

## event

Representa una ocurrencia detectada por el dispositivo.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| device_id | UUID |
| event_type_id | UUID |
| occurred_at | TIMESTAMPTZ |
| severity_id | UUID |
| sound_pattern_id | UUID |
| is_offline_sync | BOOLEAN |
| metadata | JSONB |
| is_active | BOOLEAN |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| deleted_at | TIMESTAMPTZ |
| deleted_by | UUID |
| version | INTEGER |
| status | VARCHAR(50) |
| status_category | VARCHAR(30) |

---

## evidence

Archivos asociados a un evento.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| event_id | UUID |
| media_type_id | UUID |
| minio_key | VARCHAR(500) |
| size_bytes | BIGINT |
| checksum_sha256 | VARCHAR(64) |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| is_active | BOOLEAN |

---

## alert_log

Registro histórico de las alarmas emitidas por el dispositivo.

Un evento puede no generar alarmas, generar una única alarma o múltiples alarmas conforme evoluciona la condición detectada.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| event_id | UUID |
| sound_pattern_id | UUID |
| severity_id | UUID |
| triggered_at | TIMESTAMPTZ |
| device_id | UUID |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| is_active | BOOLEAN |

---

# monitoring

## Responsabilidad

Gestiona el envío y seguimiento de notificaciones.

---

## notification

Notificaciones enviadas a los usuarios como consecuencia de una alarma.

| Campo | Tipo |
| ----- | ---- |
| id | UUID |
| user_id | UUID |
| alert_log_id | UUID |
| title | VARCHAR(200) |
| message | TEXT |
| channel | VARCHAR(30) |
| is_active | BOOLEAN |
| sent_at | TIMESTAMPTZ |
| delivered_at | TIMESTAMPTZ |
| read_at | TIMESTAMPTZ |
| retry_count | SMALLINT |
| error_message | TEXT |
| created_at | TIMESTAMPTZ |
| created_by | UUID |
| updated_at | TIMESTAMPTZ |
| updated_by | UUID |
| deleted_at | TIMESTAMPTZ |
| deleted_by | UUID |
| version | INTEGER |
| status | VARCHAR(50) |
| status_category | VARCHAR(30) |

---

# Relaciones

## security

- Un **MODULE** contiene múltiples **FEATURE**.
- Un **ROLE** posee múltiples **FEATURE** mediante **ROLE_FEATURE**.
- Un **USER** puede tener múltiples **ROLE** mediante **USER_ROLE**.
- Un **USER** puede generar múltiples **PASSWORD_RESET_REQUEST**.
- Un **USER** puede registrar múltiples **AUDIT_LOGIN**.

---

## parameterization

- Un **EVENT_CATEGORY** clasifica múltiples **EVENT_TYPE**.
- Un **EVENT_TYPE** define una **SEVERITY** por defecto.
- Un **EVENT_TYPE** define un **SOUND_PATTERN** por defecto.

---

## device-management

- Un **DEVICE** puede asignarse a múltiples usuarios mediante **DEVICE_ASSIGNMENT**.
- Un **DEVICE** puede tener una configuración almacenada en **DEVICE_CONFIG**.

---

## telemetry-service

- Un **DEVICE** genera múltiples **EVENT**.
- Un **EVENT** pertenece a un **EVENT_TYPE**.
- Un **EVENT** tiene como máximo una **EVIDENCE** en MVP (`UNIQUE(event_id)`).
- Una **EVIDENCE** pertenece a un **MEDIA_TYPE**.
- Un **EVENT** puede generar cero, una o múltiples **ALERT_LOG**.
- Un **ALERT_LOG** utiliza un **SOUND_PATTERN**.
- Un **ALERT_LOG** registra una **SEVERITY**.

---

## monitoring

- Un **USER** puede recibir múltiples **NOTIFICATION**.
- Un **ALERT_LOG** puede originar múltiples **NOTIFICATION**.
