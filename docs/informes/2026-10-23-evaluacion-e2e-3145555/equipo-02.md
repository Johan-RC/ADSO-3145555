# Equipo 2 · SmartHome — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 49/100 · Juicio D**

## Veredicto

SmartHome tiene piezas bien construidas por separado: un backend con capas hexagonales y validacion estricta, una app movil cuyo contrato con el backend coincide en autenticacion, hogares, consumo y notificaciones, y una base de datos con Liquibase, indices y RLS. Aun asi, el puntaje es 48,9 con juicio D, a unos 21 puntos del umbral de 70, y ninguno de los 5 flujos de punta a punta funciona (los 5 estan ROTOS, 0 COMPLETOS). Hay 2 hallazgos bloqueantes: la base de datos declarada esta congelada desde junio y no es la que el backend necesita, y el alta de dispositivos en el movil termina en 'Integracion pendiente', asi que sin dispositivos no hay control ni consumo. Ademas hay 4 criticos: el web de dev es el andamiaje y la integracion real esta en ramas sin fusionar, los cinco repos no arrancan como un sistema, y hay credenciales expuestas en repos publicos (documentos Word de la documentacion y un administrador con clave conocida en la migracion de la BD). Lo primero es decidir una unica base de datos oficial y retirar y rotar esas credenciales; con eso, fusionar las ramas y conectar el alta de dispositivos, el equipo queda cerca de un sistema que arranque.

## Plan para cerrar las brechas

1. **Elegir un unico repositorio oficial de base de datos (smarthome-database o smart-home-database), declararlo, e incorporar a su rama principal los changesets que el backend necesita (refresh_token, session_version, funciones fn_*, esquema de homes, devices, consumo y notificaciones). Es el primer paso del cierre porque desbloquea los cinco flujos.** (esfuerzo L) — se cierra cuando: Con Liquibase aplicado desde cero sobre Postgres, el backend pasa prisma validate y sus pruebas e2e de auth, hogares, dispositivos y consumo; el README y el backend citan el mismo repo de BD.
2. **Conectar el alta de dispositivos del movil con las sesiones de configuracion Shelly del backend (crear, identificar, completar) y resolver el 503 del provision por identidad MQTT; corregir la ruta de salir de un hogar y los campos de telemetria del listado de dispositivos. Depende de la BD oficial del paso 1.** (esfuerzo L) — se cierra cuando: Desde la app se agrega un Shelly al hogar, queda registrado y se puede encender, apagar y ver su consumo; pairing-service ya no lanza PAIRING_UNSUPPORTED y salir de un hogar responde 2xx.
3. **Retirar de las ramas y del historial de smart-home-docs los documentos Word con credenciales y correos personales, rotar la contrasena de la cuenta, cualquier secreto JWT y las contrasenas de BD que hayan coincidido, y reponer los documentos con datos ficticios. Se puede hacer en paralelo con el paso 1: es la exposicion mas urgente.** (esfuerzo M) — se cierra cuando: El historial del repo publico ya no contiene los .docx originales (git log --all sin esos archivos), las credenciales fueron rotadas y los documentos nuevos solo traen datos ficticios.
4. **Sacar del repo de BD el usuario administrador con contrasena conocida (sembrarlo desde variable de entorno sin valor por defecto), el volcado SQL con usuarios y hashes y el archivo .env.shared, e incluirlos en .gitignore y limpiar el historial; rotar la contrasena del administrador y la de Postgres.** (esfuerzo S) — se cierra cuando: git grep no encuentra la contrasena del admin ni backups/ ni .env.shared en ningun SHA de las ramas vigentes; el seed lee la clave de una variable y falla si no existe.
5. **Fusionar con PR revisado la rama 12-dev (o 09-dev) del web en dev, conservando el CI/Docker, y corregir los clientes API que apuntan a rutas inexistentes y el registro mal formado; volver a ejecutar el CI de dev.** (esfuerzo S) — se cierra cuando: origin/dev contiene la integracion real; el registro de una cuenta nueva funciona contra el backend y los clientes de API usan solo rutas que existen en el backend; CI de dev en verde.
6. **Crear un docker-compose unico (Postgres con Liquibase, backend, web, broker MQTT) con README de arranque en orden y la version de BD que requiere cada version del backend; completar el README del backend y el .env.example del movil.** (esfuerzo M) — se cierra cuando: Un integrante nuevo ejecuta los pasos del README en una maquina limpia y llega al login del web con el backend y la BD levantados.
7. **Integrar a las ramas principales el trabajo atrapado en ramas y PR sin fusionar (backend, movil, web y documentacion), definir ramas de produccion utiles y revisar los PR con aprobacion de otro integrante.** (esfuerzo M) — se cierra cuando: No quedan PR abiertos con trabajo entregable; main/dev del backend incluyen staging y endurecimiento de Shelly; los PR fusionados tienen una revision aprobada.
8. **Corregir el CI: el del movil en verde y ejecutando sus 5 suites, y las pruebas de seguridad del backend (sesiones, alcance de dispositivos, consumo) en CI; agregar CI y validacion de changelogs al repo de BD y pruebas minimas al web.** (esfuerzo M) — se cierra cuando: Los cuatro repos tienen un workflow verde que ejecuta las suites completas; el repo de BD aplica Liquibase desde cero en CI.
9. **Resolver la incoherencia de autenticacion y sesion: usuarios sembrados con hash compatible con el backend (argon2), JWT fuera de localStorage con cierre de sesion que revoque en el servidor y vida de sesion adecuada.** (esfuerzo M) — se cierra cuando: Un usuario sembrado puede iniciar sesion en el backend; el cierre de sesion invalida el refresh token en el servidor y la sesion web no expira a los 15 minutos sin refresco.
10. **Actualizar la documentacion para reflejar el sistema real (arquitectura NestJS/Prisma/MQTT, sin modo mock) y llevarla a la rama principal; agregar indicadores de exito medibles y una politica de tratamiento de datos (Ley 1581).** (esfuerzo M) — se cierra cuando: El README y los documentos de main describen la arquitectura construida, hay al menos 3 KPI medibles y una politica de datos con consentimiento y retencion.
11. **Normalizar la base de datos: migraciones incrementales con rollback atado a Liquibase, nombres de columnas y esquema audit consistentes con el backend, y politica ON DELETE en las claves foraneas.** (esfuerzo M) — se cierra cuando: Cada changeset tiene rollback probado en CI, los nombres siguen una convencion unica y las 43 FK declaran ON DELETE.
12. **Mejorar calidad y despliegue: plan de rollback y release repetible, OpenAPI completo, cabeceras de seguridad en nginx, refactor de clases y pantallas muy largas, i18n y limpieza de archivos duplicados.** (esfuerzo L) — se cierra cuando: Existe un procedimiento de despliegue con rollback documentado, el OpenAPI cubre todos los endpoints y el nginx envia cabeceras de seguridad.

## Verificación independiente

Hallazgos confirmados: 7 · matizados: 2 · refutados: 0 · duplicados fusionados: 6.

