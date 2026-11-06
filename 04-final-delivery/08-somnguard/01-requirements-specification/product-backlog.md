<div style="display:flex; align-items:center; justify-content:space-between;">

<div>
<img src="../assets/icons/logo-somnguard.png" width="140"/>
</div>

<div align="right">

# SOMNGUARD

## Product backlog

**Estado:** En progreso
**Fecha:** 2026-08-19

</div>

</div>

Backlog de producto inicial, derivado de las funcionalidades del sistema (`F-01..F-10` del análisis de software), el catálogo de módulos y el plan de trabajo de la propuesta técnica. Las historias de usuario (HU) se gestionan en GitHub Projects con el formato `HU-<REPO>-NNN - Nombre/Descripción` (ver [convenciones ágiles](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/00-documentation-governance/agile-conventions.md)).

## Épicas (agrupaciones de trabajo)

| Épica | Módulo / componente | Funcionalidades |
|-------|---------------------|-----------------|
| Seguridad y cuentas | security | F-09 (gestión de cuentas, roles y permisos) |
| Gestión de dispositivos | device-management | F-07 (alta, asignación y configuración) |
| Telemetría y sincronización | telemetry-service + edge | F-01 (monitoreo), F-02 (detección), F-03 (alertas), F-04 (registro), F-05 (transmisión) |
| Monitoreo y notificaciones | monitoring | F-08 (notificaciones de eventos críticos) |
| Parametrización | parameterization | F-10 (administración de catálogos) |
| Analítica y reportes | analytics | F-06 (análisis de datos y reportes) |

> `Setup y Foundation` y `Device Edge` no son épicas de producto: son fases de trabajo en `user-stories.md`/`traceability-matrix.md`.

## Priorización MoSCoW (MVP)

| Prioridad | Épicas |
|-----------|--------|
| Must | Seguridad y cuentas, Gestión de dispositivos, Telemetría y sincronización, Monitoreo y notificaciones, Parametrización |
| Should | Analítica y reportes, Resumen IA (al final del MVP) |
| Could | Video en tiempo real (post-MVP) |
| Won't | Funcionalidades fuera del alcance definido |

<!-- PDF_PAGEBREAK -->

## Estado inicial por épica (corte del 2026-08-19)

Los estados de esta tabla corresponden al backlog inicial y no describen el avance actual de implementación. Para verificar el estado vigente, consultar las historias de usuario y el [backlog técnico](../07-improvement-actions/technical-backlog.md).

| Épica | Estado | Nota |
|-------|--------|------|
| Seguridad y cuentas | Pendiente en el corte inicial | La nota original sobre la capa de aplicación quedó obsoleta: la capa API ya está construida y TD-002 se marcó resuelto el 2026-11-05. El avance posterior debe verificarse contra las historias y los pendientes técnicos vigentes. |
| Gestión de dispositivos | Pendiente | Depende de Seguridad (roles) |
| Telemetría y sincronización | Pendiente | Depende de Gestión de dispositivos |
| Monitoreo y notificaciones | Pendiente | Depende de Telemetría (eventos) |
| Parametrización | Pendiente | Requisito de Telemetría (catálogos validan eventos) |
| Analítica y reportes | Pendiente | Depende de Telemetría y Monitoreo |

## Historias de usuario (ejemplos iniciales — canónicas en `user-stories.md`)

| HU | Título (GitHub Projects) | Repo |
|----|--------------------------|------|
| `HU-API-001` | Autenticar usuario en la plataforma | API |
| `HU-API-007` | Registrar evento de telemetría de forma idempotente | API |
| `HU-DB-001a` | Crear esquema de catálogos de parametrización | DB |
| `HU-DEVICE-003` | Sincronizar lote de eventos con respaldo offline | DEVICE |
| `HU-PORTAL-002` | Consultar línea de tiempo de eventos del conductor | PORTAL |
| `HU-APP-002` | Recibir notificación de evento crítico | APP |

## Ver también

- [Convenciones ágiles](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/00-documentation-governance/agile-conventions.md)
- [Matriz de trazabilidad](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/04-requirements/traceability-matrix.md)
- [Análisis del software](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/04-requirements/software-analysis.md)
- [Plan de trabajo](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/01-project-context/software-technical-proposal.md#7-plan-de-trabajo-y-cronograma)


