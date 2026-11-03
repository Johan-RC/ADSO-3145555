# Equipo 10 · SRD — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 72/100 · Juicio A**

## Veredicto

Los cinco flujos principales (acceso con segundo factor, personas, tesorería, inventario y calendario con aviso) quedaron verificados como completos de la pantalla a la tabla, con contratos coherentes, datos aislados por servicio y dinero en centavos con idempotencia. Lo que falta es entrega: main y qa están vacíos y todo vive en dev, el historial son 4 instantáneas, no hay integración continua ni camino de despliegue, y los servicios corren con php -S de un solo proceso. No hay hallazgos bloqueantes ni críticos; quedan 5 altos (rama, historial, CI, servidor y contrato OpenAPI desfasado) y 17 medios, entre ellos la brecha de aceptación formal de requisitos y la llave HMAC compartida, que la verificación bajó de alto a medio. El puntaje es 72,3 con juicio A, solo 2,3 puntos por encima del umbral de 70, así que conviene cerrar primero la rama, la CI y el contrato para no quedar por debajo.

## Plan para cerrar las brechas

1. **Promover el trabajo de dev a main y qa mediante PR, definir el flujo de ramas y un procedimiento de despliegue y rollback por escrito; desde ahora trabajar con commits incrementales en lugar de instantáneas.** (esfuerzo M) — se cierra cuando: main y qa contienen el mismo código entregable que dev, el último merge llegó por PR, el historial nuevo tiene commits incrementales y existe un documento de despliegue y rollback probado una vez en un ambiente.
2. **Crear un pipeline de CI que ejecute las 302 pruebas PHP, el lint y un subconjunto de los specs Playwright en cada PR, proteger main con ese chequeo y abrir issues para el trabajo pendiente.** (esfuerzo M) — se cierra cuando: Cada PR muestra el pipeline en verde o rojo, main exige el chequeo y existen issues enlazados a los PR.
3. **Reemplazar php -S por php-fpm con nginx en imágenes multi-etapa, correr sin root y reducir el tiempo de espera del gateway.** (esfuerzo M) — se cierra cuando: Los Dockerfile usan php-fpm, el proceso no corre como root y una prueba de carga con llamadas simultáneas no bloquea el gateway.
4. **Sincronizar OpenAPI, trazabilidad, README y diccionario de datos con el código y agregar una verificación automática del contrato.** (esfuerzo M) — se cierra cuando: El contrato OpenAPI coincide con las rutas del gateway verificado en CI y el README, la trazabilidad y el diccionario reflejan chat, exportaciones y el modelo actual.
5. **Cerrar un MVP de 8 a 12 RF Must con evidencia de punta a punta (spec verde sobre la imagen final), actualizar los estados Pendiente desactualizados, declarar el resto fuera de esta entrega y definir indicadores de éxito medibles con más de un criterio de aceptación por requisito.** (esfuerzo L) — se cierra cuando: docs/requirements.json marca esos RF como aceptados con enlace a su spec verde, el resto como fuera de alcance, y hay al menos 3 KPI medibles.
6. **Reforzar la seguridad: llaves por servicio o firma asimétrica con emisor verificado, cookie Secure con TLS obligatorio y HSTS, claves de prueba fuera del repositorio y límite de intentos que no bloquee a terceros.** (esfuerzo M) — se cierra cuando: Cada servicio verifica el emisor con su propia llave, la cookie sale con Secure y HSTS, no hay claves constantes versionadas y un test demuestra que intentos fallidos ajenos no bloquean al usuario legítimo.
7. **Agregar política de tratamiento de datos personales con referencia a la Ley 1581 de 2012 y exponerla en la aplicación.** (esfuerzo S) — se cierra cuando: Existe la política en el repositorio, se enlaza desde el login y el registro de personas y cita la Ley 1581.
8. **Probar contra MySQL en CI, activar rollback en migraciones o documentar el plan de reversa, agregar claves foráneas y ON DELETE explícitos y limpiar el árbol database/ vacío.** (esfuerzo L) — se cierra cuando: Las pruebas corren sobre MySQL con cobertura medida, las migraciones tienen down o plan escrito y las relaciones de un servicio tienen FK con política declarada.
9. **Manejar la sesión vencida redirigiendo a Login, retirar o implementar la sección Descargas y completar .env.example con las 9 variables que exige compose.yaml.** (esfuerzo S) — se cierra cuando: Con una sesión expirada la web vuelve a Login sin pantalla de error, Descargas no aparece vacía y un clon limpio levanta con cp .env.example .env.
10. **Unificar los clientes móviles, dividir los componentes web grandes, traducir los mensajes de validación indicando el campo, retirar la ruta huérfana de releases y normalizar las convenciones REST.** (esfuerzo L) — se cierra cuando: Hay un solo cliente móvil, validaciones en español con el campo señalado, sin ruta huérfana y los errores salen de un único manejador.
11. **Subir los diagramas fuente al repositorio, depurar los documentos bitácora y los ADR duplicados, quitar binarios repetidos y sostener un ritmo semanal de commits.** (esfuerzo M) — se cierra cuando: Los diagramas existen como fuente en docs/, los ADR tienen numeración única, no hay binarios duplicados y hay commits en cada semana restante.

## Verificación independiente

Hallazgos confirmados: 2 · matizados: 2 · refutados: 0 · duplicados fusionados: 3.

