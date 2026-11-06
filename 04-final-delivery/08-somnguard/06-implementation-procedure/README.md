# Implementation procedure / Procedimiento de implementación

**Training project deliverable / Producto del proyecto formativo:** Procedimiento de implementación del software.

## Required content / Contenido requerido

- [x] Implementation procedure, with environments and steps / Procedimiento de implementación, con ambientes y pasos
- [x] Deployment evidence and production URL, if deployed / Evidencia de despliegue y URL de producción, si se desplegó

## Files / Archivos

- [Deployment procedure (editable Markdown)](deployment-procedure.md).
- [Deployment procedure (PDF)](deployment-procedure.pdf).
- [Deployment evidence](evidence/): nine VPS screenshots from the 2026-10-30 run.
- [Local verification report (editable Markdown)](evidence/local-verification-2026-11-06.md).
- [Local verification report (PDF)](evidence/local-verification-2026-11-06.pdf).

## Verified locally on 2026-11-06 / Verificado localmente

Liquibase status reported the local database as up to date. In a disposable PostgreSQL 16.15 database, validation, update, rollback of 95 active changesets, re-application, final status and validation all passed. A synthetic backup restored correctly into a second disposable database. The local S3-compatible service also passed a synthetic write/read comparison, and the test object was deleted. The full scope and limits are recorded in the linked report.

## Still pending / Aún pendiente

The existing `10-livekit-test.png` capture includes a visible face and event/device metadata. Confirm that the subject and metadata are synthetic/test data or that publication is authorized; otherwise replace it with an approved anonymized QA capture before making this repository public. Do not treat local-only presence as permission to publish.

The following production/VPS captures remain missing from `evidence/`:

- `03-liquibase-status.png`: Liquibase status from the deployed database.
- `06-seaweedfs-storage.png`: real write/read verification against production SeaweedFS.
- `12-backup-restore.png`: evidence of backup/restore for the deployed environment.

The local API Compose service named `minio` uses Adobe S3Mock, not SeaweedFS. The local report does not replace these production captures.

## Format / Formato

- Final version in PDF, plus the editable source when it exists. / Versión final en PDF y, si existe, el archivo fuente editable.
- Use English file names without spaces or accents. / Use nombres de archivo en inglés, sin espacios ni tildes.
- Files over 50 MB go to Drive and are listed in the project `README.md`. / Los archivos de más de 50 MB van a Drive y se relacionan en el `README.md` del proyecto.
- Do not add passwords, tokens, keys or real user data. / No incluya contraseñas, tokens, llaves ni datos reales de usuarios.
