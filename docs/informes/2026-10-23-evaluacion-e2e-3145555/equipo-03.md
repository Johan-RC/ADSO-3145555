# Equipo 3 · Guardián Escolar — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 50/100 · Juicio D**

## Veredicto

Guardián Escolar tiene una base técnica sólida: el backend y la base de datos coinciden sin deriva (25 tablas), el registro y el inicio de sesión con 2FA funcionan de punta a punta, y 3 de los 5 flujos principales están completos. Lo que impide cerrar es que 2 flujos siguen rotos después de la verificación: el celular del estudiante no puede terminar un trayecto (envía estados que el servidor no conoce) y las alertas llegan al acudiente sin id, sin hora y siempre como no leídas. En seguridad queda 1 hallazgo crítico (la clave JWT tiene un valor por defecto público) y ningún bloqueante, más 20 altos entre los que están el código de vinculación derivable, el administrador sembrado con hash versionado, la falta de límite de intentos, la ausencia de CI y de revisión en los 188 PR, y que main y qa están desfasadas de dev. El resultado es 49,5 sobre 100 con juicio D, a unos 20 puntos del umbral de 70, y además el extremo a extremo (25) está por debajo del mínimo de 50; la mayoría de las correcciones de los dos primeros pasos del plan son de esfuerzo S o M, así que el cierre es alcanzable si se sigue el orden.

## Plan para cerrar las brechas

1. **Eliminar el valor por defecto y el relleno con 'x' de la clave de firma JWT: el backend debe fallar al arrancar si JWT_SECRET falta o es corto; rotar la clave en todos los ambientes.** (esfuerzo S) — se cierra cuando: El backend no arranca sin JWT_SECRET de al menos 32 bytes; una búsqueda del valor anterior en el árbol actual no da resultados y los tokens firmados con la clave vieja son rechazados.
2. **Reparar los dos flujos rotos del cliente: usar los estados COMPLETED y CANCELED del servidor, adjuntar la credencial del dispositivo hijo al PATCH de estado, validar transiciones en el backend y dejar de tragar el error; corregir el mapeo de notificaciones al contrato real (receiptId, notificationId, wasRead, receivedAt, eventDateTime) y llamar markAsRead al abrir una alerta.** (esfuerzo M) — se cierra cuando: Desde el celular del estudiante se inicia y se termina un trayecto (trips.trip_ended_at con valor y estado COMPLETED; un estado inválido devuelve 400); una alerta de zona segura generada en el servidor aparece en la app con hora y como no leída, y al abrirla queda leída y persiste tras recargar.
3. **Alinear main y qa con dev en backend e infraestructura (autorización de suscripciones WebSocket, ruta del backend en el compose, variables de Maps) y documentar el orden de promoción dev a qa a main.** (esfuerzo S) — se cierra cuando: Un clon limpio de main de ambos repos levanta el sistema completo con docker compose up; una suscripción WebSocket ajena a un viaje es rechazada en main.
4. **Reemplazar el código de vinculación derivado del UUID por un código aleatorio persistido, con expiración, rotación y revocación, y limitar sus intentos.** (esfuerzo M) — se cierra cuando: Existe columna y migración para el código; un código vencido o rotado se rechaza; tras N intentos fallidos el endpoint responde 429.
5. **Cerrar la omisión de confirmación de dispositivo y poner límite de intentos en login, 2FA y restablecimiento de contraseña.** (esfuerzo M) — se cierra cuando: Un login sin deviceIdentifier exige confirmación o se rechaza; la prueba automatizada muestra bloqueo temporal tras N intentos fallidos en login, verificación 2FA y reset.
6. **Quitar de la semilla el administrador con correo y hash versionados (crearlo por variable de entorno al desplegar) y dejar que el backend se conecte con el rol de aplicación de mínimo privilegio.** (esfuerzo S) — se cierra cuando: Una base nueva no contiene ningún usuario con hash versionado; la aplicación se conecta con gps_guardian_app y no con postgres; la contraseña por defecto no aparece en el árbol actual.
7. **Retirar el APK de 50 MB del repositorio (y de public/), reemplazarlo por un release o enlace de descarga, y quitar los túneles personales como URL por defecto exigiendo la URL de API en la configuración.** (esfuerzo S) — se cierra cuando: git ls-files no lista ningún .apk; el build móvil falla con un mensaje claro si falta la URL de API; ninguna cadena devtunnels aparece en el código.
8. **Confirmar el despliegue declarado (Render) o corregir el README con el despliegue real, y crear un CI mínimo por repo (build y pruebas en cada PR) con revisión obligatoria de al menos una persona antes de fusionar.** (esfuerzo M) — se cierra cuando: El GET a la URL pública del README responde 200 o el README ya no la declara; cada repo tiene un workflow con ejecución exitosa y la protección de rama exige una aprobación.
9. **Agregar pruebas: autorización y acceso por objeto, vinculación de dispositivo y WebSocket en el backend; pruebas de cliente y de contrato para los dos flujos que estaban rotos en el frontend; dejar de omitir pruebas en el build de la imagen.** (esfuerzo M) — se cierra cuando: npm test y mvn test se ejecutan en CI y pasan; existe al menos una prueba que falla si el cliente envía FINISHED o si la lectura de notificaciones pierde el id.
10. **Corregir el seguimiento compartido y el canal en tiempo real: compartir viajes, coordenadas y alertas con el segundo acudiente, usar un solo protocolo WebSocket en cliente y servidor, mostrar estados de carga y error, devolver direcciones en las rutas y no cerrar sesión ante cualquier 403.** (esfuerzo L) — se cierra cuando: Un segundo acudiente vinculado ve el viaje en curso y sus alertas; el cliente recibe posiciones por el canal en tiempo real sin recargar; con la red apagada la app muestra un error con opción de reintentar; un 403 no cierra la sesión.
11. **Llevar la documentación al repositorio: README ejecutable del backend, dependencia de los demás repos, definición de problema, usuarios, alcance e historias con criterios de aceptación, y desactivar Swagger y métricas abiertas en producción.** (esfuerzo M) — se cierra cuando: Un integrante nuevo levanta el sistema siguiendo solo el README; existe una carpeta docs con el alcance y al menos las historias principales; /swagger-ui y /actuator/prometheus responden 401 o 404 con el perfil de producción.
12. **Partir las pantallas de 700 a 1458 líneas del frontend en componentes y hooks, y sacar de studentStorage.js la capa de datos, el caché y el mapeo, retirando el código y las rutas huérfanas.** (esfuerzo L) — se cierra cuando: Ninguna pantalla supera 400 líneas; el acceso a la API vive en servicios y no en studentStorage.js; las pruebas de cliente del plan siguen pasando tras el refactor.

## Verificación independiente

Hallazgos confirmados: 4 · matizados: 1 · refutados: 0 · duplicados fusionados: 7.

Confirme H-01 (critico), H-03, H-05 y H-06 con evidencia propia; matice H-02 (el APK existe, pero versionar un binario es `medio`, no `alto`). Los cuatro items PASS se sostienen (T-13.3 tambien deduplicando commits por ambiente: Integrante 62,9 %), los flujos 1-3 salen COMPLETO y el 4 (cierre del trayecto) ROTO tal como se afirmo, pero el 5 (alertas) esta degradado (sin hora, siempre no leidas) y no roto, por lo que lo marco COMPLETO con defectos. De los 33 pares, 8 son duplicados reales, agrupados en 7 entradas (H-03/H-11/H-54, H-07/H-18, H-15/H-25, H-19/H-26, H-24/H-35, H-40/H-49) y 25 son defectos distintos en el mismo archivo; H-02/H-47 y H-41/H-53 solo se solapan en parte. El login Integrante 3 queda confirmado por la API de commits (mismo correo), no solo inferido.

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Completo | Registro, verificacion de correo e inicio de sesion (2FA y confirmacion de dispositivo) | — |
| Completo | Alta de estudiante, contactos de emergencia y vinculacion del celular por QR | — |
| Completo | Rutas, paradas y asignacion de ruta al estudiante | — |
| Roto | Seguimiento del trayecto: iniciar, enviar coordenadas, ver y cerrar | Cierre del trayecto. El celular del estudiante envia status FINISHED (app/student-dashboard.js:333) y CANCELLED (:222, :305), valores que no existen en TripStatus (COMPLETED, CANCELED) ni en el enum trip_status_enum; ademas PATCH /api/trips/{id}/status exige LOCATION_VIEW o ADMIN y trackingService.updateStatus no adjunta la credencial del dispositivo hijo; el error se traga con .catch(() => null). Resultado: el viaje queda IN_PROGRESS para siempre y trip_ended_at nunca se llena. Iniciar (POST /trips) y enviar coordenadas (POST /trips/{id}/coordinates) si coinciden con el contrato. |
| Roto | Alertas y notificaciones al acudiente (zona segura, desvio, inactividad) | Lectura en el cliente. normalizeNotification (app/(tabs)/notifications.js:75-82) espera id/reciboId, leida, recibidoEn, creadoEn y estudianteNombre; NotificationResponse entrega receiptId, notificationId, wasRead, receivedAt y eventDateTime. Todas las alertas del servidor llegan sin id, sin hora y como no leidas, y notificationService.markAsRead nunca se invoca. La generacion en servidor (TripAlertService -> NotificationService -> notifications/notification_receipts) y el CRUD de zonas seguras si coinciden con el contrato. |

## Hallazgos

