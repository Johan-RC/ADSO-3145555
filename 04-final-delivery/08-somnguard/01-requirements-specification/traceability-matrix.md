<div style="display:flex; align-items:center; justify-content:space-between;">

<div>
<img src="../assets/icons/logo-somnguard.png" width="140"/>
</div>

<div align="right">

# SOMNGUARD

## Matriz de trazabilidad

**Estado:** En progreso
**Fecha:** 2026-08-23

</div>

</div>

Matriz completa que relaciona **Requisitos Funcionales (RF)** ↔ **Historias de Usuario (HU)** ↔ **Módulo Backend** ↔ **Reglas de Negocio (RN)** ↔ **NFR** ↔ **ADR** ↔ **Pruebas**. Fuente: `functional.md`, `user-stories.md`, `entities-and-rules.md`, `non-functional.md`, ADRs.

---

## Matriz Principal: RF → HU → Módulo → RN → NFR → ADR → Pruebas

| RF ID | Descripción | HU(s) Asociadas | Módulo Backend | RN Origen | NFR | ADR | Estrategia de Pruebas |
|-------|-------------|-----------------|----------------|-----------|-----|-----|----------------------|
| RF-SEC-01 | Registro cuenta (email/tel único, hash bcrypt) | HU-API-001, HU-PORTAL-001, HU-APP-001 | Security | RN-SEC-01, RN-SEC-02 | NFR-01 | ADR-001 | Unitarias: validador unicidad, hash bcrypt. Integración: POST /auth/register 201/409 |
| RF-SEC-02 | Login JWT RS256 + refresh token (15min/7d) | HU-API-001, HU-PORTAL-001, HU-APP-001 | Security | RN-SEC-03, RN-SEC-04 | NFR-01, NFR-04 | ADR-001 | Unitarias: generación/validación JWT, rotación refresh. Integración: login 200, token válido 15min |
| RF-SEC-03 | Logout con invalidación refresh token (blocklist) | HU-API-001, HU-PORTAL-001, HU-APP-001 | Security | RN-SEC-05 | NFR-01 | ADR-001 | Integración: logout 204, refresh posterior 401 |
| RF-SEC-04 | Recuperación contraseña via token temporal (1h) | HU-API-002, HU-PORTAL-001, HU-APP-001 | Security | RN-SEC-06 | NFR-01 | ADR-001 | Integración: forgot→reset flow, token expira 1h, un solo uso |
| RF-SEC-05 | Actualización datos personales (unicidad email/tel) | HU-API-002, HU-PORTAL-001, HU-APP-001 | Security | RN-SEC-07 | NFR-01 | — | Unitarias: validador PATCH /users/me. Integración: 200/409 |
| RF-DEV-06 | Asociación device ↔ user (1:1, device_assignment) - ver RF-DEV-02 detalle | HU-API-006 | Device Management | RN-DEV-01 | NFR-01 | — | Integración: assign/unassign, state machine |
| RF-DEV-07 | Desasociación device (libera para otro user) - ver RF-DEV-02 detalle | HU-API-006 | Device Management | RN-DEV-02 | NFR-01 | — | Integración: unassign → estado Registrado |
| RF-SEC-08 | Eliminación cuenta soft-delete (ventana 30d) | HU-API-002 | Security | RN-SEC-08 | NFR-01, NFR-06 | — | Integración: DELETE /users/me → deleted_at, recuperación 30d |
| RF-SEC-09 | Auditoría login (IP, user-agent, éxito/fallo, ts) | HU-API-001 | Security | RN-SEC-09 | NFR-04 | — | Unitarias: audit_login insert. Integración: login fallido/éxito registra |
| RF-SEC-10 | RBAC: roles, features, role_feature, middleware 403 | HU-API-003 | Security | RN-SEC-10 | NFR-01, NFR-04 | ADR-001 | Unitarias: middleware authz. Integración: 403 sin feature, 200 con feature |
| RF-PAR-01 | CRUD catálogos base (event_category, severity, media_type, sound_pattern, event_type) | HU-API-004 | Parameterization | RN-PAR-01 | — | — | CRUD por API: 201/200/204/404. Seed SRS verificado |
| RF-PAR-02 | Gestión sound_pattern (Hz, duración, repeticiones, patrón) | HU-API-004 | Parameterization | RN-PAR-02 | — | — | Unitarias: validador sound_pattern. Integración: CRUD completo |
| RF-PAR-03 | Gestión event_type con umbrales configurables | HU-API-004 | Parameterization | RN-PAR-03 | — | — | Unitarias: validador umbrales JSONB. Integración: CRUD + seed Apéndice 2 |
| RF-PAR-04 | ~~Umbrales por defecto + override por device_config (JSONB)~~ DEROGADA ADR-011 (solo global) | HU-API-005 | Parameterization | RN-PAR-04 | — | ADR-011 | — |
| RF-PAR-05 | Versionado catálogos + bump `global_config.version` + `global_config_history` | HU-API-004 | Parameterization | RN-PAR-05, RN-PAR-06 | — | ADR-011 | Unitarias: bump en misma tx; Integración: CRUD bumpea + history |
| RF-PAR-06 | Config global generada + `applied < global ⇒ desactualizado` (status), manual-only + refresh | HU-API-004, HU-API-005 | Parameterization | RN-PAR-06 | — | ADR-011 | Integración: heartbeat manual-only, GET versionado, status outdated |
| RF-DEV-01 | Alta device: serial, firmware, api_key_hash, estados | HU-API-006 | Device Management | RN-DEV-03 | NFR-01 | — | Integración: POST /devices (admin), unique serial/api_key |
| RF-DEV-02 | Asociación/desasociación device ↔ user | HU-API-006 | Device Management | RN-DEV-01, RN-DEV-02 | NFR-01 | — | Integración: assign/unassign, state machine 6 estados |
| RF-DEV-03 | Config global versionada (`GET` genera + `version` + persiste `device_config/history`; `PATCH 410`; `POST /refresh`) | HU-API-005 | Device Management | RN-DEV-04 | NFR-03 | ADR-011 | Integración: GET versionado + persiste, PATCH 410, refresh idempotente |
| RF-DEV-04 | Heartbeat device: last_seen, firmware, conectividad + `configPending` manual-only + `configVersionAvailable` | HU-API-006, HU-DEVICE-002 | Device Management | RN-DEV-05 | NFR-03 | ADR-011 | Integración: POST heartbeat, transición Activo↔Offline 5min, pending manual |
| RF-DEV-05 | State machine device (Registrado→Asignado→Activo↔Offline→Suspendido→Retirado) | HU-API-006, HU-DEVICE-002 | Device Management | RN-DEV-06 | NFR-03 | — | Integración: transiciones automáticas + admin manual |
| RF-DEV-08 | Consulta devices por user (filtros estado, fecha) | HU-API-006, HU-PORTAL-002 | Device Management | RN-DEV-07 | — | — | Integración: GET /devices con filtros + paginación |
| RF-DEV-09 | Rotacion API Key PATCH /rotate-key (solo admin, mitiga T-002) | HU-API-006 | Device Management | RN-DEV-03 | NFR-01 | ADR-001 | Integración: invalida anterior, devuelve nueva una vez, 401 con vieja |
| RF-DEV-10 | Tokens aprovisionamiento (un uso, 7d, hash, auditados) | HU-API-006, HU-DB-003 | Device Management | RN-DEV-08 | NFR-01 | ADR-010 | Integración: POST provisioning-tokens admin, 201 expone una vez |
| RF-DEV-11 | Auto-registro idempotente (token+serial, key una vez) | HU-API-006, HU-DB-003 | Device Management | RN-DEV-08 | NFR-01 | ADR-010 | Integración: reintento → 200 sin reexponer key |
| RF-DEV-12 | Reclamo con claim_code público reutilizable (solo REGISTERED, unassign libera) | HU-API-006, HU-PORTAL-006, HU-DB-003 | Device Management | RN-DEV-09 | NFR-01 | ADR-010 | Integración: POST /devices/claim → assignment |
| RF-TEL-01 | Ingesta eventos idempotente (device+API key, event_id único) | HU-API-007 | Telemetry Service | RN-TEL-01 | NFR-03, NFR-07 | — | Unitarias: validador idempotencia. Integración: duplicados en `duplicate_ids` del 201, ACK limpia buffer |
| RF-TEL-02 | Ingesta evidencia multimedia → MinIO bucket somnguard-evidence | HU-API-007 | Telemetry Service | RN-TEL-02 | NFR-02, NFR-06 | ADR-006 | Integración: upload MinIO, retorna evidence_id, verifica checksum SHA256 (64 hex) |
| RF-TEL-03 | Registro alert_log (código AS-XX, ts, event_id, severidad) | HU-API-007 | Telemetry Service | RN-TEL-03 | NFR-04 | — | Integración: alert_log creado tras ingesta evento crítico |
| RF-TEL-04 | Sync offline-first: buffer SQLite local, reintentos backoff, deduplicación | HU-DEVICE-003, HU-API-007 | Telemetry Service + Edge | RN-TEL-04 | NFR-03, NFR-07 | — | Integración: offline 1h → online sync → ACK → limpieza buffer |
| RF-TEL-05 | Pull manual config global versionada (`GET /config`, persiste `applied` + `device_config/history`) | HU-API-005, HU-DEVICE-002, HU-DEVICE-003 | Telemetry Service | RN-TEL-05 | NFR-03 | ADR-011 | Integración: heartbeat manual → GET → aplica versión + cache |
| RF-TEL-06 | Consulta eventos con filtros (device, tipo, severidad, fechas, paginación) | HU-API-008, HU-PORTAL-002 | Telemetry Service | RN-TEL-06 | NFR-03 | — | Integración: GET /api/v1/events con joins, índices device_id+occurred_at |
| RF-TEL-07 | Limpieza buffer local tras ACK sync (retención 7d fallidos) | HU-DEVICE-003 | Telemetry Service | RN-TEL-07 | NFR-02, NFR-06 | — | Integración: ACK 201 → borra confirmados, retención 7d fallidos |
| RF-MON-01 | Notificación push/email/webhook evento crítico (EV-SOM-05, EV-DIS-02, EV-DIS-04, EV-CIN-01/02) | HU-API-009, HU-APP-002 | Monitoring | RN-MON-01 | NFR-04 | — | Integración: trigger auto severity=crítica, canales push/email/in-app |
| RF-MON-02 | Plantillas notificación por event_type + severity | HU-API-009 | Monitoring | RN-MON-02 | — | — | Unitarias: template renderer. Integración: plantillas por tipo/severidad |
| RF-MON-03 | Tracking delivery: sent→delivered→read, reintentos backoff | HU-API-009, HU-APP-002 | Monitoring | RN-MON-03 | NFR-04 | — | Integración: estados notificación, reintentos max 3 exponenciales |
| RF-MON-04 | Preferencias notificación por user (canales, horarios, severidad mín) | HU-API-009, HU-APP-002 | Monitoring | RN-MON-04 | — | — | Unitarias: filtro preferencias. Integración: respeta silencio/severidad |
| RF-ANA-01 | Timeline cronológico eventos (filtros fecha, tipo, severidad, device) | HU-API-010, HU-PORTAL-003 | Analytics | RN-ANA-01 | NFR-03 | — | Integración: GET /api/v1/analytics/timeline <500ms p95 10k eventos |
| RF-ANA-02 | Métricas agregadas: freq por tipo, severidad media, tendencia temporal | HU-API-010, HU-PORTAL-003 | Analytics | RN-ANA-02 | NFR-03 | — | Integración: GET /api/v1/analytics/metrics, vistas materializadas |
| RF-ANA-03 | Resumen descriptivo IA (patrones, tendencia, conclusiones) | HU-API-011, HU-PORTAL-004, HU-APP-003 | Analytics | RN-ANA-03 | NFR-05 | ADR-003 | Integración: POST /api/v1/analytics/reports → LLM prompt → texto |
| RF-ANA-04 | Reporte consolidado PDF/HTML (timeline + métricas + IA + evidencia) | HU-API-011, HU-PORTAL-004, HU-APP-003 | Analytics | RN-ANA-04 | NFR-02, NFR-05 | ADR-003 | Integración: POST /api/v1/analytics/reports → PDF/HTML, cache 1h, MinIO |
| RF-ANA-05 | Video tiempo real WebRTC a demanda (Post-MVP) | HU-API-012, HU-DEVICE-005, HU-PORTAL-005, HU-APP-004 | Analytics + Edge | RN-ANA-05 | NFR-03, NFR-04 | — | **Post-MVP**: Integración WebRTC signaling, SFU, bitrate adaptativo |
| RF-EDGE-01 | Init hardware: verifica cámara, carga modelo, emite AS-08/AS-09 | HU-DEVICE-002 | Device Edge | RN-EDGE-01 | NFR-01, NFR-03 | — | Hardware: arranque <60s, cámara OK/ERROR |
| RF-EDGE-02 | Verificación campo visual cámara (obstrucción/mala posición) | HU-DEVICE-002 | Device Edge | RN-EDGE-02 | NFR-03 | — | Hardware: detecta obstrucción → AS-09, pausa detección |
| RF-EDGE-03 | Captura continua video rostro, landmarks → habilita análisis | HU-DEVICE-002 | Device Edge | RN-EDGE-03 | NFR-03, NFR-04 | — | Unitarias: frame reader FPS. Integración: landmarks detectados |
| RF-EDGE-04 | Detección somnolencia (PERCLOS, parpadeo, cierre ojos, bostezo, cabeceo) → AS-01..04 | HU-DEVICE-001 | Device Edge | RN-EDGE-04 | NFR-04 | — | Unitarias: detector con dataset etiquetado. Integración: <2s/frame |
| RF-EDGE-05 | Detección distracciones: teléfono (AS-05), mirada fuera (AS-06), movimientos (AS-05) | HU-DEVICE-001 | Device Edge | RN-EDGE-05 | NFR-04 | — | Unitarias: clasificador distracciones. Integración: precisión >90% |
| RF-EDGE-06 | Detección cinturón: presencia + posición → AS-07 intermitente si no | HU-DEVICE-001 | Device Edge | RN-EDGE-06 | NFR-04 | — | Unitarias: detector cinturón. Integración: AS-07 si no detectado |
| RF-EDGE-07 | Alerta sonora diferenciada por event_type + escalamiento persistencia | HU-DEVICE-004 | Device Edge | RN-EDGE-07 | NFR-04 | — | Integración: sound_pattern por AS-XX, escalamiento >10s, cola alertas |
| RF-EDGE-08 | Registro local eventos + alert_log + evidencia en buffer SQLite offline | HU-DEVICE-003 | Device Edge | RN-EDGE-08 | NFR-02, NFR-06 | — | Integración: buffer SQLite, pending_events, evidence_path, retries |
| RF-EDGE-09 | Gestión estado monitoreo: pausa sin rostro >30s (Espera), reanuda al detectar | HU-DEVICE-002 | Device Edge | RN-EDGE-09 | NFR-03 | — | Integración: Activo↔Espera por detección rostro |
| RF-EDGE-10 | Detección conectividad (ping/HEAD), sync auto online, reintentos exponenciales | HU-DEVICE-003 | Device Edge | RN-EDGE-10 | NFR-03, NFR-07 | — | Integración: ping 30s → online sync → backoff 1m/2m/4m/1h |
| RF-EDGE-11 | Aplicación config global versionada (umbrales, sound_pattern, volumen, sync) en caliente + cache + `applied` | HU-DEVICE-002, HU-DEVICE-004, HU-API-005 | Device Edge | RN-EDGE-11 | NFR-03 | ADR-011 | Integración: heartbeat manual → GET vN → aplica en caliente + cache |
| RF-EDGE-12 | Liberación almacenamiento: retención 7d + auto-limpieza tras ACK | HU-DEVICE-003 | Device Edge | RN-EDGE-12 | NFR-02, NFR-06 | — | Integración: storage <90% → AS-09, retención evidencia 7d |
| RF-EDGE-13 | Video streaming WebRTC a demanda (Post-MVP) | HU-DEVICE-005, HU-API-012 | Device Edge | RN-EDGE-13 | NFR-03, NFR-04 | — | **Post-MVP**: WebRTC H.264, bitrate adaptativo, auto-stop 30s |

