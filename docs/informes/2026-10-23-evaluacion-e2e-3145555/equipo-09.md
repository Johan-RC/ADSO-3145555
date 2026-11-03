# Equipo 9 · SaborExpress — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 59/100 · Juicio D**

## Veredicto

SaborExpress funciona de punta a punta: los cinco flujos revisados (sesión, pedido de mesa, pedido a domicilio con pago, entrega y catálogo) quedaron completos tras la verificación y los contratos entre web, móvil y backend coinciden casi sin excepción. El puntaje es 59,4 (juicio D), unos 10 puntos por debajo del umbral de 70. Lo que más pesa es un hallazgo bloqueante: la clave JWT y las contraseñas de SMTP, base de datos y gerente quedaron en el historial de main y hay que rotarlas y limpiar el historial ya. Quedan cuatro hallazgos altos: un Administrador puede descargar el CV de empleados de otra sede, el backend no se puede levantar desde el repositorio (README vacío y sin .env.example), no hay pruebas de integración de autenticación y roles, y el pipeline de release está varado fuera de main. Cerrar las acciones 1 a 5 del plan elimina el bloqueante y los altos; el resto es documentación, defectos de la ruta de error del cliente y deuda de calidad, que se atienden después.

## Plan para cerrar las brechas

1. **Rotar la clave JWT, la contraseña de aplicación de Gmail, la contraseña del gerente semilla y la de PostgreSQL; reescribir el historial con git filter-repo en todas las ramas y forks; publicar un .env.example sin valores.** (esfuerzo M) — se cierra cuando: Los cuatro valores antiguos dejan de funcionar; git log --all -p no devuelve ninguno de ellos en ninguna rama y existe .env.example sin secretos.
2. **Cerrar la autorización del backend: filtrar por sede la descarga de CV, añadir [Authorize] explícito a Customers/me y validar tipo, contenido y extensión en la subida de imágenes.** (esfuerzo S) — se cierra cuando: Pruebas muestran que un Administrador de otra sede recibe 403 al pedir un CV, que Customers/me responde 401 sin token y que un archivo no imagen es rechazado.
3. **Documentar cómo levantar el sistema: README del backend (requisitos, variables, migraciones, arranque), README de móvil y web, y variables EXPO_PUBLIC_API_URL, APP_ENV y NEXT_PUBLIC_API_URL; corregir la configuración base que apunta a un túnel de desarrollo.** (esfuerzo S) — se cierra cuando: Una persona ajena al equipo clona cada repo y lo ejecuta siguiendo solo el README; la URL base nunca queda como 'undefined/api'.
4. **Integrar a main el pipeline de release, la readiness y el rollback; hacer que la CI corra sobre main y sobre push a develop; añadir CI a web y móvil; proteger el arranque que migra y siembra con una guardia; limpiar las ramas de respaldo.** (esfuerzo M) — se cierra cuando: main contiene el workflow de release; hay ejecuciones verdes de CI en main, en web y en móvil; el arranque en producción no siembra sin una bandera explícita.
5. **Escribir pruebas de integración de los flujos de autenticación (login, refresco, bloqueo) y de roles por sede, y ejecutarlas en la CI.** (esfuerzo M) — se cierra cuando: La CI ejecuta pruebas que cubren login, refresco y al menos un caso de 403 por rol y por sede, y el trabajo falla si alguna se rompe.
6. **Sacar del código la clave de teselas de MapTiler y la de Firebase (google-services.json) del móvil, leerlas de variables de entorno y restringirlas por aplicación u origen en su consola; son claves de cliente, el riesgo es consumo de cuota y no acceso a datos.** (esfuerzo S) — se cierra cuando: Una búsqueda de las claves en el árbol y en los bundles no da resultados; las claves antiguas están revocadas o restringidas por aplicación.
7. **Corregir los flujos con defecto funcional: la compensación del pedido del cliente debe usar un endpoint permitido al cliente, la pantalla de reseñas debe tener un origen que la pueble, y los fallos de efectivo, cancelación y dirección deben mostrarse al usuario.** (esfuerzo M) — se cierra cuando: Un cliente que cancela o falla en un pedido ve el error y el pedido se compensa sin 403; una reseña creada por un cliente aparece en el panel.
8. **Completar el expediente documental: agregar historias de usuario con criterios de aceptación, indicadores con meta numérica y una matriz historia-pantalla-endpoint (la acta ya declara responsable, ficha y necesidad de negocio); actualizar el modelo de datos al estado actual (quitar DailyMenu, añadir las tablas y migraciones recientes); retirar los 43 blobs duplicados y el MySQL obsoleto entidades.sql.** (esfuerzo M) — se cierra cuando: El expediente trae historias con criterios y una matriz historia-pantalla-endpoint; el modelo documentado coincide con las 29 tablas del snapshot de migraciones; no quedan duplicados.
9. **Normalizar la API: filtro de excepciones con cuerpo único, códigos correctos (500 para lo inesperado, registrado en log), paginación en los listados, versión en la ruta y OpenAPI publicado fuera de desarrollo.** (esfuerzo M) — se cierra cuando: Un error inesperado devuelve 500 con el mismo formato y queda en el log; los listados aceptan página y tamaño; el contrato OpenAPI se descarga en el ambiente desplegado.
10. **Cerrar brechas de seguridad restantes: proteger /metrics, no aceptar el JWT por URL salvo en hubs con alternativa, registrar el consentimiento de datos personales (Ley 1581) en el servidor con política operativa, y revisar el tablero público de cocina.** (esfuerzo M) — se cierra cuando: /metrics responde 401 sin credencial; existe una tabla o campo de consentimiento con fecha y versión de la política, y el tablero de cocina exige un enlace con caducidad.
11. **Mejorar la higiene del repositorio y del proceso: retirar IDE, datos subidos, capturas, notas y volcados versionados; borrar código y endpoints muertos; limpiar el historial web con inicio de sesión simulado; exigir descripción y una revisión en cada PR y mensajes de commit descriptivos.** (esfuerzo S) — se cierra cuando: git ls-files no lista archivos de IDE ni capturas; los PR nuevos tienen descripción y al menos una revisión; no hay commits con mensaje 'subir'.
12. **Reducir deuda de calidad: partir los componentes de más de 1000 líneas (ClientDashboard, SchedulesView), mover la lógica de los controladores a servicios, unificar nombres de tablas, añadir restricciones CHECK, aclarar el soporte de motores y completar la verificación responsive e idiomas con capturas.** (esfuerzo L) — se cierra cuando: Ningún componente supera 500 líneas; los controladores no inyectan repositorios; todas las tablas siguen una convención y las reglas clave tienen CHECK; existe evidencia visual por pantalla e idioma.

## Verificación independiente

Hallazgos confirmados: 3 · matizados: 2 · refutados: 0 · duplicados fusionados: 1.

Confirmé 3 de los 5 hallazgos revisados (H-01 bloqueante con el matiz de que las contraseñas de BD apuntan a localhost, H-03 y H-05) y maticé 2: H-02 baja de alto a medio porque SaborExpress_Acta_Constitucion.md sí declara responsable, ficha y necesidad de negocio y los 25 RF traen criterio de aceptación (genérico, sin historias ni KPIs), y H-04 baja de alto a medio porque es una clave de teselas de MapTiler de cliente. Los 4 ítems PASS y los 5 flujos COMPLETO se sostienen (con la salvedad de que la factura del flujo de domicilio es de personal y de que la ruta de error del pedido está rota); aportes 87 y 7 verificados con fusión de cuentas válida; de 20 pares solo H-03/H-47 es duplicado real.

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Completo | Inicio, renovación y cierre de sesión (web con cookies, móvil con token) | — |
| Completo | Pedido de mesa del mesero y avance en cocina | — |
| Completo | Pedido a domicilio del cliente con pago en efectivo o Wompi y factura | — |
| Completo | Entrega a domicilio: asignación, estados del repartidor y calificación | — |
| Completo | Gestión de catálogo (productos y categorías) desde el panel web | — |