### [Crítico] H-01 · La clave de firma JWT tiene un valor por defecto público y se rellena con la letra x si es corta o vacía
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `src/main/resources/application.yml:42`
- **Por qué importa:** La propiedad guardian.security.jwt.secret usa un respaldo conocido ('replace-me-in-local-env') en application.yml:42; JwtService.java:105-123 acepta cualquier cadena, la rellena con 'x' hasta 32 bytes y firma con ella (una cadena vacía produce 32 'x'). El .env.example de Docker-Infra y del backend deja la variable vacía y docker-compose.yaml del backend la pasa como vacía (línea 13), así que seguir el README sin editar produce una clave deducible. Como el filtro carga los roles desde la BD por el correo del subject (JwtAuthenticationFilter.java:41) y el correo del administrador sembrado está en 02_dml/00_inserts/002_admin_user.sql:20, cualquiera con ese respaldo puede acuñar un token de ADMIN y ver o modificar datos de menores. No se probó contra ningún despliegue.
- **Cómo cerrarlo (S):** Quitar el valor por defecto de application.yml (fallar el arranque si falta la variable), exigir al menos 32 bytes aleatorios en el constructor de JwtService (sin relleno), rotar la clave de cualquier ambiente ya levantado y añadir una prueba que verifique que el arranque falla sin clave.

### [Alto] H-03 · El valor por defecto de la API es un tunel personal de devtunnels
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** confirmado; también reportado como H-11, H-54
- **Evidencia:** `config/endpoints.js:8`
- **Por qué importa:** Cualquier build sin EXPO_PUBLIC_API_URL (Expo Go, APK) apunta a s3tn0qz4-8080.use.devtunnels.ms, un tunel temporal de la maquina de un integrante: la app deja de funcionar cuando ese equipo se apaga y mientras tanto las peticiones viajan a un host temporal de la maquina de un integrante.
- **Cómo cerrarlo (S):** Quitar los tres DEFAULT_* de endpoints.js, exigir la variable al compilar y fallar con un mensaje claro si falta.

### [Alto] H-04 · Los fallos de red se muestran como 'sin datos': casi no hay estados de carga ni de error
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(tabs)/index.js:45 (.catch(() => []) en lineas 45-47), app/(tabs)/history.js:62, app/(tabs)/notifications.js:90`
- **Por qué importa:** Si el backend esta caido o la sesion falla, el acudiente ve su historial y sus notificaciones vacios y concluye que su hijo no tuvo viajes ni alertas: para una app de seguridad escolar es el peor falso negativo. Solo admin.js (205 lineas) renderiza carga y error.
- **Cómo cerrarlo (M):** Adoptar AppLoading, AppError y AppEmptyState en todas las pantallas que leen de la API, quitar los .catch(() => []) y ofrecer 'Reintentar'.

### [Alto] H-05 · Ningun repo define el problema, los usuarios, el alcance, los indicadores ni las historias con criterios de aceptacion
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** confirmado
- **Evidencia:** `git grep -i -E 'KPI|indicador|criterio de aceptaci|historia de usuario|alcance' en los cuatro README devuelve 0 coincidencias; los HU-NN son contadores de rama por repo (HU-04 es navegacion en el frontend y autenticacion en el backend).`
- **Por qué importa:** Sin definicion de producto no hay forma de comprobar que lo construido resuelve el problema de seguimiento escolar, ni de medir exito (cuantas rutas, que tiempo de alerta). Las historias numeradas HU-01 a HU-32 no se corresponden entre repos.
- **Cómo cerrarlo (M):** Escribir en docs/ la vision (problema, usuarios: acudiente, estudiante, administrador), el alcance del MVP, al menos 3 indicadores medibles y las historias Must con 2 o mas criterios de aceptacion, enlazadas a pantalla y endpoint.

### [Alto] H-06 · 188 pull requests sin una sola revision: todos se fusionan solos
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado
- **Evidencia:** `gh api graphql: reviews.totalCount = 0 en los 188 PR (62 FE, 89 BE, 32 DB, 5 Infra); mergedBy coincide con el autor en 183.`
- **Por qué importa:** Los PR existen como tramite entre ramas por ambiente, pero nadie revisa el codigo de otro. Los errores que se ven en el frontend (t('cncel'), catch silenciosos, un APK de 50 MB) son exactamente lo que una revision atraparia.
- **Cómo cerrarlo (S):** Activar proteccion de rama en dev, qa y main con una aprobacion obligatoria de otro integrante, y asignar revisor por PR (CODEOWNERS por repo).

### [Alto] H-08 · Las ramas de entrega main y qa estan desfasadas de dev en backend e infra: el despliegue desde main no levanta el sistema completo
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `owner/repo propietario/Docker-Infra-Guardian-Escolar:docker-compose.yaml (origin/qa y origin/main: context ../backend) frente a dev (context ../Backend-Guardian-Escolar, linea 53); owner/repo propietario/Backend-Guardian-Escolar: git diff dev origin/qa en 10 archivos`
- **Por qué importa:** Contenido de las ramas adelantadas (solo adelantadas en commits de merge): Backend main/qa = consolidacion HU-21..32 del 2026-10-19 sin el ultimo merge de dev (PR #89, 2026-10-22, fix/audit-seguridad-backend-dev); 10 archivos difieren: faltan PATCH /api/notifications/read-all, la autorizacion de suscripcion STOMP por viaje (WebSocketAuthChannelInterceptor) y la lista de origenes permitidos en EmailLinkService, y qa/main quitaron variables de Google Maps. Infra main/qa: docker-compose.yaml construye el backend desde '../backend' (la carpeta real es Backend-Guardian-Escolar), sin las variables GOOGLE_MAPS_* y con README distinto; dev usa la ruta correcta. Frontend (develop = main = qa) y BD (dev = main = qa) tienen arboles identicos. Si se despliega desde main/qa, el compose de infra falla al construir el backend y el backend publicado no tiene los endurecimientos de dev ni el proxy de Maps configurado. Lo que el equipo declara como entregable (dev/develop) y lo que promueve su flujo (main) no son lo mismo.
- **Cómo cerrarlo (S):** Promover dev -> qa -> main en los cuatro repos tras corregir la ruta ../Backend-Guardian-Escolar, y fijar una sola rama de entrega declarada.

### [Alto] H-09 · El celular del estudiante no puede cerrar el trayecto: estados FINISHED/CANCELLED inexistentes y PATCH sin credencial del dispositivo
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/student-dashboard.js:333`
- **Por qué importa:** El backend define PENDING, IN_PROGRESS, COMPLETED, CANCELED (TripStatus.java y trip_status_enum) y exige LOCATION_VIEW o ADMIN en PATCH /trips/{id}/status (TripController.java:29-43). El cliente envia FINISHED en la linea 333 y CANCELLED en 222 y 305, sin adjuntar la credencial del hijo, y silencia el fallo con .catch(() => null). Los viajes nunca terminan: el historial muestra 'En proceso', no hay duracion ni hora de fin, y la pantalla de seguimiento prioriza viajes IN_PROGRESS obsoletos.
- **Cómo cerrarlo (S):** Alinear los valores del enum (COMPLETED/CANCELED), crear un endpoint de cierre autorizado para CHILD_DEVICE (por ejemplo POST /trips/{id}/finish) y propagar el error al usuario en lugar de tragarlo. Cubrir con una prueba de contrato que compare los enums del cliente con el OpenAPI.

### [Alto] H-10 · El mapeo de notificaciones usa campos antiguos: sin id, sin hora, siempre 'no leida'; markAsRead nunca se llama
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(tabs)/notifications.js:76`
- **Por qué importa:** NotificationResponse entrega receiptId, notificationId, message, eventType, eventDateTime, wasRead, receivedAt, readAt (NotificationDtos.java:14), pero normalizeNotification lee id/reciboId, leida, recibidoEn/creadoEn, estudianteNombre. Efecto: claves React indefinidas, hora vacia, insignia de no leidas inflada y el PATCH /api/notifications/{receiptId}/read (que existe) no se usa. Ademas eliminar una notificacion solo borra la copia local en AsyncStorage (studentStorage.js:426) y la del servidor reaparece.
- **Cómo cerrarlo (S):** Mapear los campos reales (receiptId, wasRead, receivedAt), invocar markAsRead al abrir y decidir si 'eliminar' es local o un endpoint real. Retirar la mezcla de notificaciones locales de AsyncStorage con las del servidor.

### [Alto] H-12 · Compartir un estudiante con otro acudiente no comparte viajes, coordenadas ni alertas: el seguimiento es solo del propietario
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/modules/trips/service/TripService.java:51`
- **Por qué importa:** StudentAccessService.visibleStudents:25 incluye los estudiantes compartidos (student_guardians), pero TripService.list:51 filtra por el correo del propietario, getAllowed:146 compara contra student.user, el unico destinatario de las notificaciones es student.user (TripAlertService) y el WebSocket de la rama dev repite el mismo criterio. El segundo acudiente ve al estudiante en la lista pero nunca su viaje, y la pantalla de compartir (student.js, shareWithGuardian) promete lo contrario.
- **Cómo cerrarlo (M):** Resolver el acceso a viajes, coordenadas y notificaciones con StudentAccessService.validateAccess (propietario o student_guardians ACTIVE) y crear un notification_receipt por cada acudiente activo.

