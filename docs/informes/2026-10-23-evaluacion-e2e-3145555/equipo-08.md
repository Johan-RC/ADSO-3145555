# Equipo 8 · SomnGuard — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 67/100 · Juicio D**

## Veredicto

SomnGuard funciona en lo esencial: tres de los cinco flujos de punta a punta estan completos (registro e inicio de sesion, aprovisionamiento del dispositivo y deteccion con alerta critica dentro de la plataforma), y la base de datos con 92 migraciones con rollback es el punto mas solido. Lo que falta es que dos flujos estan rotos: el historial de la app queda en una sola pagina por una diferencia entre camelCase y snake_case, y el push critico al telefono no existe del lado de la app. En seguridad no quedan bloqueantes ni criticos, pero si 12 hallazgos altos, entre ellos el restablecimiento de contrasena con un codigo de 6 digitos sin vinculo a la cuenta ni limite de intentos (el verificador lo bajo de critico a alto porque el limitador de 5 solicitudes por minuto lo hace probabilistico) y el WebSocket /ws/stream sin autenticacion. Tambien pesan que un integrante concentra el 76 % de los commits, que el portal en main aparece como un solo commit de transferencia, que el streaming de video del dispositivo solo esta en develop y que la API, la app, el dispositivo y el portal carecen de pruebas de seguridad o de CI. El puntaje es 66,8 con juicio D, a 3,2 puntos del umbral de 70: corregir los dos flujos rotos, cerrar el reset y el WebSocket y promover las ramas a main alcanza para superarlo.

## Plan para cerrar las brechas

1. **Corregir el restablecimiento de contrasena: exigir correo mas codigo en verify-reset-code y reset-password, invalidar el codigo tras 5 intentos fallidos, usar un token de mayor entropia de un solo uso y limitar por cuenta ademas de por IP.** (esfuerzo M) — se cierra cuando: Con un codigo valido de otro usuario o tras 5 intentos fallidos, reset-password responde 4xx; hay pruebas negativas en CI que lo comprueban.
2. **Autenticar el WebSocket /ws/stream (JWT o llave de dispositivo), validar pertenencia a la sesion o dispositivo y corregir el filtro de llave de API que autentica sin verificar.** (esfuerzo M) — se cierra cuando: Una conexion a /ws/stream sin credenciales o con una llave falsa es rechazada (401/403) y una prueba automatizada lo demuestra.
3. **Arreglar el historial de la app: leer total_items y total_pages en snake_case, interpretar el sobre de error del API y llevar al acceso cuando la sesion vence.** (esfuerzo S) — se cierra cuando: El historial navega mas de una pagina contra el API real, un error 4xx/5xx muestra un mensaje legible y una sesion vencida lleva a la pantalla de acceso.
4. **Implementar el push critico en la app: registrar el token del dispositivo en /notifications/device-tokens, usar notificaciones nativas y activar el proveedor FCM en el API.** (esfuerzo L) — se cierra cuando: Una alerta critica genera una notificacion en un telefono real y existe la fila de monitoring.device_token para ese usuario.
5. **Promover el trabajo a main sin perder autoria: llevar develop de device (streaming de video) a qa y main y reconciliar las ramas divergentes de api, app, db y portal con merge commits.** (esfuerzo S) — se cierra cuando: main de device contiene app/streaming/publisher.py; git blame de main en portal muestra a los autores reales y no hay divergencia pendiente entre develop y main.
6. **Agregar pruebas automatizadas de seguridad al API (login, reset, control de acceso con casos negativos) y pruebas de la app movil, y ejecutarlas en CI.** (esfuerzo L) — se cierra cuando: El CI ejecuta pruebas de login, reset de contrasena y control de acceso con casos negativos, y pruebas basicas de la app; el pipeline falla si alguna cae.
7. **Crear CI y reproducibilidad en device y portal: pipeline de pruebas y build, scripts de instalacion y aprovisionamiento con contenido, dependencias fijadas, despliegue del portal reproducible desde el repo y rollback documentado.** (esfuerzo L) — se cierra cuando: Un clon limpio de cada repo se instala y ejecuta siguiendo solo el README; el CI corre en cada PR y existe un procedimiento de rollback documentado.
8. **Registrar los errores 500 con el trace_id entregado y dejar de tragar excepciones en DeviceManager y en la auditoria de estado del dispositivo.** (esfuerzo M) — se cierra cuando: Un 500 provocado deja una linea de log con el mismo trace_id que recibe el cliente y ya no hay bloques except o catch vacios en DeviceManager.
9. **Repartir el trabajo y la revision: asignar a cada integrante al menos una HU de api o db hasta su PR, exigir revision de alguien distinto al autor (tambien en device) y respetar la convencion de commits.** (esfuerzo M) — se cierra cuando: Cada integrante tiene commits en al menos un repo de backend o datos y los PR nuevos tienen una aprobacion de otra persona.
10. **Alinear la arquitectura con lo documentado: desacoplar modulos del API de los repositorios JPA ajenos, pasar los cuatro controladores por la capa de aplicacion y partir HistoryScreen.** (esfuerzo L) — se cierra cuando: Ningun modulo importa repositorios JPA de otro modulo, los controladores usan casos de uso y HistoryScreen queda dividido en componentes; una prueba de arquitectura lo verifica.
11. **Endurecer secretos, transporte y privacidad: sacar tokens del localStorage del portal, retirar credenciales por defecto de S3, coturn y LiveKit, exigir https en el dispositivo, proteger OpenAPI y actuator, definir la URL del API en EAS production y registrar consentimiento y retencion de datos.** (esfuerzo M) — se cierra cuando: Ningun secreto por defecto en el codigo, el dispositivo rechaza URLs http, el portal no usa localStorage para tokens, OpenAPI no es publico en prod y el build production de EAS carga contra el API.
12. **Alinear base de datos y documentacion con el sistema real: Liquibase como unico dueno del esquema, roles de minimo privilegio, FK para estados, indices redundantes fuera, y README, OpenAPI, ADR, 06-data, criterios de exito y plantillas de UX al dia.** (esfuerzo M) — se cierra cuando: El perfil dev usa ddl-auto validate, existe un script de roles versionado, las migraciones nuevas pasan verify-rollback, un revisor sigue cada README sin errores y los criterios de exito tienen metrica y valor objetivo.

## Verificación independiente

Hallazgos confirmados: 3 · matizados: 2 · refutados: 0 · duplicados fusionados: 3.

Confirme H-02, H-05 y H-07, los cuatro items PASS (R-5.1 app, R-11.1 device, T-14.3, R-8.1 db), los cinco flujos (3 COMPLETO, 2 ROTO) y todas las cifras de aportes, con fusiones de cuenta validas por correo; matice H-01 (el defecto de vinculacion sin intentos existe, pero RateLimitFilter de 5 solicitudes por minuto lo hace probabilistico: alto, no critico) y H-08 (clase de 1242 lineas con 11 'except Exception: pass', pero la mayoria son limpiezas best effort: medio). No refute ninguno. De los 13 pares, 3 son duplicados reales (H-03/H-06 conservar H-06, H-17/H-39 conservar H-17, H-27/H-42 conservar H-42 con la parte del README de H-27 reubicada) y los otros 10 son defectos distintos aunque compartan archivo.

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Completo | Registro, verificacion de correo e inicio de sesion | — |
| Completo | Aprovisionar un dispositivo y vincularlo a un usuario | — |
| Completo | Deteccion en el dispositivo, ingesta de telemetria y alerta critica in-app | — |
| Roto | Consultar el historial de eventos y la evidencia desde la app | Lectura de la paginacion en la app: eventsApi.ts:244 espera totalItems/totalPages en camelCase y el contrato del API es total_items/total_pages, por lo que HistoryScreen.tsx:234 queda con una sola pagina (hallazgo H-A04; verificado por lectura de codigo y configuracion, no ejecutado). La lista, los filtros y GET /events/{id}/evidence si coinciden con el API. |
| Roto | Notificacion push de una alerta critica al telefono del conductor | La app nunca registra el token de dispositivo: no hay libreria de notificaciones en package.json, ninguna llamada a /notifications/device-tokens y el interruptor de NotificationsScreen.tsx:14 es estado local. El API (NotificationController.java:85, FcmPushSender) y la tabla monitoring.device_token (db 037) existen, y el proveedor por defecto es 'log' (hallazgo H-A02). |

## Hallazgos

