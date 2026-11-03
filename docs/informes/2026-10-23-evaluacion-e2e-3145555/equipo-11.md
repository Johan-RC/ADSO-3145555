# Equipo 11 · Alerta Mujer — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 69/100 · Juicio D**

## Veredicto

Alerta Mujer queda en 69,4 puntos con juicio D, a menos de un punto del umbral de 70. Cuatro de los cinco flujos principales funcionan de punta a punta (SOS con ubicacion, evidencia WebP, atencion administrativa con chat y panel de contactos), sobre una base Liquibase con rollbacks y roles de minimo privilegio. El quinto flujo, el registro de una usuaria nueva, esta roto: con la configuracion por defecto el simulador de telefono esta apagado y el unico camino de registro movil no se puede completar (hallazgo critico). Ademas hay un hallazgo bloqueante: una credencial de administrador en claro en las pruebas Playwright y en el historial del repositorio publico de Frontend, que debe rotarse primero. Para cerrar faltan tambien promover develop a main en los tres repositorios, bloqueo de intentos en el inicio de sesion, integracion continua y un ambiente desplegado, y poner al dia el contrato OpenAPI y la documentacion.

## Plan para cerrar las brechas

1. **Rotar de inmediato la clave del administrador expuesta y de cualquier cuenta que la reuse; sacar las credenciales de las pruebas Playwright (variables de entorno o archivo ignorado, usuario de prueba sintetico en entorno aislado); considerar reescribir el historial y retirar la credencial del README de la rama de la HU-020.** (esfuerzo S) — se cierra cuando: La clave anterior ya no inicia sesion; una busqueda de credenciales en el arbol y en el historial publicado no encuentra la clave ni el correo en claro; las pruebas leen su usuario de variables de entorno.
2. **Resolver el registro movil: integrar un proveedor real de SMS (o restituir la verificacion por correo), no devolver el codigo en la respuesta HTTP fuera de perfiles de prueba y documentar el simulador como solo demo.** (esfuerzo L) — se cierra cuando: Con IDENTITY_PHONE_SIMULATOR_ENABLED en false una usuaria nueva completa el registro desde la app movil; ninguna respuesta HTTP incluye simulatedPhoneCode; una prueba e2e cubre el camino con el simulador apagado.
3. **Promover el trabajo de develop a main en Backend, Database y Frontend con PR revisado, dejar main como rama estable y, desde ahora, trabajar con commits incrementales y PR con revision para que el historial refleje el desarrollo real.** (esfuerzo S) — se cierra cuando: main de los tres repos contiene el codigo evaluado (README real, fuentes y pruebas); cada fusion a main tiene al menos una revision aprobada visible y los commits nuevos de Frontend son incrementales (sin volcados de miles de lineas) con actividad en semanas consecutivas.
4. **Agregar bloqueo temporal y limite de intentos al inicio de sesion, y mover el refresh token de la web fuera de sessionStorage.** (esfuerzo M) — se cierra cuando: Tras N intentos fallidos el endpoint responde 429 o bloquea la cuenta por un tiempo, con prueba automatica; el refresh token de la web no esta en sessionStorage ni localStorage.
5. **Crear integracion continua en los cuatro repositorios (compilar, pruebas, lint) y hacer que las pruebas de integracion del backend fallen, no se omitan, cuando no hay base de datos.** (esfuerzo M) — se cierra cuando: Cada PR dispara un workflow que queda verde en el repositorio; las 14 pruebas de integracion corren contra una base de servicio en CI y su omision silenciosa ya no es posible.
6. **Desplegar un ambiente accesible, publicar una version etiquetada de la app y documentar plan de reversion, arranque del conjunto y publicacion de la web y el APK.** (esfuerzo L) — se cierra cuando: Existe una URL declarada que responde, una release etiquetada con el APK descargable y un procedimiento de reversion en el README; la clave del migrador ya no viaja como argumento de linea de comandos.
7. **Reemplazar la pagina simulada de descarga del APK por un enlace real a la release y eliminar el estado simulado y el codigo de cliente sin contraparte.** (esfuerzo M) — se cierra cuando: La pagina de descarga entrega el APK real sin depender de ?state=; no quedan datos de demostracion empaquetados en la web ni metodos de API sin uso.
8. **Corregir las FK en cascada hacia auditoria e historial de estados, agregar indices a las FK de tablas que crecen y validar el CHECK de 500 000 bytes.** (esfuerzo M) — se cierra cuando: Borrar una cuenta no elimina la auditoria ni el historial que firmo; las FK listadas tienen indice; el CHECK queda validado, todo en changesets con rollback.
9. **Regenerar o actualizar el contrato OpenAPI y la documentacion de datos y arquitectura contra el codigo de develop, y verificar el contrato automaticamente.** (esfuerzo M) — se cierra cuando: El OpenAPI incluye los endpoints que usa mobile, coincide con los controladores y una prueba o paso de CI falla si divergen; modelo y arquitectura describen el estado del 16-oct.
10. **Redactar la politica de proteccion de datos personales (Ley 1581) y completar KPI medibles y criterios de aceptacion y prioridad de las historias base.** (esfuerzo M) — se cierra cuando: Existe un documento de politica de datos en Docs enlazado desde el README; hay al menos 3 KPI con linea base y cada HU base tiene criterios de aceptacion y prioridad.
11. **Descomponer el AppStateProvider de 773 lineas y el IdentityOtpRepository de 587 lineas, agregar control automatico de limites entre modulos y pruebas de pantallas moviles y e2e portable.** (esfuerzo L) — se cierra cuando: Ningun contexto o repositorio de esos dos supera un tamano acordado por el equipo; una prueba de arquitectura falla ante importes de internos de otro modulo; las pruebas e2e corren con configuracion de entorno y hay pruebas de las pantallas moviles clave.
12. **Unificar la regla de inactividad, mapear errores HTTP de protocolo a su codigo correcto, mejorar la accesibilidad movil de la app de emergencia y mover los repositorios a una organizacion con respaldo.** (esfuerzo M) — se cierra cuando: Los umbrales de inactividad estan unificados y documentados; 405, 413 y 415 no devuelven 500; los controles de la app de emergencia tienen etiquetas de accesibilidad; los repos tienen al menos un segundo administrador u organizacion.

## Verificación independiente

Hallazgos confirmados: 5 · matizados: 1 · refutados: 0 · duplicados fusionados: 2.