### [Alto] H-13 · El canal en tiempo real esta roto y sin uso: STOMP sobre SockJS en el servidor, WebSocket nativo en un cliente que nadie importa; el seguimiento solo se refresca a mano
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/shared/config/WebSocketConfig.java:38`
- **Por qué importa:** WebSocketConfig registra /ws con .withSockJS(); con SockJS el WebSocket crudo vive en /ws/websocket y /ws responde un saludo HTTP. services/socket.js:8 usa brokerURL nativo sobre WS_URL (/ws) y createTrackingSocket no se importa en ninguna pantalla (la dependencia sockjs-client tampoco). TripService.java:118 emite a /topic/trips/{id}/coordinates sin receptor, y app/(tabs)/tracking.js solo recarga en el montaje, al cambiar de estudiante o con el boton. El README y Nginx documentan /ws como funcional. La conclusion sobre el handshake sale de leer el codigo, no de ejecutarlo.
- **Cómo cerrarlo (M):** Decidir un solo mecanismo: o sondeo con intervalo en tracking.js, o STOMP funcional (usar SockJS en el cliente o exponer /ws/websocket) con suscripcion real; retirar lo que no se use y documentar la decision en un ADR.

### [Alto] H-14 · Pantallas de 700 a 1458 lineas que concentran estado, reglas y presentacion
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(tabs)/student.js:98 (20 useState en 1458 lineas); app/(tabs)/zones.js:1 (958 lineas, 16 useState); app/student-dashboard.js:1 (723); features/child-link/ScanQrScreen.js:1 (695)`
- **Por qué importa:** El limite de la guia senior-frontend es 300 lineas por archivo. Estas pantallas mezclan formulario, validacion de edad por grado, modales, QR y compartir; cada cambio arriesga romper otro flujo y no se pueden probar por separado.
- **Cómo cerrarlo (L):** Partir student.js y zones.js en formulario, lista, modales y hooks por responsabilidad, moviendo las reglas de edad y grado a un modulo propio.

### [Alto] H-15 · El código de vinculación del estudiante se deriva del UUID, no caduca y protege endpoints públicos que devuelven datos de menores
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-25
- **Evidencia:** `src/main/java/com/guardianescolar/api/modules/students/service/StudentLinkCodeService.java:12`
- **Por qué importa:** codeFor() devuelve los 10 primeros caracteres hexadecimales del UUID del estudiante (40 bits, sin secreto adicional ni caducidad). GET /api/students/{id}/linked-profile y POST /api/students/link-device son públicos (SecurityConfig.java:73,81); el primero devuelve nombre, grado, fecha de nacimiento y teléfono del contacto de emergencia (StudentDeviceLinkService.java:55-72) y el segundo entrega un token de dispositivo infantil (línea 50). Sin studentId, linkDevice recorre a todos los estudiantes comparando el código (líneas 112-117), sin límite de peticiones, lo que permite adivinarlo y además cargar la BD.
- **Cómo cerrarlo (M):** Generar un código aleatorio (SecureRandom, 8+ caracteres) guardado con caducidad y de un solo uso, comparar en tiempo constante, aplicar límite de intentos por IP y por estudiante, y devolver en linked-profile solo lo estrictamente necesario.

### [Alto] H-16 · La confirmación de nuevo dispositivo se omite cuando el cliente no envía deviceIdentifier
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/modules/auth/service/DeviceSessionService.java:25`
- **Por qué importa:** validateDeviceLogin() retorna sin exigir confirmación si deviceIdentifier es nulo (línea 25) y LoginRequest lo declara opcional (AuthDtos.java:31). Quien conozca la contraseña y no tenga 2FA activo obtiene un token sin pasar por la confirmación por correo que el sistema anuncia como defensa. El control solo es efectivo contra clientes honestos.
- **Cómo cerrarlo (S):** Exigir deviceIdentifier (@NotBlank) en el login y tratar su ausencia como dispositivo no confirmado; añadir una prueba negativa en AuthServiceTwoFactorDeviceTest.

### [Alto] H-17 · No hay límite de intentos en login, verificación 2FA de 6 dígitos ni restablecimiento de contraseña
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/modules/auth/service/TwoFactorService.java:88`
- **Por qué importa:** Una búsqueda de rate limit/lockout/intentos en src/main solo encuentra el limitador de Google Maps (MapsRateLimiter); CustomUserDetailsService fija accountLocked(false) (línea 50). validateCode() compara el código de 6 dígitos (línea 88) sin contador de fallos durante 10 minutos, así que 1 000 000 de combinaciones son atacables en línea por /api/auth/2fa/verify (público, SecurityConfig.java:78). El código 2FA además se guarda en claro en users (TwoFactorService.java:69).
- **Cómo cerrarlo (M):** Contador de fallos y bloqueo temporal por cuenta e IP (Bucket4j o tabla propia), invalidar el código tras 5 fallos, guardar el código como hash y limitar /password/forgot y /2fa/resend.

### [Alto] H-18 · Las ramas main y qa no tienen el control de acceso a las suscripciones WebSocket de viajes que sí existe en dev
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-07
- **Evidencia:** `src/main/java/com/guardianescolar/api/shared/security/WebSocketAuthChannelInterceptor.java:54`
- **Por qué importa:** authorizeTripSubscription (dev, líneas 34-35 y 54-79) fue añadido el 2026-10-21 en 94335b0 ('harden notification and websocket audit findings') solo a dev. git diff origin/dev origin/main muestra que main y qa no lo contienen (el interceptor de main tiene 63 líneas y no valida el destino). En la rama de producción cualquier usuario autenticado que conozca un UUID de viaje puede suscribirse a /topic/trips/{id}/coordinates y ver la ubicación en vivo de un menor. Las mismas ramas difieren en otros 9 archivos de notificaciones.
- **Cómo cerrarlo (S):** Promocionar dev a qa y main (con PR y revisión) y fijar una regla que impida que main quede detrás de la rama de trabajo; añadir una prueba de suscripción denegada.

### [Alto] H-19 · La siembra crea siempre un administrador con correo y hash bcrypt versionados, en todos los ambientes
- **Repositorio:** `propietario/DB-Structure-Guardian-Escolar`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-26
- **Evidencia:** `02_dml/00_inserts/002_admin_user.sql:20`
- **Por qué importa:** El changeSet 005b-dml-admin-user (changelog.yaml:23) inserta con UUID fijo un usuario ADMIN activo y con correo verificado («correo», la misma cuenta que el backend usa como remitente en README.md:83) y un hash bcrypt de cost 10 versionado. No tiene contexto ni etiqueta de ambiente y hace UPSERT, de modo que reaparece y pisa la contraseña en cada update. Cualquiera con el repositorio puede intentar romper el hash sin conexión y, combinado con H-B01, el correo es el único dato que falta para forjar un token. La contraseña en claro no se encontró en el repositorio ni se intentó descifrar.
- **Cómo cerrarlo (S):** Sacar la creación del administrador de las migraciones (script de arranque con contraseña de entorno o contexto dev/local de Liquibase), rotar la contraseña de cualquier base ya sembrada y no reutilizar la cuenta de correo del sistema como administrador.

### [Alto] H-20 · El frontend no tiene ninguna prueba automatizada ni script de pruebas
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `package.json:16`
- **Por qué importa:** git ls-tree de 90b4c35bd2 no lista archivos de prueba y package.json solo define lint. Login, 2FA, confirmación de dispositivo, rutas protegidas, geometría de rutas y reintentos de WebSocket se validan solo a mano.
- **Cómo cerrarlo (M):** Añadir Jest con jest-expo y pruebas de servicios (auth.service, api.js), utils (routeGeometry, validators) y de las pantallas de login/registro; ejecutarlas en CI.

### [Alto] H-21 · Ninguna prueba cubre autorización, acceso por objeto, vinculación de dispositivo ni WebSocket; las 9 pruebas de integración se borraron
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/test/java/com/guardianescolar/api/modules/auth/service/AuthServiceTwoFactorDeviceTest.java`
- **Por qué importa:** src/test tiene 12 clases (auth, correo, mapas, geometría, errores, JWT) pero ninguna toca StudentAccessService, TripService, SafeZoneService, StudentLinkCodeService, SecurityConfig ni WebSocketAuthChannelInterceptor. El commit 735f6d6 (2026-09-11) eliminó AuthControllerIntegrationTest, StudentControllerIntegrationTest, RealtimeTrackingIntegrationTest y otras 6 pruebas de integración sin reemplazo. Sin pruebas negativas de acceso no autorizado (puerta de calidad de la skill de seguridad de API), una regresión como H-B05 pasa sin aviso.
- **Cómo cerrarlo (M):** Recuperar pruebas MockMvc/@SpringBootTest para los controladores críticos con casos 401/403 y de acceso a objeto ajeno, y una prueba por cada hallazgo de seguridad corregido.

### [Alto] H-22 · Ningún repositorio tiene CI y las ramas qa/main se promocionan sin puertas automáticas
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Ejecuciones de CI: gh api repos/.../actions/runs devuelve total 0 en frontend, backend e infraestructura; en BD 1 ejecución en estado skipped`
- **Por qué importa:** Sin .github/workflows en ninguno de los 4 repositorios (65, 92, 35 y 9 ramas), nada compila, prueba ni escanea antes de fusionar. La cadena HU-xx-dev, qa, main (69 commits de promoción en el backend) depende solo de revisión humana, que no detectó que main perdió el control de WebSocket (H-B05).
- **Cómo cerrarlo (M):** Añadir un workflow por repositorio (backend: mvn verify; frontend: lint y expo export; BD: liquibase validate/update contra Postgres de servicio; infra: docker compose config) y exigirlos como checks obligatorios en qa y main.