## Hallazgos

### [Bloqueante] H-01 · Clave JWT, contraseña SMTP y contraseñas de base de datos y gerente quedaron en el historial de main
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `git -C <clon> log --all -p -- Properties/launchSettings.json (ea63729 añade el 2026-08-26; 3eb3536 y 5a4e970 lo quitan); git -C <clon> branch -r --contains ea63729 incluye origin/main; be4c67c (2026-07-17) en appsettings.json; árbol actual limpio en Configuration/JwtConfiguration.cs:35-41`
- **Por qué importa:** Quien clone el repositorio (o cualquiera de sus 21 ramas) puede firmar JWT válidos con rol de gerente, usar la cuenta SMTP de Gmail y entrar con la cuenta de gerente inicial; quitar el archivo después no borra el historial. Valores ««redactado»»: JWT de 68 caracteres, SMTP de 19, gerente de 19.
- **Cómo cerrarlo (M):** Rotar de inmediato los cuatro valores (clave JWT, contraseña de aplicación de Gmail, contraseña del gerente semilla, contraseña de PostgreSQL), reescribir el historial con git filter-repo en todas las ramas y forks, y crear un .env.example sin valores. Añadir un escáner de secretos (gitleaks) al CI.

### [Alto] H-03 · El backend no se puede levantar desde el repositorio: README vacío y sin .env.example
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado; también reportado como H-47
- **Evidencia:** `README.md:1 | README.md contiene solo '# SaborExpressBack' (18 bytes). El código exige JwtSettings:SecretKey, Wompi:PublicKey/PrivateKey/IntegritySecret/EventsSecret, Brevo:ApiKey, InitialManager:Password y la cadena de conexión (Program.cs:19 carga .env), pero no existe ningún archivo de ejemplo; appsettings.json:27 trae además una URL de túnel de desarrollo. La guía está en otro repo y no lista las claves.`
- **Por qué importa:** Un compañero, un instructor o el propio equipo en otra máquina no puede reproducir el sistema; además la API arranca migrando la base (Program.cs:105) sin que se avise.
- **Cómo cerrarlo (S):** README con requisitos (.NET 8, PostgreSQL), pasos, tabla de variables y .env.example sin valores; docker-compose con API + base de datos; mencionar que MigrateAsync corre al iniciar y qué hacen los seeders.

### [Alto] H-05 · Un Administrador puede descargar el CV (dato personal) de empleados de cualquier sede
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `Controllers/EmployeesController.cs:70-77, Modules/Employees/Services/EmployeeService.cs:301-308`
- **Por qué importa:** GetAll, GetById y Update reciben el usuario actual y acotan por sede, pero DownloadCv llama GetCvAsync(id) sin actor ni comprobación de sede: rompe el aislamiento entre sedes y expone documentos personales (Ley 1581). El CV se valida solo por ContentType declarado.
- **Cómo cerrarlo (S):** Pasar currentUserId a GetCvAsync, aplicar la misma regla de sede que GetByIdAsync y devolver 403 fuera de la sede. Verificar la firma %PDF del archivo al subirlo. Añadir una prueba de integración con dos sedes.

### [Alto] H-06 · Sin pruebas de integración ni de los flujos de autenticación y de roles
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `tests/SaborExpressBack.QA.Tests/OperationalAuthorizationTests.cs:20-70, tests/SaborExpressBack.QA.Tests/SaborExpressBack.QA.Tests.csproj:1-23, docs/QA-01-REGRESION-OPERATIVA.md:20`
- **Por qué importa:** Ninguna prueba toca AuthService, UserRoleService, PasswordResetService ni el pipeline HTTP; la autorización se prueba leyendo atributos por reflexión, por lo que un atributo ausente (H-B03) o un filtro de sede omitido (H-B02) pasa en verde. Los criterios de aceptación de seguridad del Docs (13-code-examples/SECURITY-TESTS.md) están como casos de diseño sin ejecutar.
- **Cómo cerrarlo (M):** Añadir WebApplicationFactory con una base de pruebas (SQLite o Testcontainers) y casos: login con bloqueo, token vencido, cliente que lee pedido ajeno, administrador de otra sede, webhook sin firma. Medir cobertura con coverlet.

### [Alto] H-07 · El pipeline de release, la readiness y el rollback existen solo en una rama sin integrar a main
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Program.cs:103; rama origin/release/HU-STG-02-smoke-migraciones (1 commit adelantado, ab7d52f): .github/workflows/release-artifact.yml, scripts/release/preflight.ps1, scripts/release/smoke-staging.ps1, docs/release/HU-STG-02-smoke-migraciones.md`
- **Por qué importa:** main (el entregable) tiene solo un /health de vivacidad, ninguna construcción de imagen ni procedimiento de despliegue o recuperación, y Program.cs:105,137 aplica Database.MigrateAsync al arrancar sin puerta de respaldo. La rama adelantada sí trae: imagen inmutable a ghcr con manifiesto de digest, /health/ready con comprobación de migraciones, preflight de configuración, humo de staging y runbook de rollback sin Down() automático.
- **Cómo cerrarlo (S):** Integrar la rama a main por pull request con revisión, ejecutar el workflow, y documentar el rollback por digest en el README. Mantener la puerta de respaldo antes de migrar.

### [Medio] H-02 · La documentación es ingeniería inversa del código: no define problema, usuarios, indicadores ni historias con criterios de aceptación
- **Repositorio:** `propietario/SaborExpressDocs`
- **Lente SDLC OS:** A05 · **Verificación independiente:** matizado (severidad ajustada de alto)
- **Evidencia:** `1-project-charter/ACTA-CONSTITUCION.md:63 | El acta deja 'Equipo / ficha SENA / instructor / entidad patrocinadora' como pendientes (línea 9), el beneficio 'aún debe comprobarse en un piloto', y los criterios de éxito (líneas 55-65) son 'criterios propuestos, no resultados'; 'Métricas de rendimiento y usabilidad definidas antes de medir' (línea 63) equivale a no tener indicadores medibles. 2-requirements/REQUISITOS-Y-TRAZABILIDAD.md:9 declara que traduce 'capacidades reconocibles del repositorio' a requisitos: son RF-01..RF-25 derivados del código. No hay ninguna historia 'Como [rol], quiero... para...' ni AC por historia, ni cliente real/restaurante piloto, ni línea base. Ningún criterio permite decir si el producto cumple su propósito.`
- **Por qué importa:** Un producto sin problema ni métricas definidas no puede priorizarse, aceptarse ni demostrarse como valioso; el estándar de entrega pide >=3 indicadores medibles y >=3 historias Must con >=2 criterios de aceptación.
- **Cómo cerrarlo (M):** Escribir en el repo Docs un PRD corto: problema y usuario real (restaurante/rol), alcance MVP, >=3 KPIs con fórmula, línea base y meta (p. ej. tiempo medio de pedido a cocina, % de pagos Wompi conciliados sin intervención, p95 de la API), y >=3 historias Must (pedido de cliente, cobro en caja, pago Wompi) con >=2 AC cada una, enlazadas a endpoint y pantalla.

### [Medio] H-04 · Clave de API de MapTiler incrustada en el código del cliente móvil
- **Repositorio:** `propietario/SaborExpressMovil`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** matizado (severidad ajustada de alto)
- **Evidencia:** `src/features/branches/components/leafletShared.ts:52 | La URL de teselas 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=««redactado»»' (tipo: clave de API de MapTiler) está escrita en el HTML del mapa y se empaqueta en la app y en el repositorio. Nota: la evaluación de secretos (R-5.1) corresponde al especialista de seguridad; aquí se reporta como configuración no externalizada (R-4.4).`
- **Por qué importa:** Cualquiera con acceso al repo o al paquete puede usar y agotar la cuota de la clave; rotarla exige recompilar.
- **Cómo cerrarlo (S):** Mover la clave a una variable pública restringida por dominio/paquete (EXPO_PUBLIC_*), rotar la actual y restringirla en el panel del proveedor.