Confirme H-01, H-02, H-03, H-04 y H-07 abriendo el codigo en los SHA evaluados; matice H-06 (existe con 773 lineas, pero la severidad justa es medio, no alto) y la lectura de H-01 (la credencial esta en 4 sitios del spec y en el historial, pero el spec esta desactualizado y no se puede probar que sea valida contra un despliegue). Refute T-14.1 como PASS: el registro es ROTO con la configuracion por defecto (simulador de telefono apagado), contradiciendo el 'COMPLETO' del especialista, asi que la fraccion de flujos completos baja a 4/5 y el valor a PARTIAL; R-5.1 (Backend), R-8.1 y R-6.1 quedan confirmados como PASS, los otros cuatro flujos son COMPLETO y los 111 commits de la unica integrante estan verificados con una sola identidad. Duplicados reales: H-12 con H-26 (se conserva H-26) y H-23 con H-35 (se conserva H-23); los demas pares son defectos distintos en el mismo archivo.

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Roto | Registro y verificación de una usuaria (phone-first v2) | Capas coherentes: mobile identityApi.ts:26-29 (POST /api/v2/registration-requests, verification-codes, verify, PUT credentials con X-Registration-Proof) coincide con PhoneFirstRegistrationController (mismo prefijo, cabecera y verbos) y con 004_add_phone_first_registration_flow.sql / 005_allow_phone_simulator_registration_otp.sql. Paso roto: start() llama requirePhoneSimulator() y, con IDENTITY_PHONE_SIMULATOR_ENABLED=false (valor por defecto en application.properties:20, .env.example:23 y docker-compose.yml:24), lanza RuleViolationException en la primera pantalla; no hay otro registro en el movil (identityApi.createRegistration v1 no lo llama ninguna pantalla) ni proveedor SMS. Solo funciona como demostracion con el simulador activo, donde el codigo viaja en la respuesta. El especialista dijo COMPLETO; yo lo bajo a ROTO en configuracion por defecto. |
| Completo | Activar un SOS, enviar ubicación y finalizarlo | — |
| Completo | Capturar y subir evidencia fotográfica WebP (máx. 500 000 bytes) | — |
| Completo | Atención administrativa de una alerta con chat en tiempo real | — |
| Completo | Panel interno de alertas para contactos aceptados | — |

## Hallazgos

### [Bloqueante] H-01 · Credencial de administrador en claro en las pruebas Playwright (y en el historial)
- **Repositorio:** `propietario/AlertaMujer_Frontend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `web/tests/web-flows.spec.ts:17`
- **Por qué importa:** Expone un secreto y el correo personal de un integrante en un repositorio publico: las pruebas no simulan la API (sin route.fulfill) y entran contra un backend real, de modo que la cuenta es de administracion con acceso a alertas, evidencias y datos de usuarias (criterio bloqueante de la rubrica: expone un secreto o datos de personas). Aparece en las lineas 16-17, 127-128, 249-250 y 309-310 del SHA; en el historial esta en el commit 4ccb3f5 (web/src/shared/data/WebStateContext.tsx:122-123 como verificacion de inicio de sesion en el cliente) y en el README de la rama origin/feat/hu-am-020-dev (web/README.md:31). La validez contra un despliegue real no se pudo comprobar.
- **Cómo cerrarlo (S):** Rotar de inmediato la clave de ese administrador y cualquier cuenta que la reuse; sacar las credenciales de las pruebas (leerlas de variables de entorno o de un archivo ignorado, y sembrar un usuario de prueba con datos sinteticos en un entorno aislado); como la clave seguira en el historial, tratarla como comprometida y, si el equipo quiere limpiar el historial, reescribirlo con filter-repo coordinado.

### [Crítico] H-02 · El unico registro movil exige el simulador de telefono: con la configuracion por defecto ninguna usuaria nueva puede registrarse
- **Repositorio:** `propietario/AlertaMujer_Frontend`
- **Lente SDLC OS:** A05 · **Verificación independiente:** confirmado
- **Evidencia:** `mobile/src/modules/identity/presentation/screens/RegisterStep1Screen.tsx:33`
- **Por qué importa:** RegisterStep1Screen llama solo a identityApi.startPhoneFirstRegistration (POST /api/v2/registration-requests). En el Backend start() empieza con requirePhoneSimulator() (propietario/AlertaMujer_Backend:src/main/java/com/alertamujer/backend/identity/service/impl/PhoneFirstRegistrationServiceImpl.java:75), que lanza RuleViolationException si IDENTITY_PHONE_SIMULATOR_ENABLED es false, el valor por defecto (propietario/AlertaMujer_Backend:.env.example y src/main/resources/application.properties:20). No hay proveedor SMS en pom.xml ni en src/main. Con el simulador activo el codigo viaja en la respuesta (simulatedPhoneCode, PhoneFirstRegistrationServiceImpl.java:106), asi que la verificacion del telefono no verifica nada. El flujo principal de registrarse e iniciar sesion solo funciona en un entorno de demostracion; en otro la usuaria no pasa de la primera pantalla.
- **Cómo cerrarlo (L):** Integrar un proveedor real de SMS o restituir la verificacion por correo como camino de registro; si el simulador se mantiene para demo, documentarlo como tal en README y en el flujo funcional de Docs, no devolver el codigo en la respuesta fuera de perfiles de prueba y cubrir el camino con simulador apagado en una prueba e2e.

### [Alto] H-03 · La pagina de descarga del APK es una simulacion: el estado lo decide el parametro ?state= y no existe un enlace real al APK
- **Repositorio:** `propietario/AlertaMujer_Frontend`
- **Lente SDLC OS:** A03 · **Verificación independiente:** confirmado
- **Evidencia:** `web/src/modules/public-site/PublicPages.tsx:320`
- **Por qué importa:** DownloadPage lee requested desde ?state=; por defecto muestra 'preparing' con un StatePanel de carga que nunca termina, y en 'available' el boton 'Descargar' esta deshabilitado (linea 373). No hay URL de artefacto ni build de Android configurable (no hay eas.json ni android.package en mobile/app.json). HU-AM-013 / RF14 'Sitio publico y APK' promete algo que el usuario no puede completar: es un callejon sin salida para la usuaria que llega desde la web.
- **Cómo cerrarlo (M):** Publicar el APK (GitHub Release o almacenamiento) y leer su URL/estado de una variable o endpoint; quitar el parametro de estado manipulable y mostrar un mensaje claro mientras no exista, con contacto alterno.

### [Alto] H-04 · La rama main de Backend, Database y Frontend es un README de una linea; todo el trabajo esta atrapado en develop
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado
- **Evidencia:** `propietario/AlertaMujer_Frontend:README.md y git rev-list --count origin/main..origin/develop (Backend 62, Database 59, Frontend 70)`
- **Por qué importa:** origin/main contiene un unico commit 'initial commit' (a328c27, 236f04a, 918e80a). Qa apunta al mismo commit que main y ninguno de los 90 PR tiene main como base. Quien abra el repositorio por defecto, o un evaluador, ve un proyecto vacio; no existe un flujo de promocion dev, qa, main (la propia Docs lo reconoce como GAP-01).
- **Cómo cerrarlo (S):** Abrir un PR de develop a main en cada repo y fijar main como rama de entrega, con develop como integracion; definir la promocion qa/main y proteger main.

### [Alto] H-05 · El historial de Frontend no refleja el desarrollo real: 13 commits de HU son esqueletos y la aplicacion entra en un commit de 14 406 lineas 'desde una implementacion de referencia'
- **Repositorio:** `propietario/AlertaMujer_Frontend`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `mobile/package-lock.json (commit 27d4e76: 14 archivos, 11297 inserciones); commit c24a9e8: 175 archivos, 14406 inserciones, 'synchronize frontend with reference implementation'`
- **Por qué importa:** Los commits HU-AM-001 a 013 declaran pantallas completas pero cambian de 2 a 8 lineas (por ejemplo mobile/app/auth/login.tsx queda en 2 lineas en 27d4e76 y e371cc9 'implement controlled SOS activation' toca 8 lineas). El codigo real de web y movil aparece en c24a9e8, etiquetado HU-AM-020, y la 'reference implementation' no esta en ningun repo declarado. No se puede rastrear HU a codigo ni saber que parte escribio el autor.
- **Cómo cerrarlo (S):** Documentar de donde viene la implementacion de referencia (herramienta, prototipo o repo) en el README o un ADR, y a partir de ahora commitear por HU con el cambio real; no reescribir el historial publicado, pero anotar en CHANGELOG que HU-AM-001 a 013 son andamiaje.

### [Alto] H-07 · El inicio de sesion no tiene bloqueo ni limite de intentos
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `src/main/java/com/alertamujer/backend/identity/service/impl/AuthenticationServiceImpl.java:73`
- **Por qué importa:** login() solo compara la clave y devuelve 401 (lineas 66-93): no cuenta intentos fallidos, no bloquea la cuenta y no limita por IP o por identificador; user_credentials no tiene columna de intentos y pom.xml no incluye ninguna libreria de limitacion. Los codigos OTP si tienen intentos maximos (IdentityOtpRepository.java:239-241), por lo que la brecha esta solo en la clave. En una app de seguridad personal, la fuerza bruta sobre cuentas, incluida la del administrador (ruta publica /api/v1/auth/login), es un riesgo explotable.
- **Cómo cerrarlo (M):** Registrar intentos fallidos por cuenta y por IP con ventana y bloqueo temporal (o un filtro de limitacion como Bucket4j), responder con un retraso uniforme y registrar el evento en la auditoria; anadir una prueba negativa de bloqueo.

### [Alto] H-08 · Ningun repositorio ejecuta integracion continua; el unico workflow se creo y se borro tras tres fallos
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/AlertaMujer_Backend/actions/runs total 0; propietario/AlertaMujer_Database commit 80fb51f elimina .github/workflows/database-release-validation.yml tras tres ejecuciones en failure`
- **Por qué importa:** Backend y Frontend no tienen .github en ninguna rama (0 ejecuciones en la API de Actions). Database creo .github/workflows/database-release-validation.yml en 1828854 (2026-10-02), tres ejecuciones fallaron el 2026-10-03 y el workflow se elimino en 80fb51f en lugar de corregirse; la propia documentacion lo reconoce (propietario/AlertaMujer_Docs:10-devops/ci-cd.md:4). Sin CI no hay pruebas en cada cambio ni evidencia automatica; las 126 a 138 pruebas verdes que reporta el equipo son afirmaciones locales. Tampoco hay proteccion de rama verificable (la consulta devuelve 404).
- **Cómo cerrarlo (M):** Crear un workflow por repositorio: Backend con mvn verify y PostgreSQL como servicio, Frontend con typecheck, lint y pruebas, Database restaurando el workflow corregido (el fallo se lee en los registros de las ejecuciones); exigirlos con proteccion de rama.

