# Equipo 1 · Driviqe — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 56/100 · Juicio D**

## Veredicto

Driviqe tiene una base solida: migraciones Liquibase con rollback, entidades alineadas con el esquema y cuatro de los cinco flujos principales completos (registro y login, catalogo, reserva con puntos de entrega y contrato en PDF). El flujo de pago con Wompi esta roto: ningun cliente usa los endpoints de pago del backend, la web y la app firman y verifican la transaccion en el dispositivo, y el backend confirma la reserva fabricando un pago APROBADO sin consultar a la pasarela. Hay tres hallazgos criticos y ninguno bloqueante: ese pago sin verificar, la clave de firma de los JWT que es un valor por defecto en el codigo, y las credenciales del super administrador y de los encargados sembradas en las migraciones para todos los ambientes. Ni la web ni la app movil tienen pruebas automatizadas, su CI no compila y no hay despliegue repetible. El puntaje es 55.8 (juicio D), a unos 14 puntos del umbral de 70, y el extremo a extremo (42) tambien queda bajo el minimo de 50; cerrar el pago de punta a punta y sacar los secretos del repo es lo que mas acerca al equipo, y despues vienen pruebas y despliegue.

## Plan para cerrar las brechas

1. **Rehacer la confirmacion de pago: que los clientes usen /v1/payments/wompi/initiate del backend, que checkout/confirm consulte a Wompi (o espere el webhook firmado) y deje de fabricar pagos APPROVED (tambien el camino de ContractSignatureService al firmar), y que la web y la app dejen de firmar y verificar en el dispositivo.** (esfuerzo L) — se cierra cuando: Una reserva solo pasa a pagada tras un webhook o consulta server-side a Wompi con referencia PAY-; una prueba de integracion con transaccion DECLINED o inexistente no confirma la reserva ni crea filas CONF- en billing.payments (ni en checkout/confirm ni al firmar el contrato); no queda codigo de firma de Wompi en web ni movil.
2. **Quitar el secreto JWT por defecto: leerlo solo de variable de entorno, fallar al arrancar si falta, rotar la clave actual y eliminar tambien la clave de base de datos por defecto y otros valores por defecto de credenciales.** (esfuerzo S) — se cierra cuando: Arrancar el backend sin JWT_SECRET ni DB_PASSWORD termina con error; busqueda en el arbol de valores por defecto de credenciales en application*.yml y en el codigo da cero resultados; los tokens firmados con la clave anterior son rechazados.
3. **Retirar de las migraciones y semillas las credenciales del super administrador y de los encargados, rotar esas claves en todos los ambientes y crear el primer administrador por un paso de arranque con clave por variable de entorno; corregir el rol EMPLOYEE desalineado entre seed y backend.** (esfuerzo M) — se cierra cuando: Ninguna migracion ni seed de main contiene claves ni hashes de cuentas privilegiadas; las claves antiguas ya no inician sesion en dev, qa ni prod; el rol EMPLOYEE es coherente entre seed, permisos y pruebas.
4. **Cerrar la exposicion de datos: proteger /uploads/** con autenticacion y autorizacion por propietario, aplicar la lista de CORS configurada en vez de abrirlo a cualquier origen, y cerrar Swagger/api-docs en main.** (esfuerzo M) — se cierra cuando: GET sin token a un archivo de /uploads devuelve 401; una peticion con Origin no listado no recibe cabeceras CORS; /swagger-ui y /v3/api-docs devuelven 401/404 con el perfil de produccion.
5. **Poner limite de intentos y limitacion de tasa a los OTP y endpoints publicos, revocar el refresh token al cerrar sesion, implementar el cambio de contrasena del perfil en el backend y exigir el consentimiento de Habeas Data por defecto.** (esfuerzo M) — se cierra cuando: Tras N intentos fallidos de OTP el backend responde 429; un refresh token usado tras logout es rechazado; el cambio de contrasena desde web y app responde 200 y permite iniciar con la nueva; sin consentimiento no se completa el registro.
6. **Conectar los consentimientos legales y el historial a los clientes, corregir el catalogo web (paginacion real y categorias desde la API) y la ruta de resenas con doble prefijo /v1.** (esfuerzo M) — se cierra cuando: Con mas de 10 vehiculos la web los muestra todos mediante paginacion; las categorias salen de la API; las resenas de sucursal del panel cargan sin error; los clientes muestran y registran consentimientos.
7. **Hacer que el CI de web y movil compile y agregar pruebas automatizadas minimas (autenticacion, catalogo, reserva y pago), mas pruebas de migraciones ejecutadas en el CI de la base de datos.** (esfuerzo L) — se cierra cuando: Cada repo tiene un workflow verde que compila y ejecuta pruebas en cada PR; hay al menos una prueba por flujo principal; el CI de database corre las pruebas de migraciones y valida el changelog.
8. **Establecer despliegue repetible con plan de reversa: pipeline de deploy del backend, eas.json con URL real de API, imagen sin root y con HEALTHCHECK, y reglas de rama para que main no reciba correcciones directas.** (esfuerzo L) — se cierra cuando: Un merge a la rama de ambiente despliega sin pasos manuales y existe un procedimiento de reversa probado; eas.json de preview y produccion apunta a la API real; el contenedor corre como no root y reporta salud.
9. **Hacer reproducible el arranque: README del backend y de la app movil que funcionen de cero, .env.example y compose completo, versiones de Java alineadas (17 o 21) entre pom, Dockerfile y documentacion.** (esfuerzo M) — se cierra cuando: Una persona ajena al equipo levanta backend completo y app movil siguiendo solo el README; la version de Java coincide en pom, Dockerfile y README.
10. **Alinear la documentacion con el codigo: pago, pilas tecnologicas, diccionario de datos (8 tablas atrasadas), contrato OpenAPI publicado y plantillas de API vacias, indicadores de exito medibles y contrato de UX. Agregar paginacion y lista blanca de orden en los endpoints de listado.** (esfuerzo M) — se cierra cuando: La documentacion del pago describe el flujo realmente implementado; el diccionario de datos coincide con el SQL de main; el OpenAPI se publica desde el build; los documentos de API y CHANGELOG ya no estan vacios.
11. **Refactorizar el codigo mas dificil de mantener: servicios de pago, promociones y recibos del backend, excepciones tragadas, paginas web de hasta 2054 lineas y pantallas moviles de mas de 1000 lineas, y mejorar accesibilidad (zoom, estados de carga y error).** (esfuerzo L) — se cierra cuando: Ninguna clase o pagina supera un limite acordado (por ejemplo 400 lineas); no quedan catch vacios en contratos y pagos; el viewport permite zoom; los paneles muestran carga y error.
12. **Mejorar proceso y base de datos: exigir revision de PR antes de fusionar, usar issues y tablero, limpiar ramas viejas, agregar indices a claves foraneas, revisar la clave primaria compuesta de iam.users y retirar archivos basura (.idea, copia del backlog, pagina de prueba de Wompi).** (esfuerzo M) — se cierra cuando: Las PR de main exigen al menos una aprobacion de otra persona; existen issues enlazados a las PR; las claves foraneas de consulta frecuente tienen indice; .idea y archivos de prueba ya no estan versionados.

## Verificación independiente

Hallazgos confirmados: 6 · matizados: 1 · refutados: 0 · duplicados fusionados: 5.

Confirme las cinco afirmaciones graves (H-01 a H-05) y H-08, H-09 y H-12 abriendo el codigo en el SHA evaluado; H-06 lo matizo a medio (llaves de sandbox y daño real ya en H-01), y H-01 conserva su gravedad aunque la validacion de documentos es mas debil de lo dicho y hallé un segundo camino que fabrica pagos CONF- en ContractSignatureService:77. Los cuatro PASS (R-5.1 Documentation, R-8.1 database, R-6.1 y R-7.1 Back-end) se sostienen (R-5.1 con un hueco menor de historial por un archivo .dot ilegible); cuatro flujos son COMPLETO y el de pago ROTO (el camino feliz sandbox funciona, pero el servidor no verifica); las cifras de aportes (1164/328/310) cuadran con git shortlog y las fusiones de cuentas son validas por correo o noreply, salvo el enlace login-correo de Integrante 3 que sigue sin confirmar. Cinco de los 18 pares son duplicados reales (H-01/H-02, H-03/H-13, H-04/H-05, H-22/H-33, H-55/H-62); los demas son defectos distintos que solo comparten archivo, con solape parcial H-35/H-59 sobre Java 17 vs 21. Observacion fuera de lista: los PASS de R-5.1 en front-end_web y front-end_movil pasan por alto la integrityKey de sandbox incrustada en wompiService.

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Completo | Registro, verificacion OTP e inicio de sesion | — |
| Completo | Consultar catalogo de vehiculos y ver la ficha | — |
| Completo | Cotizar y crear la retencion de reserva con puntos de entrega | — |
| Roto | Pagar con Wompi y confirmar la reserva | Confirmacion de pago: ningun cliente llama a /v1/payments/wompi/initiate; firman la transaccion en el cliente, consultan sandbox.wompi.co desde el navegador y llaman a checkout/confirm, que no verifica ninguna transaccion y fabrica un pago APPROVED. El webhook firmado (que busca la referencia PAY- creada por initiate) nunca puede coincidir con la referencia que usan los clientes. |
| Completo | Generar, firmar y descargar el contrato en PDF | — |

## Hallazgos

### [Crítico] H-01 · El backend confirma la reserva y fabrica un pago APROBADO sin consultar a Wompi
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A06 · **Verificación independiente:** confirmado; también reportado como H-02
- **Evidencia:** `src/main/java/com/drivique/api/service/ReservationService.java:495 (confirmReservationPayment, lineas 446-500); cliente web: project-drivique/front-end_web:web-drivique/src/modules/payments/pages/PaymentResponsePage.jsx:40`
- **Por qué importa:** POST /api/v1/reservations/checkout/confirm/{holdId} solo exige que el JWT sea del dueño de la retencion y que los documentos esten aprobados (linea 457); no recibe ni valida un identificador de transaccion. Quien tenga sesion puede llamarlo directamente y pasar la reserva a PENDING_SIGNATURE o CONFIRMED, y el codigo inserta en billing.payments una fila APPROVED con referencia inventada (prefijo CONF-) y monto del contrato, o 398000 si no hay (linea 495). La verificacion que si existe (el navegador consulta sandbox.wompi.co) esta del lado del atacante. La tabla de pagos deja de servir para conciliar y una reserva puede quedar pagada sin cobro. Verificado leyendo ambos extremos; no se ejecuto el endpoint.
- **Cómo cerrarlo (M):** Quitar la creacion del Payment de confirmReservationPayment y confirmar la reserva solo desde WompiPaymentService.processWebhook (o consultando la API de Wompi desde el servidor con la referencia). Hacer que web y movil llamen a /v1/payments/wompi/initiate para obtener referencia y firma del servidor, y que la pantalla de retorno solo consulte el estado de la reserva. Agregar una prueba de integracion donde confirm sin pago aprobado devuelva 409.

### [Crítico] H-03 · La clave de firma de los JWT es un valor por defecto en el codigo y nadie la sobrescribe
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado; también reportado como H-13
- **Evidencia:** `src/main/java/com/drivique/api/service/JwtService.java:27`
- **Por qué importa:** El @Value de jwt.secret trae un valor por defecto en JwtService.java:27 y en DeliveryActionTokens.java:22. No existe jwt.secret ni JWT_SECRET en application*.yml, .env.example, README ni docs, asi que el valor publico en este repositorio es la clave efectiva salvo que el host la defina por fuera. JwtAuthenticationFilter.java:43-69 confia en los claims roles y permissions: con la clave conocida cualquiera fabrica un token de SUPER_ADMIN y tambien las firmas HMAC de /v1/public/deliveries/action. El repo es publico. Se marca critico y no bloqueante porque no se pudo comprobar si el host define la variable (ver no_verificado).
- **Cómo cerrarlo (S):** Quitar el valor por defecto en JwtService y DeliveryActionTokens para que la aplicacion no arranque sin JWT_SECRET (minimo 32 bytes aleatorios), documentarlo en .env.example, definirlo en el panel de Render y rotarlo ya (la actual debe darse por comprometida). Usar claves distintas para los tokens de acceso y para las acciones de entrega.

### [Crítico] H-05 · Las semillas crean un super administrador y seis encargados con clave conocida en todos los ambientes
- **Repositorio:** `project-drivique/database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** confirmado; también reportado como H-04
- **Evidencia:** `02_dml/01_updates/iam/update-operational-users-passwords.sql:1; README.md:141; changelog/releases/hu-int-17.yaml:168`
- **Por qué importa:** El comentario del SQL y la tabla del README publican la contrasena comun ««redactado»» de «correo» y seis cuentas de encargado. Los changesets de hu-int-04 y hu-int-17 que las crean o actualizan no declaran context ni etiqueta de ambiente (no hay ningun context en changelog/, 01_ddl/ ni 02_dml/), asi que el mismo changelog maestro aplicado a qa o produccion deja un SUPER_ADMIN con clave publica. El README dice que aplica solo a locales, pero nada en Liquibase lo impone. No se verifico la base desplegada ni se intento autenticar.
- **Cómo cerrarlo (S):** Sacar las cuentas de 02_dml/ del master o ponerlas bajo un context local excluido en qa y main; crear el administrador inicial por variable de entorno al desplegar; rotar las claves de esas cuentas si ya existen en qa o produccion; retirar la contrasena del README y del comentario SQL.

### [Alto] H-07 · La web firma, inicia y verifica el pago desde el navegador y no usa los endpoints de pago del backend
- **Repositorio:** `project-drivique/front-end_web`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web-drivique/src/services/wompiService.js:8`
- **Por qué importa:** El archivo reconoce 'TODO: MIGRAR A BACKEND'. La clave de integridad de Wompi está en web-drivique/src/config/datos/config.json:5 (valor ««redactado»»), generarFirmaIntegridad firma el monto en el cliente (línea 99), web-drivique/src/modules/payments/pages/PaymentResponsePage.jsx:30 consulta https://sandbox.wompi.co desde el navegador y luego llama a /reservations/checkout/confirm (web-drivique/src/services/reservationsService.js:46). Los endpoints POST /v1/payments/wompi/initiate y /webhook del Back-end (PaymentWebhookController.java) no se invocan desde ningún cliente. | Impacto: El cliente decide el monto y declara el resultado; el flujo de pago implementado en el backend queda huérfano, y apuntar a sandbox en el código de producción rompe el cobro real.
- **Cómo cerrarlo (M):** Llamar a /v1/payments/wompi/initiate para obtener checkoutUrl y firma desde el servidor, retirar la clave de integridad del bundle y confirmar solo por webhook; leer la URL de Wompi de configuración.

### [Alto] H-08 · La documentación afirma lo contrario de lo que hace el código con el pago
- **Repositorio:** `project-drivique/Documentation`
- **Lente SDLC OS:** A05 · **Verificación independiente:** confirmado
- **Evidencia:** `docs/04-architecture/overview.md:90`
- **Por qué importa:** Dice 'El cliente no decide la aprobación de una transacción por su pantalla de regreso' y que Wompi se procesa por servicios backend y webhook; en el código el cliente consulta a Wompi y llama a confirmar (ver H-C01, H-C02, H-C03). | Impacto: Los evaluadores y futuros mantenedores asumirán un control que no existe.
- **Cómo cerrarlo (S):** Corregir el documento al estado real y volver a afirmarlo solo cuando el pago pase por initiate y webhook.

### [Alto] H-09 · Los consentimientos legales (Habeas Data) y el historial no los consume ningun cliente
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A05 · **Verificación independiente:** confirmado
- **Evidencia:** `project-drivique/Back-end:src/main/java/com/drivique/api/controller/ConsentController.java:32; project-drivique/Back-end:docs/HU-BE-11.md:1; project-drivique/database:01_ddl/03_tables/iam/user_consents.sql:1`
- **Por qué importa:** El backend tiene POST /v1/consents, GET /v1/users/me/consents y GET /v1/consents/status, la tabla inmutable iam.user_consents y un trigger que impide mutarla; git grep de consents en servicios, modulos, store y app de web y movil da 0 resultados. Ni el registro ni el checkout dejan evidencia de aceptacion de la politica de datos, que es lo que HU-BE-11 busca para la Ley 1581 de 2012. Capa de base de datos y backend listas, cliente ausente: flujo declarado e inexistente de extremo a extremo.
- **Cómo cerrarlo (M):** Registrar el consentimiento en el registro y en el primer pago (POST /v1/consents con tipo y version) y bloquear el avance si GET /consents/status devuelve pendientes; agregar una prueba e2e.

### [Alto] H-10 · Cambiar la contrasena desde el perfil no existe en el backend y falla en los dos clientes
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `project-drivique/front-end_web:web-drivique/src/services/userService.js:145; project-drivique/front-end_movil:app-drivique/modules/auth/services/authService.ts:210; project-drivique/Back-end:src/main/java/com/drivique/api/dto/UpdateUserProfileRequestDTO.java:1`
- **Por qué importa:** El web hace POST /usuario/cambiar-contrasena, ruta que no existe (404). El movil manda currentPassword y newPassword a PUT /users/me, pero UpdateUserProfileRequestDTO exige firstName y lastName y no tiene esos campos, asi que responde 400 y la app interpreta 400 como 'contrasena actual incorrecta' (passwordService.ts). Un usuario no puede cambiar su clave estando autenticado; solo el flujo de recuperacion por OTP funciona. El backend no tiene ningun endpoint de cambio de clave (git grep de change-password y changePassword sin resultados).
- **Cómo cerrarlo (S):** Crear POST /v1/users/me/password (currentPassword, newPassword) con la politica de PasswordValidatorService e invalidacion de sesiones, documentarlo en OpenAPI y apuntar ambos clientes ahi; retirar las rutas /usuario/* del web.

### [Alto] H-11 · El catalogo web pide la primera pagina por defecto (10 vehiculos) y filtra en el cliente con categorias fijas
- **Repositorio:** `project-drivique/front-end_web`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web-drivique/src/modules/catalog/hooks/useCatalog.js:101; project-drivique/Back-end:src/main/java/com/drivique/api/controller/VehicleController.java:44`
- **Por qué importa:** catalogService.getVehiculos() llama a /vehicles/search sin size (catalogService.js:69) y el backend usa size=10 por defecto; el web solo lee data.content y no sigue las paginas. El catalogo, el mapa de sedes (BranchesPage), el conteo de la portada y la reserva manual del administrador ven como maximo 10 vehiculos. Los chips de categoria son la lista fija ['Sedan','SUV','Económico','Deportivo'] (constants.js:6) frente a SUV, Sedán, Hatchback, Camioneta y Lujo sembradas, y el filtrado ocurre sobre esos 10. Hoy hay 6 vehiculos sembrados y no se nota; en cuanto la flota pase de 10 se pierden vehiculos sin error. El movil si manda size 100.
- **Cómo cerrarlo (S):** Paginar de verdad (pasar page y size, usar totalElements) o filtrar en servidor con los parametros que ya acepta el backend, y cargar las categorias desde /vehicle-categories.

### [Alto] H-12 · La ruta de pago documentada (backend firma y webhook confirma) esta construida pero desconectada de los clientes
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A06 · **Verificación independiente:** confirmado
- **Evidencia:** `project-drivique/Back-end:src/main/java/com/drivique/api/service/WompiPaymentService.java:9; project-drivique/Back-end:src/main/java/com/drivique/api/controller/PaymentWebhookController.java:5; project-drivique/front-end_web:web-drivique/src/services/wompiService.js:99; project-drivique/Documentation:docs/04-architecture/overview.md:90`
- **Por qué importa:** El backend implementa initiate (referencia PAY- y firma de integridad en el servidor) y un webhook con checksum comparado con MessageDigest.isEqual, que es la arquitectura que describe overview.md. Pero git grep de payments/wompi da 0 usos en web y movil: los clientes firman con la llave de integridad de sandbox empaquetada (config.json:5 y wompiService.ts:15, valor ««redactado»»), usan su propia referencia y consultan sandbox.wompi.co (tambien en produccion, PaymentResponsePage.jsx:30). Resultado: el webhook jamas encuentra el pago ('Pago no encontrado'), la documentacion describe un diseño que no corre y la llave de integridad queda en el bundle publico.
- **Cómo cerrarlo (M):** Conectar los clientes a /payments/wompi/initiate, eliminar la firma y la llave del cliente, apuntar la verificacion al backend y actualizar overview.md con el flujo real. Cubre tambien el hallazgo H-A01.

### [Alto] H-14 · Servicios de pago, promociones y recibos escritos en pocas líneas ilegibles y clases enormes
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/drivique/api/service/WompiPaymentService.java:7`
- **Por qué importa:** WompiPaymentService.java tiene 14 líneas, una de 2448 caracteres; PromotionValidationService (12 líneas, 2407), PaymentReceiptService (4 líneas, 1982) y VehicleInspectionService también; 42 de 467 archivos tienen líneas de más de 250 caracteres. ReservationService.java suma 974 líneas con createReservation de unas 228 y 16 dependencias, y 14 archivos superan 300 líneas. | Impacto: Es el código que mueve dinero y descuentos; nadie puede revisarlo en un PR ni depurarlo, y por eso pasó la lógica de H-C01.
- **Cómo cerrarlo (M):** Reformatear con un formateador (google-java-format o spotless) en CI, partir ReservationService en cotización, creación y confirmación, y rechazar líneas de más de 140 caracteres.

### [Alto] H-15 · Páginas monolíticas de hasta 2054 líneas con estilos y colores incrustados
- **Repositorio:** `project-drivique/front-end_web`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web-drivique/src/modules/admin/components/BranchDashboard.jsx`
- **Por qué importa:** 52 de 221 archivos superan 300 líneas y 12 superan 1000 (BranchDashboard.jsx 2054, ReservationManagementPage.jsx 2027, IncidentManagementPage.jsx 1974, VehicleManagementPage.jsx 1927); ReservationManagementPage declara 21 useState y 198 style={{ }}; en total 3301 estilos en línea y 1913 colores hex pese a existir variables de marca (web-drivique/src/styles/brand-system.css). Muestreo: se leyeron los dos componentes más grandes. | Impacto: Cada cambio en el panel arriesga romper otra función de la misma página; el cambio de marca por servidor no alcanza los colores incrustados.
- **Cómo cerrarlo (L):** Partir cada página en contenedor, hooks de datos y componentes de tabla/formulario/modal de menos de 300 líneas y mover colores y espaciados a las variables CSS.

### [Alto] H-16 · /uploads/** se sirve sin autenticacion y contiene documentos de identidad, contratos firmados y evidencias
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/drivique/api/config/SecurityConfig.java:40`
- **Por qué importa:** Una cadena de filtros dedicada con permitAll para /uploads/** (SecurityConfig.java:40-51, repetida en :79) y WebMvcConfig.java:24 sirven el directorio completo. LocalFileStorageService guarda ahi los documentos KYC (UserDocumentService.java:155), la firma y el PDF del contrato (ContractSignatureService.java:98-100) y las fotos de incidentes (IncidentService.java:376). Los endpoints autenticados de lectura (ContractService.java:219) quedan evadidos por la URL cruda, y UserDocumentResponseDTO.java:17 la entrega al cliente. La unica barrera es el nombre UUID del archivo (sin caducidad ni revocacion); el CSP de esa ruta usa frame-ancestors con comodin (SecurityConfig.java:49). Son datos personales sensibles (Ley 1581). Se marca alto y no critico porque explotarlo exige conocer la URL.
- **Cómo cerrarlo (M):** Quitar /uploads/** del permitAll y de la cadena propia, servir los archivos privados solo mediante endpoints autenticados con verificacion de propietario o personal (ya existe storage.read), o usar URLs firmadas de corta duracion. Mover el almacenamiento a un bucket privado, porque el disco de un contenedor es efimero.

### [Alto] H-17 · CORS abierto a cualquier origen con credenciales y la lista configurada nunca se aplica
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/drivique/api/config/SecurityConfig.java:145`
- **Por qué importa:** corsConfigurationSource fija setAllowedOriginPatterns con comodin y setAllowCredentials(true) (lineas 145 y 149); el campo allowedOrigins que se arma desde app.cors.allowed-origins (lineas 27-35) no se usa en ninguna parte. El .env.example dice que CORS_ALLOWED_ORIGINS es obligatorio en qa y main, y el equipo cree que lo restringe. Con tokens Bearer el riesgo es menor que con cookies, pero la configuracion declarada y la real no coinciden y una futura cookie de sesion nacería expuesta.
- **Cómo cerrarlo (S):** Construir la CorsConfiguration con setAllowedOrigins(allowedOrigins) y fallar al arrancar si la lista esta vacia en qa o main; agregar una prueba que verifique que un Origin no listado no recibe Access-Control-Allow-Origin.

### [Alto] H-18 · Codigos OTP de 6 digitos sin limite de intentos ni limitacion de tasa en endpoints publicos
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/drivique/api/service/VerificationCodeService.java:45`
- **Por qué importa:** VerificationCodeService.validate (linea 45) compara el hash del codigo con el de la base y devuelve 400 sin contar intentos ni invalidar el codigo; el espacio es de 1 000 000 valores (linea 28). /v1/auth/verify-email, validate-reset-code y reset-password son publicos (SecurityConfig.java:95-99) y el proyecto no tiene ninguna libreria de limitacion de tasa (busqueda de bucket4j, resilience4j y RateLimit sin resultados). Un atacante puede adivinar el codigo de recuperacion de la cuenta de un correo conocido dentro de su ventana de validez y tomar la cuenta. El bloqueo de 5 intentos (AuthService.java:152) solo protege el login.
- **Cómo cerrarlo (M):** Contar intentos por codigo y por correo, invalidar el codigo tras 5 fallos, agregar limitacion de tasa por IP y por cuenta en los endpoints publicos de auth (Bucket4j o en el proxy) y una prueba negativa que lo demuestre.

### [Alto] H-19 · La app movil no tiene ninguna prueba automatizada y su CI no compila
- **Repositorio:** `project-drivique/front-end_movil`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app-drivique/package.json:13`
- **Por qué importa:** package.json (lineas 5-15) solo tiene build web y lint; no hay archivos de prueba ni jest-expo. El workflow solo busca datos simulados. La app tiene un flujo de pago por WebView y reserva con carga de documentos sin ninguna comprobacion automatica; los arreglos del 21 de octubre llegaron directo a main.
- **Cómo cerrarlo (M):** Agregar jest-expo con pruebas de servicios (sessionTokens, authService, wompiService) y de la logica de pago; correr lint, tsc y test en CI.

### [Alto] H-20 · El frontend web no tiene ninguna prueba automatizada y su CI no compila
- **Repositorio:** `project-drivique/front-end_web`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web-drivique/package.json:6`
- **Por qué importa:** package.json (lineas 6-12) define dev, build, lint y check:no-mocks, sin script test ni dependencias de pruebas; no hay archivos de prueba. El unico workflow ejecuta el escaner de datos simulados, no vite build ni eslint. Flujos criticos como login, reserva y pago con Wompi (con correcciones el 21 de octubre directo en main) no tienen red de seguridad ni verificacion automatica de que el sitio compila antes de que Netlify lo publique.
- **Cómo cerrarlo (M):** Agregar Vitest con Testing Library para login, guardias de ruta y pasos de la reserva, correr npm ci, lint, build y test en el workflow, y pedirlos como requisito de PR.

### [Alto] H-21 · No hay despliegue repetible ni plan de reversa: el CI solo verifica
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `pom.xml:167; .github/workflows/ci.yml:1`
- **Por qué importa:** El unico workflow (ci.yml) corre mvnw verify; ninguna rama (main, qa, dev, HU-*) tiene workflow de despliegue ni se construye ni publica la imagen. El API aparece en Render (netlify.toml del front) sin que el repositorio diga como se publica, que variables lleva ni como se revierte. Documentation/docs/09-deployment/production.md:7 describe el despliegue como diseño (ej. Supabase o AWS RDS) y no el real; no hay rollback-plan ni runbook en ningun repo. Sin esto la promocion dev a qa a main no es reproducible.
- **Cómo cerrarlo (M):** Agregar un job de despliegue (o documentar el despliegue automatico de Render con su render.yaml), publicar la imagen versionada por SHA, escribir un deployment-plan y un rollback-plan breves (volver a la imagen anterior; rollback de Liquibase por changeSet) y una prueba de humo posterior contra /api/actuator/health.

### [Alto] H-22 · La configuracion de compilacion de la app apunta a un marcador y no hay camino de liberacion real
- **Repositorio:** `project-drivique/front-end_movil`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-33
- **Evidencia:** `app-drivique/eas.json:13`
- **Por qué importa:** eas.json define los perfiles preview y production con la URL de marcador del API (lineas 13 y 22) y submit.production vacio; sin la variable, authService.ts:64,106,149 cae a localhost en el puerto 8080. Un APK o AAB generado con estos perfiles no se conecta a ningun backend, y la documentacion (docs/09-deployment/production.md) promete Play Store y App Store. No hay evidencia de una compilacion firmada de la app.
- **Cómo cerrarlo (M):** Fijar la URL del API real (o variables de EAS por ambiente), quitar el fallback a localhost en produccion, y documentar y automatizar la compilacion y el submit (workflow con EAS).

### [Alto] H-23 · El rol EMPLOYEE se quito del seed pero el backend, los permisos y las pruebas siguen exigiendolo
- **Repositorio:** `project-drivique/database`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `02_dml/00_inserts/iam/seed-roles.sql:1; 02_dml/00_inserts/iam/seed-role-permissions.sql:26; scripts/tests/test-hu-bd-06-rbac.sql:61`
- **Por qué importa:** El commit 4380b22 (17-oct, HU-INT-21) borro la fila EMPLOYEE de seed-roles.sql: solo quedan SUPER_ADMIN, BRANCH_ADMIN y CUSTOMER, tambien en dev y qa. Sin embargo seed-role-permissions.sql:26 le asigna permisos (cero filas al no existir), la prueba test-hu-bd-06-rbac.sql:61-64 espera 5 permisos para EMPLOYEE, el HU-END-TO-END lo lista como rol obligatorio y el backend lo exige en 16 @PreAuthorize (p. ej. CashPaymentController: solo EMPLOYEE o BRANCH_ADMIN confirman pagos en efectivo). Ademas el backend usa ADMIN, AGENT y FLEET_MANAGE y el web mapea BRANCH_MANAGER, que tampoco existen en iam.roles. Una base creada desde cero no tiene el rol de personal de mostrador.
- **Cómo cerrarlo (S):** Decidir el catalogo de roles (CUSTOMER, EMPLOYEE, BRANCH_ADMIN, SUPER_ADMIN segun el documento de cierre), sembrar EMPLOYEE de nuevo, eliminar de @PreAuthorize y del web los roles que no existen y hacer que la prueba RBAC falle el pipeline.

### [Medio] H-06 · La app móvil repite el pago firmado y verificado en el dispositivo
- **Repositorio:** `project-drivique/front-end_movil`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** matizado (severidad ajustada de alto)
- **Evidencia:** `app-drivique/modules/reservation/services/wompiService.ts:15`
- **Por qué importa:** Mismo patrón que la web: clave de integridad en el código (línea 15, valor ««redactado»»), firma en línea 42, consulta a sandbox.wompi.co en línea 172 y llamada a /reservations/checkout/confirm desde app-drivique/app/payment-response.tsx:92; ningún uso de /payments/wompi. | Impacto: Un APK decompilable expone la clave y permite firmar montos arbitrarios; la verificación depende del cliente.
- **Cómo cerrarlo (M):** Reutilizar el endpoint initiate del backend y eliminar la clave; mostrar el estado del pago leyéndolo del backend.

### [Medio] H-24 · La bitácora de auditoría de la app se fabrica en el cliente con IP y correo inventados
- **Repositorio:** `project-drivique/front-end_movil`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app-drivique/store/auditStore.ts:55`
- **Por qué importa:** registrarEvento guarda el correo 'visitante@...' y la IP fija 192.168.1.50; useSocialAuth.ts:76 y :230 generan una IP 192.168.1.x aleatoria con Math.random. Son datos simulados presentados como registros de auditoría, aunque el backend ya tiene AuditService. | Impacto: Una auditoría con datos falsos no sirve de evidencia y contradice el propio guardia 'no-simulated-data' del repositorio.
- **Cómo cerrarlo (S):** Eliminar el store o alimentarlo solo desde el backend; no enviar IP desde el cliente.

### [Medio] H-25 · App móvil sin accesibilidad y con un error de catálogo sin salida
- **Repositorio:** `project-drivique/front-end_movil`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app-drivique/app/(tabs)/catalog.tsx:456`
- **Por qué importa:** 294 TouchableOpacity/Pressable y solo 2 atributos accessibilityLabel/Role en app/ y modules/; si falla la carga del catálogo se muestra únicamente errorTexto sin botón de reintentar (líneas 456-459), mientras la web sí ofrece ErrorState con reintento (CatalogPage.jsx:336 del repo web). | Impacto: El primer paso del flujo principal (buscar vehículo) queda bloqueado ante un fallo de red y la app no es operable con lector de pantalla.
- **Cómo cerrarlo (M):** Añadir accessibilityRole/Label a los controles del flujo reserva-pago y un botón 'Reintentar' en todos los estados de error.

### [Medio] H-26 · El viewport de la web bloquea el zoom y la marca visible sigue siendo RentaMóvil
- **Repositorio:** `project-drivique/front-end_web`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web-drivique/index.html:8`
- **Por qué importa:** maximum-scale=1.0, user-scalable=0 impide ampliar el texto (falla WCAG 1.4.4, que el SRS promete en docs/02-product/goals-and-objectives.md del repo Documentation); el título es 'RentaMóvil — Alquiler de vehículos en Colombia' (línea 9) y package.json se llama web-renta-movil; hay 17 <div onClick> sin rol de botón. | Impacto: Usuarios con baja visión no pueden usar la web y la pestaña del navegador muestra otro producto.
- **Cómo cerrarlo (S):** Quitar maximum-scale y user-scalable, renombrar a Drivique y cambiar los <div onClick> por <button>.

### [Medio] H-27 · El panel de reservas no muestra carga ni error
- **Repositorio:** `project-drivique/front-end_web`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web-drivique/src/modules/admin/pages/ReservationManagementPage.jsx:85`
- **Por qué importa:** cargarYEvaluarReservas solo hace console.error (línea 85) y los catálogos usan .catch(() => undefined) (líneas 88-89); la página no tiene estado de carga y se refresca por polling cada 30 s. Un fallo se ve igual que 'no hay reservas'. | Impacto: El encargado puede creer que no hay entregas ese día cuando en realidad falló la API.
- **Cómo cerrarlo (S):** Exponer isLoading/isError con reintento (react-query ya es dependencia) y avisar con un banner cuando el polling falle.

### [Medio] H-28 · Sin indicadores de éxito medibles y sin historias de usuario con criterios en su carpeta
- **Repositorio:** `project-drivique/Documentation`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/02-product/vision-y-alcance.md`
- **Por qué importa:** La sección 6 'Objetivos y evidencia de éxito' es cualitativa y aclara que no se inventan métricas: no hay ninguno de los 3 indicadores con fórmula, línea base y meta. docs/01-srs/user-stories.md son 11 líneas sin criterios ni prioridad y docs/02-product/user-stories/HU-001-plantilla.md es solo plantilla; las 17 HU-INT con criterios, Must y puntos viven en un archivo suelto del repo database ('HU-END-TO-END-DRIVIQUE (2).md'). Lo bueno: cada RF tiene criterios de aceptación y el backlog usa MoSCoW. | Impacto: No se puede decir si el producto cumplió su propósito, y el backlog real no está donde el equipo dice que está.
- **Cómo cerrarlo (S):** Definir al menos 3 KPI (p. ej. tasa de reserva completada, tiempo de entrega, no-shows) con línea base y meta, y mover las HU-INT a docs/02-product/user-stories/.

### [Medio] H-29 · No existe contrato de experiencia de usuario
- **Repositorio:** `project-drivique/Documentation`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/03-design/ui-ux/.gitkeep`
- **Por qué importa:** La carpeta ui-ux está vacía, no hay inventario de pantallas, flujos alternativos ni tokens de diseño en el repo; solo nombres de componentes dentro de las fichas RF, que además casan poco con los archivos reales. Los criterios de accesibilidad del SRS no se cumplen (H-C09, H-C10). | Impacto: Sin flujos ni tokens, web y móvil divergieron (RentaMovil, colores incrustados, textos distintos) y no hay forma de revisar la usabilidad.
- **Cómo cerrarlo (M):** Publicar un ux-flows.md por flujo principal (buscar, reservar, pagar, firmar, entregar) con estados de error y un design-tokens.md compartido por web y móvil.

### [Medio] H-30 · Pilas tecnológicas y READMEs desactualizados
- **Repositorio:** `project-drivique/Documentation`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/06-mobile/architecture/tech-stack.md:12`
- **Por qué importa:** Documentan Expo ~51 y React Native 0.74 (código: ~57 y 0.86), Vite ^5.4 y Router ^6 (código: Vite 8 y Router 7), XLSX y Lucide que la web no usa, y H2 en el backend (docs/07-backend/tech-stack.md:38; el código usa Testcontainers). El README del Back-end dice sin entidades y Java 21, y el pom fija Java 17. | Impacto: Quien siga la documentación instalará versiones incorrectas y desconfiará del resto.
- **Cómo cerrarlo (S):** Generar los tech-stack desde package.json/pom.xml o enlazar a ellos y corregir los README.

### [Medio] H-31 · Ninguna de las PR tiene revisión: cada persona fusiona su propio código
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/project-drivique/Documentation/pulls/N/reviews devuelve lista vacía en las 43 PR; igual en 13 PR muestreadas por cada uno de los otros 4 repos`
- **Por qué importa:** 952 PR (937 fusionadas) con la cadena dev, qa, main por HU, pero p. ej. las PR 228, 227 y 220 de Back-end las crea y fusiona Integrante 3, y la 50 Integrante 2 se fusiona a sí misma; no hay revisor ni protección de rama verificable. | Impacto: El flujo parece de revisión pero no revisa: así llegó H-C01 a main.
- **Cómo cerrarlo (S):** Exigir una aprobación de otro integrante y activar la protección de rama en main, qa y dev.

### [Medio] H-32 · Cerrar sesion nunca revoca el refresh token en el servidor
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `project-drivique/Back-end:src/main/java/com/drivique/api/controller/AuthController.java:61; project-drivique/front-end_web:web-drivique/src/services/httpClient.js:23`
- **Por qué importa:** POST /v1/auth/logout existe y revoca el refresh token, pero git grep de auth/logout da 0 llamadas en web y movil; clearSessionTokens solo borra el almacenamiento local. Un refresh token copiado sigue vigente tras 'cerrar sesion' hasta su expiracion.
- **Cómo cerrarlo (S):** Llamar a /auth/logout con el refreshToken antes de limpiar el estado local en ambos clientes.

### [Medio] H-34 · Las reseñas de sucursal del panel admin llaman a una ruta con doble prefijo /v1 y fallan en silencio
- **Repositorio:** `project-drivique/front-end_web`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web-drivique/src/services/branchReviewManagementService.js:23`
- **Por qué importa:** El baseURL ya termina en /api/v1 (config/apiConfig.js:2 y netlify.toml:10) y el servicio llama a '/v1/admin/reviews/branches' (lineas 23, 33 y 42), es decir /api/v1/v1/admin/...: 404. El catch devuelve una lista vacia, de modo que el encargado ve 'sin reseñas' y no puede responder ni eliminar. El endpoint real del backend (AdminBranchReviewController) esta completo.
- **Cómo cerrarlo (S):** Cambiar las tres rutas a '/admin/reviews/branches' y mostrar el error en vez de devolver una lista vacia.

### [Medio] H-35 · No se puede levantar el backend completo con los archivos del repo
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/resources/application.yml (variables) frente a .env.example`
- **Por qué importa:** Faltan en .env.example las variables WOMPI_*, GOOGLE_CLIENT_SECRET, FACEBOOK_APP_SECRET, APP_FRONTEND_URL y el secreto JWT; docker-compose.yml solo levanta PostgreSQL sin esquema; el README pide Java 21 mientras pom.xml:30 fija 17. | Impacto: Cada integrante tiene que adivinar la configuración y la base arranca vacía.
- **Cómo cerrarlo (S):** Completar .env.example, añadir el servicio api al compose con dependencia del repo database y alinear la versión de Java.

### [Medio] H-36 · El README de la app móvil no permite levantarla
- **Repositorio:** `project-drivique/front-end_movil`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md`
- **Por qué importa:** Manda a clonar tu-org/rentamovil-frontend y a entrar en 'appmovilrenta' (la carpeta es app-drivique), anuncia Expo ~54/RN 0.81.5 (package.json: ~57/0.86.3), no explica EXPO_PUBLIC_API_URL ni arrancar el backend, e incluye credenciales de una cuenta de prueba de la app y números de Nequi de prueba (««redactado»»). | Impacto: Un integrante nuevo no puede ejecutar la app con la guía y las credenciales de prueba quedan en un repositorio público.
- **Cómo cerrarlo (S):** Reescribir el README con pasos reales (instalar, copiar .env.example, apuntar al backend, npm run android) y mover las cuentas de prueba a un documento privado.

### [Medio] H-37 · Limites de capa debiles: controladores con repositorios, clases de una linea y excepciones tragadas
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/drivique/api/service/ReservationService.java:483`
- **Por qué importa:** VehicleController y NationalityController inyectan repositorios; WompiPaymentService (6 lineas de mas de 400 caracteres), VehicleInspectionService, CashPaymentController y PricingCatalogController estan escritos en una sola linea; ReservationService tiene 973 lineas y mezcla reserva, contrato y pago, con catch (Exception ignored) al generar el contrato (lineas 483 y 569), de modo que una reserva se confirma aun si no se pudo crear el contrato.
- **Cómo cerrarlo (M):** Mover las consultas a servicios, formatear el codigo y dividir ReservationService (reserva, contrato, pago); registrar o propagar los errores de generacion de contrato.

### [Medio] H-38 · El diccionario de datos esta 8 tablas atrasado respecto del SQL de main
- **Repositorio:** `project-drivique/Documentation`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/04-architecture/database/data-dictionary.md:9`
- **Por qué importa:** Declara 69 tablas tomadas del commit e2cb3446 de la rama dev; main tiene 77. Sin documentar: iam.security_configuration_changes, location.branch_categories, location.delivery_drivers, support.incident_attachments, support.incident_status_history y support.notification_delivery_attempts, notification_outbox y notification_templates. Quien lea la documentacion no conoce las tablas de notificaciones, repartidores ni incidencias.
- **Cómo cerrarlo (S):** Regenerar el diccionario desde main, repetir los diagramas ER afectados y fijar el commit; automatizar la comparacion con el SQL en CI.

### [Medio] H-39 · Excepciones tragadas en contratos y pagos
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/drivique/api/service/ContractSignatureService.java:123`
- **Por qué importa:** catch (Exception e) {} vacío en ContractSignatureService.java:123 (falla al emitir la notificación del contrato), 'catch (Exception ignored) {}' en ContractController.java:87 y en ReservationService.java:483 al generar el contrato; CashPaymentService.java:31 también traga RuntimeException. | Impacto: Un contrato o recibo puede no generarse y nadie se entera; el pago queda aprobado sin contrato.
- **Cómo cerrarlo (S):** Registrar con logger al menos el error y reintentar o marcar la entidad como pendiente.

### [Medio] H-40 · Pantallas móviles de más de 1000 líneas, 'any' y colores incrustados
- **Repositorio:** `project-drivique/front-end_movil`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app-drivique/app/(tabs)/notifications.tsx`
- **Por qué importa:** 41 de 168 archivos superan 300 líneas y 4 superan 1000 (notifications.tsx 1545, support.tsx 1541, EditDatesLocationSection.tsx 1206, profile.tsx 1096); 111 usos de 'any' y 821 hex en TSX. | Impacto: TypeScript pierde su valor con 'any' y las pantallas no se pueden probar ni reutilizar.
- **Cómo cerrarlo (M):** Extraer componentes y hooks por pantalla, tipar los DTO del API y centralizar colores en el tema.

### [Medio] H-41 · Swagger UI y /v3/api-docs publicos en todos los perfiles, incluido main
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/drivique/api/config/SecurityConfig.java:82`
- **Por qué importa:** SecurityConfig.java:82-84 declara permitAll para /v3/api-docs/**, /swagger-ui/** y /swagger-ui.html sin condicion de perfil, y application.yml:74-77 los habilita siempre. Publica la superficie completa del API (incluidos los endpoints administrativos) a cualquiera en produccion.
- **Cómo cerrarlo (S):** Deshabilitar springdoc en el perfil main (springdoc.api-docs.enabled en false) o protegerlo con rol de administrador.

### [Medio] H-42 · Valores por defecto de credenciales en la configuracion y en el codigo
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/resources/application.yml:24`
- **Por qué importa:** application.yml:24 deja un valor por defecto para la clave de la base (marcador change-me) y :11 un correo de servicio como usuario SMTP por defecto; el historial muestra que antes fueron valores adivinables (commits fe9429d y 9098b63). Un despliegue que olvide la variable arranca con credenciales predecibles en vez de fallar. Es el mismo patron que H-B01.
- **Cómo cerrarlo (S):** Quitar los defaults de credenciales (usar la variable sin valor por defecto) para que el arranque falle si falta.

### [Medio] H-43 · El consentimiento de Habeas Data no se exige por defecto
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/resources/application.yml:88`
- **Por qué importa:** compliance.required-consents queda como lista vacia (application.yml:88) con el ejemplo comentado en la linea 87. Sin configurar cada ambiente, el registro y la reserva no exigen aceptar terminos ni tratamiento de datos, aunque el sistema guarda cedulas, licencias y datos de contacto.
- **Cómo cerrarlo (S):** Definir los consentimientos obligatorios (terminos y tratamiento de datos, con version del documento) en application.yml para qa y main, y probar que el registro falla sin ellos.

### [Medio] H-44 · La lista de dominios permitidos del WebView de pagos se evalua con includes() sobre la URL completa
- **Repositorio:** `project-drivique/front-end_movil`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app-drivique/app/wompi-checkout.tsx:134`
- **Por qué importa:** wompi-checkout.tsx:134-136 acepta cualquier URL que contenga checkout.wompi.co, .wompi.co o .wompi.com en cualquier parte (incluida la consulta) y tambien http plano (linea 133); el retorno del comercio acepta localhost y 127.0.0.1 (lineas 145-148). Un enlace manipulado dentro del flujo de pago puede mantener al usuario en una pagina falsa que parece parte del checkout.
- **Cómo cerrarlo (S):** Parsear la URL con new URL y comparar protocolo https y hostname exacto o sufijo con punto delante; eliminar los retornos localhost del build de produccion.

### [Medio] H-45 · El access token JWT se guarda en localStorage
- **Repositorio:** `project-drivique/front-end_web`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web-drivique/src/store/authStore.js:82`
- **Por qué importa:** authStore.js:82 hace localStorage.setItem del token (y :87 del perfil completo del usuario); el refresh token queda en sessionStorage (httpClient.js:16) y el codigo de recuperacion tambien en sessionStorage. Cualquier XSS (hay dangerouslySetInnerHTML, ver R-5.5) o extension maliciosa puede leer el token de un administrador.
- **Cómo cerrarlo (M):** Mantener el access token solo en memoria y usar refresh en cookie HttpOnly con SameSite, o al menos acortar su vida y no persistir el perfil; revisar la CSP del sitio en Netlify.

### [Medio] H-46 · Las pruebas de migraciones existen pero ningun CI las ejecuta y el repo no valida el changelog
- **Repositorio:** `project-drivique/database`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:42`
- **Por qué importa:** Hay mas de 30 scripts scripts/test-hu-bd-XX con SQL de comprobacion y pruebas de rollback (fortaleza), pero el repositorio no tiene workflows (gh api: 0 ejecuciones). Un cambio al changelog puede romper la migracion sin que nadie lo vea hasta que alguien corra el script en su maquina con Docker y PowerShell. Por eso tampoco se detecto que el changeSet de usuarios operativos se aplica en todos los ambientes (H-B02).
- **Cómo cerrarlo (M):** Agregar un workflow que levante Postgres como servicio, ejecute liquibase validate y update, los SQL de scripts/tests y un rollback-count; marcar el job como requerido para PR a main.

### [Medio] H-47 · La imagen del API corre como root y no declara HEALTHCHECK
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Dockerfile:9`
- **Por qué importa:** La etapa final (Dockerfile:9-14) parte de eclipse-temurin:21-jre-alpine, copia el jar y ejecuta java -jar sin USER; no hay HEALTHCHECK aunque el endpoint de salud existe (application.yml:58). Ante una vulnerabilidad en la aplicacion, el atacante tendria root dentro del contenedor.
- **Cómo cerrarlo (S):** Crear un usuario sin privilegios (addgroup y adduser) y USER antes del ENTRYPOINT, y agregar HEALTHCHECK contra /api/actuator/health/liveness.

### [Medio] H-48 · main recibe correcciones directas y se adelanta a develop y qa
- **Repositorio:** `project-drivique/front-end_movil`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app-drivique/scripts/check-no-simulated-data.mjs:1; .github/workflows/no-simulated-data.yml:6`
- **Por qué importa:** En front-end_movil, main contiene commits del 21 de octubre (f57c2fb y bd9b4e7, fix de reservas y KYC) que develop y qa no tienen (git diff origin/main origin/develop: 6 archivos); lo mismo en front-end_web (5 archivos). Las ramas feature/pasarela-de-pagos, fix/arreglos y HU-00 siguen vivas y divergidas (mas de 150 archivos de diferencia). En Back-end, database y Documentation, dev y qa solo tienen merges ya reflejados en main. El ambiente de pruebas no refleja lo que se entrega, lo que anula el sentido de la promocion dev, qa, main.
- **Cómo cerrarlo (S):** Aplicar la regla del equipo: toda correccion nace en una rama HU-dev y se promueve; sincronizar develop y qa con main hoy y borrar las ramas feature ya integradas.

### [Medio] H-49 · Varias claves foraneas sin indice propio
- **Repositorio:** `project-drivique/database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/fleet/vehicles.sql:26`
- **Por qué importa:** Sin indice que empiece por la columna: fleet.vehicles (brand_id, fuel_type_id, transmission_type_id, status_id), billing.payments (payment_method_id, currency_id), contract.rental_contracts (vehicle_id, pickup_branch_id, return_branch_id, signed_city_id), iam.users (document_type_id, nationality_id), rental.branch_reviews (user_id) y otras. PostgreSQL no los crea solo; los borrados del padre y los joins escanean la tabla hija. Hay ademas un indice redundante (idx_users_email sobre una columna UNIQUE). Cruce hecho con un script de lectura sobre 01_ddl; puede haber algun falso positivo en tablas con indices compuestos.
- **Cómo cerrarlo (S):** Agregar un changeset de indices para esas FK (con su rollback) y quitar el redundante.

### [Medio] H-50 · Clave primaria compuesta (id, email) en iam.users que la entidad no refleja, y datos de direccion duplicados
- **Repositorio:** `project-drivique/database`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/04_alters/iam/add-composite-pk-email-hu-int-21.sql:5`
- **Por qué importa:** El changeset de HU-INT-21 hace DROP de users_pkey con CASCADE y recrea 33 FK; deja el email (mutable) dentro de la clave primaria mientras User.java:14 usa solo id y todas las FK apuntan a uq_users_id. Es una clave que no aporta integridad y que complica cualquier cambio de correo. La direccion existe dos veces (iam.users.address y iam.user_profiles.address) y user_profiles no tiene entidad ni uso en el backend.
- **Cómo cerrarlo (M):** Volver a PK simple en id con email UNIQUE, decidir un solo lugar para la direccion y eliminar o usar iam.user_profiles.

### [Medio] H-51 · El contrato OpenAPI esta incompleto y no se publica
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/drivique/api/controller/AuthController.java:24`
- **Por qué importa:** 136 anotaciones @Operation para 228 mapeos; 20 de 52 controladores no tienen ninguna (register, resend-verification y validate-reset-code en AuthController, PaymentWebhookController, CashPaymentController, FleetCatalogController, PricingController, etc.). El contrato solo existe en tiempo de ejecucion (/api/v3/api-docs): docs/07-backend/contracts/openapi esta vacio. Los clientes no pueden generar tipos ni el equipo verificar el contrato contra ellos.
- **Cómo cerrarlo (M):** Anotar todos los endpoints, exportar openapi.json en CI al repositorio Documentation y validar los clientes contra el.

### [Medio] H-52 · Paginacion solo en tres endpoints y orden dinamico sin lista blanca
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/main/java/com/drivique/api/controller/VehicleController.java:46`
- **Por qué importa:** Solo /vehicles/search, /admin/vehicles y /admin/reports/data paginan; AdminUserController.list (linea 30), BranchController.active, incidentes, notificaciones y reservas del panel devuelven listas completas. En /vehicles/search el parametro sort se pasa directo a Sort.by(property) (lineas 46-55): una propiedad inexistente produce PropertyReferenceException y cae en el manejador generico de 500 (inferido de la lectura, no ejecutado).
- **Cómo cerrarlo (S):** Estandarizar Pageable con tope en todas las listas del panel y validar sort contra una lista de campos permitidos.

### [Bajo] H-53 · Copia numerada del backlog versionada en la raíz
- **Repositorio:** `project-drivique/database`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md`
- **Por qué importa:** 'HU-END-TO-END-DRIVIQUE (2).md' (35 KB) está en la raíz del repo de base de datos aunque el Back-end la ignora; es un backlog de integración, no un artefacto de base de datos. | Impacto: Archivo duplicado en el lugar equivocado.
- **Cómo cerrarlo (S):** Moverlo a Documentation (docs/02-product/user-stories/) y quitar el '(2)'.

### [Bajo] H-54 · Carpeta .idea versionada
- **Repositorio:** `project-drivique/front-end_movil`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `app-drivique/.idea/misc.xml`
- **Por qué importa:** Se versionan app-drivique/.idea/ con 8 archivos, incluido caches/deviceStreaming.xml de 1906 líneas, aunque app-drivique/.gitignore existe. | Impacto: Ruido y conflictos de IDE en cada PR.
- **Cómo cerrarlo (S):** git rm -r --cached app-drivique/.idea y añadir .idea/ al .gitignore.

### [Bajo] H-55 · Documentos de API, CHANGELOG y CONTRIBUTING vacíos y UML sin vincular
- **Repositorio:** `project-drivique/Documentation`
- **Lente SDLC OS:** A05 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-62
- **Evidencia:** `docs/07-backend/api-docs/swagger.md`
- **Por qué importa:** swagger.md y postman-collection.md son stubs ('Aquí se debe alojar...'), docs/CHANGELOG.md, docs/CONTRIBUTING.md y docs/01-srs/restricciones-y-supuestos.md tienen 4 bytes, y la columna UML de docs/01-srs/matriz-trazabilidad.md dice 'Vincular CU/secuencia' en los 54 requisitos. | Impacto: Los entregables que el README promete no existen.
- **Cómo cerrarlo (S):** Exportar openapi.json del Back-end, rellenar o eliminar los archivos vacíos y completar la columna UML.

### [Bajo] H-56 · Seguimiento sin issues ni tablero
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api search/issues devuelve 0 issues en los 5 repos y graphql projectsV2 totalCount 0`
- **Por qué importa:** El plan existe como Markdown (docs/HU-BE-xx.md en Back-end, 17 HU-INT con 154 casillas sin marcar en el repo database); no se puede ver estado ni responsable. | Impacto: No hay forma objetiva de saber qué HU está terminada.
- **Cómo cerrarlo (S):** Crear un proyecto de GitHub con las HU-INT y vincular cada PR a su issue.

### [Bajo] H-57 · Cientos de ramas viejas y algunas con trabajo menor sin integrar
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `Back-end: origin/HU-BE-26-qa (420e0c0), origin/HU-BE-17-dev (9f77761); front-end_movil: origin/fix/resumen-reserva-mejoras (a996258), origin/feature/pasarela-de-pagos (2ec8fc4), origin/fix/arreglos (1a5948a)`
- **Por qué importa:** El flujo HU-xxx-dev/qa/main deja 196 ramas en Back-end y database, 234 en web y 155 en móvil. dev y qa son idénticos a main, pero 420e0c0 (quita cascade en Reservation) y 9f77761 (reinicio de BD en pruebas) en Back-end, y tres ramas de móvil de jul-sep (wompi, cupones por categoría) no están en main por patch-id; no se determinó si fueron reemplazadas. | Impacto: Ruido que oculta cuál es la rama viva y riesgo de perder arreglos.
- **Cómo cerrarlo (S):** Borrar las ramas HU ya fusionadas (GitHub 'delete branch on merge') y decidir caso a caso las cinco con commits propios.

### [Bajo] H-58 · Ramas con trabajo de reserva y pago que main no tiene
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `project-drivique/front-end_movil:app-drivique/eas.json:1`
- **Por qué importa:** front-end_movil: fix/resumen-reserva-mejoras (4 archivos, 1-sep: abandono de Wompi, cancelar por sucursal, cupones por categoria), fix/arreglos (13 archivos, 1-sep), feature/pasarela-de-pagos (24 archivos, 23-jul, primer trabajo de Wompi); front-end_web: fix/HU-14-calendario-reservas-dev (8 archivos, 17-jul); Back-end: HU-BE-17-dev/main y HU-BE-26-qa (commits de pruebas del 1 y 2 de oct sobre bases viejas). Las ramas dev y qa de los cinco repos solo tienen merges de HU-INT-21 sin diferencia de contenido. No se verifico si el trabajo de las ramas fix/ se reimplemento en main por otra via.
- **Cómo cerrarlo (S):** Revisar cada rama, integrar o cerrar y borrar las ramas viejas para que main sea la fuente del flujo de reserva y pago.

### [Bajo] H-59 · La documentacion y el Dockerfile dicen Java 21, el pom compila para Java 17
- **Repositorio:** `project-drivique/Back-end`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `pom.xml:30`
- **Por qué importa:** pom.xml fija java.version y maven.compiler.release en 17; README.md, docs/04-architecture/decisions/0003-stack-backend.md y el Dockerfile (imagenes temurin-21) indican 21. Corre en 21 pero compila con nivel de lenguaje 17: la documentacion no describe lo construido.
- **Cómo cerrarlo (S):** Alinear pom.xml a 21 o corregir la documentacion.

### [Bajo] H-60 · Pagina de prueba de Wompi con llave y firma de integridad dentro del sitio publicado
- **Repositorio:** `project-drivique/front-end_web`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `web-drivique/public/wompi-test.html:27`
- **Por qué importa:** public/wompi-test.html se copia a dist y se sirve en Netlify; contiene la llave publica de prueba y una firma de integridad precalculada (linea 31) para un monto fijo. No es la llave de integridad, pero es una pagina de depuracion en produccion y una referencia de pago de prueba reutilizable.
- **Cómo cerrarlo (S):** Mover la pagina fuera de public/ o excluirla del build de produccion.

### [Bajo] H-61 · Semilla de datos 'realistas' huerfana en main y ya eliminada en dev y qa
- **Repositorio:** `project-drivique/database`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `02_dml/00_inserts/seed-demo-realistic-data.sql:1`
- **Por qué importa:** El archivo de 399 lineas (clientes colombianos, reservas, KYC) no esta en ningun changelog, asi que no se ejecuta, pero queda en main; las ramas dev y qa (PR 246 y 248 del 19-oct) lo borran y main no recibio ese cambio. Es el unico SQL sin referencia de 264.
- **Cómo cerrarlo (S):** Borrarlo de main o moverlo a una carpeta de demos fuera de 02_dml y documentarlo.

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 80.0 |
| D2 | Reproducibilidad | 61.2 |
| D3 | Arquitectura y congruencia | 54.2 |
| D4 | Calidad de código | 40.9 |
| D5 | Seguridad | 59.2 |
| D6 | Pruebas | 42.5 |
| D7 | DevOps y despliegue | 59.1 |
| D8 | Datos | 60.0 |
| D9 | API y contratos | 55.0 |
| D10 | Frontend y móvil | 60.4 |
| D11 | IoT y firmware | — |
| D12 | Documentación y trazabilidad | 44.4 |
| D13 | Proceso y colaboración | 84.2 |
| D14 | Extremo a extremo | 42.3 |

## Lo que está bien

- Migraciones Liquibase completas, ordenadas y reversibles (`project-drivique/database:changelog/db.changelog-master.yaml:1 incluye 54 releases (hu-bd-03..41, hu-int-04..21); 263 de 263 rollbacks estan referenciados y solo 1 de 264 SQL de avance queda fuera de un changelog.`)
- Entidades del backend y esquema fisico alineados (`72 entidades JPA con @Table apuntan a tablas existentes en el DDL de project-drivique/database y ninguna columna @Column/@JoinColumn queda sin aparecer en el SQL (cruce hecho sobre src/main/java/com/drivique/api/model y 01_ddl); ddl-auto validate en src/main/resources/application.yml:37.`)
- Minimo privilegio para la aplicacion en la base (`project-drivique/database:docker/initdb/01-create-application-role.sh crea un rol LOGIN sin SUPERUSER ni CREATEDB con clave por variable de entorno, mas 21 archivos en 03_dcl/01_grants.`)
- Contrato de errores uniforme y API versionada (`project-drivique/Back-end:src/main/java/com/drivique/api/exception/ApiExceptionHandler.java:103 devuelve application/problem+json con ApiProblem; los 52 controladores cuelgan de /v1.`)
- Firma del webhook de Wompi verificada con comparacion en tiempo constante (`project-drivique/Back-end:src/main/java/com/drivique/api/service/WompiSignatureService.java:12 usa MessageDigest.isEqual sobre el checksum del evento.`)
- Clientes alineados con el backend en autenticacion, reserva y contrato (`project-drivique/front-end_movil: 79 llamadas directas a la API y 0 sin contraparte en project-drivique/Back-end (cruce automatico de rutas y metodos); CreateReservationRequestDTO.java coincide con el cuerpo de reservationPersistService.ts:238.`)
- Documentacion de arquitectura y datos honesta sobre su alcance (`project-drivique/Documentation:docs/04-architecture/overview.md (C4 nivel 1 y 2) y docs/04-architecture/database/data-dictionary.md:9 fijan el commit fuente y declaran lo que no acreditan.`)
- Despliegue en linea operativo (`GET https://drivique-api.onrender.com/api/actuator/health y /api/v1/vehicles/featured respondieron 200; netlify.toml:10 del repo web declara esa API y driviqueapp.netlify.app respondio 200.`)
- Pruebas de base de datos y de backend contra PostgreSQL real (`project-drivique/Back-end:.github/workflows/ci.yml ejecuta mvn verify con Testcontainers PostgreSQL 17 y un guardia contra datos simulados; project-drivique/database:scripts/tests tiene 50 pruebas SQL.`)
- Autorizacion por rol a nivel de clase y propiedad del recurso en los servicios (`src/main/java/com/drivique/api/controller/AdminUserController.java:20; src/main/java/com/drivique/api/service/ReservationService.java:386`)
- Contraseñas con BCrypt costo 12; refresh token aleatorio, guardado como hash y rotado; bloqueo tras 5 intentos probado (`src/main/java/com/drivique/api/config/PasswordConfig.java:9; src/main/java/com/drivique/api/service/AuthService.java:198; src/test/java/com/drivique/api/auth/AuthIntegrationTests.java:126`)
- Webhook de Wompi con validacion de firma en tiempo constante (`src/main/java/com/drivique/api/service/WompiSignatureService.java:16`)
- Suite de pruebas amplia (457 pruebas, Testcontainers PostgreSQL 17) que corre en cada PR, con regla de cobertura JaCoCo y CI en verde en main (`pom.xml:167; .github/workflows/ci.yml:36`)
- Errores sin fuga de detalles: sin stacktrace ni mensaje interno, salud sin detalles, Problem Details y auditoria con enmascarado de campos sensibles (`src/main/resources/application.yml:4`)
- Guardia de CI que impide datos y proveedores simulados en codigo productivo (`pom.xml:167; .github/workflows/ci.yml:21`)
- Proteccion contra path traversal y validacion de tipo, extension y tamaño de archivo al almacenar (`src/main/java/com/drivique/api/service/LocalFileStorageService.java:78`)
- Base de datos con pruebas de migracion y rollback por HU, rollback por cada changeSet y rol de aplicacion distinto del de migracion (`scripts/test-hu-bd-06-rbac.ps1`)
- Git flow estricto por historia de usuario con 952 PR (`gh api search/issues repo:project-drivique/* type:pr: 228+43+250+179+252 PR; ramas HU-xxx-dev/qa/main y merges 'Merge pull request #228' en Back-end`)
- Mensajes de commit con convención y aportes repartidos (`git log --all --no-merges: 1575 de 1802 commits siguen Conventional Commits; ningún integrante supera 65 % del total`)
- dev y qa sin trabajo atrapado respecto a main (`git diff HEAD origin/dev y origin/qa sin diferencias de árbol en Back-end, database, front-end_web y front-end_movil`)
- SRS completo con criterios de aceptación por requisito y matriz RF-endpoint-tabla fiable (`docs/01-srs/functional-requirements.md (54 RF con Criterios de Aceptación) y docs/01-srs/matriz-trazabilidad.md: 62 de 63 rutas citadas existen en los controladores`)
- Backlog de integración con criterios, DoR/DoD y puntos (`HU-END-TO-END-DRIVIQUE (2).md en project-drivique/database: 17 HU-INT con MoSCoW, criterios de aceptación y Story Points`)
- Manejo central de errores y capas respetadas en el backend (`src/main/java/com/drivique/api/exception/ApiExceptionHandler.java; solo 2 de 52 controladores importan repositorios`)
- Repositorio de base de datos con Liquibase, rollbacks por archivo y prueba reproducible (`changelog/db.changelog-master.yaml, 05_rollbacks/ y scripts/test-liquibase-migrations.ps1; docker-compose.yml con healthcheck`)
- Sesión con refresco automático y cola de peticiones en web y móvil, refresh token en SecureStore (`web-drivique/src/services/httpClient.js:30; app-drivique/services/http/sessionTokens.ts`)
- Catálogo web con estados de carga, error con reintento y vacío (`web-drivique/src/modules/catalog/pages/CatalogPage.jsx:335`)
- Guardia de CI contra datos simulados en los tres repos de código (`.github/workflows/ci.yml (Back-end) y .github/workflows/no-simulated-data.yml en web y móvil`)

## Lo que no se pudo verificar

- Levantar la base desde cero y aplicar los 54 releases (R-8.5) — Exige docker y liquibase; el briefing prohibe ejecutar codigo de los aprendices.
- Si las cuentas semilla de administrador existen en la base desplegada en Render — No se intento autenticar ni consultar la base; solo se lee el repositorio.
- Flujo autenticado de reserva y pago contra el despliegue (T-14.3) — Escribiria datos en un servicio de terceros; solo se hicieron GET publicos (health, vehicles/featured y la portada).
- Comportamiento de PUT /users/me con campos de clave, de sort invalido y de confirm sin pago — Inferido por lectura de DTO y servicio; no se ejecuto ningun endpoint.
- Triggers (53), funciones y vistas del esquema, y tipos/nulabilidad entidad contra columna — El cruce de entidades contra DDL comparo nombres de tabla y columna; no se revisaron tipos ni los triggers en profundidad.
- Si las ramas fix/ y feature/pasarela-de-pagos fueron reimplementadas en main — Solo se comparo el diff de cada rama contra su base; no se rastreo la reimplementacion.
- Autorizacion de GET /v1/branches/admin y /managers frente a la regla publica /v1/branches/* — Es seguridad (D5, especialista B); se deja anotado para que lo revise quien corresponda.
- Documentacion en Google Drive — El equipo declara la organizacion project-drivique como evidencia, no una carpeta de Drive; se evaluo contra el repositorio Documentation.
- Que responde el API desplegado y si JWT_SECRET esta definida en Render — Un unico GET a la URL de salud del API declarada en netlify.toml devolvio 000 (sin respuesta en 15 s, posible arranque en frio); no se puede leer la configuracion del host. De eso depende que H-B01 sea explotable hoy.
- Si las migraciones con las credenciales de demostracion (H-B02) se aplicaron a un ambiente de produccion — No hay acceso a las bases ni a un ambiente publico declarado.
- Que las pruebas del Back-end pasen en una maquina limpia — No se ejecuta codigo de los aprendices (mvn, docker); se uso el estado de las ejecuciones de CI (43 exitosas de 50).
- Contenido interno de appmovilrenta1.zip y web-renta-movil.zip del historial — Solo se listaron los nombres de las entradas (sin .env, llaves ni keystores); no se escaneo el contenido de cada archivo.
- Limitacion de tasa en el proxy o en Render para los endpoints de auth — Fuera del repositorio; el codigo no tiene ninguna.
- Si los clientes del seed demo (database seed-demo-realistic-data.sql) son personas reales — El comentario dice clientes reales colombianos; no se pudo contrastar con ninguna fuente.
- URL publica del frontend web y de la app movil — El equipo declara solo la organizacion de GitHub; no hay URL de la web ni enlace de descarga de la app.
- Compilación y ejecución de web, móvil y API — No se ejecutó npm, expo, mvn ni docker; R-10.1 se evaluó leyendo scripts, dependencias y resolviendo 799 y 606 importaciones locales.
- Despliegue en línea — El equipo solo declara la organización de GitHub; aunque netlify.toml cita drivique-api.onrender.com y driviqueapp.netlify.app no son URL declaradas, así que no se hizo GET.
- Miembros, propietarios y protección de ramas de la organización project-drivique — La API devolvió 403/404 sin permisos de administración; T-13.6 queda en PARTIAL.
- Revisiones de las PR — Se muestrearon 56 de 952 PR (43 de Documentation y 13 por cada otro repo): todas sin revisión; no se leyeron los comentarios en línea.
- Muestreo de D4 — Lectura profunda de los dos componentes más grandes del equipo (BranchDashboard.jsx y ReservationManagementPage.jsx de la web) más ReservationService.java y WompiPaymentService.java; el resto por patrones (git grep) y conteo de líneas.
- Diagramas UML (.drawio y PDF) y rutas de la matriz no encontradas — No se abrieron los diagramas; en la matriz se comprobó con un script que 62 de 63 rutas existen (POST /api/v1/reservations no se pudo casar automáticamente).
- Si las ramas antiguas de móvil y Back-end fueron reemplazadas — Los parches no están en main por patch-id pero los archivos divergieron; requiere decisión del equipo.
- Documentación en Drive — El equipo declara solo la organización de GitHub y la documentación sí vive en el repo Documentation; no aplica la regla de Drive.
