# Code and tags / Código y tags: SomnGuard

## Original repositories / Repositorios originales

Every original working repository of the project must be listed here and must be **public**. The instructor compares what was delivered against these repositories, so they must stay public and keep their full history until the review ends.

Todos los repositorios originales de trabajo del proyecto deben estar aquí y deben ser **públicos**. El instructor contrasta lo entregado contra estos repositorios, así que deben seguir públicos y con todo su historial hasta terminar la revisión.

If one is missing, add a row. If one is empty or no longer used, write that in the commit column. Visibility was rechecked on 2026-11-06.

Si falta alguno, agregue la fila. Si uno está vacío o ya no se usa, indíquelo en la columna del commit. La visibilidad se volvió a revisar el 2026-11-06.

| Component / Componente | Repository / Repositorio | Status / Estado | Access for `ariel5253` / Acceso de `ariel5253` | Commit of tag `final-delivery-2026` / Commit del tag | Main version ZIP / ZIP versión main | Full export ZIP / ZIP completo |
|---|---|---|---|---|---|---|
| Backend | [SomnGuard/somnguard-api](https://github.com/SomnGuard/somnguard-api) | Public / Público | Verify directly / Verificar directamente | [`903d3c275bf016a13c7e462a7f062fc7c84659fc`](https://github.com/SomnGuard/somnguard-api/commit/903d3c275bf016a13c7e462a7f062fc7c84659fc) | `somnguard-api-final-delivery-2026-main.zip` (local; link pending) | `somnguard-api-full-export.zip` (local; link pending) |
| Mobile app | [SomnGuard/somnguard-app](https://github.com/SomnGuard/somnguard-app) | Public / Público | Verify directly / Verificar directamente | [`135c24e82001578911529a70a4a4afabaf5eeec7`](https://github.com/SomnGuard/somnguard-app/commit/135c24e82001578911529a70a4a4afabaf5eeec7) | `somnguard-app-final-delivery-2026-main.zip` (local; link pending) | `somnguard-app-full-export.zip` (local; link pending) |
| Database | [SomnGuard/somnguard-db](https://github.com/SomnGuard/somnguard-db) | Public / Público | Verify directly / Verificar directamente | [`e1af032352d114181392583a458a672585a5b127`](https://github.com/SomnGuard/somnguard-db/commit/e1af032352d114181392583a458a672585a5b127) | `somnguard-db-final-delivery-2026-main.zip` (local; link pending) | `somnguard-db-full-export.zip` (local; link pending) |
| Device / firmware | [SomnGuard/somnguard-device](https://github.com/SomnGuard/somnguard-device) | Public / Público | Verify directly / Verificar directamente | [`f07d1b870ac3e46a2acc7f7b8e1b266ed65c09b5`](https://github.com/SomnGuard/somnguard-device/commit/f07d1b870ac3e46a2acc7f7b8e1b266ed65c09b5) | `somnguard-device-final-delivery-2026-main.zip` (local; link pending) | `somnguard-device-full-export.zip` (local; link pending) |
| Documentation | [SomnGuard/somnguard-docs](https://github.com/SomnGuard/somnguard-docs) | Public / Público | Verify directly / Verificar directamente | [`2bc61dda553075642c62ef7ea35b8fb61d36b0dd`](https://github.com/SomnGuard/somnguard-docs/commit/2bc61dda553075642c62ef7ea35b8fb61d36b0dd) | `somnguard-docs-final-delivery-2026-main.zip` (local; link pending) | `somnguard-docs-full-export.zip` (local; link pending) |
| Web frontend | [SomnGuard/somnguard-portal](https://github.com/SomnGuard/somnguard-portal) | Public / Público | Verify directly / Verificar directamente | [`83ba3148d570a7590a5cea8e457992123485f696`](https://github.com/SomnGuard/somnguard-portal/commit/83ba3148d570a7590a5cea8e457992123485f696) | `somnguard-portal-final-delivery-2026-main.zip` (local; link pending) | `somnguard-portal-full-export.zip` (local; link pending) |
| Landing / download page | [SomnGuard/somnguard.github.io](https://github.com/SomnGuard/somnguard.github.io) | Public / Público | Verify directly / Verificar directamente | No tag / Sin tag de entrega | | |

The six tagged repositories and the landing-page repository were confirmed public on 2026-11-06. A mirror audit of all fetched refs found no real `.env` files tracked on 2026-11-05; `.env.example` templates remain. Repeat secret checks before publishing if refs or repositories change.

Los seis repositorios con tag y el repositorio de landing se confirmaron públicos el 2026-11-06. La auditoría de los refs descargados no encontró archivos `.env` reales versionados el 2026-11-05; solo plantillas `.env.example`. Repita la revisión de secretos antes de publicar si cambian los refs o repositorios.

On 2026-11-06, a read-only permission check for `ariel5253` returned HTTP 403 for all seven repositories in the table. The connector cannot establish whether write access is already granted. Verify it directly in GitHub before delivery.

El 2026-11-06, la consulta de solo lectura de permisos de `ariel5253` devolvió HTTP 403 en los siete repositorios de la tabla. El conector no permite establecer si ya tiene acceso de escritura. Verifíquelo directamente en GitHub antes de entregar.

## Why two ZIP files / Por qué dos ZIP

| File / Archivo | Content / Contenido | Purpose / Para qué sirve |
|---|---|---|
| `<repo>-final-delivery-2026-main.zip` | Only the code of `main` at tag `final-delivery-2026` / Solo el código de `main` en el tag | The exact version delivered, used for software registration / La versión exacta entregada, la que se usa para registro de software |
| `<repo>-full-export.zip` | The whole repository: all branches, tags and history / Todo el repositorio: ramas, tags e historial | Proof of the work done and a complete backup / Prueba del trabajo realizado y respaldo completo |

## Where the ZIP files live / Dónde quedan los ZIP

The 12 ZIP files (two for each of the six tagged repositories) are prepared locally in `release-assets/` under this folder, and their SHA-256 hashes are recorded in `SHA256SUMS.txt`. The parent delivery repository ignores ZIP files, so these upload assets will not be included in the Pull Request. The table lists the exact asset filenames; replace the local references with public Release links only after the team authorizes and creates the `final-delivery` release.

Los 12 ZIP (dos por cada uno de los seis repositorios con tag) están preparados localmente en `release-assets/`, dentro de esta carpeta, y sus hashes SHA-256 están en `SHA256SUMS.txt`. El repositorio padre de la entrega ignora los ZIP, por lo que estos archivos para subir no se incluirán en el Pull Request. La tabla registra los nombres exactos de los archivos; reemplácelos por enlaces públicos del Release solo cuando el equipo autorice y cree el release `final-delivery`.

## Integrity / Integridad

Copy the SHA-256 of every ZIP into [`SHA256SUMS.txt`](SHA256SUMS.txt). / Copie el SHA-256 de cada ZIP en ese archivo.

## Local verification / Verificación local

Checked locally on 2026-11-05. All 12 archive SHA-256 values match `SHA256SUMS.txt`. Each of the six `*-final-delivery-2026-main.zip` files exactly matches the file paths and contents produced by `git archive` from its corresponding `final-delivery-2026` tag. Each of the six full-export repositories passed `git fsck --full`, resolves the tag to the commit listed above, and contains the branch refs present in the corresponding local `origin` refs. The ZIP assets have not been uploaded; Release links and instructor write-access confirmation remain pending.

Verificado localmente el 2026-11-05. Los 12 SHA-256 coinciden con `SHA256SUMS.txt`. Cada archivo `*-final-delivery-2026-main.zip` coincide exactamente en rutas y contenido con `git archive` del tag `final-delivery-2026` correspondiente. Cada repositorio full-export pasó `git fsck --full`, conserva el tag en el commit indicado y las ramas que aparecen en las referencias `origin` locales. Los ZIP no se han subido; faltan los enlaces del Release y confirmar el acceso de escritura del instructor.

Supplementary CI evidence for workflows associated with the tagged API, database, and app commits is documented in the [test report](../05-test-documentation/test-report.md). These results complement, but do not replace, the local test run or the operational evidence still required in the implementation procedure.

La evidencia complementaria de CI para los commits etiquetados del API, la base de datos y la aplicación está documentada en el [informe de pruebas](../05-test-documentation/test-report.md). Complementa los resultados locales, pero no reemplaza la ejecución local ni las evidencias operativas pendientes del procedimiento de implementación.

## Recheck / Revisión adicional (2026-11-06)

All 12 prepared ZIP files were rechecked locally against `SHA256SUMS.txt`; every SHA-256 matched and every ZIP passed its CRC integrity test. The six `final-delivery-2026` tags in the API, app, DB, device, docs and portal repositories still resolve to the commit IDs listed above. This recheck does not replace the 2026-11-05 full-export `git fsck` and `git archive` comparison recorded earlier. The ZIPs are now copied to the ignored local `release-assets/` folder and have not been attached to a Release. A read-only `git ls-remote origin` check on 2026-11-06 confirmed that all six remote tags dereference to the commit IDs listed in the table. The GitHub connector also confirmed that all seven repositories in the table are public. Instructor write access remains unverified because permission queries returned HTTP 403.

Los 12 ZIP preparados se comprobaron de nuevo en local contra `SHA256SUMS.txt`; todos los SHA-256 coincidieron y todos pasaron la prueba de integridad CRC. Los seis tags `final-delivery-2026` de API, app, DB, device, docs y portal siguen resolviendo a los commits listados arriba. Esta revisión no sustituye la comprobación de `git fsck` y la comparación con `git archive` del 2026-11-05, registrada antes. Los ZIP se copiaron a la carpeta local ignorada `release-assets/` y no se han adjuntado a un Release. Una consulta de solo lectura con `git ls-remote origin` del 2026-11-06 confirmó que los seis tags remotos apuntan a los commits de la tabla. El conector de GitHub confirmó que los siete repositorios de la tabla son públicos; el acceso de escritura del instructor sigue sin verificarse porque las consultas de permisos devolvieron HTTP 403.