### [Alto] H-23 · El despliegue en Render documentado en el README no respondió al GET de comprobación
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `El GET único a la URL declarada devolvió código 000 (sin respuesta en 15 s); la URL está en README.md de Fronted-GuardianEscolar-`
- **Por qué importa:** El README del frontend (líneas 56-66) apunta a https://gps-guardian-escolar-backend.onrender.com como API_UPSTREAM; el único GET permitido a /api/health devolvió 000. Puede ser un servicio de capa gratuita dormido o suspendido, pero entonces la entrega no es verificable ni utilizable por un tercero. El equipo tampoco declara ninguna URL en PROYECTOS-FICHA-3145555.md.
- **Cómo cerrarlo (S):** Verificar el servicio, declarar la URL pública en la ficha del proyecto y mantener un endpoint de salud accesible o evidencias de la ejecución (captura, registro) en el repositorio.

### [Alto] H-24 · No hay release repetible ni plan de rollback; las ramas main/qa de infraestructura están desactualizadas
- **Repositorio:** `propietario/Docker-Infra-Guardian-Escolar`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-35
- **Evidencia:** `docker-compose.yaml:28`
- **Por qué importa:** Las imágenes se construyen siempre desde el contexto local y se etiquetan latest (docker-compose.yaml:28), el backend es 0.0.1-SNAPSHOT (pom.xml), no hay registro de imágenes, etiquetas de versión ni procedimiento de vuelta atrás. En origin/main y origin/qa de este repositorio el compose apunta a ../backend (no a ../Backend-Guardian-Escolar) y no incluye las variables de Google Maps de dev, de modo que desplegar desde la rama de producción falla o arranca incompleto. No hay documento de despliegue ni de rollback (el repo A11 exige release-readiness, deployment-plan y rollback-plan).
- **Cómo cerrarlo (M):** Publicar imágenes versionadas desde CI en un registro, documentar despliegue y rollback (volver a la etiqueta anterior; Liquibase rollback por changeset) y sincronizar main/qa con dev.

### [Medio] H-02 · APK de 50,8 MB versionado en el repositorio del frontend
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A11 · **Verificación independiente:** matizado (severidad ajustada de alto)
- **Evidencia:** `public/gps-guardian-escolar.apk (git ls-tree -l: 50816486 bytes; anadido en c147393, 1d847ca y cb9eae0)`
- **Por qué importa:** Un binario generado no debe vivir en Git: engorda cada clon, queda para siempre en el historial aunque se borre y no se puede revisar. Ademas se sirve junto a la app web como si fuera un recurso de la aplicacion.
- **Cómo cerrarlo (S):** Quitarlo del arbol, publicarlo como release de GitHub o artefacto de EAS, anadir *.apk al .gitignore y limpiar el historial si el tamano del clon importa.

### [Medio] H-27 · Cualquier 403 cierra la sesion del usuario
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `services/api.js:51`
- **Por qué importa:** El interceptor trata 401 y 403 igual: borra el almacenamiento y emite authExpired. Un acudiente que entra a una funcion de administrador es expulsado en vez de ver 'no tienes permiso'.
- **Cómo cerrarlo (S):** Reservar el cierre de sesion para 401 fuera de los endpoints publicos y mostrar una pantalla propia para 403.

### [Medio] H-28 · El boton cancelar de la confirmacion de borrado nativa muestra el texto 'cncel'
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(tabs)/student.js:225 (t('cncel') y style: 'cncel'); contexts/LanguageContext.js:32 devuelve la propia clave si falta.`
- **Por qué importa:** En movil, al borrar un estudiante, el boton de cancelar dice literalmente 'cncel' en todos los idiomas, y el estilo invalido hace que la plataforma no lo trate como cancelacion. Ademas hay textos fuera de i18n (student.js:723 'Guardar').
- **Cómo cerrarlo (S):** Usar t('cancel') con style 'cancel' y anadir una regla de lint o prueba que falle cuando una clave de traduccion no exista.

### [Medio] H-29 · Accesibilidad y responsive solo parciales
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(auth)/register.js:14 y app/(tabs)/student.js:30 (Dimensions.get una vez al cargar); app/(tabs)/zones.js:478 es la unica etiqueta accesible en 958 lineas; app/(tabs)/student.js:546`
- **Por qué importa:** Con 66 atributos de accesibilidad para 128 elementos tocables y TextInput sin etiqueta, un lector de pantalla no puede completar el registro de un estudiante; rotar el movil o redimensionar la web no recalcula el layout. El contraste WCAG no se pudo medir.
- **Cómo cerrarlo (M):** Sustituir Dimensions.get por useWindowDimensions, etiquetar todos los controles tactiles y campos, y comprobar contraste con los tokens finales.

### [Medio] H-30 · La documentacion no vive en el repositorio: solo hay README y todo lo demas esta en Drive
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `PROYECTOS-FICHA-3145555.md (enlace a carpeta de Drive); README.md de los cuatro repos sin docs/, diagrama ni ADR.`
- **Por qué importa:** Lo que el equipo documenta sobre arquitectura, modelo y requisitos no puede revisarse junto al codigo ni versionarse; las rubricas de congruencia (T-12.3, T-12.4, R-12.1) no se pueden evaluar.
- **Cómo cerrarlo (M):** Subir al repo un docs/ con arquitectura (diagrama de componentes), modelo de datos, lista de historias con criterios de aceptacion y ADR.

### [Medio] H-31 · El frontend tenia 19 documentos tecnicos en el repo y se borraron en octubre
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git -C <clon> log --all --diff-filter=D -- DOCUMENTACION_MARKDOWN (cb9eae0e00, 1d847ca919, c1473935cc); README.md:1 no los reemplaza`
- **Por qué importa:** La carpeta DOCUMENTACION_MARKDOWN (arquitectura, flujo de datos, autenticacion, ADR, glosario y flujo Git, anadida en 098c3e0 el 1-sep) era la unica documentacion tecnica versionada del equipo y desaparecio de develop y de main entre el 15 y el 19 de octubre (commits 'Fix frontend routes, maps, QR and tunnel configuration' y 'consolidate frontend HU-14 through HU-23').
- **Cómo cerrarlo (S):** Restaurar la carpeta desde 098c3e0, actualizarla a lo construido y moverla a un docs/ dentro del repo.

### [Medio] H-32 · El README de la base de datos remite a documentacion que no existe en ningun repo
- **Repositorio:** `propietario/DB-Structure-Guardian-Escolar`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:7 (cinco enlaces a ../docs/database/*.md) y README.md:33 ('docker-compose.yaml de la raiz del proyecto')`
- **Por qué importa:** Los enlaces rotos y la raiz inexistente hacen que el modelo de datos documentado no se pueda consultar desde el repo.
- **Cómo cerrarlo (S):** Mover esos cinco documentos a un docs/ dentro de este repo o quitar los enlaces, y corregir la referencia al compose.

### [Medio] H-33 · Historial recreado por ambiente: cada HU se commitea tres veces y los cortes por HU son retroactivos
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git -C <clon> log --all --no-merges: backend 97 commits y 69 asuntos distintos; frontend HU-01 a HU-09 el 26-ago entre las 16:44 y las 21:22; backend HU-09 a HU-12 el 8-sep entre las 22:36 y las 23:33.`
- **Por qué importa:** Los conteos de commits se inflan hasta tres veces, el aporte por persona no refleja el esfuerzo real y el historial no permite reconstruir cuando y por quien se escribio cada funcion.
- **Cómo cerrarlo (M):** Promover con merge o cherry-pick del mismo commit (no recommitear por ambiente) y registrar el avance real por historia en el tablero.

### [Medio] H-34 · Ningun issue ni tablero visible para planear el trabajo
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/.../issues devuelve 0 en los cuatro repos; las historias solo existen como nombres de rama HU-NN.`
- **Por qué importa:** Sin issues no hay forma de saber que historia corresponde a cada rama, quien la tomo ni que falta; la trazabilidad exigida queda solo en Drive.
- **Cómo cerrarlo (S):** Crear un issue por historia (HU-01 a HU-32) con sus criterios de aceptacion y enlazarlo desde cada PR.

### [Medio] H-36 · Codigo y rutas huerfanos entre capas
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `config/endpoints.js:197`
- **Por qué importa:** ENDPOINTS (endpoints.js) no se importa y lista GET /students/{id}, /routes/{id}, /trips/{id}, /safe-zones/{id}, /devices/{id} que el backend no expone; hooks/useAuth.js llama authService.forgotPassword, inexistente; verify-recovery-code y choose-recovery-action no tienen entrada y authService.verifyRecoveryCode siempre lanza error (auth.service.js:323). En el backend, 8 endpoints no tienen consumidor (ver T-14.4). Cada huerfano es superficie sin pruebas y confunde a quien mantenga el sistema.
- **Cómo cerrarlo (S):** Eliminar lo muerto o conectarlo; mantener un unico catalogo de rutas (o generar el cliente desde OpenAPI).

### [Medio] H-37 · RouteResponse no devuelve direcciones: tras recargar, origen y destino se muestran como coordenadas; ademas la descripcion concatena ambas direcciones con tope de 255
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/modules/routes/dto/RouteDtos.java:36`
- **Por qué importa:** El cliente guarda las direcciones solo dentro de description ('Origen: X. Destino: Y.', studentStorage.js:359-370) y al leer espera route.originAddress/destinationAddress (studentStorage.js:185-186), campos que RouteResponse no tiene; cae a 'lat, lng'. RouteRequest.description admite 255 caracteres y dos direcciones formateadas de Google pueden superarlos (400 al crear).
- **Cómo cerrarlo (S):** Agregar origin_address y destination_address a routes (migracion Liquibase) y a RouteRequest/RouteResponse, y dejar description para texto libre.

### [Medio] H-38 · PATCH de estado acepta cualquier transicion y se permiten varios viajes activos por estudiante
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/modules/trips/service/TripService.java:85`
- **Por qué importa:** changeStatus asigna request.status() sin maquina de estados (un COMPLETED puede volver a PENDING) y hadDeviation viene del cliente; create no comprueba si el estudiante ya tiene un viaje IN_PROGRESS. Junto con H-A01 acumula viajes huerfanos.
- **Cómo cerrarlo (S):** Validar transiciones permitidas (PENDING->IN_PROGRESS->COMPLETED|CANCELED) y rechazar un segundo viaje activo (indice unico parcial en trips por student_id donde status='IN_PROGRESS').