Confirme los 4 items PASS (T-14.1, R-5.1, T-3.3, R-8.1) y los 5 flujos como COMPLETO tras retrazarlos por codigo, y confirme el aporte (7 commits de Integrante 1; la fusion con Integrante es valida por mismo correo y mismo login). De la muestra de hallazgos confirme H-02 y H-06 (alto; H-06 cuenta 141 archivos Playwright cuando son 140 specs) y matice H-01 y H-04 a medio: H-01 es una brecha de aceptacion formal con estados 'Pendiente' ya desactualizados frente al codigo, y H-04 es real (InternalAuth.php:62, una sola INTERNAL_KEY) pero exige comprometer antes un servicio y hay controles de audiencia, ruta, hash y nonce. De los 16 pares solo 3 son duplicados reales (H-02/H-07, H-05/H-21, H-29/H-30); los otros 13 son defectos distintos.

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Completo | Acceso a una junta con segundo factor (login y verificacion) | — |
| Completo | Registrar una persona de la junta | — |
| Completo | Registrar un asiento de tesoreria (ingreso o egreso) | — |
| Completo | Dar de alta un bien de inventario | — |
| Completo | Crear un evento de calendario con participantes y recibir el aviso | — |

## Hallazgos

### [Alto] H-02 · main y qa están vacíos: todo el trabajo entregable vive solo en dev
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado; también reportado como H-07
- **Evidencia:** `README.md; git rev-list --count origin/main = 1 (4d4a74e); origin/dev = 0da0c9c, 6 commits adelante`
- **Por qué importa:** La rama por defecto es main y solo tiene el commit inicial con un README de 2 líneas. Quien abra el repositorio, un revisor o un despliegue desde main recibe un proyecto vacío; si se borra o rompe dev, no hay copia integrada. qa existe pero apunta al mismo commit que main.
- **Cómo cerrarlo (S):** Fusionar dev en main mediante un Pull Request (aunque sea autorrevisado), proteger main, usar qa como rama de pruebas real o eliminarla, y declarar en el README qué rama es la entregable.

