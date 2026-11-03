# Equipo 6 · One Language — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 53/100 · Juicio D**

## Veredicto

One Language tiene un backend Spring Boot ordenado y probado y clientes web y móvil funcionales y desplegados en https://onelanguage.tech; cuatro de los cinco flujos declarados están completos de punta a punta. El flujo central, traducir una seña en vivo con la cámara, queda roto al reproducirlo desde los repositorios: el modelo de reconocimiento no está en ninguna rama ni release (crítico), y el puerto por defecto de la IA (8000) no coincide con el de los clientes (8001), un defecto de severidad media; el sitio en vivo responde porque se despliega desde dev con piezas que no están en los repos. El hallazgo bloqueante es que la contraseña de PostgreSQL y una clave JWT siguen en claro en el historial público sin evidencia de rotación; además hay 2 críticos en total y 6 altos: el trabajo está en dev y develop (main y qa están vacíos o con solo andamiaje), ningún repo tiene CI y el frontend y la IA no tienen pruebas. El puntaje es 53 y el juicio D, a 17 puntos del umbral de 70; las dos primeras acciones del plan (rotar credenciales y publicar el modelo) son de esfuerzo bajo y resuelven el bloqueante y los dos críticos.

## Plan para cerrar las brechas

1. **Rotar la contraseña de PostgreSQL y la clave JWT expuestas, retirarlas de la documentación y de main/qa, y decidir si se reescribe el historial público.** (esfuerzo S) — se cierra cuando: Las credenciales antiguas ya no funcionan en ningún entorno; git grep del valor antiguo en dev, main y qa no devuelve coincidencias; los despliegues usan los valores nuevos desde variables de entorno.
2. **Publicar el paquete del modelo de reconocimiento (release de GitHub, Git LFS o descarga documentada con checksum) y documentar cómo colocarlo.** (esfuerzo S) — se cierra cuando: Desde un clon limpio, siguiendo solo el README, docker compose up deja el servicio de IA en estado saludable y /health responde 200 con el modelo cargado.
3. **Promover el trabajo de dev/develop a qa y main mediante PR (Database incluida, cuyo main y qa solo tienen andamiaje) y etiquetar un primer release en los cuatro repos.** (esfuerzo S) — se cierra cuando: git rev-list --count origin/main..origin/dev (develop en AI) da 0 en los cuatro repos; existe al menos un tag o release por repo.
4. **Crear CI en los cuatro repos (build, lint, pruebas) y, en este orden, añadir pruebas al frontend y a la IA (hoy no tienen ninguna), luego a controladores y reglas de seguridad del backend y de migraciones desde cero en Database.** (esfuerzo L) — se cierra cuando: Cada repo tiene un workflow con ejecuciones recientes en verde en la API de Actions; el frontend y la IA tienen pruebas con afirmaciones reales y un job aplica las migraciones y los rollbacks en una base vacía.
5. **Unificar el puerto por defecto del servicio de IA (8000 u 8001) en compose, proxy de Vite, network.ts, .env.example y README de los repos, de modo que el flujo de traducción en vivo conecte sin configuración extra.** (esfuerzo S) — se cierra cuando: git grep de 8000 y 8001 muestra un único puerto en servicio y clientes; el flujo Traducir una seña en vivo conecta por el WebSocket sin mostrar model_error.
6. **Proteger el WebSocket de reconocimiento (autenticación con el JWT, Origin obligatorio, límites de conexiones, tamaño y tasa) y limpiar dependencias sin uso y con avisos de seguridad.** (esfuerzo M) — se cierra cuando: Una conexión sin token o sin Origin válido es rechazada; requirements.txt no contiene Flask, Celery, Redis ni SQLAlchemy; pip-audit no reporta avisos altos.
7. **Corregir la imagen web del repositorio: enrutar /api y /auth al backend en nginx (hoy lo resuelve un proxy externo), alinear la CSP con el README, ejecutar como usuario no root y añadir healthcheck.** (esfuerzo M) — se cierra cuando: Con el contenedor web, login y registro funcionan sin proxy externo; docker inspect muestra usuario no root y healthcheck en estado healthy.
8. **Endurecer el backend: política de contraseña y longitudes máximas en el servidor, mensajes de login y recuperación no enumerables con límite de peticiones, Swagger y SQL en el log solo en dev, sin printStackTrace, imagen no root con healthcheck.** (esfuerzo M) — se cierra cuando: El registro con contraseña débil o campos largos devuelve 400; login y recuperación devuelven el mismo mensaje exista o no la cuenta; con perfil prod /swagger-ui da 401 o 404; el contenedor corre como no root y su healthcheck pasa.
9. **Mejorar la base de datos: roles y grants de mínimo privilegio, índices en claves foráneas, quitar validCheckSum ANY y completar rollbacks, y retirar columnas sin consumidor.** (esfuerzo M) — se cierra cuando: La app se conecta con un rol sin privilegios de superusuario; la carpeta de índices tiene changesets; ningún changeset usa validCheckSum ANY y todos tienen rollback probado en CI.
10. **Reforzar sesión y privacidad en los clientes: almacenar el token de forma más segura, restaurar la sesión y proteger rutas en móvil, y completar términos y aviso de privacidad conforme a la Ley 1581 de 2012.** (esfuerzo M) — se cierra cuando: El móvil guarda el token en almacenamiento seguro y al reabrir restaura la sesión; las pantallas autenticadas redirigen a login sin token; el aviso de privacidad indica finalidad, derechos del titular y tratamiento del video.
11. **Fortalecer el proceso: activar revisión obligatoria en PR, pasar los repos a una organización con más de un administrador y dejar de reescribir historial.** (esfuerzo S) — se cierra cuando: Los repositorios están en una organización con al menos dos administradores; la protección de rama exige una revisión aprobada; los PR nuevos muestran reviews de un compañero.
12. **Cerrar documentación y calidad: guía conjunta de despliegue, READMEs de backend y base corregidos, documentación de producto en el repo, limpieza de .idea y JAR, estado de carga en formularios, accesibilidad, OpenAPI curado y formato de error uniforme con paginación.** (esfuerzo L) — se cierra cuando: Un README raíz explica cómo levantar los cuatro repos y cada paso funciona en un clon limpio; el repositorio contiene problema, alcance, historias e indicadores; no hay .idea ni JAR versionados; la API publica un OpenAPI versionado con un único formato de error.

## Verificación independiente

Hallazgos confirmados: 4 · matizados: 3 · refutados: 0 · duplicados fusionados: 6.

Confirmé 4 de los 8 hallazgos (H-01, H-02, H-04, H-06) y los 4 PASS (R-5.1 Frontend, R-6.1 Backend, R-2.1 Database, T-13.3); matizo H-03 (cita docker-compose.yml:25 errónea y el modelo sí corre en ai.onelanguage.tech; es el mismo defecto que H-02), H-05 (la imagen no enruta /api, pero el sitio en vivo sí por un proxy externo: medio y no alto), H-07 y H-08 (medio y no alto); ninguno fue refutado por completo. De los 5 flujos, 4 son COMPLETO y 1 ROTO al reproducirlo desde los repos (puerto 8000/8001 y modelo ausente), aunque el despliegue vivo responde. Aportes 41/43 verificados con un único correo por persona; duplicados reales: H-02/H-03/H-39, H-08/H-25, H-07/H-23/H-53, H-29/H-45 y H-37/H-42; los otros 30 pares de la lista solo comparten archivo y describen defectos distintos.

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Completo | Registrarse e iniciar sesion | — |
| Completo | Recuperar la contrasena por correo | — |
| Roto | Traducir una sena en vivo con la camara | Web/mobile hacia el servicio de IA: el paquete del modelo (lsc_sequence_model.keras, lsc_labels.json, lsc_config.json) no esta en ninguna rama ni release (model/ y *.keras estan en .gitignore y el servicio aborta al arrancar si falta, web_service.py:82), y el puerto por defecto del servicio es 8000 mientras el proxy de Vite (web/vite.config.js:28), mobile/src/config/network.ts:4 y mobile/.env.example:4 apuntan a 8001. Con la configuracion por defecto el cliente muestra model_error. |
| Completo | Guardar la traduccion y consultar el historial | — |
| Completo | Configurar accesibilidad y permisos de camara y audio | — |

