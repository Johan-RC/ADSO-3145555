# Verificación técnica local complementaria / Local technical verification

**Fecha:** 6 de noviembre de 2026 (America/Bogota)  
**Entorno:** desarrollo local con Docker; pruebas de migración y backup en PostgreSQL efímero.  
**Alcance:** estado Liquibase de la base local, ciclo completo de migraciones en una base aislada, restauración de backup sintético y lectura/escritura en el servicio S3 compatible local.

## Resultados comprobados

| Verificación | Resultado | Evidencia observada |
|---|---|---|
| `liquibase status --verbose` en la base local | APROBADO | `somnguard` estaba al día; no había changesets pendientes. Consulta de solo lectura. |
| `validate`, `update`, rollback y re-aplicación | APROBADO | En PostgreSQL 16.15 efímero: 95 changesets activos aplicados, rollback de 95 hasta 0 y re-aplicación de 95. Estado final al día y `validate` sin errores. Los otros 95 de 190 quedaron filtrados por los contextos seleccionados. |
| Backup y restauración | APROBADO | `scripts/verify-backup-restore.sh` generó un dump custom no vacío y lo restauró en una segunda base aislada. El registro sintético restaurado coincidió; el contenedor se eliminó al finalizar. |
| Almacenamiento S3 compatible local | APROBADO | Escritura y lectura firmadas de un objeto sintético en el bucket local; el contenido leído coincidió byte por byte y el objeto de prueba fue eliminado. El servicio Compose llamado `minio` usa `adobe/s3mock:4.12.4`. |

## Procedimiento y límites

- El estado de la base local se consultó con Liquibase 4.33.0 y los contextos `01_ddl,02_dml,03_dcl,04_tcl`. Las credenciales se tomaron en memoria del contenedor local y no se copiaron a este informe.
- La prueba de rollback usó `scripts/verify-rollback.ps1`, un proyecto Compose con nombre aleatorio y su propia base PostgreSQL. El conteo fue 95 antes, 0 después del rollback y 95 tras re-aplicar. El script completo ejecutó `validate`, `history`, `rollback-count-sql` y el estado final. Sus recursos temporales quedaron eliminados.
- El servicio de almacenamiento local es S3Mock, no SeaweedFS. Esta prueba no demuestra escritura/lectura en el VPS ni en el SeaweedFS de producción.
- Las pruebas de backup se hicieron con datos sintéticos en una base efímera. No se generó ni se restauró un backup de producción.
- La evidencia de consola del VPS sigue pendiente: `03-liquibase-status.png`, `06-seaweedfs-storage.png` y `12-backup-restore.png`. Este informe de ejecución local no sustituye esas capturas.

## Observación de mantenimiento

Durante el rollback y la re-aplicación aparecieron mensajes idempotentes de índices/constraints existentes o ausentes. La prueba terminó correctamente. Se confirmó que algunos índices se declaran tanto en SQL de tablas como en los archivos dedicados de `01_ddl/10_indexes` (por ejemplo, dispositivo y evento). No es un fallo de esta ejecución; conviene consolidar estas definiciones mediante una migración futura, sin editar changesets ya aplicados.

**Resultado general:** verificaciones locales aprobadas dentro del alcance indicado; las tres evidencias operativas del VPS permanecen abiertas.