### [Alto] H-03 · Historial aplastado en 4 instantáneas v1 a v4 de hasta 536 archivos
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/TRAZABILIDAD.md; docs/INFORME-AVANCE-SRD-2026-09-21.md; git log --shortstat (466, 536, 231 y 294 archivos por commit)`
- **Por qué importa:** Semanas de trabajo con entradas fechadas día a día en la documentación (4, 5, 7, 8 y 13 al 19 de octubre) aparecen como 4 commits de 12 000 a 130 000 líneas y mensajes sin significado. No se puede revisar qué cambió, cuándo, ni revertir o hacer bisect; tampoco demostrar autoría y ritmo de trabajo.
- **Cómo cerrarlo (M):** Desde ahora un commit por cambio lógico con mensaje descriptivo (Conventional Commits: feat(records): ..., fix(web): ...), en ramas de funcionalidad con PR. El historial pasado no se puede reconstruir; declararlo en el README del proceso.

### [Alto] H-05 · Todos los servicios, incluido el gateway, se sirven con el servidor integrado de PHP de un solo proceso mientras el gateway espera hasta 90 s por llamada
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-21
- **Evidencia:** `docker/php.Dockerfile:18`
- **Por qué importa:** El CMD de la imagen unica es php -S 0.0.0.0:8000 para el gateway y los diez servicios, y no se define PHP_CLI_SERVER_WORKERS en ningun archivo. El servidor integrado atiende una peticion a la vez salvo que se configuren procesos; el gateway admite login con espera de 30 s y adjuntos de chat con 90 s (services/gateway/app/Http/Controllers/GatewayController.php:63 y :302) y el chat acepta JSON de hasta 14 MB en base64 (services/chat/app/Http/Controllers/ChatController.php:66). Una subida o un correo lento bloquea al resto de usuarios del gateway. La limitacion de concurrencia es de la arquitectura de ejecucion, no del dominio. No se midio bajo carga; la consecuencia se infiere del comportamiento documentado del servidor integrado.
- **Cómo cerrarlo (M):** Servir cada servicio con PHP-FPM + nginx, FrankenPHP u Octane (o al menos PHP_CLI_SERVER_WORKERS) y mover los adjuntos a subida multiparte directa a files en lugar de JSON base64 a traves del gateway. Medir con la prueba de carga que el README dice que falta.

### [Alto] H-06 · No existe integración continua: 302 pruebas PHP y 141 archivos Playwright nunca se ejecutan automáticamente
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A11 · **Verificación independiente:** confirmado
- **Evidencia:** `scripts/Test.ps1:1`
- **Por qué importa:** El repositorio no tiene .github/workflows en main, qa ni dev y la API de GitHub devuelve 0 flujos y 0 ejecuciones. La suite es excelente pero depende de que una sola persona la corra a mano en Windows; ninguna fusión o push se bloquea ante una regresión, y no hay evidencia verificable de que dev pase hoy.
- **Cómo cerrarlo (M):** Crear .github/workflows/ci.yml que en cada push y PR ejecute composer install + phpunit por servicio (matriz de 11 servicios), npm ci + build de apps/web y jest de apps/mobile, y publique el resultado. Dejar Playwright con Compose en un job nocturno.

### [Alto] H-08 · El contrato OpenAPI esta desfasado respecto al codigo y nada lo verifica
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `contracts/gateway.openapi.json:6`
- **Por qué importa:** Comparacion automatica de rutas y metodos: el gateway implementa 155 operaciones (services/gateway/routes/web.php) y unas 44 no estan en contracts/gateway.openapi.json (carpetas, documentos de carpeta, llamadas de voz y señales, privacy-requests, system/services, busqueda y fijado de chat, export-jobs de personas). A nivel de servicio chat.openapi.json cubre 9 de 23 rutas, files 13 de 35 y records 26 de 35. La descripcion del contrato (linea 6) afirma que archivos y otros dominios aun no estan expuestos. Los contratos se generan con scripts escritos a mano (tools/contracts.mjs, tools/contracts-files.mjs) y no hay prueba que compare contrato y rutas. Quien integre un cliente nuevo no puede fiarse del contrato; los documentos (docs/CARPETAS.md, docs/DOCUMENTOS-PRIVADOS.md) si describen esas rutas.
- **Cómo cerrarlo (M):** Generar el contrato desde las rutas reales (o agregar una prueba de CI que falle cuando route:list y el OpenAPI difieran), completar chat, files y records y corregir la descripcion. Retirar de los contratos las rutas que ya no existan.

### [Medio] H-01 · Ningún requisito está aceptado: 47 RF Parciales, 9 Pendientes, 18 RNF y 20 CU sin validar
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** matizado (severidad ajustada de alto)
- **Evidencia:** `propietario/SRD-v1: docs/requirements.json; docs/TRAZABILIDAD.md; docs/PENDIENTES-WEB-2026-10-16.md`
- **Por qué importa:** El propio equipo declara que la web no está aceptada al 100 %, que 3 de 10 criterios de UX siguen abiertos, que de 140 specs solo 33 se repitieron sobre la imagen final y que Windows y Android son parciales. Con la entrega cerca, el sistema no tiene un conjunto de requisitos mínimo cerrado que pueda llamarse entregable.
- **Cómo cerrarlo (L):** Acordar un MVP de 8 a 12 RF Must, cerrarlos de punta a punta con evidencia (spec verde sobre la imagen final) y marcar el resto como fuera de esta entrega.

### [Medio] H-04 · Toda la confianza entre servicios descansa en una sola llave HMAC compartida y en un emisor autodeclarado
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A04 · **Verificación independiente:** matizado (severidad ajustada de alto)
- **Evidencia:** `packages/php/src/InternalAuth.php:62`
- **Por qué importa:** InternalClient firma con la misma llave INTERNAL_KEY en los 11 servicios (packages/php/src/InternalClient.php:39; 20 menciones en compose.yaml) e InternalAuth acepta como emisor valido a gateway, identity, configuration, records y audit para cualquier ruta (InternalAuth.php:62), leyendo el emisor del propio cuerpo firmado. Quien comprometa un servicio de menor privilegio, por ejemplo files, que procesa archivos subidos, puede acunar un contexto con emisor gateway, cualquier rol y cualquier organization_id y llamar a tesoreria, registros o identidad. El control por audiencia, metodo, ruta, hash y nonce protege contra repeticion, no contra un servicio comprometido. Verificado leyendo el codigo; no se explotó.
- **Cómo cerrarlo (M):** Una llave por par emisor-destino (o claves asimetricas por servicio con la publica en el destino) y mover la lista de permisos entre servicios de InternalAuth.php:25-61 a configuracion por servicio, sin la rama general para gateway, identity, configuration, records y audit. Agregar una prueba que falle si un servicio firma con un emisor que no le corresponde.

### [Medio] H-09 · Una sesión que vence a mitad de uso deja la pantalla con error sin salida a Login; no hay enrutador
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `apps/web/src/api.ts:78; apps/web/src/App.tsx:132; apps/web/src/App.tsx:254; apps/web/src/ui.tsx:8`
- **Por qué importa:** api() lanza ApiError(401) y solo el arranque (App.tsx:132) lo trata como ir a Login. En cualquier pantalla posterior, ErrorBox muestra Debes iniciar sesión y el usuario queda atrapado hasta recargar; solo Chat tiene un evento propio (Chat.tsx:67). Además la navegación es un estado interno (page en App.tsx:83): recargar vuelve a Home, el botón Atrás sale de la app y ninguna sección tiene URL compartible (solo /invite y /j/código).
- **Cómo cerrarlo (M):** Centralizar en api.ts un manejador de 401 que limpie el principal y muestre sesión expirada en Login (con 403 a una pantalla propia), y adoptar un enrutador (React Router o hash) con rutas por sección y una pantalla 404.

### [Medio] H-10 · Componentes de la web muy grandes con llamadas a API dentro de las pantallas
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `apps/web/src/Persons.tsx:368; apps/web/src/Persons.tsx:403; apps/web/src/App.tsx:76; apps/web/src/App.tsx:139`
- **Por qué importa:** Persons() reúne unas 430 líneas, 25 useState y 4 efectos que llaman api() directamente; App() hace composición, carga de foto, logo y permisos con fetch y localStorage en el mismo archivo de 1073 líneas. El estándar de frontend del marco limita los archivos a 300 líneas y separa servicios y hooks. Cada cambio de una pantalla corre el riesgo de romper otra y es difícil de probar con unidad.
- **Cómo cerrarlo (L):** Extraer hooks por responsabilidad (usePersons, usePersonExport, usePrincipalAssets) y un módulo de servicios, tipar las respuestas (quitar Record<string, any>) y partir style.css e i18n.ts por feature.

### [Medio] H-11 · El producto no declara indicadores de éxito medibles y cada requisito tiene un solo criterio de aceptación
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/docs-entregables/Word/03_SRD_Propuesta_Tecnica.docx; docs/docs-entregables/Word/01_SRD_Especificacion_de_Requisitos_SRS.docx; docs/requirements.json`
- **Por qué importa:** El problema (dispersión de registros), los usuarios y el alcance sí están declarados, pero los beneficios se difieren al piloto sin asignar porcentajes que todavía no se han medido y no hay KPIs con fórmula, línea base y meta; solo RNF-001 tiene una meta numérica. Los 56 RF traen un único criterio CA-RF cada uno y solo prioridad Alta o Media, sin MoSCoW ni historias Como-quiero-para. No se puede decidir cuándo el producto es un éxito.
- **Cómo cerrarlo (M):** Definir 3 o más KPIs (p. ej. minutos por planilla, duplicados detectados, tiempo de cierre de tesorería) con línea base y meta, y ampliar a 2 o más criterios los RF Alta con una prioridad MoSCoW.