## Hallazgos

### [Bloqueante] H-01 · La contraseña de PostgreSQL está en claro en dev, main, qa y en todo el historial del repositorio público
- **Repositorio:** `propietario/OneLanguage-Database`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `docker/documentacion.md:38 (también 57, 75 y 184); en main/qa: docker-compose.yml:9,28 y .env.example:3 (git grep origin/main); historial: commits d2e5ad5, 72d431e, e8681b9, 5536326`
- **Por qué importa:** Es una credencial real: el mismo valor (««redactado»») fue el valor por defecto del backend (commit 842bf5d) y el repo es público; main, la rama por defecto, la sirve en el docker-compose.yml. La mudanza a variables de entorno del 2026-09-09 la dejó en la documentación y en main/qa. Quien la copie obtiene acceso a cualquier instancia que la reutilice, y parece una contraseña personal, no un valor de ejemplo.
- **Cómo cerrarlo (S):** 1) Rotar la contraseña en todo entorno que la haya usado. 2) Sustituir los ejemplos de docker/documentacion.md y los de main/qa por marcadores (your_database_password). 3) Reescribir el historial con git filter-repo solo si se decide, sabiendo que lo importante es la rotación. 4) Activar GitHub secret scanning y push protection en la organización.

### [Crítico] H-02 · El paquete del modelo de IA no esta versionado ni publicado: la traduccion en vivo no se puede reproducir desde los repositorios
- **Repositorio:** `propietario/OneLanguage-AI`
- **Lente SDLC OS:** A06 · **Verificación independiente:** confirmado; también reportado como H-39, H-03
- **Evidencia:** `web_service.py:82`
- **Por qué importa:** El servicio de IA lanza RuntimeError al arrancar si falta model/ (web_service.py:82). model/ y *.keras estan en .gitignore (lineas 31 y 35), ninguna de las 6 ramas contiene un modelo, gh api releases devuelve 0 y el README promete descargar un modelo publicado como artefacto de una version. Sin ese paquete la funcion central del producto (traducir senas) no corre en ningun entorno nuevo, ni siquiera en una maquina de la evaluacion.
- **Cómo cerrarlo (S):** Publicar el paquete (modelo, etiquetas y configuracion) como release del repositorio o en un almacenamiento declarado, con version y suma de verificacion, y documentar en el README el comando exacto para obtenerlo. Añadir al arranque un mensaje que diga donde conseguirlo.

### [Crítico] H-04 · Una clave JWT y la contraseña de BD por defecto quedaron en el historial público y no hay evidencia de rotación
- **Repositorio:** `propietario/OneLanguage-Backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `Backend-OneLanguage/src/main/resources/application.properties:30 (HEAD usa variable de entorno); commits 595b1fd (2026-07-01) y 842bf5d (2026-06-25), retirada en ac558df (2026-09-09)`
- **Por qué importa:** El backend firma sesiones con HS256 (JwtService.java:125-127): quien conozca la clave puede fabricar un JWT válido para cualquier correo registrado y entrar como esa persona. Verifiqué que la clave está en el historial de dev y de 11 ramas; no pude verificar si producción (onelanguage.tech responde 200) usa todavía ese valor. Borrarla del código el 2026-09-09 no la invalida.
- **Cómo cerrarlo (S):** Generar una clave nueva de al menos 256 bits aleatorios, cargarla solo por JWT_SECRET en el servidor y confirmar que ya no coincide con el valor del historial; rotar la contraseña de BD (ver H-B01). Añadir al arranque una validación de longitud mínima y de que la clave no sea la de ejemplo.

### [Alto] H-06 · main y qa de tres repos siguen en el commit inicial: todo el trabajo está atrapado en dev y develop
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado
- **Evidencia:** `git rev-list --count origin/main..origin/dev: Backend 29, Frontend 76, Database 30, AI 14 (develop); main = 367e477 / 155f568 / 0032cde`
- **Por qué importa:** La rama de producción no contiene nada entregable; cualquier despliegue o corrección desde main parte de cero y la rama qa no cumple su función. El flujo dev, qa, main que sugiere la estructura de ramas nunca se ejecutó.
- **Cómo cerrarlo (S):** Promover dev a qa y a main mediante PR (con revisión) en los cuatro repos, etiquetar una versión y proteger main y qa.

### [Alto] H-09 · El frontend (web y móvil) no tiene ninguna prueba automatizada ni script de pruebas
- **Repositorio:** `propietario/OneLanguage_Frontend`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web/package.json:6`
- **Por qué importa:** 0 archivos de prueba en web/ y mobile/ y ningún script test: el registro, el login con bloqueo, la recuperación de contraseña, el manejo del 401 (api.js:33-45) y el historial con grabaciones, que son los criterios de aceptación centrales de las HU de autenticación, no tienen una sola prueba que los pruebe. Cualquier refactor puede romper el flujo principal sin aviso.
- **Cómo cerrarlo (M):** Añadir Vitest + Testing Library en web (login, registro, ProtectedRoute, interceptor de api.js) y jest-expo en móvil para los servicios y la pantalla de login; un smoke e2e (Playwright) del flujo registro → login → traducir → historial.

### [Alto] H-10 · El servicio de reconocimiento no tiene pruebas que protejan el comportamiento del modelo ni del WebSocket
- **Repositorio:** `propietario/OneLanguage-AI`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `evaluate_dataset.py:34`
- **Por qué importa:** Los scripts evaluate_* miden exactitud a mano pero no afirman nada ni fallan por debajo de un umbral; RecognitionSession (web_service.py:131-234) concentra la lógica de estabilización, reinicio y confirmación sin una prueba. Un cambio de umbrales o de etiquetas puede degradar el reconocimiento sin que nadie lo note.
- **Cómo cerrarlo (M):** Pruebas con pytest sobre RecognitionSession con secuencias sintéticas (no_hands, idle, translated, estabilidad), pruebas del WebSocket con TestClient (fotograma inválido, tamaño excedido, Origin no permitido) y una compuerta de exactitud mínima sobre un conjunto de evaluación reservado.

### [Alto] H-11 · Ninguno de los cuatro repositorios tiene CI: las pruebas, el lint y el build nunca corren automáticamente
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/OneLanguage-Backend/actions/runs, repos/propietario/OneLanguage-Database/actions/runs, repos/propietario/OneLanguage_Frontend/actions/runs y repos/propietario/OneLanguage-AI/actions/runs: total_count 0 en los cuatro; git ls-tree de las 77 ramas remotas sin .github`
- **Por qué importa:** Los 29 tests del backend, el lint de web/mobile y las migraciones solo corren si alguien los ejecuta a mano, y el Dockerfile del backend compila con -DskipTests. No hay compuerta de calidad antes de promover a qa/main ni evidencia de que lo desplegado haya pasado alguna prueba. Para un sistema ya en producción es la brecha operativa principal.
- **Cómo cerrarlo (M):** Añadir un workflow por repo: backend (mvn verify con la H2 de pruebas y jacoco), frontend (npm ci, lint, build, y pruebas cuando existan), database (liquibase validate + update sobre un PostgreSQL de servicio + rollback de prueba), AI (instalación, pruebas, build de imagen). Exigirlos con protección de rama.

### [Alto] H-12 · No hay release promovido: main y qa están vacíos en tres repos y el de Database tiene una instantánea vieja con la contraseña
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/OneLanguage-Backend/releases: 0 releases y 0 tags en los cuatro repos; git ls-tree origin/main de Backend, Frontend y AI: 1 archivo ('Initial commit'); Database origin/main: 75 archivos con commits e8681b9 y 94812a4`
- **Por qué importa:** El trabajo entregable vive solo en dev/develop; main y qa de Backend, Frontend y AI contienen un único commit inicial, y las de Database divergen de dev (+2 commits: e8681b9/72d431e con 'database architecture project', docs/arquitectura-capa-sql.md y docs/sql-layer-architecture.md que dev no tiene, y la contraseña en claro). Sin tags ni releases no hay versión identificable en producción ni objetivo de rollback, y no se sabe de qué commit sale lo que responde en onelanguage.tech.
- **Cómo cerrarlo (M):** Definir el flujo dev → qa → main con PR y compuerta de CI, etiquetar cada despliegue (v1.0.0), fusionar a Database dev el contenido útil de main/qa (docs) y retirar de ahí la contraseña, y registrar qué commit está en producción.