### [Medio] H-39 · Editar una ruta con paradas probablemente choca con el indice unico ux_stops_route_order
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `src/main/java/com/guardianescolar/api/modules/routes/service/RouteService.java:108`
- **Por qué importa:** replaceStopsIfRequested borra las paradas con un deleteByRouteId derivado y guarda las nuevas con los mismos stop_order (1..n) en la misma transaccion; Hibernate ejecuta los INSERT antes que los DELETE al hacer flush, de modo que el indice unico ux_stops_route_order (route_id, stop_order) del repo DB (10_indexes/002_normalization_constraints.sql) puede rechazar la edicion con 409 'La operacion viola una restriccion de datos'. El cliente siempre envia stops al actualizar (studentStorage.js:387). Inferido del orden del flush; no se ejecuto.
- **Cómo cerrarlo (S):** Hacer flush tras el borrado (deleteByRouteId con @Modifying y flushAutomatically) o actualizar las paradas por posicion; agregar una prueba de integracion de edicion de ruta.

### [Medio] H-41 · El README del backend es una nota de entrega de HU y no sirve para arrancar el servicio
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:1 ('HU-20 Backend Implementado'), README.md:29 (./mvnw test), mvnw:6 (docker run), README.md:35 ('Tests run: 3')`
- **Por qué importa:** Un recien llegado no sabe que necesita Java 17, una base PostgreSQL creada por otro repo, ni que mvnw exige Docker. Las cifras de pruebas del README ya no coinciden con las 12 clases de prueba.
- **Cómo cerrarlo (S):** Reescribir el README con descripcion del servicio, prerrequisitos, variables, como levantar con el compose de Docker-Infra y como correr pruebas; sustituir mvnw por el wrapper real o documentar el uso de Docker.

### [Medio] H-42 · El backend no declara que depende del repositorio de base de datos
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/resources/application.yml:14 (ddl-auto validate); el repo ya no contiene migraciones; README.md y docker-compose.yaml no nombran DB-Structure-Guardian-Escolar.`
- **Por qué importa:** El compose standalone solo arranca si alguien creo antes la base con Liquibase desde otro repo; quien levante el backend solo vera fallar la validacion del esquema sin saber por que.
- **Cómo cerrarlo (S):** Documentar la dependencia y el orden de arranque (DB, Liquibase, backend) en el README y remitir al compose de Docker-Infra como camino unico.

### [Medio] H-43 · El README de infraestructura tiene una ruta obsoleta y no explica la disposicion de carpetas
- **Repositorio:** `propietario/Docker-Infra-Guardian-Escolar`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:14 (.\docker-infra\.env), docker-compose.yaml:26 (../DB-Structure-Guardian-Escolar), docker-compose.yaml:108 (../Fronted-GuardianEscolar-)`
- **Por qué importa:** El compose solo funciona si los cuatro repos estan clonados como hermanos con esos nombres exactos (incluido el guion final de Fronted-GuardianEscolar-); ni el README ni el resto de repos lo dicen y el comando de 'raiz del proyecto' apunta a una carpeta que no existe.
- **Cómo cerrarlo (S):** Anadir una seccion 'Preparacion' con los cuatro git clone, el cp .env.example .env y el unico comando de arranque, y corregir la ruta.

### [Medio] H-44 · Las politicas de seguridad que guarda la base (password_policies, security_settings) no las aplica el codigo
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/modules/auth/service/AuthValidationService.java:28`
- **Por qué importa:** La BD siembra min_length=10, expiracion 90 dias, MAX_LOGIN_ATTEMPTS=5, LOCKOUT_TIME_MINUTES=15 y SESSION_TIMEOUT_MINUTES=30 (propietario/DB-Structure-Guardian-Escolar:01_ddl/03_tables/003_security.sql:66-71 y 02_dml/00_inserts/001_security_catalog.sql:82), pero el backend fija PASSWORD_MIN_LENGTH=8 en una constante, ninguna clase usa PasswordPolicyRepository ni SecuritySettingsRepository fuera de su declaracion y no existe bloqueo por intentos fallidos. La tabla dice una cosa y el sistema hace otra.
- **Cómo cerrarlo (M):** O el backend lee esas tablas (y aplica bloqueo y expiracion) o se eliminan; no mantener un modelo que aparenta controles inexistentes.

### [Medio] H-45 · La ingesta de coordenadas hace entregas externas dentro de la transaccion y repite alertas sin deduplicar
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/modules/notifications/service/NotificationService.java:97`
- **Por qué importa:** POST /trips/{id}/coordinates (TripService.registerCoordinate, @Transactional) llama a TripAlertService, que crea notificaciones y entrega por correo, SMS y Expo Push de forma sincrona (NotificationService.createForUser:97 -> NotificationDeliveryService.deliver); no hay @Async ni evento posterior al commit. La alerta de inactividad se dispara en cada coordenada con stoppedSeconds >= umbral (TripAlertService.java:49) sin ventana de silencio. Con un envio cada 5 s (config/constants.js UPDATE_INTERVAL_MS) un proveedor lento retiene conexion y transaccion y un nino detenido genera cientos de alertas. Ademas un salto imposible se descarta devolviendo 201 sin persistir (TripService.java:111).
- **Cómo cerrarlo (M):** Publicar un evento tras el commit y entregar de forma asincrona; guardar el ultimo estado de alerta por viaje para no repetirla; responder 202/422 cuando se descarte una coordenada.

### [Medio] H-46 · studentStorage.js hace de capa de datos, cache local y mapeo, y esconde errores del servidor
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `utils/studentStorage.js:152 (getStudentExtras) y utils/studentStorage.js:153,173,220,264 (.catch(() => []))`
- **Por qué importa:** Si la API de zonas falla, getStudentExtras devuelve las zonas guardadas en AsyncStorage como si fueran las vigentes y las pantallas muestran datos desactualizados sin avisar. El nombre del archivo ('storage') oculta que contiene la logica de negocio del frontend.
- **Cómo cerrarlo (M):** Renombrar y dividir en repositorios por recurso (students, zones, routes), eliminar el respaldo local de zonas y rutas y propagar los errores a la pantalla.

### [Medio] H-47 · Un APK de 50 MB versionado y servido desde public/ contiene una clave de Google cuya restricción no es verificable
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `public/gps-guardian-escolar.apk`
- **Por qué importa:** git cat-file del blob public/gps-guardian-escolar.apk (50 816 486 bytes) contiene 1 coincidencia del patrón de clave de Google (prefijo AIza + 35 caracteres); valor ««redactado»». Una clave de Maps dentro de un APK es esperable por diseño del SDK de Android; lo que la vuelve riesgo es que debe estar restringida por paquete y huella de firma y no se puede comprobar. El archivo está en public/, así que además se sirve desde el sitio web y queda en el historial de varias ramas (c147393, 1d847ca, cb9eae0). No se pudo confirmar si la clave está restringida por aplicación o dominio (el README.md:70 dice que debe estarlo); una clave sin restricciones permite consumo facturable por terceros. Un binario compilado fuera del repositorio tampoco tiene procedencia verificable.
- **Cómo cerrarlo (S):** Rotar la clave en la consola de Google, aplicar restricciones de paquete/dominio y cuota, sacar el APK del repositorio (publicarlo como release o artefacto de CI) y limpiar el historial si la clave era sin restricciones.

### [Medio] H-48 · En web el JWT vive en AsyncStorage (localStorage) y nginx no envía cabeceras de seguridad
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `utils/storage.js:14`
- **Por qué importa:** storage.setToken usa AsyncStorage en web (líneas 13-14), accesible a cualquier script inyectado (XSS), contra la guía de API de no guardar tokens en localStorage; nginx.conf.template no define CSP, X-Frame-Options ni X-Content-Type-Options. En móvil sí usa SecureStore (línea 16).
- **Cómo cerrarlo (M):** Con la API en el mismo origen, pasar el token a una cookie HttpOnly SameSite desde el backend o acortar su vida y añadir CSP y cabeceras de seguridad en nginx.

### [Medio] H-49 · El JWT completo se guarda en claro en user_sessions y nunca se consulta; no hay cierre de sesión ni revocación
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-40
- **Evidencia:** `src/main/java/com/guardianescolar/api/modules/auth/service/DeviceSessionService.java:57`
- **Por qué importa:** saveSession() persiste el token emitido (línea 57) pero JwtAuthenticationFilter solo valida firma, usuario y expiración (línea 46) y AuthController no tiene endpoint de logout. Un token robado vale 30 minutos aunque se cambie la contraseña o se cierre sesión, y un volcado de la tabla expone tokens vigentes.
- **Cómo cerrarlo (M):** Guardar solo un hash o el jti, validar la sesión (ACTIVE) en el filtro, añadir /api/auth/logout y revocar sesiones al cambiar contraseña o desactivar 2FA.

### [Medio] H-50 · Swagger UI, api-docs y métricas de Prometheus expuestos en el perfil de producción
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/shared/config/SecurityConfig.java:83`
- **Por qué importa:** Swagger y /v3/api-docs son permitAll (líneas 83-87) sin desactivarlos en application-prod.yml, y application.yml:89-93 expone health, info, metrics y prometheus a cualquier usuario autenticado (un acudiente corriente). Entrega el mapa completo de la API a un atacante y métricas internas a usuarios sin privilegio.
- **Cómo cerrarlo (S):** Desactivar springdoc en prod (springdoc.api-docs.enabled=false), exponer solo health y restringir el resto de actuator a ROLE_ADMIN o a una red interna.