### [Medio] H-12 · La documentación no depende de Drive, pero los diagramas de arquitectura solo están dentro de Word/PDF
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `docs/docs-entregables/Word/03_SRD_Propuesta_Tecnica.docx; docs/ARQUITECTURA.md`
- **Por qué importa:** La regla de Drive no aplica porque todo el expediente está en el repositorio (fortaleza). Sin embargo los diagramas son imágenes dentro de binarios: no se revisan en un PR ni se ven en GitHub, y su vigencia frente a compose.yaml no pudo comprobarse.
- **Cómo cerrarlo (S):** Versionar el diagrama de componentes como Mermaid o SVG en docs/ARQUITECTURA.md y enlazarlo desde el README.

### [Medio] H-13 · Actividad en 3 de las 8-9 semanas y con huecos de hasta 14 días
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/SRD-v1: datos-git.json (equipo 10: W39=2, W41=4, W43=1); git log --all --format=%ad`
- **Por qué importa:** Sin commits entre el 27-ago y el 22-sep, ni del 22-sep al 6-oct (14 días), ni del 9 al 19-oct (10 días); el último commit es del 19-oct. A tres días del corte, el ritmo observable no demuestra trabajo sostenido ni permite detectar bloqueos a tiempo.
- **Cómo cerrarlo (S):** Publicar avances al menos semanalmente (push de ramas de funcionalidad) y tener issues con fechas para que el avance sea visible desde GitHub.

### [Medio] H-14 · Sin PR, sin issues y sin CI: la planeación está solo en Markdown
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/SRD-v1: docs/PENDIENTES-WEB-2026-10-16.md; docs/TRAZABILIDAD.md; gh api repos/propietario/SRD-v1/pulls e issues = 0`
- **Por qué importa:** Hay seguimiento serio de 56 RF y de los pendientes, pero está en archivos de hasta 347 KB (docs/VALIDACION.md) y no en issues o tablero: no hay estado por tarea, responsable ni cierre trazable a un commit. Sin PR, ningún cambio pasa por revisión ni por una verificación automática.
- **Cómo cerrarlo (M):** Crear un issue por cada RF Pendiente o Parcial (56 en docs/requirements.json), enlazarlos a PR y a un tablero; reducir la bitácora de docs a un resumen.

### [Medio] H-15 · .env.example incompleto: faltan 9 variables que compose.yaml exige
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `compose.yaml; .env.example; tools/initialize.mjs:22`
- **Por qué importa:** compose.yaml exige APP_KEY y DB_PASSWORD de chat, inventory, notifications y treasury y REVERB_APP_SECRET, y el .env.example raíz no las lista; solo 5 de 10 servicios tienen su .env.example. Quien no use scripts/Initialize.ps1 no sabe qué falta, y los demás sistemas operativos no tienen camino.
- **Cómo cerrarlo (S):** Generar .env.example desde la lista que ya conoce tools/initialize.mjs, y añadir un camino equivalente en shell para Linux y macOS.

### [Medio] H-16 · La trazabilidad y el README dicen que el chat, las exportaciones extensas y la privacidad no estan implementados, pero el codigo los tiene
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/requirements.json:410`
- **Por qué importa:** docs/requirements.json marca como Pendiente y no implementado RF-041 (enviar y conservar mensajes), RF-042 (adjuntos y notas de voz), RF-043 (estados de entrega y lectura), RF-044 (llamadas de voz), RF-036 y RF-037 (fichas y exportaciones extensas), RF-052 y RF-053 (movil y paridad) y RF-054 (privacidad y supresion). El codigo tiene chat con recibos y adjuntos (services/chat/database/migrations/2026_10_11_000001_message_attachments.php), llamadas (services/chat/database/migrations/2026_10_12_000001_create_voice_calls.php), trabajos de exportacion (services/records/database/migrations/2026_10_11_000001_person_export_jobs.php) y solicitudes de privacidad (services/records/database/migrations/2026_10_11_000003_privacy_requests.php). README.md:39 sigue diciendo que faltan adjuntos y notas de voz. Ninguno de los 56 RF figura como cumplido (47 Parcial, 9 Pendiente), asi que el estado real de avance no se puede leer de la documentacion.
- **Cómo cerrarlo (S):** Actualizar requirements.json y el README desde el codigo (estado por RF con enlace a ruta y prueba) y anadir al cierre de cada entrega un paso que revise esa tabla.

### [Medio] H-17 · El diccionario de datos del documento de diseno ya no corresponde al modelo implementado
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/docs-entregables/Word/04_SRD_Diseno_del_Software.docx`
- **Por qué importa:** Seccion 5 del documento 04: 50 tablas, 19 con nombre exacto en las migraciones; no existen roles, permissions, role_permissions, membership_grants, processed_events, idempotency_requests, report_templates, suppression_orders ni releases, y 34 tablas reales no estan descritas (voice_calls, folder_documents, privacy_request_history, security_notices...). Los permisos por rol son una matriz fija en codigo (packages/php/src/Access.php:12-30), no datos. Los nombres de base documentados (db_auth, db_registros) no son los reales (srd_identity, srd_records, en database/03_dcl/01_grants/initialize-services.sh:10). El documento sostiene que las migraciones son la referencia ejecutable, lo cual reduce el dano, pero un modelo documentado distinto del real impide revisar el diseno.
- **Cómo cerrarlo (M):** Regenerar el diccionario desde information_schema o las migraciones y marcar en el documento lo que es diseno futuro; registrar como ADR la decision de dejar los permisos en codigo.

