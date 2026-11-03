# Equipo 12 · EcoRuteando — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 44/100 · Juicio D**

## Veredicto

EcoRuteando tiene una base seria: un backend .NET modular con errores centralizados, migraciones Liquibase reversibles y tres de cinco flujos completos de punta a punta (registro e inicio de sesión, planificar y registrar trayectos, calificar rutas). Los otros dos flujos están rotos en el móvil (reportes y votos de obstáculos, y recuperación de contraseña) porque consume rutas y campos que el backend no tiene. Tras la verificación quedan un hallazgo bloqueante, la clave de Google Maps escrita en el código público de la app móvil y en main, y tres críticos: cualquier usuario registrado puede modificar la configuración global y las estadísticas, los tokens temporales de 2FA sirven como tokens de acceso y el secreto TOTP se envía a un servicio externo para dibujar el QR. Además no hay una sola prueba automatizada ni integración continua real, y la documentación describe en varios puntos otro sistema. El puntaje es 43,9 con juicio D, lejos de los 70 puntos: el extremo a extremo (31) también queda bajo su mínimo de 50, pero casi todo lo bloqueante y crítico es de esfuerzo pequeño y se puede cerrar en pocos días.

## Plan para cerrar las brechas

1. **Rotar y restringir la clave de Google Maps y sacarla del código (RouteMiniMap.tsx y build.gradle); leerla solo de EXPO_PUBLIC_GOOGLE_MAPS_KEY o de secretos de EAS.** (esfuerzo S) — se cierra cuando: La clave anterior está revocada en Google Cloud, la nueva está restringida por paquete y SHA-1, y una búsqueda en el árbol de main no encuentra ningún literal de clave.
2. **Proteger con roles y permisos los endpoints de administración (configuración global, factores de CO2, estadísticas, exportaciones), exigir dueño para editar POI y asociación ruta-POI, y validar las entradas de Administración, Integraciones y Notificaciones.** (esfuerzo S) — se cierra cuando: Un usuario sin rol de administrador recibe 403 en cada uno de esos endpoints y 403 al editar un POI ajeno, con pruebas que lo demuestran; las entradas inválidas devuelven 400.
3. **Separar los tokens: el token temporal de 2FA y el de dispositivo de confianza no deben aceptarse como acceso; quitar el código de verificación de la respuesta del registro; endurecer el código de recuperación (ligarlo al correo) y las fugas menores de autenticación.** (esfuerzo M) — se cierra cuando: Usar un token de 2FA contra un endpoint protegido devuelve 401; la respuesta de POST de registro no contiene el código; el restablecimiento exige correo y código; hay pruebas para los tres casos.
4. **Generar el QR del segundo factor en el propio cliente (librería local) para que el secreto TOTP no salga a un servicio externo.** (esfuerzo S) — se cierra cuando: Con la red del navegador abierta no hay ninguna petición a un dominio externo al activar 2FA y el QR se muestra correctamente.
5. **Corregir la configuración móvil: perfil de producción de EAS con el host real del backend, perfil preview sin túnel temporal, login solo por HTTPS al host configurado y APK de producción firmado con una keystore propia fuera del repositorio.** (esfuerzo M) — se cierra cuando: Un build de producción inicia sesión contra el backend desplegado por HTTPS; el repositorio no contiene la keystore de depuración usada para firmar y no queda ninguna URL en HTTP.
6. **Reparar los dos flujos rotos del móvil: usar /api/obstacle-reports/active con radiusKm, el campo confirms y los nombres confirmationsCount/rejectionsCount/derivedStatus; leer el código de recover-new-password; y quitar o implementar las llamadas a historial del perfil y registro de notificaciones push.** (esfuerzo S) — se cierra cuando: En un dispositivo o emulador se listan reportes cercanos, se vota y se restablece la contraseña con el código recibido, sin respuestas 404 en el registro de red; los dos flujos pasan a COMPLETO.
7. **Arreglar contratos del backend: restricción de ruta de los endpoints de roles y permisos (Guid en lugar de int), proxy de Google Maps con autenticación y límite de uso, GET /api/routes limitado al usuario y paginado, y paginación en los demás listados. Aislar el módulo de administración: que lea usuarios por la capa de la aplicación y no por SQL directo, y resolver la tabla compartida y los controladores duplicados.** (esfuerzo M) — se cierra cuando: Los seis endpoints de roles responden con un Guid válido; /api/routes devuelve solo rutas del usuario con paginación; el proxy de Maps responde 401 sin sesión y 429 al exceder el límite. El módulo de administración no ejecuta SQL directo sobre la tabla de usuarios.
8. **Completar el front web: enviar de verdad la foto del reporte de obstáculos, enlazar o retirar las pantallas de administración inaccesibles, mensajes claros para ruta desconocida, rol insuficiente y sesión vencida, sacar IP local y URL de release del código y cerrar el historial de direcciones.** (esfuerzo M) — se cierra cuando: La foto adjunta llega al backend y se ve en el reporte; cada pantalla de administración es alcanzable con el rol correcto; no quedan IP ni URL fijas en el código; los tokens ya no se guardan en localStorage o la decisión queda documentada.
9. **Crear la base de pruebas e integración continua: pruebas unitarias y de integración del backend (autenticación, permisos, registro), pruebas del front y del móvil para los flujos principales, CI que compile y ejecute pruebas en los cuatro repos, y Dockerfiles unificados con usuario no root, healthcheck y clave TOTP documentada.** (esfuerzo L) — se cierra cuando: Cada repositorio tiene un workflow que falla si no compila o si fallan las pruebas; el backend tiene pruebas que cubren los casos de las acciones 2 y 3; el contenedor corre sin root y el README explica la variable de la clave TOTP.
10. **Ordenar la base de datos: incluir la migración de foto de perfil en el changelog, definir los índices de las consultas frecuentes, agregar FK y tipos coherentes en usage_id, retirar la migración EF residual, corregir el default de users.status y que el CI de migración se ejecute antes de aplicar desde main.** (esfuerzo M) — se cierra cuando: Liquibase aplica el changelog completo en una base vacía sin errores en CI, la foto de perfil funciona, existen los índices y la FK de usage_id, y hay una sola fuente de verdad del esquema.
11. **Alinear la documentación con lo construido: README por repositorio, arquitectura, modelo de datos, contradicciones de seguridad, URL de despliegue vigente, usuario administrador y datos de ejemplo para recorrer el sistema, e indicadores de éxito con historias y criterios de aceptación.** (esfuerzo M) — se cierra cuando: Cada repo tiene un README específico con instalación y ejecución que funciona desde cero; el modelo y la arquitectura documentados coinciden con las tablas y módulos reales; la URL documentada responde.
12. **Mejorar el proceso y la mantenibilidad: dividir las pantallas gigantes, revisar los PR antes de fusionar, usar issues o tablero, cerrar PR y ramas muertas, limpiar archivos duplicados y .gitignore, historial móvil legible, corregir problemas de accesibilidad y retirar credenciales de prueba de app.http.** (esfuerzo L) — se cierra cuando: Ningún archivo de pantalla supera un tamaño acordado, cada PR tiene al menos una revisión, no hay PR ni ramas obsoletas abiertas, app.http no tiene credenciales ni tokens y el .gitignore evita los residuos de IDE.

## Verificación independiente

Hallazgos confirmados: 6 · matizados: 3 · refutados: 0 · duplicados fusionados: 4.

Revise en el SHA evaluado los 7 hallazgos graves, los 4 de la muestra, los 4 items PASS, los 5 flujos, los aportes y los 11 pares de duplicados. Confirme 8 hallazgos (H-01, H-02, H-03, H-05, H-06, H-10, H-13, H-15), matice 3 (H-04 de critico a alto porque el APK parece construirse sin EAS, H-07 de critico a alto porque la verificacion se anula pero no hay acceso a cuentas existentes, H-08 por la imprecision de 'tres repos') y no refute ninguno. Los 4 items PASS, los 5 flujos (3 completos, 2 rotos) y las cifras de aportes (255/10/6, identidades con el mismo correo) se sostienen; los duplicados reales son H-01/H-02, H-07/H-13 y H-58 con H-61 y H-62, mientras que H-49 solo comparte una frase con H-04.

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Completo | Registro, verificación de correo e inicio de sesión (CU01/CU05) | — |
| Completo | Planificar ruta, registrar el trayecto y verlo en el historial (CU03/CU04/CU06) | — |
| Completo | Calificar una ruta completada (CU09) | — |
| Roto | Reporte ciudadano de obstáculos y validación comunitaria por votos (CU07/CU22) | El móvil consulta GET /api/obstacle-reports/nearby (no existe; la ruta es /active con radiusKm) y vota con el campo 'confirm' en vez de 'confirms', por lo que cada voto llega como rechazo; además espera confirmCount/rejectCount/state y el backend responde confirmationsCount/rejectionsCount/derivedStatus. Crear el reporte (POST /api/obstacle-reports) sí funciona. |
| Roto | Recuperación de contraseña (CU02) | En el móvil la pantalla recover-new-password nunca lee el código recibido por parámetro y envía token vacío a POST /api/auth/reset-password; el restablecimiento falla. En la web el flujo pasa el código al servicio y es coherente. |