### [Alto] H-01 · El restablecimiento de contrasena se autoriza solo con un codigo de 6 digitos, sin vincularlo a la cuenta ni limitar intentos
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A12 · **Verificación independiente:** matizado (severidad ajustada de critico)
- **Evidencia:** `src/main/java/com/somnguard/security/application/service/PasswordResetService.java:141-159 y src/main/java/com/somnguard/security/adapter/in/web/AccountController.java:70-72`
- **Por qué importa:** AccountController.resetPassword llama resetPassword(req.token(), req.newPassword()), que fija email en null; el servicio busca el registro por el hash SHA-256 del codigo (espacio de 10^6 valores compartido por todos los usuarios con un reset pendiente) y la comprobacion de correo es opcional (linea 154). No hay contador de intentos por codigo (AuthService si tiene bloqueo, el reset no). Un atacante puede disparar forgot-password para muchas cuentas y adivinar codigos para fijar la contrasena de cualquier usuario con un codigo vigente; ademas, dos usuarios con el mismo codigo pendiente hacen fallar findByTokenHash con error 500. Solo lo frena RateLimitFilter (5 solicitudes por minuto por IP), lo que reduce pero no elimina la probabilidad.
- **Cómo cerrarlo (M):** Exigir correo mas codigo en verify-reset-code y reset-password (buscar por usuario y comparar hash), limitar intentos fallidos por solicitud (invalidar el codigo tras 5), usar un codigo de mayor entropia o un token aleatorio de un solo uso, y agregar pruebas negativas.

### [Alto] H-02 · Un solo integrante concentra el 76 % de los commits y dos de los cuatro casi no aparecen
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado
- **Evidencia:** `git shortlog -sne --all --no-merges en los 7 repos: Integrante 244, Integrante, Integrante 3 6, Integrante 5 de 322`
- **Por qué importa:** Con 79,9 % de los commits únicos en una persona, el conocimiento del sistema no está repartido: Integrante 3 y Integrante no tienen un solo commit en api, db, device ni docs, y el equipo no puede sustentar el sistema si falta Integrante.
- **Cómo cerrarlo (M):** Repartir historias entre los cuatro con propietarios por repo, hacer que quienes tienen menos aportes lleven al menos una HU de api o db hasta su PR con revisión, y registrar el reparto en el tablero.

### [Alto] H-04 · El código del portal en main quedó atribuido a un commit de transferencia del 22 de octubre
- **Repositorio:** `SomnGuard/somnguard-portal`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/styles/shell.css (commit 4b91933, Integrante 4, 2026-10-22, 90 archivos, +9332/-1047)`
- **Por qué importa:** El blame de main para 1426 líneas de shell.css y otros 89 archivos escritos por Integrante y Integrante apunta a un commit de Integrante con padre único (PR 10, fusionado por él mismo el día del corte); la autoría real y el aporte por persona no se pueden leer en la rama de producción.
- **Cómo cerrarlo (S):** Fusionar develop en main con un merge commit (o rebase que conserve autores) y no con un commit de transferencia; documentar el motivo si ya se hizo para no perder el historial.

### [Alto] H-05 · El push critico a la app movil no existe del lado cliente: ni registra token de dispositivo ni usa notificaciones nativas
- **Repositorio:** `SomnGuard/somnguard-app`
- **Lente SDLC OS:** A06 · **Verificación independiente:** confirmado
- **Evidencia:** `SomnGuard-app/src/features/profile/screens/NotificationsScreen.tsx:14`
- **Por qué importa:** RF-MON-01 y la seccion 12.1 del documento de arquitectura exigen notificacion push en la app, con o sin la app abierta (HU-APP-002). La BD (monitoring.device_token), el API (POST /api/v1/notifications/device-tokens, NotificationController.java:85) y el proveedor FCM existen, pero la app no depende de ninguna libreria de notificaciones (package.json), nunca llama a device-tokens ni a notification-preferences, y el interruptor de NotificationsScreen es un useState local. Ademas el proveedor por defecto del API es 'log'. El portal si muestra las notificaciones in-app, de modo que el usuario final movil, que es el conductor, no recibe la alerta fuera de la app.
- **Cómo cerrarlo (M):** Agregar expo-notifications (o FCM nativo), registrar y borrar el token en POST/DELETE /notifications/device-tokens al iniciar y cerrar sesion, conectar el interruptor a PUT /users/me/notification-preferences, y activar app.notifications.push.provider=fcm en los ambientes con credenciales.

### [Alto] H-06 · La rama main del dispositivo no contiene el streaming de video que develop si trae
- **Repositorio:** `SomnGuard/somnguard-device`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-03
- **Evidencia:** `app/streaming/publisher.py`
- **Por qué importa:** git ls-tree origin/main app/streaming no devuelve nada y git diff --stat HEAD origin/main muestra que main no tiene app/streaming/* (publisher, webrtc, livekit_pub, session, frames), scripts/stream_publish.py ni tests/unit/test_streaming.py (16 archivos, 1446 lineas). develop tiene 27 commits que main no tiene (incluye HU-DEVICE-005: publicacion WebRTC/LiveKit y QoS adaptativo); los 16 commits que main tiene y develop no son sobre todo merges de promocion, y su contenido unico son unas 9 lineas (manejo del landmarker y SOMNGUARD_API_URL en .env.example). Lo evaluado en develop no es lo que se despliega desde main, y el flujo de video en vivo del API y de la app no tiene contraparte en la rama de produccion del dispositivo.
- **Cómo cerrarlo (M):** Integrar develop en main por PR hasta que el ejecutable del Raspberry Pi salga de una sola rama y confirmar en el PR que las 9 lineas propias de main se conservan o se descartan a proposito.

### [Alto] H-07 · La arquitectura hexagonal documentada es nominal: los modulos se acoplan por repositorios JPA y platform depende de los modulos
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A06 · **Verificación independiente:** confirmado
- **Evidencia:** `src/main/java/com/somnguard/analytics/adapter/out/persistence/AnalyticsEventQueryAdapter.java:4`
- **Por qué importa:** ADR-002 y architecture-document.md (lineas 221 y 230) prometen que un modulo solo usa los puertos de entrada de otro y que platform no depende de ningun modulo; ADR-003 nombra el acceso directo a repositorios ajenos como riesgo mitigado. Medido: 24 archivos de application/ y domain/ importan adapter.*, 4 controladores importan repositorios (AuthController tiene logica de verify-password), telemetry_service importa 15 veces adapters de parameterization, analytics importa repositorios de telemetry_service y device_management, platform importa excepciones de cuatro modulos, y solo hay 10 archivos de puertos (device_management, parameterization y telemetry_service no tienen ninguno). El 'camino evolutivo a microservicios' del documento no existe hoy.
- **Cómo cerrarlo (L):** Definir puertos de entrada para lo que otros modulos consumen (catalogos de parameterization, consulta de eventos, asignaciones), mover las entidades JPA fuera de application/ y domain/, hacer que platform capture excepciones por una interfaz o clase base comun, y agregar una prueba ArchUnit que haga cumplir la regla en CI.

### [Alto] H-09 · El WebSocket de senalizacion /ws/stream es publico y reenvia video y estado sin autenticacion ni autorizacion
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/somnguard/platform/config/SecurityConfig.java:55 y src/main/java/com/somnguard/platform/config/StreamSignalingHandler.java:21`
- **Por qué importa:** SecurityConfig lo declara permitAll y el handler lo reconoce en su comentario (linea 21: auth real JWT/API-key en el handshake es fase 2). Cualquiera que conozca un session_id puede unirse al relay y recibir cuadros de video del conductor (lineas 73-79), y cualquiera que conozca un device_id puede suscribirse al estado en tiempo real (lineas 54-62). La restriccion de origenes solo detiene navegadores, no clientes arbitrarios. La explotacion exige conocer UUID, pero son datos que circulan por la app y el REST.
- **Cómo cerrarlo (M):** Autenticar el handshake (JWT del usuario o llave de dispositivo), validar contra el REST que el usuario o dispositivo pertenece a la sesion o al device antes de unirse a una sala, y expirar las salas.