### [Medio] H-18 · La cookie de sesión se emite sin Secure y TLS es opcional; nginx-tls.conf no define HSTS
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `compose.yaml:28`
- **Por qué importa:** SESSION_SECURE_COOKIE está en false en el gateway y los demás servicios del compose (compose.yaml:28, :96, :153) y el modo HTTPS es un perfil opcional con certificado autofirmado (docker/nginx-tls.conf). Si el compose se despliega tal cual, la cookie con la credencial de sesión viaja por HTTP y puede interceptarse. Es el único punto que invalida lo bueno de la autenticación del gateway.
- **Cómo cerrarlo (S):** Hacer SESSION_SECURE_COOKIE=true por defecto en el perfil de producción, redirigir 80 a 443 y añadir Strict-Transport-Security en docker/nginx-tls.conf.

### [Medio] H-19 · Datos personales tratados sin política de tratamiento ni referencia a la Ley 1581 de 2012
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/SUPRESIONES.md:3`
- **Por qué importa:** El sistema guarda fichas de personas, fotos, notas y documentos de juntas, pero git grep de '1581' no encuentra ninguna coincidencia y no existe política de tratamiento, finalidad, aviso de privacidad ni procedimiento de consultas y reclamos. Las copias cifradas conservan datos ya suprimidos, límite reconocido en docs/SUPRESIONES.md. La base técnica (supresión, aislamiento por junta, auditoría) existe; falta el marco legal que la hace defendible.
- **Cómo cerrarlo (S):** Redactar docs/TRATAMIENTO-DE-DATOS.md con responsable, finalidades, derechos del titular y plazos de la Ley 1581, enlazarlo desde los términos que se aceptan en el login, y definir la caducidad de las copias de seguridad.

### [Medio] H-20 · Las pruebas PHP corren sobre SQLite en memoria, no sobre MySQL, y no se mide cobertura ni hay pruebas unitarias puras
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:112`
- **Por qué importa:** README.md:112 dice que PHPUnit usa SQLite en memoria; la base real es MySQL, de modo que índices, restricciones, bloqueos (lockForUpdate en AuthController.php:39) y tipos solo se ejercitan con scripts manuales como scripts/Test-MySqlIsolation.ps1. No hay carpeta tests/Unit ni configuración de cobertura, así que no se sabe qué porcentaje de las 11 aplicaciones queda cubierto. Parte de los recorridos Playwright se saltan según la variable de entorno (tools/browser-tests/platform.spec.mjs:5).
- **Cómo cerrarlo (M):** Añadir un job de CI con servicio MySQL 8.4 para correr al menos identity, records y treasury contra la base real, activar cobertura (pcov) con umbral mínimo y registrar los test.skip que quedan.

### [Medio] H-22 · 45 de 71 migraciones desactivan el rollback y no hay plan de reversa por escrito en database/
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `services/records/database/migrations/2026_09_07_000002_records.php:60`
- **Por qué importa:** El metodo down() de 45 migraciones lanza RuntimeException con el texto Rollback destructivo deshabilitado (por ejemplo services/records/database/migrations/2026_09_07_000002_records.php:60). Las otras 26 si tienen down() real. Las carpetas database/05_rollbacks/01_ddl a 04_tcl solo contienen README. Una migracion defectuosa en un servicio solo se corrige con restauracion de respaldo (docs/RESPALDOS.md) o con una migracion nueva hacia adelante; ese procedimiento no esta descrito por migracion.
- **Cómo cerrarlo (M):** Escribir down() reversible donde no haya perdida de datos y, donde no se pueda, documentar en la propia migracion el plan de reversa (consulta de reversion o restauracion) y probarlo en el simulacro de respaldo.

### [Medio] H-23 · Relaciones dentro de un mismo servicio sin clave foranea y casi sin politica ON DELETE explicita
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `services/files/database/migrations/2026_09_27_000002_create_folder_documents.php:9`
- **Por qué importa:** folder_documents.folder_id (linea 9) no referencia a internal_folders; internal_folders.parent_id (services/files/database/migrations/2026_09_27_000001_create_internal_folders.php:12), message_actions.message_id (services/chat/database/migrations/2026_10_14_000001_message_actions.php:16) y privacy_request_history.request_id (services/records/database/migrations/2026_10_11_000003_privacy_requests.php:29) tampoco. Solo 4 de las 31 FK declaran onDelete. Las reglas se aplican en codigo; un error de aplicacion o un script manual pueden dejar documentos huerfanos de carpeta o mensajes sin conversacion. Excepcion razonable: privacy_requests.person_id sin FK porque debe sobrevivir a la supresion de la persona.
- **Cómo cerrarlo (S):** Agregar las FK intra-servicio con ON DELETE explicito (RESTRICT para jerarquias e historiales) mediante migraciones nuevas y documentar los casos sin FK por diseno.

