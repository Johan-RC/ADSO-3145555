<div style="display:flex; align-items:center; justify-content:space-between;">

<div>
<img src="../assets/icons/logo-somnguard.png" width="140"/>
</div>

<div align="right">

# SOMNGUARD

## Registro de riesgos

**Estado:** En progreso
**Fecha de revisión:** 2026-11-06

</div>

</div>

Riesgos del proyecto SomnGuard: técnicos, de alcance, de equipo, externos y de seguridad.

## Cómo se calcula la exposición

**Exposición = Probabilidad × Impacto** (escala Baja=1 / Media=2 / Alta=3).

- Baja: producto < 3
- Media: producto 3–6
- Alta: producto > 6

## Riesgos activos

| ID | Categoría | Riesgo | Prob. | Impacto | Exposición | Mitigación | Owner | Estado |
|----|-----------|--------|-------|---------|------------|------------|-------|--------|
| R-002 | Técnico | Cambios futuros de Liquibase pueden introducir regresiones que impidan aplicar el esquema desde cero. | Media | Alto | Media | El flujo de [validación de Liquibase](https://github.com/SomnGuard/somnguard-db/blob/final-delivery-2026/.github/workflows/liquibase.yml) ejecuta validación, aplicación, rollback y re-aplicación en una base aislada en cada PR y en `main`, `qa` y `develop`. La ejecución local desde PostgreSQL vacía está registrada en el [informe técnico complementario](../06-implementation-procedure/evidence/local-verification-2026-11-06.md). Revisar el resultado CI antes de promover cambios. | Equipo Backend | En seguimiento |
| R-003 | Alcance | Quedan pendientes funcionales y documentales identificados como TD-003, TD-008 y TD-009; no priorizarlos puede retrasar el cierre del MVP. | Media | Alto | Media | Priorizar los ítems del [backlog técnico](./technical-backlog.md), asignar responsables y registrar evidencia de cierre por módulo. | PM/Arquitecto | Abierto |
| R-004 | Técnico | Precisión de la detección de fatiga/somnolencia en edge depende de datos de campo; validación tardía puede retrasar el MVP. | Media | Alto | Media | Validar con datos de campo desde el prototipo; umbrales configurables vía `parameterization`. | Equipo Edge | Abierto |
| R-005 | Técnico | Sincronización offline sin idempotencia puede duplicar eventos y corromper métricas. | Media | Medio | Media | ID único por evento + índice de idempotencia (RN-08); pruebas de integración. | Equipo Backend | Abierto |
| R-006 | Seguridad | Exposición de evidencia multimedia (PII) por control de acceso débil. | Media | Alto | Media | URLs firmadas, RBAC por rol (ver [modelo de amenazas](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/security-threat-model.md)). | Arquitectura | Abierto |
| R-007 | Equipo | Concentración de conocimiento: una sola persona figura como owner de la mayoría de los documentos; ausencia o rotación frena el proyecto (factor bus = 1). | Media | Alto | Media | Documentar decisiones (ADRs, runbooks), mantener este repo como fuente de verdad, formar equipo por módulo. | PM | Abierto |
| R-009 | Técnico | Los contratos OpenAPI estáticos de los módulos siguen pendientes; la documentación de clientes podría divergir de los endpoints implementados. | Media | Medio | Media | Mantener el [inventario de contratos](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/07-api-design/contracts/README.md) al día y publicar los seis YAML pendientes cuando se estabilicen los endpoints. | Arquitectura | Abierto |
| R-010 | Técnico | `analytics` (resumen IA) depende de un modelo externo; costo/latencia o indisponibilidad afectan el módulo. | Media | Medio | Media | Diseñar con puerto de salida desacoplado y fallback a resumen sin IA. | Arquitectura | Abierto |

## Bloqueantes activos

| ID | Bloqueante | Condición de desbloqueo | Responsable |
|----|-----------|-------------------------|-------------|
| B-003 | La validación del MVP depende de datos de campo del detector. | Completar prototipo edge con datos reales. | Equipo Edge |

## Riesgos aceptados

| ID | Riesgo | Justificación |
|----|--------|---------------|
| RA-001 | En el MVP, el edge envía telemetría con API key del dispositivo en lugar de un flujo M2M más robusto. | Simplicidad del MVP; la clave es rotable y revocable (amenaza T-002 del modelo de amenazas, mitigada). |

## Riesgos resueltos

| ID | Riesgo | Resolución | Estado |
|----|--------|------------|--------|
| R-001 | Archivos `.env.*` reales versionados en los seis repositorios auditados. | La revisión local de los seis clones y sus referencias/historial alcanzables encontró plantillas `.env.example`, pero no archivos `.env` reales versionados. Los `.env` locales examinados están ignorados. Repetir la revisión si se agregan repositorios o referencias. | Cerrado (2026-11-05; alcance de la auditoría indicado) |
| R-008 | Proveedor de notificaciones push no definido (Q-008). | Se seleccionó FCM (QR-023); la historia HU-API-009 figura implementada y probada E2E en la documentación del proyecto. | Cerrado |

## Bloqueantes cerrados

| ID | Bloqueante | Resolución | Fecha |
|----|------------|------------|-------|
| B-001 | Construcción de la capa de aplicación bloqueada por un hallazgo de secretos `.env`. | La aplicación está implementada en los repositorios de API, portal, app y edge; la auditoría de los seis repositorios no encontró `.env` reales versionados. El bloqueo dejó de aplicar. | 2026-11-05 |

## Ver también

- [Preguntas abiertas](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/15-project-control/open-questions.md)
- [Modelo de amenazas](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/security-threat-model.md)
- [Backlog técnico](./technical-backlog.md)