---

## Matriz Épicas → HUs → Sprints (MVP)

| Épica | HUs (MVP) | Sprints | SP Total | Prioridad |
|-------|-----------|---------|----------|-----------|
| Setup y Foundation | HU-API-SETUP, HU-DB-001a, HU-DB-001b, HU-DB-003 | 0-1 | 26 | Must |
| Seguridad y cuentas | HU-API-001, 002, 003, HU-PORTAL-001, HU-APP-001 | 1 | 34 | Must |
| Gestión de dispositivos | HU-API-005, 006, HU-PORTAL-006 | 1-2, 6 | 21 | Must/Should |
| Parametrización | HU-API-004 | 1 | 8 | Must |
| Telemetría y sincronización | HU-API-007, 008, HU-DEVICE-001, 002, 003, 004 | 1-3 | 67 | Must |
| Monitoreo y notificaciones | HU-API-009, HU-APP-002 | 3 | 16 | Must |
| Analítica y reportes | HU-API-010, 011, HU-DB-002, HU-PORTAL-003, 004, HU-APP-003 | 3-5 | 44 | Must/Should |
| Device Edge | HU-DEVICE-001, 002, 003, 004 | 1-3 | 47 | Must |

> SP por épica no suma al total: Device Edge comparte HUs con Telemetría. Total único MVP: 224 SP (28 HUs: Must 195 + Should 29).