### [Medio] H-24 · Los mensajes de validacion por defecto salen en ingles y la interfaz no indica el campo
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `apps/web/src/ui.tsx:21`
- **Por qué importa:** No existe ningun directorio lang/ en los diez servicios ni en el gateway, aunque APP_LOCALE es es (compose.yaml:19-30), y localizedError devuelve el mensaje del servidor sin cambios en espanol (ui.tsx:21-23); en ingles reemplaza lo no reconocido por Revisa este campo (ui.tsx:39). Un usuario hispanohablante ve bajo el formulario textos de Laravel por defecto en ingles. No se ejecuto la interfaz; se verifico por lectura de codigo y por la ausencia de archivos de idioma.
- **Cómo cerrarlo (S):** Incluir lang/es (y en) con los atributos de campo en cada servicio o en un paquete compartido en packages/php, y mostrar el nombre del campo en el mensaje.

### [Bajo] H-25 · Binarios documentales duplicados y esqueleto database/ sin contenido
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/docs-entregables/PDF/04_SRD_Diseno_del_Software.pdf; docs/docs-entregables/Word/04_SRD_Diseno_del_Software.docx; database/01_ddl/03_tables/README.md; tools/refactor-records-once.mjs`
- **Por qué importa:** 6,8 MB de los mismos 12 documentos en Word y PDF inflan cada clon, database/ contiene 25 README sin SQL junto a las migraciones reales en services/*/database, y queda un script de un solo uso. No rompe nada, pero confunde a quien busca el esquema.
- **Cómo cerrarlo (S):** Conservar un formato o publicarlos como release, documentar en database/ dónde están las migraciones reales y retirar tools/refactor-records-once.mjs.

### [Bajo] H-26 · La sección Descargas del menú es una pantalla vacía permanente
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `apps/web/src/App.tsx:542; apps/web/src/App.tsx:553`
- **Por qué importa:** Todo usuario ve la entrada Descargas que solo dice que todavía no hay instaladores. Es un callejón sin salida en el menú principal; los clientes Windows y Android existen en el repo pero no hay forma de obtenerlos desde la web.
- **Cómo cerrarlo (S):** Ocultar la sección hasta que haya paquetes firmados, o enlazar los instaladores (o las instrucciones de docs/MOVIL.md y docs/ESCRITORIO.md).

### [Bajo] H-27 · Documentación como bitácora: archivos de cientos de KB, ADR con números repetidos y párrafos que el propio equipo marca como superados
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/VALIDACION.md; docs/ARQUITECTURA.md:3; docs/ARQUITECTURA.md:7; docs/ARQUITECTURA.md:25; docs/WEB_ACEPTACION.md`
- **Por qué importa:** TRAZABILIDAD.md acumula decenas de párrafos fechados antes de su matriz; ARQUITECTURA.md repite ADR-018 y ADR-019 dos veces y los ordena de forma inversa; WEB_ACEPTACION.md admite que algunos párrafos están superados. Cuesta encontrar la verdad vigente y se pierde confianza en el resto.
- **Cómo cerrarlo (S):** Numerar los ADR en orden, mover lo histórico a un CHANGELOG y dejar cada doc con el estado vigente y una fecha.

### [Bajo] H-28 · Ruta huerfana GET /api/v1/releases que siempre devuelve una lista vacia
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `services/gateway/routes/web.php:144`
- **Por qué importa:** El gateway responde una lista vacia sin consultar a ningun servicio (web.php:144) y ni apps/web ni apps/mobile la llaman, pero esta publicada en el contrato. Es superficie sin funcion.
- **Cómo cerrarlo (S):** Eliminar la ruta y su entrada del contrato, o implementarla cuando exista el servicio de reportes o versiones.

### [Bajo] H-30 · Dos clientes móviles duplicados y divergentes
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-29
- **Evidencia:** `apps/mobile/src/api.ts; apps/mobile-expo/src/api.ts; apps/mobile/App.tsx; apps/mobile-expo/App.tsx`
- **Por qué importa:** apps/mobile (React Native desnudo) y apps/mobile-expo repiten el mismo src/ con diferencias pequeñas; cada corrección hay que hacerla dos veces y ya difieren (api.ts, connection.ts, Agenda.tsx). La documentación señala que ninguno está aceptado.
- **Cómo cerrarlo (M):** Elegir una base (la variante Expo declarada para demostración) y extraer lo común a un paquete compartido, o eliminar la otra.