### [Alto] H-09 · No hay ambiente desplegado, version publicada ni plan de reversion de la aplicacion
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/AlertaMujer_Backend:docker-compose.yml:8 (imagen local); propietario/AlertaMujer_Docs:10-devops/environments.md:7-15`
- **Por qué importa:** No hay URL de despliegue, ni docker-compose de produccion, ni releases ni etiquetas; la imagen se etiqueta :local (docker-compose.yml:8). La base si tiene reversion por changeset (05_rollbacks espejo de cada changelog), pero para el backend y las apps no existe estrategia de rollback ni de promocion entre dev, QA y produccion; el equipo lo declara pendiente (GAP-01 en propietario/AlertaMujer_Docs:04-requirements/traceability-matrix.md). El sistema no se puede demostrar fuera de la maquina del equipo.
- **Cómo cerrarlo (L):** Definir un ambiente publico (aunque sea de QA), publicar imagenes versionadas por etiqueta en un registro, documentar y probar el despliegue y su reversion, y etiquetar cada entrega con su version.

### [Alto] H-10 · Borrar una cuenta arrastra la auditoría y el historial de estados que ella firmó
- **Repositorio:** `propietario/AlertaMujer_Database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/016_create_audit_logs_table.sql:20`
- **Por qué importa:** audit.audit_logs.actor_user_id y subject_user_id, y emergency_status_history.actor_user_id (011, línea 26), referencian identity.users con ON DELETE CASCADE. El backend ofrece borrado de cuenta propia (DELETE /me) y administrativo (DELETE /admin/users/{id}/deletion). Al borrar a una usuaria desaparecen las filas de auditoría donde ella fue sujeto. Además, el administrador reemplazado queda como USER deshabilitado (AdministrationRepository.java:157-163) y el nuevo administrador puede borrarlo: se pierden las acciones que firmó sobre alertas ajenas, incluidas filas del historial de estados de emergencias de otras personas. La auditoría que el código llama inmutable no lo es: no hay triggers (01_ddl/09_triggers vacío) que impidan el borrado en cascada.
- **Cómo cerrarlo (M):** Cambiar esas FK a ON DELETE SET NULL (las tres columnas ya admiten NULL) o conservar un identificador anonimizado; añadir una migración con su rollback y una prueba en scripts/test-release.ps1 que borre un usuario y compruebe que la auditoría y el historial sobreviven.

### [Alto] H-11 · El contrato OpenAPI publicado no coincide con lo que consume mobile ni con lo que expone el backend
- **Repositorio:** `propietario/AlertaMujer_Docs`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `07-api/contracts/openapi/openapi-alertamujer-v1.yaml:141`
- **Por qué importa:** El README del backend dice que el OpenAPI es la fuente de verdad. Pero (1) no hay ninguna mención de /api/v2 en todo el repositorio de Docs, y mobile hace el registro real por esas 4 operaciones (identityApi.ts:26-29); (2) el OpenAPI sigue publicando POST /me/device-tokens, retirado del backend; (3) declara after con mínimo 1 (línea 295) mientras mobile envía after=0 y el backend lo acepta. Quien implemente un cliente nuevo desde el contrato no puede registrar usuarias.
- **Cómo cerrarlo (S):** Actualizar el OpenAPI a la versión vigente: añadir los 4 paths v2 con la cabecera X-Registration-Proof, quitar device-tokens, alinear el mínimo de after, y reflejar /api/v2 en la tabla de rutas del README del backend. Idealmente generar o validar el contrato contra el código (springdoc o prueba de contrato en CI).

### [Medio] H-06 · AppStateProvider.tsx de 773 lineas es un unico contexto que concentra sesion, perfil, contactos, emergencia, historial y permisos
- **Repositorio:** `propietario/AlertaMujer_Frontend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** matizado (severidad ajustada de alto)
- **Evidencia:** `mobile/src/shell/providers/AppStateProvider.tsx:193`
- **Por qué importa:** Un componente de unas 580 lineas con unos 50 hooks y 28 acciones expuestas por un solo useMemo (linea 700) hace que cualquier cambio de estado re-renderice toda la app y vuelve casi imposible probar o modificar un flujo aislado. Supera el limite de 300 lineas y la regla de un hook o contexto por responsabilidad del skill senior-frontend. Hay 7 catch que tragan el error (lineas 345, 465, 473) y un comentario de encabezado que habla de 'prototipos heredados'.
- **Cómo cerrarlo (L):** Partirlo en SessionProvider, ContactsProvider, EmergencyProvider y useDeviceRequirements, con hooks por modulo; reemplazar los catch silenciosos por estado de error visible.