### [Alto] H-13 · Las ramas main y qa del repositorio de base de datos son una version vacia de hace cuatro meses
- **Repositorio:** `propietario/OneLanguage-Database`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:24`
- **Por qué importa:** main y qa estan 30 commits detras de dev y 2 por delante: los dos commits del 18 de junio (PR 2 y 3, HU-01-qa y HU-01-main) agregan docs/arquitectura-capa-sql.md y docs/sql-layer-architecture.md (unas 145 lineas cada uno) y un docker-compose.yml con usuario, base y clave fijos en el archivo (clave ««redactado»»), y dejan todos los changelog en databaseChangeLog: [] sin ninguna tabla. La rama por defecto no construye el esquema: docker compose up -d sobre main levanta una base vacia. Los documentos de arquitectura que dev referencia solo existen alli.
- **Cómo cerrarlo (S):** Integrar dev en qa y main con el flujo de PR del equipo, conservar los dos documentos de docs/ en dev (actualizados) y no volver a poner credenciales en el compose.

### [Medio] H-05 · La imagen web de producción no enruta /api ni /auth y su CSP contradice el README
- **Repositorio:** `propietario/OneLanguage_Frontend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** matizado (severidad ajustada de alto)
- **Evidencia (inferida):** `web/nginx.conf:14; web/nginx.conf:16; web/Dockerfile:10; README.md:58`
- **Por qué importa:** Con VITE_API_URL=/ por defecto, nginx solo sirve la SPA (try_files a index.html), así que login y registro devolverían HTML; el ejemplo del README (VITE_API_URL=http://localhost:8084) queda bloqueado por la CSP (connect-src solo admite self y los dominios onelanguage.tech). Solo funciona detrás de un proxy no documentado en ningún repo. Inferido de la configuración; no se ejecutó.
- **Cómo cerrarlo (M):** Añadir al nginx.conf un proxy a /api y /auth (con el upstream por variable), corregir el ejemplo del README y hacer la CSP parametrizable, o incluir un docker-compose de despliegue completo.

### [Medio] H-07 · El puerto del servicio de IA no coincide entre el servicio (8000) y los clientes por defecto (8001)
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A06 · **Verificación independiente:** matizado (severidad ajustada de alto)
- **Evidencia:** `docker-compose.yml:18`
- **Por qué importa:** El servicio y su compose usan 8000 (AI_PORT en .env.example:8, docker-compose.yml:18, web_service.py:291). El proxy de Vite del frontend apunta a ws://127.0.0.1:8001 (web/vite.config.js:28) y mobile usa 8001 en src/config/network.ts:4 y .env.example:4, mientras que README.md:87 y mobile/README.md:19 dicen 8000. Con la configuracion por defecto web y mobile no encuentran el modelo. Solo el README de la IA menciona 8001 como alternativa y obliga a cambiar AI_HOST_PORT. Rutas con prefijo de repo: propietario/OneLanguage-AI:docker-compose.yml:18 y propietario/OneLanguage_Frontend:web/vite.config.js:28.
- **Cómo cerrarlo (S):** Elegir un unico puerto (8000), cambiarlo en vite.config.js y network.ts y en mobile/.env.example, y documentar en un solo lugar la matriz de puertos: backend 8084, IA 8000, frontend 5173.

### [Medio] H-08 · El WebSocket de reconocimiento no exige autenticación y su control de Origin se omite sin el encabezado
- **Repositorio:** `propietario/OneLanguage-AI`
- **Lente SDLC OS:** A12 · **Verificación independiente:** matizado (severidad ajustada de alto); también reportado como H-25
- **Evidencia:** `web_service.py:259-282 (control de Origin en 261-265); límites ausentes en 136 y 114-118`
- **Por qué importa:** Cualquier cliente que no sea un navegador puede abrir /ws/recognize, enviar fotogramas de hasta 2,5 MB y consumir CPU de TensorFlow/MediaPipe; no hay tope de conexiones, tasa ni duración, y la inferencia se serializa con un candado global, así que pocas conexiones degradan el servicio para los usuarios reales. Es un servicio expuesto públicamente según la configuración (wss://ai.onelanguage.tech). El impacto de saturación es inferido del código, no probado.
- **Cómo cerrarlo (M):** Exigir el JWT del backend en la conexión (primer mensaje o parámetro firmado de corta vida) y validarlo en el servicio; rechazar conexiones sin Origin permitido; limitar conexiones por IP/usuario, fotogramas por segundo y duración; ocultar la lista de etiquetas en /health.

### [Medio] H-14 · Se versionaron .idea/, un package.json huérfano y restos de las plantillas Expo y Vite
- **Repositorio:** `propietario/OneLanguage_Frontend`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `.idea/caches/deviceStreaming.xml; package.json; mobile/components/hello-wave.tsx; mobile/scripts/reset-project.js; web/src/assets/react.svg`
- **Por qué importa:** La raíz no tiene .gitignore: se publicó la configuración del IDE (85 KB de caché de dispositivos) y un package.json y package-lock.json con expo ~54 que no corresponden a mobile/package.json (expo ~57) y confunden un npm install ejecutado en la raíz. Los restos de plantilla añaden ruido y código muerto.
- **Cómo cerrarlo (S):** Añadir un .gitignore raíz, retirar .idea y el package.json raíz con git rm y eliminar los archivos de plantilla sin uso.

### [Medio] H-15 · Login y registro web no muestran estado de envío ni bloquean el botón
- **Repositorio:** `propietario/OneLanguage_Frontend`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web/src/pages/login/Login.jsx:212; web/src/components/Button/Button.jsx:3`
- **Por qué importa:** Con red lenta el usuario puede enviar varias veces el formulario sin saber que se está procesando: es la primera pantalla del flujo principal. Login.jsx y Register.jsx no tienen estados loading ni disabled (el móvil sí).
- **Cómo cerrarlo (S):** Añadir un estado submitting, pasar disabled al Button y mostrar texto de carga, como ya hacen ResetPassword.jsx y las pantallas móviles.

### [Medio] H-16 · El móvil no restaura la sesión ni protege las pantallas autenticadas
- **Repositorio:** `propietario/OneLanguage_Frontend`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `mobile/app/index.tsx:15; mobile/app/_layout.tsx:1; mobile/src/services/authService.ts:118`
- **Por qué importa:** Al abrir la app siempre se llega al login aunque haya un token guardado, y el grupo (auth) no tiene guardia: las rutas se abren por enlace directo sin sesión y solo user_profile.tsx reacciona a un 401. El token queda en AsyncStorage sin cifrar.
- **Cómo cerrarlo (M):** Leer el token al arrancar, redirigir a main si es válido y a login si no, centralizar el manejo de 401 y guardar el token con expo-secure-store.

### [Medio] H-17 · La documentación de producto no vive en el repositorio: sin problema, usuarios, alcance, indicadores ni historias
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md; git grep -i de 'historia de usuario|KPI|indicador|criterio de aceptación' en los 4 SHA: 0 coincidencias; PROYECTOS-FICHA-3145555.md declara solo una carpeta de Drive`
- **Por qué importa:** Los únicos .md de los cuatro repos son README técnicos. Las ramas HU-01 a HU-25 y los títulos de PR citan historias que no se pueden leer ni ubicar en una pantalla o endpoint desde el repositorio; no se puede comprobar si hay al menos 3 indicadores medibles ni historias Must con al menos 2 criterios de aceptación. La carpeta de Drive no es accesible para el evaluador (no se evalúa su contenido).
- **Cómo cerrarlo (M):** Traer al repositorio (docs/) el problema, usuarios, alcance, indicadores, historias con criterios de aceptación y un diagrama de arquitectura, y referenciar cada HU en la pantalla o endpoint que la implementa.

### [Medio] H-18 · 70 pull requests sin una sola revisión, fusionados por su propio autor
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/OneLanguage-Backend/pulls/{1..14}: autor igual a quien fusiona en los 14; /reviews y /comments: 0 en los 70 PR de los cuatro repos`
- **Por qué importa:** El PR existe pero no cumple su función (segunda mirada). Los defectos de H-C03, H-C05 o el console.error habrían podido detectarse en una revisión cruzada entre los dos integrantes.
- **Cómo cerrarlo (S):** Exigir al menos una aprobación del otro integrante antes de fusionar y activar la protección de ramas dev, qa y main.

### [Medio] H-19 · La propiedad del código depende de dos cuentas personales sin organización
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/OneLanguage-Backend (owner.type User); gh api repos/propietario/OneLanguage-AI (dueño Integrante 2); pulls/14 fusionado por Integrante 2`
- **Por qué importa:** Tres repos viven en la cuenta personal de Integrante y el de IA (que concentra el modelo ausente) en la de Integrante; sin organización ni colaboradores confirmados en el repo de IA, el proyecto se pierde si una cuenta se cierra o se desvincula del programa.
- **Cómo cerrarlo (S):** Mover los 4 repos a una organización del programa (o añadir al otro integrante, al instructor y a una cuenta de respaldo como administradores).

### [Medio] H-20 · El historial del frontend se rehízo el 2026-05-07 y el esqueleto de base de datos se commiteó tres veces
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git show 51267a4fa5 (Frontend, 82 archivos); git show d2e5ad5a97, 72d431e, e8681b9 (Database, 74 archivos cada uno)`
- **Por qué importa:** El mensaje del commit 51267a4 reconoce que se recreó el repositorio por malas prácticas: se perdió el historial previo y no se puede atribuir autoría anterior a junio. En Database, el mismo árbol de 74 archivos (41 .gitkeep y documentación genérica de otro repo) se presentó como 'database architecture project' en dev, qa y main.
- **Cómo cerrarlo (S):** Documentar en el README el origen de ambos hechos y, desde ahora, no reescribir historial; atribuir la documentación genérica a su fuente.

### [Medio] H-21 · No hay guía conjunta para levantar los cuatro repositorios
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md; docker-compose.yml; mobile/README.md`
- **Por qué importa:** Cada README describe su repo, pero ninguno enlaza a los demás ni da el orden (base de datos, backend, IA, web y móvil), los puertos definitivos ni un compose conjunto; mobile/README.md es la plantilla de Expo con una sección añadida. Un integrante nuevo o el instructor no puede montar el sistema sin preguntar.
- **Cómo cerrarlo (M):** Crear una guía de integración (en un repo de documentación o en cada README) con el diagrama de componentes, orden de arranque, puertos y variables, y un docker-compose de desarrollo.

### [Medio] H-22 · Las instrucciones de ejecución del backend no funcionan tal como están escritas
- **Repositorio:** `propietario/OneLanguage-Backend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:39; README.md:46; README.md:61; Backend-OneLanguage/src/main/resources/application.properties:13`
- **Por qué importa:** README.md:39 manda copiar .env.example a .env y ejecutar ./mvnw spring-boot:run, pero Spring Boot no lee .env y nada en el proyecto lo carga (sin dotenv ni spring.config.import): el datasource queda sin resolver. Y la URL de ejemplo con localhost:5438 no sirve dentro del contenedor del compose.
- **Cómo cerrarlo (S):** Documentar exportar las variables antes de mvnw (o añadir spring.config.import=optional:file:.env[.properties]) y dar la URL para Docker (host.docker.internal o una red compartida), o incluir PostgreSQL en el compose.

### [Medio] H-23 · El puerto del servicio de IA es 8000 en el servicio y en dos README, y 8001 en los clientes
- **Repositorio:** `propietario/OneLanguage_Frontend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-53
- **Evidencia:** `web/vite.config.js:28; mobile/src/config/network.ts:4; mobile/.env.example:4; README.md:87; mobile/README.md:12`
- **Por qué importa:** Con los valores por defecto, la traducción web (proxy a 8001) y móvil (8001 por defecto) no encuentran al servicio de IA (8000 por defecto en AI_PORT y en el compose de propietario/OneLanguage-AI); cada integrante depende de saber qué variable cambiar.
- **Cómo cerrarlo (S):** Elegir un solo puerto y aplicarlo en el compose de IA, vite.config.js, network.ts, .env.example y README, o centralizarlo en un documento de integración.

### [Medio] H-24 · La documentacion del modelo en el README de la base lista tablas que ya no existen
- **Repositorio:** `propietario/OneLanguage-Database`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:65`
- **Por qué importa:** README.md:65 y :67 describen auth.sessions y translation.audio_files, eliminadas por 01_ddl/10_alter/002-drop-unused-auth-tables.sql y 005-drop-unused-translation-catalog-tables.sql. README.md:24 lista una carpeta docs/ que no existe en dev (los dos documentos de arquitectura de la capa SQL solo estan en main y qa). Quien lea el README entiende un modelo distinto del implementado (T-3.6).
- **Cómo cerrarlo (S):** Actualizar la seccion Esquemas, tablas y relaciones con las tablas reales (users, password_reset_tokens, permissions, user_permissions, translations, language, accessibility_settings) y traer o quitar la carpeta docs/.

### [Medio] H-26 · Componentes de pantalla de 300 a 529 líneas y traducciones en líneas de 4 026 caracteres
- **Repositorio:** `propietario/OneLanguage_Frontend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `mobile/app/(auth)/camera.tsx:60; mobile/app/(auth)/user_profile.tsx:1; web/src/i18n.js:60`
- **Por qué importa:** camera.tsx (el componente más grande del equipo) concentra cámara, WebSocket, reconexión, voz y guardado con 11 useState y 13 useRef; 9 archivos superan 300 líneas y no hay pruebas en el cliente, así que cualquier cambio es riesgoso. Los hex repetidos en 11 pantallas móviles ignoran ThemeContext.
- **Cómo cerrarlo (M):** Extraer hooks (useRecognitionSocket, useCameraCapture, useSpeech) y subcomponentes, dividir i18n por idioma y namespace, y consumir colores desde el tema.

### [Medio] H-27 · Dependencias y código muertos: Flask, Celery, Redis y SQLAlchemy se instalan en la imagen sin usarse
- **Repositorio:** `propietario/OneLanguage-AI`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `requirements.txt:3; requirements.txt:5; requirements.txt:22; recognizer.py:190; Dockerfile:16`
- **Por qué importa:** Ningún .py importa Flask, Celery, Redis, SQLAlchemy, pandas, eventlet ni gunicorn (git grep), pero la imagen los instala: más tamaño y superficie de ataque. recognizer.py conserva un modo 'legacy' que carga model/scaler.pkl y otros archivos que el entrenamiento ya no genera, y la lógica de decisión está duplicada con web_service.py.
- **Cómo cerrarlo (S):** Depurar requirements.txt a lo importado, separar requirements-train.txt, eliminar el modo legacy y reutilizar la lógica común desde lsc_pipeline.py.

### [Medio] H-28 · Enumeración de cuentas por mensajes de login y de recuperación, sin límite de peticiones
- **Repositorio:** `propietario/OneLanguage-Backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/passwordreset/service/imple/PasswordResetServiceImpl.java:48`
- **Por qué importa:** forgot-password responde 400 'No existe un usuario con ese correo.' (líneas 48-51); el login devuelve 'Credenciales inválidas.' si el correo no existe (AuthServiceImple.java:38-39) pero 'Te quedan N intentos' y luego 423 si existe (líneas 63-74). Cualquiera puede listar qué correos están registrados. Como el bloqueo es por cuenta (5 intentos, 3 minutos, líneas 26-27), un atacante también puede bloquear repetidamente a una persona concreta, y forgot-password no tiene límite de tasa (inunda de correos y anula el enlace vigente de la víctima).
- **Cómo cerrarlo (S):** Responder siempre con el mismo mensaje y código en forgot-password y en login (sin contador de intentos para correos desconocidos), enviar el correo solo si existe, y añadir límite de tasa por IP y por correo (por ejemplo Bucket4j o un filtro simple).

### [Medio] H-29 · El servidor no impone política de contraseña ni longitudes máximas; la regla solo vive en el frontend
- **Repositorio:** `propietario/OneLanguage-Backend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-45
- **Evidencia:** `Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/users/dto/UserRequestDto.java:18`
- **Por qué importa:** UserRequestDto.java:18-19 y ResetPasswordRequest.java:19-20 aceptan cualquier cadena no vacía: una llamada directa a POST /api/users con la contraseña '1' crea la cuenta. Sin @Size en correo y nombre, una entrada larga rompe contra varchar(255)/(150) y termina en un 500 genérico. El skill de seguridad de API pide validar en el borde con lista blanca por campo.
- **Cómo cerrarlo (S):** Añadir @Size(min=8,max=72) y un patrón de complejidad (o una lista de contraseñas comunes) en ambos DTO, y @Size en email y fullName con los límites de la tabla; cubrirlo con pruebas negativas.

### [Medio] H-30 · La base de datos no tiene roles ni permisos de mínimo privilegio: la app solo puede usar el superusuario
- **Repositorio:** `propietario/OneLanguage-Database`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `03_dcl/01_grants/changelog.yaml:1`
- **Por qué importa:** Los changelogs de roles, grants y políticas están vacíos y el README pide 'credenciales de mínimo privilegio' sin que exista un rol que lo permita; docker-compose.yml:8 y el valor por defecto histórico del backend usan postgres. Un fallo de inyección o una fuga de la cadena de conexión da control total del servidor de BD, no solo de las tablas de la aplicación. Que producción use el superusuario es una inferencia; no verificada.
- **Cómo cerrarlo (M):** Crear en 03_dcl un rol de aplicación sin DDL con GRANT mínimo sobre los esquemas auth y translation, un rol de migración distinto, y usar el primero en el backend; documentar cómo crearlos.

### [Medio] H-31 · El JWT de 24 horas se guarda en localStorage (web) y AsyncStorage sin cifrar (móvil)
- **Repositorio:** `propietario/OneLanguage_Frontend`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web/src/pages/login/Login.jsx:126`
- **Por qué importa:** web/src/services/authSession.js:23-40 y Login.jsx:126-127 guardan el token y el objeto de usuario en localStorage; mobile/app/(auth)/login.tsx:91-96 hace lo mismo en AsyncStorage (no expo-secure-store). Cualquier XSS o un dispositivo móvil con respaldo/root accesible lee la sesión completa; el backend no permite revocarla durante 24 h. La CSP con script-src 'self' (nginx.conf:14) reduce el riesgo en web, no en móvil.
- **Cómo cerrarlo (M):** En móvil usar expo-secure-store; en web, cookie HttpOnly con SameSite emitida por el backend (o token de corta vida con refresco); añadir revocación/versión de token en el backend para cambio de contraseña y cierre de sesión.

### [Medio] H-32 · Términos y avisos de privacidad insuficientes y contradictorios para datos de personas y video (Ley 1581 de 2012)
- **Repositorio:** `propietario/OneLanguage_Frontend`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web/src/i18n.js:40`
- **Por qué importa:** La app registra correo y nombre y puede guardar video de la persona que firma. La cláusula de privacidad es una sola frase (terms.p5), no identifica responsable, finalidad, derechos, retención ni transferencia; el aviso en español dice que el video se guarda con 'Guardar en historial' (i18n.js:101) y el inglés que no se almacenan (i18n.js:102). La aceptación se valida solo en el cliente (Register.jsx:58-59) y el servidor no la registra (UserRequestDto.java no la recibe). No hay forma de probar el consentimiento ni de eliminar definitivamente la cuenta.
- **Cómo cerrarlo (M):** Redactar una política de tratamiento (responsable, finalidades, derechos ARCO, retención, video), unificar los avisos en los cuatro idiomas, enviar y guardar la aceptación con versión y fecha en el backend, y ofrecer eliminación definitiva de cuenta y grabaciones.

### [Medio] H-33 · Dependencias con avisos de seguridad conocidos y paquetes sin uso en la imagen de inferencia
- **Repositorio:** `propietario/OneLanguage-AI`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `requirements.txt:5`
- **Por qué importa:** requirements.txt incluye Flask 3.1.0, Jinja2 3.1.5, requests 2.32.3, tensorflow 2.16.1 y keras 3.3.3, versiones que tienen correcciones de seguridad posteriores (afirmación desde avisos públicos, sin escáner; verificado=false), más Flask, celery, redis, SQLAlchemy, pandas, gunicorn y eventlet que ningún .py importa, y eventlet/joblib sin versión. Cada paquete extra amplía la superficie de ataque de un servicio expuesto y engorda la imagen.
- **Cómo cerrarlo (S):** Reducir requirements.txt a lo que importa el código (fastapi, uvicorn, tensorflow/keras, mediapipe, opencv, numpy, python-dotenv), fijar todas las versiones, actualizar a las corregidas y correr pip-audit o Dependabot.

### [Medio] H-34 · Las pruebas del backend no cubren controladores, reglas de seguridad ni el almacenamiento de grabaciones
- **Repositorio:** `propietario/OneLanguage-Backend`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Backend-OneLanguage/src/test/java/com/sena/Backend_OneLanguage/security/jwt/JwtAuthenticationFilterTest.java:31`
- **Por qué importa:** Sin MockMvc ni @WebMvcTest (git grep): ninguna regla de SecurityConfig (qué es público y qué exige JWT) ni la propiedad del recurso en /api/translations/{id}/recording tienen prueba, aunque el README afirma que las grabaciones solo son accesibles para su propietario. Tampoco hay pruebas de TranslationService, TranslationRecordingStorage (tamaño, tipo, ruta), ni de resetPassword (token usado, vencido o inválido): PasswordResetServiceImplTest solo cubre forgotPassword (dos pruebas). Falta cobertura medida (sin jacoco) y la prueba contra PostgreSQL está apagada por defecto. Desde el criterio A09: los criterios de aceptación de seguridad no están trazados a pruebas.
- **Cómo cerrarlo (M):** Añadir @WebMvcTest/MockMvc con spring-security-test (ya en el pom) para los 401/403 y el acceso cruzado entre usuarios, pruebas de TranslationRecordingStorage con archivos temporales y de resetPassword; activar jacoco con un umbral y ejecutar la prueba de PostgreSQL en CI con Testcontainers.

### [Medio] H-35 · No se prueba que las migraciones se apliquen desde cero ni que sus rollbacks funcionen
- **Repositorio:** `propietario/OneLanguage-Database`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:56`
- **Por qué importa:** No hay ningún script, pipeline ni prueba que levante una base vacía, aplique los changesets y ejecute los rollbacks. La propia documentación reconoce que la existencia de un changeset no demuestra que se haya aplicado (README.md:56), y el backend corre con ddl-auto=validate, de modo que una migración rota se descubre al arrancar en el ambiente.
- **Cómo cerrarlo (S):** Un job de CI con PostgreSQL de servicio que ejecute liquibase update, valide el esquema contra las entidades del backend y pruebe rollbackCount N en cada PR.

### [Medio] H-36 · La imagen del backend corre como root, incluye el JDK completo y no tiene healthcheck utilizable
- **Repositorio:** `propietario/OneLanguage-Backend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Dockerfile:10`
- **Por qué importa:** Dockerfile:10 usa eclipse-temurin:17 (JDK) sin USER, línea 8 salta las pruebas y no cachea dependencias; el actuator está en el pom pero /actuator/** exige JWT (SecurityConfig.java:89-91), de modo que un balanceador recibe 401, y docker-compose.yml no define healthcheck, restart ni límites de recursos. Una vulnerabilidad en la app da root dentro del contenedor y una caída no se detecta ni se reinicia sola.
- **Cómo cerrarlo (S):** Imagen final eclipse-temurin:17-jre con usuario no root, copiar el pom primero y usar mvn dependency:go-offline, permitir /actuator/health (solo estado) sin JWT, añadir HEALTHCHECK y restart: unless-stopped al compose.

### [Medio] H-37 · Migraciones sin rollback completo y con comprobación de checksum desactivada en tres changesets
- **Repositorio:** `propietario/OneLanguage-Database`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-42
- **Evidencia:** `01_ddl/10_alter/changelog.yaml:80`
- **Por qué importa:** El changeset 010-backfill-accessibility-settings (líneas 80-88) no declara rollback aunque el README promete reversibilidad; tres changesets usan validCheckSum: ANY (dos en 01_ddl/03_tables/changelog.yaml y uno en 01_ddl/10_alter/changelog.yaml), lo que permite editar un script ya aplicado sin que Liquibase lo detecte. Los rollbacks de los DROP (changesets 006 y 009) solo restauran estructura, no datos, y el README lo reconoce. liquibase/liquibase se usa sin tag (docker-compose.yml:22).
- **Cómo cerrarlo (S):** Añadir rollback al changeset 010, quitar validCheckSum: ANY y corregir los checksums con clearCheckSums solo una vez y documentado, fijar la versión de la imagen de Liquibase y exigir copia de seguridad previa en el procedimiento de despliegue.

### [Medio] H-38 · El contenedor web corre nginx como root, sin healthcheck, y la topología de producción no está documentada
- **Repositorio:** `propietario/OneLanguage_Frontend`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web/Dockerfile:18`
- **Por qué importa:** web/Dockerfile:18-25 usa nginx:1.27-alpine sin USER ni HEALTHCHECK (puerto 80, como root). VITE_API_URL=/ por defecto (Dockerfile:10) implica que /api y /auth llegan al backend por un proxy externo, pero nginx.conf no define proxy_pass y ningún repo documenta ese proxy, el TLS ni los hosts onelanguage.tech y ai.onelanguage.tech (que solo aparecen fijados en Dockerfile:13, nginx.conf:14 y mobile/eas.json:13-14,22-23). Quien herede el proyecto no puede reproducir el despliegue.
- **Cómo cerrarlo (M):** Usar nginxinc/nginx-unprivileged (puerto 8080) con HEALTHCHECK, añadir location /health, y documentar en un runbook (o en un docker-compose de producción) el proxy, el TLS, los dominios y cómo se construye cada imagen.

### [Medio] H-40 · Esquema sin indices propios: la carpeta de indices esta vacia y las claves foraneas no tienen indice
- **Repositorio:** `propietario/OneLanguage-Database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/09_indexes/changelog.yaml:1`
- **Por qué importa:** databaseChangeLog es una lista vacia. translations.id_user (01_ddl/03_tables/007-table-translations.sql), password_reset_tokens.id_user y accessibility_settings.id_language son FK sin indice; el backend consulta siempre por usuario, sin borrar y ordenado por fecha (TranslationRepository.java:10 del backend), asi que cada lectura del historial y cada borrado en cascada de un usuario recorre toda la tabla hija. El skill de PostgreSQL del marco exige un indice por cada FK y por patron de consulta.
- **Cómo cerrarlo (S):** Añadir un changeset en 09_indexes con indices sobre translations (id_user, created_at) parcial donde deleted_at es nulo, password_reset_tokens (id_user) y accessibility_settings (id_language), con su rollback.

### [Medio] H-41 · Migraciones con vaivenes: tablas creadas para eliminarse y reformuladas con otros tipos
- **Repositorio:** `propietario/OneLanguage-Database`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/10_alter/changelog.yaml:20`
- **Por qué importa:** auth.sessions, signs, translation_signs y audio_files se crean en 03_tables y se eliminan en 10_alter/002 y 10_alter/005; permissions y user_permissions se crean (sin UNIQUE ni CHECK, con TIMESTAMP), se eliminan en 002 y se recrean en 004 con otros tipos (TIMESTAMPTZ, UNIQUE, CHECK). Una instalacion nueva ejecuta DDL muerto, la linea base no cuenta la historia real y el modelo logico que el equipo diseno (catalogo de senas) quedo recortado sin dejar un ADR ni documento que lo explique. El skill del marco pide que una tabla que ninguna entidad declara no se cree.
- **Cómo cerrarlo (M):** Consolidar una linea base limpia para instalaciones nuevas (o documentar el recorte en un ADR) y dejar los alter solo para cambios sobre bases ya desplegadas. Retirar los validCheckSum ANY.

### [Medio] H-43 · Tres formatos de error distintos y listas sin paginacion
- **Repositorio:** `propietario/OneLanguage-Backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/config/GlobalExceptionHandler.java:75`
- **Por qué importa:** GlobalExceptionHandler devuelve status y message (linea 75), JwtAuthenticationEntryPoint devuelve timestamp, status, error, message y path (lineas 33-37) y el fallo de login devuelve code, remainingAttempts y lockedUntil (lineas 43-50). Los clientes web y mobile solo leen message, asi que ignoran code, remainingAttempts y lockedUntil. La validacion entrega solo el primer error (linea 21) sin indicar el campo. GET /api/translations devuelve todo el historial sin paginacion (TranslationService.java:52).
- **Cómo cerrarlo (M):** Definir un unico cuerpo de error (timestamp, status, code, message, path y lista de errores por campo) y usarlo en los tres lugares; agregar paginacion (page, size) a GET /api/translations.

### [Medio] H-44 · Contrato de la API sin documentar de forma curada ni versionar
- **Repositorio:** `propietario/OneLanguage-Backend`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Backend-OneLanguage/pom.xml:60`
- **Por qué importa:** springdoc esta en el pom y Swagger UI se permite sin autenticacion (SecurityConfig.java:69), pero no hay una sola anotacion de OpenAPI ni esquema Bearer, no hay version en las rutas y el README del backend no menciona /swagger-ui. Los cambios de contrato (por ejemplo la retirada del permiso files) no tienen como avisarse a los clientes. En la IA el WebSocket tampoco tiene esquema de mensajes ni version.
- **Cómo cerrarlo (M):** Anotar controladores y DTO (@Operation, @Tag, @Schema, respuestas de error), declarar el esquema Bearer, publicar el OpenAPI en el README, prefijar /api/v1 y restringir Swagger UI fuera de desarrollo.

### [Bajo] H-46 · Un JAR de 1,1 MB versionado y un README que cita una carpeta docs/ ya eliminada
- **Repositorio:** `propietario/OneLanguage-Database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `postgresql-42.7.9.jar; README.md:24; docker-compose.yml:22`
- **Por qué importa:** El controlador JDBC viene dentro de la imagen oficial de Liquibase, por lo que el binario sobra; README.md:24 lista docs/, carpeta que el commit 7bd29f1 borró de dev (sigue en main con documentación genérica). Pequeño pero induce a error.
- **Cómo cerrarlo (S):** Retirar el JAR y el volumen que lo monta (o descargarlo en el compose), y corregir el árbol del README.

### [Bajo] H-47 · Accesibilidad incompleta en un producto cuyo público es accesibilidad: lang fijo y pantallas móviles sin etiquetas
- **Repositorio:** `propietario/OneLanguage_Frontend`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web/index.html:2; mobile/app/(auth)/login.tsx:1; mobile/app/(auth)/history.tsx:1`
- **Por qué importa:** El atributo lang de html queda en inglés y no cambia con el idioma elegido (los lectores de pantalla pronuncian mal), y login, home, history y accessibility móviles no declaran accessibilityLabel ni accessibilityRole. Es el único público objetivo de la aplicación.
- **Cómo cerrarlo (S):** Actualizar document.documentElement.lang al cambiar de idioma y añadir roles y etiquetas a los controles móviles.

### [Bajo] H-48 · Columnas y datos sin consumidor: voice_feedback, processing_time y los campos extra de login
- **Repositorio:** `propietario/OneLanguage-Database`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/011-table-accesibility-settings.sql:11`
- **Por qué importa:** accessibility_settings.voice_feedback existe en el DDL pero ninguna entidad, DTO o pantalla la usa (la voz automatica se guarda solo en el cliente); translations.processing_time nunca se escribe y input_type y translation_status se fijan a camera y completed en TranslationService.java:43 y :46 del backend. Son residuos del modelo original que el equipo recorto a medias.
- **Cómo cerrarlo (S):** Mapear voice_feedback en la entidad y el DTO para persistir la preferencia de voz, o eliminarla; decidir si processing_time y translation_status se usaran y, si no, retirarlos.

### [Bajo] H-49 · El README del backend afirma una dependencia de la IA y OpenFeign que el codigo no tiene
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:118`
- **Por qué importa:** El README del backend (lineas 12 y 118) lista OpenFeign y dice que el reconocimiento depende del servicio de IA, pero no existe ningun @FeignClient ni URL de IA en application.properties: web y mobile hablan directo con el WebSocket de la IA. El pom incluye spring-cloud-starter-openfeign sin uso (pom.xml:65). Ruta con prefijo: propietario/OneLanguage-Backend:README.md:118.
- **Cómo cerrarlo (S):** Quitar OpenFeign del pom y del README y escribir en el README la relacion real: el frontend consume la IA directamente y el backend solo guarda el resultado.

### [Bajo] H-50 · requirements.txt arrastra dependencias de otra arquitectura que ningun archivo usa
- **Repositorio:** `propietario/OneLanguage-AI`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `requirements.txt:5`
- **Por qué importa:** Flask, Flask-SQLAlchemy, SQLAlchemy, celery, redis, gunicorn, eventlet y pandas estan en requirements.txt y ningun .py las importa (git grep). La imagen Docker las instala con TensorFlow, crece sin motivo y sugiere un servicio con cola y base de datos que no existe.
- **Cómo cerrarlo (S):** Depurar requirements.txt a lo que importa el codigo (fastapi, uvicorn, tensorflow, mediapipe, opencv, numpy, scikit-learn, joblib, pyttsx3, python-dotenv) y separar las dependencias de entrenamiento de las del servicio.

### [Bajo] H-51 · printStackTrace y mensaje interno en la respuesta 500, show-sql activo y dependencias sin uso
- **Repositorio:** `propietario/OneLanguage-Backend`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/config/GlobalExceptionHandler.java:67; Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/config/GlobalExceptionHandler.java:61; Backend-OneLanguage/src/main/resources/application.properties:20; Backend-OneLanguage/pom.xml:65`
- **Por qué importa:** printStackTrace no pasa por el logger ni conserva contexto; IllegalStateException devuelve su mensaje al cliente; spring.jpa.show-sql=true está en la configuración principal; openfeign y devtools están declarados sin uso.
- **Cómo cerrarlo (S):** Usar un logger con el stack trace, devolver un mensaje fijo en los 500, mover show-sql a un perfil de desarrollo y retirar las dependencias sin uso.

### [Bajo] H-52 · Swagger, SQL en el log y stack traces quedan activos en cualquier entorno
- **Repositorio:** `propietario/OneLanguage-Backend`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/security/config/SecurityConfig.java:67`
- **Por qué importa:** SecurityConfig.java:67-71 deja públicos /swagger-ui y /v3/api-docs, application.properties:20 imprime todo el SQL y GlobalExceptionHandler.java:67 llama printStackTrace. En producción esto publica el mapa completo de la API y llena el log de detalles internos. No hay perfil de producción que lo apague.
- **Cómo cerrarlo (S):** Crear un perfil prod con springdoc.api-docs.enabled=false, spring.jpa.show-sql=false y logger en lugar de printStackTrace; dejar Swagger solo en dev.

### [Bajo] H-54 · Tipos de fecha mezclados, sin CHECK de dominio y unicidad de correo que ignora el borrado logico
- **Repositorio:** `propietario/OneLanguage-Database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/002-table-Password-Reset-Tokens.sql:11`
- **Por qué importa:** password_reset_tokens, translations y accessibility.* usan TIMESTAMP sin zona mientras users y las tablas restauradas usan TIMESTAMPTZ (el skill del marco exige timestamptz). translation_status, input_type, text_size y theme_color solo se validan en el DTO del backend. users.email es UNIQUE sobre todas las filas, pero el backend solo comprueba usuarios no borrados (UserRepository.java:21 del backend): hoy no hay ruta de borrado de usuario, pero el dia que exista, volver a registrar el mismo correo fallara con un 500. Si Hibernate con ddl-auto=validate acepta OffsetDateTime sobre columnas TIMESTAMP no se pudo ejecutar.
- **Cómo cerrarlo (S):** Unificar a TIMESTAMPTZ NOT NULL DEFAULT now(), añadir CHECK para los enumerados y un indice unico parcial sobre email donde deleted_at es nulo, todo mediante changesets nuevos.

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 89.1 |
| D2 | Reproducibilidad | 68.8 |
| D3 | Arquitectura y congruencia | 58.3 |
| D4 | Calidad de código | 59.8 |
| D5 | Seguridad | 58.6 |
| D6 | Pruebas | 27.5 |
| D7 | DevOps y despliegue | 33.3 |
| D8 | Datos | 50.0 |
| D9 | API y contratos | 45.0 |
| D10 | Frontend y móvil | 50.0 |
| D11 | IoT y firmware | — |
| D12 | Documentación y trazabilidad | 50.0 |
| D13 | Proceso y colaboración | 55.3 |
| D14 | Extremo a extremo | 50.0 |

## Lo que está bien

- Persistencia de contrasenas y recuperacion bien resueltas (`propietario/OneLanguage-Backend:Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/security/config/SecurityConfig.java:106 usa BCrypt; PasswordResetServiceImpl guarda solo el hash del token, vence a los 15 minutos y es de un solo uso.`)
- Contratos REST coherentes de punta a punta en los flujos reales (`propietario/OneLanguage_Frontend:web/src/services/translationService.js:18 consume exactamente los campos de propietario/OneLanguage-Backend:Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/translation/dto/TranslationResponseDto.java:15; accesibilidad y permisos tambien coinciden.`)
- Migraciones versionadas con Liquibase, con capas SQL ordenadas y rollbacks (`propietario/OneLanguage-Database:changelog-master.yaml:1 incluye DDL, DML, DCL y TCL en orden; 20 de 21 changesets declaran rollback y los 05_rollbacks existen.`)
- Compose de la base con healthcheck y variables sin valores reales (`propietario/OneLanguage-Database:docker-compose.yml:16 define pg_isready y Liquibase espera a service_healthy; .env.example solo trae marcadores.`)
- Datos de cada usuario aislados por consulta y borrado logico (`propietario/OneLanguage-Backend:Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/translation/repository/TranslationRepository.java:10 filtra por usuario y deleted_at; las grabaciones solo las sirve a su dueno.`)
- Protocolo WebSocket de la IA claro y compartido por web y mobile (`propietario/OneLanguage-AI:web_service.py:259 define ready, prediction y error; propietario/OneLanguage_Frontend:web/src/pages/translate/Translate.jsx:154 y mobile/app/(auth)/camera.tsx lo consumen igual.`)
- Servicio de IA con comprobaciones de coherencia del modelo y Docker con healthcheck (`propietario/OneLanguage-AI:web_service.py:107 valida longitud de secuencia, caracteristicas y etiquetas; docker-compose.yml:23 define el healthcheck de /health.`)
- Cabeceras de seguridad y CORS restringido sin credenciales (`propietario/OneLanguage-Backend:Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/config/CorsConfig.java:29 usa lista de origenes y allowCredentials en falso; propietario/OneLanguage_Frontend:web/nginx.conf:14 define CSP y cabeceras.`)
- Autenticación del backend correcta y bien probada (`Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/security/jwt/JwtService.java:112 verifica firma y expiración; JwtAuthenticationFilter.java:46-80 responde 401; SecurityConfig.java:48-51 sesión STATELESS y 89-91 anyRequest().authenticated(); Backend-OneLanguage/src/test/java/com/sena/Backend_OneLanguage/auth/service/imple/AuthServiceImpleTest.java:98 prueba el bloqueo por intentos.`)
- Autorización por propietario en todos los endpoints de datos, sin IDOR (`Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/translation/service/TranslationService.java:57 y 78 filtran por usuario autenticado; users, feature-permissions y accessibility-settings resuelven todo con @AuthenticationPrincipal.`)
- Contraseñas y tokens de recuperación hasheados con bcrypt, enlace de un solo uso y 15 minutos (`Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/passwordreset/service/imple/PasswordResetServiceImpl.java:68 y 129-143 (usado/vencido), UserServiceImpl.java:34-36.`)
- Suite de pruebas unitarias del backend con aserciones de comportamiento (29 @Test, 109 verificaciones) (`Backend-OneLanguage/src/test/java/com/sena/Backend_OneLanguage/security/jwt/JwtAuthenticationFilterTest.java:58 (JWT vencido devuelve 401) y auth/service/imple/AuthServiceImpleTest.java:98.`)
- Cabeceras de seguridad y CSP estricta en el nginx del frontend y cabeceras HSTS/X-Frame/nosniff en el backend (`web/nginx.conf:9-14 y Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/security/config/SecurityConfig.java:39-46.`)
- CORS por lista blanca desde variable de entorno y sin credenciales (`Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/config/CorsConfig.java:25-29 y Backend-OneLanguage/src/main/resources/application.properties:7.`)
- Configuración externalizada con plantillas .env.example sin valores en los cuatro repos y .env ignorado (`.env.example del backend, Database y AI, y web/.env.example; .gitignore de cada repo.`)
- Migraciones Liquibase ordenadas por tipo con rollbacks versionados y arranque condicionado a un healthcheck (`05_rollbacks/ y docker-compose.yml:15-26 con pg_isready y service_healthy en propietario/OneLanguage-Database.`)
- Servicio de IA que no persiste imágenes, con /health, healthcheck de compose y .dockerignore que deja fuera datos y modelos (`web_service.py:249-251, docker-compose.yml:23-28 y .dockerignore en propietario/OneLanguage-AI.`)
- Despliegue real en línea: https://onelanguage.tech respondió HTTP 200 al GET de solo lectura del 2026-10-22 (`GET único con curl -s -m 15; dominios configurados en mobile/eas.json:13-14,22-23 de propietario/OneLanguage_Frontend.`)
- Backend con capas claras y controladores delgados (`Backend-OneLanguage/src/main/java/com/sena/Backend_OneLanguage/translation/controller/TranslationController.java`)
- README del backend específico, con tabla de endpoints coherente con el código y sin promesas falsas (aclara qué no existe) (`README.md`)
- Sesión web bien resuelta: expiración del token verificada, interceptor 401 con cierre de sesión, rutas protegidas y confirmación de logout (`web/src/services/authSession.js:29`)
- Estados de carga, error y vacío diseñados en el historial web y móvil (`web/src/pages/history/History.jsx:167`)
- El componente de cámara móvil traduce cada fallo (cámara, modelo, guardado) a un estado visible y reconecta el WebSocket solo (`mobile/app/(auth)/camera.tsx:181`)
- Producto accesible por diseño: 4 idiomas, tema y tamaño de texto sincronizados con el backend y aria-live en la traducción web (`web/src/pages/translate/Translate.jsx:340`)
- Entorno de base de datos reproducible con un comando: compose con healthcheck y Liquibase en espera del servicio saludable (`docker-compose.yml`)
- README del servicio de IA muy completo (funcionamiento, dataset, evaluación, Docker, diagnóstico) y compose con healthcheck y modelo montado como volumen de solo lectura (`README.md`)
- Disciplina de ramas por historia (HU-01 a HU-25), feature branches todas integradas en dev y aportes equilibrados 51 y 49 % (`git shortlog -sne --all --no-merges; git rev-list --count origin/dev..origin/security/add-http-security-headers = 0`)

## Lo que no se pudo verificar

- Documentacion de arquitectura, 05-architecture, 06-data y ADR del equipo (T-3.1, T-3.6) — Documentacion en Drive no accesible desde el repositorio. Segun la regla de la ficha corresponde ademas un hallazgo medio de D12 que debe registrar el especialista C.
- Arranque real del backend contra el esquema (spring.jpa.hibernate.ddl-auto=validate) y tipos TIMESTAMP frente a OffsetDateTime — Exigiria ejecutar Maven y PostgreSQL; esta prohibido ejecutar el codigo de los aprendices.
- Levantado desde cero de la base con docker compose y ejecucion de los 21 changesets — Exigiria ejecutar Docker; se verifico solo de forma estatica (rutas, ids, orden y rollbacks).
- OpenAPI generado por springdoc y su coherencia con los controladores — Requiere arrancar el backend; solo se comparo la tabla de rutas del README con los controladores.
- Despliegue en linea (onelanguage.tech y ai.onelanguage.tech) y T-14.3 — El equipo no declara URL de despliegue; los dominios solo aparecen en web/nginx.conf y web/Dockerfile del frontend, por eso no se consultaron.
- Calidad y etiquetas del modelo de reconocimiento y envio real del correo SMTP — El modelo no esta en ningun repositorio y el SMTP exige credenciales y ejecucion.
- Para el especialista B (D5): clave de base de datos en texto claro (««redactado»») en docker/documentacion.md lineas 38, 57, 75 y 184 de OneLanguage-Database en dev, y en docker-compose.yml y docker/documentacion.md de main y qa — Es un tema de seguridad fuera de las dimensiones D14, D3, D8 y D9; se deja anotado para que se revise tambien el historial.
- Para el especialista B (D5): POST /auth/forgot-password responde 400 con el texto No existe un usuario con ese correo (enumeracion de cuentas); Swagger UI sin autenticacion y spring.jpa.show-sql=true en application.properties:20 — Fuera de mis dimensiones; observado al leer el flujo de recuperacion y la configuracion.
- Si la clave JWT y la contraseña de BD del historial siguen vigentes en producción — Exige acceder al servidor o probar credenciales contra servicios reales, fuera del permiso de solo lectura.
- Vulnerabilidades reales de las dependencias (Maven, npm, pip) — No se ejecutan mvn, npm audit ni pip-audit; las observaciones de versiones salen de la lectura de los manifiestos y de avisos públicos conocidos.
- Que las 29 pruebas del backend pasen y su cobertura — No se ejecuta código del equipo (mvnw test); se evaluó por lectura.
- Backend desplegado (/actuator/health, /v3/api-docs, cabeceras reales) y servicio de IA en ai.onelanguage.tech — Solo se autorizó un GET a la URL de despliegue; se hizo uno a https://onelanguage.tech (200). No hay evidencia de que el backend o la IA respondan en producción.
- Proxy inverso, TLS, protección de ramas y secret scanning de GitHub — No hay configuración en los repos ni documentación; la carpeta de Drive del equipo (documentación) no es accesible desde el evaluador.
- Saturación real del servicio de IA por conexiones simultáneas — Exige ejecutar y cargar el servicio; el hallazgo H-B03 se infiere del código.
- D11 IoT y firmware — Ningún repositorio del equipo es de tipo iot; todos los ítems son NA.
- Documentación de producto y arquitectura (carpeta de Drive declarada por el equipo) — Documentación en Drive no accesible desde el repositorio; R-12.1 (x4), T-12.3 y T-12.4 quedan NV y se registra el hallazgo H-C07.
- R-10.1: que web y móvil compilen — Exige npm install y vite build o expo, prohibido ejecutar. Solo se verificó de forma estática (scripts, lockfiles, importaciones relativas y dependencias declaradas).
- Muestreo D4 por tamaño: se leyeron con profundidad los 2 componentes más grandes del equipo, mobile/app/(auth)/camera.tsx (529 líneas) y recognizer.py (502 líneas) — Backend (mayor clase 189 líneas) y Database solo se revisaron por muestreo de controlador, manejador de excepciones y configuración; los hallazgos D4 de esos repos son por búsqueda dirigida, no lectura completa.
- Despliegue en línea: el dominio onelanguage.tech aparece en mobile/eas.json y web/nginx.conf pero el equipo no declara ninguna URL de despliegue — Solo se permite un GET contra una URL que el equipo declare; no se hizo. T-7.4 y T-14.3 no son de este especialista.
- Comportamiento real de la imagen web detrás de un proxy, y de H-C03 y H-C05 — Inferidos de la configuración; comprobarlos exige construir y ejecutar contenedores.
- Colaboradores y protección de ramas — gh api repos/.../collaborators devolvió 403 (se requiere permiso de escritura) y branches/main/protection devolvió 404 (no se distingue 'sin protección' de 'sin permiso').
- Tablero de GitHub Projects o seguimiento de HU fuera de GitHub — No consultable por la API con los permisos de solo lectura; T-13.7 se evalúa solo por issues (0).
- Fechas de commit — Las fechas de autor se tomaron tal cual; no se puede descartar que se hayan editado, aunque la cadencia semanal casi idéntica entre repos sugiere entregas sincronizadas.
- Segunda cuenta de algún integrante — No se detectó; en el repo de IA todos los commits son de Integrante 2 y Integrante no figura como autor.
