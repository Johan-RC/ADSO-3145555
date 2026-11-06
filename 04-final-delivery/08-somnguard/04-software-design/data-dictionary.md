<div style="display:flex; align-items:center; justify-content:space-between;">

<div>
<img src="../assets/icons/logo-somnguard.png" width="140"/>
</div>

<div align="right">

# SOMNGUARD

## Diccionario de Datos Unificado

**Estado:** Borrador
**Fecha:** 2026-08-22

</div>

</div>

> **Fuentes:** [02-modules-entities.md](./02-modules-entities.md) (MER + atributos),
> [entities-and-rules.md](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/02-domain/entities-and-rules.md) (RN-*),
> [ADR-004](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/decisions/records/ADR-004-database-strategy.md) (BD strategy + convenciones),
> [ADR-009](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/decisions/records/ADR-009-status-parametrized-audit.md) (estados + auditoría),
> [ADR-001](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/decisions/records/ADR-001-backend-java-spring-boot.md) (auth),
> [SRS](https://github.com/SomnGuard/somnguard-docs/tree/main/docs/04-requirements/01-srs) (RF-*, RNF-*).
>
> **Convenciones base (ADR-004):**
> - **Naming:** `snake_case` tablas/columnas
> - **PK:** UUID v7 (generado en app, no en BD)
> - **Auditoría base (todas las tablas):** `created_at` TIMESTAMPTZ NOT NULL, `created_by` UUID NULL
> - **Auditoría extendida (tablas con UPDATE real):** `updated_at`, `updated_by`, `version` INTEGER NOT NULL DEFAULT 1 (optimistic lock)
> - **Soft delete (tablas transaccionales):** `deleted_at` TIMESTAMPTZ NULL, `deleted_by` UUID NULL; NULL = activo; nunca `DELETE` físico
> - **Estados parametrizados (ADR-009 — solo 5 tablas core):** `status_category` + `status` (FK a `parameterization.status_category` / `status`)
> - **JSONB** para configuraciones flexibles
> - **FKs:** `ON DELETE RESTRICT` (por defecto)
> - **Índices** en columnas de filtro frecuente

---

## Resumen de Entidades por Módulo/Esquema

| Esquema (Módulo) | Entidades (Tablas) | Tipo |
|------------------|-------------------|------|
| `security` | `user`, `role`, `module`, `feature`, `role_feature`, `user_role`, `password_reset_request`, `audit_login`, `refresh_token`, `email_verification`, `user_status_audit` | Transaccional |
| `parameterization` | `event_category`, `severity`, `media_type`, `sound_pattern`, `event_type`, `global_config`, `global_config_history`, `status_category`, `status`, `status_transition` | Catálogo / Config |
| `device_management` | `device`, `device_assignment`, `device_config` (registro del pull, ADR-011 enmendada), `device_config_history` (registro del pull, ADR-011 enmendada), `device_status_audit`, `device_config_status_audit`, `device_provisioning_token`, `device_provisioning_audit` | Transaccional |
| `telemetry_service` | `event`, `evidence`, `alert_log`, `event_status_audit` | Transaccional (alta escritura) |
| `monitoring` | `notification`, `notification_status_audit` | Transaccional |
| `analytics` | *Sin tablas propias* — vistas materializadas (`v_event_timeline`, `v_metrics_daily`) | Analítico |

**Total: 33 tablas** (los `.mmd` de `01-entity-relationship-model` y `02-relational-model` cubren las 20 entidades de dominio: sin tablas `*_status_audit`, `refresh_token`, `email_verification` ni `device_provisioning_*`)

---

## Convenciones de Columna (Por tipo de tabla)

### Tabla A — Transaccionales con UPDATE concurrente (user, device, device_config, notification, device_assignment, event, event_type)
| Campo | Tipo | Null | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | UUID | NO | — | PK — generado en app (UUID v7) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | Auditoría: creación (UTC) |
| `created_by` | UUID | SÍ | — | User ID o Device ID que creó |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | Auditoría: última modificación (UTC) |
| `updated_by` | UUID | SÍ | — | User ID o Device ID que modificó |
| `deleted_at` | TIMESTAMPTZ | SÍ | NULL | **Soft delete** — NULL = activo |
| `deleted_by` | UUID | SÍ | — | User ID o Device ID que eliminó |
| `version` | INTEGER | NO | 1 | Optimistic locking (incrementa en cada UPDATE) |
| `is_active` | BOOLEAN | NO | TRUE | **Soft delete flag** — por defecto TRUE; FALSE = inactivo. **Este es el campo base de soft delete en todas las tablas.** |
| `status` | VARCHAR(50) | SÍ | NULL | **Estado de negocio** — solo en tablas donde aplica (ver Tabla C). FK `parameterization.status`. NULL = no tiene estado parametrizado. |
| `status_category` | VARCHAR(30) | SÍ | NULL | **Categoría de estado** — solo en tablas donde aplica. FK `parameterization.status_category`. NULL = no tiene categoría. |

### Tabla B — Transaccionales solo INSERT / append-only (evidence, alert_log, audit_login, password_reset_request, device_config_history)
| Campo | Tipo | Null | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | UUID | NO | — | PK — generado en app (UUID v7) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | Auditoría: creación (UTC) |
| `created_by` | UUID | SÍ | — | User ID o Device ID que creó |

### Tabla C — Catálogos inmutables (role, module, feature, event_category, severity, media_type, sound_pattern, status_category, status, status_transition)

> `event_type` no es inmutable: tiene workflow (`DRAFT/PUBLISHED/DEPRECATED`) y auditoría completa, ver Tabla A.
| Campo | Tipo | Null | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` / `code` | UUID / VARCHAR | NO | — | PK |
| `created_at` | TIMESTAMPTZ | NO | `now()` | Auditoría: creación (UTC) |
| `created_by` | UUID | SÍ | — | User ID que creó (seed = SYSTEM_ACTOR_ID) |
| `is_active` | BOOLEAN | NO | TRUE | **Activo/Inactivo** — por defecto TRUE. Soft delete = `is_active = FALSE`. **Este es el campo base de soft delete en catálogos.** |
| `updated_at` | TIMESTAMPTZ | SÍ | — | Auditoría: última modificación (UTC) |
| `updated_by` | UUID | SÍ | — | User ID modificador |

> **Excepción:** `parameterization.event_type` tiene columnas adicionales: `status` VARCHAR(50) y `status_category` VARCHAR(30) con FK a `parameterization.status`/`status_category` (decisión ADR-009). Los demás catálogos usan solo `is_active` para estado.

> **Regla:** `SYSTEM_ACTOR_ID = 00000000-0000-0000-0000-000000000000` para seeds y acciones automáticas.

---

## Esquema: `security` (Módulo Security)

### `security.user` — Usuarios del sistema (Portal, App, Admin)

| Columna | Tipo | Null | Default | FK | Índice | Descripción | RN |
|---------|------|------|---------|----|--------|-------------|-----|
| `id` | UUID | NO | — | PK | PK | Identificador único | |
| `email` | VARCHAR(255) | NO | — | — | **UNIQUE** | Correo único (login) | RN-01 |
| `password_hash` | TEXT | NO | — | — | — | Hash bcrypt (costo 12) | RN-01 |
| `first_name` | VARCHAR(100) | NO | — | — | — | Nombre | |
| `last_name` | VARCHAR(100) | NO | — | — | — | Apellido | |
| `phone` | VARCHAR(30) | SÍ | — | — | **UNIQUE** | Teléfono único (opcional) | RN-01 |
| `is_active` | BOOLEAN | NO | TRUE | — | — | **Soft delete** — por defecto TRUE. FALSE = inactivo. | |
| `email_verified_at` | TIMESTAMPTZ | SÍ | — | — | — | Timestamp verificación correo | |
| `last_login_at` | TIMESTAMPTZ | SÍ | — | — | — | Último login exitoso | |
| `failed_login_attempts` | SMALLINT | NO | 0 | — | — | Contador fallos consecutivos | |
| `locked_until` | TIMESTAMPTZ | SÍ | — | — | — | Bloqueo temporal tras 5 fallos | |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación | |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (NULL = auto-registro) | |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación | |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador | |
| `deleted_at` | TIMESTAMPTZ | SÍ | NULL | — | — | Soft delete | |
| `deleted_by` | UUID | SÍ | — | `security.user(id)` | — | User ID que eliminó | |
| `version` | INTEGER | NO | 1 | — | — | Optimistic locking | |
| `status` | VARCHAR(50) | SÍ | NULL | `parameterization.status(code)` | IDX | Estado de negocio (ADR-009) | |
| `status_category` | VARCHAR(30) | SÍ | NULL | `parameterization.status_category(code)` | — | Categoría de estado (ADR-009) | |

**Índices compuestos:** `idx_user_status_active (status) WHERE deleted_at IS NULL`

**Reglas:** RN-01 (unicidad email/phone, hash pwd), RN-02 (roles/permisos via `user_role` + `role_feature`)

---

### `security.role` — Roles del sistema

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `code` | VARCHAR(50) | NO | — | — | **UNIQUE** | Código técnico: `admin`, `user` |
| `name` | VARCHAR(100) | NO | — | — | — | Nombre legible |
| `description` | TEXT | SÍ | — | — | — | Descripción |
| `is_active` | BOOLEAN | NO | TRUE | — | — | **Soft delete** — por defecto TRUE |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (seed = SYSTEM_ACTOR_ID) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |

**Seed:** `admin` (todas features), `user` (features propias)

---

### `security.module` — Módulos funcionales (agrupadores de features)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `code` | VARCHAR(50) | NO | — | — | **UNIQUE** | Código: `security`, `device_management`, `telemetry`, `monitoring`, `analytics`, `parameterization` |
| `name` | VARCHAR(100) | NO | — | — | — | Nombre legible |
| `description` | TEXT | SÍ | — | — | — | Descripción |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (seed = SYSTEM_ACTOR_ID) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |

---

### `security.feature` — Funcionalidades protegidas (permisos atómicos)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `module_id` | UUID | NO | — | `security.module(id)` | IDX | Módulo al que pertenece |
| `code` | VARCHAR(50) | NO | — | — | **UNIQUE (module_id, code)** | Código: `device.read`, `event.write`, `analytics.report`, etc. Nuevas (ADR-010, seeds pendientes): `device.provision` (crear tokens), `device.claim` (reclamar con claim) |
| `name` | VARCHAR(100) | NO | — | — | — | Nombre legible |
| `description` | TEXT | SÍ | — | — | — | Descripción |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (seed = SYSTEM_ACTOR_ID) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |

---

### `security.role_feature` — Asignación Role ↔ Feature (N:M)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `role_id` | UUID | NO | — | `security.role(id)` | **UNIQUE (role_id, feature_id)** | Role |
| `feature_id` | UUID | NO | — | `security.feature(id)` | IDX | Feature |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (seed = SYSTEM_ACTOR_ID) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |
| `deleted_at` | TIMESTAMPTZ | SÍ | NULL | — | — | Soft delete |
| `deleted_by` | UUID | SÍ | — | `security.user(id)` | — | User ID que eliminó |
| `version` | INTEGER | NO | 1 | — | — | Optimistic locking |
| `is_active` | BOOLEAN | NO | TRUE | — | — | Activo/Inactivo — por defecto TRUE |

---

### `security.user_role` — Asignación User ↔ Role (N:M) con vigencia

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `user_id` | UUID | NO | — | `security.user(id)` | **UNIQUE (user_id, role_id) WHERE deleted_at IS NULL** | Usuario |
| `role_id` | UUID | NO | — | `security.role(id)` | IDX | Role |
| `assigned_at` | TIMESTAMPTZ | NO | `now()` | — | — | Cuándo se asignó |
| `expires_at` | TIMESTAMPTZ | SÍ | — | — | — | Expiración opcional (NULL = indefinido) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |
| `deleted_at` | TIMESTAMPTZ | SÍ | NULL | — | — | Soft delete = revocación |
| `deleted_by` | UUID | SÍ | — | `security.user(id)` | — | User ID que revocó |
| `version` | INTEGER | NO | 1 | — | — | Optimistic locking |
| `is_active` | BOOLEAN | NO | TRUE | — | — | Activo/Inactivo — por defecto TRUE |

> **Regla:** Un user solo tiene UNA asignación activa por role (`deleted_at IS NULL`)

---

### `security.password_reset_request` — Solicitudes de recuperación de contraseña

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `user_id` | UUID | NO | — | `security.user(id)` | IDX | Usuario solicitante |
| `token_hash` | TEXT | NO | — | — | — | Hash del token (SHA-256) |
| `expires_at` | TIMESTAMPTZ | NO | `now() + 1 hour` | — | — | Expiración (1h) |
| `is_used` | BOOLEAN | NO | FALSE | — | — | Si ya se consumió |
| `used_at` | TIMESTAMPTZ | SÍ | — | — | — | Cuándo se usó |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (system) |
| `is_active` | BOOLEAN | NO | TRUE | — | — | **Soft delete** — por defecto TRUE |

---

### `security.audit_login` — Auditoría de intentos de autenticación (Append-only)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `user_id` | UUID | SÍ | — | `security.user(id)` | IDX | Usuario (NULL si email no existe) |
| `email_attempted` | VARCHAR(255) | NO | — | — | IDX | Email usado en intento |
| `outcome` | VARCHAR(50) | NO | — | — | — | `SUCCESS`, `INVALID_CREDENTIALS`, `ACCOUNT_LOCKED`, `ACCOUNT_SUSPENDED`, `EMAIL_NOT_VERIFIED` |
| `ip_address` | VARCHAR(45) | NO | — | — | — | IPv4 o IPv6 |
| `user_agent` | TEXT | SÍ | — | — | — | User-Agent del cliente |
| `attempted_at` | TIMESTAMPTZ | NO | `now()` | — | **IDX (attempted_at DESC)** | Timestamp intento |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | = attempted_at |
| `created_by` | UUID | SÍ | — | — | — | = user_id (NULL si email no existe) |
| `is_active` | BOOLEAN | NO | TRUE | — | — | **Soft delete** — por defecto TRUE |

> **Retención:** 2 años (política de limpieza job mensual)

---

## Esquema: `parameterization` (Módulo Parameterization)

### `parameterization.event_category` — Categorías de eventos (alto nivel)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `code` | VARCHAR(30) | NO | — | — | **UNIQUE** | Código: `SOMNOLENCE`, `DISTRACTION`, `SEATBELT`, `SYSTEM` |
| `name` | VARCHAR(100) | NO | — | — | — | Nombre legible |
| `description` | TEXT | SÍ | — | — | — | Descripción |
| `sort_order` | INTEGER | NO | 0 | — | — | Orden visual |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (seed = SYSTEM_ACTOR_ID) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |

| `is_active` | BOOLEAN | NO | TRUE | - | - | **Soft delete** - por defecto TRUE |
---

### `parameterization.severity` — Niveles de severidad

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `code` | VARCHAR(20) | NO | — | — | **UNIQUE** | Código: `info`, `warning`, `high`, `critical` |
| `name` | VARCHAR(50) | NO | — | — | — | Nombre legible |
| `priority` | SMALLINT | NO | 0 | — | — | Prioridad numérica (1=info..4=critical) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (seed = SYSTEM_ACTOR_ID) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |
| `is_active` | BOOLEAN | NO | TRUE | - | - | **Soft delete** - por defecto TRUE |

---

### `parameterization.media_type` — Tipos de evidencia multimedia

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `code` | VARCHAR(20) | NO | — | — | **UNIQUE** | Código: `image_jpeg`, `video_mp4` |
| `name` | VARCHAR(50) | NO | — | — | — | Nombre legible |
| `mime_type` | VARCHAR(50) | NO | — | — | — | MIME type: `image/jpeg`, `video/mp4` |
| `max_size_mb` | INTEGER | NO | 10 | — | — | Tamaño máximo permitido |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (seed = SYSTEM_ACTOR_ID) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |
| `is_active` | BOOLEAN | NO | TRUE | - | - | **Soft delete** - por defecto TRUE |

---

### `parameterization.sound_pattern` — Patrones de sonido (AS-XX)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `code` | VARCHAR(30) | NO | — | — | **UNIQUE** | Código: `AS-01`..`AS-09` |
| `description` | TEXT | NO | — | — | — | Descripción legible |
| `frequency_hz` | INTEGER | NO | — | — | — | Frecuencia en Hz |
| `duration_ms` | INTEGER | NO | — | — | — | Duración por pitido (ms) |
| `repetitions` | SMALLINT | NO | 1 | — | — | Repeticiones (0 = continuo/hasta respuesta) |
| `pattern_type` | VARCHAR(20) | NO | `beep` | — | — | `beep`, `continuous`, `intermittent`, `escalating` |
| `interval_ms` | INTEGER | SÍ | — | — | — | Intervalo entre repeticiones (ms) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | NO | — | `security.user(id)` | — | User ID creador (seed = SYSTEM_ACTOR_ID) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | NO | — | `security.user(id)` | — | User ID modificador |
| `is_active` | BOOLEAN | NO | TRUE | - | - | **Soft delete** - por defecto TRUE |

**Seed (Apéndice 1 SRS):**
| code | description | frequency_hz | duration_ms | repetitions | pattern_type | interval_ms |
|------|-------------|--------------|-------------|-------------|--------------|-------------|
| AS-01 | Somnolencia leve | 800 | 500 | 1 | beep | — |
| AS-02 | Somnolencia moderada | 950 | 400 | 2 | beep | 200 |
| AS-03 | Somnolencia severa | 1100 | 300 | 3 | beep | 200 |
| AS-04 | Estado crítico | 1200 | 2000 | 0 | continuous | — |
| AS-05 | Distracción teléfono | 900 | 700 | 2 | beep | 300 |
| AS-06 | Mirada fuera vía | 950 | 500 | 2 | beep | 200 |
| AS-07 | Cinturón no detectado | 700 | 1000 | 0 | intermittent | 1000 |
| AS-08 | Confirmación inicio | 600 | 300 | 1 | beep | — |
| AS-09 | Error sistema | 1000 | 500 | 2 | escalating | 200 |

---

### `parameterization.event_type` — Tipos de eventos detectados (configurables)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `code` | VARCHAR(30) | NO | — | — | **UNIQUE** | Código: `EV-SOM-01`..`EV-SYS-06` |
| `name` | VARCHAR(100) | NO | — | — | — | Nombre legible |
| `event_category_id` | UUID | NO | — | `parameterization.event_category(id)` | IDX | Categoría |
| `default_severity_id` | UUID | NO | — | `parameterization.severity(id)` | — | Severidad por defecto |
| `default_sound_pattern_id` | UUID | NO | — | `parameterization.sound_pattern(id)` | — | Sonido por defecto |
| `threshold_config` | JSONB | NO | `{}` | — | — | Umbrales configurables (ej: `{"blink_rate_max": 25, "eye_closed_min_sec": 2}`) |
| `is_active` | BOOLEAN | NO | TRUE | — | — | Si está vigente |
| `status` | VARCHAR(50) | NO | `DRAFT` | `parameterization.status(code)` | IDX | Estado: DRAFT, PUBLISHED, DEPRECATED |
| `status_category` | VARCHAR(30) | NO | `PENDING` | `parameterization.status_category(code)` | — | Categoría |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |
| `deleted_at` | TIMESTAMPTZ | SÍ | NULL | — | — | Soft delete |
| `deleted_by` | UUID | SÍ | — | `security.user(id)` | — | User ID que eliminó |
| `version` | INTEGER | NO | 1 | — | — | Optimistic locking |

**Seed (Apéndice 2 SRS):**
| code | name | event_category | default_severity | default_sound | threshold_config (ejemplo) |
|------|------|----------------|------------------|---------------|---------------------------|
| EV-SOM-01 | Parpadeo anómalo | SOMNOLENCE | info | AS-01 | `{"blink_rate_max": 25, "blink_rate_min": 5, "window_sec": 15}` |
| EV-SOM-02 | Cierre prolongado ojos | SOMNOLENCE | warning | AS-02 | `{"eye_closed_min_sec": 2}` |
| EV-SOM-03 | Bostezo detectado | SOMNOLENCE | warning | AS-02 | `{"yawn_count_min": 2, "window_min": 5}` |
| EV-SOM-04 | Cabeceo/inclinación | SOMNOLENCE | high | AS-03 | `{"head_tilt_deg_min": 20, "duration_sec_min": 3}` |
| EV-SOM-05 | Microsueño detectado | SOMNOLENCE | critical | AS-04 | `{"eye_closed_min_sec": 3, "head_tilt_deg_min": 20, "simultaneous": true}` |
| EV-DIS-01 | Uso teléfono móvil | DISTRACTION | info | AS-05 | `{"detection_confidence_min": 0.7, "duration_sec_min": 2}` |
| EV-DIS-02 | Uso prolongado teléfono | DISTRACTION | high | AS-05 | `{"duration_sec_min": 5}` |
| EV-DIS-03 | Mirada fuera de la vía | DISTRACTION | info | AS-06 | `{"duration_sec_min": 3}` |
| EV-DIS-04 | Mirada prolongada fuera | DISTRACTION | high | AS-06 | `{"duration_sec_min": 5}` |
| EV-DIS-05 | Movimiento anómalo | DISTRACTION | info | AS-05 | `{"duration_sec_min": 3}` |
| EV-CIN-01 | Cinturón no detectado | SEATBELT | info | AS-07 | `{"no_detection_sec_min": 10}` |
| EV-CIN-02 | Cinturón mal colocado | SEATBELT | info | AS-07 | `{"incorrect_position_sec_min": 10}` |
| EV-SYS-01 | Inicialización exitosa | SYSTEM | info | AS-08 | `{}` |
| EV-SYS-02 | Error cámara/obstrucción | SYSTEM | warning | AS-09 | `{"invalid_image_sec_min": 10}` |
| EV-SYS-03 | Rostro no detectado | SYSTEM | info | AS-09 | `{"no_face_sec_min": 30}` |
| EV-SYS-04 | Conectividad perdida | SYSTEM | info | AS-09 | `{}` |
| EV-SYS-05 | Conectividad restaurada | SYSTEM | info | AS-08 | `{}` |
| EV-SYS-06 | Almacenamiento casi lleno | SYSTEM | warning | AS-09 | `{"usage_pct_min": 90}` |

---

### `parameterization.global_config` — Versión global de configuración (ADR-011, singleton)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | SMALLINT | NO | 1 | PK | PK | Singleton (`CHECK id=1`) |
| `version` | INTEGER | NO | 1 | — | — | Contador monotónico; `++` por cada `POST/PATCH/DELETE` efectivo en `sound_pattern`/`event_type` (API Java, misma transacción, `SELECT FOR UPDATE`) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Último bump |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | Admin que provocó el bump |

**Regla:** `device.applied_config_version < global_config.version ⇒ desactualizado`. Seed: `(1, 1, now(), NULL)`.

---

### `parameterization.global_config_history` — Historial de versiones globales (Append-only)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `version` | INTEGER | NO | — | — | **UNIQUE** | Versión global de ese snapshot |
| `snapshot_json` | JSONB | NO | — | — | — | Config efectiva completa (`{version, thresholds, event_sound_map, detection_thresholds, sound_patterns, volume_pct, volume_scale, schema_version, sync/heartbeat, retention}`) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | **IDX (created_at DESC)** | Timestamp del bump |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | Admin que provocó el bump |
| *append-only* | — | — | — | — | — | Solo INSERT |

---

### `parameterization.status_category` — Categorías de estado (ADR-009)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `code` | VARCHAR(30) | NO | — | PK | PK | `ACTIVE`, `INACTIVE`, `PENDING`, `ERROR`, `ARCHIVED` |
| `name` | VARCHAR(100) | NO | — | — | — | Nombre legible |
| `description` | TEXT | SÍ | — | — | — | Descripción |
| `sort_order` | INTEGER | NO | 0 | — | — | Orden |
| `is_final` | BOOLEAN | NO | FALSE | — | — | Si es estado terminal (no hay salidas) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (seed = SYSTEM_ACTOR_ID) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |

---

### `parameterization.status` — Estados específicos por entidad (ADR-009)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `code` | VARCHAR(50) | NO | — | PK | PK | Código estado: `ACTIVE`, `OFFLINE`, `SYNCHRONIZED`, etc. |
| `status_category` | VARCHAR(30) | NO | — | `parameterization.status_category(code)` | IDX | Categoría padre |
| `name` | VARCHAR(100) | NO | — | — | — | Nombre legible |
| `description` | TEXT | SÍ | — | — | — | Descripción |
| `entity_type` | VARCHAR(50) | NO | — | — | **IDX (entity_type, code)** | `device`, `event`, `user`, `device_config`, `notification` |
| `sort_order` | INTEGER | NO | 0 | — | — | Orden dentro de categoría |
| `is_initial` | BOOLEAN | NO | FALSE | — | — | Estado inicial al crear entidad |
| `is_terminal` | BOOLEAN | NO | FALSE | — | — | Estado terminal (sin salidas) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (seed = SYSTEM_ACTOR_ID) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |

**Seed clave (códigos prefijados por entidad; `event_type` usa bare en sus propias filas por legado de seeds — unificar pendiente):**
| entity_type | code | status_category | is_initial | is_terminal |
|-------------|------|-----------------|------------|-------------|
| device | DEVICE_REGISTERED | PENDING | TRUE | FALSE |
| device | DEVICE_ASSIGNED | PENDING | FALSE | FALSE |
| device | DEVICE_ACTIVE | ACTIVE | FALSE | FALSE |
| device | DEVICE_OFFLINE | INACTIVE | FALSE | FALSE |
| device | DEVICE_SUSPENDED | INACTIVE | FALSE | FALSE |
| device | DEVICE_RETIRED | ARCHIVED | FALSE | TRUE |
| event | EVENT_DETECTED | PENDING | TRUE | FALSE |
| event | EVENT_REGISTERED | PENDING | FALSE | FALSE |
| event | EVENT_SYNCHRONIZED | ACTIVE | FALSE | FALSE |
| event | EVENT_ANALYZED | ACTIVE | FALSE | FALSE |
| event | EVENT_ARCHIVED | ARCHIVED | FALSE | TRUE |
| user | USER_PENDING_VERIFICATION | PENDING | TRUE | FALSE |
| user | USER_ACTIVE | ACTIVE | FALSE | FALSE |
| user | USER_SUSPENDED | INACTIVE | FALSE | FALSE |
| user | USER_SOFT_DELETED | ARCHIVED | FALSE | TRUE |
| device_config | DEVICE_CONFIG_DRAFT | PENDING | TRUE | FALSE |
| device_config | DEVICE_CONFIG_PUBLISHED | ACTIVE | FALSE | FALSE |
| device_config | DEVICE_CONFIG_DEPRECATED | INACTIVE | FALSE | FALSE |
| notification | NOTIFICATION_PENDING | PENDING | TRUE | FALSE |
| notification | NOTIFICATION_SENT | ACTIVE | FALSE | FALSE |
| notification | NOTIFICATION_DELIVERED | ACTIVE | FALSE | FALSE |
| notification | NOTIFICATION_READ | ACTIVE | FALSE | FALSE |
| notification | NOTIFICATION_FAILED | ERROR | FALSE | TRUE |

---

### `parameterization.status_transition` — Transiciones permitidas (ADR-009)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `from_status` | VARCHAR(50) | NO | — | `parameterization.status(code)` | PK | Estado origen |
| `to_status` | VARCHAR(50) | NO | — | `parameterization.status(code)` | PK | Estado destino |
| `allowed_roles` | VARCHAR(100)[] | SÍ | NULL | — | — | Roles permitidos (NULL = system/any) |
| `description` | TEXT | SÍ | — | — | — | Descripción transición |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Timestamp creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (seed = SYSTEM_ACTOR_ID) |
| *append-only* | — | — | — | — | — | Solo INSERT |

**Ejemplos seed (códigos prefijados por entidad):**
| from_status | to_status | allowed_roles | description |
|-------------|-----------|---------------|-------------|
| DEVICE_REGISTERED | DEVICE_ASSIGNED | `{user}` | Usuario asocia device |
| DEVICE_ASSIGNED | DEVICE_ACTIVE | `{system}` | Primer heartbeat |
| DEVICE_ACTIVE | DEVICE_OFFLINE | `{system}` | Sin heartbeat > 5 min |
| DEVICE_OFFLINE | DEVICE_ACTIVE | `{system}` | Heartbeat recibido |
| DEVICE_ACTIVE | DEVICE_SUSPENDED | `{admin}` | Admin suspende |
| DEVICE_SUSPENDED | DEVICE_ACTIVE | `{admin}` | Admin reactiva |
| EVENT_DETECTED | EVENT_REGISTERED | `{system}` | Persistido en buffer local |
| EVENT_REGISTERED | EVENT_SYNCHRONIZED | `{system}` | ACK recibido de API |

> Transiciones de desasociación (`*_ACTIVE`/`*_ASSIGNED` → `*_REGISTERED` vía `unassign`) documentadas en `es-device.mmd` y `HU-API-006 AC-003, todavía sin filas en seeds.

---

## Esquema: `device_management` (Módulo Device Management)

### `device_management.device` — Dispositivos físicos

| Columna | Tipo | Null | Default | FK | Índice | Descripción | RN |
|---------|------|------|---------|----|--------|-------------|-----|
| `id` | UUID | NO | — | PK | PK | Identificador | |
| `serial_number` | VARCHAR(100) | NO | — | — | **UNIQUE** | Número de serie único (lo informa el hardware en self-register, no manual) | RN-03 |
| `api_key_hash` | TEXT | NO | — | — | — | HMAC-SHA256 de API Key | RN-03 |
| `firmware_version` | VARCHAR(50) | SÍ | — | — | — | Versión firmware instalada (la informa el software en self-register, nullable hasta primer heartbeat) | |
| `is_active` | BOOLEAN | NO | TRUE | — | — | **Soft delete** — por defecto TRUE. FALSE = inactivo. | |
| `last_heartbeat_at` | TIMESTAMPTZ | SÍ | — | — | IDX | Último heartbeat recibido | |
| `last_sync_at` | TIMESTAMPTZ | SÍ | — | — | — | Última sincronización exitosa | |
| `last_config_pull_at` | TIMESTAMPTZ | SÍ | — | — | — | Última descarga config (solo pull del device, no lectura portal) | |
| `applied_config_version` | INTEGER | NO | 0 | — | — | Última versión global aplicada (`global_config.version` del último `GET` con API Key; `0`=nunca; `applied < global ⇒ desactualizado`, ADR-011) | |
| `pending_config_update` | BOOLEAN | NO | FALSE | — | — | Flag manual: `true` por `POST /refresh` (gesto usuario; `PATCH` legacy derogado); el heartbeat expone solo `pending` (manual-only) y el `GET` del device lo limpia; `applied<global` se expone vía `GET /config/status{outdated}` | |
| `last_seen_ip` | VARCHAR(45) | SÍ | — | — | — | IP origen último request | |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación | |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (admin que registra) | |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación | |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador | |
| `deleted_at` | TIMESTAMPTZ | SÍ | NULL | — | — | Soft delete | |
| `deleted_by` | UUID | SÍ | — | `security.user(id)` | — | User ID que eliminó | |
| `version` | INTEGER | NO | 1 | — | — | Optimistic locking | |
| `status` | VARCHAR(50) | SÍ | NULL | `parameterization.status(code)` | IDX | Estado de negocio | |
| `status_category` | VARCHAR(30) | SÍ | NULL | `parameterization.status_category(code)` | — | Categoría de estado | |
| `claim_code` | VARCHAR(20) | NO | — | — | **UNIQUE** | Código de reclamo público, permanente por device; solo sirve en REGISTERED (unassign lo libera y re-sirve) | |
| `claimed_at` | TIMESTAMPTZ | SÍ | — | — | — | Cuándo se reclamó (NULL = disponible para reclamar) | |
| `provisioning_token_id` | UUID | SÍ | — | `device_management.device_provisioning_token(id)` | IDX | Token que originó el registro (NULL = alta manual) | |

**Índices:** `idx_device_status_active (status) WHERE deleted_at IS NULL`, `idx_device_heartbeat (last_heartbeat_at)`

**Reglas:** RN-03 (device pertenece a cuenta asignada, API key válida para eventos), RN-10 (config se descarga y aplica)

---

### `device_management.device_assignment` — Historial de asignación Device ↔ User

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `device_id` | UUID | NO | — | `device_management.device(id)` | **UNIQUE (device_id) WHERE unassigned_at IS NULL** | Device |
| `user_id` | UUID | NO | — | `security.user(id)` | **UNIQUE (user_id) WHERE unassigned_at IS NULL** | Usuario (1 usuario ↔ 1 device vigente, RN-DEV-01) |
| `assigned_at` | TIMESTAMPTZ | NO | `now()` | — | — | Cuándo se asignó |
| `unassigned_at` | TIMESTAMPTZ | SÍ | — | — | — | Cuándo se desasignó (NULL = actual) |
| `assigned_by` | UUID | NO | — | `security.user(id)` | — | Quién asignó (admin o user) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |
| `deleted_at` | TIMESTAMPTZ | SÍ | NULL | — | — | Soft delete = desasignación |
| `deleted_by` | UUID | SÍ | — | `security.user(id)` | — | User ID que desasignó |
| `version` | INTEGER | NO | 1 | — | — | Optimistic locking |
| `is_active` | BOOLEAN | NO | TRUE | — | — | **Soft delete** — por defecto TRUE |

> **Regla:** Un device solo tiene UNA asignación activa (`unassigned_at IS NULL` AND `deleted_at IS NULL`)

---

### `device_management.device_config` — Registro del pull (ADR-011 enmendada)

> Cada `GET /devices/{id}/config` con API Key hace upsert (snapshot global aplicado). La config es 100% global (`parameterization.global_config`); `PATCH /devices/{id}/config` responde `410`.

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `device_id` | UUID | NO | — | `device_management.device(id)` | **UNIQUE** | Device (1 config aplicada por device) |
| `configuration` | JSONB | NO | `'{}'` | — | — | Snapshot global aplicado en el último pull (lo que el device cachea y aplica) |
| `is_active` | BOOLEAN | NO | TRUE | — | — | **Soft delete** — por defecto TRUE. FALSE = inactivo. |
| `version` | INTEGER | NO | 1 | — | — | Optimistic locking legacy |
| `published_at` | TIMESTAMPTZ | SÍ | — | — | — | Cuándo se publicó |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User ID creador (admin) |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador |
| `deleted_at` | TIMESTAMPTZ | SÍ | NULL | — | — | Soft delete |
| `deleted_by` | UUID | SÍ | — | `security.user(id)` | — | User ID que eliminó |
| `status` | VARCHAR(50) | SÍ | NULL | `parameterization.status(code)` | IDX | Estado de negocio |
| `status_category` | VARCHAR(30) | SÍ | NULL | `parameterization.status_category(code)` | — | Categoría de estado |

**Ejemplo global vigente (`GET /devices/{id}/config`, ADR-011):**
```json
{
  "version": 16,
  "thresholds": {"EV-SOM-01": {"eye_closed_min_sec": 2}},
  "event_sound_map": {"EV-SOM-01": "AS-02"},
  "detection_thresholds": {},
  "sound_patterns": {"AS-02": {"frequency_hz": 880, "duration_sec": 0.5}},
  "volume_pct": 80,
  "volume_scale": 0.8,
  "schema_version": 1,
  "sync_interval_sec": 30,
  "heartbeat_interval_sec": 30,
  "retention_days": 7
}
```
> Nota: el firmware ignora `thresholds`/`event_sound_map` y fusiona `detection_thresholds` (vacío no borra base).

---

### `device_management.device_config_history` — Historial de pulls (ADR-011 enmendada, append-only)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `device_config_id` | UUID | NO | — | `device_management.device_config(id)` | IDX | Config padre |
| `configuration` | JSONB | NO | — | — | — | Snapshot global aplicado en ese pull (ver `global_config_history` para el versionado global) |
| `changed_by` | UUID | NO | — | `security.user(id)` | — | Actor del pull (`device.created_by`, o `SYSTEM_ID` si NULL por self-register) |
| `change_reason` | VARCHAR(200) | SÍ | — | — | — | Motivo (`Pull manual tras refresh (heartbeat pending)`) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | **IDX (created_at DESC)** | Timestamp |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | = changed_by |
| *append-only* | — | — | — | — | — | Solo INSERT |

---

### `device_management.device_provisioning_token` — Tokens de aprovisionamiento (un uso)

| Columna | Tipo | Null | Default | FK | Índice | Descripción | RN |
|---------|------|------|---------|----|--------|-------------|-----|
| `id` | UUID | NO | — | PK | PK | Identificador del token | |
| `token_hash` | TEXT | NO | — | — | **UNIQUE** | SHA-256 del token (nunca plano) | |
| `serial_number` | VARCHAR(100) | SÍ | NULL | — | IDX | Serial pre-asociado (NULL = abierto al primer registro válido) | |
| `max_uses` | SMALLINT | NO | 1 | — | — | Usos permitidos (normalmente 1) | |
| `uses_count` | SMALLINT | NO | 0 | — | — | Usos consumidos | |
| `expires_at` | TIMESTAMPTZ | NO | `now() + 7 days` | — | — | Expiración | |
| `revoked_at` | TIMESTAMPTZ | SÍ | NULL | — | — | Revocación (NULL = vigente) | |
| `device_id` | UUID | SÍ | NULL | `device_management.device(id)` | — | Device creado con este token | |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación | |
| `created_by` | UUID | NO | — | `security.user(id)` | — | Admin que lo generó | |

### `device_management.device_provisioning_audit` — Auditoría de aprovisionamiento (Append-only)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador |
| `token_id` | UUID | NO | — | `device_management.device_provisioning_token(id)` | IDX | Token involucrado |
| `action` | VARCHAR(30) | NO | — | — | — | `CREATED`, `USED`, `REVOKED`, `CLAIMED` |
| `device_id` | UUID | SÍ | NULL | `device_management.device(id)` | — | Device asociado (si aplica) |
| `actor_id` | UUID | SÍ | NULL | `security.user(id)` | — | Admin actor (NULL = el propio device) |
| `ip_address` | VARCHAR(45) | SÍ | NULL | — | — | IP origen |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | **IDX (created_at DESC)** | Timestamp |
| *append-only* | — | — | — | — | — | Solo INSERT |

---

## Esquema: `telemetry_service` (Módulo Telemetry Service)

### `telemetry_service.event` — Eventos detectados (alta escritura)

| Columna | Tipo | Null | Default | FK | Índice | Descripción | RN |
|---------|------|------|---------|----|--------|-------------|-----|
| `id` | UUID | NO | — | PK | PK | **event_id** — generado en device (UUID v7) | RN-08 |
| `device_id` | UUID | NO | — | `device_management.device(id)` | **IDX (device_id, occurred_at DESC)** | Device origen | RN-03 |
| `event_type_id` | UUID | NO | — | `parameterization.event_type(id)` | IDX | Tipo de evento | RN-04 |
| `occurred_at` | TIMESTAMPTZ | NO | — | — | **IDX (occurred_at DESC)** | Timestamp evento (UTC, device) | |
| `severity_id` | UUID | NO | — | `parameterization.severity(id)` | IDX | Severidad (puede diferir de default) | |
| `sound_pattern_id` | UUID | SÍ | — | `parameterization.sound_pattern(id)` | — | Sonido reproducido | |
| `is_offline_sync` | BOOLEAN | NO | FALSE | — | — | TRUE si generado offline | RN-08 |
| `metadata` | JSONB | NO | `'{}'` | — | — | Datos extra (confianza, coordenadas, etc.) | |
| `is_active` | BOOLEAN | NO | TRUE | — | — | **Soft delete** — por defecto TRUE. FALSE = inactivo. | RN-08 |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación | |
| `created_by` | UUID | NO | — | `device_management.device(id)` | — | Device ID que generó | |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación | |
| `updated_by` | UUID | SÍ | — | — | — | User/Device ID modificador | |
| `deleted_at` | TIMESTAMPTZ | SÍ | NULL | — | — | Soft delete | |
| `deleted_by` | UUID | SÍ | — | — | — | User/Device ID que eliminó | |
| `version` | INTEGER | NO | 1 | — | — | Optimistic locking | |
| `status` | VARCHAR(50) | SÍ | NULL | `parameterization.status(code)` | IDX | Estado de negocio | |
| `status_category` | VARCHAR(30) | SÍ | NULL | `parameterization.status_category(code)` | — | Categoría de estado | |

**Índices compuestos críticos:**
- `idx_event_device_time (device_id, occurred_at DESC)` — timeline por device
- `idx_event_type_severity (event_type_id, severity_id)` — filtros dashboard

**Reglas:** RN-04 (clasificación via catálogos), RN-05 (alert_log asociado), RN-06 (evidencia + retención), RN-08 (idempotencia via `id` UUID v7)

---

### `telemetry_service.evidence` — Evidencia multimedia (frames, video)

| Columna | Tipo | Null | Default | FK | Índice | Descripción |
|---------|------|------|---------|----|--------|-------------|
| `id` | UUID | NO | — | PK | PK | Identificador evidencia |
| `event_id` | UUID | NO | — | `telemetry_service.event(id)` | **UNIQUE** | Evento asociado (1 evidencia por evento en MVP). Mapeo lote: `POST /telemetry/events JSON` fase 1 -> `POST /telemetry/events/{id}/evidence multipart` fase 2. Key `{device_id}/{YYYY}/{MM}/{DD}/{event_id}.jpg` |
| `media_type_id` | UUID | NO | — | `parameterization.media_type(id)` | — | Tipo: image_jpeg, video_mp4 |
| `minio_key` | VARCHAR(500) | NO | — | — | — | Key en MinIO: `{device_id}/{YYYY}/{MM}/{DD}/{event_id}.jpg` (ver ADR-006) |
| `size_bytes` | BIGINT | NO | — | — | — | Tamaño archivo |
| `checksum_sha256` | VARCHAR(64) | NO | — | — | — | SHA-256 del archivo (integridad) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Timestamp subida |
| `created_by` | UUID | NO | — | `device_management.device(id)` | — | Device que subió |
| `is_active` | BOOLEAN | NO | TRUE | — | — | **Soft delete** — por defecto TRUE |

> **Retención:** 90 días (eventos normales) / 5 años (severity=critical) — ADR-006 ILM

---

### `telemetry_service.alert_log` — Registro histórico de alarmas (Append-only)

| Columna | Tipo | Null | Default | FK | Índice | Descripción | RN |
|---------|------|------|---------|----|--------|-------------|-----|
| `id` | UUID | NO | — | PK | PK | Identificador | |
| `event_id` | UUID | NO | — | `telemetry_service.event(id)` | IDX | Evento origen | RN-05 |
| `sound_pattern_id` | UUID | NO | — | `parameterization.sound_pattern(id)` | — | Patrón reproducido (AS-XX) | RN-05 |
| `severity_id` | UUID | NO | — | `parameterization.severity(id)` | IDX | Severidad registrada | |
| `triggered_at` | TIMESTAMPTZ | NO | — | — | **IDX (triggered_at DESC)** | Timestamp alarma | |
| `device_id` | UUID | NO | — | `device_management.device(id)` | IDX | Device (denormalizado para queries) | |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | = triggered_at | |
| `created_by` | UUID | NO | — | `device_management.device(id)` | — | = device_id | |
| `is_active` | BOOLEAN | NO | TRUE | — | — | **Soft delete** — por defecto TRUE | |

> **Retención:** 5 años — RN-05, ADR-006

---

## Esquema: `monitoring` (Módulo Monitoring)

### `monitoring.notification` — Notificaciones a usuarios (push, email, in-app)

| Columna | Tipo | Null | Default | FK | Índice | Descripción | RN |
|---------|------|------|---------|----|--------|-------------|-----|
| `id` | UUID | NO | — | PK | PK | Identificador | |
| `user_id` | UUID | NO | — | `security.user(id)` | **IDX (user_id, sent_at DESC)** | Usuario destinatario | RN-07 |
| `alert_log_id` | UUID | NO | — | `telemetry_service.alert_log(id)` | IDX | Alarma origen | RN-07 |
| `title` | VARCHAR(200) | NO | — | — | — | Título notificación | |
| `message` | TEXT | NO | — | — | — | Cuerpo mensaje | |
| `channel` | VARCHAR(30) | NO | — | — | — | `push`, `email`, `in_app` | |
| `is_active` | BOOLEAN | NO | TRUE | — | — | **Soft delete** — por defecto TRUE. FALSE = inactivo. | |
| `sent_at` | TIMESTAMPTZ | SÍ | — | — | — | Cuándo se envió | |
| `delivered_at` | TIMESTAMPTZ | SÍ | — | — | — | Cuándo se entregó (push) | |
| `read_at` | TIMESTAMPTZ | SÍ | — | — | — | Cuándo se leyó (in_app) | |
| `retry_count` | SMALLINT | NO | 0 | — | — | Reintentos | |
| `error_message` | TEXT | SÍ | — | — | — | Error si FAILED | |
| `created_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: creación | |
| `created_by` | UUID | SÍ | — | `security.user(id)` | — | User/Device ID creador (system) | |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | — | — | Auditoría: última modificación | |
| `updated_by` | UUID | SÍ | — | `security.user(id)` | — | User ID modificador | |
| `deleted_at` | TIMESTAMPTZ | SÍ | NULL | — | — | Soft delete | |
| `deleted_by` | UUID | SÍ | — | `security.user(id)` | — | User ID que eliminó | |
| `version` | INTEGER | NO | 1 | — | — | Optimistic locking | |
| `status` | VARCHAR(50) | SÍ | NULL | `parameterization.status(code)` | IDX | Estado de negocio | |
| `status_category` | VARCHAR(30) | SÍ | NULL | `parameterization.status_category(code)` | — | Categoría de estado | |

**Reglas:** RN-07 (notificaciones críticas auto, propietario device), plantillas por event_type+severity

---

## Esquema: `analytics` (Módulo Analytics)

> **Sin tablas transaccionales propias.** Solo **vistas materializadas** y **proyecciones** optimizadas para consultas.

### `analytics.v_event_timeline` — Vista: Timeline de eventos (denormalizada)

```sql
CREATE MATERIALIZED VIEW analytics.v_event_timeline AS
SELECT
  e.id AS event_id,
  e.device_id,
  d.serial_number,
  e.event_type_id,
  et.code AS event_type_code,
  et.name AS event_type_name,
  ec.code AS event_category_code,
  e.severity_id,
  s.code AS severity_code,
  s.priority AS severity_priority,
  e.occurred_at,
  e.is_offline_sync,
  e.status,
  e.status_category,
  ev.minio_key AS evidence_key,
  ev.media_type_id,
  mt.code AS media_type_code
FROM telemetry_service.event e
JOIN device_management.device d ON d.id = e.device_id
JOIN parameterization.event_type et ON et.id = e.event_type_id
JOIN parameterization.event_category ec ON ec.id = et.event_category_id
JOIN parameterization.severity s ON s.id = e.severity_id
LEFT JOIN telemetry_service.evidence ev ON ev.event_id = e.id
LEFT JOIN parameterization.media_type mt ON mt.id = ev.media_type_id
WHERE e.deleted_at IS NULL AND d.deleted_at IS NULL;
```
**Refresh:** Trigger on `event` insert/update + pg_cron cada 5 min
**Índices:** `CREATE INDEX ON analytics.v_event_timeline (device_id, occurred_at DESC)`

---

### `analytics.v_metrics_daily` — Vista: Métricas diarias pre-agregadas

```sql
CREATE MATERIALIZED VIEW analytics.v_metrics_daily AS
SELECT
  DATE_TRUNC('day', e.occurred_at AT TIME ZONE 'America/Bogota') AS metric_date,
  e.device_id,
  da.user_id,
  e.event_type_id,
  et.event_category_id,
  e.severity_id,
  COUNT(*) AS event_count,
  COUNT(*) FILTER (WHERE e.severity_id = (SELECT id FROM parameterization.severity WHERE code='critical')) AS critical_count,
  COUNT(*) FILTER (WHERE e.severity_id = (SELECT id FROM parameterization.severity WHERE code='high')) AS high_count,
  MIN(e.occurred_at) AS first_event_at,
  MAX(e.occurred_at) AS last_event_at
FROM telemetry_service.event e
JOIN device_management.device d ON d.id = e.device_id
JOIN device_management.device_assignment da ON da.device_id = d.id AND da.unassigned_at IS NULL AND da.deleted_at IS NULL
JOIN parameterization.event_type et ON et.id = e.event_type_id
WHERE e.deleted_at IS NULL AND d.deleted_at IS NULL
GROUP BY 1,2,3,4,5,6;
```
**Refresh:** pg_cron cada hora (agregación incremental)

---

## Tablas de Auditoría de Estado (ADR-009 - Triggers automáticos)

Para cada entidad con `status` + `status_category`, se crea tabla `_status_audit`:

| Tabla Auditoría | Entidad Origen | Esquema |
|-----------------|----------------|---------|
| `device_status_audit` | `device_management.device` | `device_management` |
| `event_status_audit` | `telemetry_service.event` | `telemetry_service` |
| `user_status_audit` | `security.user` | `security` |
| `device_config_status_audit` | `device_management.device_config` | `device_management` |
| `notification_status_audit` | `monitoring.notification` | `monitoring` |

**Estructura común:**
```sql
CREATE TABLE {schema}.{entity}_status_audit (
    id              BIGSERIAL PRIMARY KEY,
    {entity}_id     UUID NOT NULL REFERENCES {schema}.{entity}(id),
    from_status     VARCHAR(50),
    to_status       VARCHAR(50) NOT NULL,
    from_category   VARCHAR(30),
    to_category     VARCHAR(30) NOT NULL,
    changed_by      UUID,  -- user_id o device_id (NULL = system)
    changed_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    context_json    JSONB  -- metadata extra
);
CREATE INDEX ON {schema}.{entity}_status_audit ({entity}_id, changed_at DESC);
```

---

## Resumen de Convenciones por Tipo de Tabla

| Tipo de Tabla | Ejemplos | Auditoria | Soft Delete | Version | Estados |
|---------------|----------|-----------|-------------|---------|---------|
| **Catálogo inmutable** | `role`, `module`, `feature`, `event_category`, `severity`, `media_type`, `sound_pattern`, `status_category`, `status`, `status_transition` | `created_at`, `created_by` (+`updated_at`/`is_active` donde existen: `role`, `event_category`, `severity`, `media_type`, `sound_pattern`, `event_type`) | NO | NO | NO |
| **Configuración versionada** | `global_config`, `global_config_history`, `event_type`, `device_config` + `device_config_history` (registro del pull, ADR-011 enmendada) | Completa | SÍ (`global_config` singleton sin soft delete) | SÍ (`global_config.version` monotónica) | `status_category` + `status` (solo `event_type`) |
| **Transaccional principal** | `user`, `device` (`applied_config_version`, `pending_config_update`), `device_assignment`, `event`, `notification` | Completa | SÍ | SÍ | `status_category` + `status` donde aplica (sin estado: `device_assignment`) |
| **Append-only (eventos)** | `audit_login`, `alert_log`, `password_reset_request`, `evidence`, `global_config_history`, `device_config_history` | `created_at`/`created_by` | NO (físico) | NO | NO |
| **Histórico de estado** | `*_status_audit` | Append-only | NO | NO | N/A |

---

## Referencias Cruzadas Rápidas

| Necesitas | Documento |
|-----------|-----------|
| Reglas de negocio (RN-*) | [entities-and-rules.md](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/02-domain/entities-and-rules.md) |
| Estrategia BD (esquemas, Liquibase) | [ADR-004](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/decisions/records/ADR-004-database-strategy.md) |
| Estados parametrizados + auditoría | [ADR-009](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/decisions/records/ADR-009-status-parametrized-audit.md) |
| Auth (JWT, API Keys) | [ADR-001](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/decisions/records/ADR-001-backend-java-spring-boot.md) |
| Offline-first device | [ADR-005](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/decisions/records/ADR-005-offline-first-device.md) |
| MinIO evidence storage | [ADR-006](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/decisions/records/ADR-006-minio-evidence-storage.md) |
| Convenciones modelado Liquibase | [modeling-conventions.md](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/06-data-architecture/modeling-conventions.md) |
| Estrategia migraciones | [migration-strategy.md](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/06-data-architecture/migration-strategy.md) |
| Catálogo módulos | [module-catalog.md](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/09-modules/module-catalog.md) |

---

## Próximos Pasos

1. **Validar** diccionario con DBA + Backend Lead (revisión 30 min)
2. **Generar changelogs Liquibase** iniciales por módulo (basados en este diccionario)
3. **Crear `modeling-conventions.md`** con reglas formales (naming, FKs, índices, JSONB, triggers)
4. **Crear `migration-strategy.md`** (orden ejecución, rollback, seed data, CI integration)
5. **Actualizar `../09-modules/modules/_template/module/data-model.md`** para cada módulo use este diccionario como fuente