### [Medio] H-13 · La documentacion esta atrasada respecto al codigo del 16-oct y el contrato OpenAPI no cubre el flujo que usa Mobile
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/AlertaMujer_Docs:README.md:9; propietario/AlertaMujer_Docs:07-api/contracts/openapi/openapi-alertamujer-v1.yaml:141; propietario/AlertaMujer_Docs:08-uml/diagram-index.md:16`
- **Por qué importa:** Docs (ultimo commit 15-oct) afirma que HU-API-020 a 022 estan 'propuestas', pero Backend las integro el 15-oct (PR 24 a 26); no hay HU-AM-032, HU-API-023 ni HU-DB-028 (registro por telefono, administrador inicial) aunque existen sus ramas y PR; el OpenAPI aun declara /me/device-tokens (FCM retirado por HU-API-021) y no tiene /api/v2/registration-requests; los catalogos dicen 31 HU-AM, 22 HU-API y 27 HU-DB cuando hay 32, 23 y 28. Un tercero que lea Docs no entiende como se registra una usuaria hoy.
- **Cómo cerrarlo (M):** Actualizar README, user-stories, OpenAPI y diagram-index con el corte del 16-oct y agregar a scripts/validate-docs.ps1 una comprobacion de rutas contra los controladores del Backend.

### [Medio] H-14 · No hay indicadores de exito medibles ni linea base: el producto no declara cuando se considera logrado
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/AlertaMujer_Docs:03-product/problem-framing.md:34`
- **Por qué importa:** El problema, los actores y la vision estan bien planteados, pero 'Metricas cuantitativas de tiempo/exito' esta en 'En refinamiento', los objetivos OBJ-01 a 06 de 03-product/vision.md no tienen meta numerica y RNF3 dice 'UI responde de inmediato' sin umbral. El criterio del rol A05 exige al menos 3 KPI con formula, linea base y meta. Sin ellos no se puede decidir si el SOS es suficientemente rapido ni evaluar el producto.
- **Cómo cerrarlo (S):** Definir 3 o mas KPI (por ejemplo tiempo de SOS a emergencia confirmada, porcentaje de alertas con ubicacion, tiempo de atencion administrativa) con formula, meta y como se mide.

### [Medio] H-15 · Las historias base no tienen criterios de aceptacion ni prioridad; solo las 9 HU recientes los tienen
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/AlertaMujer_Docs:04-requirements/frontend-stories.md:11`
- **Por qué importa:** HU-AM-001 a 027, HU-API-001 a 019 y HU-DB-001 a 025 son filas de catalogo (Id, resultado, cliente, dependencia) sin Dado/Cuando/Entonces ni prioridad MoSCoW; solo los hu-*.md de 04-requirements (HU-AM-028 a 031, HU-API-020 a 022, HU-DB-026 y 027) traen escenarios Gherkin. No se puede verificar a posteriori que el registro, el SOS o la atencion administrativa cumplan lo pedido, y el Must de la entrega no esta definido.
- **Cómo cerrarlo (M):** Agregar al menos 2 criterios de aceptacion y una prioridad a las HU de los flujos de registro, SOS, chat/evidencia y atencion administrativa, y enlazarlas a la pantalla o endpoint.

### [Medio] H-16 · Sin issues ni tablero, y los 90 PR se fusionan solos sin revision
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/AlertaMujer_Frontend/issues?state=all: 0; pulls/33/reviews: 0`
- **Por qué importa:** Los 4 repos tienen 0 issues y 0 proyectos; Backend (28), Database (29) y Frontend (33) tienen un PR por HU, todos aprobados y fusionados por el propio autor a develop en minutos, sin revision ni proteccion de rama visible; Docs hace commit directo a main. En un equipo de una persona falta un revisor externo, pero el instructor podria hacerlo.
- **Cómo cerrarlo (S):** Crear issues por HU enlazados al PR, un tablero simple y pedir revision del instructor o de un companero antes de fusionar a main.

### [Medio] H-17 · Actividad concentrada en 4 de 8 semanas y sin commits en los ultimos 6 dias
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `datos-git.json equipo 11: semanas activas W39, W40, W41, W42; git log --all --no-merges`
- **Por qué importa:** Sin commits entre el 27-ago y el 21-sep ni del 17 al 22-oct en ningun repo; 111 commits en 25 dias. El proyecto avanzo en rafagas (23 commits de Frontend en un dia, 29 de Backend en una semana) y quedo detenido con HU-AM-032 como ultima entrega y las pruebas web en 3 de 10.
- **Cómo cerrarlo (S):** Retomar con una cadencia semanal y reservar las ultimas semanas a cerrar los hallazgos de este informe.

### [Medio] H-18 · La verificación del teléfono es una simulación: sin ella el registro no funciona y con ella el código viaja en la respuesta
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/alertamujer/backend/identity/service/impl/PhoneFirstRegistrationServiceImpl.java:271`
- **Por qué importa:** El único camino de registro que usa mobile (v2) exige identity.phone-simulator.enabled=true; con el valor por defecto false responde 422 (línea 272). Con la bandera activa la API devuelve el código OTP en el campo simulatedPhoneCode (PhoneFirstRegistrationResponse y RegistrationStageResponse), así que el teléfono no queda realmente verificado. No existe proveedor de SMS. Un despliegue real no puede registrar usuarias con seguridad.
- **Cómo cerrarlo (L):** Declarar explícitamente en README y OpenAPI que es una simulación académica con fecha de retiro, o integrar un proveedor de SMS detrás de la misma interfaz y dejar el simulador solo para perfiles de prueba; que el campo simulatedPhoneCode nunca se emita fuera de ese perfil.

### [Medio] H-19 · No hay forma documentada de arrancar el conjunto ni de publicar la web y el APK
- **Repositorio:** `propietario/AlertaMujer_Frontend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:10`
- **Por qué importa:** El README raiz manda a 'npm install; npm run dev' sin pedir .env (la web lanza CONFIGURATION_ERROR sin VITE_API_BASE_URL, web/src/shared/api/client.ts:31), mobile/.env.example omite EXPO_PUBLIC_AUTHORITY_PHONE (mobile/src/core/config/appConfig.ts:12), mobile/README.md dice 'core/ Integracion futura', no hay Node declarado, ni Dockerfile/hosting para la web, ni eas.json ni android.package para generar el APK. Un tercero no puede levantar ni entregar el frontend con lo que hay en el repo.
- **Cómo cerrarlo (S):** Agregar en el README raiz el orden Database, Backend, Frontend, los .env.example completos, la version de Node (engines o .nvmrc) y un procedimiento de build para web y APK.

### [Medio] H-20 · Los módulos del backend se importan los internos y no hay control automático de límites
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/alertamujer/backend/contacts/service/impl/ContactAlertServiceImpl.java:10`
- **Por qué importa:** La regla documentada es 'de módulo a módulo solo por interfaz pública; no import de internals'. El código la incumple: contacts importa evidence.storage.EvidenceStorage, administration importa los records EmergencyRepository.EmergencyData y ProfileRepository.UserProfileData (AdministrationRepository.java:3 y :5) y AdministrationServiceImpl usa servicios de identity y emergency. No hay ArchUnit ni prueba equivalente (git grep archunit sin resultados), de modo que la regla se erosiona sin aviso.
- **Cómo cerrarlo (M):** Definir una interfaz pública por módulo (paquete api o facade) para lo que otros módulos necesitan y añadir una prueba ArchUnit que falle con las dependencias prohibidas, como pide boundary-enforcement.md.