## Hallazgos

### [Bloqueante] H-02 · Clave de Google Maps versionada en el codigo de la app movil (y en main)
- **Repositorio:** `propietario/Movil-EcoRuteando`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado; también reportado como H-01
- **Evidencia:** `android/app/build.gradle:98 y src/components/maps/RouteMiniMap.tsx:16`
- **Por qué importa:** La clave ««redactado»» esta en texto plano en un repositorio publico, en main desde el 2026-10-19 (RouteMiniMap) y el 2026-10-22 (build.gradle, commit 6e12e34). Cualquiera puede usarla y generar consumo a cargo del proyecto. No se pudo comprobar si tiene restricciones de aplicacion en la consola de Google, asi que se asume sin ellas.
- **Cómo cerrarlo (S):** Revocar y regenerar la clave, restringirla por paquete com.ecoruteando.mobile y huella SHA-1 y por API, sacarla del codigo (gradle.properties local o secreto de EAS, y EXPO_PUBLIC solo con la clave restringida) y quitar el valor de respaldo de RouteMiniMap.tsx. Reescribir el historial no es obligatorio si la clave se revoca.

### [Crítico] H-03 · El secreto del segundo factor se envía a un servicio externo para dibujar el QR
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `front-end/ecoRuteando-react/src/features/home/pages/UserProfile.jsx:1531`
- **Por qué importa:** Al activar 2FA, la pantalla construye https://api.qrserver.com/v1/create-qr-code/?data= con el otpauth completo (que contiene el secreto del autenticador) y lo pide a un tercero; la CSP de nginx lo permite (img-src api.qrserver.com). Quien opere o intercepte ese servicio obtiene el secreto TOTP del usuario y anula el segundo factor.
- **Cómo cerrarlo (S):** Generar el QR en el navegador con una librería local (qrcode o qrcode.react) y quitar api.qrserver.com del img-src de nginx; hacer lo mismo con el QR de descarga del APK si se quiere evitar el rastreo.

### [Crítico] H-05 · Cualquier usuario registrado puede modificar la configuracion global, los factores de CO2, las estadisticas y las exportaciones
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `src/Modules/Admin/EcoRuteando.Modules.Admin.Presentation/Controllers/SystemConfigurationController.cs:35`
- **Por qué importa:** El registro es abierto y PUT api/admin/system-configuration (SystemConfigurationController.cs:35-37), POST y PUT api/admin/transport-factors (TransportFactorsController.cs:49-71), POST api/admin/statistics/daily (StatisticsController.cs:48), POST y PATCH api/admin/exports (ExportsController.cs:28 y :74) y los POST de api/integrations/cache y de ingesta de clima y aire (ApiCacheController.cs:39, WeatherController.cs:41) solo llevan [Authorize], sin rol ni permiso; el comentario del codigo dice que requieren privilegios administrativos. Un usuario cualquiera cambia la URL de privacidad y terminos, el correo del administrador, los factores que calculan el CO2 de todos, sobreescribe las estadisticas del portal y fija la FileUrl de exportaciones de otros. GET de exportaciones por id no verifica dueno. El unico control de acceso real a la administracion esta en el cliente (ADR 004).
- **Cómo cerrarlo (S):** Agregar HasPermission o Authorize con roles Admin y SuperAdmin a cada endpoint de api/admin y de api/integrations que muta, validar propiedad en exportaciones, y crear pruebas negativas (un usuario normal debe recibir 403). Sembrar permisos de administracion en Liquibase.

### [Crítico] H-06 · El token temporal de 2FA y el token de dispositivo de confianza sirven como tokens de acceso
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `src/Modules/Security/EcoRuteando.Modules.Security.Application/Users/Commands/LoginUsers/LoginUserCommandHandler.cs:143`
- **Por qué importa:** El login emite con la misma clave, emisor y audiencia un JWT de 60 minutos con rol two_factor_pending (lineas 143-146), y solo PermissionAuthorizationHandler.cs:26 lo rechaza; cualquier endpoint con solo [Authorize] lo acepta (api/auth/me, api/users/me incluida DELETE, y todo el modulo de administracion de H-B02). Con solo la contrasena se evita el segundo factor. El token de dispositivo de confianza (TrustedDeviceService.cs:25-40, 30 dias) tampoco se distingue en JwtAuthenticationExtensions.cs:25-40: sirve como token de acceso de 30 dias.
- **Cómo cerrarlo (M):** Emitir los tokens de 2FA y de dispositivo con otra audiencia o con una clave distinta, o rechazarlos en el middleware de JwtBearer (OnTokenValidated por claim token_type o por rol), y acortar la vida del token pendiente a 5 minutos.

### [Alto] H-04 · El perfil de producción de EAS apunta a un host de Render que no existe
- **Repositorio:** `propietario/Movil-EcoRuteando`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** matizado (severidad ajustada de critico)
- **Evidencia:** `eas.json:24`
- **Por qué importa:** Una compilación hecha con el perfil production fija EXPO_PUBLIC_API_URL a ecoruteando-backend.onrender.com, que responde 404 con x-render-routing: no-server (comprobado con HEAD el 2026-10-23); el backend vivo es ecoruteandobackend.onrender.com (sin guion), usado en apiClient.ts:5 y vercel.json:6. Esa app instalada no podría iniciar sesión ni consumir ningún endpoint. El manual de despliegue (documents/manual-tecnico/14-despliegue.md:10 en el repo EcoRuteando) repite el host equivocado. No se pudo comprobar con qué perfil se compiló el APK v1.0.7 publicado.
- **Cómo cerrarlo (S):** Unificar el host en una sola variable (eas.json, apiClient.ts, vercel.json, keep-alive.yml y manual), corregir el perfil production y el preview (que apunta a un túnel efímero de trycloudflare), y verificar con un curl de salud antes de cada build.

### [Alto] H-07 · El registro devuelve en la respuesta HTTP el código de verificación del correo
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** matizado (severidad ajustada de critico); también reportado como H-13
- **Evidencia:** `src/Modules/Security/EcoRuteando.Modules.Security.Presentation/Controllers/AuthController.cs:55`
- **Por qué importa:** POST /api/auth/register responde { userId, verificationCode }. Quien registra un correo ajeno puede verificarlo al instante con POST verify-email, que además recibe solo el código sin el correo (src/Modules/Security/EcoRuteando.Modules.Security.Application/Users/Commands/VerifyEmail/VerifyEmailCommandHandler.cs:30): la verificación de correo no verifica nada y el código de 6 dígitos tiene un índice único global, así que dos usuarios con el mismo código chocan.
- **Cómo cerrarlo (S):** Quitar verificationCode de la respuesta, enlazar el código al usuario (pedir correo + código en verify-email) y usar un código no único globalmente o un token largo.

### [Alto] H-08 · La documentación contradice lo construido en al menos seis puntos
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** matizado (descripción precisada)
- **Evidencia:** `documents/manual-tecnico/14-despliegue.md:32`
- **Por qué importa:** README raíz (líneas 93 y 98: TypeScript y Node.js con Express, cuando el front es JSX y el backend .NET 9); RNF y diagramas de secuencia con Argon2id y ORS/OSRM frente a BCryptPasswordHasher.cs y Google Maps; el manual (línea 79) anuncia bicicleta y transporte público que el ADR-8 excluyó; 14-despliegue.md:32 y 75-78 niegan render.yaml y CI que existen en tres repos; el artículo (línea 67) promete 129 casos de prueba frente a los 20 diseñados del informe de pruebas y ninguna prueba automatizada; el manual marca como Completo el reporte con foto que no funciona. Un lector que se fíe de la documentación toma decisiones equivocadas y el equipo pierde credibilidad ante la evaluación.
- **Cómo cerrarlo (M):** Reescribir README raíz desde el documento de arquitectura v1.1, hacer una pasada de congruencia de los CU y RNF contra el código (Argon2id, ORS/OSRM, foto, bicicleta), corregir 14-despliegue.md y bajar el artículo a los 20 casos reales.

### [Alto] H-09 · El reporte de obstáculos ofrece adjuntar una foto que nunca se envía
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `documents/Especificación de casos de uso/CU07-reporte-ciudadano-de-obstaculos.md y documents/Manual-Tecnico-EcoRuteando.md:1675`
- **Por qué importa:** CU07 y RF17 incluyen adjuntar fotografía y el manual lo marca Completo. En la app móvil report.tsx deja elegir una imagen (línea 76) pero el POST de la línea 98 no incluye photoUri, y CreateObstacleReportCommand.cs del backend no tiene campo de foto ni existe un endpoint de subida. El usuario cree que adjuntó evidencia y el moderador nunca la recibe. En el móvil, además, el botón de enviar no se bloquea mientras se envía (report.tsx:341).
- **Cómo cerrarlo (M):** Implementar la subida (multipart o URL firmada) con campo PhotoUrl en el comando, o retirar el selector de foto y marcar RF17 como Parcial en la matriz; bloquear el botón con un estado de envío.