### [Medio] H-08 · Artefactos de IDE, datos subidos y capturas versionados pese a estar en .gitignore
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `wwwroot/uploads/products/33e89adf-d31c-4c55-a8af-359fd392520e.png | .vs/SaborExpress.slnx/v18/.suo (280 KB), .vs/ProjectEvaluation/*.bin, SaborExpress.csproj.user, 48 imágenes en wwwroot/uploads/products/ (contenido subido por usuarios en ejecución) y la carpeta Analisis/ con una captura de 1,2 MB siguen en el árbol; .gitignore:10 y :11 ya excluyen .vs/ y *.user (se agregaron tarde).`
- **Por qué importa:** Ensucian el repo, generan conflictos entre máquinas y mezclan datos de ejecución con código.
- **Cómo cerrarlo (S):** git rm --cached de .vs, *.user y wwwroot/uploads; mover las notas de Analisis/ al repo Docs.

### [Medio] H-09 · Carpetas de IDE y notas de trabajo versionadas en el móvil
- **Repositorio:** `propietario/SaborExpressMovil`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `entidades.sql:1 | .idea/ completo (deviceStreaming.xml 106 KB), .gradle/config.properties (aunque .gitignore lo lista), .vscode/, .claude/settings.json, .mcp.json, entidades.sql con DDL MySQL (el backend usa PostgreSQL por defecto) y logos de 2,1 MB.`
- **Por qué importa:** Ruido, conflictos y un DDL que contradice el motor por defecto del backend.
- **Cómo cerrarlo (S):** Añadir .idea/ a .gitignore, git rm --cached, y mover entidades.sql al repo Docs o al backend como referencia.

### [Medio] H-10 · Volcado de depuración y notas pegadas versionadas en la web
- **Repositorio:** `propietario/SaborExpressWeb`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `login-debug.txt:1 | login-debug.txt (823 líneas de código fuente) y el archivo 'estructura' (texto con marcas '[cite_start]' y '[cite: N]' de una herramienta) están en la raíz; .expo/ de Expo en un proyecto Next.js.`
- **Por qué importa:** Es ruido que un evaluador o futuro mantenedor debe filtrar y que puede contener código no vigente.
- **Cómo cerrarlo (S):** Eliminarlos; la guía de arquitectura de 'estructura' ya está en src/features/README.md.

### [Medio] H-11 · Fallos al confirmar efectivo, cancelar o fijar dirección se tragan y el usuario ve éxito
- **Repositorio:** `propietario/SaborExpressMovil`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/features/Client/components/ClientDashboard.tsx:679 | En el pago en efectivo, orderService.confirmCash(order.id) está dentro de un catch vacío con comentario (líneas 679-682) y a continuación se llama finishOrderSuccess() (línea 683): si la API rechaza o la red falla, el cliente ve el pedido como exitoso aunque el cajero no lo reciba confirmado. Mismo patrón en 556 y 562 (cancelación) y 285 (dirección por defecto).`
- **Por qué importa:** Es un callejón sin salida silencioso en el flujo principal del cliente (pedir y pagar): no hay reintento ni aviso, y la operación puede quedar inconsistente.
- **Cómo cerrarlo (S):** Mostrar el error con opción de reintentar, o dejar el pedido en estado pendiente de confirmación visible; registrar el fallo.

### [Medio] H-12 · La verificación visual de responsive e idiomas está declarada 'Pendiente' (sin capturas)
- **Repositorio:** `propietario/SaborExpressWeb`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/QA_I18N_RESPONSIVE.md:1 | La matriz 360x800, 768x1024 y 1366x768 en es/en/pt/fr figura como 'Pendiente de recorrido visual'; solo la auditoría de claves i18n (136 claves) y 3 pruebas unitarias se ejecutaron.`
- **Por qué importa:** El diseño adaptable y los textos largos en cuatro idiomas no están comprobados en las pantallas más usadas (pedidos, caja, domicilios).
- **Cómo cerrarlo (M):** Hacer el recorrido y adjuntar capturas por viewport e idioma, o anotar los defectos encontrados.

### [Medio] H-13 · Trazabilidad solo hasta el endpoint: sin historias y casi ninguna pantalla enlazada
- **Repositorio:** `propietario/SaborExpressDocs`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `2-requirements/REQUISITOS-Y-TRAZABILIDAD.md:49 | La matriz RF-01..RF-25 (líneas 24-49) enlaza a controladores y rutas que sí existen en el backend, pero solo RF-25 cita una pantalla (src/app/reports/page.tsx) y ningún RF cita pantallas del móvil (src/app/cashier, waiter, delivery, client) ni vistas web (src/features/*/views).`
- **Por qué importa:** Sin el eslabón requisito -> pantalla -> endpoint -> tabla, no se puede comprobar cobertura funcional ni estimar el impacto de un cambio; el flujo de punta a punta queda sin guía.
- **Cómo cerrarlo (S):** Añadir a la matriz las columnas 'pantalla web', 'pantalla móvil' y 'tabla', empezando por pedido, pago Wompi, cobro en caja y reparto.

### [Medio] H-14 · Documentación desactualizada respecto del código entregado el 22-oct
- **Repositorio:** `propietario/SaborExpressDocs`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `4-design/ARQUITECTURA-ACTUAL.md:1 | Los documentos son 'v2.0, corte 14-oct'; el backend añadió después CashClosuresController (18-oct), InvoicesController con PDF, idempotencia de Wompi, observabilidad Prometheus/Grafana (observability/) y release HU-STG-02. Los .md de Docs dan 0 coincidencias para Prometheus/Grafana y para factura PDF; el catálogo de API (6-api/ENDPOINTS-VERIFICADOS.md) admite no cubrir todos los controladores.`
- **Por qué importa:** La documentación deja de describir el sistema construido (T-12.4) justo cuando se entrega.
- **Cómo cerrarlo (M):** Regenerar el catálogo de API desde Swagger, actualizar el diagrama de componentes y el diccionario de datos contra las migraciones del 22-oct, y registrar la fecha/SHA de cada documento.