Confirmé H-01, H-02, H-04, H-06, H-08, H-10 y H-12; maticé H-03 (el plan de pruebas expone un correo y una clave de aspecto real, pero el manual de instalación solo trae valores de ejemplo: bajar a critico), H-05 (es falso que no haya docker-compose: la BD tiene uno, falta uno de sistema) y H-07 (clave por defecto y 4 usuarios semilla: medio); ninguno refutado. Los 4 ítems PASS se sostienen (backend R-5.1/R-6.1/R-7.1 con CI verde en el SHA y sin secretos en el historial; R-2.1 de la BD coherente con los scripts) y los 5 flujos están ROTOS como se afirmó. Las cifras de aportes (72/65/21 de 158) y las fusiones por correo idéntico son correctas; sugiero eliminar los duplicados H-13, H-17, H-19, H-07, H-34 y H-29, y corregir 82 por 64 archivos en H-04.

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Roto | Registrarse, activar la cuenta e iniciar sesion | tabla: el movil y el backend coinciden en rutas y DTO (passwordConfirmation incluido), pero el Prisma del backend mapea auth.user con name, status, email_verified, session_version y la tabla auth.refresh_token, y la BD declarada tiene auth.user con nombre, apellido, username, tipo_documento y numero_documento NOT NULL, sin session_version y sin refresh_token (solo auth.session). Ademas el web de dev envia el registro sin passwordConfirmation y espera un token que el backend no devuelve. |
| Roto | Crear un hogar e invitar o gestionar miembros | tabla: homes.home exige estrato SMALLINT NOT NULL y usa id_user, nombre, estado, mientras el backend inserta created_by, name, status sin estrato (CreateHomeDto solo trae name). Ademas el boton Salir del hogar del movil llama POST /homes/:id/leave, ruta que no existe (el backend expone PATCH /homes/:homeId/members/me/leave). |
| Roto | Agregar un dispositivo Shelly al hogar | movil a servicio: ambos lados existen pero no estan conectados. Las pantallas descubren e identifican el Shelly por LAN o BLE pero terminan en 'Integracion pendiente'; pairingService es un stub que lanza PAIRING_UNSUPPORTED y shellyService y createDevice no se usan en ninguna pantalla. El backend ya expone setup-sessions y provision (este ultimo responde 503 MQTT_DEVICE_BOOTSTRAP_REQUIRED con TLS o namespace). El web de dev no tiene pantalla de alta. |
| Roto | Encender o apagar un dispositivo y ver su estado en tiempo real | tabla: el contrato movil-backend coincide (TURN_ON y TURN_OFF, evento device.status.updated), pero devices.device de la BD declarada usa nombre, estado, encendido, consumo_actual_w, mac_address y no tiene manufacturer_device_id, connectivity_status, transport_type ni messaging_protocol que el backend lee y escribe; ademas sin el alta de dispositivo (flujo 3) no hay dispositivos que controlar desde la app. |
| Roto | Consultar el consumo y generar un reporte | tabla: consumption.consumption de la BD declarada tiene watts, kwh_acumulado, costo_estimado y fecha_lectura y el backend consulta power_w, energy_delta_kwh y read_at. Ademas el PDF y CSV se generan solo en el cliente movil (lib/utils/consumption-pdf.ts) aunque el diseno prometia exportacion en servidor, y el dashboard web de dev muestra cifras fijas en el codigo (web/src/features/consumption/pages/DashboardPage.tsx:6) y llama a /consumption que no existe. |

## Hallazgos

### [Bloqueante] H-01 · El alta de dispositivos no esta integrada en el movil: sin dispositivos no hay control ni consumo
- **Repositorio:** `propietario/from_movil`
- **Lente SDLC OS:** A06 · **Verificación independiente:** confirmado
- **Evidencia:** `app/(tabs)/prepare-shelly.tsx:491`
- **Por qué importa:** Las pantallas prepare-shelly y shelly-setup terminan en 'Integracion pendiente' y no registran el dispositivo; lib/services/pairing-service.ts lanza PAIRING_UNSUPPORTED aunque el backend ya expone /shelly/setup-sessions; shellyService y createDevice no se invocan desde ninguna pantalla. Ademas el provision del backend responde 503 cuando MQTT usa TLS o namespace (src/modules/devices/application/use-cases/provision-shelly-device.use-case.ts:47). El flujo central del producto (medir y controlar un enchufe) no se puede recorrer de punta a punta.
- **Cómo cerrarlo (L):** Conectar el movil a las sesiones de configuracion del backend (crear, identificar, completar) y definir la identidad MQTT por dispositivo que el 503 exige; hasta entonces, documentar el alta manual como flujo oficial.

