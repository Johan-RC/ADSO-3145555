<div style="display:flex; align-items:center; justify-content:space-between;">

<div>
<img src="../assets/icons/logo-somnguard.png" width="140"/>
</div>

<div align="right">

# SOMNGUARD

## Requisitos no funcionales

**Estado:** En progreso
**Fecha:** 2026-08-19

</div>

</div>

Requisitos no funcionales del sistema, derivados de la sección 17 del documento de arquitectura y del informe de diseño. Los nuevos requisitos usan el identificador `NFR-` según `../00-documentation-governance/agile-conventions.md`.

## Catálogo de NFR

| ID | Categoría | Requisito | Meta / evidencia |
|----|-----------|-----------|------------------|
| NFR-01 | Seguridad | Seguridad en todo el ciclo: autenticación JWT, RBAC, API keys por dispositivo, cifrado de datos sensibles | Cumplimiento de controles de [`../00-documentation-governance/security-policy.md`](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/00-documentation-governance/security-policy.md) y [`../07-api-design/authentication.md`](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/07-api-design/authentication.md) |
| NFR-02 | Mantenibilidad | Código organizado en módulos con arquitectura hexagonal (puertos y adaptadores), dependencias dirigidas al centro | Verificación por reglas de arquitectura (ArchUnit) en CI |
| NFR-03 | Tolerancia a fallos | El edge opera sin conectividad (buffer offline) y la API rechaza duplicados por idempotencia | Flujos `sd-offline-sync` y RN-08 |
| NFR-04 | Rendimiento | Baja latencia en alertas críticas (detección → alerta sonora) | Medición en prototipo edge; la alerta es local, sin dependencia de red |
| NFR-05 | Escalabilidad | Escalabilidad razonable del backend para < 10k usuarios y crecer por instancias | Pruebas de carga por ambiente de QA |
| NFR-06 | Trazabilidad | Trazabilidad de eventos y auditoría de accesos (`audit_login`) | Registros de observabilidad y logs (sección 15 del documento de arquitectura) |
| NFR-07 | Privacidad | Privacidad de datos sensibles y evidencia multimedia (Ley 1581/2012, retención configurable) | Política de retención y control de acceso a evidencia |
| NFR-08 | Disponibilidad | Disponibilidad de la plataforma ≥ 99% mensual (SLO del contrato de servicio; ver [`../13-operations/_template-sla-slo-sli.md`](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/13-operations/_template-sla-slo-sli.md)) | Monitoreo de uptime, SLIs registrados en observabilidad |

## Mapeo a componentes

| NFR | Componente principal | Componentes de soporte |
|-----|---------------------|------------------------|
| NFR-01 | security | platform (logging, observabilidad) |
| NFR-02 | todos los módulos | platform, ADR-002 |
| NFR-03 | telemetry-service, edge | device-management (API keys), storage (MinIO) |
| NFR-04 | edge (detección) | telemetry-service (registro), monitoring (notificación) |
| NFR-05 | backend (monolito modular) | PostgreSQL, devops (CI/CD) |
| NFR-06 | telemetry-service, security | platform (observabilidad) |
| NFR-07 | telemetry-service (evidence) | security (RBAC), storage |
| NFR-08 | platform (observabilidad, despliegue) | devops (CI/CD, ambientes qa/main), backup-and-recovery |

## Ver también

- [Documento de arquitectura](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/architecture-document.md#17-requisitos-no-funcionales)
- [Seguridad](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/00-documentation-governance/security-policy.md)
- [Estrategia de pruebas](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/11-quality-assurance/test-strategy.md)