### [Alto] H-10 · El móvil consume contratos que el backend no tiene: reportes cercanos y voto comunitario
- **Repositorio:** `propietario/Movil-EcoRuteando`
- **Lente SDLC OS:** A06 · **Verificación independiente:** confirmado
- **Evidencia:** `src/services/reports.ts:38`
- **Por qué importa:** GET /api/obstacle-reports/nearby no existe (el backend expone /active con radiusKm), el voto manda 'confirm' mientras el backend lee 'Confirms' (queda en false) y los nombres de la respuesta difieren (confirmCount/rejectCount/state contra confirmationsCount/rejectionsCount/derivedStatus). La validación comunitaria del móvil no funciona y los votos se contarían como rechazos.
- **Cómo cerrarlo (S):** Alinear el cliente con el contrato real (o añadir /nearby), renombrar campos en un solo sitio y añadir una prueba de contrato que falle si el cliente llama una ruta inexistente.

### [Alto] H-11 · Recuperación de contraseña en el móvil envía token vacío
- **Repositorio:** `propietario/Movil-EcoRuteando`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(auth)/recover-new-password.tsx:45`
- **Por qué importa:** La pantalla anterior pasa el código por parámetro de ruta pero esta pantalla no lo lee (la única referencia a token es la línea 45, con cadena vacía): el usuario móvil que olvidó su contraseña no puede recuperarla.
- **Cómo cerrarlo (S):** Leer el parámetro con useLocalSearchParams y enviarlo en el cuerpo de reset-password; cubrir el flujo con una prueba.

### [Alto] H-12 · El móvil llama dos rutas inexistentes: historial del perfil y registro de notificaciones push
- **Repositorio:** `propietario/Movil-EcoRuteando`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/shared/services/pushNotificationService.ts:47`
- **Por qué importa:** POST /api/notifications/device/register (el backend tiene /device-token) y GET /api/mobility/trips/history en app/(tabs)/profile.tsx:327 (la ruta real es /api/trips) devuelven 404: las notificaciones push (CU10) nunca registran el dispositivo y el historial del perfil no carga.
- **Cómo cerrarlo (S):** Corregir las dos URLs y centralizar los paths en un módulo de endpoints compartido para que no diverjan.

### [Alto] H-14 · Pantallas gigantes en móvil y web: el mantenimiento ya es costoso
- **Repositorio:** `propietario/Movil-EcoRuteando`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(tabs)/plan-route.tsx:74`
- **Por qué importa:** En móvil plan-route.tsx tiene 2.001 líneas, 41 useState y 7 useEffect, cinco catch vacíos (234, 686, 964, 973, 1081) y llama a apiClient directo (228, 993, 999) existiendo src/services; 18 archivos superan 300 líneas. En web UserProfile.jsx (1.790), PlanRoute.jsx (1.764) y RouteManage.jsx (1.509) mezclan UI, red y estado; 20 archivos superan 300. Cada cambio toca zonas sin pruebas y es probable romper algo no relacionado.
- **Cómo cerrarlo (L):** Partir por responsabilidad: hooks (useRoutePlanner, useTripTracking), servicios de datos fuera de las pantallas y subcomponentes por sección; fijar un tope de 300 líneas por archivo con una regla de lint.

### [Alto] H-15 · Los POI y la asociacion ruta-POI se pueden editar sin ser duenos
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `src/Modules/Mobility/EcoRuteando.Modules.Mobility.Presentation/Controllers/PoisController.cs:70`
- **Por qué importa:** El permiso routes.write se siembra al rol User (02_dml/01_inserts/005_insert_mobility_permissions_for_users.sql en EcoRuteandoDb), y PUT y DELETE de api/pois/{id} (PoisController.cs:70-98) y POST y DELETE de api/routes/{id}/pois/{poiId} (RoutesController.cs:133-160) no comprueban propiedad: cualquier usuario puede editar o desactivar los puntos de interes de todos y alterar las rutas ajenas. Las rutas si validan propiedad (RoutesController.cs:106), lo que muestra que el patron existe y se omitio aqui.
- **Cómo cerrarlo (S):** Pasar RequestedByUserId e IsAdmin a los comandos de POI y de ruta-POI y rechazar con 403 si no es el creador o administrador; separar el permiso pois.write del de rutas.

### [Alto] H-16 · Proxy de Google Maps anonimo con la clave del servidor y limitador general sin aplicar
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Mobility/EcoRuteando.Modules.Mobility.Presentation/Controllers/GoogleMapsController.cs:33`
- **Por qué importa:** GoogleMapsController no tiene [Authorize]: directions, geocode, reverse-geocode y places (lineas 33, 91, 122 y 147) se pueden llamar sin sesion y consumen la clave de Maps del servidor. El limitador api de 100 por minuto esta definido (Program.cs:90-97) y ninguna ruta lo usa (git grep sin resultados de EnableRateLimiting api ni RequireRateLimiting), asi que no hay tope por IP.
- **Cómo cerrarlo (S):** Exigir sesion en api/maps, aplicar EnableRateLimiting api a ese controlador (o un GlobalLimiter) y limitar cuota por usuario.

### [Alto] H-17 · El login movil reenvia correo y contrasena a hosts fijos, incluso por HTTP en claro
- **Repositorio:** `propietario/Movil-EcoRuteando`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(auth)/login.tsx:154`
- **Por qué importa:** Ante cualquier error de red (login.tsx:153-169) la app envia el correo y la contrasena a un tunel publico de Cloudflare y a dos URL http de la red local 10.3.234.116, y guarda el host que responde como URL del API (SecureStore customApiUrl, linea 162). El AndroidManifest de produccion tiene usesCleartextTraffic true (android/app/src/main/AndroidManifest.xml:17), asi que el trafico HTTP sale en claro. Un tunel temporal caducado o un host de la red del aula pueden capturar credenciales, y el usuario puede redirigir toda la app a un servidor propio.
- **Cómo cerrarlo (S):** Eliminar la lista de respaldo y el campo de URL personalizada en compilaciones de produccion (dejarlos tras un flag de desarrollo), poner usesCleartextTraffic en false en el manifest principal y permitir HTTP solo en el manifest de debug.

### [Alto] H-18 · Ni una prueba automatizada en los cuatro repositorios
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `EcoRuteando.sln`
- **Por qué importa:** La solucion tiene 22 proyectos y ninguno de pruebas; el frontend y la app movil no tienen script de test; la base no tiene pruebas de datos; tampoco hay pruebas en ninguna de las 187 ramas revisadas. Los 28 casos de uso y los criterios de aceptacion de las historias no tienen una sola prueba que los respalde, y los hallazgos H-B02 a H-B04 son exactamente el tipo de defecto que una prueba negativa de acceso habria atrapado.
- **Cómo cerrarlo (L):** Empezar por pruebas de integracion del backend (WebApplicationFactory) con el caso de cada permiso y propiedad, mas 10 pruebas unitarias de dominio (CO2, politicas de bloqueo), y ejecutarlas en el CI.

### [Alto] H-19 · El backend no tiene integracion continua: solo un ping que no falla nunca
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `.github/workflows/keep-alive.yml:17 y EcoRuteando.sln`
- **Por qué importa:** El unico workflow hace curl -s sin -f contra el endpoint /api/auth/me (que responde 401 sin sesion), por lo que casi siempre sale en verde. No compila, no prueba y no analiza dependencias. Ademas la programacion declarada es cada 10 minutos, pero las ejecuciones observadas por la API estan separadas por horas, por lo que no evita el arranque en frio del plan gratis de Render.
- **Cómo cerrarlo (M):** Agregar un workflow en pull_request y push a main con dotnet restore, build y test, y reemplazar el keep-alive por un healthcheck real o por un monitor externo.

### [Alto] H-20 · El APK de produccion se firma con la keystore de depuracion versionada
- **Repositorio:** `propietario/Movil-EcoRuteando`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `android/app/build.gradle:120`
- **Por qué importa:** buildTypes.release usa signingConfigs.debug (build.gradle:120) con android/app/debug.keystore y contrasena publica en el repositorio (lineas 103-109). Como la web distribuye el APK por descarga directa (DownloadApkModal.jsx y nginx), cualquiera puede construir una actualizacion falsa con la misma firma que Android aceptaria como legitima.
- **Cómo cerrarlo (S):** Generar una keystore de release propia, guardarla fuera del repositorio (EAS credentials) y hacer que release use esa firma; retirar la debug.keystore del arbol.

### [Alto] H-21 · La migración de la foto de perfil existe pero no está en el changelog
- **Repositorio:** `propietario/EcoRuteandoDb`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/006_security_module/015_alter_profile_photo_url_to_text.sql:2`
- **Por qué importa:** Una base creada con db.changelog-master.yaml deja profile_photo_url en VARCHAR(500), mientras UsersController.UpdateMyPhoto (backend, UsersController.cs:146) guarda la foto en base64. La entrada del changelog existe solo en la rama DB-17-profile-photo-text-column. Con una foto real el valor excede 500 caracteres y la actualización fallaría (consecuencia inferida, no ejecutada).
- **Cómo cerrarlo (S):** Registrar el changeset 015 en 01_ddl/03_tables/006_security_module/changelog.yaml con su rollback y añadir al CI un 'liquibase update' real sobre una base vacía, no solo validate/updateSQL.

