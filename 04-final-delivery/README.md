# Final Delivery / Entrega Final: ADSO 3145555

Final evidence of the training projects. Every project delivers 100% of its work here, with enough quality to go to software registration.

Evidencia final de los proyectos formativos. Cada proyecto entrega aquí el 100 % de su trabajo, con la calidad necesaria para ir a registro de software.

The goal is to request registration before the Dirección Nacional de Derecho de Autor, for the apprentices team and the instructors team that supported the project or are cross-cutting to it. The delivery is part of the completion of the technologist taught stage, with the training project and the Developers & Geeks research seedbed.

El propósito es solicitar el registro ante la Dirección Nacional de Derecho de Autor, a nombre del equipo de aprendices y del equipo de instructores que apoyaron el proyecto o son transversales a su consecución. La entrega se ampara en el proceso de finalización de la etapa lectiva del tecnólogo, con el proyecto formativo, y en el semillero de investigación Developers & Geeks.

**Deadline / Fecha límite:** 04 / 11 / 2026, 23:59 (Colombia)

Read the [delivery guide and presentation](00-delivery-guide/). / Lea la [guía de entrega y la presentación](00-delivery-guide/).

## English

### What each project delivers

| Item | Where |
|---|---|
| General information and team members | `<project>/README.md` |
| Requirements specification | `<project>/01-requirements-specification/` |
| Software analysis | `<project>/02-software-analysis/` |
| Technical proposal | `<project>/03-technical-proposal/` |
| Software design | `<project>/04-software-design/` |
| Test documentation | `<project>/05-test-documentation/` |
| Implementation procedure | `<project>/06-implementation-procedure/` |
| Improvement actions | `<project>/07-improvement-actions/` |
| Manuals | `<project>/08-manuals/` |
| Project article | `<project>/09-project-article/` |
| Videos | `<project>/10-videos/` |
| Links to every repository, tags and ZIP files | `<project>/code-tag/README.md` |
| Team and roles | `<project>/team-roster.md` |
| Software registration data | `<project>/software-registration.md` |

### Delivery rules

1. One member per project uploads everything, from their fork, through a Pull Request to `main`.
2. Only touch your own project folder.
3. Everything lives here. Only very heavy files, such as videos, go to Drive, with their link in the project `README.md`.
4. ZIP files go to a GitHub Release in your fork, never in the Pull Request.
5. Never upload passwords, tokens, keys or `.env` files. If one was ever committed, change it: deleting the file does not remove it from history.
6. Every original working repository must be public and listed in `code-tag/README.md`. The instructor compares the delivery against those repositories.
7. Two videos are required, an advertising pitch and a short usage tutorial, linked in `10-videos/README.md`.
8. Give the instructor account `ariel5253` write access to every original repository.

### Steps

Before tagging, bring all finished work into `main` in every repository, remove secrets and make every repository public.

Tag each repository:

```powershell
git checkout main
git pull origin main
git tag -a final-delivery-2026 -m "Final delivery ADSO 3145555"
git push origin final-delivery-2026
```

Create both ZIP files for each repository:

```powershell
$url  = "https://github.com/ORG/REPO.git"
$name = "REPO"
git clone --mirror $url "$name.git"
git -C "$name.git" archive --format=zip --prefix="$name-final-delivery-2026/" -o "..\$name-final-delivery-2026-main.zip" final-delivery-2026
Compress-Archive -Path "$name.git" -DestinationPath "$name-full-export.zip"
Get-FileHash "$name-final-delivery-2026-main.zip","$name-full-export.zip" -Algorithm SHA256
```

Then:

1. In your fork, go to **Releases**, then **Draft a new release**. Use the tag `final-delivery` and attach all the ZIP files.
2. Complete the tables in `code-tag/README.md` and `code-tag/SHA256SUMS.txt`.
3. Open a Pull Request from your fork to `main` of `code-sena/ADSO-3145555`, titled `Final delivery: <project>`.

## Español

### Qué entrega cada proyecto