### [Bloqueante] H-02 · La BD declarada no es la que el backend necesita: ninguno de los flujos principales puede completarse contra ella
- **Repositorio:** `propietario/smart-home-database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** confirmado
- **Evidencia:** `01_ddl/03_tables/001_create_auth_tables.sql:78`
- **Por qué importa:** El Prisma del backend (prisma/schema.prisma) mapea auth.user con name, status, email_verified y session_version y la tabla auth.refresh_token, devices.device con name, status, is_on y manufacturer_device_id, homes.home con created_by y status (sin estrato), consumption con power_w, energy_delta_kwh y read_at, y notifications.notification con status UNREAD, READ o DISMISSED. La BD declarada tiene auth.user con nombre, apellido, username y tipo_documento NOT NULL, ninguna tabla refresh_token, device con nombre, estado y encendido, home con estrato NOT NULL y notification con leida booleana; session_version, manufacturer_device_id, device_telemetry_raw, device_schedule y alert_rule no existen en ninguna de sus ramas (git grep da 0). Cualquier consulta Prisma sobre user falla por columna inexistente, asi que registro, login y todo lo demas se rompen.
- **Cómo cerrarlo (L):** Decidir una unica fuente de verdad de la BD, declararla en el listado de repos y llevar a su rama principal el esquema que el backend consume (los 64 changesets que el backend cita). Anadir en el CI del backend una prueba que levante la BD con Liquibase y ejecute prisma validate.

### [Crítico] H-03 · Repo público de documentación con credenciales de una cuenta real, correos personales y claves de ejemplo en documentos Word de las ramas docs/06-pruebas y docs/07-implementacion
- **Repositorio:** `propietario/smart-home-docs`
- **Lente SDLC OS:** A12 · **Verificación independiente:** matizado (severidad ajustada de bloqueante)
- **Evidencia:** `README.md (main sin contenido); evidencia real en origin/docs/06-pruebas commit bde51ac y origin/docs/07-implementacion commit 2de556e, carpetas docs/06-pruebas y docs/07-implementacion (git show y lectura del XML del documento Word)`
- **Por qué importa:** El plan de pruebas incluye el JSON de login con el correo (n****«correo») y la contraseña ««redactado»» de una integrante, y los correos personales de otras dos; el manual de instalación incluye contraseñas de usuarios de BD, un ejemplo de clave JWT y una contraseña Wi-Fi. El repo es público (gh api: private=false) y el historial es permanente. Exposición de datos de personas (Ley 1581) y de secretos; si esa clave JWT o esas cuentas se usaron en algún entorno real, permiten falsificar sesiones o entrar.
- **Cómo cerrarlo (M):** Retirar los documentos de las ramas y del historial (reescritura con filter-repo y push forzado coordinado), rotar la contraseña de la cuenta, cualquier secreto JWT y las contraseñas de BD que hayan coincidido, y reemplazar los documentos por versiones con datos ficticios. Alojar documentos con datos personales fuera de un repo público.

### [Crítico] H-04 · La rama dev del web es el andamiaje, no el producto: la integración real está en 09-dev/12-dev sin fusionar
- **Repositorio:** `propietario/smarthome-frontend-web`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado; también reportado como H-13
- **Evidencia:** `web/src/features/devices/pages/Devices.tsx:7`
- **Por qué importa:** origin/dev tiene 2 commits (a1f67af exportación de Figma Make y 380d822 con CI/Docker); Devices.tsx y Consumption.tsx:15 usan arreglos fijos y solo auth y Homes llaman a la API. Los 24 commits de 09-dev/12-dev (82 archivos, +10 667) con la integración, el refresh de sesión, el registro y activación y Shelly nunca llegaron a dev, y main solo tiene un README. El flujo de CI de dev (verde) y el despliegue por Dokploy publicarían la maqueta. Impacto: Quien despliegue o evalúe dev ve datos inventados, y el web real no se puede desplegar sin saber que vive en otra rama. Es el trabajo de Integrante (16 de sus 21 commits) y de Integrante atrapado.
- **Cómo cerrarlo (S):** Fusionar 12-dev (o 09-dev, que ya contiene la fusión del PR #1) en dev con un PR revisado, conservar el commit de CI/Docker de 380d822, volver a ejecutar el flujo de dev y recién entonces habilitar el despliegue.

### [Crítico] H-05 · Los cinco repositorios declarados no forman un sistema que arranque: la BD declarada está congelada y el backend depende de otro repositorio
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** matizado (descripción precisada); también reportado como H-17
- **Evidencia:** `propietario/smart-home-docs:README.md:3`
- **Por qué importa:** smart-home-database (último push 2026-06-23, 92 changeSets) no contiene la tabla refresh_token que usa prisma/schema.prisma del backend (la BD solo tiene auth.session). El backend (su .gitignore con /smarthome-database/ y sus documentos) y el README de docs apuntan a propietario/smarthome-database, un repositorio activo (push 2026-10-22) que el equipo no declaró y que no se evaluó. Además no hay docker-compose en ningún repositorio y el nginx del web espera un host 'backend'. Verificado leyendo ambos esquemas; no se ejecutó nada. Impacto: Con lo declarado no se puede levantar BD + backend + web ni migrar a la versión que el backend necesita; el login del backend fallaría contra la BD declarada. Quien reciba el proyecto depende de saber qué repositorio no declarado usar.
- **Cómo cerrarlo (M):** Declarar smarthome-database como el repositorio oficial de BD (archivar o actualizar smart-home-database), y añadir en backend o docs un docker-compose único (postgres+liquibase, backend, web, broker) con README de arranque en orden y la rama/versión de BD que requiere cada versión del backend.

### [Crítico] H-06 · El usuario administrador se crea en todo entorno con una contraseña conocida escrita en claro en la migración
- **Repositorio:** `propietario/smart-home-database`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado; también reportado como H-19
- **Evidencia:** `02_dml/00_inserts/005_insert_admin_user.sql:47`
- **Por qué importa:** La contraseña del admin (««redactado»») está en la línea 47 y en el comentario de la 19; el changeset dml-insert-005-admin-user (02_dml/00_inserts/changelog.yaml:70) no declara context, y el que la cambia es context reference (02_dml/01_updates/changelog.yaml:31) y su contenido es un marcador sin sustituir. Cualquier instalación nace con un administrador cuya clave está publicada en un repo público. Si el administrador se despliega sin cambiar la clave, la cuenta es explotable.
- **Cómo cerrarlo (S):** Quitar la contraseña del SQL: generar el hash fuera del repo o exigir un parámetro de Liquibase, poner un context de seed solo en desarrollo, y obligar al cambio en el primer inicio. Rotar la clave en cualquier entorno donde ya se aplicó.

### [Alto] H-08 · En el web de dev no se puede registrar una cuenta nueva
- **Repositorio:** `propietario/smarthome-frontend-web`
- **Lente SDLC OS:** A03 · **Verificación independiente:** confirmado
- **Evidencia:** `web/src/features/auth/pages/LoginPage.tsx:63`
- **Por qué importa:** La pantalla envía name, email y password a /auth/register, pero RegisterUserDto del backend (src/modules/auth/application/dto/register-user.dto.ts) exige también passwordConfirmation con ValidationPipe global en modo forbidNonWhitelisted, así que responde 400; aunque pasara, el backend no devuelve sesión sino activación por correo y AuthContext.saveSession lanza 'formato inesperado'. Dev no tiene pantalla de activación (ActivateAccountPage solo existe en 12-dev). Impacto: Un usuario sin cuenta previa queda en un callejón sin salida en el primer paso del producto (A03: flujo principal sin salida).
- **Cómo cerrarlo (S):** Alinear el payload con el DTO, mostrar 'revisa tu correo' tras el registro y traer la pantalla de activación de 12-dev.

### [Alto] H-09 · La sesión web muere a los 15 minutos y el cierre de sesión no revoca nada en el servidor
- **Repositorio:** `propietario/smarthome-frontend-web`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-34
- **Evidencia:** `web/src/app/contexts/AuthContext.tsx:56`
- **Por qué importa:** El token de acceso dura 15 min (JWT_EXPIRES_IN en el .env.example del backend) y el web no implementa refresh ni envía credenciales (sin credentials:'include'); api-client.ts responde a un 401 con window.location.assign('/login'), perdiendo lo que el usuario hacía. logout() solo borra localStorage y no llama a POST /auth/logout, de modo que la cookie de refresh y la familia de sesión siguen vivas. El token se guarda en localStorage. Impacto: Experiencia rota para cualquier uso de más de 15 minutos y sesión que el usuario cree cerrada pero sigue válida. El móvil sí lo resuelve (SecureStore, refresh en lib/api/api-client.ts:141, logout en el servidor).
- **Cómo cerrarlo (S):** Portar el refresh y el logout de servidor de 12-dev (commit fd660e4 'add refresh and session logout') y revisar el almacenamiento del token.

### [Alto] H-10 · La documentación no vive en la rama principal: smart-home-docs entrega un README
- **Repositorio:** `propietario/smart-home-docs`
- **Lente SDLC OS:** A05 · **Verificación independiente:** confirmado; también reportado como H-29
- **Evidencia:** `README.md:1`
- **Por qué importa:** main tiene un único archivo. El SRS, el diseño, la propuesta, las pruebas, los manuales, el artículo, el despliegue y los términos están como .docx en 12 ramas docs/*, con 9 PR abiertos contra dev nunca fusionados (el de requisitos cerrado sin fusionar), y ningún documento es legible como texto en GitHub (el SRS es un .docx guardado con extensión .md y sufijo (1)). La rama docs/12-terminos-y-condiciones ni siquiera tiene PR. Impacto: Quien abra el repositorio no encuentra requisitos, diseño ni manuales; la trazabilidad y la revisión por pares son imposibles sobre binarios y ramas separadas.
- **Cómo cerrarlo (S):** Fusionar las 12 ramas en main bajo docs/NN-*/, convertir al menos SRS, diseño y despliegue a Markdown versionable (o dejar el .docx con extensión correcta y un índice en el README) y retirar las copias duplicadas.

### [Alto] H-11 · El informe de diseño describe una arquitectura distinta de la construida
- **Repositorio:** `propietario/smart-home-docs`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:1`
- **Por qué importa:** docs/04-diseno-software/INFORME DE DISEÑO.docx (rama docs/04-diseno-software) declara backend 'Node.js Express ... patrón MVC' y almacenamiento 'PostgreSQL MySQL / MongoDB Firebase / AWS S3'; el sistema real es NestJS con capas hexagonales, Prisma, PostgreSQL con RLS y MQTT (prisma/schema.prisma, src/modules del backend). Los diagramas UML (casos de uso, clases, componentes, despliegue) están en ese .docx y no en el repositorio. Impacto: La documentación de diseño no sirve para mantener el sistema y contradice al SRS actualizado, que sí dice NestJS/Prisma.
- **Cómo cerrarlo (M):** Actualizar el informe de diseño al estado real (diagrama de componentes de lo construido y despliegue) y retirar las opciones alternativas.