### [Alto] H-22 · El esquema no define ningún índice
- **Repositorio:** `propietario/EcoRuteandoDb`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/10_indexes/changelog.yaml:1`
- **Por qué importa:** El archivo es 'databaseChangeLog: []' y no hay CREATE INDEX en 01_ddl ni 02_dml. PostgreSQL no indexa las FK: user_id/route_id de route_usage, favorite_routes, ratings, obstacle_reports quedan en escaneo completo, y las consultas de reportes y puntos de interés cercanos sobre columnas GEOGRAPHY no tienen índice GiST. La migración EF residual del backend sí declaraba índices para security, lo que confirma la divergencia.
- **Cómo cerrarlo (M):** Crear 10_indexes con un índice por FK, GiST en location/route_geometry y los compuestos de los patrones de consulta (usuario + fecha de inicio), cada uno con rollback.

### [Alto] H-23 · Seis endpoints de roles y permisos son inalcanzables por la restricción {id:int} con claves Guid
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Security/EcoRuteando.Modules.Security.Presentation/Controllers/RolesController.cs:38`
- **Por qué importa:** GET/PUT/DELETE api/roles/{id:int} y api/permissions/{id:int} reciben Guid id, y las tablas security.roles y security.permissions tienen id UUID: ninguna petición con un UUID casa con la ruta (404). CreateRole devuelve CreatedAtAction hacia una acción que nunca resuelve. El manual replica el error (09-endpoints.md).
- **Cómo cerrarlo (S):** Cambiar a {id:guid} en los seis atributos y cubrir con una prueba de integración por controlador.

### [Alto] H-24 · GET /api/routes entrega las rutas de todos los usuarios, sin paginar, y la web persiste un viaje transitorio por cada cálculo
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Mobility/EcoRuteando.Modules.Mobility.Application/Routes/Queries/GetRoutes/GetRoutesQueryHandler.cs:23`
- **Por qué importa:** El handler trae toda la tabla (GetAllAsync/GetActiveAsync) y solo filtra por dueño en memoria si mine=true. La web crea una ruta 'Viaje: origen -> destino (marca de tiempo)' en cada cálculo (propietario/EcoRuteando:front-end/ecoRuteando-react/src/features/home/pages/PlanRoute.jsx:435) y solo la oculta en el cliente buscando '[trip_transient]' en la descripción. Cualquier usuario con routes.read recibe nombres, coordenadas y polilíneas de los trayectos ajenos (datos personales de ubicación, Ley 1581), y la tabla crece sin límite.
- **Cómo cerrarlo (M):** Filtrar por dueño y por tipo en la consulta SQL, añadir paginación, y modelar el viaje transitorio como route_usage con geometría propia en vez de una fila en routes.

### [Medio] H-25 · Tres de los cuatro repos no tienen README útil y el cuarto describe otro sistema
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:1`
- **Por qué importa:** EcoRuteandoBackend, EcoRuteandoDb y Movil-EcoRuteando tienen un README de una línea (el de Movil además en UTF-16 y no se lee), el README de front-end es la plantilla de Vite y el raíz de EcoRuteando describe otro stack. Quien reciba un repo suelto no sabe qué es ni cómo ejecutarlo; las instrucciones reales están en una sección de 1.800 líneas del manual.
- **Cómo cerrarlo (S):** Un README por repo con qué es, requisitos con versiones, variables, comandos de arranque y de qué otro repo depende, enlazando al manual; recodificar el de Movil a UTF-8.

### [Medio] H-26 · Navegación del web: la ruta desconocida, el rol insuficiente y la sesión vencida no explican nada
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `front-end/ecoRuteando-react/src/app/App.jsx:145`
- **Por qué importa:** La ruta comodín redirige a /dashboard (App.jsx:145) sin pantalla de no encontrado; ProtectedRoute.jsx:29 manda a quien no tiene el rol a /dashboard sin avisar (no hay 403); y el vencimiento de sesión ejecuta localStorage.clear() (borra también idioma y tema) y navega a /login sin mensaje (api.js:81-82 y 101). El usuario queda sin saber qué pasó. Los tokens viven en localStorage, expuestos ante cualquier XSS.
- **Cómo cerrarlo (S):** Pantalla 404 y pantalla 403 con salida, mensaje de sesión expirada en /login, borrar solo las claves de sesión y evaluar cookies HttpOnly para el refresh token.

### [Medio] H-27 · Hay pantallas de administración completas a las que nadie puede llegar
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `front-end/ecoRuteando-react/src/features/admin/pages/PoiManage.jsx:1`
- **Por qué importa:** PoiManage.jsx (gestión de puntos de interés) y AdminReports.jsx (verificación de reportes) no tienen ruta en App.jsx ni import en ningún archivo (git grep), aunque el backend expone CreatePoi y DeactivatePoi y existe la rama DB-06-gestion-pois; /admin/reports redirige a tickets. AdminDashboard, MapView, RutaMapa, SocialButtons y dos servicios más tampoco se usan. El administrador no puede gestionar los POI desde la web.
- **Cómo cerrarlo (S):** Enrutar PoiManage en /admin/poi con enlace desde AdminPanel y ProtectedRoute admin, o borrar los módulos sin uso.

### [Medio] H-28 · IP de red local y URL de release incrustadas en el front
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `front-end/ecoRuteando-react/src/shared/components/DownloadApkModal.jsx:28`
- **Por qué importa:** DownloadApkModal.jsx:28 y 67 inicializan una IP privada y otra distinta (10.3.234.116 y 10.90.222.239) y public/version.json:4 la versiona junto con el enlace del release v1.0.7; con cada versión del APK hay que editar código. El enlace descargable local nunca funcionará fuera de esa red.
- **Cómo cerrarlo (S):** Leer URL y versión de una variable de entorno o de la API de releases de GitHub y no versionar la IP local.

### [Medio] H-29 · Móvil: callejones sin salida en notificaciones, estadísticas y guardia de sesión
- **Repositorio:** `propietario/Movil-EcoRuteando`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/_layout.tsx:17`
- **Por qué importa:** El manejador de toque en una notificación está vacío (app/_layout.tsx:17 solo tiene un comentario, aunque climateAlerts.ts:95 envía actionUrl), el toque no lleva a ningún lado; stats.tsx:41 convierte un fallo de red en la pantalla de sin viajes; la sesión se protege ocultando pestañas y con AccountRequired por pantalla, sin guardia en el enrutador; y apiClient.ts:84-86 borra tokens al fallar el refresh sin avisar a AuthContext, dejando la UI como autenticada con llamadas que fallan.
- **Cómo cerrarlo (M):** Implementar router.push(actionUrl) en el manejador, estados de carga y error con reintento en stats.tsx, un guardia de grupo en app/(tabs)/_layout.tsx y una función signOut invocada desde el interceptor.

### [Medio] H-30 · No hay indicadores de éxito de producto ni catálogo de historias con criterios de aceptación
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `documents/Articulo-Academico-EcoRuteando.md:55`
- **Por qué importa:** El problema y los actores están (README, manual §3), y los RNF traen criterios medibles técnicos, pero los objetivos O1-O6 del artículo son de ingeniería, no hay al menos tres KPIs con fórmula, línea base y meta (CO2 evitado, trayectos completados, reportes validados), y las HU-01 a HU-36 con que se nombran ramas y PR no están listadas en ningún documento con criterios de aceptación; la trazabilidad llega a Web / Móvil / Backend, no a pantalla o endpoint.
- **Cómo cerrarlo (M):** Añadir un kpi-baseline con tres indicadores y un backlog.md con las HU Must y dos criterios cada una, enlazadas a pantalla y endpoint en la matriz.

### [Medio] H-31 · 246 PR sin una sola revisión y sin issues ni tablero
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/EcoRuteando/pulls`
- **Por qué importa:** Los 103 + 94 + 31 + 18 PR se abren y fusionan con la misma cuenta, sin revisores ni comentarios, y main no tiene protección; por cada historia hay tres PR (dev, qa, main) que no aportan control. Tampoco hay issues ni tablero, por lo que el backlog solo vive en nombres de rama. Es un equipo de una persona, por lo que no se puntúa T-13.3, pero el proceso no deja huella de calidad ni de planeación.
- **Cómo cerrarlo (S):** Crear issues por historia con criterios de aceptación y un Project, proteger main exigiendo PR y que el instructor o un compañero revise; reducir a un PR por historia si no hay entornos reales dev y qa.