### [Alto] H-10 · El nucleo de seguridad de la API no tiene ninguna prueba; la unica prueba de control de acceso solo inspecciona anotaciones
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/test/java/com/somnguard/analytics/adapter/in/web/AnalyticsControllerSecurityTest.java:52-70`
- **Por qué importa:** Entre las 24 clases de prueba (126 @Test) no hay ninguna para AuthService, JwtService, PasswordResetService, RegisterUserService, RequireFeatureInterceptor, ApiKeyAuthenticationFilter ni RateLimitFilter (src/test/java/com/somnguard/security solo contiene pruebas de plantillas y envio de correo). No existe MockMvc, WebMvcTest ni Testcontainers aunque testcontainers esta en el pom. Por eso H-B01, H-B02 y H-B03 pasan el CI en verde. Los criterios de aceptacion de seguridad (401/403) no estan probados.
- **Cómo cerrarlo (M):** Agregar pruebas de integracion con MockMvc y el perfil test para login, refresh, reset de contrasena, 401 sin token, 403 sin feature y llave de dispositivo invalida; medir cobertura con jacoco.

### [Alto] H-11 · La app movil no tiene pruebas automatizadas y su CI solo compila el APK en main
- **Repositorio:** `SomnGuard/somnguard-app`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard-app/package.json:12`
- **Por qué importa:** No existe ni un archivo de prueba ni script de test; el workflow android-apk.yml esta solo en main, no corre lint ni pruebas y tuvo dos fallos consecutivos el 2026-10-15 antes de un exito. Los flujos criticos (login, restauracion de sesion, refresco de token) no tienen red de seguridad.
- **Cómo cerrarlo (M):** Anadir jest-expo con pruebas de sessionStore, cliente HTTP y formularios, y un job de lint y test en PR hacia develop y main.

### [Alto] H-12 · El dispositivo edge no tiene CI y sus scripts de instalacion, aprovisionamiento, actualizacion y reset estan vacios
- **Repositorio:** `SomnGuard/somnguard-device`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `scripts/install_service.sh`
- **Por qué importa:** scripts/install_service.sh, provision.sh, update.sh, factory_reset.sh y deploy/somnguard-device.service pesan 0 bytes (git ls-tree -l) pero el Makefile expone los objetivos provision e install-service. No hay forma repetible de instalar, actualizar o revertir el software en una Raspberry Pi, y las 142 pruebas no corren en ningun pipeline (1 ejecucion en total, solo Copilot).
- **Cómo cerrarlo (M):** Escribir la unidad systemd y los scripts (con usuario no root y reinicio automatico), un procedimiento de actualizacion con version y rollback, y un workflow con ruff y pytest.

### [Alto] H-13 · El portal no tiene ni CI ni pruebas y su imagen de despliegue no es reproducible desde el repositorio
- **Repositorio:** `SomnGuard/somnguard-portal`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `package.json:6`
- **Por qué importa:** No hay .github/workflows en ninguna rama (gh api actions/runs: total_count 0), ni script de test, ni Dockerfile o configuracion de Nginx, aunque el manual de despliegue del repo docs dice que se sirve como Nginx en contenedor. El portal llega a produccion sin build verificado, lint ni pruebas automaticas.
- **Cómo cerrarlo (M):** Crear un workflow con npm ci, lint, tsc/build y pruebas (Vitest o Playwright, que ya estan en devDependencies), y versionar el Dockerfile multi-etapa con Nginx no root.

### [Alto] H-14 · Los errores 500 se pierden sin registro y el trace_id que se entrega no corresponde a nada
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/somnguard/platform/error/GlobalExceptionHandler.java:34`
- **Por qué importa:** traceId() devuelve UUID.randomUUID() nuevo en cada respuesta (linea 34) y ninguno de los manejadores, incluido handleGeneric (linea 145), registra la excepcion ni el trace_id; Spring no vuelve a registrar una excepcion ya resuelta. Un usuario puede reportar un trace_id y no habra rastro del fallo. Ademas DataIntegrityViolationException siempre responde DEVICE_CONFLICT con 'asignacion duplicada' (lineas 84-86) aunque la restriccion sea de otra tabla.
- **Cómo cerrarlo (S):** Tomar el trace_id del MDC/traceparent, registrar con log.error(traceId, ex) en handleGeneric y en los conflictos, y diferenciar el codigo del conflicto por nombre de restriccion.

### [Medio] H-08 · DeviceManager es una clase de 1242 líneas que traga errores en silencio
- **Repositorio:** `SomnGuard/somnguard-device`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** matizado (severidad ajustada de alto)
- **Evidencia:** `app/device/manager.py:200`
- **Por qué importa:** 36 bloques 'except Exception' y al menos 10 con 'pass' (líneas 200, 549, 760, 1058, 1100, 1108, 1119, 1140, 1147, 1191) esconden fallos de reconfiguración, conectividad y retención; además se llama a atributos privados de otros objetos (eng._register_success, conn._was_offline) y 42 métodos de estado, red, configuración y streaming comparten una clase, así que cualquier cambio arriesga el resto.
- **Cómo cerrarlo (L):** Separar en coordinadores (estado, heartbeat y registro, sincronización, streaming), registrar con logger cada excepción capturada y exponer métodos públicos en lugar de usar atributos privados.

### [Medio] H-15 · Una sesión vencida deja al usuario en una pantalla que falla en lugar de llevarlo al acceso
- **Repositorio:** `SomnGuard/somnguard-app`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard-app/src/shared/api/client.ts:177`
- **Por qué importa:** Cuando el refresh falla tryRefresh limpia los tokens y devuelve false, pero nada redirige a /(auth)/login y (tabs)/_layout.tsx no tiene guardia; solo SplashScreen decide la ruta una vez al arrancar. El usuario ve errores en cada pantalla sin saber que debe volver a entrar (regla de 401 central de la guía de frontend).
- **Cómo cerrarlo (S):** Emitir un evento de sesión expirada desde apiFetch y que el layout raíz redirija al login con el mensaje 'tu sesión expiró'; agregar guardia en (tabs).

### [Medio] H-16 · El perfil production de EAS no define la URL del API y la app falla al cargar sin ella
- **Repositorio:** `SomnGuard/somnguard-app`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard-app/eas.json:23`
- **Por qué importa:** El perfil production está vacío mientras client.ts:8 lanza un Error en el import si EXPO_PUBLIC_API_URL no existe; un build de producción (el que se publica) arranca con pantalla de error, y solo el perfil preview, que es un APK interno, está bien configurado.
- **Cómo cerrarlo (S):** Definir EXPO_PUBLIC_API_URL en el perfil production y documentar en el README qué perfil se publica.

### [Medio] H-17 · El portal guarda token y refresh token en localStorage y registra datos del usuario en consola
- **Repositorio:** `SomnGuard/somnguard-portal`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-39
- **Evidencia:** `src/shared/api/secureStorage.ts:19`
- **Por qué importa:** El encabezado del archivo promete memoria o cookie httpOnly, pero getAccessToken y getRefreshToken leen localStorage siempre, de modo que cualquier XSS roba la sesión; además auth.api.ts:302 imprime el correo, roles y permisos en la consola del navegador de cada usuario.
- **Cómo cerrarlo (M):** Mantener el access token solo en memoria, mover el refresh a cookie httpOnly cuando el API lo permita y quitar los console.log de producción.

### [Medio] H-18 · El dispositivo no obliga a usar https y su URL por defecto es http
- **Repositorio:** `SomnGuard/somnguard-device`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/common/config.py:87`
- **Por qué importa:** SOMNGUARD_API_URL cae por defecto a http://localhost:8000 y el README documenta http://localhost:8080; ninguna validacion rechaza http en produccion, de modo que la llave del dispositivo y las imagenes viajarian en claro si se configura mal.
- **Cómo cerrarlo (S):** Rechazar esquemas distintos de https salvo con una bandera explicita de desarrollo.

### [Medio] H-19 · La documentación describe un sistema distinto en varios puntos verificables
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard/somnguard-docs:docs/10-devops/local-setup.md:57`
- **Por qué importa:** local-setup usa el perfil develop y /health frente a dev y /actuator/health; ADR-007 (OpenTelemetry/LGTM) y ADR-006 (MinIO) están Aceptadas sin correspondencia en el código; HU-APP-001 exige biometría inexistente; el README de la app trae usuarios mock y el del portal omite la mayoría de sus unas 25 pantallas. Un integrante nuevo no puede fiarse de la documentación.
- **Cómo cerrarlo (M):** Hacer una pasada de conciliación por ADR y por HU marcando 'implementada, diferida o descartada' con el commit o ruta que la prueba, y corregir los README de app, portal y device.

### [Medio] H-20 · Los criterios de éxito del producto no son medibles y el backlog sigue en 'Pendiente'
- **Repositorio:** `SomnGuard/somnguard-docs`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/01-project-context/scope-declaration.md:59`
- **Por qué importa:** El proyecto declara tres criterios cualitativos ('detección y alerta funcionando', 'eventos sin duplicados', 'notificación recibida') sin fórmula, línea base ni meta, y product-backlog.md:48 marca todas las épicas como Pendiente aunque casi todo está construido; no hay forma de decir si SomnGuard cumple su objetivo.
- **Cómo cerrarlo (S):** Definir al menos tres KPI con fórmula, línea base y meta (p. ej. latencia de alerta menor a 2 s, eventos duplicados 0 %, porcentaje de eventos críticos notificados) y actualizar el estado de las épicas.

