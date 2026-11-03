# Equipo 5 · Lava Rápido Vehicular — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 59/100 · Juicio D**

## Veredicto

Los cinco flujos principales (cuenta, reserva, pago con Wompi, asignación de operador y calificación) están completos de punta a punta en el código y los contratos entre móvil, panel web y backend coinciden; aun así el puntaje es 58,6 (juicio D, a unos 11 puntos del umbral de 70). Lo más grave es el único bloqueante: la contraseña de la base, la clave que firma los JWT y la clave de Gmail están en claro en main, qa y el historial de un repositorio público (develop ya las lee de variables, pero el historial las conserva), así que hay que rotarlas primero. El único crítico es que el esquema de la base de datos no está en ningún repositorio declarado, por lo que nadie puede levantar el backend solo con lo entregado, y main y qa no contienen el trabajo real, que vive en develop. Además faltan README útiles, CI/CD (unas 310 pruebas que nunca corren solas) y revisión entre pares de las PR. Resueltas las credenciales, el esquema y la rama principal, lo que queda es documentación, automatización y limpieza de código.

## Plan para cerrar las brechas

1. **Rotar de inmediato la contraseña de la base, la clave JWT y la clave de aplicación de Gmail; sacar los literales de application.properties en main, qa y las ramas que aún los tienen (develop ya usa variables de entorno), reescribir el historial de todas las ramas con git filter-repo o recrear el repositorio limpio, y quitar la contraseña fija del script de pruebas.** (esfuerzo M) — se cierra cuando: Las tres credenciales anteriores ya no funcionan; git grep sobre todas las ramas y el historial no devuelve valores reales en application.properties ni en local-http-roles.ps1; un escaneo con gitleaks sale limpio.
2. **Entregar y declarar el esquema de la base de datos (migraciones Liquibase/Flyway, semillas de roles y administradores) dentro de un repositorio declarado o de database/, corregir el enlace de 'Base de datos' en la ficha y revisar los índices de las llaves foráneas.** (esfuerzo M) — se cierra cuando: Un tercero clona solo los repos declarados, ejecuta el comando documentado y el backend arranca con ddl-auto=validate sin errores; las tablas de los 5 flujos y los roles existen.
3. **Llevar develop a main y qa por PR (o cambiar la rama por defecto), etiquetar una versión estable y dejar de usar la imagen ':local' y la versión SNAPSHOT en el despliegue.** (esfuerzo S) — se cierra cuando: La rama por defecto de ambos repos contiene el código vigente; existe al menos un tag/release y el compose referencia una imagen versionada.
4. **Escribir el README del backend (propósito, requisitos, variables, arranque con Docker, perfiles, orden con la base de datos), completar el .env.example con las variables que exige el compose (Wompi, correo, URL del frontend, CORS), documentar el aprovisionamiento del primer administrador y restituir en el repositorio los contratos de reservas y pagos que se borraron.** (esfuerzo M) — se cierra cuando: Siguiendo solo el README en una máquina limpia, docker compose up levanta el backend sin pedir variables no documentadas y se crea el primer administrador con el procedimiento descrito.
5. **Crear workflows de CI por repositorio (backend: mvnw verify y gitleaks; panel: npm ci, typecheck, vitest y build; móvil: npm ci, typecheck y jest) y exigirlos como check obligatorio en PR hacia develop, qa y main.** (esfuerzo M) — se cierra cuando: Cada PR dispara los workflows, aparecen en Actions con ejecuciones verdes y la protección de rama impide fusionar con el check en rojo.
6. **Reescribir el README del frontend con las tecnologías y versiones reales (Vite 6, zustand, Expo 57), los pasos de instalación, el .env y la estructura real de carpetas.** (esfuerzo S) — se cierra cuando: Un tercero instala y arranca el panel y la app móvil siguiendo solo el README y sin encontrar diferencias con package.json.
7. **Endurecer la seguridad del backend: límite de intentos y bloqueo en login y recuperación de cuenta, apagar Swagger y restringir el detalle de salud fuera de desarrollo, y agregar @Valid a los dos endpoints que reciben el cuerpo sin validar.** (esfuerzo M) — se cierra cuando: Tras N intentos fallidos el login responde 429 o bloquea la cuenta; /swagger-ui y el detalle de salud responden 401/404 sin autenticación en prod; los dos endpoints rechazan cuerpos inválidos con 400, con pruebas que lo comprueban.
8. **Endurecer el frontend: no guardar el JWT del admin en sessionStorage (cookie HttpOnly o equivalente), servir Leaflet desde el paquete o con versión e integridad fijas, y completar la política de datos personales con responsable, canal de contacto y derechos del titular (Ley 1581).** (esfuerzo M) — se cierra cuando: El token ya no es legible desde JavaScript, el mapa no carga código de CDN sin integridad y la política publicada nombra responsable, canal y derechos.
9. **Sacar las llamadas HTTP a Wompi de las transacciones y fijarles tiempos de espera; añadir pruebas de la matriz de autorización con SpringBootTest o WebMvcTest con seguridad, pruebas de la capa de datos, medición de cobertura y al menos un flujo e2e del pago.** (esfuerzo L) — se cierra cuando: verificar() y reconciliar() no mantienen una transacción abierta durante la llamada a Wompi y fallan con tiempo de espera definido; el CI reporta cobertura y una prueba e2e del pago pasa.
10. **Publicar el contrato OpenAPI versionado, versionar la API (/api/v1), paginar los listados, unificar convenciones de respuesta y retirar o implementar el código cliente sin contraparte, y alinear el tipo TipoVehiculo del admin con el enum del backend.** (esfuerzo L) — se cierra cuando: Existe un openapi.json en el repositorio que valida el CI; los listados aceptan página y tamaño; locationService.ts y orderService.ts ya no existen o tienen endpoint real; el admin acepta todos los valores del enum.
11. **Refactorizar y limpiar: dividir las seis pantallas móviles de más de 1 250 líneas, eliminar código muerto y servicios duplicados, centralizar las reglas de negocio duplicadas, unificar nomenclatura e idioma, comprimir las imágenes pesadas, mostrar los errores de carga como estado con reintento, restringir el registro del panel web y persistir la sesión móvil de forma segura.** (esfuerzo L) — se cierra cuando: Ningún archivo de pantalla supera 300 líneas; las imágenes del bundle móvil pesan menos de 500 KB cada una; no quedan archivos vacíos ni servicios duplicados; el horario de operación se define en un solo lugar.
12. **Alinear el proceso de equipo: documentación dentro de los repositorios (docs/ con problema, usuarios, alcance, KPI, historias con criterios de aceptación, arquitectura y ADR), issues y tablero para las historias HU-nn, PR con plantilla y aprobación del otro integrante, y mensajes de commit descriptivos; documentar por qué se reinició el historial del frontend.** (esfuerzo M) — se cierra cuando: Cada repo tiene docs/ con los artefactos listados; las historias existen como issues vinculados a sus PR; las nuevas PR tienen al menos una aprobación del otro integrante y la plantilla completa.