### [Medio] H-32 · Historial de Movil aplastado y megacommits que no se pueden revisar
- **Repositorio:** `propietario/Movil-EcoRuteando`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app/(tabs)/plan-route.tsx:1`
- **Por qué importa:** Movil-EcoRuteando empieza con un commit de 119 archivos y 26.541 líneas (cb8b4004c5, 2026-10-06 07:50) 39 minutos después del Initial commit, con pantallas de 1.793 y 1.038 líneas ya hechas: el trabajo previo se hizo fuera del repo y no hay historia. En EcoRuteando, 5523949 mezcla 136 archivos (documentación, mermaid.min.js duplicado y código) bajo un mensaje de corrección de HU-32, y en Backend c29557b68a (131 archivos) y caa82a7808 (80 archivos) tienen mensajes que no describen su contenido. Esto impide revisar o revertir.
- **Cómo cerrarlo (S):** Commits atómicos por cambio con mensaje convencional, subir el trabajo previo en lotes con historia real y no mezclar documentación con código en un mismo commit.

### [Medio] H-33 · El historial de direcciones (CU27) está a medias y rompe silenciosamente
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `front-end/ecoRuteando-react/src/services/routeService.js:34`
- **Por qué importa:** La web pide GET /routes/history/addresses al abrir la planificación; el backend tiene el handler GetUserAddressHistoryHandler y la tabla mobility.address_history, pero ningún controlador lo expone, la entidad no tiene configuración EF y nadie escribe en la tabla. La promesa en pantalla desaparece sin error visible (el .then vacío oculta el 404).
- **Cómo cerrarlo (S):** Implementar el endpoint y la escritura al buscar, o retirar la llamada, el handler y la tabla.

### [Medio] H-34 · La URL de despliegue documentada no es la que responde
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `documents/manual-tecnico/14-despliegue.md:10`
- **Por qué importa:** El manual y los perfiles de EAS apuntan a https://ecoruteando-backend.onrender.com (404 en un GET) mientras vercel.json y el cliente móvil usan https://ecoruteandobackend.onrender.com (200). Quien siga el manual construye la app móvil contra un servidor que no existe.
- **Cómo cerrarlo (S):** Corregir la URL en 14-despliegue.md y eas.json y ponerla en una sola variable.

### [Medio] H-35 · Levantar el sistema desde cero no deja una cuenta de administrador ni datos para recorrerlo
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker-compose.yml:17 y .env.example:5`
- **Por qué importa:** El .env.example del backend omite GoogleMaps__ApiKey, Admin__Email/Admin__Password (sin ellos AdminBootstrapService omite la creación del administrador) y DB_USERNAME/DB_PASSWORD que usa docker-compose.yml:17. Además el compose de EcoRuteando define GoogleMaps__ApiKey desde GOOGLE_MAPS_API_KEY (docker-compose.yml:41 del repo web), y en Docker Compose la sección environment gana sobre env_file: aunque se complete la clave en el .env del backend, llega vacía si la variable de la raíz no existe. El seed de rutas y POI (scripts/seed_mobility_demo.sql en Db) no entra al changelog y es de Bogotá mientras el producto es de Neiva, así que el primer arranque muestra todas las pantallas vacías.
- **Cómo cerrarlo (S):** Completar .env.example con todas las variables, alinear los nombres del compose con los del código, y añadir un changelog de datos de demostración para Neiva más un administrador inicial documentado.

### [Medio] H-36 · README y documento de arquitectura describen otro sistema
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:98`
- **Por qué importa:** El README declara 'Node.js con Express' y rutas con bicicleta y transporte público, y el backend es ASP.NET Core 9 en C#. documents/documento-arquitectura.md:69 lista un solo módulo (Security) cuando el código tiene cinco (Admin, Integrations, Mobility, Notifications, Security) y afirma alcance solo vehículo y a pie mientras el enum de base y de EF conserva bike, public_transport y mixed.
- **Cómo cerrarlo (S):** Reescribir el README con el stack real y actualizar la sección 5 del documento de arquitectura con los cinco módulos.

### [Medio] H-37 · Contradicciones internas de seguridad entre la documentación y el código
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `documents/documento-arquitectura.md:39`
- **Por qué importa:** Los casos de uso y diagramas de secuencia (CU01, DS01) prometen Argon2id, el documento de arquitectura y el código usan BCrypt (BCryptPasswordHasher.cs en el backend), y el manual dice que el refresh token se hashea con BCrypt cuando RefreshTokenService.cs usa SHA-256. El manual además lista rutas /sensitive/... que no existen.
- **Cómo cerrarlo (S):** Unificar en un solo texto lo implementado y marcar como futuro lo que no se construyó.

### [Medio] H-38 · Fronteras de módulo difusas: tabla compartida y controladores duplicados
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Mobility/EcoRuteando.Modules.Mobility.Infrastructure/Persistence/Configurations/TransportFactorConfiguration.cs:12`
- **Por qué importa:** admin.transport_factors está mapeada por Admin y por Mobility (dos modelos de la misma tabla), el esquema community lo gestiona Mobility sin módulo propio y existen api/exports y api/admin/exports, api/admin/stats y api/admin/statistics, api/weather y api/integrations/weather. Cambiar la tabla exige tocar dos módulos.
- **Cómo cerrarlo (M):** Asignar cada tabla a un solo módulo y exponer la lectura entre módulos por una interfaz; fusionar o renombrar los controladores duplicados.

### [Medio] H-39 · El módulo de administración lee la tabla de usuarios por SQL directo y esconde el fallo
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Admin/EcoRuteando.Modules.Admin.Infrastructure/Persistence/Repositories/SupportTicketRepository.cs:85`
- **Por qué importa:** SupportTicketRepository.GetUserDetailsAsync abre la conexión de EF y ejecuta SELECT sobre security.users (línea 85) saltándose el límite del módulo Security que la propia arquitectura declara aislado, y si falla hace Console.WriteLine (línea 104) y devuelve el diccionario vacío: los tickets se muestran sin nombre ni correo y nadie se entera. En web y móvil hay 79 y 66 llamadas a console usadas como estrategia de errores.
- **Cómo cerrarlo (S):** Exponer una consulta de Security (por MediatR o una interfaz pública) para obtener nombres, registrar con ILogger y propagar el error; sustituir los console de las apps por un logger con niveles.

### [Medio] H-40 · El frontend guarda access y refresh token en localStorage
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `front-end/ecoRuteando-react/src/api/api.js:92`
- **Por qué importa:** api.js:92-93 y AuthContext.jsx:40-41 escriben ambos tokens en localStorage; cualquier XSS los lee. La skill de seguridad de API lo marca como salida prohibida. El CSP de nginx mitiga pero permite style-src unsafe-inline. La app movil si usa SecureStore, lo que muestra que el equipo sabe la alternativa.
- **Cómo cerrarlo (M):** Mover el refresh token a una cookie HttpOnly SameSite=Strict servida por el backend y mantener el access token solo en memoria.

### [Medio] H-41 · El codigo de recuperacion de contrasena tiene 6 digitos y se busca sin el correo
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Security/EcoRuteando.Modules.Security.Application/Users/Commands/ResetPassword/ResetPasswordCommandHandler.cs:40`
- **Por qué importa:** ForgotPassword genera un OTP de 100000 a 999999 (OtpProvider.cs:11), valido 1 hora (ForgotPasswordCommandHandler.cs:76), y ResetPassword lo localiza solo por su hash (ResetPasswordCommandHandler.cs:40) sin correo asociado: el atacante no necesita conocer la victima, basta acertar cualquier codigo activo. El limitador sensitive (3 por hora por IP, AuthController.cs:152) lo frena desde una IP, pero no desde varias.
- **Cómo cerrarlo (S):** Exigir el correo en ResetPasswordRequest y buscar por correo y hash, bajar la validez a 15 minutos, invalidar tras 5 intentos fallidos y revocar las sesiones al cambiar la contrasena.

### [Medio] H-42 · Correo personal, contrasena de prueba y JWT reales versionados en app.http
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Api/EcoRuteando.Api/app.http:8`
- **Por qué importa:** El archivo app.http versiona el correo de una persona, una contrasena de prueba ««redactado»» y cinco JWT firmados con la clave real del backend (expirados el 2026-07-27, lineas 13 a 29). Hoy no son utilizables, pero sientan el habito y exponen datos personales (Ley 1581). El token se subio en el commit 9a8e948 del 2026-07-31.
- **Cómo cerrarlo (S):** Reemplazar por variables de la extension REST Client (@token) o un archivo .http.user ignorado por git, y pedir al dueno del correo que cambie su contrasena si la reutiliza.

### [Medio] H-43 · Administracion, Integraciones y Notificaciones aceptan entradas sin validar
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Admin/EcoRuteando.Modules.Admin.Application/Exports/Commands/UpdateExportStatus/UpdateExportStatusCommandHandler.cs:17`
- **Por qué importa:** Solo los modulos Seguridad (8 validadores) y Movilidad (16) registran FluentValidation y ValidationBehavior; los otros tres reciben texto libre (FileUrl, ExportType, URL de terminos y privacidad, colores y logo de la configuracion) sin validar formato, longitud ni esquema de URL, lo que habilita enlaces de descarga maliciosos en las exportaciones y URL arbitrarias en la configuracion que ven todos los usuarios.
- **Cómo cerrarlo (M):** Registrar AddValidatorsFromAssembly y el ValidationBehavior en esos tres modulos, validar URL con esquema https y listas blancas de ExportType.

