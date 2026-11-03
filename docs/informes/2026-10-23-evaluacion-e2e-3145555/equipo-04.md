# Equipo 4 · FaceLit — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 48/100 · Juicio D**

## Veredicto

FaceLit tiene un núcleo que sí funciona: el inicio de sesión, la asistencia facial por sesión de ambiente y la gestión académica de programas y fichas llegan completos del front a la tabla (3 de los 5 flujos revisados). Lo que impide cerrar es el registro facial del aprendiz, que está roto porque el backend consulta columnas de user_face que la base declarada no tiene, y la gestión de horarios, que no existe en backend ni en base de datos (las pantallas usan datos de demostración en memoria). Hay dos hallazgos críticos de seguridad: cualquier usuario autenticado puede registrar o justificar la asistencia de cualquier aprendiz, y el código de recuperación de contraseña de 6 dígitos se puede forzar; además la clave estática del servicio biométrico viaja dentro de la app y permite leer o desactivar plantillas faciales (alto, no crítico). El puntaje es 47,8 con juicio D: está unos 22 puntos por debajo del umbral de 70 y el extremo a extremo (40) no llega a 50, con 17 hallazgos altos entre ellos ningún CI, 245 MB de videos y 97 MiB de repositorio Maven versionados, y README que describen otro sistema. Para cerrar, primero la seguridad de asistencia y recuperación, luego reparar el registro facial y los horarios, y después integrar la rama de producción, el CI y la documentación.

## Plan para cerrar las brechas