## Verificación independiente

Hallazgos confirmados: 4 · matizados: 1 · refutados: 0 · duplicados fusionados: 3.

Confirmé 4 de los 6 hallazgos revisados (H-02, H-03, H-04, H-08) y maticé 2: H-01 (los secretos literales en main, qa y el historial existen y el repo es público, pero fabricar tokens de admin para cualquier UUID solo vale para el JWT de main/qa con rol en el token; en develop exige conocer UUID y correo) y H-05 (duplicado de H-02, y lo borrado fueron dos scripts de pago_intentos, no el esquema). Los 4 ítems PASS se sostienen (R-10.2 con la línea corrida a api.ts:43; T-14.1 con la salvedad de que la tabla física no es comprobable), los 5 flujos se sostienen como COMPLETO a nivel de código y las cifras de aportes (56, 56 y 1) son exactas; la fusión de Integrante 3 con Integrante 1 sigue sin confirmar. Duplicados reales: H-05 con H-02, H-22 con H-07 (H-22 trae una afirmación errónea sobre store/) y H-40 con H-32 de forma parcial; los otros 10 pares no lo son.

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Completo | Registrarse, iniciar sesión y recuperar contraseña (móvil y web) | — |
| Completo | Registrar vehículo y reservar un lavado (móvil) | — |
| Completo | Pagar la reserva con Wompi y confirmar el pago | — |
| Completo | Asignar un operador y ejecutar el servicio (admin web → móvil del operador) | — |
| Completo | Calificar un servicio finalizado y recibir notificaciones (móvil) | — |

## Hallazgos

### [Bloqueante] H-01 · Contraseña de la base, clave de firma JWT y clave de la cuenta Gmail en claro en main, qa y el historial de un repositorio público
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** matizado (descripción precisada)
- **Evidencia:** `backend-vehicular/src/main/resources/application.properties`
- **Por qué importa:** Con git show origin/main:backend-vehicular/src/main/resources/application.properties (líneas 8, 22 y 29) se leen tres valores literales ««redactado»»: la contraseña de PostgreSQL, la clave que firma los JWT y la clave de aplicación de una cuenta Gmail. Lo mismo ocurre en qa y en HU-01 a HU-05, y el historial de las 36 ramas los conserva desde el commit 95a7492 (2026-05-07), con las variantes sucesivas de la contraseña de la base en 541efb1 y 64358cd. Quien conozca la clave JWT puede fabricar tokens válidos para cualquier UUID, incluidos los dos administradores, y el repositorio es público (gh api: private=false). Aunque develop ya usa variables, borrar el archivo no retira el secreto del historial.
- **Cómo cerrarlo (M):** 1) Rotar ya la contraseña de la base, la clave JWT (invalida todas las sesiones) y la clave de aplicación de Gmail, y revocar la anterior. 2) Reescribir el historial con git filter-repo sobre application.properties en todas las ramas y forzar el push, o crear un repositorio limpio desde develop. 3) Llevar el contenido de develop a main y qa para que el árbol vigente deje de tener literales. 4) Activar el escaneo de secretos y la protección de push de GitHub, y añadir gitleaks al CI.

### [Crítico] H-02 · El esquema de base de datos no está en ningún repositorio entregado: el backend no arranca sin un repo no declarado
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A13 · **Verificación independiente:** confirmado; también reportado como H-05
- **Evidencia:** `backend-vehicular/src/main/resources/application.properties:6; backend-vehicular/docker-compose.yml:65`
- **Por qué importa:** El backend usa ddl-auto=validate (application.properties:17) y su comentario dice que Liquibase vive en 'lavarapido-base-datos', un repositorio que el equipo no declaró (su enlace de 'Base de datos' apunta al repo del frontend, que no tiene SQL). Los 18 modelos JPA, las tablas de los 5 flujos y los datos mínimos (roles, administradores) no se pueden reproducir desde lo entregado; el compose del backend exige una red Docker creada por ese otro proyecto. Un tercero que clone los repos declarados no puede levantar el sistema ni auditar la BD.
- **Cómo cerrarlo (M):** Entregar y declarar un repositorio (o carpeta database/) con migraciones versionadas (Liquibase/Flyway), semillas de roles y un comando documentado para levantarlo desde cero; corregir el enlace de 'Base de datos' en la ficha y documentar en el README del backend el orden de arranque.

### [Alto] H-03 · README del backend vacío
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado
- **Evidencia:** `README.md:1`
- **Por qué importa:** El README es '# backend'. Con 15 módulos, JWT, pagos Wompi, push y correo, ningún integrante nuevo ni evaluador sabe qué variables, qué base ni qué perfil usar.
- **Cómo cerrarlo (S):** Escribir README con propósito, requisitos, variables (.env.example completo), arranque con Docker, perfiles dev/prod, tests y endpoints principales.

### [Alto] H-04 · La rama principal no contiene lo entregable en ninguno de los dos repositorios
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado
- **Evidencia:** `Comparación origin/main contra origin/develop en ambos clones: backend main 2026-08-11 vs develop 70 commits adelante; frontend main con 1 archivo vs develop 308`
- **Por qué importa:** main y qa están abandonados; quien clone el repositorio por defecto obtiene un backend de agosto o un frontend vacío. Los enlaces declarados apuntan a /tree/develop, es decir el equipo ya lo sabe, pero la rama por defecto engaña.
- **Cómo cerrarlo (S):** Promover develop a main por PR (o cambiar la rama por defecto), etiquetar una versión y mantener qa y main alineadas con un flujo documentado.

