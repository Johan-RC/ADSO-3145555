<div style="display:flex; align-items:center; justify-content:space-between;">

<div>
<img src="../assets/icons/logo-somnguard.png" width="140"/>
</div>

<div align="right">

# SOMNGUARD

## Backlog técnico

**Estado:** En progreso
**Fecha de revisión:** 2026-11-05

</div>

</div>

Deuda técnica conocida y pendientes vigentes del proyecto SomnGuard. La API ya cuenta con módulos implementados en Java, configuración de seguridad, persistencia y dependencias de build. Este backlog se revisó contra los seis repositorios locales completos el 2026-11-05 para retirar afirmaciones obsoletas y conservar pendientes verificables.

## Leyenda

- **Impacto**: Bajo / Medio / Alto — efecto sobre despliegue, integridad o velocidad del equipo.
- **Prioridad**: P0 (bloqueante) · P1 (alta) · P2 (media) · P3 (baja).
- **Estado**: Abierto · En curso · Resuelto.

## Deuda técnica activa

| ID | Descripción | Impacto | Prioridad | Módulo(s) afectado(s) | Estado |
|----|-------------|---------|-----------|----------------------|--------|
| TD-001 | **Archivos `.env` reales versionados (hallazgo descartado)**: auditoría local de los seis repositorios completos y de sus referencias/historial alcanzables. Solo se encontraron plantillas `.env.example` versionadas; no se encontraron archivos `.env` reales en Git. Los `.env` presentes en algunas copias locales están ignorados. No se requiere purga del historial por este hallazgo. Repetir la revisión si se agregan repositorios o referencias que no estén en estos clones. | Alto | P0 | Todos | Resuelto (auditoría 2026-11-05) |
| TD-002 | **Capa de aplicación no construida**: pendiente obsoleto. La API contiene implementaciones Java en los módulos `security`, `parameterization`, `device_management`, `telemetry_service`, `analytics`, `monitoring` y `platform`. Los pendientes funcionales concretos se mantienen en sus ítems propios, como TD-009. | Alto | P1 | API | Resuelto (verificación 2026-11-05) |
| TD-003 | **Contratos OpenAPI por módulo incompletos**: la API ya incluye SpringDoc y `OpenApiConfig`. Los seis contratos YAML de módulo siguen pendientes según `docs/07-api-design/contracts/README.md`; `streaming.yaml` existe como propuesta post-MVP. | Medio | P2 | API / documentación | Abierto |
| TD-004 | **Documentación por módulo**: `09-modules/modules/_template/` lista; `modules/security/` documentado desde 2026-09-01 (README, data-model, events, decisions, features-analysis; runbook pendiente). | Medio | P2 | 09-modules | Resuelto (instancia security 2026-09-01; runbook → TD-008) |
| TD-005 | **Catálogos sin semillas definidas**: valores iniciales de `parameterization` fijados en `data-dictionary.md` y seeds `001..008` (categorías, severidades, sonidos, tipos, estados). | Medio | P2 | parameterization | Resuelto (verificado 2026-09-05) |
| TD-006 | **Estados de negocio sin decisión**: si usar catálogo parametrizable genérico o `VARCHAR + CHECK` para estados de dispositivo/evento (ver [modeling-conventions](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/06-data-architecture/modeling-conventions.md) y QR-013 en [open-questions](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/15-project-control/open-questions.md)). | Medio | P2 | telemetry-service, device-management | Resuelto (ADR-009 aceptada 2026-08-22: `status_category` + `status`) |
| TD-007 | **Driver JDBC / dependencias de build sin fijar**: pendiente original superado. `somnguard-api/pom.xml` existe, define el parent de Spring Boot y declara PostgreSQL en runtime; las dependencias gestionadas heredan versiones del parent. | Medio | P1 | API | Resuelto (verificación 2026-11-05) |
| TD-008 | **Runbook de security pendiente**: `modules/security/` documentado salvo `runbook.md` exigido por la plantilla. | Bajo | P3 | 09-modules | Abierto |
| TD-009 | **Implementar provisioning/self-register/claim**: endpoints (`provisioning-tokens`, `self-register`, `claim`), tablas (`device_provisioning_token`, `device_provisioning_audit`, claim en `device`), features (`device.provision`, `device.claim`). Diseño en ADR-010. | Alto | P1 | device_management, security | Abierto |
| TD-010 | **Implementar ADR-011 (solo global)**: DDL (`global_config`, `global_config_history`, `device.applied_config_version` + regularizar `pending_config_update`), bump en `ParameterizationController` (misma tx + history), `GET /config` versionado (persiste `device_config/history`), `heartbeat` manual-only, `GET /config/status`, `PATCH 410`, `POST /refresh`, backfill `applied=0`, UI app `applied vs available`, caché + fusión `detection_thresholds` en device. Código implementado 2026-09-15 (enmienda manual-only); Q-021 ratificada. | Alto | P1 | parameterization, device_management, device, app/portal, db | Resuelto 2026-09-15 |

## Seguimiento de pendientes vigentes

La construcción inicial de la capa de aplicación ya no es una fase pendiente. El trabajo abierto se gestiona por tareas concretas de módulos, decisiones de arquitectura y documentación. Entre los pendientes de este archivo están TD-003 (contratos OpenAPI estáticos), TD-008 (runbook de security) y TD-009 (provisioning/self-register/claim). Antes de cerrar cada uno se debe contrastar el código actual y conservar evidencia verificable.

## Criterio de ingreso al backlog

Un ítem entra aquí cuando: (1) está identificado con módulo y evidencia concreta, (2) tiene impacto y prioridad asignados, y (3) no es una tarea de contenido puramente documental (esas van a las ramas `docs/*`). Al resolverse se marca como Resuelto y se mueve al histórico en el cierre de iteración.

## Ver también

- [Product backlog](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/03-product-definition/product-backlog.md)
- [Riesgos](./risks.md)
- [Dependencias](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/15-project-control/dependencies.md)