---

## Referencias Cruzadas

| Origen | Destino | Referencia |
|--------|---------|------------|
| HU (nueva) | RF / RN / NFR / ADR / TC | Plantilla [`./_template-hu.md`](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/04-requirements/_template-hu.md) |
| Épica | Funcionalidades / HUs | [`../03-product-definition/product-backlog.md`](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/03-product-definition/product-backlog.md) |
| NFR | Componentes / Pruebas | [`./non-functional.md`](./non-functional.md) |
| RF | RN / F-SRS / Épica / HU | [`./functional.md`](./functional.md) |
| RN | Entidades / Módulos | [`../02-domain/entities-and-rules.md`](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/02-domain/entities-and-rules.md) |
| ADR | Decisiones arquitectura | [`../05-architecture/decisions/records/`](https://github.com/SomnGuard/somnguard-docs/tree/main/docs/05-architecture/decisions/records) |
| Modelo datos | Entidades / Atributos / Relaciones | [`../06-data-architecture/02-modules-entities.md`](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/06-data-architecture/02-modules-entities.md) |
| API Design | Endpoints / Contratos | [`../07-api-design/api-design.md`](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/07-api-design/api-design.md) |
| Estrategia pruebas | Unitarias / Integración / E2E / Hardware | [`../11-quality-assurance/test-strategy.md`](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/11-quality-assurance/test-strategy.md) |
| Convenciones ágiles | Branching / Commits / Issues | [`../00-documentation-governance/agile-conventions.md`](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/00-documentation-governance/agile-conventions.md) |

---

## Próximos Pasos

1. **Validar matriz** con PO + Arquitecto + Tech Leads (revisión 1h).
2. **Crear issues en GitHub Projects** desde `user-stories.md` (IDs, títulos, ACs, SP, labels `repo:api|db|device|portal|app`, `moscow:must|should|could`, `sprint:N`).
3. **Mantener sincronizada** esta matriz al crear/modificar HUs, RFs, ADRs o NFRs.
4. **Aplicar `cross-cutting.md`** (reglas transversales: auth, audit, obs, idempotencia, tz, errores) y vincular aquí.


