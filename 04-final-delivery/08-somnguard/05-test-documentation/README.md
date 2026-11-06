# Test documentation / Documentación de pruebas

**Training project deliverable / Producto del proyecto formativo:** Documentación de pruebas.

## Required content / Contenido requerido

- [x] Test plan / Plan de pruebas
- [x] Test cases / Casos de prueba
- [x] Test results with evidence / Resultados de las pruebas con evidencia

## Deliverables / Entregables

- `test-report.md`: editable report with plan, cases, execution results, evidence, findings, and recommended action.
- `test-report.pdf`: final PDF version of the report.
- `test-strategy.md` and `test-strategy.pdf`: project test strategy.

The report records three manual registration cases that passed. The latest automated API run on 2026-11-06 passed 162/162 tests (0 failures, 0 errors, 0 skipped), including the PostgreSQL/Testcontainers integration on a temporary PostgreSQL 16.15 container. The test-only JWT key fixture resolved the earlier context initialization errors. See `test-report.md` / `test-report.pdf` for the run details and the Surefire shutdown note. The integration fixture inserts the active default role and disables Liquibase, so it does not verify the role seed migration; see AP-003 in the improvement actions.

## Format / Formato

- Final version in PDF, plus the editable source when it exists. / Versión final en PDF y, si existe, el archivo fuente editable.
- English file names, without spaces or accents: `test-report.pdf`. / Nombres de archivo en inglés, sin espacios ni tildes.
- Files over 50 MB go to Drive and are listed in the project `README.md`. / Los archivos de más de 50 MB van a Drive y se relacionan en el `README.md` del proyecto.
- Do not add passwords, tokens, keys or real user data. / No incluya contraseñas, tokens, llaves ni datos reales de usuarios.