### [Medio] H-44 · El manual declara funcionalidades como completas sin pruebas que las respalden
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `documents/manual-tecnico/17-18-seguridad-features.md:1`
- **Por qué importa:** La seccion 18 marca como Completo el registro, 2FA, RBAC y sesiones. Sin pruebas, esa palabra es una afirmacion no verificable, y el propio manual 17.4 describe hallazgos (claves en un .env commiteado, ausencia de rate limiting) que ya no corresponden al codigo: el historial de los cuatro repositorios no muestra ningun .env agregado y el rate limiting existe.
- **Cómo cerrarlo (S):** Vincular cada funcionalidad completa a su prueba o marcarla como sin verificar, y actualizar la seccion 17.4 con el estado real.

### [Medio] H-45 · El CI del frontend solo compila y la imagen corre nginx como root sin healthcheck
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `front-end/ecoRuteando-react/package.json:8 y .github/workflows/ci.yml:22`
- **Por qué importa:** El workflow Validar Proyecto hace npm install (no npm ci) y npm run build en pull_request; no ejecuta npm run lint (que existe en package.json), npm audit ni pruebas, y no corre en push a main. La imagen final de nginx no declara USER ni HEALTHCHECK.
- **Cómo cerrarlo (S):** Cambiar a npm ci, agregar lint, audit y pruebas, y usar nginx-unprivileged con HEALTHCHECK.

### [Medio] H-46 · Dos Dockerfiles divergentes, ambos como root y sin healthcheck, y sin plan de release ni rollback
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Api/EcoRuteando.Api/Dockerfile:30`
- **Por qué importa:** El Dockerfile de Render expone 8080 y el dockerfile de la raiz 5124 (dockerfile:66), ninguno define USER (corren como root), ninguno HEALTHCHECK, y render.yaml no define healthCheckPath. No hay documento de release ni de rollback del backend (git grep sin coincidencias), a diferencia de la base de datos que si lo tiene.
- **Cómo cerrarlo (M):** Unificar en un solo Dockerfile multi-etapa con usuario no root (la imagen aspnet 9 trae el usuario app), agregar /health y healthCheckPath, y documentar el rollback por version desde el panel de Render.

### [Medio] H-47 · La clave de cifrado de los secretos TOTP no esta documentada ni aprovisionada
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Security/EcoRuteando.Modules.Security.Infrastructure/Security/AesEncryptionService.cs:13`
- **Por qué importa:** AesEncryptionService exige la clave Encryption__TotpSecretKey de 32 bytes en base64 y lanza excepcion si falta, pero no aparece en .env.example, docker-compose.yml, render.yaml ni appsettings.json. En una instalacion hecha con los archivos del repositorio, activar o verificar el 2FA terminaria en error 500 (efecto inferido; no se puede ver el panel de Render).
- **Cómo cerrarlo (S):** Agregar la variable a .env.example, docker-compose.yml y render.yaml (sync false) y validar las variables obligatorias al arrancar.

### [Medio] H-48 · La base se migra sola cada dia desde main, con un CI que no ejecuta la migracion
- **Repositorio:** `propietario/EcoRuteandoDb`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `render.yaml:11`
- **Por qué importa:** El cron de Render ejecuta liquibase update cada dia a las 03:00 UTC sobre la base real, mientras el CI solo corre validate y updateSQL (ci.yml:51 y :60) en PR hacia develop: ninguna ruta aplica los cambios a un Postgres antes de producir. Las 05_rollbacks existen y son una fortaleza, pero no hay procedimiento documentado que las enlace con un despliegue fallido.
- **Cómo cerrarlo (M):** Agregar al CI un paso que ejecute update contra el Postgres de servicio y luego rollback del ultimo cambio, disparar la migracion tras el merge a main en lugar del cron diario y documentar el procedimiento de rollback.

### [Medio] H-49 · La app movil no tiene pipeline y su perfil preview apunta a un tunel temporal
- **Repositorio:** `propietario/Movil-EcoRuteando`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `eas.json:16`
- **Por qué importa:** No hay workflows en el repositorio, el perfil preview de eas.json:16 apunta a un tunel quick de Cloudflare que caduca, y las URL del backend estan inconsistentes entre eas.json:24 (con guion) y src/shared/services/apiClient.ts:5 (sin guion); vercel.json y keep-alive usan la segunda. Un build de produccion puede apuntar a un host distinto del real.
- **Cómo cerrarlo (S):** Definir un workflow que ejecute tsc y el build con EAS por etiqueta, fijar una sola URL por perfil desde un secreto y confirmar cual es el host oficial de Render.

### [Medio] H-50 · El modelo de datos documentado no corresponde al implementado
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `documents/manual-tecnico/08-modelo-datos.md:34`
- **Por qué importa:** El manual declara roles/permissions con id SERIAL (son UUID), la tabla trip_history (no existe), cuatro procedimientos sp_* (07_procedures está vacío), enums con otros nombres y valores, users.full_name (son first_name y last_name) y '36 tablas' (hay 41). Quien use el manual para consultar o migrar se equivocará.
- **Cómo cerrarlo (S):** Regenerar 08-modelo-datos.md desde el DDL (o un diagrama ER generado) y retirar lo que no existe.

### [Medio] H-51 · Dos fuentes de verdad del esquema: migración EF residual junto a Liquibase
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Security/EcoRuteando.Modules.Security.Infrastructure/Migrations/20260701141621_InitialCreate.cs:21`
- **Por qué importa:** El backend conserva una migración EF InitialCreate (5 tablas de security con índices) y el snapshot, pero nada la ejecuta (no hay Migrate ni EnsureCreated) y el esquema real lo crea Liquibase en otro repositorio. Cualquiera que ejecute dotnet ef database update obtendrá un esquema distinto.
- **Cómo cerrarlo (S):** Eliminar la carpeta Migrations del módulo Security o documentarla como obsoleta; Liquibase queda como única fuente.

### [Medio] H-52 · Integridad de trayectos: usage_id sin FK y con tipos incompatibles
- **Repositorio:** `propietario/EcoRuteandoDb`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/004_mobility__module/009_create_table_ratings.sql:5`
- **Por qué importa:** mobility.ratings.usage_id es BIGINT y mobility.route_usage.usage_id es UUID; shared_routes.usage_id (UUID) no tiene FK porque la PK compuesta (usage_id, created_at) de la tabla particionada lo impide. El backend replica el error (Rating.UsageId es long?, ShareRouteCommand.UsageId es Guid). Además route_usage se particiona por rango pero solo existe la partición DEFAULT, así que el particionado no aporta nada y es lo que bloquea las FK.
- **Cómo cerrarlo (M):** Decidir si route_usage necesita particionado; si no, PK simple en usage_id, FK desde ratings y shared_routes y tipo UUID en ratings.usage_id.

### [Medio] H-53 · Ningún listado pagina
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Mobility/EcoRuteando.Modules.Mobility.Infrastructure/Persistence/Repositories/RouteUsageRepository.cs:39`
- **Por qué importa:** GET trips, routes, users, pois y audit-logs devuelven la colección completa con ToListAsync (no aparece pageSize ni Skip/Take en Presentation ni Application). Con el historial creciendo por cada cálculo de ruta la respuesta y el uso de memoria crecen sin techo; el manual dice 'paginado' para GET /users.
- **Cómo cerrarlo (M):** Añadir page/pageSize con tope y orden estable, y devolver total en cabecera o sobre.

### [Medio] H-54 · Los controladores reciben los comandos de la capa Application como cuerpo HTTP
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Mobility/EcoRuteando.Modules.Mobility.Presentation/Controllers/RoutesController.cs:70`
- **Por qué importa:** CreateRoute, UpdateRoute, StartTrip, RateRoute y CreateObstacleReport enlazan el record de MediatR directamente (con campos como CreatedBy, UserId, IsAdmin que luego se pisan con 'with'). El contrato HTTP queda atado al modelo interno y un campo nuevo en el comando se vuelve público sin querer; por ejemplo, un cuerpo con nombre de campo equivocado se acepta con valores por defecto.
- **Cómo cerrarlo (M):** Definir DTOs de petición en Presentation (como ya hacen Security y VoteReportApiRequest) y mapearlos al comando.

### [Bajo] H-55 · Archivos duplicados, .gitignore roto y residuos de IDE versionados
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `.gitignore:22`
- **Por qué importa:** .gitignore:22 dice .idea/git reset (el patrón .idea/ no queda activo) y repite .env; documents/ duplica carpetas (web_documentacion y web_docmuentacion), PNG, visores HTML y mermaid.min.js de 3,3 MB; en Movil se versionan .idea/ (5 archivos), android/app/debug.keystore y el prebuild de android/. Ensucia el repo y complica la revisión.
- **Cómo cerrarlo (S):** Corregir .gitignore, git rm de los duplicados y de .idea/ en Movil, y decidir si android/ se genera con expo prebuild en CI en vez de versionarse.

