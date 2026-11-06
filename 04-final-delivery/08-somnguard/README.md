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
| Delivery date / Fecha de entrega | Pending PR submission / Pendiente de enviar el PR |
| Delivered by / Entregado por | To be confirmed by the team / Por confirmar por el equipo |

## Summary / Resumen

- **Problem it solves / Problema que resuelve:** Detecta señales de somnolencia o fatiga en el conductor con procesamiento local y emite alertas sonoras; registra eventos para consulta posterior.
- **Target users / Usuarios:** Conductores y personal administrador autorizado que consulta dispositivos, eventos y avisos.
- **Main features / Funciones principales:** Detección en el dispositivo, alertas locales, almacenamiento y sincronización de eventos al recuperar conexión, consulta en portal web y app móvil.
- **Technology stack / Tecnologías:** Java/Spring Boot, PostgreSQL/Liquibase, React/Vite, React Native, Python/OpenCV, Docker, Traefik y LiveKit.
- **Production URL / URL en producción:** [Portal](https://somnguard.tech), [health de API](https://api.somnguard.tech/actuator/health) y [descarga Android](https://download.somnguard.tech/SomnGuard.apk); evidencias capturadas el 2026-10-30.
- **Demo credentials / Credenciales de prueba:** do not write real passwords here / no escriba contraseñas reales aquí

## Team members / Integrantes

> Names and document numbers were preloaded by the instructor from the Sofía Plus report. Each member checks their row, completes GitHub user and role, and marks the last column. Report any error, missing member or extra member to the instructor.
>
> Los nombres y documentos los precargó el instructor desde el reporte de Sofía Plus. Cada integrante revisa su fila, completa usuario de GitHub y rol, y marca la última columna. Reporte al instructor cualquier error, o si falta o sobra alguien.

| Full name / Nombre completo | Doc. type / Tipo | Doc. number / Número | Ficha | GitHub user / Usuario | Role / Rol | Verified and authorized / Verificado y autorizado |
|---|---|---|---|---|---|---|
| JUAN CARLOS JURADO CASTAÑEDA | CC | 1077224670 | 3145555 | JuanCarlosJC-20 | | ☐ |
| JOHAN STEVEN RODRIGUEZ CHARRY | CC | 1075794019 | 3145555 | Johan-RC | | ☐ |
| CRISTIAN JAVIER PALMA SOTTO | CC | 1141115893 | 3145555 | CristianJPalma | | ☐ |
| BRAYAN ALBERTO PERDOMO PERDOMO | CC | 1075235870 | 3145555 | Brayanperdomoo | | ☐ |

Data use authorization: by checking the box, the member confirms their data and authorizes publishing their name, document number and ficha in this public repository, for the software registration process (Ley 1581 de 2012). Anyone who does not authorize it tells the instructor before delivering.

Autorización de datos: al marcar la casilla, el integrante confirma sus datos y autoriza publicar su nombre, número de documento y ficha en este repositorio público, para el trámite de registro de software (Ley 1581 de 2012). Quien no lo autorice se lo informa al instructor antes de entregar.

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
| [`08-manuals/`](08-manuals/) | Manuals / Manuales | Partial: technical and deployment manuals are present; user manual revision 1.1 is aligned across Markdown, DOCX, and PDF, and the ten-page PDF was visually reviewed. Six real screenshots remain pending across five blocks. Block 4 requires Home and live QA Monitoring; the others cover login, app Monitoring, synthetic History, and the admin inventory/user form. |
| [`09-project-article/`](09-project-article/) | Project article / Artículo del proyecto | Partial: ACM 6 pp, IEEE 7 pp and APA 7 21 pp compared; the team still must choose the final style and confirm the editable source for those team-article PDFs. A separate individual security manuscript in the adjacent `Somguard` workspace is not their source or a substitute. |
| [`10-videos/`](10-videos/) | Videos / Videos | Partial: pitch (1:19) and tutorial (3:38) play without sign-in. The pitch mentions long trips/cargo transport but lacks a clear differentiator and CTA; two claims in illustrative screens need product verification. The public tutorial shows potentially identifiable names, faces, filled access fields, event/device details and logs; confirm they are synthetic or authorized before public submission. |
| [`code-tag/`](code-tag/) | Repository links, tags and ZIP files / Enlaces, tags y ZIP | 12 ZIPs verified locally against the manifest and tagged trees; Release links and instructor access verification remain pending. |
| [`team-roster.md`](team-roster.md) | Team and roles / Equipo y roles | Team role and contribution details still need confirmation; the personal-data publication authorizations remain unchecked. |
| [`software-registration.md`](software-registration.md) | Software registration data / Datos para registro de software | Applicant and representation details, creation year, several declarations, and readiness of the three attachment categories need confirmation. The third-party component list is present as a draft and still needs team verification. |

A document being present does not mean it has been approved or fully validated. The status above records current evidence and open work; all external publication remains pending review.
## Large files on Google Drive / Archivos pesados en Google Drive

Only files too heavy for GitHub go here, such as demo videos. Everything else stays in this folder.

Aquí solo van archivos demasiado pesados para GitHub, como videos de demostración. Todo lo demás vive en esta carpeta.

| File / Archivo | Size / Tamaño | Link / Enlace |
|---|---|---|
| Pitch publicitario (`video-publicitario.mp4`) | 8,974,448 bytes | [Abrir en Drive](https://drive.google.com/file/d/1Mqo-R2HJLbO1hgdx-M8pdhNxHzLNB-OE/view?usp=drivesdk) - 1:19; reproducción completa sin sesión. Revisar diferenciador, CTA y dos afirmaciones de función no verificadas en el código/documentación. |
| Tutorial de uso (`tutirual-uso.mp4`) | 25,300,457 bytes | [Abrir en Drive](https://drive.google.com/file/d/1NZHFwlfdvIojKzKitcW4re_j_22_LZZG/view?usp=drivesdk) - 3:38; reproducción completa sin sesión. Confirmar que nombres, rostros, acceso, eventos, dispositivo y logs sean de prueba o estén autorizados; el video todavía es público. |

\n