### [Bajo] H-31 · Claves de aplicación de prueba constantes versionadas y MySQL sin contraseña en el compose de pruebas
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker/files-api.compose.yaml:25`
- **Por qué importa:** El APP_KEY ««redactado»» es un valor obvio repetido en docker/files-api.compose.yaml:25 y en los services/*/phpunit.xml, y el MySQL del compose de pruebas usa MYSQL_ALLOW_EMPTY_PASSWORD (docker/files-api.compose.yaml:5). Está en una red internal y solo para pruebas, por lo que no es explotable, pero un escáner de secretos lo marcará y alguien podría copiarlo a un entorno real.
- **Cómo cerrarlo (S):** Generar la clave al vuelo en el script de prueba o marcarla explícitamente como de prueba y añadir una excepción documentada al escáner de secretos.

### [Bajo] H-32 · El límite de intentos de login se cuenta por correo antes de validar la contraseña, lo que permite bloquear a otra persona
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `services/identity/app/Http/Controllers/AuthController.php:36`
- **Por qué importa:** La clave de RateLimiter es el hash del correo (AuthController.php:35) y se incrementa en cada intento (línea 37) con ventana de 300 s y tope de 10: cualquiera que conozca el correo de un miembro puede mandar 10 peticiones y dejarlo sin poder entrar 5 minutos. Se infiere de la lectura del código sin ejecutarlo.
- **Cómo cerrarlo (S):** Combinar correo e IP en la clave de límite y aplicar retardo progresivo en lugar de bloqueo duro, manteniendo el límite global por IP que ya existe en el gateway.

### [Bajo] H-33 · El arbol database/ de 31 carpetas esta vacio y conserva la estructura de un ZIP de referencia
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `database/changelog/changelog-master.yaml:15`
- **Por qué importa:** database/01_ddl a 05_rollbacks contienen solo README (database/01_ddl/03_tables/README.md aclara que no hay scripts) y el changelog dice que no se ejecute con Liquibase. La unica fuente real es services/*/database/migrations. El arbol sugiere una separacion de base de datos que el repositorio no tiene.
- **Cómo cerrarlo (S):** Eliminar las carpetas vacias o llenarlas con el DDL exportado y las politicas DCL reales; dejar un unico README en database/ que apunte a las migraciones.

### [Bajo] H-34 · Convenciones REST inconsistentes: camelCase en rutas, altas con 200 y manejador de errores copiado 11 veces
- **Repositorio:** `propietario/SRD-v1`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `services/gateway/app/Http/Controllers/GatewayController.php:52`
- **Por qué importa:** auth/revokeOthers y auth/switchOrganization (GatewayController.php:52) conviven con rutas en kebab-case; no hay ninguna respuesta 201 en services/ ni packages/ (las altas devuelven 200; contracts/gateway.openapi.json documenta solo 200 para POST /persons); el bloque withExceptions que arma la envoltura de error esta repetido en bootstrap/app.php de los 11 servicios (por ejemplo services/records/bootstrap/app.php:22).
- **Cómo cerrarlo (S):** Unificar nombres a kebab-case con alias, devolver 201 con Location en las altas y mover el manejador de errores a packages/php.

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 62.5 |
| D2 | Reproducibilidad | 85.0 |
| D3 | Arquitectura y congruencia | 67.9 |
| D4 | Calidad de código | 81.8 |
| D5 | Seguridad | 92.1 |
| D6 | Pruebas | 80.0 |
| D7 | DevOps y despliegue | 31.8 |
| D8 | Datos | 90.0 |
| D9 | API y contratos | 55.0 |
| D10 | Frontend y móvil | 87.5 |
| D11 | IoT y firmware | — |
| D12 | Documentación y trazabilidad | 61.1 |
| D13 | Proceso y colaboración | 25.0 |
| D14 | Extremo a extremo | 90.0 |

## Lo que está bien

- Los cinco flujos principales estan completos de la pantalla a la tabla y sus contratos coinciden (`apps/web/src/Treasury.tsx:93; services/treasury/app/Http/Controllers/TreasuryController.php:60; services/treasury/database/migrations/2026_09_23_000001_treasury.php:18; 170 llamadas del cliente web y movil comparadas con las rutas de services/gateway/routes/web.php`)
- Aislamiento real de datos por servicio: una base y un usuario MySQL por servicio, con permisos solo sobre su base (`database/03_dcl/01_grants/initialize-services.sh:12; compose.yaml:752`)
- Dinero en centavos enteros con idempotencia, bloqueo de cuenta y reversos por asiento nuevo (`services/treasury/database/migrations/2026_09_23_000001_treasury.php:18; services/treasury/app/Application/LedgerService.php:103`)
- Control optimista de concurrencia con columna version y respuesta 409, y outbox transaccional hacia auditoria (`services/records/app/Application/PersonService.php:225; packages/php/src/OutboxPublisher.php:22`)
- Integridad multi-junta en el esquema: FK compuestas organization_id + id para los hijos de persons (`services/records/database/migrations/2026_09_07_000002_records.php:44`)
- Entorno reproducible con un comando, imagenes fijadas por digest y semillas sinteticas con claves aleatorias (`scripts/Up.ps1:17; compose.yaml:752; tools/browser-fixture.mjs:9`)
- Envoltura de error uniforme y versionado de API en gateway y servicios, con contratos OpenAPI y esquema de evento versionado (`services/records/bootstrap/app.php:22; contracts/audit-event.v1.schema.json`)
- Honestidad documental sobre el alcance: el diseno y el README declaran que el servicio de reportes y la produccion segura no existen aun (`README.md:1; docs/docs-entregables/Word/04_SRD_Diseno_del_Software.docx`)
- Autenticación entre servicios firmada con HMAC, expiración de 60 s, nonce de un solo uso y lista cerrada de llamadas permitidas por emisor (`packages/php/src/InternalAuth.php:13`)
- Matriz de seis roles centralizada y aplicada en el servidor de cada servicio, con 272 aserciones 401/403 en pruebas (`packages/php/src/Access.php:14`)
- Login con segundo factor por correo, límite de intentos, regeneración de sesión y hash Argon (`services/identity/app/Http/Controllers/AuthController.php:33`)
- Cero secretos en árbol e historial: compose exige variables, un script genera claves aleatorias y las credenciales de prueba se generan por ejecución (`tools/initialize.mjs:7`)
- Suite de pruebas muy amplia: 302 métodos PHPUnit, 191 pruebas JS y 141 archivos Playwright con 2306 aserciones (`tools/browser-tests/playwright.config.mjs`)
- Imágenes base fijadas por digest, usuario no root en los servicios PHP, 24 healthchecks y puertos solo en 127.0.0.1 (`compose.yaml:57`)
- Cabeceras de seguridad y CSP en nginx, errores sanitizados en JSON sin trazas, APP_DEBUG=false (`docker/nginx.conf:8`)
- Supresión de datos personales ejecutable con confirmación, fotos privadas con antivirus y respaldos cifrados con prueba de restauración (`scripts/Test-BackupRestore.ps1`)
- Sistema real y extenso, no un andamiaje (`compose.yaml; services/records/app/Application/PersonService.php; apps/web/src/Persons.tsx`)
- Manejo de errores centralizado y mensajes accionables en servidor y cliente (`services/records/bootstrap/app.php; apps/web/src/api.ts; apps/web/src/ui.tsx`)
- Autenticación web por cookie con CSRF, sin acceso guardado en localStorage; consulta de sesión al arrancar (`apps/web/src/api.ts; apps/web/src/App.tsx`)
- Estados de carga, vacío y error como componentes compartidos con pruebas de navegador (140 specs) (`apps/web/src/ui.tsx; tools/browser-tests/web-error-states.spec.mjs; tools/browser-tests/web-empty-states.spec.mjs`)
- Accesibilidad y responsive cuidados: etiquetas, foco visible, diálogos nativos con Escape, auditoría a 320-1280 px, tema claro y oscuro (`apps/web/src/Login.tsx; apps/web/src/style.css; tools/browser-tests/web-layout-audit.spec.mjs`)
- Reproducibilidad cuidada: imágenes fijadas por digest, variables obligatorias, puertos solo en loopback, secretos generados al vuelo y semilla ficticia (`docker/php.Dockerfile; compose.yaml; tools/initialize.mjs; scripts/Seed-ComposeTests.ps1`)
- Capas claras en el backend (controlador, aplicación, persistencia, validación) y 11 contratos OpenAPI (`services/records/app/Http/Controllers/PersonController.php; services/records/app/Persistence/PersonRepository.php; contracts/gateway.openapi.json`)
- Expediente documental completo dentro del repo (SRS, análisis, propuesta, diseño, manuales, pruebas) con matriz de trazabilidad de 56 RF y honestidad sobre lo que falta (`docs/TRAZABILIDAD.md; docs/requirements.json; docs/docs-entregables/Word/01_SRD_Especificacion_de_Requisitos_SRS.docx`)
- Cero TODO o FIXME ocultos y cero console.log en el código muestreado (`apps/web/src/App.tsx; services/records/app/Application/PersonService.php`)

## Lo que no se pudo verificar

- Que migrate --force aplique las 71 migraciones desde cero y que los cinco flujos funcionen en ejecucion — Exigiria ejecutar Docker y el codigo de los aprendices, prohibido; los flujos se trazaron por lectura.
- Campo por campo de los esquemas OpenAPI contra los validadores de cada servicio — Solo se comparo ruta y metodo para todo el contrato y campos para los cinco flujos; revisar los 11 contratos completos excede el tiempo disponible.
- Despliegue en linea (T-14.3) — El equipo no declara URL de despliegue; solo el repositorio en la rama dev.
- Rendimiento del servidor integrado de PHP bajo carga concurrente (H-A02) — Requiere ejecutar el sistema; la consecuencia se infiere de la configuracion.
- Contenido de los demas PDF y Word de docs/docs-entregables — Solo se extrajo el texto del documento de diseno 04_SRD_Diseno_del_Software.docx.
- Resultado de scripts/Test-MySqlIsolation.ps1 — Es un script del repositorio que requiere Docker.
- Ramas qa y main frente a dev — main y qa contienen solo el commit inicial; todo el trabajo esta en dev. Es hallazgo de proceso (D13) y corresponde a otro especialista.
- Comportamiento real de CORS del gateway (valor por defecto de Laravel 12 sin config/cors.php) — Comprobarlo exige ejecutar el servicio y enviar una petición con cabecera Origin; la regla prohíbe ejecutar el código de los aprendices.
- Vulnerabilidades conocidas en dependencias (composer audit, npm audit) — Exige ejecutar herramientas de gestor de paquetes sobre el código del equipo; solo se revisaron las versiones de los lockfiles.
- Que las pruebas PHPUnit y Playwright pasen hoy en la rama dev — No hay CI ni ejecuciones en GitHub, y ejecutarlas está prohibido para el evaluador; los conteos de aserciones son estáticos.
- Despliegue público y respuesta a un GET — El equipo solo declara la URL del repositorio; no declara ningún despliegue.
- Cifrado de respaldos y comportamiento de ClamAV en la práctica — Solo se leyó la documentación y los scripts; verificarlo exige levantar Docker.
- Compilación de la web, build de Docker y ejecución de pruebas — El briefing prohíbe ejecutar el código del aprendiz; R-10.1, R-2.1 y R-2.3 se evaluaron por lectura.
- Muestreo de D4: se leyeron con profundidad los dos componentes más grandes por líneas (apps/web, 12 970 líneas, y services/records, 5 316). El directorio tools/ (16 842 líneas) es de pruebas y utilidades y no se muestreó — Presupuesto de lectura; el resto de servicios y de apps/mobile se evaluó solo por búsquedas.
- Colaboradores del repositorio y Projects v2 de Integrante 1 — La API de colaboradores responde 403 sin permiso de escritura; no se consultaron los tableros por GraphQL.
- Contenido de las imágenes y de los PDF de docs/docs-entregables (vigencia de los diagramas) y contraste de color WCAG — Solo se extrajo el texto de los .docx; no se renderizaron imágenes ni se midieron contrastes.
- Almacenamiento del acceso en apps/mobile (módulo nativo ConnectionModule.kt) — Fuera del muestreo; en apps/mobile-expo se usa expo-secure-store (apps/mobile-expo/src/connection.ts).
- Un comando de lectura con sed fue bloqueado por el guardia de gobernanza; no se insistió y se reemplazó por git grep sin sed — Bloqueo del guardia de gobernanza.
- Despliegue en línea: el equipo no declara URL de despliegue (solo la rama dev), por lo que no se hizo ningún GET — No hay URL declarada.
