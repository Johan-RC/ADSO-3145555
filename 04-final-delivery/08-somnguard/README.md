# SomnGuard

Final delivery of the training project / Entrega final del proyecto formativo.

## General information / Información general

| Field / Campo | Value / Valor |
|---|---|
| Product name / Nombre del producto | SomnGuard |
| Ficha | 3145555 |
| Training program / Programa de formación | Análisis y Desarrollo de Software (228118) |
| Training project / Proyecto formativo | Desarrollo de software orientado a servicios |
| Training center / Centro de formación | Centro de la Industria, la Empresa y los Servicios (Regional Huila) |
| Process / Proceso | Completion of the technologist taught stage / Finalización de la etapa lectiva del tecnólogo |
| Research seedbed / Semillero de investigación | Developers & Geeks |
| Delivery version / Versión entregada | `final-delivery-2026` |
| Delivery date / Fecha de entrega | 2026-11-07 / 7 de noviembre de 2026 |
| Delivered by / Entregado por | Apprentice team / Equipo de aprendices |

## Summary / Resumen

- **Problem it solves / Problema que resuelve:** Detecta señales de somnolencia o fatiga en el conductor con procesamiento local y emite alertas sonoras; registra eventos para consulta posterior.
- **Target users / Usuarios:** Conductores y personal administrador autorizado que consulta dispositivos, eventos y avisos.
- **Main features / Funciones principales:** Detección en el dispositivo, alertas locales, almacenamiento y sincronización de eventos al recuperar conexión, consulta en portal web y app móvil.
- **Technology stack / Tecnologías:** Java/Spring Boot, PostgreSQL/Liquibase, React/Vite, React Native, Python/OpenCV, Docker, Traefik y LiveKit.
- **Production URL / URL en producción:** [Portal](https://somnguard.tech), [health de API](https://api.somnguard.tech/actuator/health) y [descarga Android](https://download.somnguard.tech/SomnGuard.apk); evidencias capturadas el 2026-10-30.
- **Demo credentials / Credenciales de prueba:** do not write real passwords here / no escriba contraseñas reales aquí

## Team members / Integrantes

> The team confirmed the four member records on 2026-11-07. The checkboxes record confirmation of the personal data and authorization to publish the listed fields. Report any error, missing member or extra member to the instructor.
>
> El equipo confirmó los cuatro registros el 2026-11-07. Las casillas registran la verificación de los datos y la autorización para publicar los campos indicados. Reporte al instructor cualquier error, o si falta o sobra alguien.

| Full name / Nombre completo | Doc. type / Tipo | Doc. number / Número | Ficha | GitHub user / Usuario | Role / Rol | Data checked / Datos verificados | Publication authorized / Autorización de publicación |
|---|---|---|---|---|---|---|---|
| JUAN CARLOS JURADO CASTAÑEDA | CC | 1077224670 | 3145555 | JuanCarlosJC-20 | Desarrollador Full Stack | ☑ | ☑ |
| JOHAN STEVEN RODRIGUEZ CHARRY | CC | 1075794019 | 3145555 | Johan-RC | Desarrollador Frontend | ☑ | ☑ |
| CRISTIAN JAVIER PALMA SOTTO | CC | 1141115893 | 3145555 | CristianJPalma | Desarrollador Full Stack | ☑ | ☑ |
| BRAYAN ALBERTO PERDOMO PERDOMO | CC | 1075235870 | 3145555 | Brayanperdomoo | Desarrollador Frontend | ☑ | ☑ |

Data verification and publication consent are tracked separately. On 2026-11-07, the team confirmed that all four member records are correct and that all four apprentices authorize public publication of the listed fields; both columns are marked accordingly. Do not add addresses, phone numbers or email addresses here.

La verificación de datos y el consentimiento de publicación se registran por separado. El 2026-11-07, el equipo confirmó que los cuatro registros son correctos y que los cuatro aprendices autorizan publicar los campos indicados; ambas columnas están marcadas. No agregue direcciones, teléfonos ni correos aquí.

## Delivery contents / Contenido de la entrega

| Folder / Carpeta | Content / Contenido | Closure status / Estado de cierre |
|---|---|---|
| [`01-requirements-specification/`](01-requirements-specification/) | Requirements specification / Especificación de requisitos | SRS, functional/non-functional requirements, stories, backlog, and traceability matrix are present as PDFs and editable sources. The product backlog identifies its epic statuses as an initial 2026-08-19 snapshot; source documents still record “En progreso”, and team approval/current status confirmation remain pending. |
| [`02-software-analysis/`](02-software-analysis/) | Software analysis / Análisis del software | Files and diagrams present; source document still records “En progreso”. |
| [`03-technical-proposal/`](03-technical-proposal/) | Technical proposal / Propuesta técnica | PDF and editable source present; source document still records “En progreso”. |
| [`04-software-design/`](04-software-design/) | Software design / Diseño del software | Files and Figma prototype link present; data dictionary is a draft and some design sources remain in progress. |
| [`05-test-documentation/`](05-test-documentation/) | Test documentation / Documentación de pruebas | Complete for the documented API scope: the 2026-11-06 local suite passed 162/162, including PostgreSQL/Testcontainers; CI on tagged API and database revisions also passed. The report states that E2E/mobile and performance tests are outside this execution's scope. The integration fixture seeds the default role; Liquibase role provisioning remains tracked under AP-003. |
| [`06-implementation-procedure/`](06-implementation-procedure/) | Implementation procedure / Procedimiento de implementación | Partial: 9 VPS captures are present; local Liquibase status, isolated apply/rollback/reapply, synthetic backup/restore, and local S3Mock write/read passed on 2026-11-06. Production captures for Liquibase status, SeaweedFS, and backup/restore remain pending; local S3Mock is not production SeaweedFS. The LiveKit capture shows a visible face; confirm it is synthetic/authorized or replace it with approved anonymized QA evidence before public delivery. |
| [`07-improvement-actions/`](07-improvement-actions/) | Improvement actions / Acciones de mejoramiento | AC-002 closed locally on 2026-11-06 with the 162/162 API suite; AC-003 closed locally with the empty PostgreSQL migration cycle and evidence. AP-002 is implemented in CI; its required-check branch protection remains unverified. AP-001, AP-003, and IM-001 through IM-003 remain open; AP-003 still needs an integration test that does not seed the default role in its fixture. |
| [`08-manuals/`](08-manuals/) | Manuals / Manuales | Partial: technical and deployment manuals are present; user manual revision 1.1 is aligned across Markdown, DOCX, and PDF, and the ten-page PDF was visually reviewed. Detailed capture and evidence status is recorded in [`08-manuals/README.md`](08-manuals/README.md). |
| [`09-project-article/`](09-project-article/) | Project article / Artículo del proyecto | Partial: ACM 6 pp, IEEE 7 pp and APA 7 21 pp compared; the team still must choose the final style and confirm the editable source for those team-article PDFs. A separate individual security manuscript in the adjacent `Somguard` workspace is not their source or a substitute. |
| [`10-videos/`](10-videos/) | Videos / Videos | Partial: pitch (1:19) and tutorial (3:38) play without sign-in. The pitch mentions long trips/cargo transport but lacks a clear differentiator and CTA; two claims in illustrative screens need product verification. The public tutorial shows potentially identifiable names, faces, filled access fields, event/device details and logs; confirm they are synthetic or authorized before public submission. |
| [`code-tag/`](code-tag/) | Repository links, tags and ZIP files / Enlaces, tags y ZIP | Six tags are published; the `final-delivery` Release has all 12 ZIPs. Asset sizes and SHA-256 digests match the local files. `ariel5253` access is reported granted in seven repositories. |
| [`team-roster.md`](team-roster.md) | Team and roles / Equipo y roles | Apprentice roles and individual contributions are recorded. The README marks all four member-data checks and publication consents based on the team's confirmation. Instructor direct/indirect classifications remain to be confirmed. |
| [`software-registration.md`](software-registration.md) | Software registration data / Datos para registro de software | Applicant identity and project data are populated; the applicant confirms the team's verbal authorization for Juan Carlos to represent the co-holders, and no written authorization is attached. All three attachment categories have files locally. Third-party asset/model provenance and some license/deployment details remain to be confirmed. The team declaration remains unchecked. |

A document being present does not mean it has been approved or fully validated. The status above records current evidence and open work; all external publication remains pending review.
## Large files on Google Drive / Archivos pesados en Google Drive

Only files too heavy for GitHub go here, such as demo videos. Everything else stays in this folder.

Aquí solo van archivos demasiado pesados para GitHub, como videos de demostración. Todo lo demás vive en esta carpeta.

| File / Archivo | Size / Tamaño | Link / Enlace |
|---|---|---|
| Pitch publicitario (`video-publicitario.mp4`) | 8,974,448 bytes | [Abrir en Drive](https://drive.google.com/file/d/1Mqo-R2HJLbO1hgdx-M8pdhNxHzLNB-OE/view?usp=drivesdk) - 1:19; reproducción completa sin sesión. Revisar diferenciador, CTA y dos afirmaciones de función no verificadas en el código/documentación. |
| Tutorial de uso (`tutirual-uso.mp4`) | 25,300,457 bytes | [Abrir en Drive](https://drive.google.com/file/d/1NZHFwlfdvIojKzKitcW4re_j_22_LZZG/view?usp=drivesdk) - 3:38; reproducción completa sin sesión. Confirmar que nombres, rostros, acceso, eventos, dispositivo y logs sean de prueba o estén autorizados; el video todavía es público. |

\n
