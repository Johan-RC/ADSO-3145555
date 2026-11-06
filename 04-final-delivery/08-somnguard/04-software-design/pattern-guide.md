<div style="display:flex; align-items:center; justify-content:space-between;">

<div>
<img src="../assets/icons/logo-somnguard.png" width="140"/>
</div>

<div align="right">

# SOMNGUARD

## Guía de patrones

**Estado:** En progreso
**Fecha:** 2026-08-19

</div>

</div>

Guía de patrones del backend SomnGuard: patrón base **monolito modular hexagonal** (ADR-002), capas, reglas de dependencia, mapeo de entidades y anti-patrones prohibidos.

## Patrón seleccionado

| Campo | Valor |
|-------|-------|
| Patrón | Monolito modular hexagonal |
| Justificación | Un solo deployable con módulos independientes; puertos y adaptadores aíslan el dominio de la infraestructura (ADR-002) |
| ADR de decisión | ADR-002 |

## Capas del patrón

| Capa | Responsabilidad | Puede depender de | No puede depender de |
|------|-----------------|-------------------|----------------------|
| `domain` | Entidades, lógica de negocio pura | Ninguna | `adapter/*` |
| `application` | Casos de uso, orquestación | `domain` | `adapter/*` |
| `adapter/in` | Controllers web, AMQP, entrada de eventos | `application` | — |
| `adapter/out` | Persistencia, storage, APIs externas | `application` | — |

## Reglas de dependencia

- Las dependencias apuntan hacia el centro: `adapter/*` → `application` → `domain`.
- La capa `domain` no importa nada de capas externas.
- Los puertos (interfaces) se definen en `application/port`; los adaptadores en `adapter/*`.
- Un módulo solo se comunica con otros módulos a través de puertos de entrada de `application/port/in` (ver [`../00-documentation-governance/structure-rules.md`](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/00-documentation-governance/structure-rules.md)).

## Mapeo de entidades por capa

| Entidad / Concepto | Capa | Tipo DDD |
|--------------------|------|----------|
| `Event` | `domain` | Aggregate Root |
| `EventRepository` | `application/port/out` | Repository interface |
| `PostgresEventRepository` | `adapter/out/persistence` | Adapter |
| `RecordEventUseCase` | `application/usecase` | Use Case |

## Módulos del backend

| Módulo | Responsabilidad | Patrón |
|--------|-----------------|--------|
| security | Autenticación, autorización, auditoría | Hexagonal (ADR-002) |
| parameterization | Catálogos configurables | Hexagonal (ADR-002) |
| device-management | Dispositivos y asignaciones | Hexagonal (ADR-002) |
| telemetry-service | Eventos, evidencia, alertas | Hexagonal (ADR-002) |
| monitoring | Notificaciones de eventos críticos | Hexagonal (ADR-002) |
| analytics | Métricas, resumen IA, reportes | Hexagonal (ADR-002) |
| platform | Transversal (errores, logging, observabilidad) | Fuera de módulos; dependencia permitida desde cualquier módulo |

## Anti-patrones prohibidos

- No llamar directamente a repositorios desde controllers sin pasar por casos de uso.
- No poner lógica de negocio en `adapter/*`.
- No compartir entidades de dominio entre módulos — usar DTOs o eventos.
- `platform` no depende de ningún módulo.

## Referencias

- [Documento de arquitectura](./architecture-document.md)
- [Reglas de estructura](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/00-documentation-governance/structure-rules.md)
- [ADRs](https://github.com/SomnGuard/somnguard-docs/tree/main/docs/05-architecture/decisions/records)
- [Modelo de datos](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/06-data-architecture/modeling-conventions.md)