### [Alto] H-06 · El primer administrador solo se crea con una herramienta offline que ningún documento menciona
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/security/AdminIdentityPolicy.java:21 y backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/security/OwnerProvisioningTool.java:19`
- **Por qué importa:** ADMIN_USER_IDS debe tener exactamente dos UUID o el arranque falla, ningún endpoint crea administradores y la única vía es OwnerProvisioningTool (main manual con consola interactiva). Sin documentación, una instalación nueva queda con el panel inaccesible, y la restricción de exactamente dos dueños no está justificada en ningún lado.
- **Cómo cerrarlo (S):** Documentar el procedimiento de aprovisionamiento (comando, variables, orden) y la regla de dos administradores; considerar un script de arranque inicial en compose.

### [Alto] H-07 · README del frontend desactualizado y con instalación que falla por pasos que no menciona
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-22
- **Evidencia:** `README.md:1 contra lava-rapido-admin/package.json:1 y lava-rapido-mobile/package.json:1`
- **Por qué importa:** Dice Vite 8, Redux Toolkit y Expo 52 (el código usa Vite ^6, zustand y expo ~57); no menciona el .env, y la app móvil lanza una excepción al arrancar sin EXPO_PUBLIC_API_URL (apiUrl.ts:3); no dice que necesita el backend ni la versión de Node.
- **Cómo cerrarlo (S):** Reescribir el README con prerrequisitos, .env, backend, scripts reales y la estructura actual.

### [Alto] H-08 · Seis pantallas móviles de 1 250 a 1 756 líneas mezclan interfaz, acceso a datos y estilos
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** confirmado
- **Evidencia:** `lava-rapido-mobile/src/features/reservations/screens/ReservationScreen.tsx:102 (1 756 líneas) y lava-rapido-mobile/src/features/operator/screens/OperatorProfileScreen.tsx:91 (1 729 líneas)`
- **Por qué importa:** El criterio del SDLC OS es 300 líneas por archivo; estas pantallas llaman a servicios o a api.get dentro del componente, repiten patrones de error y son difíciles de probar y de modificar sin romper otro flujo.
- **Cómo cerrarlo (L):** Dividir por pantalla/sección/formulario, mover datos a hooks de feature y estilos a un archivo propio; empezar por ReservationScreen y OperatorProfileScreen.

### [Alto] H-09 · Ninguno de los dos repositorios tiene CI/CD: 128 + unas 182 pruebas nunca corren solas
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/backend/actions/workflows → total_count 0; gh api repos/propietario/Frontend-lavarapido/actions/runs → total_count 0; sin .github/workflows en ninguna de las 36 y 64 ramas`
- **Por qué importa:** El sistema procesa pagos con Wompi y tiene tres ramas de entorno (develop, qa, main), pero nada compila, prueba ni escanea en cada push o PR. Las 32 ramas HU-NN-dev se integran sin compuerta; el equipo ya tiene la suite escrita y solo falta ejecutarla. Una regresión (por ejemplo en SecurityConfig) llegaría a qa o main sin aviso.
- **Cómo cerrarlo (S):** Crear un workflow por repositorio: backend con setup-java 17, ./mvnw verify y gitleaks; panel con npm ci, typecheck, vitest run y build; móvil con npm ci, typecheck y jest. Exigirlo como check obligatorio en PR hacia develop, qa y main con protección de rama.

### [Medio] H-10 · 34,5 MB de imágenes sin optimizar versionadas en el bundle móvil
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-mobile/src/assets/logo.png (2,3 MB) y lava-rapido-mobile/src/assets/ServicioMotor.png (2,6 MB)`
- **Por qué importa:** 30 archivos superan 500 KB; todo clon y cada build de Expo cargan esos MB, y el APK crece sin necesidad.
- **Cómo cerrarlo (S):** Comprimir (WebP/AVIF, tamaños de pantalla), servir imágenes de servicios desde el backend o un CDN y moverlas con Git LFS si deben quedar.

### [Medio] H-11 · Los errores de carga en móvil se muestran como alerta modal y no como estado de la pantalla con reintento
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-mobile/src/features/reservations/screens/ReservationScreen.tsx:300`
- **Por qué importa:** Principio frontend.state.error del SDLC OS: el fallo debe ser un estado renderizado con acción siguiente. Tras cerrar la alerta, la pantalla queda como 'sin vehículos' y el usuario no sabe si es un fallo temporal; en el admin ya existe un reintento (RequireAdmin.tsx).
- **Cómo cerrarlo (M):** Agregar estado de error con botón Reintentar en las pantallas móviles que cargan datos.

### [Medio] H-12 · El panel web permite registrar y entrar a cuentas que no pueden hacer nada y las deja en la portada
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-admin/src/features/auth/components/LoginForm/LoginForm.tsx:51 y lava-rapido-admin/src/router/AccessDeniedPage.tsx:5`
- **Por qué importa:** El admin web expone /register (registro para usuarios en Lava Rápido móvil) y login a cualquier rol; un usuario o operador queda en la portada o en 'Acceso denegado' sin camino a la app móvil, su única opción real. Es un callejón sin salida del flujo de entrada.
- **Cómo cerrarlo (S):** Redirigir a cuentas no ADMIN a una pantalla que indique usar la app móvil (con enlace de descarga) o retirar el registro del panel.

### [Medio] H-13 · La documentación del equipo no vive en el repositorio (solo en Drive)
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md y PROYECTOS-FICHA-3145555.md (declaración del equipo: Documentacion = carpeta de Drive)`
- **Por qué importa:** Los repos no tienen docs/, diagramas, ADR ni especificación: quien mantenga el código no encuentra la documentación junto a él y el evaluador no pudo leerla.
- **Cómo cerrarlo (M):** Copiar al repositorio (docs/) la documentación vigente: arquitectura, modelo de datos, API y HU, con enlaces desde el README.

### [Medio] H-14 · Los repositorios no declaran problema, usuarios, alcance, indicadores de éxito ni historias con criterios de aceptación
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md (frontend, solo estructura e instalación) y ramas origin/HU-01-dev a origin/HU-62-dev sin enunciado asociado`
- **Por qué importa:** Sin al menos 3 KPI medibles ni 3 historias Must con 2 criterios cada una no se puede decir si el producto cumple su objetivo; las ramas HU no se ubican en pantallas o endpoints. (La carpeta de Drive no pudo leerse; esto es lo que el repositorio muestra.)
- **Cómo cerrarlo (M):** Agregar docs/producto.md con problema, usuarios (cliente, operador, administrador), alcance MVP, KPI y una tabla HU, criterios, pantalla y endpoint.

### [Medio] H-15 · Se borró la documentación versionada del backend en lugar de actualizarla
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md; commits 8a933c7 (2026-08-12) y e38afcb (2026-09-30) eliminan docs/BACKEND.md, docs/RESERVAS_FRONTEND.md, docs/PAGOS_FRONTEND.md, WOMPI_FRONTEND_CONTRACT.md y BACKEND_STATUS.md`
- **Por qué importa:** Los contratos de reservas y pagos que consume el frontend dejaron de estar escritos en el repositorio justo cuando se agregó Wompi.
- **Cómo cerrarlo (M):** Restaurar y actualizar los contratos (o publicar el OpenAPI) y mantenerlos en el mismo PR que cambia la API.