### [Medio] H-21 · Regla de inactividad con umbrales distintos y sin documentar
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/alertamujer/backend/administration/service/impl/AdministrationServiceImpl.java:179`
- **Por qué importa:** El trabajo programado deshabilita a los 3 meses de inactividad (AdministrationServiceImpl.java:153, comentario en InactiveAccountScheduler que la llama 'documentada') y la acción manual del administrador exige solo 2 meses (línea 179). No hay ninguna mención en el repositorio de Docs (git grep inactiv sin resultados). Son dos umbrales sin fuente documentada ni un valor único configurable.
- **Cómo cerrarlo (S):** Documentar la regla en 02-domain/entities-and-rules.md y el OpenAPI con un único valor configurable (system_configuration) y usarlo en ambos lugares con una prueba.

### [Medio] H-22 · La documentación de datos y arquitectura describe un sistema anterior al código evaluado
- **Repositorio:** `propietario/AlertaMujer_Docs`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `06-data/models.md:8`
- **Por qué importa:** models.md afirma 16 entidades y deja como Pendiente HU-DB-026 y HU-DB-027, pero ambas están aplicadas en develop de Database (03_dcl/03_retirements, 04_alter/003): quedan 14 entidades y límite de 500 000 bytes. boundary-enforcement.md dice que el Backend no tiene control porque 'no existe código' y 13-operations/project-status-2026-10-13.md afirma que app.json fue movido a web y que mobile envía JPEG/PNG, pero mobile/app.json existe y webpEvidence.ts convierte a WebP. El archivo ADR-007-webp-evidence-up-to-10mb.md habla de 500 KB en su cuerpo. Un revisor nuevo no sabe qué es verdad.
- **Cómo cerrarlo (S):** Sincronizar Docs main con develop: actualizar models.md (14 entidades, esquema notification retirado), boundary-enforcement.md, la matriz de trazabilidad (GAP-01 a GAP-06 resueltos o vigentes) y el estado técnico; renombrar el archivo del ADR-007. Añadir a la definición de terminado de cada HU 'documentación actualizada'.

### [Medio] H-23 · Estado simulado y datos de demostracion muertos siguen empaquetados en la web
- **Repositorio:** `propietario/AlertaMujer_Frontend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-35
- **Evidencia:** `web/src/shared/data/WebStateContext.tsx:3`
- **Por qué importa:** WebStateContext importa mockData.ts (293 lineas, usuarias y alertas ficticias) y define alerts, users, audit y las acciones startAttention, sendMessage, retryMessage, createUser, changeUserStatus (desde la linea 164); ningun componente las usa porque AlertsList, UsersList y AuditPage ya consumen la API. El codigo muerto incluye el nombre de una persona real como actor de auditoria simulada y 3 fotos de 945 KB. Confunde a quien lea el codigo y se publica en el bundle.
- **Cómo cerrarlo (S):** Eliminar mockData.ts, las acciones simuladas y los JPG de demostracion; dejar WebStateContext solo con sesion y filtros.

### [Medio] H-24 · El simulador de telefono devuelve el codigo en la respuesta HTTP y es el unico camino del registro v2
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/alertamujer/backend/identity/dto/response/OtpIssuedResponse.java:9`
- **Por qué importa:** Con IDENTITY_PHONE_SIMULATOR_ENABLED activo (application.properties:20) el servidor devuelve el codigo de verificacion al propio solicitante (RegistrationStageResponse.java:6), lo que elimina la prueba de posesion del telefono; con la bandera apagada, el registro v2 no funciona (PhoneFirstRegistrationServiceImpl.java:271-272). Ambos extremos dejan un flujo declarado sin una verificacion de telefono real. La bandera esta apagada por defecto, de modo que no se explota en el estado entregado.
- **Cómo cerrarlo (M):** No permitir la bandera en un perfil de produccion (fallar al arrancar si esta activa fuera de local o test), integrar un proveedor de SMS real o retirar el paso del telefono del registro; documentar el simulador como solo de desarrollo.

### [Medio] H-25 · No hay politica de proteccion de datos personales conforme a la Ley 1581 en ningun repositorio
- **Repositorio:** `propietario/AlertaMujer_Docs`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `00-governance/security-policy.md`
- **Por qué importa:** El sistema trata ubicacion en tiempo real, imagenes de evidencia, chat y datos de contacto de mujeres en situacion de riesgo, pero ninguno de los cuatro repositorios menciona la Ley 1581, la finalidad del tratamiento, el responsable, el canal para ejercer derechos ni la retencion de ubicacion, evidencia y chat. Existen mecanismos tecnicos (terminos aceptados, eliminacion de cuenta), pero no la base de cumplimiento; la evidencia se guarda en disco local (05-architecture/decisions/records/ADR-005-local-evidence-files.md) sin cifrado en reposo documentado.
- **Cómo cerrarlo (M):** Redactar una politica de tratamiento de datos (finalidad, responsable, derechos ARCO, retencion y borrado de ubicacion y evidencia, autorizacion explicita), enlazarla desde la aceptacion de terminos y evaluar cifrado en reposo del volumen de evidencia.

### [Medio] H-26 · El refresh token de la web de administracion se guarda en sessionStorage
- **Repositorio:** `propietario/AlertaMujer_Frontend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-12
- **Evidencia:** `web/src/shared/data/WebStateContext.tsx:73`
- **Por qué importa:** El token de renovacion del administrador queda en sessionStorage (escritura en la linea 73, lectura en la 91) y es legible por cualquier script de la pagina (XSS). El movil lo guarda bien en el almacen seguro del sistema (mobile/src/core/api/tokenStorage.ts:3) y el README web lo presenta como decision consciente. La cuenta afectada es la de mas privilegios.
- **Cómo cerrarlo (M):** Mover el token de renovacion a una cookie HttpOnly, Secure y SameSite emitida por el backend (con proteccion CSRF), o acortar su vida y atarlo al dispositivo; mantener el access token solo en memoria.

