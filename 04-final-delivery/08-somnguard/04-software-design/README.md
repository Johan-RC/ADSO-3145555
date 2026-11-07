# Software design / Diseño del software

**Training project deliverable / Producto del proyecto formativo:** Documentación de diseño del software (interfaces gráficas, modelo arquitectónico, patrones de diseño, modelo de datos).

## Required content / Contenido requerido

- [x] Graphical interfaces: mockups or prototype / Interfaces gráficas: mockups o prototipo — [Figma SomnGuard](https://www.figma.com/design/DRxeTn6XLorEBquwTviLUO/SomnGuard?node-id=0-1) (editable online prototype / prototipo editable en línea) and [SomnGuard.fig](./SomnGuard.fig) (exported editable file / archivo editable exportado)
- [x] Architectural model / Modelo arquitectónico
- [x] Design patterns applied, with where they are used / Patrones de diseño aplicados, indicando dónde se usan
- [x] Data model: conceptual, logical and physical / Modelo de datos: conceptual, lógico y físico — ER and relational sources plus a read-only physical PostgreSQL snapshot / fuentes ER y relacional más snapshot físico de PostgreSQL en modo lectura

## Data model files / Archivos del modelo de datos

- [Software design report / Informe de diseño](./software-design-report.md) and [PDF](./software-design-report.pdf): explains the three model levels and their status.
- [Physical data model / Modelo físico](./database-physical-model.md) and [PDF](./database-physical-model.pdf): read-only snapshot of 38 application tables across five schemas, with five readable schema diagrams and Liquibase references.
- Editable Mermaid sources and PNG exports are in [`diagrams/source/`](./diagrams/source/) and [`diagrams/exports/`](./diagrams/exports/).

**Pending source reconciliation / Conciliación pendiente:** `somnguard-docs` marks the logical model as in progress and its data dictionary as a 33-table draft. The local physical snapshot contains 38 application tables and includes three changesets absent from the `final-delivery-2026` tag recorded in `code-tag/README.md`. The documents preserve these statuses and do not present the counts as equivalent or claim that the local snapshot exactly matches that tag.

## Format / Formato

- Final version in PDF, plus the editable source when it exists. / Versión final en PDF y, si existe, el archivo fuente editable.
- Use English file names without spaces or accents. / Use nombres de archivo en inglés, sin espacios ni tildes.
- Files over 50 MB go to Drive and are listed in the project `README.md`. / Los archivos de más de 50 MB van a Drive y se relacionan en el `README.md` del proyecto.
- Do not add passwords, tokens, keys or real user data. / No incluya contraseñas, tokens, llaves ni datos reales de usuarios.