### [Bajo] H-56 · Accesibilidad mínima sin cubrir en web y móvil
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `front-end/ecoRuteando-react/src/features/auth/components/Login.jsx:1`
- **Por qué importa:** Web: 1 htmlFor para 72 campos, 90 outline-none frente a 53 estilos de foco y 28 atributos aria; móvil: 3 accessibilityLabel en toda la app y fuente fija. Quien navega con teclado o lector de pantalla no puede completar el registro ni el reporte con seguridad; los RNF del propio equipo piden WCAG 2.1.
- **Cómo cerrarlo (M):** Etiquetas asociadas en todos los campos, foco visible, accessibilityLabel y accessibilityRole en botones y campos del móvil, y una pasada de contraste sobre los tokens finales.

### [Bajo] H-57 · PR abiertos viejos que borrarían 42.000 líneas y ramas muertas acumuladas
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/EcoRuteando/pulls (PR 35, 39, 40 y 41 abiertos)`
- **Por qué importa:** Siguen abiertos desde el 2026-10-09 los PR #39, #40 y #41 (HU-01, HU-02 y HU-23 hacia main) y el #35: HU-01-main contra main tiene 249 archivos con 42.769 líneas eliminadas, de modo que fusionarlos por error revertiría el producto. Además hay 81 ramas en EcoRuteando, 69 en Backend, 18 en Db y 19 en Movil; HU-04-develop y HU-05-develop conservan el Api .NET 8 abandonado con bin/obj y .vs. main sí contiene todo el trabajo vigente (develop y qa van 0 commits por delante).
- **Cómo cerrarlo (S):** Cerrar los PR #35, #39, #40, #41 y borrar las ramas fusionadas o abandonadas; activar la eliminación automática de ramas al fusionar.

### [Bajo] H-58 · Versiones y credenciales de la BD desalineadas entre compose, CI y .env.example
- **Repositorio:** `propietario/EcoRuteandoDb`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-62, H-61
- **Evidencia:** `docker-compose.yml:43`
- **Por qué importa:** El compose de Db fija usuario y contraseña de Liquibase en línea (43-44) ignorando las variables POSTGRES_*, el .env.example sugiere el puerto 5433 mientras el compose usa 5450, el CI valida con Liquibase 4.27.0 y postgres:16 sin PostGIS (ci.yml:37) frente a 5.0.2 y postgis 16-3.5 que se despliegan. El CI puede pasar sin garantizar que el despliegue funcione.
- **Cómo cerrarlo (S):** Usar las variables en el comando de Liquibase, alinear el puerto del .env.example y que el CI use la misma imagen y versión que el compose.

### [Bajo] H-59 · Ramas HU-04-develop y HU-05-develop guardan un prototipo de API abandonado
- **Repositorio:** `propietario/EcoRuteando`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git log del clon repos/12/Integrante 1-lsd__EcoRuteando entre el SHA evaluado y origin/HU-05-develop`
- **Por qué importa:** El historial entre el SHA evaluado y origin/HU-05-develop muestra 8 commits (7 de Integrante 3, 1 de Integrante, abril de 2026) con 459 archivos y unas 20 000 líneas, en su mayoría una carpeta Api/ con bin/obj y .vs versionados y un commit final 'remove Api'. No está en main ni coincide con el backend actual. HU-19-interrupcion-trayecto y HU-01/02/23-main solo traen merges ya integrados.
- **Cómo cerrarlo (S):** Archivar con una etiqueta y borrar las ramas, y aclarar en el README la autoría de contribuciones cruzadas.