### [Medio] H-21 · La documentación de experiencia de usuario contiene solo plantillas
- **Repositorio:** `SomnGuard/somnguard-docs`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/12-user-experience/README.md`
- **Por qué importa:** La sección promete prototipos y guías de diseño en Figma pero solo tiene tres plantillas vacías (_template-ux-flows.md, _template-ui-spec.md, _template-design-system.md); app y portal tienen decenas de pantallas, tema propio y 30 colores sin tokens, sin un contrato de flujos, estados ni accesibilidad que los guíe.
- **Cómo cerrarlo (M):** Documentar los flujos principales (alta de cuenta, vincular dispositivo, recibir alerta, ver evidencia), la especificación de pantallas y los tokens reales de tema; enlazar el Figma si existe.

### [Medio] H-22 · Las ramas develop y main de api, app y db han divergido en flujos de despliegue
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git diff --stat origin/main origin/develop (api 10 archivos, app 4, db 1; .github/workflows/deploy-production.yml, docker-publish.yml y android-apk.yml solo en main)`
- **Por qué importa:** El CI/CD de producción y la construcción del APK existen solo en main, así que develop y qa no los ejercitan; qa de app y portal se detuvo en septiembre (49dfeee, 8808410) y cada cambio se replica por copia en tres ramas con SHA distintos, lo que triplica commits y dificulta saber qué está en cada ambiente.
- **Cómo cerrarlo (M):** Definir una dirección única de promoción (feature a develop a qa a main con merge y no con copias), traer los workflows de main a develop y borrar o actualizar las ramas por ambiente obsoletas.

### [Medio] H-23 · Solo 26 de 145 PR tienen revisión humana de alguien distinto al autor; device ninguno
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/SomnGuard/somnguard-device/pulls?state=all (18 PR, todos de Integrante 1, 0 con revisor humano distinto del autor)`
- **Por qué importa:** Revisión humana distinta del autor: api 9 de 55, app 8 de 24, db 4 de 38, portal 5 de 10, device 0 de 18. El repositorio con la lógica de detección no tuvo una segunda mirada y el resto depende de las sugerencias del bot de Copilot, que en varios casos se aceptaron con el mensaje automático 'Potential fix for pull request finding'.
- **Cómo cerrarlo (S):** Exigir un revisor humano distinto del autor en la protección de rama de develop, qa y main de api y device, y repartir las revisiones entre los cuatro.

### [Medio] H-24 · Requisitos de analitica con IA, reporte PDF y analitica en la app (RF-ANA-03/04, HU-APP-003) no estan cumplidos como se documentan
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard/somnguard-docs:docs/04-requirements/traceability-matrix.md:67; SomnGuard/somnguard-api:src/main/java/com/somnguard/analytics/application/usecase/AnalyticsSummaryService.java:18; SomnGuard/somnguard-api:src/main/java/com/somnguard/analytics/adapter/in/web/AnalyticsController.java:109`
- **Por qué importa:** La matriz de trazabilidad y ADR-003 prometen un resumen descriptivo con IA y un reporte PDF/HTML por POST /api/v1/analytics/reports con cache en MinIO, consumido por portal y app (HU-APP-003). El codigo implementa GET /analytics/reports, 'consolidado sin IA' en el comentario del servicio, sin LLM, sin PDF de servidor (el portal lo genera en el navegador) y la app no llama a ningun endpoint de analytics. La documentacion no registra el recorte de alcance.
- **Cómo cerrarlo (S):** Declarar en ADR-003 y en la matriz que el MVP es un resumen sin IA por GET, y marcar RF-ANA-03, RF-ANA-04 y HU-APP-003 como pendientes, o implementarlos.

### [Medio] H-25 · La paginacion del historial de la app lee claves en camelCase y el API responde en snake_case
- **Repositorio:** `SomnGuard/somnguard-app`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard-app/src/shared/api/eventsApi.ts:244`
- **Por qué importa:** El contrato documentado (api-design.md linea 30, user-stories.md linea 473) y el JavaDoc de EventPageResponse dicen pagination{page,page_size,total_items,total_pages}; el portal lee ambas formas (analytics.api.ts linea 60) pero la app solo totalItems/totalPages y cae a data.length. Si el API serializa como documenta, HistoryScreen.tsx:234 calcula una sola pagina y el conductor no puede avanzar a eventos anteriores salvo por filtros de fecha. El formato en snake_case esta fijado en SomnGuard/somnguard-api:src/main/resources/application.yml:33 (property-naming-strategy SNAKE_CASE) y el portal lo comenta ('El backend usa snake_case', auth.api.ts:282); la lectura de la app es directa del codigo y no se ejecuto.
- **Cómo cerrarlo (S):** Leer total_items/total_pages (con respaldo camelCase) en eventsApi.ts y devicesApi.ts, y cubrirlo con una prueba de contrato contra la respuesta real del API.

### [Medio] H-26 · La app no interpreta el sobre de error del API y puede mostrar JSON crudo al usuario
- **Repositorio:** `SomnGuard/somnguard-app`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard-app/src/shared/api/client.ts:144`
- **Por qué importa:** El API responde errores como {error:{code,message,details,trace_id}} (GlobalExceptionHandler); client.ts busca data.message, data.error como cadena o data.errors, y cae a 'texto crudo si es corto' (linea 153), de modo que el mensaje es el JSON completo; profile.service.ts:26 lo reenvia con new Error(e.message). Los flujos con mapeo por estado HTTP (login, claim) lo ocultan, los demas no. El portal si implementa parseApiError (src/shared/api/errors.ts).
- **Cómo cerrarlo (S):** Portar parseApiError del portal a la app y usar error.code para elegir el texto traducido.

### [Medio] H-28 · El README de la app manda a ejecutar comandos en una carpeta donde no existe el proyecto
- **Repositorio:** `SomnGuard/somnguard-app`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:34`
- **Por qué importa:** El README raíz indica npm install y npm run start, pero package.json está en SomnGuard-app/; la raíz solo tiene un package-lock.json vacío. Además lista usuarios mock que el código ya no usa, de modo que quien siga el README no llega a una app funcionando.
- **Cómo cerrarlo (S):** Corregir el README (cd SomnGuard-app, copiar .env.example, perfiles de EAS), eliminar el lockfile vacío y la sección de usuarios mock.

### [Medio] H-29 · El dispositivo no es reproducible: dependencias sin fijar, README con archivo inexistente y puertos por defecto distintos
- **Repositorio:** `SomnGuard/somnguard-device`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `pyproject.toml:12`
- **Por qué importa:** Todas las dependencias van con '>=' sin lockfile (mediapipe y opencv cambian de API entre versiones), el README manda a ejecutar preview_camera.py que no existe y omite el extra stream, y el backend por defecto es localhost:8000 en config.py:87 y localhost:8080 en app/streaming/publisher.py:64.
- **Cómo cerrarlo (S):** Generar un requirements bloqueado (o uv.lock), corregir el README y definir una sola constante de URL por defecto.

### [Medio] H-30 · Traefik (ADR-008) no tiene configuracion versionada en ningun repositorio y el ADR no coincide con el despliegue real
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard/somnguard-docs:docs/05-architecture/decisions/records/ADR-008-traefik-edge-gateway.md:52; SomnGuard/somnguard-docs:docs/10-devops/manual-despliegue-somnguard.md:105; SomnGuard/somnguard-api:docker-compose.yml:31`
- **Por qué importa:** ADR-008 (Aceptada) enruta por PathPrefix(`/api`) y `/` sobre un solo host; el manual de despliegue enruta por subdominios (api.somnguard.tech, somnguard.tech, livekit., turn., download.) desde un directorio deploy/proxy del VPS que no esta en ninguno de los siete repositorios; en el unico repo donde aparece la palabra es un comentario del compose. El enrutamiento y los certificados de produccion no se pueden revisar ni reproducir desde el codigo.
- **Cómo cerrarlo (S):** Versionar deploy/proxy (compose de Traefik sin acme.json ni secretos) en un repo de infraestructura o en somnguard-docs, y actualizar ADR-008 al esquema por subdominios.