### [Medio] H-16 · Pull Requests sin ninguna revisión: 103 PR, todos fusionados por su propio autor
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/backend/pulls/36 (cuerpo vacío, 0 reviews) y repos/propietario/Frontend-lavarapido/pulls/60`
- **Por qué importa:** Las PR existen por historia pero no cumplen su función de control: 0 revisiones, 0 comentarios y cuerpos vacíos; los dos integrantes no se revisan entre sí, incluido código de pagos y seguridad.
- **Cómo cerrarlo (S):** Exigir una aprobación del otro integrante (protección de rama), usar plantilla de PR con historia y criterios de aceptación.

### [Medio] H-17 · Sin issues ni tablero: la planeación existe solo como nombres de rama HU-nn
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/backend/issues (0) y graphql projectsV2 de ambas cuentas (vacío)`
- **Por qué importa:** Decenas de historias de usuario no tienen enunciado, responsable ni estado visibles; no se puede medir avance ni trazar requisitos a código.
- **Cómo cerrarlo (S):** Crear issues HU-nn con criterios de aceptación y un Project, y enlazar cada PR a su issue.

### [Medio] H-18 · Historial del frontend reiniciado: 92 archivos entran en un solo commit y el repositorio anterior no se conserva
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md y git show --stat c7cba5d0d0 (92 archivos, 10 815 líneas, 2026-05-07)`
- **Por qué importa:** El mensaje admite que el código se movió a otro repositorio por malas prácticas; se pierde la autoría y el rastro previo, y el 25-ago otro grupo de 81 archivos se agregó en una carpeta mal nombrada (lava-rapido-adminn) y se renombró.
- **Cómo cerrarlo (S):** Documentar el origen del código movido y enlazar el repositorio anterior; evitar commits masivos de reubicación sin mensaje descriptivo.

### [Medio] H-19 · Código cliente huérfano: servicios del móvil que llaman a rutas que el backend no tiene (RF2/RF7/RF8 sin implementar)
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/Frontend-lavarapido:lava-rapido-mobile/src/services/locationService.ts:6; propietario/Frontend-lavarapido:lava-rapido-mobile/src/services/orderService.ts:6`
- **Por qué importa:** orderService.ts y locationService.ts (rutas /orders, /orders/history, /orders/{id}/receipt, /operators/{id}/location y un WebSocket a wss://api.lavarapido.com/tracking) no tienen contraparte en el backend ni son importados por ninguna pantalla; aparentan funciones (seguimiento en tiempo real, comprobante) que el sistema no tiene. Del lado contrario, /api/auditoria y /api/log-errores no tienen pantalla en el admin.
- **Cómo cerrarlo (S):** Eliminar los dos archivos o implementar las funciones; decidir si auditoría y log de errores tendrán pantalla en el panel admin o se retiran de la superficie pública.

### [Medio] H-20 · El .env.example no lista las variables que el compose exige (Wompi, correo, URL del frontend, CORS)
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/.env.example:1 contra backend-vehicular/docker-compose.yml:49-60`
- **Por qué importa:** docker-compose up aborta pidiendo WOMPI_PUBLIC_KEY aunque el aprendiz copió el ejemplo; el correo y CORS en producción tampoco se documentan.
- **Cómo cerrarlo (S):** Completar .env.example con todas las variables (sin valores) y una breve explicación de cada una; añadir GOOGLE_MAPS_ANDROID_API_KEY al ejemplo móvil.

### [Medio] H-21 · Llamadas HTTP a Wompi dentro de @Transactional y sin tiempos de espera
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/pagos/service/PagoService.java:211; backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/pagos/service/WompiTransactionClientImpl.java:29`
- **Por qué importa:** verificar() y reconciliar() abren transacción y consultan a Wompi dentro de ella (PagoService.java:174 y :211) con un RestClient.create sin connect/read timeout. Si Wompi se demora, cada petición retiene una conexión del pool de PostgreSQL y el pool se agota. Se reconoce que el servidor consulta antes de tomar los bloqueos FOR UPDATE, lo que limita el daño.
- **Cómo cerrarlo (S):** Configurar timeouts en el cliente (RestClient con request factory) y mover la consulta remota fuera de la transacción (consultar primero, abrir una transacción corta para aplicar el resultado).

### [Medio] H-23 · Reglas de negocio incrustadas y copiadas en varios servicios
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/reservas/entity/Reserva.java:102 y backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/reservas/service/ReservaService.java:259`
- **Por qué importa:** El horario 06:00-20:00 está en tres sitios, y obtenerUsuarioAutenticado()/esAdmin() se repiten en PagoService, ReservaService y VehiculoService; cambiar la política exige tocar varios archivos y es fácil que diverjan.
- **Cómo cerrarlo (S):** Extraer constantes configurables (propiedades) y mover el usuario autenticado a AccountAccessService.

### [Medio] H-24 · Código muerto y duplicado: 8 archivos vacíos, slices Redux sin store y alias a carpetas inexistentes
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-mobile/src/features/auth/slice.ts:1 y lava-rapido-mobile/tsconfig.json:9-14`
- **Por qué importa:** El README promete Redux y store/ pero la sesión se maneja con useState en App.tsx; los archivos vacíos y duplicados confunden a quien busca la fuente de verdad (useI18n y useTheme están en dos lugares).
- **Cómo cerrarlo (S):** Eliminar hooks vacíos y slices sin uso, o conectarlos; quitar aliases muertos y unificar validators.

### [Medio] H-25 · Login y recuperación de cuenta sin límite de intentos ni bloqueo
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/users/service/UserService.java:78`
- **Por qué importa:** Con git grep (rate limit, bucket4j, lockout, throttle) no aparece ningún control en src/main ni en el pom.xml. /api/users/login y /api/auth/forgot-password son públicos (SecurityConfig.java:94-99) y la política de contraseñas solo exige 8 caracteres (PasswordRules.java). Un atacante puede probar contraseñas sin freno contra cualquier cuenta, incluidas las dos de administración, o inundar de correos la cuenta del titular.
- **Cómo cerrarlo (M):** Añadir un limitador por IP y por correo (Bucket4j o filtro propio) en login y forgot-password, bloqueo temporal tras N fallos con registro en auditoría, y subir la política a 10+ caracteres con lista de contraseñas comunes. Cubrirlo con pruebas negativas.

### [Medio] H-26 · Swagger público fuera de prod y detalle de salud público en prod
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/shared/config/SecurityConfig.java:101`
- **Por qué importa:** SecurityConfig deja permitAll /swagger-ui y /v3/api-docs (líneas 101-105) y solo application-prod.properties los apaga (líneas 25-26); docker-compose.yml arranca con el perfil docker, que publica el mapa completo de la API. En prod, /actuator/health es público (línea 110) con show-details y show-components en always (application-prod.properties:29-30), añadido en 08d11da como cambio «temporal» que nunca se revirtió; cualquiera ve el estado de la BD y del correo. Ayuda al reconocimiento previo a un ataque.
- **Cómo cerrarlo (S):** Poner springdoc.*.enabled=false en el perfil docker y condicionar las reglas permitAll de Swagger a un perfil dev; en prod usar show-details=never o when-authorized (ADMIN) y dejar la sonda pública solo con el estado agregado.

### [Medio] H-27 · El JWT del administrador se guarda en sessionStorage
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-admin/src/store/authStore.ts:49`
- **Por qué importa:** authStore.ts guarda el token y el usuario en sessionStorage (líneas 49-50) y api.ts lo lee de ahí (api.ts:24). Cualquier XSS, incluida una dependencia de terceros comprometida, puede leerlo; con la clave de H-B01 filtrada el riesgo se suma. La guía de seguridad de API de A12 lo marca como salida prohibida. Atenuantes: pestaña acotada, el código no usa innerHTML y la app móvil mantiene el token solo en memoria (api.ts, variable token).
- **Cómo cerrarlo (M):** Preferir una cookie HttpOnly, Secure y SameSite emitida por el backend (con protección CSRF) o, si se mantiene el Bearer, reducir la vida del token con refresh rotatorio, y aplicar una Content-Security-Policy estricta en el hosting del panel.

### [Medio] H-28 · Tratamiento de datos personales incompleto frente a la Ley 1581
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-admin/src/features/auth/pages/RegisterPage/legalContent.ts:15`
- **Por qué importa:** El sistema recoge nombre, correo, teléfono y número de documento. La política no identifica al responsable ni su canal de contacto, no describe los derechos de acceso, rectificación y supresión ni el procedimiento para ejercerlos, y no cita la ley; los consentimientos solo existen en el registro web, no en el móvil (RegisterScreen.tsx), y el backend no guarda constancia de la aceptación (UserRegistrationDTO.java no tiene el campo). No hay forma de acreditar el consentimiento de cada titular.
- **Cómo cerrarlo (M):** Completar la política (responsable, finalidad, derechos, canal y plazo, referencia a la Ley 1581 de 2012), mostrar los mismos consentimientos en el registro móvil, añadir al backend campos de consentimiento con fecha y versión de la política, y un procedimiento de supresión de cuenta.

### [Medio] H-29 · La matriz de autorización de SecurityConfig y la capa de BD no tienen pruebas automáticas
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/src/test/scripts/local-http-roles.ps1`
- **Por qué importa:** Con git grep no hay @SpringBootTest, @WebMvcTest con seguridad, @DataJpaTest ni Testcontainers. Las pruebas de controlador usan standaloneSetup y por tanto no pasan por la cadena de seguridad: la regla que más protege el sistema (qué rol llama a cada ruta, SecurityConfig.java:123-320) solo se comprueba con un script manual contra una base desechable. Tampoco hay pruebas de MarcaService, ServicioService, AsignacionService, CalificacionService ni AuditoriaService. El criterio de A09 exige casos trazados a criterios de aceptación y pruebas negativas de acceso no autorizado en el borde.
- **Cómo cerrarlo (M):** Añadir una clase @SpringBootTest o @WebMvcTest(import SecurityConfig) con MockMvc que recorra la matriz ruta x rol (anónimo, USER, OPERATOR, ADMIN) esperando 401/403/200, más un @DataJpaTest con PostgreSQL en Testcontainers para ReservaRepository.findSolapamientosPorVehiculo. Medir cobertura con JaCoCo.

### [Medio] H-30 · Sin cobertura medida ni pruebas e2e; el flujo de pago solo se prueba con simulacros
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-mobile/jest.config.js`
- **Por qué importa:** Ni vitest.config.ts ni jest.config.js configuran cobertura, no hay herramienta e2e (Playwright, Detox, Maestro) y el jest.config.js limita las pruebas a una lista de carpetas, por lo que una prueba nueva fuera de ellas no se ejecutaría. Para el criterio de A09 el producto no queda verificado de extremo a extremo: login, reserva y pago con Wompi nunca se prueban contra el backend.
- **Cómo cerrarlo (M):** Activar coverage (v8 en vitest y --coverage en jest) con umbral mínimo, cambiar el testMatch por un patrón general (**/*.test.ts(x)) y añadir al menos un recorrido e2e contra el backend en un entorno de pruebas.

### [Medio] H-31 · Sin release ni rollback repetibles: imagen «:local», versión SNAPSHOT, sin tags ni plan de despliegue
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/docker-compose.yml`
- **Por qué importa:** La imagen se llama lava-rapido-backend:local, el pom declara 0.0.1-SNAPSHOT (pom.xml:13), el repositorio no tiene tags ni releases (git tag vacío, gh api releases → 0) y el README es «# backend». No hay compose de producción, ni documento de despliegue o rollback, ni URL declarada (T-7.4). Si un despliegue falla no existe una versión anterior identificable a la que volver; el Dockerfile además corre como root y no define HEALTHCHECK, de modo que el orquestador no sabe si el contenedor está sano.
- **Cómo cerrarlo (M):** Versionar con tags semánticos, publicar la imagen versionada en GHCR desde el CI, añadir USER no root y HEALTHCHECK al Dockerfile, crear un compose de producción y un documento corto de despliegue y rollback (qué imagen se vuelve a levantar y cómo) en el README.

### [Medio] H-32 · Nomenclatura física mezclada: inglés y español, estados en distinta casa
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-40
- **Evidencia:** `backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/users/entity/User.java:17; backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/asignaciones/enums/EstadoAsignacion.java`
- **Por qué importa:** Tablas users, roles y user_roles (inglés) junto a reservas, vehiculos y pagos (español); columnas first_name y user_id junto a fk_id_usuario e id_reserva; estados EstadoReserva en MAYÚSCULAS y EstadoPago y EstadoAsignacion en minúsculas (esta última con un converter propio solo para adaptarse). Los principios de datos del SDLC OS exigen un solo idioma, snake_case y singular.
- **Cómo cerrarlo (M):** Documentar y fijar la convención y migrar solo lo barato (estados de asignación y pago a un mismo formato); no renombrar tablas en producción sin migración.

### [Medio] H-33 · No hay contrato OpenAPI publicado: springdoc sin anotaciones y deshabilitado en producción
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/pom.xml:56; backend-vehicular/src/main/resources/application-prod.properties:25`
- **Por qué importa:** Los clientes (web y móvil) copian a mano los DTO. Sin un openapi.json versionado nadie puede verificar el contrato antes de desplegar; la divergencia ya existe (TipoVehiculo del admin, respuestas de texto plano en /auth).
- **Cómo cerrarlo (S):** Anotar los controladores con @Operation/@Schema mínimos, exportar el openapi.json al repo (o publicarlo en un perfil protegido) y generar o validar los types de los clientes contra él.

### [Medio] H-34 · Sin versionado de la API y con listados sin paginar
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/reservas/controller/ReservaController.java:36; backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/reservas/service/ReservaService.java:156`
- **Por qué importa:** GET /api/reservas ejecuta findAll y devuelve todas las reservas de todos los clientes en una sola respuesta; lo mismo con vehículos, marcas y operadores. Con datos reales el panel admin se degrada y no hay forma de evolucionar el contrato sin romper la app móvil instalada (todas las rutas cuelgan de /api sin versión).
- **Cómo cerrarlo (M):** Paginar (Pageable) los listados del admin con filtros por estado y fecha, y prefijar /api/v1 antes de la próxima publicación de la app móvil.

### [Bajo] H-35 · La sesión móvil vive solo en memoria: cada apertura exige iniciar sesión de nuevo
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-mobile/src/services/api.ts:19 y lava-rapido-mobile/App.tsx:75`
- **Por qué importa:** Sin persistencia segura (no hay SecureStore) un cliente que cierra la app debe volver a escribir correo y contraseña; es seguro, pero fricciona el flujo principal de reservar y pagar un lavado.
- **Cómo cerrarlo (M):** Guardar la sesión en almacenamiento seguro del dispositivo (expo-secure-store) y restaurarla al abrir.

### [Bajo] H-36 · Mensajes de commit que no describen el cambio
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md y git show --stat 68cb790 y a1f0ad8171 en Frontend-lavarapido; mensajes 'backen', 'feact', 'efactor' en ambos`
- **Por qué importa:** 68cb790 habla de Jackson/pagos y modifica solo archivos del frontend; a1f0ad8 se llama 'improve mobile layout' pero agrega 81 archivos; las erratas rompen el parseo de Conventional Commits.
- **Cómo cerrarlo (S):** Revisar mensajes antes del PR y adoptar commitlint con un hook.

### [Bajo] H-37 · Tipo TipoVehiculo del admin no coincide con el enum del backend
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-admin/src/features/dashboard/types/index.ts:17`
- **Por qué importa:** El admin declara CARRO|MOTO|CAMIONETA|OTRO (con el comentario 'confirmar valores reales') y el backend acepta CARRO, CAMIONETA, MOTO, MOTOCARRO, FURGONETA y PESADO. Hoy solo se muestra como texto, pero createVehiculo/updateVehiculo del admin enviarían 'OTRO' (rechazado con 400) en cuanto se use el formulario.
- **Cómo cerrarlo (S):** Alinear el union type con el enum real (o generarlo del OpenAPI) y borrar el comentario pendiente; retirar createVehiculo/updateVehiculo si el admin no los usa.

### [Bajo] H-38 · OperadorService escribe directamente en las tablas de roles de usuarios
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/operadores/service/OperadorService.java:117`
- **Por qué importa:** El alta de operador cambia roles (setRole) con UserRoleRepository y RoleRepository en vez de llamar a un servicio de identidad; la regla de quién es operador queda repartida entre dos módulos y la baja en bloque (desactivar-todos) cambia el rol de cada usuario desde el módulo equivocado.
- **Cómo cerrarlo (S):** Exponer en el módulo de usuarios una operación asignarRol/revocarRol y que operadores la consuma.

### [Bajo] H-39 · Capa de servicios duplicada en el móvil (dos vehicleService y dos modelos Vehicle)
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-mobile/src/features/vehicles/services/vehicleService.ts:7; lava-rapido-mobile/src/services/vehicleService.ts:39`
- **Por qué importa:** ReservationScreen usa features/vehicles/services/vehicleService (solo getMyVehicles y create) y AddVehicleScreen y MyVehiclesScreen usan services/vehicleService (getMine, update, changeStatus); cada uno con su tipo Vehicle y un brandService paralelo. Un cambio de contrato exige editar dos sitios y ya hay dos formas de nombrar lo mismo.
- **Cómo cerrarlo (S):** Conservar un solo vehicleService y un solo tipo Vehicle, y eliminar brandService o vehicleService.getActiveBrands (uno de los dos).

### [Bajo] H-41 · Código comprimido en líneas de más de mil caracteres
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-admin/src/features/dashboard/pages/TurnosPage/TurnosPage.tsx:36 (1 574 caracteres) y lava-rapido-mobile/src/features/profile/screens/ServiceDetailsScreen.tsx:1`
- **Por qué importa:** Dificulta la revisión de PR y el diff línea a línea; en TurnosPage una sola línea contiene la carga completa con su manejo de error. En el backend el constructor de ReservaService está en una línea.
- **Cómo cerrarlo (S):** Aplicar Prettier/ESLint en CI y reformatear estos archivos.

### [Bajo] H-42 · Contraseña de prueba fija en un script versionado
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/src/test/scripts/local-http-roles.ps1:34`
- **Por qué importa:** El script fija una contraseña de prueba con valor ««redactado»» para registrar cuentas contra una base desechable. No es un secreto de producción, pero establece el mal hábito de dejar contraseñas en el repositorio y si alguien lo apunta a un entorno real crea cuentas con una contraseña conocida.
- **Cómo cerrarlo (S):** Generar la contraseña aleatoriamente al inicio del script, como ya se hace con el correo, o leerla de una variable de entorno como LOCAL_TEST_ADMIN_PASSWORD.

### [Bajo] H-43 · El mapa móvil carga Leaflet desde unpkg sin integridad ni versión congelada en el repositorio
- **Repositorio:** `propietario/Frontend-lavarapido`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `lava-rapido-mobile/src/features/map/data/mapHtml.ts:36`
- **Por qué importa:** El HTML del WebView carga leaflet.css y leaflet.js desde unpkg.com (líneas 36 y 46) sin atributos integrity ni crossorigin. Si el CDN o el paquete se comprometen, se ejecuta código ajeno dentro de la app de clientes y operadores.
- **Cómo cerrarlo (S):** Empaquetar Leaflet como dependencia local (ya existe en el panel) o añadir integrity con hash SRI a ambas etiquetas.

### [Bajo] H-44 · Índices de las llaves foráneas declarados solo en 2 de 18 entidades (inferido)
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/reservas/entity/Reserva.java:18`
- **Por qué importa:** Solo Reserva y PagoIntento declaran @Index; vehiculos.fk_id_usuario, asignaciones.fk_id_operador, calificaciones.fk_id_usuario y otras FK no los declaran en el modelo. Como el DDL real no está en el repo, no se puede confirmar si la base los tiene.
- **Cómo cerrarlo (S):** Revisar el esquema real con EXPLAIN en las consultas del panel y agregar índices a las FK usadas en filtros (mis-vehiculos, mis-asignaciones, notificaciones por usuario).

### [Bajo] H-45 · Convenciones REST y formatos de respuesta inconsistentes entre módulos
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/auth/controller/PasswordResetController.java:50; backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/vehiculos/controller/VehiculoController.java:62; backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/operadores/controller/OperadorController.java:46`
- **Por qué importa:** El estado se cambia por @RequestParam en reservas, vehículos, servicios y marcas, pero por cuerpo JSON en operadores y asignaciones; /auth responde texto plano mientras el resto devuelve JSON con la clave error; rutas con verbos (/verificar, /reconciliar, /login). Cada cliente debe recordar la excepción de cada módulo.
- **Cómo cerrarlo (S):** Fijar una convención (cuerpo JSON para cambios de estado, JSON en todas las respuestas, verbos solo donde no haya recurso) y aplicarla en la próxima revisión del contrato.

### [Bajo] H-46 · Dos endpoints reciben el cuerpo sin @Valid
- **Repositorio:** `propietario/backend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/pagos/controller/PagoController.java:45; backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/notificaciones/controller/NotificacionController.java:35`
- **Por qué importa:** VerificarTransaccionRequest y DispositivoRequest no pasan por Bean Validation; el registro de dispositivo guarda instalacionId y el identificador de push sin límites de longitud en el borde del servicio y la verificación de pagos duplica validaciones a mano dentro de PagoService.
- **Cómo cerrarlo (S):** Anotar los records con @NotBlank/@Size y usar @Valid en el controlador, igual que en el resto de DTO.

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 68.8 |
| D2 | Reproducibilidad | 40.0 |
| D3 | Arquitectura y congruencia | 50.0 |
| D4 | Calidad de código | 59.1 |
| D5 | Seguridad | 78.9 |
| D6 | Pruebas | 62.5 |
| D7 | DevOps y despliegue | 22.7 |
| D8 | Datos | 20.0 |
| D9 | API y contratos | 45.0 |
| D10 | Frontend y móvil | 70.8 |
| D11 | IoT y firmware | — |
| D12 | Documentación y trazabilidad | 50.0 |
| D13 | Proceso y colaboración | 68.4 |
| D14 | Extremo a extremo | 75.0 |

## Lo que está bien

- Contratos cliente-servidor alineados campo a campo en los flujos críticos (`lava-rapido-mobile/src/services/paymentService.ts:6 = backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/pagos/dto/PagoWidgetResponseDTO.java; lava-rapido-mobile/src/features/reservations/types/reservation.types.ts:13 = reservas/dto/ReservaRequestDTO.java; assignmentService.ts y EstadoAsignacion.java usan los mismos estados en minúsculas.`)
- Máquina de estados de la reserva con validación de solapamientos, horario de operación y propagación desde la asignación (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/reservas/service/ReservaService.java:97 (solapamientos), :260 (06:00-20:00), :281-301 (transiciones); asignaciones/service/AsignacionService.java:166-186.`)
- Pagos con Wompi diseñados con cuidado: firma del webhook, verificación servidor-servidor, bloqueos pesimistas, un pago por reserva e intentos idempotentes (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/pagos/controller/PagoController.java:50-56; pagos/service/PagoService.java:211-220; pagos/entity/PagoIntento.java (unique por referencia, 2 índices); pagos/entity/Pago.java (fk_id_reserva unique).`)
- Backend modular por funcionalidad (controller, dto, entity, repository, service) con manejador global de errores (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/shared/exception/GlobalExceptionHandler.java:30-171; 16 paquetes bajo backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/.`)
- Hibernate en modo validate y configuración por perfiles (dev, docker, prod) con variables de entorno (`backend-vehicular/src/main/resources/application.properties:17; backend-vehicular/src/main/resources/application-prod.properties:1-30; backend-vehicular/.env.example.`)
- URL base del móvil configurable y validada (HTTPS obligatorio fuera de desarrollo) y del admin por VITE_API_URL (`lava-rapido-mobile/src/services/apiUrl.ts:1-22; lava-rapido-mobile/.env.example; lava-rapido-admin/.env.example.`)
- Las ramas HU-xx-dev están integradas en develop: ninguna rama tiene commits que develop no tenga (`git rev-list --count c66ab99de7..origin/<rama> = 0 para las 36 ramas del backend; igual para las 64 ramas del frontend contra 9ebdc812c1.`)
- Autenticación JWT verificada de verdad en el servidor y rol leído de la BD en cada petición (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/security/JwtAuthenticationFilter.java:77`)
- Autorización en dos capas: matriz por rol en SecurityConfig y comprobación de propietario en los servicios (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/reservas/service/ReservaService.java:146`)
- Webhook de Wompi con firma verificada en tiempo constante y rechazo con 401 (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/pagos/service/WompiSignatureService.java:73`)
- Recuperación de contraseña bien diseñada: token aleatorio, hasheado, de un solo uso, con expiración y respuesta que no revela si el correo existe (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/auth/service/PasswordResetService.java:51`)
- Arranque a prueba de fallos en producción: aborta sin credenciales, HTTPS, CORS explícito ni llaves de Wompi (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/shared/config/ProductionReadiness.java:41`)
- Errores 5xx sin fuga de detalle interno y CORS con orígenes explícitos y sin credenciales (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/shared/exception/GlobalExceptionHandler.java:162`)
- Suite de backend con 128 pruebas y 404 aserciones, con casos negativos de seguridad (token legado, cuenta inactiva, correo cambiado) (`backend-vehicular/src/test/java/com/lavarapido/backend_vehicular/security/JwtAuthenticationFilterTest.java:62`)
- Frontend sin secretos en árbol ni historial, con .env.example y .env ignorado en panel y móvil (`lava-rapido-mobile/.env.example`)
- La app móvil exige URL de API con HTTPS fuera de desarrollo y mantiene el token solo en memoria, con manejo de sesión invalidada y prueba (`lava-rapido-mobile/src/services/apiUrl.ts`)
- 52 archivos de prueba en el frontend con unas 583 aserciones, incluidas guardias de ruta, seguridad de la API y recuperación de pagos pendientes (`lava-rapido-admin/src/router/RequireAdmin.test.tsx`)
- Dockerfile multi-etapa con .dockerignore que excluye .env y credenciales locales, y compose que exige variables con ${VAR:?} (`backend-vehicular/.dockerignore`)
- Backend modular por dominio con capas claras y controladores delgados (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/pagos/controller/PagoController.java:25`)
- Manejo de errores centralizado con 21 manejadores y excepciones de dominio (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/shared/exception/GlobalExceptionHandler.java:1`)
- Configuración externalizada por perfiles y variables; el build de producción del admin se niega a compilar sin HTTPS (`lava-rapido-admin/vite.config.ts:9`)
- La autenticación del admin se verifica en el servidor al entrar a cada ruta privada y ofrece reintento y acceso denegado (`lava-rapido-admin/src/router/RequireAdmin.tsx:19`)
- Accesibilidad y estados de carga en las pantallas móviles revisadas, con interfaz en 4 idiomas y tema oscuro (`lava-rapido-mobile/src/features/reservations/screens/ReservationScreen.tsx:1049`)
- Flujo de ramas por historia con 103 PR integrados a develop y reparto equilibrado de commits (56 y 56) (`gh api repos/propietario/backend/pulls y git shortlog -sne --all --no-merges`)
- Dockerfile multi-etapa y build reproducible con wrapper de Maven (`backend-vehicular/Dockerfile:5`)
- Aprovisionamiento seguro del administrador (sin endpoint público y dentro de una transacción) (`backend-vehicular/src/main/java/com/lavarapido/backend_vehicular/security/OwnerProvisioningTool.java:19`)

## Lo que no se pudo verificar

- Que las tablas, restricciones, índices y semillas del esquema físico existan y coincidan con las 18 entidades JPA — El DDL/Liquibase está en el repositorio 'lavarapido-base-datos', no declarado por el equipo y no encontrado en las cuentas Integrante ni Integrante 2; no se construyen hallazgos sobre él. Verificarlo exigiría levantar la base (prohibido ejecutar).
- T-3.1, T-3.4 y T-3.6 contra la documentación del equipo — Documentación en Drive no accesible desde el repositorio; el backend borró sus docs en e38afcb y el README del backend es una línea. Falta registrar el hallazgo medio de D12 (la documentación no vive en el repositorio), que corresponde al especialista C.
- T-14.3 (flujo principal contra el despliegue) — El equipo no declara URL de despliegue; el perfil prod usa el puerto 10000 pero no hay URL alguna en los repos ni en la ficha.
- Comportamiento en ejecución de los 5 flujos (compilación, arranque, respuesta real de Wompi sandbox) — No se ejecuta el código de los aprendices; los flujos se evaluaron por trazado estático de rutas, DTO, tipos y entidades.
- Que el App Link de recuperación de contraseña funcione en dispositivo (assetlinks y dominio único para web y móvil) — Exige un despliegue real con dominio y un APK firmado; app.config.js y assetlinks.json solo se leyeron.
- Si la contraseña de la base, la clave JWT y la clave de Gmail expuestas en main, qa y el historial ya fueron rotadas — Comprobarlo exigiría probar las credenciales contra servicios reales, lo que está fuera de las restricciones de solo lectura.
- Que los criterios de aceptación de las historias HU-01 a HU-32 estén cubiertos por pruebas — Los criterios de aceptación están en la documentación de Drive, que no es accesible desde el repositorio; solo se pudo comprobar que existen ramas HU-NN-dev y pruebas de comportamiento.
- Vulnerabilidades conocidas en las dependencias (npm audit, OWASP Dependency-Check) — Exigiría ejecutar herramientas sobre el código de los aprendices; se juzgó solo por versión en pom.xml y package.json.
- Estado real del despliegue en línea y respuesta del endpoint de salud — El equipo no declara ninguna URL de despliegue, así que no se hizo el GET de solo lectura.
- Repositorio de base de datos (Liquibase) al que remiten application.properties, docker-compose.yml y .env.example del backend — No está declarado por el equipo (el enlace de «Base de datos» apunta al repositorio del frontend); su seguridad y sus pruebas no se evaluaron.
- Un comando de búsqueda con expresión regular sobre src/test/scripts fue rechazado por el guardia de gobernanza — No se insistió con esa forma; se repitió la consulta con una búsqueda de cadena fija (git grep -F) para ubicar la contraseña de prueba de local-http-roles.ps1 (H-B11).
- Documentación en Drive (arquitectura, HU, modelo de datos, API) — carpeta de Drive no accesible desde el repositorio; R-12.1, T-12.3 y T-12.4 quedan NV
- Que el admin y la app móvil compilen y arranquen (R-10.1 evaluado solo por lectura de configuración) — exigiría npm install / expo, prohibido por las reglas del briefing
- Muestreo de calidad de código (D4) — se leyeron con profundidad ReservationScreen.tsx (1 756 líneas), OperatorProfileScreen.tsx (1 729) y, del backend, PagoService.java (504), ReservaService.java y la capa de controladores; el resto se midió con grep y conteos
- Colaboradores y permisos de los repositorios — gh api devuelve 403 sin permiso de push; el acceso mutuo se infiere por los PR fusionados
- Posible segunda cuenta: Integrante 3 (noreply de Integrante, 1 commit) frente a Integrante 1 (correo con formato inválido) — se trata como cuenta separada; posible segunda cuenta de Integrante 1, sin confirmar, y no cambia ningún porcentaje
- Repositorio de base de datos (lavarapido-base-datos) que el backend cita en comentarios — no fue declarado por el equipo ni se encontró en las cuentas; no se evalúa ni se hacen hallazgos sobre él
- Proyectos privados de GitHub o tablero externo — solo se pueden ver los Projects públicos vía API
- Despliegue en línea — el equipo no declara URL de despliegue, no se hizo ningún GET