### [Medio] H-27 · Las 14 pruebas de integracion se omiten sin avisar cuando no hay base de datos
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/test/java/com/alertamujer/backend/InternalJobsPostgreSqlIntegrationTest.java:35`
- **Por qué importa:** Las 14 clases *IntegrationTest usan Assumptions.assumeTrue sobre variables de entorno de la base: sin ellas el build verde las salta y nadie lo ve. spring-boot-testcontainers y testcontainers-postgresql estan declarados (pom.xml:117-127) pero ninguna prueba los usa. Con la brecha de CI (H-B03), la garantia de que el contrato SQL y los grants funcionan depende de que un integrante recuerde correr scripts/verify-integration.ps1.
- **Cómo cerrarlo (M):** Levantar PostgreSQL con Testcontainers (aplicando las migraciones del repo Database) para que mvn verify sea autosuficiente, o hacer que la omision falle el build en CI; reportar el conteo de omitidas.

### [Medio] H-28 · El contrato OpenAPI es manual y no se verifica contra el codigo
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:288`
- **Por qué importa:** El README declara el contrato OpenAPI como fuente (README.md:288) y la estrategia de pruebas promete una capa de contrato (propietario/AlertaMujer_Docs:11-quality/testing-strategy.md), pero el backend no genera ni valida la especificacion (sin springdoc ni prueba de contrato en pom.xml o src/test); el YAML vive en el repositorio de documentacion (propietario/AlertaMujer_Docs:07-api/contracts/openapi/openapi-alertamujer-v1.yaml). Cualquier desvio entre rutas, campos o codigos de estado pasaria sin aviso. SharedHttpContractTest cubre el formato de error, no el contrato.
- **Cómo cerrarlo (M):** Anadir una prueba que cargue el YAML y compare rutas, metodos y esquemas con los endpoints reales (o generar la especificacion desde el codigo) y ejecutarla en CI.

### [Medio] H-29 · El e2e de la web no es portable y las pantallas del movil no tienen pruebas
- **Repositorio:** `propietario/AlertaMujer_Frontend`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web/playwright.config.ts:19`
- **Por qué importa:** playwright.config.ts fija la ruta de Chrome de Windows (linea 19), no simula la API y exige un backend sembrado con la cuenta de administrador; en Linux o en CI no corre. En el movil las cinco pruebas cubren funciones puras (mobile/test/evidenceLimits.test.ts, mobile/test/contactAlerts.test.ts) pero no hay pruebas de pantallas, del cliente de API ni del flujo de sesion.
- **Cómo cerrarlo (M):** Usar el Chromium que instala Playwright, arrancar un backend de prueba (compose con la Database migrada) o simular la API de forma declarada, y anadir pruebas de componentes y del cliente de API en el movil.

### [Medio] H-30 · Claves foráneas sin índice propio en tablas que crecen
- **Repositorio:** `propietario/AlertaMujer_Database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/014_create_emergency_chat_messages_table.sql:22`
- **Por qué importa:** Sin índice que empiece por la columna: emergency_chat_messages.sender_user_id, audit_logs.actor_user_id y subject_user_id, emergency_status_history.actor_user_id. Con ON DELETE CASCADE hacia users, cada borrado de cuenta recorre completas esas tablas, que son las de mayor crecimiento (mensajes, auditoría, historial). Las listas de 01_ddl/10_indexes no los incluyen.
- **Cómo cerrarlo (S):** Crear los índices (uno por FK) en una migración nueva con rollback, citando el patrón de consulta que justifican (borrado de cuenta y filtro de auditoría por actor).

### [Medio] H-31 · Errores de protocolo HTTP se devuelven como 500 por el manejador comodín
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/alertamujer/backend/shared/errors/GlobalExceptionHandler.java:86`
- **Por qué importa:** GlobalExceptionHandler declara @ExceptionHandler(Exception.class) y solo maneja de forma específica validación, cuerpo ilegible y las excepciones propias. Una petición con verbo no permitido, tipo de contenido no soportado, falta de la parte file del multipart o un archivo sobre el tope de 650 KB (application.properties) cae en el comodín y responde 500 INTERNAL_ERROR, además de registrar un error. Para el cliente un error suyo parece una falla del servidor. Ninguna prueba cubre 405, 413 ni 415 (git grep sin resultados en src/test).
- **Cómo cerrarlo (S):** Extender el manejador (o heredar de ResponseEntityExceptionHandler) con HttpRequestMethodNotSupportedException a 405, HttpMediaTypeNotSupportedException a 415, MaxUploadSizeExceededException a 413 y MissingServletRequestPartException a 400, con el mismo ApiError, y añadir una prueba por caso.

### [Bajo] H-32 · Accesibilidad movil escasa para una app de emergencia
- **Repositorio:** `propietario/AlertaMujer_Frontend`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `mobile/src/modules/emergency/presentation/screens/HomeEmergencyScreen.tsx:254`
- **Por qué importa:** Solo 24 props de accesibilidad en 14 archivos de unas 45 pantallas y componentes; el boton SOS si tiene etiqueta y estado, pero formularios, tarjetas de contacto e historial dependen de texto sin roles. Para usuarias en situacion de estres o con lector de pantalla es el flujo mas importante.
- **Cómo cerrarlo (S):** Agregar accessibilityRole, label y hint a los controles de contactos, evidencia e historial y probar con TalkBack.

### [Bajo] H-33 · Los 4 repos viven en una cuenta personal sin organizacion ni respaldo visible
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api users/Integrante 1: type User; collaborators: 403`
- **Por qué importa:** El codigo depende de una sola cuenta personal; si se pierde el acceso se pierde el proyecto. No se pudo ver si el instructor u otra persona es colaboradora.
- **Cómo cerrarlo (S):** Transferir los repos a una organizacion del programa o agregar al instructor como colaborador con permiso de administracion.

### [Bajo] H-34 · POST /api/v1/admin/users existe en backend y OpenAPI pero ninguna pantalla lo usa
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/alertamujer/backend/identity/controller/RegistrationRequestController.java:33`
- **Por qué importa:** La web administrativa solo lista, consulta, cambia estado y elimina usuarias (adminUsersApi.ts) y no hay HU que pida el alta administrativa desde el panel; la ruta y su servicio startAdministrativeRegistration quedan sin cliente. Es superficie de ataque y mantenimiento sin uso demostrado.
- **Cómo cerrarlo (S):** Decidir: construir la pantalla de alta administrativa (y su HU) o retirar la ruta hasta que exista.

### [Bajo] H-36 · IdentityOtpRepository concentra 587 lineas y 28 metodos de cuatro responsabilidades
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/alertamujer/backend/identity/repository/IdentityOtpRepository.java:21`
- **Por qué importa:** Mezcla solicitudes de registro, usuarios, codigos OTP y purgas programadas en una sola clase; el resto del backend esta bien dividido (maximo 290 lineas). Tambien hay 37 .gitkeep en carpetas ya pobladas y CORS con 4 URLs localhost por defecto (shared/security/SecurityConfiguration.java:84).
- **Cómo cerrarlo (M):** Separar RegistrationRequestRepository, VerificationCodeRepository y un job de purga; borrar los .gitkeep sobrantes.

### [Bajo] H-37 · Valores de OTP laxos en la semilla: vigencia de 180 minutos y espera de reenvio de 300 minutos
- **Repositorio:** `propietario/AlertaMujer_Database`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `02_dml/00_inserts/001_seed_system_configuration.sql:25`
- **Por qué importa:** La semilla fija la vigencia del OTP en 180 minutos y la espera de reenvio en 300 (el script de release los vuelve a exigir en scripts/test-release.ps1:185). Un codigo valido tres horas aumenta la ventana para interceptarlo o adivinarlo (5 intentos, 3 reenvios), y 300 minutos de espera entre reenvios parece un valor en segundos mal expresado en minutos; la inconsistencia no se pudo confirmar sin ejecutar.
- **Cómo cerrarlo (S):** Revisar las unidades y reducir la vigencia a minutos tipicos (5 a 15) con un limite por destino y por IP.

### [Bajo] H-38 · La clave del migrador viaja como argumento de linea de comandos y no hay etiquetas de release
- **Repositorio:** `propietario/AlertaMujer_Database`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker-compose.yml:72`
- **Por qué importa:** Liquibase recibe la clave del migrador como argumento en el entrypoint (docker-compose.yml:72), visible en la lista de procesos del host; y el changelog de etiquetas esta vacio (04_tcl/02_release_tags/0000changelog.yaml:1), aunque scripts/test-release.ps1 exige un ReleaseTag, por lo que ninguna version de esquema queda marcada en la base.
- **Cómo cerrarlo (S):** Pasar la clave por variable de entorno de Liquibase y registrar una etiqueta de release por version con tagDatabase.