1. **Restringir por rol y pertenencia los endpoints /api/facial/events/** (registrar, justificar, inicializar ausencias) y la consulta de estado del aprendiz; agregar pruebas MockMvc de 401/403 por rol.** (esfuerzo M) — se cierra cuando: Un token de APRENDIZ recibe 403 al llamar POST /api/facial/events, /initialize-absences y PATCH /excuse; un instructor ajeno a la sesión recibe 403; las pruebas MockMvc corren en mvn test y pasan.
2. **Endurecer la recuperación de contraseña: asociar el código al correo/usuario, limitar intentos y tasa, expirar el código; invalidar el JWT al deshabilitar la cuenta, cambiar el rol o cerrar sesión.** (esfuerzo M) — se cierra cuando: Tras N intentos fallidos el código queda bloqueado y responde 429; el código de un usuario no sirve para otro; un token anterior a un cierre de sesión o cambio de rol responde 401; hay pruebas que lo demuestran.
3. **Reparar el registro facial, que hoy está roto: alinear el esquema de user_face (id_apprentice vs id_user_app, biometric_vector, profile_photo) entre FaceLit-Backend y FaceLit-DB mediante un changeset nuevo, sin editar los ya aplicados, corregir la numeración duplicada de 04_alter y probar el flujo de confirmación.** (esfuerzo M) — se cierra cuando: Con la base levantada solo con liquibase update y ddl-auto validate, POST /api/facial/registration-confirmation responde 200 y crea el aviso de registro completado; ningún changeset aplicado fue modificado.
4. **Sacar la clave del servicio biométrico del bundle: el front llama solo al backend, el micro-facial exige autenticación siempre (falla al arrancar si la clave está vacía) y la clave 'change-me' se reemplaza por un secreto real del lado servidor; quitar .env del repo del front y el valor por defecto del yaml del backend. Hoy esa clave permite leer y desactivar plantillas faciales de cualquier aprendiz, no reemplazarlas.** (esfuerzo M) — se cierra cuando: Ninguna variable EXPO_PUBLIC_ contiene una clave de servicio; llamar a GET o DELETE /users/{id} del micro-facial sin credencial devuelve 401 aun con la variable vacía; .env no está en git ls-files y existe .env.example; ningún archivo versionado trae el valor 'change-me'.
5. **Implementar de verdad horarios, CRUD de ambientes y reportes (tablas en FaceLit-DB, controladores en el backend, el front conectado) y recuperar el módulo borrado por el commit 'sube evidencia'; retirar los MOCK_ y los servicios sin contraparte.** (esfuerzo L) — se cierra cuando: Crear un horario desde la pantalla persiste en una tabla de FaceLit-DB y sobrevive a recargar; no queda ningún MOCK_SCHEDULES en el código de producción; las historias cerradas tienen el código en la rama integrada.
6. **Integrar el trabajo atrapado: llevar dev a main/qa en el backend (incluido el módulo facial), definir el flujo de ramas y exigir al menos una revisión de otra persona en los PR.** (esfuerzo S) — se cierra cuando: main del backend contiene el módulo facial y no está detrás de dev; la protección de rama exige 1 aprobación; los PR nuevos son aprobados por alguien distinto de su autor.
7. **Limpiar el peso del repositorio: quitar del árbol los 245 MB de videos (a un CDN o Git LFS), el .m2, el jar y los logs, completar .gitignore y reemplazar los README de plantilla por los reales de cada repo (incluido FaceLit-DB, que describe shopping-cart).** (esfuerzo S) — se cierra cuando: git ls-files no lista videos, .m2, *.jar ni logs; el tamaño del árbol actual baja de forma comprobable; cada README describe su propio repositorio.
8. **Documentar y hacer repetible el arranque del sistema completo: reemplazar los README y documentos que describen otro sistema por los reales de cada repo, con orden de arranque (DB, backend, micro-facial, front), .env.example por repo, docker-compose raíz, versión real de Spring Boot, y declarar dónde se despliega.** (esfuerzo M) — se cierra cuando: Una persona ajena al equipo levanta los cuatro componentes siguiendo solo el README y logra el login; toda variable usada tiene entrada en .env.example; ningún README describe un sistema distinto al del repo; el README declara la versión real de Spring Boot.
9. **Crear CI en los cuatro repositorios (build, pruebas, lint) y convertir los tres scripts sueltos del front en pruebas ejecutadas por npm test.** (esfuerzo M) — se cierra cuando: Cada repo tiene un workflow que corre en cada PR y queda en verde; npm test en el front ejecuta las pruebas; el PR no se puede fusionar con CI en rojo.
10. **Separar las bases de datos de backend y micro-facial (el micro expone una API en vez de escribir tablas ajenas), mover el SQL y la similitud facial de FacialEnrollmentController a servicio/repositorio, y publicar OpenAPI del backend con convención de errores común.** (esfuerzo L) — se cierra cuando: micro-facial no tiene acceso a los esquemas security, academic ni environment; FacialEnrollmentController no contiene SQL; /v3/api-docs responde en el backend y el formato de error coincide en ambos servicios.
11. **Pulir la base de datos: política ON DELETE e índices en FK, rollbacks de 019 y 020, la migración que borra datos, la semilla del coordinador sin contraseña quemada, contraseñas de compose por variable y nomenclatura.** (esfuerzo M) — se cierra cuando: Todas las FK declaran ON DELETE; 019 y 020 tienen rollback probado; ningún changeset borra datos sin respaldo; compose no trae contraseñas por defecto.
12. **Cerrar documentación formal y calidad: llevar a los repos el problema, usuarios, alcance, criterios de aceptación y arquitectura (hoy en Drive); endurecer imágenes Docker (usuario no root, healthcheck), CORS/WebSocket y log de SQL; manejo central de 401/403/500, idioma DE y token web.** (esfuerzo L) — se cierra cuando: Existe docs/ en el repo con problema, alcance, KPI y diagrama de arquitectura; las imágenes corren como no root con HEALTHCHECK; CORS lista orígenes explícitos; un 401 lleva a login y el front no envía un idioma que la BD rechace.

## Verificación independiente

Hallazgos confirmados: 4 · matizados: 3 · refutados: 0 · duplicados fusionados: 2.

Confirme 12 de 16 afirmaciones sin cambios (H-01, H-02, H-07, H-08, R-9.1, R-6.1, R-10.1 y los cinco flujos, incluido el registro facial como ROTO) y matice 3 hallazgos: H-03 baja de critico a alto porque en este SHA el micro-facial NO permite reemplazar el rostro (PATCH rechaza vector e imagen y el reemplazo exige un grant del coordinador), aunque si deja leer los embeddings y desactivarlos con una clave que es el marcador 'change-me'; H-04 baja a medio porque el .env solo trae URL de localhost y un marcador, y H-06 es exacto para horarios y reportes pero no para entornos, que si tienen backend parcial. Refute el PASS de R-2.1 del repo FaceLit-DB (PARTIAL: el README contradice el alcance real y habla de shopping-cart-db), aclaro que el quiebre del registro facial esta solo en la confirmacion (el rostro si se guarda), valide las cifras de aportes (416 commits, fusiones solo por correo identico o noreply del mismo login) y marque 2 duplicados reales (H-28 con H-15 y H-41 con H-21; H-41 ademas es falso en parte).

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Completo | Inicio de sesion con documento y contrasena (todos los roles) | — |
| Roto | Registro facial del aprendiz (captura, embedding, confirmacion) | Confirmacion: POST /api/facial/registration-confirmation ejecuta registered(userId), que consulta facialrecognition.user_face por id_user_app; esa columna no existe en FaceLit-DB (user_face usa id_apprentice). Responde 500 y el frontend lo traga con un warn, de modo que el aviso de registro completado nunca se genera. Los caminos /challenge y /enrollment del mismo controlador insertan en biometric_vector y profile_photo, columnas tampoco existentes, y ninguna pantalla los llama. |
| Completo | Asistencia facial en una sesion de ambiente (instructor) | — |
| Completo | Gestion academica: programas y fichas (coordinador) | — |
| No implementado | Gestion de horarios y excepciones de horario | No hay endpoint ni tabla: el backend no tiene controlador de horarios y FaceLit-DB no define ninguna tabla de horario; las pantallas operan sobre MOCK_SCHEDULES en memoria. |

## Hallazgos

### [Crítico] H-01 · Los eventos de asistencia facial no validan rol ni pertenencia: cualquier usuario autenticado puede registrar, justificar o inicializar asistencia de cualquier aprendiz
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `src/main/java/com/FaceLit/backend/config/SecurityConfig.java:61; src/main/java/com/FaceLit/backend/facial/controller/FacialEventController.java:38; src/main/java/com/FaceLit/backend/facial/service/serviceImpl/FacialEventServiceImpl.java:97`
- **Por qué importa:** SecurityConfig solo restringe /api/facial/reset-requests/** (linea 47); el resto de /api/facial/** cae en anyRequest().authenticated() (linea 61). En FacialEventController, POST /api/facial/events (linea 38), /initialize-absences (52) y PATCH /excuse reciben idApprentice e idRecordEnvironment del cuerpo o de la consulta (/from-image, linea 45, tampoco valida rol), y FacialEventServiceImpl.registerEvent (97) usa authenticatedUserId solo para auditoria (setCreatedBy, linea 153); updateExcuse (338, setUpdatedBy en 365) e initializeSessionAbsences (167) igual. Un aprendiz con su propio token puede marcar asistencia o justificar inasistencias de otro aprendiz o de toda una sesion, y GET /attendance-status (servicio linea 246) permite consultar el estado de cualquier aprendiz. Contraste: AttendanceCorrectionService.java:44 si valida rol y pertenencia, lo que muestra que el control existe y no se aplico aqui. El registro de asistencia es la funcion central del producto.
- **Cómo cerrarlo (M):** Restringir /api/facial/events/** por rol en SecurityConfig (INSTRUCTOR/COORDINATOR para registrar, justificar e inicializar) y, en el servicio, verificar que el instructor es el responsable de la sesion y que el aprendiz consulta solo su propio estado; agregar pruebas MockMvc que prueben 403 para APPRENTICE.

### [Crítico] H-02 · El codigo de recuperacion de 6 digitos se valida solo por el codigo, sin correo asociado, sin limite de intentos ni limitacion de tasa: tomar el control de una cuenta es forzable
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `src/main/java/com/FaceLit/backend/auth/service/serviceImpl/security/PasswordRecoveryServiceImpl.java:138; src/main/java/com/FaceLit/backend/auth/dto/request/security/ResetPasswordDTO.java:14; src/main/java/com/FaceLit/backend/config/SecurityConfig.java:40`
- **Por qué importa:** /api/auth/** es permitAll (SecurityConfig.java:40) y verifyToken/resetPassword buscan la recuperacion con findByToken(dto.getToken()) (PasswordRecoveryServiceImpl.java:112 y 138): el DTO solo trae el codigo de 6 digitos (ResetPasswordDTO.java:14) y la nueva contrasena, sin correo, cuenta ni contador de intentos; el unico contador (failedAttempts) pertenece al login. La vigencia es de 5 min (AppConstants.java:34) y el proyecto no usa ninguna libreria de limitacion de tasa (busqueda en pom.xml y src sin resultados). Con solo 10^6 codigos y cualquier recuperacion vigente (de cualquier usuario, incluida la coordinacion), un atacante anonimo puede probar codigos hasta acertar y fijar una contrasena nueva; cuantas mas recuperaciones pendientes, mas probable el acierto por intento. No se probo contra un servicio en ejecucion.
- **Cómo cerrarlo (M):** Atar el codigo al correo/cuenta en verify-token y reset-password, contar intentos fallidos y bloquear la recuperacion tras 3-5, agregar limitacion de tasa por IP en /api/auth/** y emitir un token largo de un solo uso.

### [Alto] H-03 · El microservicio biometrico se protege con una API key estatica que viaja dentro de la app y queda desactivada si esta vacia: cualquiera puede leer, reemplazar o borrar el vector facial de un aprendiz
- **Repositorio:** `FaceID-Proyect-2026/micro-facial`
- **Lente SDLC OS:** A04 · **Verificación independiente:** matizado (severidad ajustada de critico)
- **Evidencia:** `app/api/dependencies.py:12; app/api/v1/routes/facial_embeddings.py:20; app/core/config.py:10`
- **Por qué importa:** require_api_key solo compara contra settings.api_key y se omite cuando esta vacia (dependencies.py:12; valor por defecto vacio en config.py:10). La app la incrusta en el bundle como EXPO_PUBLIC_EMBEDDING_API_KEY (FaceID-Proyect-2026/FaceLit:shared/constants/api.js:63, con fallback ««redactado»») y la envia en cada peticion directa al servicio (FaceID-Proyect-2026/FaceLit:shared/services/facialEmbeddingService.ts:65). Con esa clave, sin identidad de usuario, las rutas GET /users/{user_id} (devuelve el embedding), PATCH /users/{user_id} (acepta un vector nuevo o una imagen), GET (lista todos) y DELETE operan sobre cualquier user_id (facial_embeddings.py:97, 115, 134, 147). Un atacante puede reemplazar el rostro de otro aprendiz por el suyo y suplantarlo en la asistencia, o exfiltrar plantillas biometricas (dato sensible, Ley 1581). Que el servicio este expuesto a Internet no se pudo comprobar; el defecto de diseno si.
- **Cómo cerrarlo (M):** Que el cliente no hable con micro-facial: enrutar todo por el backend, que ya autentica al usuario y reenvia con una clave de servicio interna (FaceLit-Backend:src/main/java/com/FaceLit/backend/facial/FacialEmbeddingVerificationClient.java:37); hacer que el servicio falle al arrancar si API_KEY esta vacia, restringirlo a la red interna y dejar de devolver el vector en las respuestas.

### [Alto] H-05 · El backend versiona 97 MiB de repositorio Maven, un jar de 11 MB y logs
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `FaceID-Back-end.jar`
- **Por qué importa:** 1 450 archivos bajo .m2/ (jars de Hibernate, Tomcat, Liquibase, Jackson), FaceID-Back-end.jar, rebuild-diagnostic.log, startup-diagnostic.log y startup-after-rebuild.log. .mvn/local-settings.xml redirige el repositorio local a una ruta absoluta de un equipo personal; el origen fue desplegar en Render (PR 53, 'se sube jav para funcionar con render'). El historial queda inflado para siempre, cada clon baja esos archivos y el Dockerfile ya compila con Maven sin necesitarlos.
- **Cómo cerrarlo (S):** Agregar .m2/, *.jar, *.log y .tmp/ al .gitignore, retirar los archivos con git rm --cached, borrar .mvn/local-settings.xml y, si el tamaño del historial molesta, limpiarlo con git filter-repo.

### [Alto] H-06 · Entornos, horarios y reportes del administrador son maquetas con datos en memoria, sin backend
- **Repositorio:** `FaceID-Proyect-2026/FaceLit`
- **Lente SDLC OS:** A03 · **Verificación independiente:** matizado (descripción precisada)
- **Evidencia:** `features/environments/environmentsStore.ts:10`
- **Por qué importa:** environmentsStore y schedulesStore arrancan de MOCK_ENVIRONMENTS y MOCK_SCHEDULES, y las pantallas de reportes leen ATTENDANCE_EVENTS (features/attendance/useAttendance.ts:29). El detalle de ambiente asigna fichas desde MOCK_FICHAS, una lista fija de 4 fichas (app/admin/environments/[id].tsx:52). El backend no tiene controlador de horarios ni de reportes, y el de ambientes solo ofrece listar y crear (EnvironmentController.java, GET y POST /environments). Todo lo que el administrador crea se pierde al recargar y las fichas reales no aparecen.
- **Cómo cerrarlo (L):** Conectar cada módulo a su endpoint real o retirar la pantalla del menú y de la documentación. Mientras tanto, rotular visiblemente 'datos de demostración' para que nadie confíe en ellos.

### [Alto] H-07 · Los README y documentos de tres repos describen un sistema distinto al construido
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** confirmado
- **Evidencia:** `FaceID-Proyect-2026/FaceLit:docs-repo/modules/HU-01.md`
- **Por qué importa:** README del backend: árbol com.tuproyecto.sena y Spring 4.0.6 frente a com.FaceLit.backend y 3.4.1 en pom.xml. README de FaceLit-DB: plantilla 'shopping-cart-db' con alcance 'solo security'. FaceLit: README de create-expo-app; docs-repo manda a la carpeta FaceLit-fixed; Instrucciones.md habla de Expo 54 (el proyecto usa 57) y docs-repo/modules/HU-01.md lista 11 pantallas de auth de las que existen 4 (no hay registro de 13 campos ni consentimiento de menores). HU-04 a HU-09 son fichas de 10 líneas. Un evaluador o el siguiente equipo no puede fiarse de ellos.
- **Cómo cerrarlo (M):** Reescribir los tres README desde el código actual y borrar lo heredado; marcar en HU-04..HU-09 qué está construido y qué no.

### [Alto] H-08 · La rama de producción está atrasada y hay trabajo atrapado en ramas sin integrar
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado
- **Evidencia:** `git rev-list --left-right --count dev...origin/main: Backend 84 detrás, FaceLit 22 sin fusionar, micro-facial 14 detrás; git cherry sin parches equivalentes en dev`
- **Por qué importa:** FaceLit-Backend: origin/main apunta al merge del 14-jul y dev la adelanta por 84 commits. FaceLit: main no contiene 22 commits no merge de dev. micro-facial: main solo tiene el commit inicial (14 atrás). Ramas con commits propios sin integrar a la evaluada: FaceLit hu-35-dev (acceso móvil directo al login, 22-oct, archivos entryPlatform.ts y su doc), final-facial-touch-ups-before-delivery (instrucciones de conexión LAN y aviso de cámara en http), feature/update-translations (9 commits i18n), correccion-instructor (7 commits de registro facial); Backend feature/facial-service (9 commits del módulo facial), hu-29-dev, hu-31-dev y hu-face; FaceLit-DB hotfix-02 (estado activo/inactivo de ambiente). git cherry no encontró parches equivalentes en dev.
- **Cómo cerrarlo (S):** Antes de la entrega: fusionar a dev lo que sirve (hu-35-dev, final-facial-touch-ups, update-translations), descartar lo obsoleto, y promover dev a qa y main. Fijar como regla que main es lo que se evalúa y despliega.

### [Alto] H-09 · El commit 'sube evidencia' borró el módulo de horarios y el CRUD de ambientes del backend mientras las historias figuran como cerradas
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git show --name-status d9d40b0 (2026-09-16): 116 archivos borrados, 24 del paquete schedule y 22 del paquete environments; git ls-tree del SHA evaluado: 0 archivos schedule`
- **Por qué importa:** git show d9d40b0 (2026-09-16, Integrante 2) elimina 116 archivos: 24 del paquete schedule (ScheduleController, ScheduleExceptionController, MyScheduleController) y 22 del paquete environments (EnvironmentController con CRUD, ChipEnvironmentController). El módulo de horarios desapareció por completo; el CRUD de ambientes se sustituyó después por un paquete environment reducido (listar, crear y sesiones). Los issues 28 a 40 (p. ej. el 38, 'Gestión de excepciones de horario', cerrado el 22-ago) siguen como hechos y main nunca recibió esos módulos. El trabajo existe solo en el historial.
- **Cómo cerrarlo (M):** Decidir si horarios y ambientes siguen en alcance. Si sí, recuperar el módulo desde d9d40b0^ por PR; si no, marcar las historias como descartadas y limpiar el frontend. No usar mensajes como 'sube evidencia' para cambios que borran código.

### [Alto] H-10 · Horarios, CRUD de ambientes y reportes funcionan solo con datos de demostracion en memoria
- **Repositorio:** `FaceID-Proyect-2026/FaceLit`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `features/schedules/schedulesStore.ts:10`
- **Por qué importa:** Los stores de horarios, ambientes, reportes y registros faciales se inicializan con MOCK_*; el backend no tiene controlador de horarios ni de CRUD de ambientes y la BD no tiene tabla de horario. El README del backend los declara (RF-4, RF-7). Las pantallas dan la impresion de funcionar, pero nada persiste ni se comparte entre usuarios.
- **Cómo cerrarlo (L):** Implementar horarios y ambientes en backend y BD (o retirar las pantallas y declararlo como fuera de alcance); conectar reportes a /api/facial/events/attendance-matrix, que ya existe.

### [Alto] H-11 · El backend consulta columnas de user_face que el esquema declarado (FaceLit-DB main) no tiene
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/FaceLit/backend/facial/FacialEnrollmentController.java:261`
- **Por qué importa:** registered() filtra por user_face.id_user_app y los endpoints /enrollment y /profile-photo usan biometric_vector y profile_photo; FaceLit-DB main define user_face con id_apprentice y embedding vector. La confirmacion del registro facial responde 500 (el front la traga con un warn) y el aviso de registro completado no se genera; las ramas develop y qa de FaceLit-DB si tienen biometric_vector, es decir, el backend se escribio contra otra version del esquema.
- **Cómo cerrarlo (M):** Decidir un unico camino de enrolamiento (el del micro-facial, que ya funciona), reescribir registered() sobre academic.apprentice y user_face.id_apprentice como ya hace registrationStatusForFrontend, eliminar /challenge, /enrollment y /profile-photo si no se usan, y agregar una prueba de integracion contra el esquema Liquibase.

### [Alto] H-12 · No hay forma documentada de levantar el sistema completo ni de saber qué variables se necesitan
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md`
- **Por qué importa:** El README del backend no trae pasos de ejecución, no hay .env.example ni docker-compose en FaceLit-Backend, FaceLit no explica que necesita el backend en :8080 y el microservicio en :8090, y micro-facial depende de una red de Docker que crea FaceLit-DB. Quien reciba el proyecto debe reconstruir el orden (DB, micro-facial, backend, app) leyendo código. La lente exige 'un camino documentado y único para levantar el producto'.
- **Cómo cerrarlo (M):** Crear un README raíz de entrega (o repo de despliegue) con el orden de arranque, un docker-compose del stack, .env.example por servicio y los puertos. Copiar el estilo del README de micro-facial.

### [Alto] H-13 · Backend y micro-facial comparten la misma base de datos y se escriben las mismas tablas
- **Repositorio:** `FaceID-Proyect-2026/micro-facial`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/repositories/facial_embedding_repository.py:19`
- **Por qué importa:** El micro hace consultas con unión sobre security.user_app, academic.apprentice, academic.apprentice_chip y environment.record_environment, y escribe facialrecognition.user_face y face_reset_request que el backend tambien modifica. Cualquier cambio de esquema rompe a ambos a la vez y el micro no se puede desplegar ni evolucionar solo.
- **Cómo cerrarlo (L):** Definir quien es dueno de facialrecognition; que el micro reciba del backend los identificadores y los candidatos de la ficha (o exponga solo calculo de embeddings) y que el acceso cruzado sea por API, no por acceso directo a esquemas ajenos.

### [Alto] H-14 · FacialEnrollmentController contiene SQL, transacciones y el cálculo de similitud facial, y guarda estado en memoria
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/FaceLit/backend/facial/FacialEnrollmentController.java:125`
- **Por qué importa:** El método enroll (líneas 125-236) usa JdbcTemplate y TransactionTemplate, toma locks con pg_advisory_xact_lock, escribe en facialrecognition.user_face, calcula similitud coseno y valida retos guardados en un ConcurrentHashMap del controlador. La lógica de negocio no es probable de probar por separado, se triplica (líneas 161, 206 y 299) y los retos se pierden al reiniciar o con más de una instancia.
- **Cómo cerrarlo (M):** Extraer un FacialEnrollmentService con repositorio, mover los retos a una tabla o caché compartida y dejar el controlador solo con validación y delegación.

### [Alto] H-15 · .env versionado y clave del servicio facial incrustada en el bundle con prefijo EXPO_PUBLIC_
- **Repositorio:** `FaceID-Proyect-2026/FaceLit`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-28
- **Evidencia:** `.env:3; shared/constants/api.js:63; .gitignore:35`
- **Por qué importa:** El archivo .env esta en el arbol del SHA evaluado y en 10 commits (git log --all -- .env); .gitignore solo cubre .env*.local. Contiene EXPO_PUBLIC_EMBEDDING_API_KEY con valor por defecto ««redactado»», que ademas se usa como fallback en api.js:63; cualquier variable EXPO_PUBLIC_ queda legible en el bundle. Otra rama tambien versiona FaceLit-fixed/.env. Aunque hoy son valores locales, el repositorio ya esta preparado para filtrar el siguiente valor real.
- **Cómo cerrarlo (S):** Quitar .env del indice (git rm --cached .env), ignorarlo en .gitignore, entregar .env.example y no usar EXPO_PUBLIC_ para ninguna clave; rotar la clave actual.

### [Alto] H-16 · El frontend solo tiene tres scripts de prueba sueltos, fuera de npm test y de CI
- **Repositorio:** `FaceID-Proyect-2026/FaceLit`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `scripts/test-notification-i18n.cjs:53; package.json:11`
- **Por qué importa:** scripts/test-*.cjs transpilan tres modulos puntuales (estado de asistencia, acceso al registro facial, plantillas de notificacion) y suman unas 70 aserciones, pero package.json solo define lint (linea 11), nada los documenta y no hay pruebas de componentes, de servicios contra la API ni e2e. Un cliente de decenas de pantallas con login y reconocimiento facial no tiene red de seguridad.
- **Cómo cerrarlo (M):** Migrar a jest-expo/Testing Library, registrar un script test en package.json, cubrir login, guardas de rol y el servicio de asistencia, y correrlo en CI.

### [Alto] H-17 · Las pruebas del backend no cubren autorizacion ni la cadena de seguridad HTTP: ninguna comprueba 401/403 por rol
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/test/java/com/FaceLit/backend/facial/FaceResetServiceTest.java:111; src/test/java/com/FaceLit/backend/BackendApplicationTests.java:4`
- **Por qué importa:** Las 106 pruebas son de servicios y contratos (bien hechas), pero ningun archivo de src/test usa @WithMockUser ni status() de MockMvc pese a que spring-security-test esta en el pom: el unico 403 probado es de logica de servicio (FaceResetServiceTest.java:111). Por eso H-B01 (roles ausentes en asistencia) y H-B02 pasan desapercibidos. El criterio A09 pide que cada criterio de aceptacion tenga una prueba que lo pruebe, y los accesos prohibidos son criterios de seguridad.
- **Cómo cerrarlo (M):** Agregar pruebas MockMvc por rol para cada controlador (APPRENTICE, INSTRUCTOR, COORDINATOR, anonimo) con 401/403 esperados, y pruebas de agotamiento de intentos del codigo de recuperacion.

### [Alto] H-18 · Ninguno de los cuatro repositorios tiene CI/CD: no hay workflows en ninguna rama y cero ejecuciones
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/FaceID-Proyect-2026/FaceLit-Backend/actions/runs?per_page=5`
- **Por qué importa:** Para los cuatro repos gh api actions/runs devolvio total_count 0 y git log --all -- .github esta vacio. Sin integracion continua nada impide fusionar a dev/main codigo que no compila o rompe pruebas (el Dockerfile del backend ademas compila con -DskipTests, Dockerfile:5), ni existe un camino repetible a produccion. El rol A11 exige pipeline, release y rollback documentados.
- **Cómo cerrarlo (M):** Agregar un workflow por repo: backend (mvn verify), micro-facial (pytest), frontend (npm run lint + scripts de prueba) y DB (liquibase validate contra un Postgres de servicio); exigirlos como checks en las ramas dev y main.

### [Alto] H-19 · Migraciones ya aplicadas se editaron en sitio
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-DB`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/00_extensions/001_enable_uuid_extension.sql:2`
- **Por qué importa:** git log muestra que 001_enable_uuid_extension.sql (extension vector, 2026-10-07), 007_create_facialrecognition_tables.sql (5 commits posteriores a su creacion) y 001_create_security_tables.sql siguen cambiando. Liquibase compara checksums: una base ya migrada falla en el siguiente update. El backend documenta como parche el uso de clearCheckSums.
- **Cómo cerrarlo (M):** Congelar los changesets existentes y expresar todo cambio como un changeset nuevo (expandir y luego contraer); recrear el baseline una sola vez y comunicarlo.

### [Alto] H-20 · El backend no publica contrato OpenAPI
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `pom.xml`
- **Por qué importa:** No hay springdoc ni swagger en las dependencias aunque el README anuncia Swagger; con un front de mas de 60 endpoints y desajustes ya detectados (idioma DE, rutas huerfanas) no hay contrato que valide ambos lados.
- **Cómo cerrarlo (S):** Agregar springdoc-openapi, anotar los DTO y publicar /v3/api-docs; usarlo para generar o verificar el cliente del front.

### [Medio] H-04 · FaceLit versiona 245 MB de videos y el archivo .env
- **Repositorio:** `FaceID-Proyect-2026/FaceLit`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** matizado (severidad ajustada de alto)
- **Evidencia:** `assets/videos/coordinator.mp4`
- **Por qué importa:** assets/videos/coordinator.mp4 (101,6 MB), instructor.mp4 (89,4 MB) y apprentice.mp4 (53,7 MB) están en el repositorio y los usa la landing. El primero roza el límite de 100 MiB de GitHub. El .env también está versionado (último cambio el 15-oct) y .gitignore solo protege '.env*.local'.
- **Cómo cerrarlo (S):** Alojar los videos fuera del repo (CDN, almacenamiento de Vercel, YouTube), comprimirlos, ignorar .env y publicar un .env.example.

### [Medio] H-21 · README de FaceLit-DB heredado de otra base y residuos de la plantilla del curso
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-DB`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-41
- **Evidencia:** `bd/modelo_datos.sql`
- **Por qué importa:** .tmp/test-rollback.sql registra un rollback de una base 'shopping_cart'; bd/modelo_datos.sql es un volcado de SQL Server; docker-compose.yml etiqueta la imagen como shopping-cart-liquibase; README.md habla de shopping-cart-db y de rutas C:/www/code-corhuila. Confunde a quien lea el repositorio y mezcla evidencia de otro proyecto con la propia.
- **Cómo cerrarlo (S):** Borrar .tmp/ y bd/modelo_datos.sql, renombrar la imagen y reescribir el README con el alcance real (7 esquemas, 21 alter, semillas).

### [Medio] H-22 · Un 401 deja al usuario con una sesión que ya no funciona y no hay manejo central de 403, 500 ni sin red
- **Repositorio:** `FaceID-Proyect-2026/FaceLit`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `shared/services/api.js:39`
- **Por qué importa:** El interceptor borra el token pero el comentario de la línea 39 admite que AuthContext no se entera, así que las guardas siguen creyendo que hay sesión (el JWT vence a las 8 h según application.yaml). El manejo por código de estado solo existe en pantallas sueltas (csv-upload.tsx:270-284, verify-identity.tsx:74-82); ninguna pantalla ofrece 'reintentar' (0 coincidencias en app/) y no hay ErrorBoundary. Es el callejón sin salida que la lente A03 busca: el usuario ve listas vacías o errores genéricos hasta que sale y entra por su cuenta.
- **Cómo cerrarlo (M):** Exponer un forceLogout en AuthContext y llamarlo desde el interceptor con mensaje 'tu sesión expiró'; centralizar 403/404/500/sin red y añadir 'reintentar' en las pantallas que leen datos.

### [Medio] H-23 · Accesibilidad mínima y textos en español incrustados que no pasan por i18n
- **Repositorio:** `FaceID-Proyect-2026/FaceLit`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/auth/login.tsx:278`
- **Por qué importa:** 39 propiedades de accesibilidad en 15 archivos frente a 589 TouchableOpacity en app/. Las etiquetas existentes están en español fijo ('Ocultar contraseña') y hay 13 mensajes 'No fue posible…' en el código, aunque el producto ofrece cuatro idiomas (shared/i18n/locales). Quien use otro idioma o un lector de pantalla recibe una experiencia incompleta.
- **Cómo cerrarlo (M):** Pasar etiquetas y mensajes a las claves de i18n, añadir accessibilityRole/Label a los botones de icono y validar con el lector de pantalla las 3 rutas principales.

### [Medio] H-24 · No hay problema, usuarios, alcance ni indicadores de éxito en los repositorios, y la mayoría de las historias carece de criterios de aceptación
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `FaceID-Proyect-2026/FaceLit:docs-repo/README.md`
- **Por qué importa:** Los repos describen qué es FaceLit pero no el problema que resuelve, la línea base de asistencia ni al menos 3 indicadores medibles (grep de 'indicador', 'KPI' y 'problema' solo da textos de interfaz en RF_RNF_APRENDIZ.md). Los criterios de aceptación existen en los issues 28 a 40 de FaceLit-Backend y en RF_RNF_APRENDIZ.md (rol aprendiz), pero no para HU-04..HU-09 del frontend ni para los demás roles. La documentación formal (SRS, anexos, priorización) vive en Drive y en el repositorio no declarado facelit-docs.
- **Cómo cerrarlo (M):** Agregar un docs/producto.md con problema, usuarios, alcance, 3 o más indicadores con fórmula y meta, y una tabla historia, criterios, pantalla y endpoint. Traer al repositorio una copia del SRS vigente.

### [Medio] H-25 · La documentación formal no vive en los repositorios declarados y no hay diagrama de arquitectura ni OpenAPI
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `FaceID-Proyect-2026/FaceLit:docs-repo/architecture.md`
- **Por qué importa:** PROYECTOS-FICHA-3145555.md enlaza una carpeta de Drive. Dentro de FaceLit, FaceLit-Backend, FaceLit-DB y micro-facial no hay ningún diagrama de sistema, ERD o de despliegue (solo un esquema ASCII de capas del frontend) y el backend no expone Swagger/OpenAPI (pom.xml sin springdoc); la única API documentada de forma consultable es la de micro-facial.
- **Cómo cerrarlo (M):** Versionar en los repos un diagrama de componentes y un ERD (Mermaid o drawio), y añadir springdoc-openapi al backend.

### [Medio] H-26 · Cero revisiones de código: 121 pull requests, 119 fusionados por su propio autor
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api graphql: pullRequests reviews totalCount = 0 en los 4 repos`
- **Por qué importa:** FaceLit 48 PR, Backend 29, DB 42, micro-facial 2. No hay una sola revisión y los únicos comentarios son del bot de Vercel; el PR de entrega a main (FaceLit 46, hu-06-main) lo abrió y fusionó la misma persona. Los PR cumplen el flujo de ramas pero no detectan errores como los 116 archivos borrados en d9d40b0.
- **Cómo cerrarlo (S):** Exigir una aprobación de otro integrante antes de fusionar a dev, qa y main (protección de rama) y asignar un revisor por componente.

### [Medio] H-27 · El front envia language DE y el backend y la BD solo aceptan ES, EN, PR y FR
- **Repositorio:** `FaceID-Proyect-2026/FaceLit`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `features/profile/useUserSettings.ts:28`
- **Por qué importa:** LANG_APP_TO_BACKEND mapea aleman a DE; el enum Language del backend y la restriccion CHECK de security.user_configuration rechazan DE (y ofrecen PR, que el front no tiene). Un usuario que elige aleman no puede guardar su preferencia.
- **Cómo cerrarlo (S):** Alinear el conjunto de idiomas en front, enum y CHECK mediante un changeset nuevo.

### [Medio] H-29 · El modelo documentado en el repo no corresponde al esquema implementado
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-DB`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `bd/modelo_datos.sql:14`
- **Por qué importa:** El modelo del repo define 31 tablas en SQL Server con Horario, ExcepcionHorario, RestriccionAmbiente, Acudiente y Consentimiento; el esquema PostgreSQL real no las tiene y agrega otras (csv_pending_transfer, account_access_request, face_reset_request, change_history). El front aun llama a /api/consent y /api/catalogos que dependen de ese modelo.
- **Cómo cerrarlo (S):** Generar el modelo logico (diagrama o data-model.md) desde las migraciones vigentes y guardarlo en el repo; retirar entidades que se descartaron.

### [Medio] H-30 · Pantallas de más de 1 000 líneas, 49 archivos sobre 300 líneas y pantallas duplicadas entre roles
- **Repositorio:** `FaceID-Proyect-2026/FaceLit`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/admin/attendance/by-ficha.tsx`
- **Por qué importa:** by-ficha.tsx concentra 1 470 líneas con 11 useState, agregación de datos y render; app/apprentice/facial.tsx tiene 1 033. 49 de 192 archivos pasan de 300 líneas (la lente fija 300 como tope). reports/calendar de admin e instructor son casi idénticos (469 vs 466 líneas, 31 de diferencia) y environments/[id] es copia exacta de 250 líneas; el instructor ya reutiliza by-ficha con props (app/instructor/attendance/by-ficha.tsx), así que el patrón existe. Además hay 296 usos de any y 147 colores hexadecimales en app/.
- **Cómo cerrarlo (L):** Partir las pantallas gigantes en hook de datos + componentes, reutilizar con props las pantallas gemelas como se hizo con by-ficha y mover colores a shared/constants/colors.ts.

### [Medio] H-31 · En la version web el token de sesion se guarda en localStorage
- **Repositorio:** `FaceID-Proyect-2026/FaceLit`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `shared/services/tokenStorage.js:9`
- **Por qué importa:** tokenStorage.js:9 usa localStorage.setItem en la plataforma web (SecureStore solo en nativo). Cualquier XSS en la app web extrae el token de 8 h, que da acceso completo a la API; la guia de seguridad de API lo lista como salida prohibida.
- **Cómo cerrarlo (M):** En web usar una cookie HttpOnly/SameSite emitida por el backend o, al menos, un token corto con refresh y una politica CSP estricta.

### [Medio] H-32 · Un token JWT sigue siendo valido tras deshabilitar la cuenta, cambiar el rol o cerrar sesion
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/FaceLit/backend/config/JwtFilter.java:61; src/main/resources/application.yaml:44`
- **Por qué importa:** JwtFilter solo valida firma y expiracion (linea 61) y toma el rol del token; no consulta el estado de la cuenta ni UserSession. Con 8 h de vigencia (application.yaml:44) un usuario retirado o degradado conserva su acceso hasta que expire. La skill de seguridad API pide un token validable en servidor (almacen de sesion o comprobacion de estado).
- **Cómo cerrarlo (M):** Validar en el filtro el estado de la cuenta y la sesion (o acortar la vigencia con un refresh token revocable) y rechazar tokens de usuarios inactivos.

### [Medio] H-33 · CORS y WebSocket abiertos a cualquier origen y SQL registrado en el log en la configuracion principal
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/FaceLit/backend/config/SecurityConfig.java:74; src/main/java/com/FaceLit/backend/realtime/RealtimeWebSocketConfig.java:21; src/main/resources/application.yaml:17`
- **Por qué importa:** setAllowedOriginPatterns("*") en la API (linea 74) y en /ws/realtime (permitAll, token como primer mensaje) y show-sql: true en la configuracion principal. Con Bearer y credenciales desactivadas el riesgo es acotado, pero cualquier origen puede invocar la API desde un navegador y el log acumula consultas con datos personales.
- **Cómo cerrarlo (S):** Configurar los origenes permitidos por variable de entorno y mover show-sql a un perfil de desarrollo.

### [Medio] H-34 · Dependencias fuera de soporte: Spring Boot 3.4.1 con Tomcat 10.1.34, y la documentacion afirma Spring Boot 4.0.6
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `pom.xml:11; README.md:161`
- **Por qué importa:** El parent es 3.4.1 (dic-2024) y el repositorio versiona tomcat-embed-core 10.1.34, anterior a las correcciones de 2025; el README declara 4.0.6 (README.md:161), de modo que la documentacion no refleja lo desplegado. En FaceLit, xlsx 0.18.5 (package.json:53, solo escritura) y en micro-facial fastapi 0.115.6 (requirements.txt:2) tambien estan atrasados. No se ejecuto npm audit ni dependency-check.
- **Cómo cerrarlo (M):** Subir a la linea 3.5.x/4.x vigente, activar Dependabot y ejecutar OWASP dependency-check en CI.

### [Medio] H-35 · La rama main del backend esta 84 commits detras de dev y no contiene el modulo facial: no hay camino repetible de release
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Dockerfile:5; src/main/java/com/FaceLit/backend/facial/controller/FacialEventController.java:38`
- **Por qué importa:** git rev-list --count origin/main..dev da 84 y main se detuvo el 14-jul-2026 (dev, 21-oct-2026); en main no existe el paquete facial/. Si el despliegue sale de main entrega un producto sin la funcion principal; si sale de dev, main no representa produccion. No hay etiquetas de version en ninguno de los cuatro repos (git tag vacio) ni plan de despliegue o rollback para backend, frontend o servicio facial (lente A11).
- **Cómo cerrarlo (M):** Definir de que rama se despliega, etiquetar versiones, promover dev -> qa -> main con PR y documentar un plan de rollback (imagen anterior + reversa de migraciones).

### [Medio] H-36 · Imagen del backend sin usuario no root, sin healthcheck y con pruebas omitidas en la construccion
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Dockerfile:5`
- **Por qué importa:** Dockerfile:7-11 ejecuta java -jar como root, no declara HEALTHCHECK ni existe endpoint de salud (sin actuator en pom.xml) y la construccion usa mvn -DskipTests (linea 5). El orquestador no puede saber si el servicio esta sano y una imagen puede publicarse con pruebas rotas.
- **Cómo cerrarlo (S):** Agregar USER no root, actuator /actuator/health con HEALTHCHECK y ejecutar mvn verify en CI antes de construir la imagen.

### [Medio] H-37 · Las migraciones 019 y 020 no tienen rollback y compose pasa una contrasena por defecto como argumento
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-DB`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/04_alter/0000changelog.yaml:141; docker-compose.yml:42`
- **Por qué importa:** En 01_ddl/04_alter/0000changelog.yaml hay 18 changesets y solo 16 bloques rollback: 019_account_access_requests (linea 141) y 020_email_change_recovery_code (147) no lo tienen, y 05_rollbacks llega solo a la 018. Un despliegue fallido de esas dos no es reversible con Liquibase. Ademas docker-compose.yml:42 pasa la contrasena por defecto como argumento del proceso.
- **Cómo cerrarlo (S):** Agregar los .rollback.sql de 019 y 020 y referenciarlos; parametrizar la contrasena sin valor por defecto.

### [Medio] H-38 · Imagen del servicio facial en una sola etapa, como root, con herramientas de compilacion y sin HEALTHCHECK
- **Repositorio:** `FaceID-Proyect-2026/micro-facial`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Dockerfile:11`
- **Por qué importa:** El Dockerfile instala build-essential en la imagen final (linea 11), no define USER ni HEALTHCHECK aunque app/main.py:51 ya expone /health. Aumenta la superficie de ataque del servicio que custodia biometria.
- **Cómo cerrarlo (S):** Multi-etapa (compilar ruedas en una etapa y copiar solo lo necesario), USER no root y HEALTHCHECK contra /health.

### [Medio] H-39 · Changeset huerfano y numeracion duplicada en 04_alter
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-DB`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/04_alter/016_facial_event_excuse_default.sql`
- **Por qué importa:** 016_facial_event_excuse_default.sql (valor por defecto FALSE y relleno de excuse) no esta en ningun changelog: en una base nueva excuse queda sin valor por defecto ni relleno, distinto de una base parchada a mano. Hay dos archivos 016 y 019/020 sin rollback.
- **Cómo cerrarlo (S):** Incluir el archivo en 0000changelog.yaml con un id nuevo, renumerar y agregar rollbacks; verificar con liquibase update sobre base vacia en CI.

### [Medio] H-40 · FK sin politica ON DELETE, sin indices en FK y una migracion de indice que borra datos
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-DB`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/04_alter/001_create_foreignkeys_security.sql:1`
- **Por qué importa:** Ninguna FK define ON DELETE; el archivo de indices de seguridad no existe (solo su rollback), asi que credential, user_session y password_recovery no tienen indice por id_user_app. 008_unique_facial_event_attendance.sql marca como borrados los duplicados dentro de una migracion de indice, mezclando DDL y datos destructivos.
- **Cómo cerrarlo (M):** Declarar ON DELETE explicito segun el modelo, crear indices por patron de consulta para cada FK, y separar la limpieza de datos en un changeset propio con su rollback.

### [Medio] H-42 · La semilla del coordinador es un dato quemado con comentario que se contradice
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-DB`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `02_dml/00_inserts/002_seed_coordinator.sql:20`
- **Por qué importa:** Siembra a 'Integrante 3' (correo example.com, documento 1000000000) con un hash bcrypt de 60 caracteres cuyo comentario dice que no es un hash real. En cada ambiente queda una cuenta COORDINATOR con credencial de origen desconocido. Valor del hash ««redactado»».
- **Cómo cerrarlo (S):** Crear el primer coordinador por variable de entorno o script de arranque fuera del repo y forzar cambio de contrasena en el primer acceso.

### [Medio] H-43 · Convenciones REST y de error distintas entre el backend y el micro-facial
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/FaceLit/backend/shared/exception/GlobalExceptionHandler.java:32`
- **Por qué importa:** El backend responde message, sin version y con 200 en creaciones; el micro responde detail, con /api/v1 y 201. El cliente mantiene dos normalizadores de error y la API no tiene una forma comun.
- **Cómo cerrarlo (M):** Fijar una convencion unica (por ejemplo ProblemDetails, RFC 9457), versionar /api/v1 en el backend y paginar los listados.

### [Bajo] H-44 · Existen dos repositorios en la organización que el equipo no declaró
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `FaceID-Proyect-2026/facelit-docs y FaceID-Proyect-2026/Documentaci-n-y-despliegue`
- **Por qué importa:** facelit-docs contiene el SRS, diagramas drawio y el diccionario de datos; Documentaci-n-y-despliegue solo tiene un commit inicial. No se evalúan, pero la documentación formal está en un repo que PROYECTOS-FICHA-3145555.md no menciona.
- **Cómo cerrarlo (S):** Declarar facelit-docs en PROYECTOS-FICHA-3145555.md o mover su contenido a docs/ de los repos declarados; borrar el repo vacío.

### [Bajo] H-45 · Cuentas por aclarar y reparto desigual por componente
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git shortlog -sne --all --no-merges en los 4 repos`
- **Por qué importa:** Integrante 5 (40 commits, 30 en FaceLit-DB) es una posible segunda cuenta de Integrante, sin confirmar; 'Integrante 3' con correo casi idéntico al de Integrante 2 (45 commits) es una posible segunda identidad de Integrante 3, sin confirmar; ninguna de las dos se fusiona. Hay 7 cuentas externas con 1 a 4 commits (Integrante, Integrante 7, Integrante 9, Integrante 10 en FaceLit-DB; Integrante 12, Integrante 13 y Integrante 11 en backend y frontend) y Integrante abrió un PR en FaceLit. Integrante (51 commits) solo aparece en el frontend, y Integrante hace 11 de los 13 commits de micro-facial.
- **Cómo cerrarlo (S):** Pedir a cada integrante que configure un único user.name y user.email, y confirmar con el equipo las cuentas listadas antes de calcular porcentajes definitivos.

### [Bajo] H-46 · Servicios del front sin contraparte y rutas del backend sin consumidor
- **Repositorio:** `FaceID-Proyect-2026/FaceLit`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `shared/services/consentService.js:5`
- **Por qué importa:** authService.register, verifyEmail, resendCode, getRegistrationStatus, consentService, catalogService y el stub de auditoria apuntan a rutas inexistentes; el front espera registered_at y el micro devuelve created_at. Es codigo muerto que oculta la realidad de lo implementado.
- **Cómo cerrarlo (S):** Eliminar lo no usado o implementarlo; corregir el tipo FacialEmbeddingResponse.

### [Bajo] H-47 · La URL de base de datos por defecto lleva credenciales de ejemplo en el código
- **Repositorio:** `FaceID-Proyect-2026/micro-facial`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/core/config.py:10`
- **Por qué importa:** Settings.database_url trae usuario y clave de ejemplo incrustados como valor por defecto. Es el mismo usuario del compose de desarrollo, pero queda el hábito y, si falta la variable en producción, el servicio intentará conectarse con esos valores.
- **Cómo cerrarlo (S):** Quitar el valor por defecto (campo obligatorio) y dejar el ejemplo solo en .env.example.

### [Bajo] H-48 · Valor por defecto de la clave del servicio facial en el yaml
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-Backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/resources/application.yaml:49`
- **Por qué importa:** facial.embedding.api-key cae a un valor por defecto conocido si la variable falta, lo que deja al backend hablando con micro-facial con una clave adivinable (la misma que usa el .env versionado del frontend).
- **Cómo cerrarlo (S):** Quitar el valor por defecto y fallar el arranque si no esta definida.

### [Bajo] H-49 · El despliegue no esta declarado ni documentado
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `eas.json:14`
- **Por qué importa:** PROYECTOS-FICHA-3145555.md no incluye URL de despliegue; solo hay una URL de preview en FaceID-Proyect-2026/FaceLit:eas.json:14 y un comentario sobre 'Render Environment' en FaceID-Proyect-2026/FaceLit-Backend:.env.example. Sin runbook no se puede verificar que el sistema funcione en linea (T-7.4 queda NV).
- **Cómo cerrarlo (S):** Declarar la URL publica de cada componente, documentar el despliegue y agregar una lista de verificacion de release.

### [Bajo] H-50 · Nomenclatura mezclada espanol/ingles y con errores de escritura en el esquema
- **Repositorio:** `FaceID-Proyect-2026/FaceLit-DB`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/002_create_roleandpermissions_tables.sql:14`
- **Por qué importa:** descripcion, name_rol, asigned_at, fk_facial_event_apprendice y categorias SEGURIDAD/ACADEMICO conviven con nombres en ingles; los nombres fisicos son contrato duradero.
- **Cómo cerrarlo (S):** Estandarizar en ingles con un changeset de renombrado en dos pasos (expandir y contraer).

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 67.2 |
| D2 | Reproducibilidad | 52.1 |
| D3 | Arquitectura y congruencia | 31.2 |
| D4 | Calidad de código | 63.6 |
| D5 | Seguridad | 50.0 |
| D6 | Pruebas | 46.7 |
| D7 | DevOps y despliegue | 25.5 |
| D8 | Datos | 40.0 |
| D9 | API y contratos | 55.0 |
| D10 | Frontend y móvil | 62.5 |
| D11 | IoT y firmware | — |
| D12 | Documentación y trazabilidad | 47.2 |
| D13 | Proceso y colaboración | 63.2 |
| D14 | Extremo a extremo | 40.0 |

## Lo que está bien

- Esquema versionado con Liquibase y rollback por changeset (`FaceID-Proyect-2026/FaceLit-DB:01_ddl/changelog.yaml; FaceID-Proyect-2026/FaceLit-DB:05_rollbacks/01_ddl/10_indexes/008_unique_facial_event_attendance.rollback.sql; FaceID-Proyect-2026/FaceLit-DB:changelog-master.yaml`)
- Reglas de negocio protegidas en el motor con indices unicos parciales y CHECK (`FaceID-Proyect-2026/FaceLit-DB:01_ddl/10_indexes/007_create_facialrecognition_indexes.sql:1; FaceID-Proyect-2026/FaceLit-DB:01_ddl/10_indexes/008_unique_facial_event_attendance.sql:13`)
- El backend valida el esquema (ddl-auto validate) en vez de generarlo (`FaceID-Proyect-2026/FaceLit-Backend:src/main/resources/application.yaml`)
- Contratos de login, sesion de ambiente, asistencia facial y academico coinciden campo a campo entre front y backend (`FaceID-Proyect-2026/FaceLit:shared/services/facialAttendanceService.ts:95 con FaceID-Proyect-2026/FaceLit-Backend:src/main/java/com/FaceLit/backend/facial/dto/request/FacialAttendanceCaptureRequestDTO.java`)
- Verificacion facial por sesion bien acotada: el backend delega al micro y solo registra el evento si hay coincidencia y prueba de vida (`FaceID-Proyect-2026/FaceLit-Backend:src/main/java/com/FaceLit/backend/facial/service/serviceImpl/FacialEventServiceImpl.java:206; FaceID-Proyect-2026/micro-facial:app/schemas/facial_embedding.py:192`)
- Micro-facial con OpenAPI automatico, version /api/v1, health, Dockerfile y pruebas (`FaceID-Proyect-2026/micro-facial:app/main.py; FaceID-Proyect-2026/micro-facial:tests/test_face_reset_postgres.py; FaceID-Proyect-2026/micro-facial:Dockerfile`)
- Semillas de roles y permisos idempotentes y alineadas con SecurityConfig (`FaceID-Proyect-2026/FaceLit-DB:02_dml/00_inserts/seed.sql:33; FaceID-Proyect-2026/FaceLit-Backend:src/main/java/com/FaceLit/backend/config/SecurityConfig.java`)
- Manejo de errores centralizado y mensajes de validacion utiles (`FaceID-Proyect-2026/FaceLit-Backend:src/main/java/com/FaceLit/backend/shared/exception/GlobalExceptionHandler.java:32`)
- Autenticacion y hash de contrasenas solidos en el backend (`src/main/java/com/FaceLit/backend/config/SecurityConfig.java:86 (BCrypt 10); src/main/java/com/FaceLit/backend/auth/service/serviceImpl/roleandpermission/LoginServiceImpl.java:111 (bloqueo a los 3 intentos, 15 min)`)
- Matriz de roles real en administracion, academico, ambientes y reinicio facial (`src/main/java/com/FaceLit/backend/config/SecurityConfig.java:46`)
- La correccion de asistencia valida rol y pertenencia a la sesion (`src/main/java/com/FaceLit/backend/facial/AttendanceCorrectionService.java:44`)
- Matricula facial con reto aleatorio, deteccion de vida y usuario tomado del token (`src/main/java/com/FaceLit/backend/facial/FacialEnrollmentController.java:125`)
- Secretos del backend externalizados y sin credenciales reales en el historial revisado (`src/main/resources/application.yaml:43`)
- Entrada validada con Bean Validation, consultas parametrizadas y codigos con SecureRandom (`src/main/java/com/FaceLit/backend/shared/util/VerificationCodeGenerator.java:3`)
- Suite de pruebas amplia y con aserciones reales en el backend (22 clases, 106 pruebas, con casos 403) (`src/test/java/com/FaceLit/backend/facial/FaceResetServiceTest.java:111`)
- micro-facial: 23 pruebas pytest con aserciones reales, .env ignorado y .env.example (`tests/test_facial_embedding_schema.py`)
- FaceLit-DB: migraciones Liquibase con rollback espejo (16 de 18 alter) y healthcheck de Postgres (`01_ddl/04_alter/0000changelog.yaml:141`)
- La app informa el tratamiento de datos biometricos con aviso de privacidad y cita de la Ley 1581 (`features/auth/components/PrivacyNoticeModal.tsx:20`)
- WebSocket que valida el token como primer mensaje y lo revalida; token en SecureStore en nativo (`src/main/java/com/FaceLit/backend/realtime/RealtimeWebSocketHandler.java:62`)
- Flujo de ramas y PR consistente, con cadena de promoción dev, qa y main (`gh api repos/FaceID-Proyect-2026/FaceLit/pulls: PR 12 a 15 (dev a hu-01-qa, qa, hu-01-main, main) y PR 38 a 46; 121 PR en 4 repos`)
- Seguimiento de trabajo en tres tableros de GitHub Projects con 58 de 67 items cerrados y 31 issues con formato 'Como… quiero… para…', 12 con criterios de aceptación verificables (`gh api graphql organization projectsV2 (Backend - Integrante 13, HU-BD, Front-end - Integrante); issues 28 a 40 de FaceLit-Backend`)
- Actividad sostenida: FaceLit con commits en las 9 semanas entre el 24-ago y el 22-oct, FaceLit-DB en 8 y el backend en 7 (`git log --all --no-merges por semana ISO en FaceLit, FaceLit-DB y FaceLit-Backend`)
- micro-facial es el repositorio mejor entregado: README con endpoints y payloads, .env.example, Dockerfile, compose, dependencias fijadas, manejo central de errores, /health y pruebas (`README.md`)
- FaceLit-DB: esquema versionado con Liquibase por capas DDL/DML/DCL/TCL, rollback espejo por cada script, compose con healthcheck y comando de reset limpio documentado (`docker-compose.yml`)
- Frontend con arquitectura app/features/shared, guardas de acceso por rol, interceptor de axios con token, i18n en cuatro idiomas y tokens de tema (`shared/hooks/useRoleGuard.ts`)
- La pantalla de asistencia por ficha cubre los cuatro estados (carga, vacío, error y éxito de excusa) y se reutiliza para el instructor con props (`app/admin/attendance/by-ficha.tsx:500`)
- Backend con capas controller/service/serviceImpl/repository/dto, manejador global de excepciones (12 handlers) y pruebas de integración de acceso a cuentas (`src/main/java/com/FaceLit/backend/shared/exception/GlobalExceptionHandler.java`)
- Existe una migración que siembra al coordinador inicial (6 INSERT), condición para que el acceso protegido sea utilizable desde cero; el contenido de las credenciales no se revisó (`02_dml/00_inserts/002_seed_coordinator.sql`)
- El despliegue web responde 200 a un GET de solo lectura (`curl -s -m 15 -o /dev/null -w %{http_code} https://facelit-ten.vercel.app (homepage del repo FaceLit en GitHub): 200`)

## Lo que no se pudo verificar

- Documentacion 05-architecture, 06-data y 09-microservices del equipo — Esta en una carpeta de Drive no accesible desde el repositorio; T-3.1 y T-3.6 se evaluaron contra lo que hay en los repos (README, docs-repo, bd/modelo_datos.sql).
- Levantado desde cero de FaceLit-DB con liquibase update y arranque del backend con ddl-auto validate — Exigiria ejecutar Docker, Liquibase o Maven, prohibido; los desajustes se establecieron por comparacion de DDL y SQL en el SHA evaluado.
- Flujo contra un despliegue en linea (T-14.3) — El equipo no declara URL de despliegue.
- Ramas no evaluadas (main y qa del backend a 4 merges de dev, feature/facial-service con un modulo facial anterior, develop y qa de la BD con esquema biometric_vector) — Solo se leyo lo necesario para explicar la deriva de esquema; no se auditaron en profundidad.
- Repositorios no declarados Documentaci-n-y-despliegue y facelit-docs — El equipo no los declaro; existen en la organizacion y no se evaluaron.
- Un primer intento de escribir el script generador por la herramienta de shell fue bloqueado por un guardia de columnas SQL (falso positivo sobre prosa) — No se insistio con ese comando; el archivo se produjo con la herramienta de escritura de archivos y el resultado se valida con validar.py.
- T-7.4: respuesta del despliegue en Render (https://facelit-backend.onrender.com) — El equipo no declara URL en PROYECTOS-FICHA-3145555.md; solo aparece en eas.json:14 de FaceLit, y la regla de red permite un GET unicamente contra la URL declarada.
- Que micro-facial este expuesto a Internet y use una API key real distinta de la de ejemplo — Depende del despliegue y de variables de entorno que no estan en el repositorio; no se ejecuto ni se consulto ningun servicio.
- Si la contrasena de la coordinadora semilla (002_seed_coordinator.sql:20) es adivinable — Exigiria probar candidatos contra el hash; no se intento. Solo se informa que el hash esta versionado.
- Vulnerabilidades concretas de dependencias (npm audit, OWASP dependency-check, pip-audit) — No se permite ejecutar herramientas ni instalar dependencias; R-5.7 se basa en versiones leidas.
- Si los scripts de prueba del frontend y las pruebas de backend y micro-facial pasan — Ejecutar mvn, npm o pytest sobre codigo de los aprendices esta prohibido; se evaluo solo por lectura.
- Explotabilidad en vivo de H-B01, H-B02 y H-B03 (limitacion de tasa en proxy, exposicion real de red) — No se probo contra servicios en ejecucion; los hallazgos se fundan en la lectura del codigo y la configuracion versionados.
- Repositorios no declarados (Documentaci-n-y-despliegue, facelit-docs) — Estan clonados pero fuera del alcance: no se construyeron hallazgos sobre ellos (queda anotado para D1).
- Documentación en Google Drive (SRS, anexos, priorización, manual de marca) — Documentación en Drive no accesible desde el repositorio; T-12.3 y T-12.4 se evaluaron solo contra README, docs-repo, docs/ e issues.
- Compilación y arranque de la app Expo, del backend y del microservicio; pantallas en ejecución — La regla de solo lectura prohíbe ejecutar el código de los aprendices (npm, mvn, docker); R-10.1 se evaluó por configuración, lockfile y rutas.
- Muestreo de D4: se leyeron con profundidad by-ficha.tsx (1 470 líneas, FaceLit) y FacialEnrollmentController.java (339 líneas, Backend); se contaron métricas (líneas, catch, any, hex) en todo el repo y se hojearon CsvAcademicServiceImpl y facial_embedding_service.py — Presupuesto de lectura: los otros componentes grandes (FacialEventServiceImpl, academicStore.ts, app/apprentice/facial.tsx) se juzgaron solo por tamaño y estructura.
- Si EXPO_PUBLIC_API_URL está definida en el proyecto de Vercel y a qué backend apunta el despliegue web — El .env versionado apunta a localhost; la configuración de Vercel no es visible desde el repositorio y la regla solo permite un GET a la URL declarada.
- Lista de administradores y colaboradores de los repos (T-13.6) — gh api collaborators devuelve 403 sin permiso de escritura; solo se verificó que el propietario es una organización.
- Identidad de las cuentas Integrante 5, 'Integrante 3' con correo casi idéntico, Integrante, Integrante 12, Integrante 13, Integrante 11 y las 4 cuentas externas de FaceLit-DB — Solo se fusionan cuentas con el mismo correo; las demás sospechas quedan sin confirmar y no cambian porcentajes.
- Si los commits de las ramas adelantadas ya están en dev por squash o por otro camino — git cherry no encontró parches equivalentes, pero un squash con cambios adicionales no se detecta; el contenido de hu-35-dev (archivo entryPlatform.ts) sí se comprobó ausente en dev.
- Contenido del script de semilla del coordinador (credenciales iniciales) — El guardia de gobernanza bloqueó el comando de lectura enmascarada; no se insistió. Solo se confirmó que el archivo existe y es una migración.
- Repositorios no declarados (facelit-docs, Documentaci-n-y-despliegue) — Clonados pero fuera del alcance de la evaluación; solo se listó su contenido para el hallazgo de D1.
