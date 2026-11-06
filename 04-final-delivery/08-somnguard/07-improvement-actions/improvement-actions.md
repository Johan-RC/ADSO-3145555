# Acciones correctivas, preventivas y de mejoramiento

**Proyecto:** SomnGuard  
**Revisión:** 2026-11-06  
**Estado:** En seguimiento

Este plan reúne acciones sustentadas por el registro de riesgos, el backlog técnico y la evidencia de pruebas de la entrega. “Pendiente” significa que no se encontró evidencia suficiente de cierre; no afirma que la implementación esté fallando.

## Acciones correctivas

| ID | Acción | Evidencia / origen | Prioridad | Estado | Criterio de cierre |
|---|---|---|---|---|---|
| AC-001 | Corregir el registro de riesgos para retirar afirmaciones obsoletas sobre archivos `.env` versionados y una capa de aplicación inexistente. | Auditoría de seis repositorios y sus referencias alcanzables; módulos de aplicación presentes. Ver [riesgos](./risks.md) y [backlog técnico](./technical-backlog.md). | Alta | Completada localmente, 2026-11-05 | Fuentes Markdown y PDF de entrega reflejan la auditoría y conservan su alcance. |
| AC-002 | Completar la suite automatizada del API con una clave RSA exclusiva de pruebas y la integración PostgreSQL con Testcontainers. | La suite local del 2026-11-06, sobre `develop` con cambios locales sin confirmar, pasó 162/162 pruebas: 0 fallos, 0 errores y 0 omitidas. `AuthPostgresIntegrationTest` usó Testcontainers con PostgreSQL 16.15. La clave RSA de prueba está en `src/test/resources/keys/test/`. La ejecución parcial del 2026-11-05 quedó superada; la CI de los tags revisados es evidencia separada. | Alta | Completada localmente, 2026-11-06; CI de tags revisada | La suite API completa pasa 162/162, incluida la integración PostgreSQL/Testcontainers; las claves RSA se limitan a recursos de prueba. |
| AC-003 | Verificar `liquibase update` desde una base PostgreSQL vacía y conservar el resultado. | En PostgreSQL 16.15 efímero se ejecutaron `validate`, `update`, rollback de 95 changesets activos hasta cero, re-aplicación de los 95 y validación final. Resultado y alcance en el [informe técnico complementario](../06-implementation-procedure/evidence/local-verification-2026-11-06.md); la [CI del tag de DB](https://github.com/SomnGuard/somnguard-db/actions/runs/40241563463) también pasó validación y rollback. | Media | Completada localmente, 2026-11-06; CI del tag revisada | La aplicación desde una base vacía y su ciclo de rollback/re-aplicación pasan y quedan respaldados por evidencia. |

## Acciones preventivas

| ID | Acción | Evidencia / origen | Prioridad | Estado | Criterio de cierre |
|---|---|---|---|---|---|
| AP-001 | Mantener `.env` reales fuera de Git y añadir una revisión automatizada de secretos al flujo de integración continua. | La auditoría actual no halló archivos `.env` reales en los seis repositorios revisados; esto no reemplaza una prevención automatizada. | Alta | Pendiente | CI detecta archivos de entorno reales y credenciales; las plantillas contienen solo valores ficticios. |
| AP-002 | Ejecutar la validación de migraciones de base de datos en cada cambio que altere Liquibase. | El workflow de [Liquibase](https://github.com/SomnGuard/somnguard-db/blob/final-delivery-2026/.github/workflows/liquibase.yml) se dispara en cada PR y en pushes a `main`, `qa` y `develop`; `verify-rollback.sh` inicia PostgreSQL aislado, valida, aplica, revierte y vuelve a aplicar los changesets. La ejecución CI del tag de DB y la verificación local del 2026-11-06 pasaron. | Media | Implementada en CI; confirmar que sea check requerido en las ramas protegidas | El pipeline valida desde cero cada PR y cambio en las ramas indicadas. Falta confirmar la regla de protección que exige el check antes de fusionar. |
| AP-003 | Completar la prueba de integración para verificar el rol predeterminado activo durante el registro desde una base limpia. | `AuthPostgresIntegrationTest` ejecuta `ensureDefaultRoleExists()` en `@BeforeEach`, que inserta el rol `user` activo antes de registrar; por eso la prueba actual no verifica que Liquibase lo aprovisione. | Alta | Pendiente | Aplicar Liquibase en PostgreSQL vacía sin sembrar el rol desde el test; registrar y verificar HTTP 201 y vínculo al rol activo `user`; cubrir rol ausente/inactivo. |

## Mejoras del software

| ID | Mejora | Referencia | Prioridad | Estado | Criterio de cierre |
|---|---|---|---|---|---|
| IM-001 | Publicar los seis contratos OpenAPI estáticos de los módulos y mantenerlos alineados con los endpoints implementados. | TD-003 del [backlog técnico](./technical-backlog.md). | Media | Pendiente | Contratos validados y enlazados desde el inventario de API. |
| IM-002 | Completar el runbook del módulo `security`. | TD-008 del [backlog técnico](./technical-backlog.md). | Baja | Pendiente | `modules/security/runbook.md` cubre operación, diagnóstico y recuperación. |
| IM-003 | Implementar el flujo de aprovisionamiento, auto-registro y vinculación de dispositivos. | TD-009 del [backlog técnico](./technical-backlog.md) y ADR-010. | Alta | Pendiente | Endpoints, persistencia, auditoría y pruebas de integración completados. |

## Seguimiento

Los estados se actualizan cuando hay evidencia verificable. Las acciones abiertas se priorizan en el backlog de producto o técnico; sus responsables y fechas límite deben ser acordados por el equipo y no se asignan aquí sin esa confirmación.

## Referencias

- [Registro de riesgos](./risks.md)
- [Backlog técnico](./technical-backlog.md)
- [ADR-010: aprovisionamiento y vinculación de dispositivos](https://github.com/SomnGuard/somnguard-docs/blob/main/docs/05-architecture/decisions/records/ADR-010-provisioning-self-register.md)