### [Bajo] H-39 · El CHECK de 500 000 bytes se creó NOT VALID y nunca se valida
- **Repositorio:** `propietario/AlertaMujer_Database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/04_alter/003_reduce_evidence_metadata_size_limit.sql:5`
- **Por qué importa:** La restricción ck_emergency_evidences_file_size_bytes_range se recreó con NOT VALID y ningún changeset ejecuta VALIDATE CONSTRAINT (git grep sin resultados): las filas anteriores de hasta 1 MB quedan sin comprobar y la restricción aparece como no validada en el catálogo.
- **Cómo cerrarlo (S):** Añadir un changeset que revise las filas existentes y ejecute ALTER TABLE ... VALIDATE CONSTRAINT, con su rollback.

### [Bajo] H-40 · Nombres de tablas en plural frente al criterio de singular de la lente A13
- **Repositorio:** `propietario/AlertaMujer_Database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/003_create_users_table.sql`
- **Por qué importa:** El catálogo de datos de la lente del instructor exige singular (user, emergency_contact); el equipo eligió plural (users, emergencies) con dos excepciones singulares. La rúbrica solo pide coherencia y por eso el ítem R-8.3 pasa; se deja como observación de alineación con el marco.
- **Cómo cerrarlo (M):** Si el instructor exige el marco, planificar el renombre en una release mayor; si no, documentar el criterio de nombres en 06-data/database-conventions.md.