### [Medio] H-31 · El modelo de datos de 06-data-architecture quedo atras de la base real
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard/somnguard-docs:docs/06-data-architecture/README.md:26; SomnGuard/somnguard-db:01_ddl/03_tables/0000changelog.yaml; SomnGuard/somnguard-db:01_ddl/03_tables/037_create_monitoring_device_token.sql`
- **Por qué importa:** El README de 06 declara el modelo como fuente de verdad con 20 entidades; 02-modules-entities.md tiene 23 secciones y la base 38 tablas. monitoring.notification_template, monitoring.device_token y monitoring.user_notification_preference (HU-API-009) no estan en el MER, el modelo relacional, 02-modules-entities.md ni el diccionario; los demas desfases (refresh_token, email_verification, auditorias de estado) solo estan en el diccionario. Un equipo nuevo reconstruiria un modelo incompleto.
- **Cómo cerrarlo (S):** Regenerar 01-entity-relationship-model.mmd, 02-relational-model.mmd y 02-modules-entities.md desde el DDL e incluir una verificacion en CI que compare tablas documentadas y tablas del changelog.

### [Medio] H-32 · Cuatro controladores saltan la capa de aplicación y contradicen el ADR-002
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/somnguard/parameterization/adapter/in/web/ParameterizationController.java:46`
- **Por qué importa:** ParameterizationController inyecta cinco repositorios, valida unicidad y devuelve entidades JPA (líneas 46-103); AccountController, AdminRbacController y AuthController también importan repositorios. La documentación promete que el dominio no conoce JPA, y las reglas de negocio quedan sin pruebas unitarias de casos de uso.
- **Cómo cerrarlo (M):** Mover la lógica a casos de uso con puertos de salida, devolver DTO y reemplazar el CRUD repetido por un servicio genérico de catálogos.

### [Medio] H-33 · HistoryScreen mezcla todo en una función de unas 700 líneas con 20 estados
- **Repositorio:** `SomnGuard/somnguard-app`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard-app/src/features/history/screens/HistoryScreen.tsx:111`
- **Por qué importa:** Filtros, fechas, paginación del servidor, catálogo, evidencia y detalle comparten un componente de 955 líneas (el tope de la guía de frontend es 300), con tres catch sin tratamiento (189, 426, 437); es la pantalla más tocada y la más difícil de probar o corregir.
- **Cómo cerrarlo (M):** Partir en hooks (useHistoryQuery, useEvidence), componentes de filtro, lista y detalle, y mover los estilos a un archivo propio; dividir resources.ts por idioma.

### [Medio] H-34 · ApiKeyAuthenticationFilter marca como autenticado a cualquier cliente que envie los dos encabezados, sin comprobar la llave
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/somnguard/platform/security/ApiKeyAuthenticationFilter.java:52-69`
- **Por qué importa:** Con cualquier valor en la cabecera de llave y un UUID cualquiera como identificador, el filtro crea una autenticacion con ROLE_DEVICE; SecurityConfig.java:57 solo exige authenticated(). Hoy los endpoints de dispositivo verifican la llave en el servicio (DeviceApiKeyService.verify) y los demas exigen @RequireFeature, por lo que el impacto actual es acotado, pero cualquier endpoint nuevo sin @RequireFeature quedaria abierto a un cliente anonimo.
- **Cómo cerrarlo (S):** Validar la llave contra el hash almacenado dentro del filtro (o eliminar el filtro y dejar la verificacion en un unico sitio) y agregar una prueba que garantice 401 con llave falsa.