### [Alto] H-12 · Trabajo relevante atrapado en ramas y PR sin fusionar, y sin ramas de producción útiles
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado
- **Evidencia:** `propietario/smarthome-backend:README.md:1`
- **Por qué importa:** main/qa son un 'Initial commit' en backend, web y BD. Backend: 11-dev (+9 commits: identidades MQTT por dispositivo, worker de revocación, ACL), 12-dev, 13-dev (endurecimiento de Shelly RPC), 14-dev (métricas Prometheus) y 15-dev (CI de staging) tienen PR abiertos (#7, #8, #4, #5, #9) sin fusionar. Móvil: 03-dev (+6, PR #1 abierto), fix/mobile-screen-styles y test/flujo-usuario-mobile. Docs: 12 ramas. Web: H-C01. Impacto: El entregable depende de saber qué rama fusionar; quien revise main o dev ve un producto distinto del que el equipo cree tener, y el cierre queda a un merge de distancia.
- **Cómo cerrarlo (M):** Definir qué ramas entran al cierre, fusionar (o cerrar con motivo) cada PR abierto, y dejar main/qa con la versión entregable.

### [Alto] H-14 · Cuatro clientes API del web apuntan a rutas que el backend no tiene
- **Repositorio:** `propietario/smarthome-frontend-web`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web/src/shared/api/reports.api.ts:3`
- **Por qué importa:** consumption.api.ts llama GET /consumption, reports.api.ts GET /reports, audit.api.ts GET /audit y settings.api.ts GET y PATCH /settings; el backend solo tiene /homes/:homeId/consumption y no hay controladores de reports, audit ni settings (git grep de @Controller). Tambien resetPassword envia token y clave sin passwordConfirmation. Son contratos inventados que fallarian con 404 o 400 al conectarlos.
- **Cómo cerrarlo (S):** Eliminar los clientes sin contraparte o implementar los endpoints; alinear los payloads con los DTO del backend (o generar el cliente desde OpenAPI).

### [Alto] H-15 · El README del backend no permite arrancarlo y no hay un camino único para levantar el sistema
- **Repositorio:** `propietario/smarthome-backend`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:44`
- **Por qué importa:** Desde la línea 40 el README es la plantilla de NestJS (npm install, npm run start, Mau, Discord); no dice copiar .env.example (48 líneas), cómo obtener y migrar la BD, ni que MQTT/SMTP son opcionales. El conocimiento de arranque está repartido en ALCANCE_2026_09_08.md y siete documentos por HU, y no existe docker-compose ni en backend, ni en web, ni en el móvil. Impacto: No se cumple el requisito de handover (un camino documentado para levantar el producto completo); el backend es la pieza que todos los demás repositorios necesitan.
- **Cómo cerrarlo (S):** Reescribir el README con: qué es, requisitos, orden (BD, .env, prisma, start:dev), puertos, cómo probar con scripts/simulate-device.js y enlace a Swagger; mover el texto de plantilla fuera.

### [Alto] H-16 · Volcado SQL de 366 KB con usuarios y hashes, y archivo .env.shared con la contraseña de Postgres, versionados
- **Repositorio:** `propietario/smart-home-database`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-07
- **Evidencia:** `backups/smarthome_backup_2026-06-23_18-01-58.sql:5143`
- **Por qué importa:** El volcado (commit e5e7b98) contiene la tabla de usuarios con 4 filas (correo y hash bcrypt) y .env.shared:9 versiona la contraseña de Postgres (valor de ejemplo débil, igual al de .env.example:3; ningún script lo lee). Los volcados de datos no pertenecen al control de versiones y facilitan ataques de diccionario fuera de línea.
- **Cómo cerrarlo (S):** Quitar backups y .env.shared del árbol y del historial, añadir backups/ y .env.shared a .gitignore, y fijar la contraseña real fuera del repo.

### [Alto] H-18 · La integración continua del móvil está en rojo en la rama evaluada y el CI no ejecuta 4 de sus 5 suites
- **Repositorio:** `propietario/from_movil`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(tabs)/(main)/index.tsx:194 y .github/workflows/mobile-ci.yml:33`
- **Por qué importa:** Mobile CI en dev (ejecución 39430097008, a4c6b065cd) falla en el paso Lint con 8 errores de eslint en app/(tabs)/(main)/index.tsx (líneas 178 y 194); las 6 últimas ejecuciones también fallan. Sin CI en verde no hay puerta de calidad y los commits siguientes se acumulan sobre rojo. El mismo workflow no corre test:alerts, test:navigation-auth, test:realtime-device-status ni test:shelly-ble-rpc.
- **Cómo cerrarlo (S):** Corregir los 8 errores (mover lecturas de useRef fuera del render, evitar setState síncrono en el efecto), añadir al workflow las cuatro suites faltantes y proteger dev con la ejecución como requisito de merge.

### [Alto] H-20 · El repo de BD declarado esta congelado desde junio y el backend y la documentacion citan otro repo
- **Repositorio:** `propietario/smarthome-backend`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/IMPLEMENTACION_HU09.md:12`
- **Por qué importa:** La documentacion del backend cita propietario/smarthome-database (ramas 09-dev a 16-dev, 64 changesets Liquibase) como su BD, y el README de smart-home-docs enlaza ese nombre, pero PROYECTOS declara propietario/smart-home-database, cuyo ultimo commit es del 2026-06-23 y cuyas ramas main y qa solo tienen el commit inicial. Quien clone lo declarado no obtiene la BD que el sistema usa.
- **Cómo cerrarlo (S):** Declarar el repo correcto en la ficha, archivar o redirigir el repo antiguo con un README y fusionar la rama de BD vigente en su main.

### [Medio] H-21 · La interfaz del móvil está escrita en español fijo y el i18n existe en una sola pantalla
- **Repositorio:** `propietario/from_movil`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(tabs)/(main)/profile.tsx:10`
- **Por qué importa:** El SRS exige internacionalización (RF6.1) y existe lib/i18n/i18n.ts, pero solo profile.tsx usa useTranslation; el resto de las pantallas (homes.tsx, reports, access) tiene textos literales. La rama fix/mobile-screen-styles añade el cambio a francés en una pantalla, también sin integrar. Impacto: Un requisito declarado queda a medias y añadir un idioma exigiría tocar todas las pantallas.
- **Cómo cerrarlo (M):** Integrar fix/mobile-screen-styles y migrar los textos de las pantallas a claves de i18n por módulo.

### [Medio] H-22 · El producto no declara indicadores de éxito medibles
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/smarthome-backend:ALCANCE_2026_09_08.md:1`
- **Por qué importa:** El SRS (rama docs/01-requisitos) tiene problema, propósito, justificación, alcance y 52 RF con criterios de aceptación y actores, pero ningún indicador con fórmula, línea base y meta (ahorro de energía, adopción, cobertura de dispositivos). Solo hay objetivos técnicos en los RNF (2 s en tiempo real, 3 s en API, 2 h de recuperación). Las HU no usan el formato 'como/quiero/para'; los RF sí tienen prioridad, pero no hay una lista de MVP. Impacto: Sin indicadores no se puede decir si el producto cumplió su propósito (reducir el desperdicio de energía); la propuesta técnica y económica queda sin criterio de éxito.
- **Cómo cerrarlo (S):** Añadir al SRS o al README de docs una sección de KPI (por ejemplo dispositivos monitoreados por hogar, latencia de telemetría p95, ahorro estimado por hogar) con línea base y meta, y marcar qué RF son MVP.

### [Medio] H-23 · La documentación del móvil describe una app con modo mock/demo que ya no existe
- **Repositorio:** `propietario/from_movil`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/BACKEND_CONNECTION.md:5`
- **Por qué importa:** BACKEND_CONNECTION.md:5 dice que sin EXPO_PUBLIC_API_URL usa datos mock y DOCUMENTACION_CODIGO_PANTALLAS_SMART_HOME.md (43 KB, líneas 131, 441, 1257) describe 'acceso demo', MOCK_CODE y un auth-store en memoria 'porque no hay backend'. lib/config/api-config.ts:4 declara que la app no usa mock ni demo y detiene el build de producción sin URL. Impacto: Quien siga la guía espera un modo demo que no hay y no entiende por qué la app falla sin URL; 21 documentos solapados dificultan saber cuál manda.
- **Cómo cerrarlo (M):** Reescribir BACKEND_CONNECTION y la documentación de pantallas desde el código actual o borrar los obsoletos, y dejar un solo documento de arranque enlazado desde el README.

### [Medio] H-24 · Revisión de código casi inexistente y seguimiento sin issues
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/*/pulls/*/reviews`
- **Por qué importa:** Revisiones: móvil 2 de 12 PR (#3 y #5), backend 0 de 11, web 0 de 1, docs 0 de 10; hay PR fusionados por su propio autor (backend #6 y #10, móvil #8); la BD no usa PR. Issues: 0 en los cinco repositorios. El mensaje de commit convencional es el 56 %. Impacto: Los cambios llegan sin segunda mirada y no hay registro de por qué se hace cada HU; con el volumen de las dos últimas semanas (82 de 134 commits) el riesgo de regresión es alto.
- **Cómo cerrarlo (S):** Exigir una aprobación antes de fusionar a dev, abrir un issue por HU enlazado al PR y adoptar commitlint o una plantilla de commit.

### [Medio] H-25 · Salir de un hogar llama a una ruta inexistente
- **Repositorio:** `propietario/from_movil`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lib/services/smart-home-service.ts:217`
- **Por qué importa:** El movil hace POST /api/v1/homes/{id}/leave; el backend define PATCH /api/v1/homes/:homeId/members/me/leave (src/modules/homes/presentation/http/homes.controller.ts:182). El miembro invitado no puede abandonar un hogar y recibe 404.
- **Cómo cerrarlo (S):** Cambiar el metodo y la ruta del movil a PATCH .../members/me/leave y cubrirlo con un test de contrato.

### [Medio] H-26 · El listado de dispositivos no devuelve los campos de telemetria que el movil espera
- **Repositorio:** `propietario/smarthome-backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/modules/devices/application/use-cases/list-home-devices.use-case.ts:14`
- **Por qué importa:** mapBackendDevice (movil, lib/services/smart-home-service.ts:66) lee energyTotalKwh, voltageV, currentA, frequencyHz, temperatureC y lastSeenAt, pero el listado solo devuelve id, nombre, estado, isOn, currentPowerW y fechas; el movil muestra 0 V, 0 A y 0 Hz hasta que llega un evento Socket.IO. Ademas currentPowerW se consulta con una llamada a BD por dispositivo (N+1).
- **Cómo cerrarlo (S):** Incluir los campos en la respuesta (o tiparlos en OpenAPI y quitarlos del movil) y resolver los permisos de detalle en una sola consulta.

### [Medio] H-27 · Trabajo del backend y del movil atrapado en ramas adelantadas sin integrar
- **Repositorio:** `propietario/smarthome-backend`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/IMPLEMENTACION_HU09.md:12`
- **Por qué importa:** Backend: 14-dev trae metricas Prometheus protegidas, 13-dev endurece la validacion RPC local de Shelly, 15-dev anade pipelines de CI de staging y 11 y 12-dev documentan EMQX y BLE (todo del 2026-10-15); main y qa solo tienen el commit inicial. Movil: 03-dev (+6, incluye cambios del 2026-09-15), test/flujo-usuario-mobile (+1, correcciones de pantallas) y fix/mobile-screen-styles (+1, cambio de idioma a frances). Web: 12-dev (+23). El comportamiento entregado en dev no incluye nada de esto.
- **Cómo cerrarlo (M):** Abrir PR de cada rama hacia dev, cerrar las que ya no aplican y llevar dev a main al terminar.

### [Medio] H-28 · El .env.example del móvil tiene dos variables pegadas en la línea 8
- **Repositorio:** `propietario/from_movil`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `.env.example:8 app.config.js:1`
- **Por qué importa:** La línea 8 es IOS_BUNDLE_IDENTIFIER=YOUR_IOS_BUNDLE_IDENTIFIERACCOUNT_REACTIVATION_URL=smarthome://reactivate-account: falta un salto de línea, por lo que ACCOUNT_REACTIVATION_URL no se define y IOS_BUNDLE_IDENTIFIER contiene basura. Impacto: Quien copie el ejemplo obtiene una configuración de enlaces de reactivación que no funciona.
- **Cómo cerrarlo (S):** Separar las dos líneas y añadir salto de línea final.

### [Medio] H-30 · Pantallas de 600-950 líneas y un contexto global de ~560 líneas en el móvil
- **Repositorio:** `propietario/from_movil`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(tabs)/(main)/homes.tsx:28`
- **Por qué importa:** homes.tsx (957 líneas) contiene filtros, modales de alta, edición y borrado y llamadas al servicio; reports.tsx 819, home-detail 695, access 686. SmartHomeProvider (lib/context/smart-home-context.tsx:154-717) concentra hogares, dispositivos, favoritos, apariencia y alertas. La referencia del SDLC OS pone el límite en 300 líneas por archivo. Impacto: Cada cambio toca archivos enormes, los re-renderizados del contexto afectan a toda la app y las pantallas no se pueden probar por separado.
- **Cómo cerrarlo (L):** Partir cada pantalla en contenedor + componentes (modal de alta, lista, filtros) y dividir el contexto por dominio (hogares, dispositivos, preferencias).

### [Medio] H-31 · El suscriptor MQTT es una clase de 949 líneas con un método de 323
- **Repositorio:** `propietario/smarthome-backend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/modules/devices/infrastructure/messaging/mqtt-device-status.subscriber.ts:123`
- **Por qué importa:** handleStatusMessage (123-446) valida, interpreta el payload de dos formatos, escribe en Prisma, calcula métricas diarias y dispara alertas; evaluateDailyConsumptionAnomaly (768-928) aloja una regla de negocio en infraestructura, y la clase tiene 17 accesos directos a Prisma. Muestreo: componentes mayores del equipo por líneas (este y homes.tsx del móvil). Impacto: Es el punto de entrada de toda la telemetría: difícil de probar por unidades y de cambiar sin romper alertas; la regla de anomalía no se puede reutilizar desde la API.
- **Cómo cerrarlo (M):** Extraer el análisis del payload a un parser puro, las reglas de anomalía a un servicio de aplicación y el acceso a datos a repositorios, dejando el suscriptor como adaptador.

### [Medio] H-32 · Sin política de tratamiento de datos, consentimiento registrado ni retención (Ley 1581 de 2012)
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/smarthome-backend:src/modules/auth/application/dto/register-user.dto.ts:10`
- **Por qué importa:** El sistema trata datos personales y de consumo de hogares. RegisterUserDto no recibe la autorización del titular; la casilla del móvil es solo visual (propietario/from_movil:app/register.tsx:326); el web no tiene aviso alguno; ningún repo define finalidad, retención ni cómo ejercer los derechos de consulta y supresión. Se agrava con la exposición de correos en H-B01.
- **Cómo cerrarlo (M):** Redactar la política de tratamiento, guardar fecha y versión de la aceptación en el registro, definir plazos de retención y un endpoint o procedimiento de consulta y supresión.

### [Medio] H-33 · Los usuarios sembrados en la BD (bcrypt) no podrían iniciar sesión en el backend (argon2)
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `propietario/smarthome-backend:src/modules/auth/infrastructure/security/argon2-password-hasher.ts:15`
- **Por qué importa:** El backend verifica con argon2.verify (línea 15) y no tiene ninguna ruta bcrypt (git grep de bcrypt en src: 0); el repo de BD siembra admin y tres usuarios con crypt y gen_salt bf (propietario/smart-home-database:02_dml/05_test_data/001_test_users.sql:33). Inferido por lectura: no se ejecutó el login. Si se confirma, las pruebas manuales con los usuarios de prueba fallan y el administrador sembrado es inutilizable.
- **Cómo cerrarlo (S):** Sembrar usuarios con hash argon2id generado por el backend (script o comando de seed del backend) y retirar bcrypt del seed.

### [Medio] H-35 · Las pruebas que sostienen la seguridad (sesiones, alcance de dispositivos, consumo) nunca corren en CI
- **Repositorio:** `propietario/smarthome-backend`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `test/session-flow-postgres.e2e-spec.ts:44 y .github/workflows/ci-deploy.yml:26`
- **Por qué importa:** Cinco suites e2e hacen describe.skip si no existe la variable *_TEST_DATABASE_URL (líneas 33-34 de test/consumption-access-postgres.e2e-spec.ts, 44 de session-flow, 8 de session-security, 49-54 de devices-scope) y el workflow (.github/workflows/ci-deploy.yml:26) solo ejecuta npm test, que apunta a src. Un cambio que rompa autenticación o aislamiento entre usuarios llega a dev en verde.
- **Cómo cerrarlo (M):** Añadir un servicio postgres al job, aplicar el esquema y ejecutar npm run test:e2e con las variables definidas; fallar el job si una suite queda omitida.

### [Medio] H-36 · El frontend web no tiene ninguna prueba en la rama evaluada
- **Repositorio:** `propietario/smarthome-frontend-web`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web/package.json:10`
- **Por qué importa:** Sin script test ni archivos de prueba; el CI solo hace lint, typecheck y build. origin/09-dev tenía web/test con una prueba de contratos de Shelly; se perdió en 380d822. Los criterios de aceptación de las pantallas de login, hogares y dispositivos no tienen prueba que los respalde.
- **Cómo cerrarlo (M):** Añadir Vitest con pruebas de api-client y AuthContext, recuperar la prueba de contratos y ejecutarlas en CI.

### [Medio] H-37 · Despliegue deshabilitado a propósito y sin plan de rollback ni release repetible
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/smarthome-backend:.github/workflows/ci-deploy.yml:43`
- **Por qué importa:** El job deploy tiene 'if: false' en backend y web, las imágenes solo se etiquetan dev y SHA en ghcr, no hay compose de producción, ni versionado semántico, ni procedimiento de reversa; docs/IMPLEMENTACION_HU09.md del backend lo condiciona a una auditoría de backup y restauración del VPS que sigue pendiente. T-7.4 queda en FAIL.
- **Cómo cerrarlo (L):** Escribir un docker-compose de producción (backend, web, BD), habilitar el deploy a un entorno de staging y documentar el rollback (imagen anterior por SHA y reversa de changesets).

### [Medio] H-38 · El repo de base de datos no tiene CI ni validación automática de los changelogs
- **Repositorio:** `propietario/smart-home-database`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker-compose.yml:49`
- **Por qué importa:** gh api actions/runs devuelve 0 ejecuciones y no existe .github. El esquema es lo único que no se prueba automáticamente aunque todo el backend depende de él (ver H-B04). El último push fue el 2026-06-23, cuatro meses antes del corte.
- **Cómo cerrarlo (S):** Workflow que levante Postgres, ejecute liquibase validate y update desde cero y compruebe el rollback.

### [Medio] H-39 · El pipeline de staging, las métricas protegidas y el endurecimiento de Shelly están en ramas que dev nunca integró
- **Repositorio:** `propietario/smarthome-backend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/HU16_PAIRING_AP_SESSIONS.md`
- **Por qué importa:** Las ramas origin/13-dev (commit 6c1470d, validación del RPC local de Shelly), origin/14-dev (134813b, métricas Prometheus protegidas) y origin/15-dev (38cdfbe, workflow Backend CI de staging con validación de BD) no son ancestro de dev: el árbol del SHA evaluado no contiene src/observability, src/config/shelly-local ni los documentos HU13 a HU15. La rama evaluada no tiene esa operación ni esos controles.
- **Cómo cerrarlo (S):** Integrar 13-dev, 14-dev y 15-dev a dev mediante pull request con revisión, o declarar explícitamente que se descartan.

### [Medio] H-40 · Las migraciones no son incrementales y el rollback no esta atado a Liquibase
- **Repositorio:** `propietario/smart-home-database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/changelog.yaml:18`
- **Por qué importa:** Un changeSet por carpeta ejecuta archivos SQL completos con CREATE TABLE IF NOT EXISTS; los cambios se hicieron editando el DDL (ver REPORTE_VALIDACION.md) y los scripts de 05_rollbacks/ se corren a mano. Ningun changelog declara rollback, asi que liquibase rollback no revierte nada y una BD existente no puede evolucionar sin recrearse.
- **Cómo cerrarlo (M):** Congelar el baseline como changeSet inicial y escribir cada cambio nuevo como changeSet con su bloque rollback.

### [Medio] H-41 · Nombres mezclados espanol e ingles y esquema audit distinto al del backend
- **Repositorio:** `propietario/smart-home-database`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/001_create_auth_tables.sql:182`
- **Por qué importa:** Columnas como recordar_sesion, expira_en, activa, nombre y estado conviven con created_at y refresh_token; el esquema se llama audit aqui e identity_audit en el Prisma. La skill de base de datos del SDLC OS exige identificadores en ingles y consistentes.
- **Cómo cerrarlo (M):** Fijar el idioma de los identificadores en un ADR y renombrar con changeSets; mantener un solo nombre de esquema entre BD y Prisma.

### [Medio] H-42 · OpenAPI incompleto y apagado por defecto en produccion
- **Repositorio:** `propietario/smarthome-backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main.ts:52`
- **Por qué importa:** Solo 29 de 64 endpoints tienen @ApiOperation; auth (13), homes (10), invitations (3), users (5) y permisos (4) no llevan resumen ni respuestas; varios @ApiOkResponse no declaran tipo. En produccion Swagger solo se publica con SWAGGER_ENABLED=true, de modo que el contrato consultable no existe para web y movil, y ya hay dos desajustes por contratos mantenidos a mano.
- **Cómo cerrarlo (M):** Documentar todos los controladores con ApiOperation y tipos de respuesta, exportar openapi.json en CI y generar o validar los clientes web y movil contra el.

### [Bajo] H-43 · Entregables duplicados y mal nombrados en las ramas de documentación
- **Repositorio:** `propietario/smart-home-docs`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:1`
- **Por qué importa:** docs/11-despliegue trae cuatro versiones del mismo documento (v1.0, SENA, SENA.1.2docx y su .docx), docs/01-requisitos nombra un .docx como .md con sufijo '(1)', docs/05-artefactos-codigo contiene solo 'WhatsApp Image 2026-10-09 at 9.55.06 AM.jpeg' y docs/03-propuesta-tecnica incluye costos_proyecto_smart_home (1).xlsx. Impacto: No hay una versión vigente identificable de cada documento y 'artefactos de código' no contiene artefactos.
- **Cómo cerrarlo (S):** Dejar una versión por documento con nombre estable, y reemplazar la imagen por los artefactos reales (enlaces a los repositorios, SHA entregados).

### [Bajo] H-44 · El web nació como una exportación de Figma Make subida en un solo commit
- **Repositorio:** `propietario/smarthome-frontend-web`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web/ATTRIBUTIONS.md:1`
- **Por qué importa:** a1f67af 'Add frontend web' (58 archivos, +9 271) incluye ATTRIBUTIONS.md de Figma Make, web/guidelines/Guidelines.md sin completar y default_shadcn_theme.css. A favor del equipo: conserva la atribución. Impacto: Los 58 archivos se presentan como trabajo propio y su origen solo se deduce de un archivo de atribución; parte de ese andamiaje (guidelines, tema por defecto) no se usa.
- **Cómo cerrarlo (S):** Documentar en el README el origen (Figma Make + shadcn/ui) y borrar los archivos de plantilla que no se usen.

### [Bajo] H-45 · El descubrimiento de Shelly corre en el servidor y solo sirve si el backend esta en la misma LAN
- **Repositorio:** `propietario/smarthome-backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/modules/devices/infrastructure/shelly/shelly-discovery.service.ts:8`
- **Por qué importa:** GET /homes/:homeId/shelly/discover usa bonjour-service (mDNS) desde el proceso del backend; con el backend desplegado en la nube (Dokploy segun el CI) nunca vera los enchufes del hogar del usuario. El diseno LAN-first tiene sentido en el movil (ya lo hace add-device.tsx), no en el servidor.
- **Cómo cerrarlo (S):** Retirar o marcar como solo desarrollo el endpoint de discover y dejar el descubrimiento local en el cliente.

### [Bajo] H-46 · Cuenta demo en el historial y registro verboso del canal BLE en el móvil
- **Repositorio:** `propietario/from_movil`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lib/pairing/shelly-gatt-rpc.ts:175`
- **Por qué importa:** El commit c2ce1cd añadió loginDemoAccount con un correo y una contraseña literales (ya eliminada del árbol; solo queda el texto de respaldo del correo en app/(tabs)/(main)/profile.tsx:233). shelly-gatt-rpc.ts tiene decenas de console.log con trazas del protocolo; no se observó que impriman credenciales Wi-Fi, pero son ruido y superficie de fuga en builds de producción.
- **Cómo cerrarlo (S):** Reescribir el historial si se quiere limpio, y proteger los console.log con __DEV__.

### [Bajo] H-47 · RolesGuard registrado y sin uso; el modelo de roles de BD no gobierna ningún endpoint
- **Repositorio:** `propietario/smarthome-backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/modules/auth/auth.module.ts:82`
- **Por qué importa:** Ningún controlador usa @Roles (git grep: 0). La autorización real es por membresía del hogar vía RLS y funciones SQL, lo cual es válido, pero el código muerto sugiere un control que no existe y el claim role del JWT no se usa para decidir nada.
- **Cómo cerrarlo (S):** Eliminar RolesGuard y el decorador, o documentar en docs/ROLES_Y_PERMISOS.md que la autorización es por membresía y que el rol global no concede acceso.

### [Bajo] H-48 · El nginx del frontend no envía cabeceras de seguridad
- **Repositorio:** `propietario/smarthome-frontend-web`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web/nginx.conf:40`
- **Por qué importa:** Los únicos add_header son Cache-Control; no hay Content-Security-Policy, X-Content-Type-Options, X-Frame-Options ni Referrer-Policy. helmet protege el API pero no la página. Con el token en localStorage (H-B06) una CSP es la mitigación principal ante XSS.
- **Cómo cerrarlo (S):** Añadir las cabeceras en el server de nginx (CSP restrictiva, nosniff, frame-ancestors none).

### [Bajo] H-49 · Ninguna de las 43 claves foraneas declara politica ON DELETE
- **Repositorio:** `propietario/smart-home-database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/002_create_homes_tables.sql:22`
- **Por qué importa:** git grep -i 'ON DELETE' en 01_ddl/03_tables devuelve 0 coincidencias frente a 43 FOREIGN KEY. Funciona porque todo es borrado logico, pero el comportamiento queda implicito (NO ACTION) y no esta decidido por el modelo.
- **Cómo cerrarlo (S):** Declarar RESTRICT, CASCADE o SET NULL en cada FK segun el modelo logico.

### [Bajo] H-50 · Formato de error y paginacion no uniformes
- **Repositorio:** `propietario/smarthome-backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main.ts:45`
- **Por qué importa:** No hay filtro global de excepciones: conviven el formato de Nest (statusCode, message, error) y objetos con code y message ad hoc; login y refresh responden 201; solo notificaciones y consumo aceptan limit, sin offset ni cursor.
- **Cómo cerrarlo (S):** Anadir un filtro global con el formato de error del equipo y HttpCode 200 en login y refresh; definir una paginacion comun.

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 68.8 |
| D2 | Reproducibilidad | 63.4 |
| D3 | Arquitectura y congruencia | 41.7 |
| D4 | Calidad de código | 65.2 |
| D5 | Seguridad | 75.7 |
| D6 | Pruebas | 43.3 |
| D7 | DevOps y despliegue | 53.8 |
| D8 | Datos | 65.0 |
| D9 | API y contratos | 65.0 |
| D10 | Frontend y móvil | 62.5 |
| D11 | IoT y firmware | — |
| D12 | Documentación y trazabilidad | 54.4 |
| D13 | Proceso y colaboración | 55.3 |
| D14 | Extremo a extremo | 0.0 |

## Lo que está bien

- Backend con capas hexagonales y casos de uso por modulo (`propietario/smarthome-backend:src/modules/auth/application/use-cases/login-user.use-case.ts; propietario/smarthome-backend:src/modules/auth/domain/ports/password-hasher.port.ts; propietario/smarthome-backend:src/modules/auth/infrastructure/security/argon2-password-hasher.ts`)
- Validacion de entrada global estricta y parametros UUID validados (`propietario/smarthome-backend:src/main.ts:45; propietario/smarthome-backend:src/modules/homes/presentation/http/homes.controller.ts:150`)
- Cliente movil con contrato correcto para auth, consumo, notificaciones y dispositivos, y nombres de eventos Socket.IO iguales a los del servidor (`propietario/from_movil:lib/services/notifications-service.ts:55; propietario/from_movil:lib/services/consumption-service.ts:68; propietario/from_movil:lib/services/realtime-service.ts:25`)
- El movil declara con honestidad lo que aun no esta integrado (pairing y favoritos lanzan error explicito, sin mocks) (`propietario/from_movil:lib/services/pairing-service.ts:19; propietario/from_movil:lib/config/api-config.ts`)
- BD con estructura Liquibase por capas, 127 indices, 69 CHECK, RLS por tabla y scripts de rollback, backup y restore (`propietario/smart-home-database:01_ddl/09_indexes/003_devices_indexes.sql; propietario/smart-home-database:03_dcl/02_policies/002_rls_devices.sql; propietario/smart-home-database:scripts/rollback.ps1`)
- Pruebas e2e del backend contra PostgreSQL real para sesiones, consumo y alcance de dispositivos (`propietario/smarthome-backend:test/session-flow-postgres.e2e-spec.ts; propietario/smarthome-backend:test/consumption-access-postgres.e2e-spec.ts`)
- Documentos tecnicos por HU que enlazan decisiones, riesgos y pendientes del backend (`propietario/smarthome-backend:docs/HU16_PAIRING_AP_SESSIONS.md; propietario/smarthome-backend:docs/INFORME_01_AUDITORIA_BACKEND_BD_2026-10-12.md`)
- Autenticación de servidor completa y verificable: firma, estado de cuenta, versión de sesión y familia de refresh (`src/modules/auth/presentation/http/guards/jwt-auth.guard.ts:49 y :80 (propietario/smarthome-backend); pruebas en test/session-security-postgres.e2e-spec.ts`)
- Contraseñas con Argon2id, bloqueo tras 5 intentos y límites por ruta (login 10/min) (`src/modules/auth/infrastructure/security/argon2-password-hasher.ts:9; src/security/rate-limit.policy.ts:4 (backend)`)
- Refresh token en cookie httpOnly, nunca en el JSON de login (`src/modules/auth/presentation/http/auth.controller.ts:144 (backend)`)
- Validación de entrada estricta: ValidationPipe con whitelist, 35 DTO, ParseUUIDPipe y consultas parametrizadas (`src/main.ts:39 y src/modules/homes/presentation/http/homes.controller.ts:91 (backend)`)
- Aislamiento de datos por usuario con RLS (app.current_user_id) y transacciones por petición (`src/infrastructure/database/prisma/prisma-rls.service.ts:15 (backend); 03_dcl/02_policies/001_rls_homes.sql:28 (BD)`)
- Configuración que falla cerrada en producción: secreto JWT de 32+ bytes, CORS explícito, HTTPS y MQTT con TLS obligatorios (`src/config/runtime-config.ts:119 y :154; src/config/mqtt-config.ts:99 (backend)`)
- Pruebas de seguridad de alta calidad en el backend: revocación de sockets, carreras de sesión, rate limit, namespace MQTT (`test/realtime-security.e2e-spec.ts, test/realtime-session-races.e2e-spec.ts, test/rate-limit.e2e-spec.ts (backend); cada HU lleva su documento con los casos probados (docs/HU09_SESSION_FAMILIES.md)`)
- Imágenes Docker multietapa, sin root y con HEALTHCHECK en backend y web; endpoints /health/live y /health/ready (`Dockerfile:19 (backend); web/Dockerfile:10 y :17 (frontend); src/health/health.controller.ts:9`)
- Móvil: token de sesión en expo-secure-store y HTTPS obligatorio en builds de producción (`lib/session/session-store.ts:123; lib/config/api-config.ts:35 (móvil)`)
- Móvil: workflow del APK con acciones fijadas por SHA y permisos mínimos; suites de lógica con aserciones reales (`.github/workflows/android-poc-apk.yml:16; scripts/navigation-auth-policy.test.js:12 (móvil)`)
- Auditoría de seguridad propia y documentación de decisiones por HU en el backend (rate limiting, familias de sesión, TLS MQTT) (`docs/INFORME_01_AUDITORIA_BACKEND_BD_2026-10-12.md:201; docs/HU10_MQTT_TLS_NAMESPACE.md (backend)`)
- El móvil tiene un flujo de autenticación completo y seguro (`lib/session/session-store.ts:1 (expo-secure-store), lib/api/api-client.ts:141 (refresh ante 401), lib/services/auth-service.ts:243 (logout y logout-all en el servidor) - repo propietario/from_movil`)
- El móvil impide compilar producción con una URL de desarrollo (`lib/config/api-config.ts:7 - guardia que exige HTTPS público y rechaza localhost, IP y marcadores`)
- Pantallas del móvil con carga, error, vacío y confirmación antes de borrar, y accesibilidad extendida (`app/(tabs)/(main)/homes.tsx:495 (estados) y 178 apariciones de accessibilityLabel/Role en app/ y components/`)
- El backend tiene arquitectura por capas, Dockerfile multi-etapa sin root con healthcheck y .env.example completo (`Dockerfile:1, .env.example:1, src/modules/devices/presentation/controllers/devices.controller.ts:1 - repo propietario/smarthome-backend`)
- API documentada con Swagger y contrato MQTT escrito (`src/main.ts:60 (89 decoradores @Api* en 24 archivos) y docs/MQTT_CONTRACT.md:1 - repo propietario/smarthome-backend`)
- La BD se levanta con un comando y tiene versiones fijadas y rollbacks (`README.md:36, docker-compose.yml:31, docker/liquibase/Dockerfile:1, carpeta 05_rollbacks/ - repo propietario/smart-home-database`)
- El SRS es completo: 52 requisitos funcionales con actores, prioridad y criterios de aceptación, más 9 requisitos no funcionales (`Rama origin/docs/01-requisitos de smart-home-docs, documento docs/01-requisitos/SRS_SMART_HOME_ACTUALIZADO_2026 (1).md`)
- Trabajo repartido entre tres integrantes con actividad en las ocho semanas (`git shortlog -sne --all --no-merges: 72/65/21 commits; commits en las semanas ISO 36 a 43`)
- El web conserva la atribución de Figma Make y shadcn/ui y su Docker usa Nginx sin privilegios (`web/ATTRIBUTIONS.md:1 y web/Dockerfile:1 - repo propietario/smarthome-frontend-web`)

## Lo que no se pudo verificar

- Que la BD declarada levanta con setup.ps1 y que el backend corre contra ella — Exige ejecutar Docker y Liquibase; la incompatibilidad se deduce de comparar prisma/schema.prisma con el DDL, no de una ejecucion.
- Contenido y compatibilidad del repo propietario/smarthome-database (ramas 09-dev a 16-dev, push 2026-10-22) — No esta declarado en PROYECTOS-FICHA-3145555.md; solo se confirmo con gh api que existe, que es publico y sus ramas. Su compatibilidad con el backend se infiere de la documentacion del backend.
- Modelo entidad-relacion (MER), mapa de procesos y wireframes — Estan en carpetas de Google Drive no accesibles; T-3.6 se evaluo contra el Informe de Diseno (.docx en la rama docs/04-diseno-software).
- URL de despliegue en linea — El documento de despliegue presenta el dominio smarthome.sena.edu.co como previsto; no se hizo ningun GET porque el equipo no declara un despliegue vigente.
- Renovacion de sesion con cookie httpOnly desde la app nativa y comportamiento real del realtime — Requiere ejecutar la app y un backend en vivo.
- Integracion web 12-dev contra el backend — Solo se inspeccionaron la lista de archivos y las rutas de sus clientes API; no es la rama evaluada.
- Contenido de las ramas 11 a 15-dev del backend y 03-dev del movil — Se revisaron mensajes de commit y estadisticas del diff, no el codigo completo.
- Resultado real de las pruebas y su cobertura — No se permite ejecutar el código de los aprendices (npm, jest, node); solo se evaluó por lectura.
- Despliegue en línea (T-7.4) y comportamiento de Dokploy/VPS — El equipo no declara ninguna URL y el job de deploy está deshabilitado; no hay nada que consultar con GET.
- Si las credenciales, correos y claves de los documentos Word en las ramas docs/06-pruebas y docs/07-implementacion están en uso en algún entorno real — Probarlas exigiría autenticarse en servicios; la rúbrica solo permite lecturas. Se trata como exposición (H-B01) sin afirmar que sean activas.
- Si la contraseña de Postgres de .env.shared es solo un ejemplo o el valor real de algún entorno — Es idéntica a la de .env.example; no hay forma de saber desde el repo qué entorno la usa.
- Vulnerabilidades conocidas de las dependencias (npm audit) y de las imágenes — Exigiría ejecutar npm o una herramienta contra el registro; solo se revisaron versiones por lectura.
- Que el login falle con los usuarios sembrados en bcrypt (H-B13) — Requiere ejecutar el backend contra una BD; inferido de que el verificador es solo argon2.
- Otras ramas del repo de docs (15 ramas) y del repo de BD (qa, main) más allá de los parches escaneados con git log -G — Los documentos Word son binarios comprimidos; se leyeron solo los dos commits que el escaneo de credenciales señaló.
- D11 (IoT y firmware) — Ningún repositorio declarado es de tipo iot; los dispositivos son Shelly comerciales y el aprovisionamiento BLE vive en el móvil (se evalúa en D10 por el especialista C).
- Contenido de los documentos .docx de smart-home-docs distintos de SRS, diseño y propuesta (pruebas, manuales, mantenimiento, artículo, despliegue, términos) — Solo se extrajo el texto del SRS, del informe de diseño y de la propuesta técnica; los demás no se leyeron y no se puntúan.
- Repositorio propietario/smarthome-database (activo, push 2026-10-22) que backend y docs usan como BD — El equipo no lo declaró; no se evaluó ni se construyeron hallazgos sobre él. Solo se verificó que existe (gh api) y que lo citan el .gitignore y los documentos del backend y el README de docs.
- Credenciales de .env.shared de smart-home-database y su historial — Corresponde a D5 (especialista B); aquí solo se registra el archivo (H-C10) y su valor no se cita.
- Desajuste de esquema entre la BD declarada y prisma/schema.prisma del backend (refresh_token ausente) — Corresponde a D3/D8/D14 (especialista A); se usó solo para el hallazgo de reproducibilidad H-C02.
- Workflow Mobile CI en rojo (paso Lint) sobre el SHA a4c6b065cd del móvil — Es D7 (especialista B); se menciona solo en R-10.1.
- Si los PR abiertos del backend (11-dev a 15-dev) y la rama 12-dev del web funcionan — Solo se leyó su lista de commits y archivos; el código no se ejecuta y no es el SHA evaluado.
- Compilación real, renderizado, accesibilidad efectiva y responsive de web y móvil — No se puede ejecutar el código de los aprendices; se juzgó por configuración, CI y lectura.
- Tablero GitHub Projects y lista de colaboradores de los repositorios — gh api devolvió 403 para collaborators y no hay permiso para leer Projects v2.
- Muestreo de D4 — Se leyó con profundidad el suscriptor MQTT del backend (949 líneas) y homes.tsx, el contexto y la lista de pantallas mayores del móvil (los componentes mayores por líneas); el web se revisó por búsquedas, y no se leyeron los demás archivos.
- Despliegue en línea del equipo — El equipo no declara ninguna URL de despliegue, por eso no se hizo ningún GET.