### [Bajo] H-41 · Convenciones REST con verbos y dos versiones de registro conviviendo
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/alertamujer/backend/administration/controller/AdministrationController.java:63`
- **Por qué importa:** DELETE /admin/users/{id}/deletion usa un sufijo verbal en lugar de DELETE sobre el recurso; coexisten registro v1 (con contraseña al inicio) y v2 (teléfono primero), ambos públicos en SecurityConfiguration, aunque mobile solo usa v2.
- **Cómo cerrarlo (S):** Normalizar a DELETE /admin/users/{id} en la próxima versión del contrato y marcar el registro v1 como obsoleto con fecha de retiro.

### [Bajo] H-42 · Dos records PageResponse idénticos
- **Repositorio:** `propietario/AlertaMujer_Backend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/alertamujer/backend/contacts/dto/response/PageResponse.java:6`
- **Por qué importa:** contacts/dto/response/PageResponse y shared/validation/PageResponse tienen la misma forma (items, page, size, total); ContactController usa el del módulo y el resto el compartido. Riesgo de divergencia del contrato de paginación.
- **Cómo cerrarlo (S):** Eliminar el duplicado y usar el compartido en ContactController y ContactService.

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 93.8 |
| D2 | Reproducibilidad | 83.3 |
| D3 | Arquitectura y congruencia | 66.7 |
| D4 | Calidad de código | 77.3 |
| D5 | Seguridad | 90.8 |
| D6 | Pruebas | 73.3 |
| D7 | DevOps y despliegue | 36.4 |
| D8 | Datos | 90.0 |
| D9 | API y contratos | 65.0 |
| D10 | Frontend y móvil | 77.8 |
| D11 | IoT y firmware | — |
| D12 | Documentación y trazabilidad | 53.7 |
| D13 | Proceso y colaboración | 34.4 |
| D14 | Extremo a extremo | 65.0 |

## Lo que está bien

- Los clientes mobile y web replican campo a campo los DTO del backend (`propietario/AlertaMujer_Frontend:mobile/src/core/api/emergencyApi.ts:1 coincide con propietario/AlertaMujer_Backend:src/main/java/com/alertamujer/backend/emergency/dto/response/EmergencyDetailResponse.java; mismo patrón en contactos, chat y panel admin.`)
- Límite de evidencia coherente en las tres capas (500 000 bytes) (`mobile/src/modules/evidence/application/evidenceLimits.ts:1, backend LocalEvidenceStorage.java:28 y Database 02_dml/01_updates/001_reduce_evidence_metadata_size_limit.sql.`)
- Migraciones Liquibase con rollback espejo y prueba de release aislada (`propietario/AlertaMujer_Database:05_rollbacks/01_ddl/03_tables/010_create_emergencies_table.rollback.sql y scripts/test-release.ps1.`)
- Roles de base de datos de mínimo privilegio y backend sin DDL (`propietario/AlertaMujer_Database:03_dcl/00_roles/001_create_technical_roles_and_transfer_schema_ownership.sql; backend con ddl-auto=validate en src/main/resources/application.properties.`)
- Integridad de negocio declarada en el esquema (`propietario/AlertaMujer_Database:01_ddl/10_indexes/007_create_emergencies_indexes.sql (una sola emergencia abierta por usuaria) y 005_create_emergency_contacts_indexes.sql (par canónico único de contactos).`)
- Error uniforme con correlación por X-Request-Id (`propietario/AlertaMujer_Backend:src/main/java/com/alertamujer/backend/shared/errors/ApiError.java y shared/observability/RequestIdFilter.java; mobile/src/core/api/ApiClient.ts los consume.`)
- Documentación SDD con ADR, OpenAPI y contrato WSS/STOMP exacto (`propietario/AlertaMujer_Docs:05-architecture/decisions/records/ADR-002-backend-modular-monolith.md y 07-api/wss-stomp.md, cuyos destinos coinciden con el código.`)
- Administrador inicial creado sin credenciales en el repositorio (`propietario/AlertaMujer_Database:docker/bootstrap-admin.sh y 01_ddl/07_functions/003_create_bootstrap_entity_admin_function.sql:126 (hash bcrypt).`)
- Autenticacion y sesion rigurosas en el servidor (`propietario/AlertaMujer_Backend:src/main/java/com/alertamujer/backend/shared/security/JwtAccessTokenService.java:34`)
- Refresh tokens con hash BCrypt y rotacion; igualacion de tiempos en el login (`propietario/AlertaMujer_Backend:src/main/java/com/alertamujer/backend/identity/service/impl/AuthenticationServiceImpl.java:69`)
- CORS por lista del entorno, sin comodin ni credenciales, probado (`propietario/AlertaMujer_Backend:src/main/java/com/alertamujer/backend/shared/security/SecurityConfiguration.java:83`)
- Propiedad del recurso aplicada en SQL (emergencia, evidencia, chat, contactos) (`propietario/AlertaMujer_Backend:src/main/java/com/alertamujer/backend/evidence/repository/EvidenceRepository.java:38`)
- Validacion de evidencia por estructura WebP real y limite de tamano (`propietario/AlertaMujer_Backend:src/main/java/com/alertamujer/backend/evidence/storage/LocalEvidenceStorage.java:116`)
- Errores 500 genericos sin filtrar detalles internos (`propietario/AlertaMujer_Backend:src/main/java/com/alertamujer/backend/shared/errors/GlobalExceptionHandler.java:86`)
- Imagen multi-etapa, usuario no root y entrypoint que exige el usuario de minimos privilegios (`propietario/AlertaMujer_Backend:Dockerfile:10`)
- Privilegios minimos de la aplicacion en la base y PostgreSQL solo en 127.0.0.1 (`propietario/AlertaMujer_Database:docker-compose.yml:33`)
- Rollback por changeset con estructura espejo, probado en el ciclo de release (`propietario/AlertaMujer_Database:scripts/test-release.ps1:367`)
- Suite del backend amplia: 46 clases, unitarias e integracion con aserciones reales y pruebas negativas (`propietario/AlertaMujer_Backend:src/test/java/com/alertamujer/backend/shared/SharedHttpContractTest.java:1`)
- Documentacion honesta sobre lo que falta (CI, ambientes, SMTP, FCM) (`propietario/AlertaMujer_Docs:10-devops/ci-cd.md:4`)
- Refresh token del movil en almacen seguro del sistema y access token en memoria (`propietario/AlertaMujer_Frontend:mobile/src/core/api/tokenStorage.ts:3`)
- Backend con arquitectura por modulos y capas respetada y manejo de errores centralizado (`src/main/java/com/alertamujer/backend/shared/errors/GlobalExceptionHandler.java; ningun controlador importa un repository; Dockerfile multi-etapa con usuario no root (propietario/AlertaMujer_Backend:Dockerfile)`)
- Base de datos versionada con Liquibase, rollback por changeset y roles de minimo privilegio (`propietario/AlertaMujer_Database:changelog/changelog-master.yaml; 05_rollbacks/01_ddl/03_tables/003_create_users_table.rollback.sql; 03_dcl/00_roles/001_create_technical_roles_and_transfer_schema_ownership.sql`)
- Documentacion extensa y honesta: 14 secciones, 7 ADR, OpenAPI de 43 rutas, diagramas Mermaid y HU recientes con escenarios Gherkin; no sobrevende (admite Playwright 3 de 10 y Mobile sin prueba en dispositivo) (`propietario/AlertaMujer_Docs:05-architecture/decisions/records/ADR-002-backend-modular-monolith.md; 04-requirements/hu-am-030-internal-notification-panel.md; 04-requirements/frontend-stories.md`)
- Frontend con URL de API configurable, sesion movil en SecureStore con guardas de navegacion y estados de carga, vacio, error y acceso denegado en el panel web (`propietario/AlertaMujer_Frontend:mobile/src/core/api/tokenStorage.ts; mobile/app/_layout.tsx; web/src/modules/alerts/AlertsList.tsx:63`)
- Activacion de SOS controlada por pulsacion larga de 1 segundo con estado accesible (`propietario/AlertaMujer_Frontend:mobile/src/modules/emergency/presentation/screens/HomeEmergencyScreen.tsx:257`)
- Flujo por HU en los 3 repos tecnicos: ramas feat/fix con PR fusionado a develop y Conventional Commits (`gh api repos/propietario/AlertaMujer_Backend/pulls?state=all (28 PR); git log --all --no-merges`)
- Existe forma de crear la primera cuenta administradora (bootstrap) para el panel web (`propietario/AlertaMujer_Database:docker/bootstrap-admin.sh; 01_ddl/07_functions/003_create_bootstrap_entity_admin_function.sql`)

## Lo que no se pudo verificar

- Arranque desde cero de la base (docker compose up) y aplicación real de los changesets, incluido el orden de 03_dcl/03_retirements — Exige ejecutar Docker y Liquibase, prohibido en esta evaluación; se verificó por lectura de changelogs y compose.
- Que las 138 pruebas del backend y las pruebas de mobile y web pasen — Exige ejecutar mvn y npm, prohibido; se leyó su existencia pero no su resultado.
- Comportamiento en dispositivo: cámara, ubicación en segundo plano y reconexión STOMP — Requiere un dispositivo o emulador Android.
- Flujo contra despliegue en línea (T-14.3) — El equipo no declara URL de despliegue.
- Respuesta real 500 frente a 405/413/415 (H-A04) — Se concluyó leyendo el manejador global; no se ejecutó una petición.
- Ramas distintas de la evaluada (33 en Backend y Database, 38 en Frontend) — Ninguna aparece como adelantada respecto del SHA evaluado; no se inspeccionó su contenido.
- Validez de la credencial de administrador de H-B01 contra un backend desplegado — No hay URL declarada y solo se permite un GET de solo lectura; ademas probar un inicio de sesion seria un acceso no autorizado.
- Ejecucion real de las pruebas (mvn verify, node --test, Playwright, test-release.ps1) y su resultado — El briefing prohibe ejecutar codigo de los aprendices; se evaluaron por lectura y por el conteo que reporta el equipo.
- Proteccion de ramas en los cuatro repositorios — La API devuelve 404 para la consulta de proteccion de main con la cuenta de evaluacion; no se distingue entre ausencia y falta de permiso.
- Usuario por defecto de la imagen oficial de Liquibase y vulnerabilidades de dependencias — Exige descargar la imagen o correr un analizador (npm audit, OWASP Dependency-Check), lo que no esta permitido.
- Cifrado en transito (TLS) en un despliegue real y cifrado en reposo del volumen de evidencia — No existe despliegue que inspeccionar; los compose son locales y sin terminacion TLS.
- Unidades reales de la espera de reenvio de OTP (H-B12) — Se confirmo el valor sembrado pero no el uso en codigo sin ejecutar el sistema.
- Compilacion, typecheck, lint, build y pruebas de Frontend (R-10.1) — El briefing prohibe ejecutar codigo de los aprendices; solo se verifico por lectura que los imports y alias resuelven.
- Revision de PR por terceros, colaboradores y proteccion de ramas (T-13.2, T-13.6) — Colaboradores y proteccion de ramas exigen permiso de push (403); solo se vieron PR, revisiones e issues publicos.
- Procedencia de la 'reference implementation' del commit c24a9e8 y si Docs d1a89c9 coincide con un framework externo — No esta en los repositorios declarados; inferido solo del mensaje de commit y de la estructura.
- Despliegue en linea y flujo contra una URL publica — El equipo no declara URL de despliegue ni homepage; Docs reconoce GAP-01 sin ambiente.
- Muestreo D4: leidos con profundidad mobile/src/shell/providers/AppStateProvider.tsx y web/src/shared/data/WebStateContext.tsx (Frontend) e IdentityOtpRepository.java con PhoneFirstRegistrationServiceImpl.java (Backend) — Se muestrearon los 2 componentes mas grandes por lineas (frontend y Backend); translations.ts y messages.ts se tomaron como datos. Database y Docs quedan fuera de D4.
- Posible segunda cuenta de autor y otros repositorios de la cuenta — Los 111 commits no merge de los 4 repos son de Integrante 1 (un solo correo); no hay otra cuenta que sospechar. Los otros 23 repositorios publicos de la cuenta no estan declarados y no se evaluaron.