### [Medio] H-35 · El limitador de tasa usa la IP remota del proxy, no crece con limpieza y no cubre los reintentos de codigos
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `src/main/java/com/somnguard/platform/security/RateLimitFilter.java:30-32`
- **Por qué importa:** El filtro usa request.getRemoteAddr() y no hay server.forward-headers-strategy en application.yml; con Traefik delante (ADR-008) todas las solicitudes llegarian con la IP del proxy, de modo que 5 solicitudes por minuto a /api/v1/auth/* serian globales: un atacante puede dejar sin login (y sin refresh) a todos los usuarios. El mapa de cubos no expulsa entradas. Los controladores, en cambio, confian en la primera IP de X-Forwarded-For (DeviceController.java:229-235), que el cliente puede falsificar en la auditoria. Es una inferencia sobre la topologia: no se pudo ejecutar.
- **Cómo cerrarlo (S):** Configurar server.forward-headers-strategy=native con el proxy de confianza, limitar por IP real y por cuenta, y expulsar cubos antiguos (Caffeine o Bucket4j).

### [Medio] H-36 · Credenciales por defecto versionadas como valores de respaldo para S3, coturn y LiveKit
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/resources/application.yml:135-136`
- **Por qué importa:** Si falta la variable de entorno, la API arranca con el usuario y secreto de S3 'minioadmin' (application.yml:135-136; docker-compose.yml:101-102), coturn con contrasena por defecto (docker-compose.yml:66) y un secreto de LiveKit de ejemplo (docker-compose.yml:49). Valores redactados. No hay secretos reales en el historial, pero un despliegue incompleto quedaria con credenciales publicas conocidas, contra la regla 'sin fallback por defecto' del SDLC OS.
- **Cómo cerrarlo (S):** Quitar los valores por defecto de credenciales (fallar en el arranque si faltan) y dejar los ejemplos solo en .env.example.

### [Medio] H-37 · No hay registro de consentimiento ni purga ni retencion en el servidor para datos personales y evidencia de rostros
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/somnguard/security/adapter/in/web/dto/RegisterRequest.java:1`
- **Por qué importa:** El sistema captura imagenes del conductor (dato sensible bajo la Ley 1581) y las guarda en S3, pero RegisterRequest no recibe la aceptacion de la politica (el portal solo marca una casilla en cliente), DELETE /users/me hace baja logica sin purgar evidencia (AccountController.java:152-175) y no hay tarea de retencion en el backend. El boton de gestion de consentimiento de la app no esta conectado.
- **Cómo cerrarlo (M):** Registrar version y fecha de aceptacion en el registro, definir y automatizar la retencion de evidencia, purgar al cerrar la cuenta y conectar la gestion de consentimiento.

### [Medio] H-38 · No existen roles ni permisos de base de datos de minimo privilegio
- **Repositorio:** `SomnGuard/somnguard-db`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `03_dcl/00_roles/0000changelog.yaml:2`
- **Por qué importa:** 03_dcl/00_roles y 03_dcl/01_grants son placeholders vacios; la API y Liquibase usan el mismo usuario propietario de la base. Una inyeccion o una llave filtrada da control total, incluidas las tablas de auditoria.
- **Cómo cerrarlo (S):** Crear roles separados (migrador y aplicacion con DML limitado por esquema) como changesets en 03_dcl y usarlos en los perfiles de la API.

### [Medio] H-40 · El README promete un CI con dependency-check, cobertura y perfil de prueba que el repositorio no tiene
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:146-166`
- **Por qué importa:** El README afirma que CI ejecuta mvn test -Ptest y dependency-check:check y que mvn verify -Ptest mide cobertura; ci.yml corre mvn -B test sin perfil ni dependency-check, pom.xml no define perfiles ni jacoco, y checkstyle esta con failOnViolation false (pom.xml:178). La documentacion da una falsa sensacion de control de calidad y de vulnerabilidades.
- **Cómo cerrarlo (S):** Alinear el README con el pipeline real o implementar lo prometido: jacoco con umbral, dependency-check en CI con clave NVD y checkstyle que falle el build.

### [Medio] H-41 · No hay un plan de rollback real: el despliegue siempre baja latest y la migracion de base de datos corre sin respaldo previo
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker-compose.yml:1`
- **Por qué importa:** En la rama main, deploy-production.yml hace docker compose pull y up --force-recreate de la imagen latest aunque docker-publish.yml tambien etiqueta por SHA, y el despliegue de somnguard-db ejecuta liquibase update sin backup ni smoke test posterior. En el repo docs, docs/10-devops solo contiene _template-rollback-plan.md (plantilla sin completar) y el manual de despliegue no describe como volver atras. Un despliegue defectuoso exigiria improvisar.
- **Cómo cerrarlo (M):** Desplegar por tag SHA/semver parametrizado, documentar y ensayar el rollback de API y de BD (backup previo, liquibase rollback), y agregar un smoke test a /actuator/health al final del job.

### [Medio] H-42 · El perfil dev del API deja que Hibernate modifique el esquema que Liquibase gobierna, y la configuracion de Liquibase del API apunta a un archivo inexistente
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-27
- **Evidencia:** `src/main/resources/application-dev.yml:8`
- **Por qué importa:** application-dev.yml fija ddl-auto en update y .env.example arranca con el perfil dev; application.yml:37 declara change-log classpath:db/changelog/db.changelog-master.xml, que no existe, con enabled en false. Las pruebas usan H2 con create-drop, es decir un esquema generado por Hibernate y no el de somnguard-db. Resultado: una columna que falte en el DDL puede pasar el desarrollo y las pruebas y solo fallar en qa/prod, donde se usa validate. (Mitigante: los 33 entities coinciden hoy con el DDL.)
- **Cómo cerrarlo (M):** Usar validate tambien en dev, borrar la configuracion muerta de Liquibase del API y agregar una prueba de integracion con Testcontainers PostgreSQL que aplique el changelog de somnguard-db.

### [Medio] H-43 · Indices duplicados y redundantes: se pagan en cada escritura sin servir a ninguna lectura
- **Repositorio:** `SomnGuard/somnguard-db`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/10_indexes/001_create_security_indexes.sql`
- **Por qué importa:** Un script sobre el SHA agrupo las 83 definiciones de indice distintas: 28 aparecen dos veces con nombre distinto (idx_user_email_active en 03_tables/001 e ix_user_email_active en 10_indexes/001, igual con role.code, module.code, role_feature.role_id...), y 9 indices repiten una restriccion UNIQUE (idx_refresh_token_token_hash frente a uq_refresh_token_hash, idx_evidence_event_id frente a uq_evidence_event_id, ix_device_config_device_id frente a uq_device_config_device_id). Ademas 3 de 44 FK no tienen indice con esa columna inicial. Los dos prefijos idx_ e ix_ rompen la convencion de nombres.
- **Cómo cerrarlo (S):** Dejar los indices en un solo lugar (10_indexes), eliminar los duplicados con una migracion nueva (DROP INDEX), crear los tres faltantes y unificar el prefijo.

### [Medio] H-44 · Los estados de negocio (status, status_category) no tienen FK y conviven con is_active y deleted_at
- **Repositorio:** `SomnGuard/somnguard-db`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/04_alter/007_fk_parameterization_status.sql`
- **Por qué importa:** ADR-009 y data-dictionary.md (lineas 33, 69 y 70) dicen que status y status_category son FK a parameterization.status y status_category; en el DDL solo existe la FK de status a status_category dentro del catalogo y las columnas de user, device, event y notification, entre otras, son VARCHAR libres. Cualquier texto entra, las transiciones sembradas en status_transition no se imponen en la base, y la categoria depende del estado pero se guarda aparte (no 3FN). Ademas conviven tres senales de ciclo de vida (is_active, deleted_at, status).
- **Cómo cerrarlo (M):** Agregar FK compuestas (status, status_category) hacia parameterization.status en una migracion nueva con limpieza previa, y documentar cual de las tres senales manda.

### [Medio] H-45 · El contrato publicado del API esta incompleto y el README lo contradice
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:135`
- **Por qué importa:** README.md lista /auth/login, /auth/register y /telemetry/events sin /api/v1 y dice que register es solo para administradores (lineas 132-141); SecurityConfig.java:52 lo permite sin autenticacion y la app lo usa publicamente. Solo StreamController tiene anotaciones OpenAPI, no hay ejemplos ni respuestas de error documentadas, el servidor de OpenApiConfig.java:44 es api.somnguard.com (el despliegue es .tech) y el contrato versionado en somnguard-docs solo cubre streaming.
- **Cómo cerrarlo (M):** Anotar los controladores (o exportar /v3/api-docs al repo de docs en CI), corregir la tabla del README y el servidor de produccion.

### [Bajo] H-46 · El portal conserva código de otro entregable y carpetas de compatibilidad sin uso
- **Repositorio:** `SomnGuard/somnguard-portal`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `entrega_vba/UserForm1_codigo.txt`
- **Por qué importa:** entrega_vba/ contiene VBA de Excel ajeno al producto, output/pdf trae PDFs de ejemplo y cinco carpetas @deprecated (src/components, context, hooks, services, utils) solo reexportan; ensucian el repositorio y confunden a quien lo hereda.
- **Cómo cerrarlo (S):** Eliminar entrega_vba/, mover los PDFs de ejemplo a docs y borrar las carpetas deprecated tras actualizar importaciones.

### [Bajo] H-47 · El repositorio somnguard.github.io no tiene README y su historial borró el que tenía
- **Repositorio:** `SomnGuard/somnguard.github.io`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `js/seed.js`
- **Por qué importa:** Es una maqueta de portal y panel administrador con datos literales publicada en una URL pública sin explicar que no es el sistema real; el commit 'Rename README.md to index.md' del 2026-09-09 dejó el repositorio sin explicación.
- **Cómo cerrarlo (S):** Añadir un README que diga que es una maqueta, de dónde salen los datos y qué la separa del portal real.

### [Bajo] H-48 · No hay documentacion de hardware (pines, esquema, versiones)
- **Repositorio:** `SomnGuard/somnguard-device`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:16`
- **Por qué importa:** El README solo menciona camara USB/CSI y Raspberry Pi; no hay conexiones, lista de materiales ni versiones de hardware probadas, lo que impide replicar el dispositivo.
- **Cómo cerrarlo (S):** Agregar docs/hardware con diagrama de conexion, BOM y modelos de camara/altavoz probados.

### [Bajo] H-49 · Una cuarta parte de los commits no sigue la convención y hay commits automáticos sin reescribir
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git log --all --no-merges (204 commits únicos, 151 convencionales)`
- **Por qué importa:** Mensajes como 'first commit', 'Update', 'mockup v1' y 'Potential fix for pull request finding' (sugerencias de Copilot aceptadas) no dicen qué cambió ni por qué, lo que dificulta el seguimiento y la trazabilidad HU a commit.
- **Cómo cerrarlo (S):** Activar commitlint o una plantilla de PR con el tipo de cambio y exigirla en la protección de rama.

### [Bajo] H-50 · Los clientes web y movil usan convenciones distintas para la URL base del API
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard/somnguard-portal:.env.example:1; SomnGuard/somnguard-app:SomnGuard-app/.env.example:8`
- **Por qué importa:** El portal toma VITE_API_URL con el sufijo /api/v1 incluido (endpoints.ts linea 6 y el manual de despliegue linea 124) y la app toma EXPO_PUBLIC_API_URL sin /api/v1 y anade el prefijo en cada llamada; una misma URL copiada de un cliente al otro rompe todas las rutas.
- **Cómo cerrarlo (S):** Unificar la convencion y validarla al arrancar (rechazar la URL si termina o no termina en /api/v1).

### [Bajo] H-51 · Vistas materializadas de analitica sin refresco ni consumidor
- **Repositorio:** `SomnGuard/somnguard-db`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/06_materialized_views/002_create_analytics_v_metrics_daily.sql`
- **Por qué importa:** analytics.v_event_timeline y analytics.v_metrics_daily se crean en el changelog pero ninguna sentencia las refresca y el adaptador de analitica del API declara que no las usa (AnalyticsEventQueryAdapter.java:45); RF-ANA-02 y ADR-003 las presentan como la via de optimizacion. Ocupan espacio, fijan la zona America/Bogota en el SQL y confunden al lector.
- **Cómo cerrarlo (S):** Eliminarlas con una migracion o programar REFRESH CONCURRENTLY y usarlas desde el adaptador.

### [Bajo] H-52 · El dispositivo marca todo evento como is_offline_sync verdadero
- **Repositorio:** `SomnGuard/somnguard-device`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/common/models.py:185`
- **Por qué importa:** build_telemetry_event fija is_offline_sync en True (linea 185) y el modelo lo tiene por defecto en True (linea 116); con un buffer offline-first (ADR-005) el campo podria significar 'paso por el buffer', pero entonces no distingue eventos en tiempo real de los reenviados tras una caida, que es lo que la tabla telemetry_service.event.is_offline_sync y la analitica esperan.
- **Cómo cerrarlo (S):** Marcar True solo cuando el evento se envia despues de haber estado pendiente mas que un umbral, y documentar la semantica.

### [Bajo] H-53 · ADR-004 manda UUID v7 generado en la app y el codigo y las semillas generan UUID v4
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `SomnGuard/somnguard-docs:docs/05-architecture/decisions/records/ADR-004-database-strategy.md:60; SomnGuard/somnguard-api:src/main/java/com/somnguard/security/application/usecase/RegisterUserService.java`
- **Por qué importa:** El API llama UUID.randomUUID() en 41 sitios, las semillas usan gen_random_uuid() y las auditorias DeviceStatusAuditEntity y NotificationStatusAuditEntity usan GenerationType.IDENTITY, todo contrario a lo que fija el ADR. Se pierde el orden temporal de las claves que justificaba la decision.
- **Cómo cerrarlo (S):** Adoptar un generador UUID v7 en el API (o corregir ADR-004 y el diccionario si se acepta v4).

### [Bajo] H-54 · Una excepción tragada pierde el evento de auditoría de cambio de estado del dispositivo
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/somnguard/device_management/application/usecase/DeviceService.java:537`
- **Por qué importa:** catch (Exception ignored) {} alrededor de events.publishEvent descarta cualquier fallo sin log, así que una transición de estado puede quedar sin notificación ni rastro; y el límite de tasa del streaming sigue como TODO (StreamController.java:30).
- **Cómo cerrarlo (S):** Registrar la excepción con logger.warn y decidir si el fallo debe revertir la transición; implementar o retirar el TODO del límite de tasa.

### [Bajo] H-55 · OpenAPI, Swagger y /actuator/info son publicos en todos los perfiles y el perfil por defecto es dev
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/somnguard/platform/config/SecurityConfig.java:51`
- **Por qué importa:** /v3/api-docs, /swagger-ui y /actuator/info (con info.env, java y os habilitados) no exigen autenticacion; SPRING_PROFILES_ACTIVE por defecto es dev (application.yml:11), con show-details always, ddl-auto update y registro DEBUG de Spring Security.
- **Cómo cerrarlo (S):** Cerrar swagger e info en prod, no tener perfil por defecto dev y fallar si no se define el perfil.

### [Bajo] H-56 · El README del app publica usuarios mock con contrasenas triviales que ya no existen en el codigo
- **Repositorio:** `SomnGuard/somnguard-app`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:55`
- **Por qué importa:** Las cuentas de ejemplo ««redactado»» (README.md:55 del repo de la app) vienen del mock de agosto (commit 51998a0) y solo confunden; si alguien las creo en el backend de prueba, serian credenciales conocidas.
- **Cómo cerrarlo (S):** Eliminar la seccion de usuarios mock del README del app.

### [Bajo] H-57 · Falta HEALTHCHECK en la imagen y el indicador de migraciones de develop siempre responde UP
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/somnguard/platform/config/HealthConfig.java:36`
- **Por qué importa:** liquibaseHealthIndicator devuelve Health.up() con detalle 'pending' sin comprobar nada (main ya lo elimino), y ni Dockerfile ni docker-compose.yml declaran HEALTHCHECK, por lo que el orquestador no reinicia una API colgada.
- **Cómo cerrarlo (S):** Eliminar el indicador falso en develop y agregar HEALTHCHECK a /actuator/health/readiness.

### [Bajo] H-58 · El buffer SQLite del dispositivo no tiene version de esquema
- **Repositorio:** `SomnGuard/somnguard-device`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/storage/buffer.py:34`
- **Por qué importa:** El esquema se crea con CREATE TABLE IF NOT EXISTS sin PRAGMA user_version ni migraciones; cuando una version nueva del firmware necesite otra columna, los dispositivos en campo con eventos pendientes no podran actualizarse sin perderlos.
- **Cómo cerrarlo (S):** Registrar PRAGMA user_version y una funcion de migracion al abrir el buffer.

### [Bajo] H-59 · Detalles REST inconsistentes: Location inexistente, PUT y PATCH mezclados, acciones como PATCH
- **Repositorio:** `SomnGuard/somnguard-api`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/somnguard/security/adapter/in/web/AuthController.java:60`
- **Por qué importa:** El Location de POST /auth/register apunta a /api/v1/auth/register/{id}, ruta que no existe; roles, features y dispositivos se actualizan con PUT y los catalogos con PATCH; rotate-key es PATCH aunque crea una credencial nueva (DeviceController.java:202).
- **Cómo cerrarlo (S):** Devolver Location a /api/v1/users/{id} o quitarlo, elegir PATCH para actualizaciones parciales y POST para rotate-key.

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 85.7 |
| D2 | Reproducibilidad | 64.5 |
| D3 | Arquitectura y congruencia | 66.7 |
| D4 | Calidad de código | 61.4 |
| D5 | Seguridad | 76.0 |
| D6 | Pruebas | 47.2 |
| D7 | DevOps y despliegue | 71.7 |
| D8 | Datos | 80.0 |
| D9 | API y contratos | 65.0 |
| D10 | Frontend y móvil | 75.0 |
| D11 | IoT y firmware | 85.0 |
| D12 | Documentación y trazabilidad | 61.1 |
| D13 | Proceso y colaboración | 52.6 |
| D14 | Extremo a extremo | 61.5 |

## Lo que está bien

- Migraciones de base de datos de nivel profesional (`SomnGuard/somnguard-db:changelog/changelog-master.yaml; 92 changesets, todos con rollback y rutas validas (script contra el SHA); scripts/verify-rollback.sh se ejecuta en .github/workflows/liquibase.yml con ejecuciones success el 2026-10-08, incluido el despliegue de produccion.`)
- Integridad referencial declarada en el esquema (`SomnGuard/somnguard-db:01_ddl/04_alter/012_fk_telemetry_service_event.sql; las 44 claves foraneas declaran ON DELETE y ON UPDATE; tipos TIMESTAMPTZ, UUID y JSONB, CHECK por dominio y unicos parciales para borrado logico.`)
- Las 33 entidades JPA coinciden con el DDL (`SomnGuard/somnguard-api:src/main/java/com/somnguard/security/adapter/out/persistence/entity/UserEntity.java contra SomnGuard/somnguard-db:01_ddl/03_tables/001_create_security_user.sql; comparacion de columnas por script sobre ambos SHA sin faltantes, y perfiles qa/prod en ddl-auto validate.`)
- Contrato dispositivo-API coherente de punta a punta (`SomnGuard/somnguard-device:app/device/backend.py:137 (self-register con X-Provision-Token e Idempotency-Key) contra SomnGuard/somnguard-api:src/main/java/com/somnguard/device_management/adapter/in/web/DeviceController.java:86; los codigos EV-* que emite el dispositivo existen todos en SomnGuard/somnguard-db:02_dml/00_inserts/005_insert_event_type.sql.`)
- Sobre de error uniforme, paginacion y versionado en el API desplegado (`SomnGuard/somnguard-api:src/main/java/com/somnguard/platform/error/ErrorResponse.java; rutas /api/v1; GET https://api.somnguard.tech/actuator/health devuelve 200 y /api/v1/events sin credenciales devuelve 401.`)
- Documentacion honesta sobre lo que no hay y cliente web que centraliza el contrato (`SomnGuard/somnguard-docs:docs/02-domain/domain-events.md:83 admite que no hay mensajeria entre modulos; SomnGuard/somnguard-portal:src/shared/api/endpoints.ts concentra todas las rutas y src/shared/api/errors.ts interpreta el sobre de error.`)
- Semillas idempotentes y editables sin romper checksums (`SomnGuard/somnguard-db:02_dml/00_inserts/0000changelog.yaml:156 (runOnChange en las semillas de features) y 02_dml/00_inserts/009_insert_security_roles.sql con ON CONFLICT.`)
- Autenticacion JWT RS256 con bloqueo de cuenta y contrasenas con bcrypt (`src/main/java/com/somnguard/platform/config/SecurityConfig.java:59 y src/main/java/com/somnguard/platform/config/SecurityBeansConfig.java:12 (SomnGuard/somnguard-api); bloqueo tras fallos en src/main/java/com/somnguard/security/application/usecase/AuthService.java:74`)
- Llaves de dispositivo con SHA-256 y comparacion en tiempo constante, mostradas una sola vez (`src/main/java/com/somnguard/device_management/application/service/DeviceApiKeyService.java:40-56 (SomnGuard/somnguard-api)`)
- RBAC por features con interceptor central y propiedad estricta de la evidencia por usuario (`src/main/java/com/somnguard/platform/security/RequireFeatureInterceptor.java:20 y src/main/java/com/somnguard/telemetry_service/application/usecase/UserEventEvidenceService.java:48 (SomnGuard/somnguard-api)`)
- Dockerfile multi-etapa con usuario no root (`Dockerfile:1 (SomnGuard/somnguard-api)`)
- Historial limpio: sin claves privadas, JWT ni llaves de proveedores en las ramas de los 7 repositorios (`git log --all -p -G sobre cada clon, sin coincidencias de BEGIN PRIVATE, eyJhbGciOi, xkeysib ni ghp_; llaves PEM en src/main/resources/keys/dev/.gitkeep y .gitignore del API`)
- Pipeline completo de build, imagen en GHCR por SHA y despliegue a VPS que responde 200 (`gh api repos/SomnGuard/somnguard-api/actions/runs (Docker Publish y Deploy API Production en success el 2026-10-15) y GET https://api.somnguard.tech/actuator/health con 200`)
- Migraciones con rollback verificado automaticamente en CI (`scripts/verify-rollback.sh y .github/workflows/liquibase.yml (SomnGuard/somnguard-db); 05_rollbacks con un reverso por changeset`)
- Tokens de la app en SecureStore y firma del APK con secretos de GitHub (`SomnGuard-app/src/shared/api/sessionStore.ts:17 (SomnGuard/somnguard-app)`)
- Dispositivo con identidad en archivo 0600, buffer offline con backoff y 142 pruebas unitarias (`app/device/identity.py:133, app/sync/engine.py:30 y tests/unit/test_manager_states.py (SomnGuard/somnguard-device)`)
- Pruebas unitarias numerosas y significativas en la API (126 @Test) (`src/test/java/com/somnguard/device_management/application/usecase/DeviceConfigServiceTest.java:1 (SomnGuard/somnguard-api)`)
- Repositorio de datos ejemplar: 38 tablas con Liquibase, rollbacks y verificación automática (`01_ddl/03_tables/0000changelog.yaml; scripts/verify-rollback.sh (SomnGuard/somnguard-db)`)
- Historias de usuario con criterios de aceptación verificables: 33 HU y 152 criterios con pantalla o endpoint nombrado (`SomnGuard/somnguard-docs:docs/04-requirements/user-stories.md:179`)
- Trazabilidad RF a HU a módulo a ADR a pruebas y 13 ADR documentados (`SomnGuard/somnguard-docs:docs/04-requirements/traceability-matrix.md:21`)
- Flujo de ramas por ambiente con 162 PR hacia develop/qa/main, revisión cruzada humana en una parte de ellos y tablero de 32 ítems (23 Done) (`gh api repos/SomnGuard/somnguard-api/pulls; gh project item-list 1 --owner SomnGuard`)
- Actividad en las 8 semanas de la ventana (semanas 35 a 42) con commits cada semana (`git log --all --no-merges --since=2026-08-27 en los 7 repos`)
- Portal con rutas protegidas por sesión, rol y permiso, refresco silencioso de sesión y estados de carga, vacío y error (`src/app/router/AppRouter.tsx (SomnGuard/somnguard-portal)`)
- App móvil con cliente HTTP con timeout, rotación de refresh, mensajes sin URL y tokens en SecureStore (`SomnGuard-app/src/shared/api/client.ts (SomnGuard/somnguard-app)`)
- API con Dockerfile multi-etapa y usuario no root, arquitectura hexagonal por módulo, Swagger y 23 archivos de prueba (`Dockerfile; pom.xml:91 (SomnGuard/somnguard-api)`)
- Edge offline-first con buffer SQLite, sincronización y 16 archivos de prueba unitaria (`tests/unit/test_sync.py; app/storage/buffer.py (SomnGuard/somnguard-device)`)

## Lo que no se pudo verificar

- Ejecucion real de los flujos (Liquibase update, arranque del API, recorrido login-eventos-notificacion) — El briefing prohibe ejecutar el codigo de los aprendices; los trazados son por lectura de rutas, DTO, entidades y DDL, y por las ejecuciones de CI consultadas con gh api.
- Formato real (snake_case) con el que el API serializa las respuestas, base de H-A04 — Se deriva de application.yml:33, del JavaDoc de EventPageResponse, de api-design.md y del comentario del portal; no se hizo una peticion autenticada ni se leyo el cuerpo de /v3/api-docs (solo se consulto el codigo HTTP).
- Flujo autenticado contra https://api.somnguard.tech (T-14.3) — No hay credenciales de prueba del equipo; solo se hicieron cuatro GET de lectura (health 200, portal 200, api-docs 200, events 401).
- Configuracion de Traefik, SeaweedFS y LiveKit del VPS — El manual de despliegue la sitúa en directorios deploy/ que no estan en ninguno de los siete repositorios.
- Contenido de las ramas adelantadas del API, app, db y portal — Revisado solo con git diff --stat contra la rama evaluada: main del API agrega los workflows deploy-production.yml y docker-publish.yml y ajustes de .env.example, docker-compose.yml y perfiles (10 archivos); main de la app agrega la compilacion y firma del APK Android en CI; main de db agrega .github/workflows/deploy-production.yml; main del portal difiere solo en package-lock.json. Las ramas feat/* y hu-* son ramas de promocion por ambiente; no se inspeccionaron una a una. La divergencia del dispositivo si se analizo (H-A03).
- Persistencia en memoria de sesiones de video (StreamSessionService, DetectionPauseService) — Usan ConcurrentHashMap, documentado como post-MVP; el comportamiento con mas de una instancia o tras reinicio exige ejecutar el API.
- Almacenamiento de evidencia en produccion (ADR-006 MinIO, compose con S3Mock, manual con SeaweedFS) — Tres tecnologias distintas en documentos y compose; cual corre en produccion no es verificable desde los repositorios.
- Ejecucion de la API, la app, el portal y el firmware (explotabilidad real de H-B01, H-B02 y H-B09, comportamiento detras de Traefik) — Las reglas prohiben ejecutar el codigo de los aprendices; los hallazgos se basan en lectura del SHA evaluado.
- npm audit, mvn dependency-check y pip-audit (vulnerabilidades de dependencias) — Exigen instalar o ejecutar herramientas y consultar bases externas; no se ejecutaron.
- El estado de la rama main de la API, app y db (workflows de despliegue y correcciones) frente al SHA evaluado develop — El SHA evaluado es develop; los archivos .github/workflows/deploy-production.yml, docker-publish.yml y android-apk.yml se leyeron con git show de origin/main solo como contexto de proceso: main contiene 32 commits no integrados en develop del API (HealthConfig sin el indicador falso, perfiles sin contextos liquibase, claves JWT por docker secrets, workflows de produccion).
- Configuracion real del VPS (Traefik, headers, secretos, backups) y el despliegue del portal y de LiveKit — Solo se hizo un GET a /actuator/health de la API; el resto vive en el servidor, no en los repositorios.
- Los changesets de 02_dml y datos semilla con credenciales por defecto, y si existe un usuario administrador inicial — Pertenece a D8 (otro especialista); aqui solo se reviso lo relativo a seguridad.
- Contenido de deploy/somnguard-device.service y scripts de provision/instalacion del dispositivo — Los cinco archivos tienen 0 bytes en el SHA evaluado; no hay nada que leer. Pueden existir en otra rama no revisada.
- Cobertura real de pruebas — Ningun repositorio publica informe de cobertura y medirla exige ejecutar las pruebas.
- Muestreo de D4: lectura en profundidad solo de app/device/manager.py (1242 líneas) y SomnGuard-app/src/features/history/screens/HistoryScreen.tsx (955 líneas) como los dos componentes más grandes por líneas, más ParameterizationController.java y DeviceService.java del API — Alcance del briefing: los ítems de D4 de los demás archivos descansan en greps (TODO, catch, console.log, localhost) y no en lectura completa; resources.ts (1777 líneas) se excluyó por ser datos de traducción.
- Compilación del portal y de la app, arranque en navegador o emulador y comportamiento real de las pantallas — Está prohibido ejecutar npm, expo o cualquier script de los aprendices; R-10.1 se evaluó por configuración estática.
- Roles de colaboradores y propietarios de la organización SomnGuard (T-13.6) — gh api responde 403/404 sin permisos de push o alcance user; solo se ve a Integrante 1 como miembro público.
- Contenido de las historias del tablero 'Somnguard - Backlog' más allá de su estado — Se contó el tablero (32 ítems) pero no se cruzó cada ítem con su PR.
- Cuentas: se fusionaron solo las que comparten correo (Integrante 2 con 'Integrante', Integrante 1 con 'Integrante', 'Integrante' con Integrante 4) — Regla de la rúbrica; no hay sospechas de segunda cuenta sin confirmar.
- Documentación en Drive — El equipo no declara Drive: toda su documentación está en somnguard-docs, así que no aplicó la regla de Drive.
- Presupuesto de lecturas de sdlc-os — Se usaron 7 lecturas de la carpeta (3 briefs, senior-frontend, react, producto-ux y principios de frontend); no se leyó nada más de esa carpeta.
- D4 y D10 de somnguard.github.io — Maqueta estática de tipo otro; se marcó NA en D4 y D10 y no se muestreó su JavaScript.