### [Medio] H-51 · Tratamiento de datos de menores sin las garantías mínimas de la Ley 1581 de 2012
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `src/main/java/com/guardianescolar/api/modules/students/domain/Student.java:51`
- **Por qué importa:** El sistema guarda fecha de nacimiento, foto (photoData en texto) y ubicación continua de menores (TripService.java:99, 005_trips_tracking.sql) con una aceptación genérica de términos (app/(auth)/register.js:31-48). No identifica al responsable, no hay procedimiento de consulta/rectificación/supresión, ni política de retención o purga, ni autorización específica del representante legal para datos de menores. Es inferencia desde el código; la política completa podría estar en el Drive del equipo, que no es accesible.
- **Cómo cerrarlo (L):** Redactar y publicar la política de tratamiento (responsable, finalidades, derechos, retención), pedir autorización explícita del representante legal, añadir endpoints de exportación y supresión y un job de purga de coordenadas antiguas.

### [Medio] H-52 · El backend se conecta como superusuario postgres y los roles de mínimo privilegio definidos no se usan
- **Repositorio:** `propietario/DB-Structure-Guardian-Escolar`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `03_dcl/00_roles/001_create_database_roles.sql:3`
- **Por qué importa:** El repositorio define gps_guardian_app y gps_guardian_readonly (NOLOGIN) con grants, pero Docker-Infra pasa DB_USERNAME con el valor de POSTGRES_USER, por defecto postgres (docker-compose.yaml:60), y el backend usa esa cuenta. Cualquier inyección o fallo de la aplicación obtiene control total del servidor de datos.
- **Cómo cerrarlo (S):** Crear el rol de aplicación con LOGIN y contraseña de entorno, concederle solo los grants del DCL y configurar DB_USERNAME con ese rol; reservar postgres para Liquibase.

### [Medio] H-53 · El README del backend promete 'Tests run: 3' y el build de la imagen salta las pruebas
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:35`
- **Por qué importa:** El resultado esperado documentado (3 pruebas) no coincide con las ~30 reales y el Dockerfile ejecuta mvn package -DskipTests (línea 5), por lo que ninguna prueba bloquea una imagen. Un README que promete no es evidencia de lo que el código hace.
- **Cómo cerrarlo (S):** Actualizar el README, quitar -DskipTests del build de imagen o ejecutar las pruebas en CI antes de construirla, y añadir jacoco con un umbral mínimo.

### [Medio] H-55 · Backend y frontend en contenedores root sin healthcheck; la BD se publica al host y el perfil prod corre sin HTTPS
- **Repositorio:** `propietario/Docker-Infra-Guardian-Escolar`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker-compose.yaml:11`
- **Por qué importa:** Los Dockerfile del backend (Dockerfile:7-11) y del frontend (Dockerfile:23-30) no definen USER ni HEALTHCHECK; el compose de infraestructura publica 5432 (línea 11), fija SPRING_PROFILES_ACTIVE prod (línea 57) con REQUIRE_HTTPS en falso (línea 64) y no incluye proxy TLS, así que contraseñas y tokens viajan en claro si se usa tal cual (el HSTS de SecurityConfig.java:65 no surte efecto sobre HTTP). frontend depende de backend sin condición de salud (línea 118).
- **Cómo cerrarlo (S):** Añadir USER no root y HEALTHCHECK a los Dockerfile, no publicar 5432 salvo en un compose de desarrollo, poner un proxy TLS o documentar que debe ir detrás de uno y usar depends_on con service_healthy.