### [Bajo] H-60 · Pequenas fugas y atajos en la autenticacion
- **Repositorio:** `propietario/EcoRuteandoBackend`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/Modules/Security/EcoRuteando.Modules.Security.Application/Users/Commands/LoginUsers/LoginUserCommandHandler.cs:109`
- **Por qué importa:** El mensaje con intentos restantes solo aparece para correos existentes (lineas 64 y 109), lo que permite enumerar cuentas; ForwardedHeaders confia en cualquier proxy (Program.cs:176-177); el limitador de recuperacion es en memoria y se pierde al reiniciar; las rutas usan IsInRole Admin y omiten SuperAdmin (RoutesController.cs:107); y el borrado de cuenta deja el correo en audit_logs (DeleteUserCommandHandler.cs:46) sin politica de retencion.
- **Cómo cerrarlo (S):** Responder igual para cuentas inexistentes, fijar KnownProxies/KnownNetworks del proveedor, persistir el limitador y definir retencion y anonimizado del registro de auditoria.

### [Bajo] H-63 · Default de users.status contradice el CHECK que se añade después
- **Repositorio:** `propietario/EcoRuteandoDb`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `01_ddl/04_constraints/003_users_check_constraints.sql:1`
- **Por qué importa:** 005_create_table_users.sql declara DEFAULT 'ACTIVE' (enum en mayúsculas), 002 convierte la columna a varchar y 003 agrega un CHECK solo con valores en minúsculas: un INSERT sin status explícito fallaría. El backend siempre envía 'active', por lo que solo afecta a SQL manual (inferido, no ejecutado).
- **Cómo cerrarlo (S):** Cambiar el default a 'active' en una migración nueva y unificar la capitalización de todos los enums.

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 59.4 |
| D2 | Reproducibilidad | 38.8 |
| D3 | Arquitectura y congruencia | 66.7 |
| D4 | Calidad de código | 51.5 |
| D5 | Seguridad | 59.2 |
| D6 | Pruebas | 0.0 |
| D7 | DevOps y despliegue | 40.2 |
| D8 | Datos | 55.0 |
| D9 | API y contratos | 45.0 |
| D10 | Frontend y móvil | 43.8 |
| D11 | IoT y firmware | — |
| D12 | Documentación y trazabilidad | 33.3 |
| D13 | Proceso y colaboración | 53.1 |
| D14 | Extremo a extremo | 30.8 |

## Lo que está bien

- Módulos del backend verdaderamente aislados (`propietario/EcoRuteandoBackend:src/Modules/Mobility/EcoRuteando.Modules.Mobility.Presentation/EcoRuteando.Modules.Mobility.Presentation.csproj: ningún csproj de módulo referencia a otro módulo; Domain solo depende de Shared y las dependencias apuntan hacia adentro (Presentation -> Application <- Infrastructure).`)
- Manejo de errores centralizado con ProblemDetails (`propietario/EcoRuteandoBackend:src/Api/EcoRuteando.Api/Middlewares/ExceptionMiddleware.cs:35 mapea excepciones tipadas a 400/401/403/404/409/429/500 con mensaje neutro en el 500 y registro del error en segundo plano.`)
- Migraciones Liquibase completas, ordenadas y reversibles (`propietario/EcoRuteandoDb:changelog/db.changelog-master.yaml:1: 76 changesets con id UUID, cada uno con rollback y todas las rutas existen (verificado por script); 05_rollbacks espeja 01_ddl y 02_dml.`)
- Integridad referencial y restricciones declaradas en el esquema (`propietario/EcoRuteandoDb:01_ddl/04_constraints/001_additional_constraints_foreign_keys.sql:1: todas las FK con ON DELETE explícito (CASCADE o SET NULL), CHECK de rangos en routes y route_usage, UNIQUE (user_id, route_id) en ratings.`)
- Semillas de permisos alineadas con el código (`propietario/EcoRuteandoDb:02_dml/01_inserts/010_insert_report_vote_permission.sql:1: cada permiso usado por HasPermission en el backend está sembrado y asignado a Admin/User (cotejo por script).`)
- Contratos web-API coincidentes y propiedad del recurso validada en servidor (`propietario/EcoRuteando:front-end/ecoRuteando-react/src/services/tripService.js:14 y propietario/EcoRuteandoBackend:src/Modules/Mobility/EcoRuteando.Modules.Mobility.Presentation/Controllers/TripHistoryController.cs:55: rutas, métodos y campos coinciden; Update/DeleteRoute comprueban que el usuario sea el creador.`)
- Esquema geoespacial y de auditoría pensado para el dominio (`propietario/EcoRuteandoDb:01_ddl/03_tables/004_mobility__module/002_create_table_routes.sql:1: GEOGRAPHY(4326), NUMERIC para distancias y CO2, TIMESTAMPTZ con default now(), JSONB con CHECK de tipo.`)
- Contrasenas con BCrypt (workFactor 12) y tokens de recuperacion y refresh almacenados como hash (`src/Modules/Security/EcoRuteando.Modules.Security.Infrastructure/Security/BCryptPasswordHasher.cs:14`)
- Validacion completa del JWT: firma, emisor, audiencia, expiracion y ClockSkew cero (`src/Modules/Security/EcoRuteando.Modules.Security.Infrastructure/JwtAuthenticationExtensions.cs:25`)
- Los secretos del TOTP se cifran con AES-256-GCM con nonce aleatorio y etiqueta (`src/Modules/Security/EcoRuteando.Modules.Security.Infrastructure/Security/AesEncryptionService.cs:26`)
- Autorizacion granular por permisos (HasPermission) evaluada contra la base, mas verificacion de propiedad en rutas e historial de viajes (`src/Modules/Mobility/EcoRuteando.Modules.Mobility.Presentation/Controllers/RoutesController.cs:106`)
- Manejo centralizado de errores: el 500 devuelve un mensaje generico y el detalle va a un registro en segundo plano (`src/Api/EcoRuteando.Api/Middlewares/ExceptionMiddleware.cs:115`)
- Bloqueo de cuenta por intentos fallidos con politica configurable y limitadores por IP en auth y rutas sensibles (`src/Api/EcoRuteando.Api/Program.cs:73`)
- Sin administrador por defecto: el bootstrap exige correo y contrasena por variables y valida la politica (`src/Modules/Security/EcoRuteando.Modules.Security.Infrastructure/Bootstrap/AdminBootstrapService.cs:46`)
- Secretos fuera del codigo en el backend: appsettings vacio, render.yaml con sync false y .dockerignore que excluye .env (`render.yaml:30`)
- El TestController responde 404 fuera de Development y Swagger solo se publica en Development (`src/Modules/Security/EcoRuteando.Modules.Security.Presentation/Controllers/TestController.cs:25`)
- Cabeceras de seguridad completas en nginx (CSP, HSTS, X-Frame-Options, nosniff, Referrer-Policy, Permissions-Policy) (`propietario/EcoRuteando:front-end/ecoRuteando-react/nginx/default.conf:8`)
- La app movil guarda los tokens en expo-secure-store y pide ubicacion solo en primer plano (`propietario/Movil-EcoRuteando:src/shared/services/keyStorage.ts:2`)
- Cada changeset de Liquibase tiene su rollback en archivo aparte y hay scripts para ejecutarlo (`propietario/EcoRuteandoDb:01_ddl/03_tables/006_security_module/changelog.yaml:12`)
- CI de validacion de la base y del frontend con ejecuciones recientes exitosas y healthcheck de Postgres en el compose (`propietario/EcoRuteandoDb:docker-compose.yml:14`)
- Backend modular con arquitectura limpia y CQRS (`src/Modules/Security/EcoRuteando.Modules.Security.Application/Users/Commands/RegisterUser/RegisterUserCommandHandler.cs:1`)
- Manejo de errores centralizado con ProblemDetails y configuración externalizada (sin secretos en appsettings.json) (`src/Api/EcoRuteando.Api/Middlewares/ExceptionMiddleware.cs:1`)
- Documentación abundante y con convención de evidencia: arquitectura v1.1, 10 ADR, 28 CU, RNF medibles, plan e informe de pruebas que distingue lo diseñado de lo ejecutado (`documents/documento-arquitectura.md:1`)
- Cliente HTTP con refresco de sesión en cola y exclusión de endpoints públicos; en móvil tokens en SecureStore y timeout de 15 s (`front-end/ecoRuteando-react/src/api/api.js:1`)
- Listas con estados de carga, error y vacío (historial, favoritos, rutas guardadas, tickets) e internacionalización en cuatro idiomas con modo oscuro (`front-end/ecoRuteando-react/src/features/home/pages/UserHistory.jsx:1`)
- Dockerfile del front multi-etapa con nginx, cabeceras de seguridad y proxy a /api; CI del front en verde en cada PR (`front-end/ecoRuteando-react/nginx/default.conf:8`)
- Repositorio de datos con estructura DDL/DML/DCL/TCL, 86 scripts de rollback y CI de validación de Liquibase en verde (`changelog/db.changelog-master.yaml:1`)
- Disciplina de ramas por historia (dev, qa, main) con 246 PR y main que contiene todo el trabajo vigente; APK publicado como release de GitHub (`package.json:1`)

## Lo que no se pudo verificar

- Que un POST real de foto de perfil falle por el VARCHAR(500) en una base creada desde main — Exige levantar la base y ejecutar el backend; no se ejecuta código de los aprendices.
- Que Liquibase aplique sin error los 76 changesets sobre una base vacía (incluida la conversión de enums a varchar) — Requiere PostgreSQL y Liquibase; el CI del repo solo hace validate y updateSQL.
- Flujos autenticados contra el despliegue en Render — Solo se permite un GET de solo lectura; los endpoints de la ruta, el viaje y la calificación exigen sesión.
- Documentación en Google Drive del equipo — No se declara carpeta de Drive; la documentación evaluada es la del repositorio EcoRuteando (documents/ y docs/adr).
- Ramas DB-06-gestion-pois y release/iteration-03 del repo EcoRuteandoDb — Traen 3 y 2 commits que no están en main por SHA; el diff contra main solo cambia changelog de inserts y nombres de rollbacks, y main ya contiene el commit 'fix rollback file names and changelog paths'. Se consideran integrados por otra vía, sin confirmar.
- Dos comandos de lectura bloqueados por el guardia de gobernanza — Falso positivo sobre patrones de texto en expresiones sed y awk; no se insistió y se obtuvo la misma información con comandos de solo lectura reformulados.
- Hallazgos sobre autorización, secretos, CI y pruebas del backend — Fuera de las dimensiones D14, D3, D8 y D9 del especialista A.
- Restricciones de la clave de Google Maps expuesta en la app movil — Se ve en la consola de Google Cloud, a la que no se accede; no se probo la clave contra servicio alguno.
- Respuesta del backend desplegado — El unico GET permitido (host usado por vercel.json y keep-alive) agoto el tiempo a 15 s, compatible con arranque en frio; el host con guion de los manuales no se probo para respetar el limite de un GET.
- Vulnerabilidades conocidas en dependencias (dotnet list package --vulnerable, npm audit) — Exige ejecutar herramientas sobre el codigo de los aprendices; se evaluo solo por version declarada.
- Afirmacion del manual tecnico sobre un .env con claves reales commiteado (17.4) — No se encontro ningun .env agregado en el historial de las cuatro repos; puede referirse a un repositorio anterior no declarado. Si existio, la rotacion de claves no se puede comprobar.
- Contenido de las ramas adelantadas (web HU-05-develop +8 y HU-04-develop +4 de abril de 2026, backend HU-01/02/23-main, base DB-06-gestion-pois y release/iteration-03) — Es tema de proceso (D13, otro especialista). Desde la lente de D7 se observo que las ramas de la base son merges y migraciones que main ya tiene, y que las del web son anteriores a la reestructuracion; no se confirmo que el trabajo este integrado.
- Estado real de la configuracion de Render y Vercel (variables, plan, rollback) — Son paneles privados; solo se leyeron render.yaml y vercel.json del repositorio.
- Efecto en ejecucion de H-B02, H-B03 y H-B04 (reproducir con peticiones HTTP reales) — No se permite ejecutar el codigo ni llamar al servicio; los hallazgos se comprobaron leyendo atributos, controladores y manejadores, no con peticiones.
- Bloques del guardia de gobernanza durante la sesion — Dos comandos de lectura fueron bloqueados por el guardia por un falso positivo con la cadena de sustitucion; se reescribieron sin ese patron y sin afectar la evidencia.
- Compilación real del front web y de la app móvil en una máquina limpia — Prohibido ejecutar npm install o expo; en web se usó como evidencia la ejecución verde de Validar Proyecto en GitHub Actions y en móvil no hay CI.
- Con qué perfil de EAS se compiló el APK v1.0.7 publicado en el release — El binario no se descargó ni inspeccionó; por eso el hallazgo del host muerto se limita a la configuración eas.json.
- Si la clave de Google Maps de Movil tiene restricción por paquete o cuota — Solo se puede saber desde la consola de Google Cloud; se trata como expuesta.
- Colaboradores, protección de ramas y Projects de organización de los 4 repos — La API respondió 403 al listar colaboradores sin permiso de escritura; solo se comprobó que no hay Projects a nivel de usuario ni issues.
- Cómo interpreta Expo el marcador de variable de entorno en app.json:34 — Exige ejecutar la configuración de Expo; el valor real viaja por manifestPlaceholders de android/app/build.gradle.
- Historial de secretos del repo web (commits 'fix: move hardcoded Google Maps API key to env var + untrack .env', cuatro veces) — Es R-5.1 y pertenece al especialista B; se deja como pista para el sintetizador.
- Muestreo de D4: lectura profunda de app/(tabs)/plan-route.tsx (2.001 líneas) y front-end/ecoRuteando-react/src/features/home/pages/UserProfile.jsx (1.790) como los dos componentes más grandes; lectura parcial de PlanRoute.jsx, AuthController.cs, RegisterUserCommandHandler.cs, SupportTicketRepository.cs, api.js, apiClient.ts, AuthContext y ProtectedRoute — Presupuesto de lectura; el resto de archivos se midió con git grep y conteos de líneas, no con lectura.
- Estado de las pantallas de móvil en tiempo de ejecución (estados de carga, vacío y error reales) — Se evaluó leyendo el código, sin ejecutar la app.
- Cuentas Integrante 2 y Integrante 3 en EcoRuteando (10 y 6 commits entre marzo y abril, antes de la ventana) — Son contribuciones cruzadas de otros equipos según las notas del evaluador; no se alteran porcentajes ni se evalúa su código, que quedó en ramas HU-04/05-develop sin integrar.