### [Medio] H-15 · Los PR son una cadena de promoción de una sola persona: 135 PR, 0 revisiones, 131 sin descripción
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/SaborExpressBack: gh api pulls (54 PR); propietario/SaborExpressWeb (42); propietario/SaborExpressMovil (31); propietario/SaborExpressDocs (8) | Todos los PR son de Integrante 1 y se fusionan develop -> qa -> staging -> main el mismo día (22-oct: Back #30-#53), sin reviews ni comentarios de revisión, y 131 de 135 sin cuerpo.`
- **Por qué importa:** El flujo parece git-flow disciplinado, pero no hay segunda mirada ni trazabilidad del cambio; las promociones se hacen en bloque al corte.
- **Cómo cerrarlo (S):** Plantilla de PR con historia (HU-xx), cambios y evidencia de prueba; pedir revisión de un compañero o del instructor al menos en main.

### [Medio] H-16 · Actividad intermitente: 3 semanas sin commits y un tercio del trabajo el día del corte
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git log --all --no-merges --format=%ad (4 repos) | Semanas ISO con commits en la ventana: W36, W37, W41, W42, W43 (5 de 9); W38-W40 vacías en los 4 repos. El 22-oct se registraron 33 de 94 commits (Back 20 de 39); el 8-oct se hicieron los commits grandes de 'update client module' y 'preparar backend para despliegue' (290 y 120 archivos).`
- **Por qué importa:** Trabajo acumulado y entregado en bloques sube el riesgo de integración y reduce la evidencia de avance continuo.
- **Cómo cerrarlo (S):** Commits pequeños y semanales; tablero con HU para repartir la carga en el tiempo.

### [Medio] H-17 · Historial con commits duplicados y ramas de respaldo (rebase/cherry-pick) y rama de release sin integrar
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/SaborExpressBack: git log origin/main (d5a4bb6427 / 17f0dcd2e5); rama origin/release/HU-STG-02-smoke-migraciones | Mismo commit de 290 archivos x2 en Back, 'feat: update client module' x4 en Web (120 archivos c/u), 4+4 'fix(settings)' repetidos, ramas backup/main-before-sync, backup/qa-before-sync, sync/*. La rama release/HU-STG-02-smoke-migraciones (+1 commit, 510 inserciones: release-artifact.yml, scripts/release/*.ps1, docs/release/*, +32 líneas en Program.cs) está solo en un PR abierto (#54 hacia develop) y no llegó a main.`
- **Por qué importa:** Indica que los ambientes se reconstruyeron a mano; hay trabajo de despliegue que el entregable (main) no contiene.
- **Cómo cerrarlo (S):** Integrar o descartar #54 explícitamente, borrar ramas backup/sync al cerrar, y fijar un solo sentido de promoción (merge o squash, no cherry-pick).

### [Medio] H-18 · La compensación del pedido del cliente usa un endpoint de personal y siempre falla
- **Repositorio:** `propietario/SaborExpressMovil`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/features/Client/components/ClientDashboard.tsx:689`
- **Por qué importa:** El flujo crea el pedido y luego sus líneas y el pago en llamadas separadas. Si fallan las líneas o Wompi, el catch llama orderService.cancel (PATCH /api/Orders/{id}/cancel), que ejecuta GetCurrentEmployeeId (propietario/SaborExpressBack:Controllers/OrdersController.cs:215) y lanza 401 porque el JWT del cliente solo lleva CustomerId (Modules/Auth/Helpers/JwtTokenGenerator.cs:47-55). El error se traga en el catch vacío y queda un pedido a domicilio huérfano o sin líneas; el cliente reintenta y lo duplica.
- **Cómo cerrarlo (S):** Usar orderService.cancelMine (ya existe, mismo archivo, línea 560) en la compensación o, mejor, crear pedido y líneas en una sola petición y transacción en el backend (CreateOrderDto con Items).

### [Medio] H-19 · La pantalla de reseñas lee una tabla que ningún cliente puede poblar
- **Repositorio:** `propietario/SaborExpressWeb`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/features/Reviews/services/review.service.ts:17`
- **Por qué importa:** El panel web consulta GET /api/Reviews/branch/{id} y /summary (propietario/SaborExpressBack:Controllers/ReviewsController.cs:74-86), pero POST /api/Reviews (ReviewsController.cs:35, rol Cliente) no se invoca desde el móvil ni la web: el móvil solo califica entregas (POST /api/Deliveries/{id}/rating). La sección de reseñas de sede queda vacía salvo escritura manual; los requisitos solo piden calificar el reparto (RF-20).
- **Cómo cerrarlo (M):** Quitar la sección de reseñas de sede o conectar un formulario de reseña de pedido en el móvil; si se mantiene la calificación de entrega, unificar la fuente.

### [Medio] H-20 · Móvil: README de plantilla y variables EXPO_PUBLIC_API_URL/APP_ENV sin documentar
- **Repositorio:** `propietario/SaborExpressMovil`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app.config.js:7 | README.md es el de create-expo-app (habla de 'app' y 'app-example'). app.config.js:9-13 aborta la compilación de producción sin EXPO_PUBLIC_API_URL con HTTPS, pero nada lo documenta; el usuario solo lo descubre al fallar.`
- **Por qué importa:** Impide reproducir los builds de preview/producción definidos en eas.json.
- **Cómo cerrarlo (S):** Reescribir el README (qué es, roles, cómo apuntar a la API, perfiles de EAS) y agregar .env.example.

### [Medio] H-21 · Web: README de plantilla y NEXT_PUBLIC_API_URL sin documentar; si falta, la URL base es 'undefined/api'
- **Repositorio:** `propietario/SaborExpressWeb`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/config/api.ts:65 | README.md es el de create-next-app. src/config/api.ts:18 lee NEXT_PUBLIC_API_URL y :65 crea axios con baseURL `${API_BASE}/api` sin validar; la guía de Docs reconoce 'no asumir un nombre de .env'. .gitignore:34 solo ignora '.env.local*'.`
- **Por qué importa:** El primer arranque falla de forma silenciosa y confusa, y un '.env' real no está protegido por .gitignore.
- **Cómo cerrarlo (S):** Documentar la variable, añadir .env.example, validar en el arranque (falla con mensaje claro) e ignorar '.env*'.

### [Medio] H-22 · Controladores con lógica de negocio y dependencias directas a repositorios
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Controllers/PaymentsController.cs:151`
- **Por qué importa:** PaymentsController.InitCashierWompi consulta _orderRepository y aplica CanManageBranchFinances antes de llamar al servicio; OrdersController inyecta 4 repositorios y decide el canal del pedido en el controlador (OrdersController.cs:49-58). Las reglas se repiten por controlador y no se pueden probar sin HTTP; ya hubo drift entre la ruta de personal y la de cliente (H-A01).
- **Cómo cerrarlo (M):** Mover esas decisiones a los servicios (el controlador solo traduce HTTP) y quitar los repositorios de los constructores.

### [Medio] H-23 · La documentación de datos describe un módulo eliminado y omite casi todo el modelo reciente
- **Repositorio:** `propietario/SaborExpressDocs`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `5-database/DICCIONARIO-DE-DATOS.md:302`
- **Por qué importa:** El diccionario, RF-24 (2-requirements/REQUISITOS-Y-TRAZABILIDAD.md:48) y M07 DailyMenu (7-manuals/MANUAL-TECNICO.md:126) siguen mencionando DailyMenu, que el backend eliminó con propietario/SaborExpressBack:Migrations/20261012130000_RemoveDailyMenu.cs. Solo 8 de 29 tablas tienen columnas documentadas; cash_closures, table_release_audits, push_devices, branch_operational_settings y los campos tax_rate, delivery_fee y table_session_id no aparecen. El corte documental es 14-oct y el backend avanzó hasta el 22-oct.
- **Cómo cerrarlo (M):** Regenerar el diccionario desde el snapshot de EF o con dotnet ef migrations script y eliminar DailyMenu de requisitos, manual técnico y diccionario; incluir fecha y SHA del backend.

### [Medio] H-24 · El filtro de excepciones convierte errores inesperados en 400 sin registrarlos
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Shared/Filters/ApiExceptionFilter.cs:24 | El comodín '_ =>' responde 400 'No se pudo completar la solicitud.' para cualquier excepción no mapeada (línea 24) y no registra nada; PersistenceException devuelve ex.Message al cliente con 500 (línea 21). AuthService.cs:318-322 traga errores con un TODO de ILogger.`
- **Por qué importa:** Los fallos reales del servidor se ven como errores del cliente, se pierde la causa y se puede filtrar texto interno.
- **Cómo cerrarlo (S):** Mapear lo no previsto a 500 con ProblemDetails, registrar con ILogger y devolver un identificador de correlación.

### [Medio] H-25 · Componentes monolíticos de más de 1000 líneas en el móvil (ClientDashboard 1402)
- **Repositorio:** `propietario/SaborExpressMovil`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/features/Client/components/ClientDashboard.tsx:65 | Muestreo de los 2 componentes más grandes del equipo: ClientDashboard.tsx es una función de 1402 líneas con 18 useState, 7 catch silenciosos y lógica de pago/cancelación/impuestos; otros: OrdersFeature.tsx 1312, WaiterDashboard.tsx 1150. Muestreo declarado en no_verificado.`
- **Por qué importa:** Dificulta pruebas y cambios; es la causa raíz de que errores como el de H-C07 pasen inadvertidos.
- **Cómo cerrarlo (L):** Extraer hooks (useCheckout, useActiveOrder), subcomponentes (carrito, selección de dirección, modal de pago) y un servicio de pagos testeable.

### [Medio] H-26 · SchedulesView: un componente de 1513 líneas con ~20 estados locales
- **Repositorio:** `propietario/SaborExpressWeb`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/features/EmployeeSchedules/views/schedules-view.tsx:142 | El archivo mide 1655 líneas; SchedulesView (líneas 142-1655) mezcla carga de sedes, horarios, modal individual, modal masivo, traslado de sede, envío de correos y confirmaciones; otras vistas: employees-view.tsx 1292, config-view.tsx 1110.`
- **Por qué importa:** Es el componente más grande del equipo; cambiarlo sin romperlo es costoso y no tiene pruebas.
- **Cómo cerrarlo (L):** Partir por responsabilidad (hook de datos, tabla semanal, modales, acciones masivas) y mover reglas de fecha/turno a src/lib con pruebas.

### [Medio] H-27 · GET y PUT /api/Customers/me sin [Authorize]: la autenticación depende de una excepción
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Controllers/CustomersController.cs:23-35, Shared/Filters/ApiExceptionFilter.cs:19`
- **Por qué importa:** No hay clase ni método con [Authorize] ni política de respaldo en Program.cs; el 401 sale solo porque GetCurrentUserId lanza UnauthorizedAccessException. Un cambio en esa función abre perfil y actualización de clientes. Además OperationalAuthorizationTests inspecciona atributos por reflexión y no puede detectar un atributo ausente.
- **Cómo cerrarlo (S):** Añadir [Authorize(Roles = RoleNames.Cliente)] a me y definir una FallbackPolicy que exija usuario autenticado salvo [AllowAnonymous] explícito; añadir una prueba que recorra todos los endpoints y falle si alguno no declara política.

### [Medio] H-28 · Subida de imágenes de producto confía en el ContentType del cliente y conserva su extensión
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Modules/Products/Services/ProductService.cs:93-103, Modules/Products/Validators/ProductValidator.cs:15, Program.cs:111`
- **Por qué importa:** Un Gerente o Administrador (o una sesión robada) puede enviar un archivo .html o .svg con ContentType image/png; se guarda en wwwroot/uploads y se sirve con UseStaticFiles desde el mismo origen del API, lo que permite XSS almacenado. No hay límite de tamaño efectivo en el guardado.
- **Cómo cerrarlo (S):** Lista blanca de extensiones (.jpg, .png, .webp) derivada del tipo detectado por firma de bytes, nombre generado sin la extensión del cliente, tamaño máximo en el servidor y encabezado X-Content-Type-Options en /uploads. Idealmente almacenar fuera de wwwroot.

### [Medio] H-29 · Endpoint /metrics anónimo y JWT aceptado por la URL en los hubs
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Program.cs:122-124, Configuration/JwtConfiguration.cs:72-78`
- **Por qué importa:** Cualquiera puede leer el catálogo de rutas, latencias y errores del API, información útil para reconocimiento. El access_token en la query de /hubs queda en registros de proxy y del servidor.
- **Cómo cerrarlo (S):** Proteger /metrics con red privada o autenticación básica del scraper; mantener el JWT por cookie HttpOnly o por encabezado en SignalR (accessTokenFactory) y no registrar la query.

### [Medio] H-30 · Protección de datos personales (Ley 1581) sin consentimiento registrado en el servidor ni política operativa
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Modules/Customers/DTOs/RegisterCustomerDto.cs; src/features/auth/components/ClientRegistrationFlow.tsx:32 (en propietario/SaborExpressMovil), 12-governance/PLAN-ETICO-PRIVACIDAD.md:5-7 (en propietario/SaborExpressDocs)`
- **Por qué importa:** Se recogen documento, teléfono, dirección y CV, pero la aceptación de términos de la app no llega al API ni queda auditada, y el plan de privacidad del expediente no cita la ley, responsable, finalidad, retención ni derechos del titular.
- **Cómo cerrarlo (M):** Guardar versión y fecha del consentimiento en el registro, publicar la política de tratamiento, definir retención y un procedimiento de supresión.

### [Medio] H-31 · Web y móvil no tienen CI y no hay despliegue verificable
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `propietario/SaborExpressWeb:package.json:7-11, propietario/SaborExpressMovil:package.json:66-73, propietario/SaborExpressBack:performance/HU-STG-01/run.ps1:25`
- **Por qué importa:** npm test, lint, typecheck y build de Next.js y Expo nunca corren automáticamente (0 ejecuciones de Actions en ambos), y la única pista de despliegue (Render y Vercel) no respondió en 15 segundos y no está declarada.
- **Cómo cerrarlo (S):** Añadir un workflow por repositorio con npm ci, lint, typecheck, test y build, y declarar en cada README la URL de despliegue y cómo se promueve.

### [Medio] H-32 · La CI no se ejecuta sobre main ni sobre push a develop
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Program.cs:103; .github/workflows/qa-operational-regression.yml:3-10 y qa-wompi-sandbox.yml:3-10 (ramas fijas de prueba y pull_request hacia qa)`
- **Por qué importa:** El commit evaluado de main no tiene ninguna ejecución; un merge a main o a develop puede romper las pruebas sin que nada lo detecte hasta el siguiente PR a qa.
- **Cómo cerrarlo (S):** Disparar un único workflow de pruebas en pull_request a cualquier rama y en push a main y develop, y exigirlo como verificación obligatoria en la protección de ramas.

### [Medio] H-33 · El código anuncia tres motores pero las migraciones solo funcionan en PostgreSQL
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Configuration/DatabaseConfiguration.cs:46`
- **Por qué importa:** DatabaseProvider acepta MySQL, SqlServer y PostgreSQL (appsettings.json:2-6 y SaborExpress.csproj con Pomelo, SqlServer y Npgsql), pero las migraciones llevan anotaciones Npgsql (Migrations/20260826001109_AddRoleIdToEmployeeSchedule.cs:20), tipos 'character varying' y 'timestamp with time zone' y SQL PL/pgSQL (Migrations/20261012130000_RemoveDailyMenu.cs:22); git grep de MySql: y SqlServer: en Migrations da 0 resultados. Elegir MySQL o SqlServer falla al migrar. La documentación (ADR-04) admite que el soporte está por validar.
- **Cómo cerrarlo (S):** Declarar PostgreSQL como único motor (quitar proveedores y cadenas de conexión sobrantes de csproj y appsettings, actualizar el ADR) o mantener migraciones por proveedor con pruebas.

### [Medio] H-34 · Nombres físicos mezclados: 24 tablas snake_case y 5 en PascalCase
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Migrations/AppDbContextModelSnapshot.cs:956`
- **Por qué importa:** Notifications, Invoices, EmployeeSchedules, RefreshTokens y EmailConfirmationCodes no tienen ToTable ni HasColumnName y quedan con el nombre por defecto de EF; el resto usa orders, order_details... Las consultas SQL a mano necesitan comillas en unas y no en otras. También hay precisión monetaria dispar (decimal(10,2), (12,2) y (14,2)) en Data/Configurations/OrderConfiguration.cs:80-90.
- **Cómo cerrarlo (M):** Añadir ToTable y HasColumnName en snake_case a esas 5 entidades en una migración de renombre (expandir y contraer) y fijar una sola precisión para dinero.

### [Medio] H-35 · El esquema no declara restricciones CHECK: las reglas de integridad viven solo en el código
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Data/Configurations/OrderDetailConfiguration.cs:1`
- **Por qué importa:** No existe HasCheckConstraint en Data ni en el snapshot: quantity > 0, unit_price >= 0, rating 1..5, importes no negativos y estados válidos dependen de OrderDetailValidator y de los servicios; cualquier escritura por otra vía (script, consola, otro cliente) puede guardar filas imposibles. La documentación (propietario/SaborExpressDocs:5-database/DICCIONARIO-DE-DATOS.md:5) las enumera como pendientes de comprobar.
- **Cómo cerrarlo (S):** Agregar CHECK para cantidades, precios, calificación y montos en una migración y reflejarlos en el diccionario.

### [Medio] H-36 · El arranque migra y siembra automáticamente sin guardia ni procedimiento en main
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Program.cs:105`
- **Por qué importa:** await app.MigrarYSembrarBaseDeDatosAsync() se ejecuta en cada arranque, incluido producción. La rama origin/release/HU-STG-02-smoke-migraciones (1 commit adelante de main, ab7d52f del 22-oct) contiene lo que falta: endpoint /health/ready que devuelve 503 con migraciones pendientes, workflow release-artifact.yml, scripts/release/preflight.ps1 y smoke-staging.ps1 y docs/release/HU-STG-02-smoke-migraciones.md con respaldo y restauración; nada de eso está en main. Sin respaldo previo, una migración con DropColumn o DropTable (hay varias) puede perder datos al desplegar.
- **Cómo cerrarlo (S):** Integrar esa rama a main por PR, separar migraciones del arranque de la API en producción y documentar el procedimiento de respaldo en el README del backend.

### [Medio] H-37 · El filtro de errores devuelve cuerpos distintos y códigos equivocados
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Shared/Filters/ApiExceptionFilter.cs:22`
- **Por qué importa:** InvalidOperationException se convierte en 409 aunque se use para reglas de negocio y permisos (Modules/Orders/Services/OrderService.cs:715 'No tienes permiso para cancelar pedidos' sale como 409 en vez de 403) y cualquier excepción no prevista cae en 400 (línea 24): un fallo del servidor parece error del cliente y no cuenta como 5xx en las métricas. Cuerpos: {error}, {message,retryAfterSeconds} y {message} (Controllers/OrdersController.cs:213) más ProblemDetails de [ApiController]; los clientes tienen que adivinar la forma.
- **Cómo cerrarlo (M):** Definir un único contrato de error (code, message, traceId), excepciones de dominio tipadas (Forbidden a 403, Conflict a 409) y devolver 500 para lo inesperado.

### [Medio] H-38 · Ningún listado pagina y la API no tiene versión
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Controllers/OrdersController.cs:76`
- **Por qué importa:** GET /api/Orders, /Orders/branch/{id}, /Payments, /Customers y similares devuelven la lista completa (solo hay Take(50) y Take(200) fijos en Modules/Payments/Repositories/PaymentRepository.cs:38 y Modules/CashClosures/Services/CashClosureService.cs:300). Con meses de pedidos el panel web y el móvil traerán todo en cada recarga y en cada evento OrdersChanged. Tampoco hay versionado (/api/v1) y el móvil publicado por EAS no se actualiza a la vez que la API.
- **Cómo cerrarlo (M):** Añadir page y pageSize (o cursor) con límite máximo a los listados de pedidos, pagos y clientes, y prefijar /api/v1.

### [Bajo] H-39 · 43 blobs duplicados entre docs-SaborExpress/ y las carpetas 1-13
- **Repositorio:** `propietario/SaborExpressDocs`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs-SaborExpress/INDICE.md:1 | Mismo .docx/.pdf/.md versionado en 2-3 rutas (ej. 4-design/SaborExpress_Diseno_de_Software.docx = docs-SaborExpress/04_SaborExpress_Diseno_del_Software.docx) y 6-api/postman-collection-inicial.json = 6-api/postman-collection.json; sin .gitignore.`
- **Por qué importa:** Cualquier corrección debe repetirse en varias copias y se desincronizan.
- **Cómo cerrarlo (S):** Elegir un árbol canónico, generar el espejo en CI o como release, y borrar duplicados.

### [Bajo] H-40 · Mensajes de commit genéricos ('subir') en el 29 % de los commits y repos en cuenta personal sin respaldo verificable
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git log --all --no-merges --format=%s (4 repos) | 27 de 94 commits son 'subir', 'subir cambios', 'Initial commit', etc. (Movil 13 de 23); la convención feat/fix aparece solo desde el 8-oct. Los 4 repos viven en la cuenta personal Integrante 1 y no se pudo verificar ningún colaborador (HTTP 403).`
- **Por qué importa:** Un historial sin mensajes no sirve para auditar; si la cuenta se pierde, se pierde el proyecto.
- **Cómo cerrarlo (S):** Adoptar Conventional Commits desde el primer commit y mover los repos a la organización del programa con >=2 propietarios.

### [Bajo] H-41 · Endpoints, tabla y función muertos sin contraparte
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Controllers/ConfigurationsController.cs:1`
- **Por qué importa:** ConfigurationsController (6 rutas sobre branch_settings), PermissionsController (CRUD), RolePermissions, UserRoles y las rutas invoices/branch no tienen consumidor; el móvil define getCurrentUser hacia /api/Auth/me (propietario/SaborExpressMovil:src/features/auth/services/getCurrentUser.ts:6) que no existe y nadie la llama. branch_settings coexiste con branch_operational_settings. Superficie de mantenimiento y ataque sin uso.
- **Cómo cerrarlo (S):** Eliminar o proteger lo que no se use y retirar la función muerta del móvil.

### [Bajo] H-42 · Lógica de negocio de pagos dentro de OrdersController y código muerto en src/
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Controllers/OrdersController.cs:172 | OrdersController consulta IPaymentRepository y decide si hay un pago Wompi reciente pendiente (líneas 170-184), regla que pertenece al servicio. src/architecture/CleanArchitectureRegistry.cs no se usa en ningún sitio y src/ es una maqueta de arquitectura objetivo.`
- **Por qué importa:** Reglas dispersas se duplican (el webhook y el servicio ya manejan Wompi) y el código muerto confunde sobre la arquitectura real.
- **Cómo cerrarlo (S):** Mover la regla a OrderService y borrar o convertir en ADR la carpeta src/.

### [Bajo] H-43 · Código muerto y TODO obsoletos en el móvil
- **Repositorio:** `propietario/SaborExpressMovil`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/features/cashier/components/CashierData.ts:45 | INITIAL_ORDERS (pedidos falsos ORD-101..104) y generateMockOrders (src/features/delivery/components/DeliveryData.ts:39) no se usan; src/features/auth/hooks/useAuth.ts:26 y :42 tienen TODO sobre persistir el token que la app ya hace en tokenStorage.ts.`
- **Por qué importa:** Datos de demostración en el paquete y comentarios que contradicen el comportamiento real.
- **Cómo cerrarlo (S):** Eliminarlos y retirar el hook useAuth.ts duplicado del index de auth.

### [Bajo] H-44 · Tablero público de cocina sin autenticación: el enlace por turno es el único control
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Controllers/PublicKitchenController.cs:6-20, Modules/Orders/Services/OrderService.cs:349-356, Modules/EmployeeSchedules/BackgroundServices/KitchenLinkNotifierBackgroundService.cs:52`
- **Por qué importa:** El enlace usa un GUID por turno que caduca (bien), pero el endpoint devuelve todos los pedidos de la sede con nombre del cliente; quien reenvíe el enlace expone datos. El comentario del controlador describe un código de sede, que ya no es lo que se usa.
- **Cómo cerrarlo (S):** Mostrar solo número de pedido y productos, acotar a pedidos activos, permitir revocar el enlace y corregir el comentario.

### [Bajo] H-45 · google-services.json versionado con la clave de API del proyecto Firebase
- **Repositorio:** `propietario/SaborExpressMovil`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `google-services.json:17`
- **Por qué importa:** La clave de cliente sirve a cualquiera que la copie para consumir cuotas del proyecto si no está restringida por paquete y huella SHA-1.
- **Cómo cerrarlo (S):** Restringir la clave en la consola de Google por paquete com.Integrante 1.saborexpress y firma, y entregar el archivo vía EAS secret en lugar de versionarlo.

### [Bajo] H-46 · Historial con inicio de sesión simulado, correo personal y contraseña trivial
- **Repositorio:** `propietario/SaborExpressWeb`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `git -C <clon> show 4dec7c7 (2026-06-11, login simulado en el módulo de autenticación); src/config/api.ts:63-70 ya no lo contiene`
- **Por qué importa:** Aunque era un simulacro, deja un correo real y una contraseña débil en el historial público; si la cuenta real reutilizó esa clave, es una exposición.
- **Cómo cerrarlo (S):** Confirmar que esa contraseña no se usa en ningún lado y limpiarla del historial junto con H-B01; ignorar .env en .gitignore.

### [Bajo] H-48 · entidades.sql es un segundo modelo de datos MySQL desfasado que se presenta como completo
- **Repositorio:** `propietario/SaborExpressMovil`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `entidades.sql:2`
- **Por qué importa:** Cabecera de DDL COMPLETO, dialecto MySQL, 18 tablas con nombres que el backend no tiene (order_items, cash_movements, settings, audit_logs) y sin muchas que sí tiene (order_status_history, push_devices, invoices...). Último cambio 2026-08-31. Un aprendiz nuevo puede ejecutarlo creyendo que es el esquema real; el backend usa PostgreSQL con migraciones.
- **Cómo cerrarlo (S):** Borrarlo del repositorio móvil o moverlo a docs con la etiqueta histórico, no ejecutar.

### [Bajo] H-49 · El contrato OpenAPI no se publica fuera de desarrollo y la documentación cubre un tercio de las rutas
- **Repositorio:** `propietario/SaborExpressBack`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Program.cs:108`
- **Por qué importa:** Swagger solo corre en Development; propietario/SaborExpressDocs:6-api/ENDPOINTS-VERIFICADOS.md lista 52 de unas 177 rutas y las colecciones Postman están en otro repositorio, sin verificación contra el código. Quien integre un cliente nuevo depende de leer controladores.
- **Cómo cerrarlo (S):** Exportar openapi.json en CI como artefacto o carpeta docs/ y generar el catálogo desde él.

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 53.1 |
| D2 | Reproducibilidad | 30.0 |
| D3 | Arquitectura y congruencia | 72.2 |
| D4 | Calidad de código | 50.0 |
| D5 | Seguridad | 69.3 |
| D6 | Pruebas | 41.7 |
| D7 | DevOps y despliegue | 37.9 |
| D8 | Datos | 70.0 |
| D9 | API y contratos | 45.0 |
| D10 | Frontend y móvil | 83.3 |
| D11 | IoT y firmware | — |
| D12 | Documentación y trazabilidad | 50.0 |
| D13 | Proceso y colaboración | 53.1 |
| D14 | Extremo a extremo | 75.0 |

## Lo que está bien

- Los contratos entre clientes y backend coinciden casi sin excepción (`Extracción estática: 91/91 llamadas http del web (p. ej. propietario/SaborExpressWeb:src/features/Order/services/order.service.ts:18) y las rutas del móvil (propietario/SaborExpressMovil:src/features/orders/services/orderEndpoints.ts:10) hacen match de ruta y verbo con propietario/SaborExpressBack:Controllers/OrdersController.cs:47; enums de pedido, detalle y entrega idénticos.`)
- Migraciones reversibles, FK con política de borrado explícita e idempotencia de pagos en el esquema (`propietario/SaborExpressBack:Data/Configurations/PaymentConfiguration.cs:64 (índice único wompi_reference); propietario/SaborExpressBack:Migrations/20261012130000_RemoveDailyMenu.cs:65 (Down); las configuraciones con FK declaran OnDelete.`)
- Documentación honesta sobre la arquitectura real (monolito modular, sin gateway) (`propietario/SaborExpressDocs:4-design/ARQUITECTURA-ACTUAL.md:7 corrige el README previo y separa lo observado de lo propuesto.`)
- Concurrencia y consistencia de pagos pensadas (`propietario/SaborExpressBack:Modules/Payments/Repositories/PaymentRepository.cs:151 (transacción Serializable), propietario/SaborExpressBack:Migrations/20261021090000_AddWompiPostProcessingOutbox.cs:1 (post-proceso Wompi) y sincronización de respaldo en Controllers/PaymentsController.cs:167.`)
- Tiempo real coherente entre servidor y clientes (`propietario/SaborExpressBack:Program.cs:119 mapea los hubs; los eventos OrdersChanged, PaymentsChanged y TablesChanged coinciden con propietario/SaborExpressMovil:src/features/shared/services/realtimeEvents.ts:8 y propietario/SaborExpressWeb:src/features/Dashboard/hooks/use-realtime-events.ts:13.`)
- Contraseñas con BCrypt y bloqueo por intentos (`Modules/Auth/Services/AuthService.cs:87-130`)
- Webhook de pagos con firma verificada en tiempo constante y límite de tamaño (`Modules/Payments/Services/WompiClient.cs:116-117, Controllers/PaymentsController.cs:183-186`)
- CORS por orígenes exactos, falla al arrancar en producción sin ellos y Swagger solo en desarrollo (`Program.cs:27-42, Shared/Security/CorsOriginPolicy.cs:10-17`)
- Autorización por recurso: pedidos, pagos y notificaciones acotados por sede y propietario; un Administrador no puede asignar Gerente (`Controllers/OrdersController.cs:63-135, Controllers/NotificationsController.cs:47-66, Modules/UsersRoles/Services/UserRoleService.cs:47-65`)
- Cookies HttpOnly y Secure con ruta acotada para el refresco; el encabezado de cliente web evita CSRF por cookie (`Controllers/AuthController.cs:189-220, Configuration/JwtConfiguration.cs:79-105`)
- CSP con nonce, HSTS y cabeceras de seguridad en la web (`proxy.ts:60-85`)
- Token móvil en SecureStore y compilaciones de producción solo HTTPS (`src/features/auth/services/tokenStorage.ts:20-35, app.config.js:9-30`)
- Imagen Docker multi-etapa que corre sin root, con .dockerignore que excluye .env (`Dockerfile, .dockerignore`)
- Pruebas con afirmaciones reales sobre firma de Wompi y ResourceReadPolicy, ejecutadas en CI en verde (`tests/SaborExpressBack.QA.Tests/WompiSandboxTests.cs:28-50, tests/SaborExpressBack.QA.Tests/OperationalAuthorizationTests.cs:85-125`)
- Rama de release con imagen por digest, readiness, preflight y runbook de recuperación honesto (sin ejecutar lo no ejecutado) (`Rama origin/release/HU-STG-02-smoke-migraciones: docs/release/HU-STG-02-smoke-migraciones.md, scripts/release/preflight.ps1`)
- Observabilidad: métricas Prometheus y tablero de Grafana provisionado (`observability/docker-compose.yml, observability/README.md, Shared/Observability/ApiMetricsRegistry.cs`)
- Sesión web sin JWT en JavaScript: cookies httpOnly, sesión en memoria y limpieza de la sesión antigua (`propietario/SaborExpressWeb:src/features/auth/context/auth-context.tsx:44 (elimina el token de localStorage), src/config/api.ts:66 (withCredentials), src/features/auth/session-memory.ts:1`)
- Cabeceras de seguridad y CSP con nonce en la web, y CORS por orígenes exactos con falla al arrancar en producción (`propietario/SaborExpressWeb:proxy.ts:59-84 (CSP, HSTS, X-Frame-Options); propietario/SaborExpressBack:Shared/Security/CorsOriginPolicy.cs:46 y Program.cs:24-30`)
- El móvil guarda tokens en SecureStore y rechaza compilar producción sin API HTTPS; desactiva cleartext fuera de producción (`propietario/SaborExpressMovil:src/features/auth/services/tokenStorage.ts:20, app.config.js:9-13 y :26`)
- Guardias por rol en cada árbol de rutas del móvil y guardia de rutas + inactividad en la web (`propietario/SaborExpressMovil:src/app/cashier/_layout.tsx:121, src/app/delivery/_layout.tsx:151; propietario/SaborExpressWeb:src/components/layout/app-shell.tsx:28`)
- Flujo git por ambientes con 135 PR y trazabilidad por HU (HU-DEV, HU-QA, HU-STG) hasta main; main contiene todo develop/qa/staging (`propietario/SaborExpressBack: gh api pulls; docs/QA-01-REGRESION-OPERATIVA.md, docs/QA_WOMPI_SANDBOX.md, performance/HU-STG-01/README.md`)
- Backend por capas con módulos, DTOs, interfaces de repositorio, manejador central de excepciones, localización de mensajes y seeders; Dockerfile multi-etapa con usuario no root (`propietario/SaborExpressBack:Modules/Orders/Interfaces/IOrderDetailRepository.cs, Shared/Filters/ApiExceptionFilter.cs, Dockerfile:5`)
- Accesibilidad y responsive trabajados en la web: aria-label/aria-expanded/aria-invalid, foco devuelto y Escape en el menú móvil (`propietario/SaborExpressWeb:src/components/layout/app-frame.tsx:15-52`)
- Internacionalización en 4 idiomas con auditoría automática y pruebas (`propietario/SaborExpressWeb:scripts/audit-i18n.mjs, docs/QA_I18N_RESPONSIVE.md; propietario/SaborExpressMovil:scripts/audit-i18n.mjs`)
- Documentación honesta y amplia: el repo Docs separa lo verificado de lo no verificado y trae diagramas editables, diccionario de datos y SRS con 25 RF mapeados a endpoints reales (`propietario/SaborExpressDocs:README.md, 2-requirements/REQUISITOS-Y-TRAZABILIDAD.md:24-49, docs-SaborExpress/ARQUITECTURA-COMPONENTES.dot`)
- Feature-first coherente en web y móvil, con documento de arquitectura y registro de features (`propietario/SaborExpressWeb:src/features/README.md, src/features/featureRegistry.ts; propietario/SaborExpressMovil:src/app/_layout.tsx`)

## Lo que no se pudo verificar

- Que los flujos funcionen en ejecución (login, pedido, pago Wompi, entrega) — No se puede ejecutar el código de los aprendices; los flujos se trazaron solo por lectura estática de rutas, verbos, DTO y mapeos.
- Que las migraciones apliquen desde una base PostgreSQL vacía — Exigiría ejecutar dotnet ef o dotnet run contra un PostgreSQL; se verificó que la primera migración crea 29 tablas y que las posteriores son aditivas, no su resultado real.
- Despliegue en línea y GET al flujo principal (T-14.3) — El equipo no declara ninguna URL de despliegue; las URL de appsettings.json son orígenes CORS de ejemplo y un Dev Tunnel.
- Llamadas del móvil construidas con variables dinámicas — La extracción de rutas del móvil resuelve constantes por expresión regular; rutas armadas en tiempo de ejecución podrían no haberse detectado (no se encontró ninguna discrepancia).
- Documentación en .docx y .pdf del repositorio de docs — Solo se leyeron las versiones .md; los .docx y .pdf se asumen espejo.
- Firma del webhook Wompi y su prueba sandbox — Reproducir el sandbox exige red de terceros y secretos, fuera del alcance de solo lectura; la corrección de la firma pertenece a D5 (otro especialista).
- Respuesta del despliegue público (API en Render) — El único GET permitido (curl -m 15 al /health del host que menciona performance/HU-STG-01/run.ps1) terminó por tiempo de espera; el plan gratuito de Render puede tardar más de 15 s en arrancar en frío, por lo que no se concluye que esté caído.
- Ejecución de las pruebas y de la CI sobre el SHA evaluado — No se permite ejecutar código del equipo; las ejecuciones de Actions que se leyeron son de otras ramas y de fecha posterior al corte (2026-10-23 UTC).
- Vulnerabilidades conocidas en dependencias (NuGet y npm) — Exigiría ejecutar dotnet list package --vulnerable / npm audit; el equipo reporta que NuGet no pudo consultar avisos (NU1900).
- Si los secretos del historial (H-B01) siguen vigentes en producción — No se prueban credenciales contra servicios; se desconoce si fueron rotadas.
- Restricciones de la clave de Firebase del móvil — Se configuran en la consola de Google, fuera del repositorio.
- Control de acceso por recurso en todos los controladores — Se revisaron atributos de los 30 controladores y en profundidad Orders, Payments, Notifications, UserPreferences, Employees y UserRoles; Addresses, Reviews, Deliveries e Invoices se revisaron solo por atributos de rol, no por la lógica de propiedad.
- Contenido de los .docx y .pdf del repositorio Docs — Solo se leyeron los archivos de texto; los binarios no se inspeccionaron.
- Aportes cruzados de Integrante 2 (equipo 8) en Movil y Web — Corresponde a D13 (especialista C); el briefing exige que aportes quede vacío en este parcial.
- Compilación y arranque real de web (next build), móvil (expo/eas) y backend (dotnet build) — Prohibido ejecutar código de los aprendices; R-10.1 se evaluó estáticamente (scripts, dependencias, 0 imports sin resolver en 148 archivos web y 259 del móvil; los 2 aparentes faltantes de pd01Ble son variantes .native/.web que Metro resuelve, limitación del verificador).
- Muestreo de D4: solo leí con profundidad src/features/EmployeeSchedules/views/schedules-view.tsx (Web, 1655 líneas) y src/features/Client/components/ClientDashboard.tsx (Móvil, 1402 líneas) como los 2 componentes más grandes por líneas, más OrderService, OrdersController y ApiExceptionFilter en el backend — Presupuesto de lectura; el resto de módulos se juzgó por estructura, tamaños y búsquedas de patrones.
- Colaboradores de los 4 repos y tablero de proyectos — La API devolvió HTTP 403 ('Must have push access') para colaboradores y 404 para proyectos de usuario.
- Contenido de los PDF/DOCX/PPTX del repo Docs (6da208a: final-project.pdf, presentation.pptx, project-defense.pdf) — No hay herramienta de extracción de texto disponible; solo se comprobó que fueron reemplazados el 14-oct (a777871).
- Contenido real de los .docx/.pdf frente a los .md del repo Docs — Se evaluaron los .md; los .docx/.pdf no se abrieron.
- Documentación en Google Drive — La regla de Drive no aplica: el equipo declara el repo Docs y su documentación vive ahí; no se declara carpeta de Drive.
- Despliegue en línea y flujos extremo a extremo — No es de este especialista (D14) y el equipo no declara URL de despliegue en PROYECTOS-FICHA-3145555.md; las URL de túnel (devtunnels) en appsettings.json son de desarrollo.