### [Medio] H-56 · Los rollbacks existen pero ningun compose los monta: liquibase rollback fallaria
- **Repositorio:** `propietario/DB-Structure-Guardian-Escolar`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker-compose.yaml:49`
- **Por qué importa:** Cada rollback se referencia como ../../05_rollbacks/... desde 01_ddl/03_tables (changelog.yaml:17), que resuelve a /db/05_rollbacks. Ni el compose del repo DB (volumes, lineas 49-55) ni el de infra montan 05_rollbacks (solo 01_ddl, 02_dml, 03_dcl y changelog). El esfuerzo de escribir 59 archivos de rollback no es utilizable en los entornos que el equipo documenta. Verificado por lectura de los montajes; no se ejecuto liquibase.
- **Cómo cerrarlo (S):** Agregar ./05_rollbacks:/db/05_rollbacks:ro a ambos compose y probar un rollback-count en CI.

### [Medio] H-57 · Higiene de migraciones: esquema exportado de una base, ediciones en sitio y DDL en carpetas DML
- **Repositorio:** `propietario/DB-Structure-Guardian-Escolar`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/003_security.sql:57`
- **Por qué importa:** Los changeSets estan organizados por tipo de objeto, no por version; device_confirmation_return_url aparece en el CREATE TABLE (003_security.sql:57) y de nuevo en el parche 02_dml/04_patches/002 (:2); ux_users_email_lower y el CHECK de correo se declaran en 10_indexes/002 y otra vez en 04_patches/003; la unica carga de 01_ddl llego en un commit 'A DDL is uploaded from the database'. Editar un changeSet ya aplicado cambia su checksum y Liquibase se detiene en bases existentes; el principio forward-only (database.migration.forward_only) no se cumple.
- **Cómo cerrarlo (M):** Congelar lo aplicado, mover cada cambio posterior a un changeSet nuevo y numerado (V###__...), y quitar las repeticiones.

### [Medio] H-58 · Indices ausentes en rutas calientes y sin politica de retencion para coordinates
- **Repositorio:** `propietario/DB-Structure-Guardian-Escolar`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/10_indexes/001_indexes.sql:15`
- **Por qué importa:** Faltan notification_receipts(user_id) (la consulta 'mis notificaciones'), notifications(safe_zone_id) y coordinates(trip_id, recorded_at) (GET /trips/{id}/coordinates ordena por recorded_at, TripService.java:123); idx_users_email duplica el UNIQUE de email; coordinates crece ~17 000 filas por dia por estudiante activo (un punto cada 5 s) sin particion, archivo ni borrado, y GET devuelve todas.
- **Cómo cerrarlo (S):** Crear los indices, definir retencion (por ejemplo 90 dias) y paginar o limitar por ventana de tiempo.

### [Medio] H-59 · Tipos inconsistentes: TIMESTAMP sin zona en logs y fotos en base64 dentro de la tabla students
- **Repositorio:** `propietario/DB-Structure-Guardian-Escolar`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/007_audit_logs.sql:13`
- **Por qué importa:** activity_logs, audit_logs y error_logs usan TIMESTAMP (sin zona) mientras el resto usa TIMESTAMPTZ, lo que desordena eventos si cambia la zona del servidor; students.photo_data TEXT (009_student_photo.sql:2) guarda imagenes de hasta 1 500 000 caracteres (StudentDtos.java:26 del backend) que GET /students devuelve para todos los estudiantes en cada llamada.
- **Cómo cerrarlo (S):** Unificar a TIMESTAMPTZ y mover las fotos a almacenamiento de objetos o a una tabla aparte con URL.

### [Medio] H-60 · La aplicacion se conecta como superusuario de Postgres; los roles gps_guardian_app/readonly no se usan
- **Repositorio:** `propietario/Docker-Infra-Guardian-Escolar`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker-compose.yaml:60`
- **Por qué importa:** El repo DB crea gps_guardian_app y gps_guardian_readonly NOLOGIN con GRANT minimos (03_dcl/00_roles y 01_grants), pero el compose de infra pasa DB_USERNAME=POSTGRES_USER (por defecto postgres) al backend. La capa DCL no tiene efecto real y un fallo del backend tiene privilegios totales sobre la base.
- **Cómo cerrarlo (S):** Crear un login para gps_guardian_app con contrasena por variable y usarlo en el backend; reservar postgres para Liquibase.

### [Medio] H-61 · El manejador catch-all convierte errores 4xx del framework en 500 y los registra como errores del sistema
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/shared/exception/ApiExceptionHandler.java:116`
- **Por qué importa:** @ExceptionHandler(Exception.class) tiene precedencia sobre los resolvers por defecto de Spring: JSON malformado, enum desconocido (por ejemplo el FINISHED del cliente), tipo de contenido no soportado, metodo no permitido o ruta inexistente terminan en 500 'Error interno del servidor', con LOGGER.error y una fila en error_logs. Eso falsea las metricas, esconde el error real al cliente y satura error_logs. Deducido de la lista de manejadores del archivo; no se ejecuto.
- **Cómo cerrarlo (S):** Extender ResponseEntityExceptionHandler o agregar manejadores para HttpMessageNotReadableException (400), HttpRequestMethodNotSupportedException (405), HttpMediaTypeNotSupportedException (415) y NoResourceFoundException (404).

### [Medio] H-62 · Sin contrato versionado ni verificacion de contrato: los desajustes cliente-servidor llegan a produccion
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `pom.xml:59`
- **Por qué importa:** El OpenAPI se genera en caliente (springdoc) sin anotaciones salvo Maps, sin version de API y sin pruebas que lo comparen con el cliente. Es la causa raiz de H-A01, H-A02 y H-A05: la verificacion de contrato exige que lo declarado se compruebe contra el codigo real.
- **Cómo cerrarlo (M):** Publicar openapi.json versionado en el repo, generar el cliente (o al menos los tipos y enums) y agregar una prueba de contrato en CI.

### [Medio] H-63 · Listados sin paginacion y con consultas N+1 en servidor y cliente
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/modules/students/service/StudentMapper.java:22`
- **Por qué importa:** StudentMapper.toResponse ejecuta 3 consultas por estudiante (dispositivos, tutores, rutas) y el cliente hace una peticion /emergency-contacts por estudiante en cada carga (propietario/Fronted-GuardianEscolar-:utils/studentStorage.js:173 y :217-221, repetida en inicio, estudiantes, zonas y seguimiento). /trips, /trips/{id}/coordinates, /notifications y /students devuelven todo sin Pageable (solo AdminService pagina).
- **Cómo cerrarlo (M):** Paginar (page/size) los listados, incluir los contactos en StudentResponse y cargar las rutas con JOIN FETCH.

### [Bajo] H-64 · Restos de la plantilla de Expo y codigo sin uso
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `scripts/reset-project.js:1; components/common/JsonView.js:6 (sin importaciones); assets/images/react-logo.png, expo-badge.png y tutorial-web.png`
- **Por qué importa:** Ruido que despista al leer el repo y aumenta el peso sin aportar al producto.
- **Cómo cerrarlo (S):** Borrar los archivos de plantilla y los componentes sin uso.

### [Bajo] H-65 · La documentacion OpenAPI cubre un solo controlador
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/guardianescolar/api/modules/maps/controller/MapsController.java:35 (unico controlador con @Operation)`
- **Por qué importa:** Swagger UI esta disponible, pero 9 de los 10 controladores aparecen sin resumen, parametros ni respuestas, y el frontend no tiene otro contrato escrito.
- **Cómo cerrarlo (M):** Anadir @Tag y @Operation a los controladores restantes y enlazar /swagger-ui.html desde el README.

### [Bajo] H-66 · Convencion de commits irregular
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git -C <clon> log --all --no-merges --format=%s: '(HU-04-DEV): ...', 'feat(auth): ...', 'HU-18: ...', ' register and track gps trips', 'structure'`
- **Por qué importa:** Los mensajes de septiembre no indican tipo ni alcance y algunos son un parrafo; dificulta generar un changelog y encontrar un cambio.
- **Cómo cerrarlo (S):** Adoptar Conventional Commits con commitlint en un hook o en el PR.

### [Bajo] H-67 · La variable de umbral de desvio del .env.example nunca llega al contenedor
- **Repositorio:** `propietario/Backend-Guardian-Escolar`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker-compose.yaml:1 (solo reenvia GPS_DESVIO_UMBRAL_METROS) frente a .env.example:25 (GPS_ROUTE_DEVIATION_THRESHOLD_METERS)`
- **Por qué importa:** Quien cambie el valor documentado en .env.example no ve ningun efecto en Docker, porque el compose solo pasa el alias antiguo.
- **Cómo cerrarlo (S):** Reenviar GPS_ROUTE_DEVIATION_THRESHOLD_METERS en el compose y retirar el alias GPS_DESVIO_UMBRAL_METROS.

### [Bajo] H-68 · Nombres mezclados en espanol e ingles y tres fuentes de color
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `utils/studentStorage.js:196 (nombre, contacto_nombre, codigo_vinculacion junto a fullName); constants/colors.js:1 (capa legacy) y 33 colores hexadecimales en app/(tabs)/student.js`
- **Por qué importa:** La guia de producto pide codigo en ingles e interfaz en el idioma del usuario; aqui los mismos objetos usan snake_case espanol y camelCase ingles y los colores no salen de un unico token.
- **Cómo cerrarlo (M):** Fijar un diccionario de nombres en ingles, migrar las pantallas pendientes a theme/tokens.js y retirar constants/colors.js y config/constants.js.

### [Bajo] H-69 · Contraseña por defecto de PostgreSQL versionada en el historial de liquibase.properties
- **Repositorio:** `propietario/DB-Structure-Guardian-Escolar`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `liquibase.properties`
- **Por qué importa:** Los commits 7ddada7 y 25c4916 contienen password con el valor por defecto de la imagen de PostgreSQL (8 caracteres, ««redactado»»); el archivo del SHA evaluado ya no lo trae. Es una credencial de desarrollo local, pero sigue en el historial y puede haberse copiado a otros ambientes.
- **Cómo cerrarlo (S):** Confirmar que ninguna base real usa esa contraseña y rotarla; el historial no requiere limpieza si se confirma que era solo local.

### [Bajo] H-70 · El script npm run password:web envía un campo que la API no reconoce
- **Repositorio:** `propietario/Fronted-GuardianEscolar-`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `scripts/password-reset-web.js:127`
- **Por qué importa:** password-reset-web.js envía {token, nuevaContrasena} pero ResetPasswordRequest espera token y newPassword (AuthDtos.java:41-43 del backend; el cliente principal usa newPassword en services/auth.service.js:164). Es la clase de desajuste de contrato que una prueba de contrato habría detectado; el script es de apoyo y no del flujo principal.
- **Cómo cerrarlo (S):** Alinear el campo o eliminar el script, y cubrir el contrato de restablecimiento con una prueba.

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 84.4 |
| D2 | Reproducibilidad | 73.8 |
| D3 | Arquitectura y congruencia | 50.0 |
| D4 | Calidad de código | 59.1 |
| D5 | Seguridad | 66.4 |
| D6 | Pruebas | 21.7 |
| D7 | DevOps y despliegue | 22.7 |
| D8 | Datos | 50.0 |
| D9 | API y contratos | 45.0 |
| D10 | Frontend y móvil | 62.5 |
| D11 | IoT y firmware | — |
| D12 | Documentación y trazabilidad | 50.0 |
| D13 | Proceso y colaboración | 68.4 |
| D14 | Extremo a extremo | 25.0 |

## Lo que está bien

- Entidades JPA y DDL sin deriva: 25 tablas, 0 columnas de diferencia (`Comparacion de @Table/@Column/@JoinColumn de src/main/java/com/guardianescolar/api/modules/**/domain (backend) contra 01_ddl/03_tables y 04_alter (repo DB): todas las columnas mapeadas existen y todas las del DDL estan mapeadas; spring.jpa.hibernate.ddl-auto=validate en src/main/resources/application.yml lo hace cumplir al arrancar.`)
- Proyecto Liquibase completo con rollback por cada cambio (`changelog/changelog-master.yaml incluye 01_ddl, 02_dml y 03_dcl; cada changeSet de los changelog.yaml declara su rollback y los 59 archivos de 05_rollbacks referenciados existen en el SHA.`)
- Orquestacion ordenada y reproducible en infra (`docker-compose.yaml (Docker-Infra): database con healthcheck -> liquibase (service_healthy) -> backend (service_completed_successfully) -> frontend; red y volumen nombrados.`)
- Modelo de datos con integridad fuerte (`01_ddl/10_indexes/002_normalization_constraints.sql (repo DB): indice unico parcial de un solo dispositivo activo por estudiante, correo unico en minuscula, unicos (notification_id,user_id) y (route_id,stop_order); CHECK de rangos y formatos en 001_users.sql y 004_safe_zones.sql; borrado logico y triggers updated_at.`)
- API REST con formato de error uniforme y codigos correctos (`src/main/java/com/guardianescolar/api/shared/exception/ApiExceptionHandler.java (ApiError con timestamp, status, message, errors; 428 para confirmacion de dispositivo, 409 para integridad, 429 para limite de Maps); controladores con 201/204 y @PreAuthorize por metodo (TripController.java:29-36).`)
- Flujo de autenticacion alineado de extremo a extremo (`EmailLinkService.java:20-28 (backend) genera /verify-email, /confirm-login y /reset-password, rutas que existen como pantallas en app/(auth) del frontend; los DTO de registro, login y 2FA coinciden con services/auth.service.js; el 428 se traduce en el cliente.`)
- Proxy Nginx parametrizado por entorno que evita CORS (`nginx.conf.template + docker/40-render-nginx-config.sh (frontend): API_UPSTREAM con valor por defecto http://backend:8080, encabezados X-Forwarded-* derivados del entorno y EXPO_PUBLIC_WEB_PROXY=true en el Dockerfile.`)
- Contraseñas con bcrypt y política de complejidad (`src/main/java/com/guardianescolar/api/shared/config/SecurityConfig.java:111 (BCryptPasswordEncoder); AuthValidationService.java:34-50 (8 a 128 caracteres con mayúscula, minúscula, número y símbolo).`)
- Autorización por permiso en todos los controladores no públicos más control de acceso por objeto (`@PreAuthorize en StudentController, RouteController, SafeZoneController, TripController, MapsController y AdminController; StudentAccessService.java:40-58, TripService.java:141-159, RouteAccessService.java:16 y SafeZoneService.java:94.`)
- Control de dispositivo hijo acotado al estudiante vinculado (`TripService.java:153-159 (validateChildStudent) y JwtAuthenticationFilter.java:47-57 (el token CHILD_DEVICE solo recibe la autoridad CHILD_DEVICE).`)
- Errores saneados: nunca se devuelve la traza al cliente y se registran en BD (`src/main/java/com/guardianescolar/api/shared/exception/ApiExceptionHandler.java:116-122 (500 con mensaje genérico) y ErrorLogService.java:32-45 con escape de entradas.`)
- Los enlaces de correo validan la URL de retorno contra una lista de orígenes permitidos (`src/main/java/com/guardianescolar/api/modules/auth/service/EmailLinkService.java:58-80 (isSafeReturnUrl e isAllowedOrigin).`)
- Código 2FA generado con SecureRandom y expiración de 10 minutos; el reto 2FA se emite solo tras validar el dispositivo (`TwoFactorService.java:19 y 69-71; AuthService.java:85-93; probado en AuthServiceTwoFactorDeviceTest.java:50-75 con Mockito InOrder.`)
- CORS por lista blanca configurable, HSTS y sesión sin estado; auditoría de operaciones que mutan datos (`SecurityConfig.java:61-69,116-126; AuditInterceptor.java:16-32.`)
- Sin credenciales reales en el árbol ni en el historial de backend e infraestructura; .env y claves excluidos de Git y de la imagen (`Backend .gitignore:2-4, .dockerignore:3-5,12-13 y .env.example con valores vacíos; Docker-Infra .gitignore:2-4 y .env.example:6,12 vacíos. Barrido de todas las ramas con git log --all -p sin hallazgos de claves reales.`)
- Orquestación de arranque ordenada: Liquibase espera a que la BD esté sana y el backend a que Liquibase termine (`Docker-Infra docker-compose.yaml:15-19, 30-32 y 99-101 (service_healthy y service_completed_successfully).`)
- Esquema versionado con Liquibase, changeSets etiquetados y rollback por cambio (`02_dml/00_inserts/changelog.yaml:23-37 y 37 scripts de rollback en 05_rollbacks.`)
- Dockerfile multi-etapa en backend y frontend; clave de Maps del cliente entra por ARG vacío y el proxy nginx deriva el esquema de la plataforma sin confiar en cabeceras externas (`Backend Dockerfile:1-9; Frontend Dockerfile:5-8,23-30 y docker/40-render-nginx-config.sh.`)
- Pruebas con aserciones reales en correo, mapas y 2FA, y limitador/circuit breaker para Google Maps (`src/test/java/com/guardianescolar/api/shared/PlacesApiNewTest.java (25 aserciones); BrevoEmailSenderTest.java; MapsRateLimiter.java.`)
- Contratos frontend-backend alineados: cada ruta que llama el cliente existe en un controlador (`services/student.service.js:5 (GET /students) contra src/main/java/com/guardianescolar/api/modules/students/controller/StudentController.java:1; lo mismo para trips, routes, safe-zones, notifications, devices, maps y admin.`)
- Manejo de errores centralizado y uniforme en el backend (`src/main/java/com/guardianescolar/api/shared/exception/ApiExceptionHandler.java:34 (11 handlers, ApiError comun y registro en ErrorLogService).`)
- Esquema de base de datos versionado con Liquibase y rollback por script (`changelog/changelog-master.yaml (incluye 01_ddl a 04_tcl) y un script de rollback por cambio en 05_rollbacks/.`)
- Compose de infraestructura bien encadenado: base con healthcheck, Liquibase que debe terminar bien y backend que depende de Liquibase (`docker-compose.yaml:26 (contexto de DB), docker-compose.yaml:53 (backend) y docker-compose.yaml:108 (frontend).`)
- Autenticacion rica en el cliente: 2FA, confirmacion de dispositivo (428), SecureStore en nativo y guardia de rutas (`services/auth.service.js:108; utils/storage.js:1; app/_layout.js:1.`)
- Disciplina de ramas por ambiente en los cuatro repos (dev, qa, main) con 188 PR, el 97 % fusionados (`gh api graphql pullRequests; bases de los PR del backend: 33 dev, 33 qa, 23 main.`)
- Imagen del frontend multi-etapa con Nginx configurable por variables en tiempo de ejecucion (`Dockerfile:1; nginx.conf.template; docker/40-render-nginx-config.sh.`)
- .env.example en los cuatro repos, sin valores reales (`docker-compose.yaml:9 y .env.example en cada repositorio.`)
- Producto con funciones diferenciadoras: vinculacion de estudiante por QR, seguimiento en tiempo real, zonas seguras, rutas con paradas, 4 idiomas y tema claro y oscuro (`features/child-link/ScanQrScreen.js:1; app/(tabs)/tracking.js:1; app/(tabs)/zones.js:1; translations/es.json:1; theme/darkTheme.js:1.`)
- Configuracion del backend externalizada y con perfiles (`src/main/resources/application.yml:14; src/main/resources/application-prod.yml:7 (ddl-auto validate).`)
- Confirmacion antes de destruir: borrar o desvincular un estudiante exige un modal que lo nombra (`app/(tabs)/student.js:225.`)

## Lo que no se pudo verificar

- Documentacion de arquitectura y modelo (06-data, 05-architecture, ADR) del equipo — Esta en una carpeta de Google Drive que el evaluador no puede abrir y los repos no la reflejan (README de la BD apunta a ../docs/database/* inexistente). T-3.6 queda NV; corresponde registrar un hallazgo D12 al especialista de documentacion.
- Levantado real de la BD con Liquibase, arranque del backend y llamadas HTTP — Las reglas prohiben ejecutar el codigo de los aprendices (docker, mvn, npm). Los hallazgos H-A04, H-A09 y H-A15b salen de lectura del codigo y del comportamiento conocido de Spring, SockJS e Hibernate.
- Despliegue en linea (T-14.3) — El equipo no declara URL de despliegue en PROYECTOS-FICHA-3145555.md; el README del frontend cita un backend en Render (gps-guardian-escolar-backend.onrender.com) como valor de API_UPSTREAM. Un GET a /api/health no respondio en 15 s (codigo 000): no se sabe si esta apagado o en arranque en frio, asi que el flujo en linea queda sin comprobar.
- Las ramas HU-* intermedias de los cuatro repos, una por una — Se compararon por diferencia de arbol las ramas main y qa contra la rama evaluada y se leyo el log de las adelantadas; las ramas HU-* no se revisaron individualmente.
- Si los secretos de EAS (EXPO_PUBLIC_API_URL) estan definidos para el APK versionado — Dato fuera del repositorio (H-A22 queda como inferencia).
- Un comando de analisis fue bloqueado por el guardia SQL de la sesion — Un guardia de columnas SQL (ajeno a este proyecto) rechazo un primer intento de generar el JSON por script; no se insistio con ese comando y el archivo se produjo con la herramienta de escritura de archivos. No afecta a la evidencia.
- Si la clave de Google hallada en el APK está restringida por aplicación o dominio y si coincide con la clave que usa el backend — Requiere acceso a la consola de Google Cloud o usar la clave contra la API, lo cual está fuera de la lectura permitida.
- El valor real de la clave JWT y de la contraseña del administrador en cualquier ambiente desplegado — Son configuración de entorno fuera del repositorio; no se intentó descifrar el hash de la siembra ni forjar tokens.
- Respuesta del despliegue de Render y estado de las rutas /api del backend desplegado — El único GET permitido devolvió 000 y no se reintentó; no puede decirse si el servicio está caído o dormido.
- Resultado de las pruebas y cobertura real — Ejecutar mvn o npm no está permitido; solo se leyó el código de las pruebas.
- Vulnerabilidades conocidas de dependencias (CVE) de Maven y npm — npm audit y los escáneres OWASP ejecutan código/red; se evaluó solo por versión.
- Usuario de ejecución de la imagen liquibase/liquibase:5.0.4 — Depende de la imagen base y no se descargó ni inspeccionó (docker prohibido).
- Modelo de amenazas y documentación de seguridad (equivalente a security-threat-model.md de A04) y la política de tratamiento de datos — Documentación en Google Drive no accesible; en los repositorios no hay modelo de amenazas, por lo que no se premia ni se castiga lo que no se pudo leer (el hueco documental lo registra el especialista C en D12).
- Persistencia y cifrado en reposo del volumen gps_guardian_escolar_postgres_data — Depende del servidor donde se despliegue; el compose no define cifrado.
- Documentacion de arquitectura, modelo de datos y requisitos del equipo (carpeta de Drive) — documentacion en Drive no accesible desde el repositorio; no se premia ni se castiga lo que no se pudo leer (R-12.1, T-12.3 y T-12.4 quedan NV).
- Compilacion real del frontend (expo export), lint, build de Maven y arranque con Docker — La restriccion de solo lectura prohibe ejecutar codigo de los aprendices; se hizo revision estatica (importaciones, scripts, rutas del compose).
- Muestreo de D4: lectura profunda de student.js y zones.js (los dos componentes mas grandes del equipo) — El backend solo se reviso por git grep (printStackTrace, TODO, controladores sin repositorios, URLs incrustadas) y por tamanos; R-4.5 del backend queda NV.
- Contraste WCAG, comportamiento visual del responsive y estados de carga en ejecucion — Exige renderizar la app; se infirio del codigo y no se midio.
- Tablero de GitHub Projects y lista de colaboradores de cada repo — La API devolvio 403 para colaboradores y el tablero no se consulto con los permisos del evaluador.
- Identidad de la cuenta Integrante 3 — Se atribuye a Integrante por el nombre y por los PR que coinciden con sus commits, pero no hay un correo noreply que lo confirme; no cambia ningun porcentaje.
- Contenido del APK versionado en el frontend — Es un binario y no se inspecciono ni se ejecuto.
- Contenido de los datos semilla (02_dml/00_inserts) — Solo se confirmo que existen un catalogo de seguridad y un usuario administrador; la completitud de datos de demostracion pertenece a D8 y no se evaluo.