| Ítem | Dónde |
|---|---|
| Información general e integrantes | `<proyecto>/README.md` |
| Especificación de requisitos | `<proyecto>/01-requirements-specification/` |
| Análisis del software | `<proyecto>/02-software-analysis/` |
| Propuesta técnica | `<proyecto>/03-technical-proposal/` |
| Diseño del software | `<proyecto>/04-software-design/` |
| Documentación de pruebas | `<proyecto>/05-test-documentation/` |
| Procedimiento de implementación | `<proyecto>/06-implementation-procedure/` |
| Acciones de mejoramiento | `<proyecto>/07-improvement-actions/` |
| Manuales | `<proyecto>/08-manuals/` |
| Artículo del proyecto | `<proyecto>/09-project-article/` |
| Videos | `<proyecto>/10-videos/` |
| Enlaces a todos los repositorios, tags y ZIP | `<proyecto>/code-tag/README.md` |
| Equipo y roles | `<proyecto>/team-roster.md` |
| Datos para registro de software | `<proyecto>/software-registration.md` |

### Reglas de entrega

1. Un integrante por proyecto sube todo, desde su fork, con un Pull Request a `main`.
2. Solo modifique la carpeta de su proyecto.
3. Todo vive aquí. Solo los archivos muy pesados, como videos, van a Drive, con su enlace en el `README.md` del proyecto.
4. Los ZIP van a un Release de GitHub en su fork, nunca en el Pull Request.
5. Nunca suba contraseñas, tokens, llaves ni archivos `.env`. Si alguno se subió alguna vez, cámbielo: borrar el archivo no lo saca del historial.
6. Todos los repositorios originales de trabajo deben ser públicos y estar en `code-tag/README.md`. El instructor contrasta la entrega contra esos repositorios.
7. Se requieren dos videos, un pitch publicitario y un tutorial corto de uso, enlazados en `10-videos/README.md`.
8. Dé a la cuenta del instructor, `ariel5253`, acceso de escritura en cada repositorio original.

### Pasos

Antes del tag, pase a `main` todo el trabajo terminado en cada repositorio, quite los secretos y haga público cada repositorio. Los comandos de tag y ZIP son los de la sección en inglés; reemplace `ORG` y `REPO` por los de cada repositorio.

Después:

1. En su fork, entre a **Releases** y luego a **Draft a new release**. Use el tag `final-delivery` y adjunte todos los ZIP.
2. Complete las tablas de `code-tag/README.md` y `code-tag/SHA256SUMS.txt`.
3. Abra un Pull Request desde su fork hacia `main` de `code-sena/ADSO-3145555`, con el título `Final delivery: <proyecto>`.

## Projects / Proyectos

| # | Project / Proyecto | Delivered / Entregado |
|---|---|---|
| 01 | [Drivique](01-drivique/) | ☐ |
| 02 | [SmartHome](02-smarthome/) | ☐ |
| 03 | [Guardián Escolar](03-guardian-escolar/) | ☐ |
| 04 | [FaceLit](04-facelit/) | ☐ |
| 05 | [Lava Rápido Vehicular](05-lava-rapido/) | ☐ |
| 06 | [One Language](06-one-language/) | ☐ |
| 07 | [Hidro Smart](07-hidro-smart/) | ☐ |
| 08 | [SomnGuard](08-somnguard/) | ☐ |
| 09 | [SaborExpress](09-saborexpress/) | ☐ |
| 10 | [SRD](10-srd/) | ☐ |
| 11 | [Alerta Mujer](11-alerta-mujer/) | ☐ |
| 12 | [EcoRuteando](12-ecoruteando/) | ☐ |

## Software registration / Registro de software

The base templates are [`SOFTWARE-REGISTRATION-TEMPLATE.md`](SOFTWARE-REGISTRATION-TEMPLATE.md) and [`TEAM-ROSTER-TEMPLATE.md`](TEAM-ROSTER-TEMPLATE.md). Each project completes its own `software-registration.md` and `team-roster.md`.

Las plantillas base son [`SOFTWARE-REGISTRATION-TEMPLATE.md`](SOFTWARE-REGISTRATION-TEMPLATE.md) y [`TEAM-ROSTER-TEMPLATE.md`](TEAM-ROSTER-TEMPLATE.md). Cada proyecto completa su propio `software-registration.md` y su `team-roster.md`.
