# Equipo 7 · Hidro Smart — evaluación extremo a extremo

Corte 2026-10-22 · **Puntaje 64/100 · Juicio D**

## Veredicto

Hidro Smart tiene tres de sus cinco flujos principales completos de punta a punta (registro e inicio de sesion, hogares y miembros, dispositivos con telemetria y consumo), sobre una base PostgreSQL versionada con Liquibase y RLS y un backend en capas con 62 archivos de prueba. Los otros dos flujos estan rotos: la web no permite crear reglas ni umbrales, asi que las alertas no pueden arrancar, y las recomendaciones de ahorro no tienen pantalla conectada al backend. Lo mas urgente es un hallazgo bloqueante de seguridad: archivos de entorno con credenciales reales siguen publicados en ramas del repositorio publico PT_HS y deben rotarse hoy. Ademas, el conjunto PT_HS esta congelado desde septiembre, con CI, firmware y contrato OpenAPI en ramas sin integrar, y no hay ningun PR con revision. Con 63.9 puntos y juicio D, el equipo queda a poco mas de 6 puntos del umbral de 70: cerrar el flujo de alertas, integrar las ramas a main y poner CI en los repositorios es el camino mas corto.

## Plan para cerrar las brechas

1. **Rotar todas las credenciales expuestas (base de datos, usuario de ingesta, clave JWT, SMTP, Liquibase), tratar la cuenta SMTP como comprometida y eliminar los archivos de entorno de las ramas hu-06/07/08-dev o reescribir el historial; dejar solo .env.example.** (esfuerzo S) — se cierra cuando: git grep de los archivos de entorno en todas las ramas y en el historial publicado no devuelve resultados, y las claves anteriores ya no autentican contra ningun servicio.
2. **Agregar a la pantalla de alertas el formulario de umbrales y reglas (alertsApi.saveThresholds y createRule) y crear umbrales por defecto al registrar el hogar, para que el flujo de alertas arranque.** (esfuerzo M) — se cierra cuando: Un usuario nuevo crea una regla desde la web, el job genera un evento de alerta y este aparece y se atiende en la pantalla, con estados de carga y error visibles.
3. **Unificar la fuente de verdad: fusionar hu-15-dev en dev y dev en main de PT_HS (previa purga de secretos), decidir el destino de las ramas hu-03, 08, 10, 11 y 13, y declarar si el entregable es el conjunto o los tres repositorios.** (esfuerzo M) — se cierra cuando: main de PT_HS contiene firmware, CI y documentacion vigentes, su README refleja el estado real y no hay commits relevantes solo en ramas huerfanas.
4. **Poner CI en los tres repositorios de componente (lint, pruebas, liquibase validate, build) y exigirla en PR a main; agregar pruebas al frontend y hacer que npm test falle si descubre cero pruebas.** (esfuerzo M) — se cierra cuando: Cada repositorio muestra ejecuciones verdes de Actions en main, el frontend ejecuta pruebas reales y la CI de BD_HS valida y aplica migraciones sobre un Postgres efimero.
5. **Asegurar el broker MQTT: TLS, usuario y ACL por dispositivo, puerto enlazado a 127.0.0.1 en el compose local; llevar lo mismo al firmware (WiFiClientSecure y almacenamiento cifrado de claves Wi-Fi).** (esfuerzo M) — se cierra cuando: El broker rechaza conexiones anonimas, la telemetria falsa sin credenciales no llega a la base y el firmware se conecta por TLS con verificacion de certificado.
6. **Integrar a main de BK_HS, BD_HS y FT_HS las ramas adelantadas (hu-11, hu-12, hu-21) con openapi.yaml, operacion-local.md y scripts de arranque, y completar el OpenAPI de los flujos principales.** (esfuerzo M) — se cierra cuando: main de BK_HS contiene docs/openapi.yaml con cuerpos y respuestas de registro, hogares, dispositivos y consumo, y los enlaces de FT_HS apuntan a main.
7. **Documentar el producto y el despliegue una sola vez: docs/producto.md con problema, usuarios, alcance, tres indicadores e historias con criterios; docs/despliegue.md vigente; desplegar API y broker con plan de rollback.** (esfuerzo L) — se cierra cuando: Existen ambos documentos sin contradicciones entre repositorios, el README publica la URL del API desplegada y hay un procedimiento de rollback probado.
8. **Ordenar el proceso de equipo: PR con al menos una aprobacion de otro integrante y proteccion de ramas, un issue por HU con tablero, y mover los cuatro repositorios a una organizacion del equipo.** (esfuerzo S) — se cierra cuando: main exige una revision aprobada, cada HU tiene issue enlazado a su PR y los repositorios pertenecen a una organizacion con permisos para los tres integrantes.
9. **Conectar la pantalla de recomendaciones al cliente HTTP y decidir, metodo por metodo, si se construye la pantalla (ARCO de administracion y miembros primero) o se retira ruta, funcion SQL y metodo.** (esfuerzo M) — se cierra cuando: RecommendationsPage consume recommendationsApi con datos reales y no quedan metodos del cliente sin uso sin justificar.
10. **Corregir reproducibilidad: completar .env.example de PT_HS con las variables del compose, arreglar enlaces y rutas heredadas del monolito en BK_HS y FT_HS, y quitar el respaldo silencioso a localhost de la URL de la API.** (esfuerzo S) — se cierra cuando: Un clon limpio de cada repositorio levanta siguiendo solo su README, docker compose config no reporta variables faltantes y ningun enlace relativo sale del repositorio.
11. **Refactorizar y pulir calidad: dividir las pantallas y el apiClient monoliticos y el repositorio de dispositivos, aprovisionamiento sin Web Bluetooth, CSRF documentado, ajustes menores de seguridad, contenedor y accesibilidad.** (esfuerzo L) — se cierra cuando: Ninguna pantalla supera unas 300 lineas, el aprovisionamiento tiene ruta alterna documentada, /health solo devuelve estado, la imagen corre sin root y el atributo lang del HTML sigue al idioma activo.
12. **Mejorar el modelo de datos y su documentacion: diagrama ER y modelo.md, una definicion vigente por funcion SQL, politicas ON DELETE explicitas, retiro de codigos de dispositivo sembrados y paginacion real en base de datos.** (esfuerzo L) — se cierra cuando: Hay un ER generado del esquema real, ninguna clave foranea sin politica, ningun codigo de dispositivo real en el repositorio y los listados usan LIMIT y OFFSET en la consulta.

## Verificación independiente

Hallazgos confirmados: 5 · matizados: 0 · refutados: 0 · duplicados fusionados: 2.

Confirme las 5 afirmaciones de hallazgos (H-01 bloqueante, con secretos reales en ramas e historial publicos de PT_HS; H-02, H-03, H-05 y H-06 alto), los 4 items PASS (R-5.1 BD_HS, R-8.1, T-14.2, R-6.1 PT_HS), los 5 flujos (3 COMPLETO, con la salvedad de SMTP en el registro y la ausencia del firmware en los SHA evaluados; 2 ROTO) y las cifras de aportes (108/64/53/2); la API de GitHub resuelve los 24 commits de BD_HS con nombre Integrante 3 como de Integrante 1. No refute nada; matices: H-03 y H-06 se solapan, H-36 se absorbe en H-06 y el unico duplicado real de los 12 pares es H-28 dentro de H-26 (los otros 10 son defectos distintos).

## Flujos extremo a extremo

| Estado | Flujo | Dónde se rompe |
|---|---|---|
| Completo | Registro, verificacion de correo e inicio de sesion | — |
| Completo | Crear hogar y gestionar miembros | — |
| Completo | Vincular dispositivo, telemetria MQTT y consulta de consumo | — |
| Roto | Configurar umbrales y reglas de alerta y atender la alerta | Paso 1, la pantalla: ninguna interfaz crea reglas ni umbrales. El cliente define createRule y saveThresholds pero ninguna pagina los llama; AlertsPage solo lee historial, pendientes y umbrales. Como todo alert_event nace de alert_rule o threshold_configuration (fn_generate_alert_events y los triggers de lectura) y ninguna semilla ni funcion inserta esas filas, un usuario nuevo nunca obtiene alertas por la web. |
| Roto | Consultar recomendaciones de ahorro | Paso 1, la pantalla: RecommendationsPage muestra 10 consejos fijos y declara en su comentario que no representan recomendaciones generadas. El backend (3 rutas /recommendations), las tablas recommendation y user_recommendation y la vista mv_recommendation_summary existen pero ninguna pantalla las consume. |

## Hallazgos

### [Bloqueante] H-01 · Archivos de entorno con credenciales reales publicados en un repositorio publico
- **Repositorio:** `propietario/PT_HS`
- **Lente SDLC OS:** A12 · **Verificación independiente:** confirmado
- **Evidencia:** `.gitignore:2 (la regla de ignorar .env llego tarde); commits aebaf48, a613c82 y 6b0bd19; los cuatro archivos de entorno (raiz, BD_HS, BK_HS y FT_HS/frontend) siguen en el arbol de origin/hu-06-dev, origin/hu-07-dev y origin/hu-08-dev y en el historial de hu-09-dev, hu-12-dev, hu-14-dev y hu-15-dev (aebaf48); a613c82 solo en hu-08-dev`
- **Por qué importa:** Contienen contrasena de base de datos (25 caracteres), contrasena del usuario de ingesta (28), clave JWT (60), contrasena y usuario SMTP (16 caracteres, apunta a Gmail) y contrasenas de Postgres y Liquibase; valores ««redactado»». Confirmado con git ls-tree y con la API de contenidos de GitHub (el archivo de entorno del backend pesa 1520 bytes en hu-06-dev). Cualquiera puede leerlos; con la clave JWT se pueden forjar sesiones si se reutilizo en algun despliegue, y la cuenta de correo queda expuesta.
- **Cómo cerrarlo (S):** Rotar de inmediato todo (base de datos, JWT, SMTP, Liquibase), tratar la cuenta SMTP como comprometida, borrar las ramas hu-06/07/08-dev o reescribir el historial con git filter-repo, activar secret scanning y push protection en el repositorio.

### [Alto] H-02 · No existe definicion de producto: ni problema, usuarios, alcance, indicadores de exito, ni historias con criterios de aceptacion
- **Repositorio:** `propietario/PT_HS`
- **Lente SDLC OS:** A05 · **Verificación independiente:** confirmado
- **Evidencia:** `README.md:1`
- **Por qué importa:** Sin historias ni criterios no hay forma de decidir cuando una HU esta terminada ni de ubicar un requisito en una pantalla o endpoint (T-12.3). Los numeros de HU solo viven en nombres de rama (hu-01 a hu-21) y no son consistentes entre repos (BD_HS consolida 'HU-18' mientras que FT_HS usa hu-10 a hu-13). El equipo no declaro Drive; el README tampoco describe el problema ni los usuarios.
- **Cómo cerrarlo (M):** Crear docs/producto.md (problema, usuarios, alcance MVP, al menos 3 indicadores medibles con formula y meta) y un backlog con las HU en formato Como/Quiero/Para, prioridad MoSCoW, al menos 3 Must con 2 criterios de aceptacion cada una, y una tabla HU -> pantalla -> endpoint -> tabla.

### [Alto] H-03 · El repositorio 'conjunto' declarado (PT_HS) esta atrasado: main tiene 1 commit, dev se congelo el 9-sep y todo lo demas esta en ramas sin integrar
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** confirmado
- **Evidencia:** `propietario/PT_HS: git rev-list --count origin/dev..origin/hu-15-dev = 16; main = 31676d3; dev = 21770ed`
- **Por qué importa:** Quien abra el enlace del equipo ve un sistema de hace seis semanas, sin firmware del ESP32, sin CI, sin el modelo ER ni la guia de operacion actual; el firmware (carpeta firmware/ con 12 archivos) no existe en ninguno de los otros tres repositorios. Es trabajo entregable atrapado y la entrega no se puede revisar ni desplegar desde main.
- **Cómo cerrarlo (M):** Fusionar hu-15-dev en dev y dev en main (con revision), decidir que pasa con las ramas hu-03, hu-08, hu-10, hu-11, hu-13 que tienen commits que hu-15-dev no contiene, y borrar las ramas muertas. Definir que repositorio es la fuente de verdad: si son los tres separados, incorporar alli el firmware; si es PT_HS, dejarlo al dia.

### [Alto] H-04 · Historial reiniciado y reconstruido: BK_HS y FT_HS empiezan con 'reset repository for HU delivery' y sus commits estan fechados y firmados en bloque
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `BK_HS:962a858 (15-oct 08:16); FT_HS:9d87caa (15-oct 08:17); BD_HS: 4 commits 'feat(db): add homes RBAC and RLS security' (a80553c, 1782d55, 0dc6441, 08bba3d) el 8-oct 10:14`
- **Por qué importa:** La historia real (desde el 3-sep, en PT_HS) no coincide con la que muestran los repos entregables, y las ramas hu-NN-dev/qa/staging/main duplican hasta cuatro veces cada commit (228 crudos frente a 181 unicos). No se puede saber quien escribio que, ni auditar el avance por semanas; las metricas por cuenta de los repositorios separados no son confiables. Atribucion: 24 commits de BD_HS llevan el nombre Integrante 3 con el correo de Integrante (se unen a el por la regla del correo; sin confirmar).
- **Cómo cerrarlo (M):** Mantener una sola historia: no reiniciar repositorios; promover entre ambientes con merge o cherry-pick sin duplicar commits, o con una sola rama de trabajo y etiquetas por entorno. Cada integrante debe configurar su user.name y user.email propios. Documentar en el README de PT_HS de donde proviene cada repositorio separado.

### [Alto] H-05 · La web no permite crear reglas ni umbrales de alerta: el flujo de alertas no puede arrancar
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A06 · **Verificación independiente:** confirmado
- **Evidencia:** `src/shared/http/apiClient.ts:841`
- **Por qué importa:** El README del conjunto declara las alertas como implementadas, pero todo evento de alerta se genera a partir de alert_rule o threshold_configuration y ninguna pantalla, semilla ni funcion SQL crea esas filas. AlertsPage (src/features/alerts/pages/AlertsPage.tsx:30) muestra siempre el guion de umbral vacio y una lista vacia, de modo que una de las funciones centrales del sistema es inalcanzable para el usuario.
- **Cómo cerrarlo (M):** Agregar a AlertsPage un formulario que llame alertsApi.saveThresholds y alertsApi.createRule (ya existen en el cliente y en alert.routes.js:37 y :43), y crear al registrar el hogar un umbral por defecto en fn_create_home_with_billing_profile. Criterio: un usuario nuevo configura un umbral diario, inserta una lectura y ve la alerta en la pantalla.

### [Alto] H-06 · El repo de conjunto evaluado es una copia congelada y hay tres fuentes de verdad divergentes
- **Repositorio:** `propietario/PT_HS`
- **Lente SDLC OS:** A06 · **Verificación independiente:** confirmado; también reportado como H-36
- **Evidencia:** `README.md:7`
- **Por qué importa:** La rama dev de PT_HS (el conjunto que el equipo declara) tiene 6 commits y contiene copias del 2026-09-09: 17 migraciones de 04_alter frente a 29 en BD_HS, 67 rutas frente a 108 y 34 archivos de prueba frente a 62. El trabajo integrado esta en la rama hu-15-dev (16 commits adelante, del 2026-10-21: CI en .github/workflows, carpeta firmware, docs/ del sistema, correos transaccionales) y ni dev ni main lo tienen. Quien clone el conjunto obtiene un sistema distinto del que entregan los tres repos sueltos, y el firmware del ESP32, primer eslabon del flujo de telemetria, solo existe en esa rama.
- **Cómo cerrarlo (M):** Elegir una fuente de verdad: o PT_HS integra BD, BK y FT como submodulos fijados a los SHA entregados, o se declara que el conjunto es solo un indice. Fusionar hu-15-dev (firmware, docs, CI) a dev y a main y actualizar el README con la fecha real. Criterio: dev y main de PT_HS contienen firmware, docs/ y CI, y apuntan a los SHA de los repos sueltos.

### [Alto] H-07 · Componentes de interfaz y cliente HTTP monoliticos: pantallas de mas de 1000 lineas y un unico apiClient de 963 lineas
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/features/devices/pages/DevicesPage.tsx:99`
- **Por qué importa:** DeviceManagement ocupa ~1100 lineas con 31 useState; AccountSettings (SettingsPage.tsx:166) ~1030 con 22 useState; apiClient.ts 963 lineas concentra todos los recursos; HomesPage 747, AppLayout 612, LoginPage 602. El criterio del rol de desarrollo frontend pone el limite en 300 lineas y un archivo por responsabilidad. Hace cambiar cualquier pantalla costosa y propensa a regresiones, y no se pueden probar por partes.
- **Cómo cerrarlo (L):** Dividir por flujo (listado, formulario, aprovisionamiento BLE, actuadores) en componentes y hooks de mas o menos 200 lineas; separar apiClient en cliente base y modulos por recurso (ya hay *.api.ts por modulo); usar react-query, ya instalado, para el estado de servidor.

### [Alto] H-08 · Version atrasada de la autenticacion: sin revocacion de sesion y con tokens en sessionStorage
- **Repositorio:** `propietario/PT_HS`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `BK_HS/src/api/middleware/auth.js:9; FT_HS/Web/src/shared/http/apiClient.ts:43`
- **Por qué importa:** El auth.js de dev solo valida la firma del JWT: cerrar sesion o revocarla no corta un token vivo, y el frontend guarda access y refresh en sessionStorage (alcanzable por cualquier XSS). Los repositorios independientes BK_HS y FT_HS ya lo resolvieron con sesiones verificadas en base y cookies httpOnly con CSRF, pero el conjunto declarado no lo refleja.
- **Cómo cerrarlo (M):** Sincronizar PT_HS con BK_HS/FT_HS actuales o declarar que el entregable son los repositorios separados; eliminar el almacenamiento de tokens en el navegador.

### [Alto] H-09 · Broker MQTT anonimo publicado en todas las interfaces mientras comanda actuadores
- **Repositorio:** `propietario/BK_HS`
- **Lente SDLC OS:** A04 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker/mosquitto/mosquitto.conf:3; docker-compose.yml:6; src/api/actuator.routes.js:32`
- **Por qué importa:** El compose publica el puerto 1883 sin TLS y con allow_anonymous true; cualquiera en la red puede publicar telemetria falsa u ordenes de actuador (electrovalvula). El codigo exige TLS y credenciales en produccion (src/config/mqtt.js:52), pero el broker de produccion no existe (docs/mqtt-production.md:17), asi que el sistema no tiene aun un camino seguro de despliegue. Ademas, con los valores por defecto del compose (NODE_ENV production y broker mqtt://) el backend caeria al arrancar (server.js:58) salvo que un archivo de entorno lo sobreescriba; el ejemplo de entorno fija development.
- **Cómo cerrarlo (M):** Definir el broker de produccion con TLS, archivo de claves y ACL por dispositivo; en el compose local enlazar 1883 a 127.0.0.1 y no usar NODE_ENV production con el broker local.

### [Alto] H-10 · Frontend sin ninguna prueba automatizada; npm test pasa en verde sin ejecutar nada
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/08_pruebas-frontend.md:5; package.json:10`
- **Por qué importa:** El script node --test no descubre archivos, asi que cualquier verificacion del frontend (validaciones, refresh de sesion, CSRF, permisos por rol) no existe; el documento lo admite. Las tres pruebas existentes estan solo en hu-15-dev de PT_HS.
- **Cómo cerrarlo (M):** Llevar las pruebas de apiClient, deviceProvisioning y reglas de formulario a FT_HS, anadir pruebas de login, refresh y 403, y hacer que el script falle si descubre cero pruebas.

### [Alto] H-11 · La rama evaluada (dev) no contiene la CI, el firmware ni las pruebas del frontend: todo vive en hu-15-dev
- **Repositorio:** `propietario/PT_HS`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `BK_HS/package.json:12; gh api actions/runs: 0 ejecuciones sobre dev; hu-15-dev tiene +16 commits con el workflow validate.yml, el directorio firmware y las pruebas de FT_HS/frontend`
- **Por qué importa:** El conjunto declarado como entregable (PT_HS) esta atrasado respecto de sus propias ramas: la CI paso a verde solo en hu-15-dev (2 verdes tras 6 rojas, 2026-10-19 y 2026-10-21; 21 ejecuciones en total, 17 rojas), no hay ejecuciones en dev ni main y el trabajo que prueba el sistema no esta integrado. Quien clone la rama por defecto no obtiene CI ni firmware.
- **Cómo cerrarlo (M):** Fusionar hu-15-dev en dev y llevar dev a main mediante PR con la CI en verde; proteger main exigiendo el workflow de validacion. Antes de fusionar hay que purgar el commit aebaf48 (git filter-repo o rebase de hu-15-dev sin ese commit), porque el historial de hu-15-dev lo contiene y llevaria los archivos de entorno con credenciales a dev y main.

### [Alto] H-12 · Los tres repositorios de componente no tienen CI, pese a tener 62 archivos de prueba en el backend
- **Repositorio:** `propietario/BK_HS`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `package.json:15; gh api actions/runs: total 0 en BK_HS, FT_HS y BD_HS`
- **Por qué importa:** Las pruebas del backend (unas 472 afirmaciones) y la validacion de migraciones nunca se ejecutan automaticamente en el repositorio donde se integra el codigo; la unica CI esta en PT_HS (ramas hu-*), con 17 de 21 ejecuciones rojas. No hay compuerta de calidad antes de main.
- **Cómo cerrarlo (S):** Copiar el workflow de validacion a BK_HS, FT_HS y BD_HS (lint, test, liquibase validate, build) y exigirlo en PR a main.

### [Alto] H-13 · El contrato OpenAPI no esta en main: vive en una rama sin integrar y solo lista rutas
- **Repositorio:** `propietario/BK_HS`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/api.md:1`
- **Por qué importa:** docs/api.md de main dice expresamente que evita duplicar contratos y solo lista 17 prefijos. El catalogo de 108 operaciones esta en la rama hu-11-dev (docs/openapi.yaml, 1 commit adelante y 77 atras, nunca fusionada) y FT_HS lo enlaza alli por el nombre antiguo del repo (docs/README.md:14 de FT_HS). Ese archivo coincide 108 de 108 con las rutas de main, pero no tiene ningun requestBody ni esquema de respuesta, de modo que no sirve para verificar contratos entre capas.
- **Cómo cerrarlo (M):** Fusionar docs/openapi.yaml a main y completar requestBody, parametros y esquemas de respuesta de al menos los flujos de registro, hogares, dispositivos y consumo; servirlo desde la API o validarlo en una prueba que compare rutas y esquemas. Criterio: main contiene el OpenAPI y una prueba falla si se agrega una ruta sin documentar.

### [Medio] H-14 · Pantallas que cargan datos sin estados de carga ni de error, y textos fijos fuera de i18n
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/features/alerts/pages/AlertsPage.tsx:40`
- **Por qué importa:** AlertsPage.tsx:40-47 y GoalsPage.tsx:55-72 (y Vacation, Audit, Technician) cargan en un useEffect y ante fallo solo muestran un toast; no hay indicador de carga ni estado de error con reintento, de modo que una peticion fallida se ve como 'sin datos'. AlertsPage.tsx:41 y DevicesPage.tsx:424 traen cadenas fijas en espanol, mientras el resto de la app usa i18n. Incumple los cuatro estados de pantalla del principio de frontend.
- **Cómo cerrarlo (M):** Unificar un patron de carga (hook o react-query) que entregue estado de carga, error con reintento y vacio disenado, y mover los textos a los archivos de idioma.

### [Medio] H-15 · La URL de la API cae a localhost sin avisar si falta la variable de entorno
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/shared/config/env.ts:14`
- **Por qué importa:** Un build sin VITE_API_URL queda apuntando a http://localhost:3000/api/v1: en produccion o en el telefono llamaria al propio dispositivo del usuario (la propia documentacion movil lo advierte) y fallaria sin explicacion.
- **Cómo cerrarlo (S):** Quitar el respaldo en builds de produccion y fallar en el arranque con un mensaje claro si la variable falta.

### [Medio] H-16 · El aprovisionamiento del dispositivo exige Web Bluetooth (Chrome/Edge) o un build nativo; sin ruta alterna se corta el flujo principal
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/shared/iot/bleProvisioning.ts:114`
- **Por qué importa:** El paso que vincula el sensor al hogar usa BLE: en navegadores sin Web Bluetooth el codigo lanza un error y la documentacion movil indica que Expo Go no permite probar BLE. Un usuario con otro navegador o telefono queda sin forma de completar el flujo (registrar, vincular, ver consumo). Se verifica el mensaje de error y la ausencia de alternativa en el codigo; el alcance real depende del dispositivo.
- **Cómo cerrarlo (L):** Documentar navegadores y telefonos compatibles en la pantalla, y ofrecer una alternativa (aprovisionamiento por punto de acceso Wi-Fi o ingreso manual) o una guia clara de que hacer.

### [Medio] H-17 · Firmware del ESP32 solo en ramas sin integrar, sin TLS al broker y con claves Wi-Fi en texto claro en NVS
- **Repositorio:** `propietario/PT_HS`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker-compose.yml:57; en hu-15-dev: firmware/src/main.cpp:60, :212 y :526, firmware/provisioning/config.example.h:4, firmware/README.md:50`
- **Por qué importa:** El firmware (reconexion Wi-Fi y MQTT, GPIO 27, YF-S201 documentado) esta en hu-15-dev y no en dev: usa PubSubClient sobre WiFiClient en el puerto 1883 sin TLS (el README admite que es solo desarrollo) y guarda las redes Wi-Fi con su clave serializadas en NVS sin cifrar. Lo positivo: config.h esta ignorado, nunca se comiteo y las plantillas llevan marcadores.
- **Cómo cerrarlo (M):** Integrar el firmware a dev, pasar a WiFiClientSecure con verificacion de certificado y usuario y clave por placa, y habilitar cifrado de NVS o flash encryption.

### [Medio] H-18 · Contrato OpenAPI, guia de operacion local y script de arranque de BD fuera de main; los enlaces de FT_HS apuntan a una rama
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `BK_HS: docs/openapi.yaml existe en origin/hu-11-dev (318 lineas, commit e45021c); docs/operacion-local.md en origin/hu-12-dev (e514a74)`
- **Por qué importa:** La documentacion de la API que el frontend cita no esta en la rama principal, y el README de BK_HS enlaza a un documento inexistente. Un revisor o un nuevo integrante no puede consultar el contrato ni arrancar el stack siguiendo main.
- **Cómo cerrarlo (S):** Integrar hu-11-dev, hu-12-dev y hu-21-* en main, y apuntar los enlaces de FT_HS al repositorio BK_HS y a main en lugar de a la rama hu-11-dev del nombre antiguo.

### [Medio] H-19 · La documentacion describe despliegues distintos segun el repositorio
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `BK_HS: docs/mqtt-production.md:11 (Supabase); PT_HS rama hu-15-dev: docs/pendientes-documentacion.md (Cloudflare Pages, Render, Neon, Brevo); FT_HS y BD_HS con pagina principal en Vercel`
- **Por qué importa:** No queda claro donde esta desplegado el sistema ni con que servicios; los documentos se contradicen y los commits muestran cambios de proveedor (Resend, Brevo, Supabase). Un operador no sabe que documento seguir.
- **Cómo cerrarlo (M):** Elegir la arquitectura de despliegue vigente, documentarla una sola vez en docs/despliegue.md (con diagrama) y retirar o marcar como historicos los demas textos.

### [Medio] H-20 · Los PR no tienen revision: 40 PR, 0 reviews, cada uno fusionado por quien lo abre
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/FT_HS/pulls (18 PR, 0 reviews)`
- **Por qué importa:** Los PR de promocion develop->qa->staging->main de BD_HS, BK_HS y FT_HS los abre y los fusiona Integrante 1 en minutos; no hay revision por pares ni comentarios de revision, por lo que los ambientes qa y staging no validan nada. En PT_HS cuatro PR llevan semanas abiertos.
- **Cómo cerrarlo (S):** Activar proteccion de rama en main/qa/staging (al menos 1 aprobacion de otro integrante) y rotar al revisor.

### [Medio] H-21 · Sin issues ni tablero: el seguimiento de HU no existe fuera de los nombres de rama
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/BK_HS/issues?state=all (0)`
- **Por qué importa:** Cero issues en los cuatro repos y sin proyecto visible. Nadie puede ver que HU estan pendientes, en curso o terminadas; el estado real solo se infiere de los commits.
- **Cómo cerrarlo (S):** Abrir un issue por HU con criterios de aceptacion y vincularlo a la rama y al PR; usar un tablero con las columnas por estado.

### [Medio] H-22 · Los tres repositorios entregables y el conjunto estan en cuentas personales distintas, y BD_HS es un fork de un repositorio de otro integrante
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `gh api repos/propietario/BD_HS (fork de propietario/BD_HS)`
- **Por qué importa:** PT_HS depende de Integrante 3, BD_HS/BK_HS/FT_HS de Integrante 1 y BD_HS nace como fork de propietario/BD_HS. Si una cuenta desaparece o cambia de permisos, se pierde parte del sistema; los colaboradores no son visibles (HTTP 403).
- **Cómo cerrarlo (S):** Mover los cuatro repositorios a una organizacion del equipo y dar permisos de escritura a los tres integrantes.

### [Medio] H-23 · Backend y base tienen funciones de privacidad, roles de hogar y dispositivos que ninguna pantalla puede usar
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/shared/http/apiClient.ts:941`
- **Por qué importa:** 34 de 108 metodos del cliente no se usan. Los que importan: privacyApi.manageRequests y updateRequest (un administrador no puede atender las solicitudes ARCO que los usuarios si pueden crear, y la Ley 1581 impone plazos de respuesta), homesApi.changeMemberRole y removeMember, devicesApi.deactivate y delete, y los tres metodos de recomendaciones. El costo de mantener rutas, funciones SQL y pruebas sin uso es real y el usuario cree que la funcion existe.
- **Cómo cerrarlo (M):** Para cada metodo sin pantalla decidir: construir la pantalla (ARCO de administracion y miembros, prioridad alta) o retirar ruta, funcion SQL y metodo. Criterio: cada ruta de backend tiene al menos una pantalla o un consumidor documentado.

### [Medio] H-24 · La proteccion CSRF depende de leer una cookie desde JavaScript, lo que solo funciona con mismo origen o dominio compartido
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `src/shared/http/apiClient.ts:63`
- **Por qué importa:** El cliente lee la cookie CSRF con document.cookie y la devuelve en la cabecera X-CSRF-Token. Con el proxy nginx (nginx.conf:7) el origen es uno solo y funciona. Si la web y la API se despliegan en sitios distintos (la rama hu-15-dev del conjunto menciona Cloudflare Pages y Render), la cookie pertenece al dominio de la API y el JavaScript de la web no la ve: todas las peticiones de escritura fallarian a menos que se configure AUTH_COOKIE_DOMAIN con un dominio padre comun. Inferido, no se ejercito contra un despliegue.
- **Cómo cerrarlo (S):** Documentar en .env.example y README el requisito de dominio compartido o de proxy mismo origen, y agregar una prueba de despliegue que haga login y una escritura. Criterio: el flujo de crear hogar funciona en el despliegue publico.

### [Medio] H-25 · El .env.example de PT_HS omite variables que el compose exige y el inicio rapido falla al copiarlo
- **Repositorio:** `propietario/PT_HS`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docker-compose.yml:103`
- **Por qué importa:** El README manda copiar .env.example, pero docker-compose.yml:102-103 exige DB_INGEST_USER y DB_INGEST_PASSWORD (con valor obligatorio) y .env.example no las define (solo aparecen en el bloque de ejemplo del README, lineas 58-60); lo mismo ocurre con DB_INGEST_POOL_MAX.
- **Cómo cerrarlo (S):** Agregar al .env.example todas las variables del compose y revisar con 'docker compose config' sobre un clon limpio.

### [Medio] H-26 · README y documentos de BK_HS enlazan a rutas del monolito que no existen al separar el repositorio
- **Repositorio:** `propietario/BK_HS`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada; también reportado como H-28
- **Evidencia:** `README.md:9`
- **Por qué importa:** README.md:9, :39 y :40 apuntan a ../docs/*.md (fuera del repo), docs/README.md:64 a ../../docs/pruebas.md y README.md:15 manda a Set-Location BK_HS; el mismo problema esta en BD_HS (docs/README.md:43). El arranque recomendado del backend no se puede seguir desde su propio repositorio.
- **Cómo cerrarlo (S):** Reescribir los enlaces y comandos para que funcionen desde la raiz de cada repositorio y agregar una seccion 'Como levantar todo junto' con el orden BD_HS, BK_HS y FT_HS.

### [Medio] H-27 · Los scripts y la documentacion del frontend asumen la estructura del monolito (FT_HS/frontend) y fallan en el repositorio FT_HS
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `scripts/prepare-mobile-bundle.mjs:8`
- **Por qué importa:** prepare-mobile-bundle.mjs:8 y run-android.mjs:9 calculan la raiz del repositorio subiendo dos niveles (fuera del repo) para leer el .env, y docs/08_pruebas-frontend.md:15 y docs/04_mobile.md:44 usan npm --prefix FT_HS/frontend. Los comandos moviles y de prueba documentados no se pueden ejecutar tal cual.
- **Cómo cerrarlo (S):** Ajustar repositoryRoot al directorio del proyecto, corregir las rutas de la documentacion y probar el procedimiento Android desde un clon limpio de FT_HS.

### [Medio] H-29 · Repositorio de dispositivos de 770 lineas y orquestacion MQTT dentro del controlador
- **Repositorio:** `propietario/BK_HS`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/core/infrastructure/repositories/postgres/PostgresDeviceRepository.js:8`
- **Por qué importa:** PostgresDeviceRepository.js mezcla ingesta MQTT, vinculacion, telemetria, configuracion y aprovisionamiento en 16 metodos, con el mapeo 'null o Number' repetido unas 20 veces; DeviceController.js:87 y :241 publican comandos MQTT y deciden que hacer si fallan, logica que debe estar en un caso de uso. El resto del backend esta bien separado, por lo que este es el punto de mayor deuda.
- **Cómo cerrarlo (M):** Extraer un mapper de filas a entidad, partir el repositorio en telemetria, aprovisionamiento y ciclo de vida, y mover la confirmacion/reactivacion MQTT a casos de uso (LinkDevice, UnlinkDevice).

### [Medio] H-30 · La base de datos no tiene pruebas ni verificacion automatica de migraciones
- **Repositorio:** `propietario/BD_HS`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:22; scripts/rollback-by-id.ps1:1`
- **Por qué importa:** Con mas de 200 changesets, RLS y 190 politicas no hay pruebas (pgTAP o scripts de humo) ni CI que ejecute liquibase validate; un cambio de politica podria abrir datos de otros usuarios sin que nada falle.
- **Cómo cerrarlo (M):** Anadir pruebas de politicas RLS por rol y ejecutar validate y update sobre un Postgres efimero en CI.

### [Medio] H-31 · Sin despliegue real ni plan de rollback del backend y del broker
- **Repositorio:** `propietario/BK_HS`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/mqtt-production.md:17; docs/mqtt-production.md:150`
- **Por qué importa:** Solo el frontend esta publicado (Vercel, respuesta 200). El backend en Render y el broker figuran como pendientes en la propia guia; no hay URL del API en ningun repositorio ni procedimiento de rollback de la aplicacion (solo scripts manuales de rollback de base de datos en propietario/BD_HS:scripts/01_rollback_by_id.ps1). El flujo de extremo a extremo en linea no es comprobable.
- **Cómo cerrarlo (L):** Desplegar API y broker, registrar las URL en el README y documentar un release repetible con rollback (imagen anterior y rollback de Liquibase).

### [Medio] H-32 · No hay documento de modelo de datos ni diagrama, y el existente omite un esquema
- **Repositorio:** `propietario/BD_HS`
- **Lente SDLC OS:** A10 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/README.md:5`
- **Por qué importa:** La base tiene 54 tablas base en 9 esquemas pero la unica descripcion es una tabla de 8 esquemas que no incluye preference. No hay entidades, relaciones, claves ni diagrama, de modo que el modelo implementado no se puede contrastar con un modelo logico y cualquier cambio exige leer 29 migraciones de alter y 94 funciones.
- **Cómo cerrarlo (M):** Generar un diagrama entidad-relacion desde el esquema real (por ejemplo con el catalogo de PostgreSQL) y un docs/modelo.md con entidades, claves y reglas por esquema, incluyendo preference y actuadores. Criterio: cada tabla de 01_ddl/03_tables aparece en el documento.

### [Medio] H-33 · Las funciones SQL se redefinen una y otra vez y se reparten entre 04_alter y 06_functions
- **Repositorio:** `propietario/BD_HS`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/04_alter/029_device_provisioning.sql:249`
- **Por qué importa:** De 94 funciones, 21 se redefinen con CREATE OR REPLACE en varios archivos; fn_ingest_sensor_reading tiene 5 definiciones y 3 sobrecargas encadenadas (4, 13 y 14 argumentos) repartidas entre 04_alter y 06_functions, fn_register_user tiene 4 definiciones y fn_create_home_with_billing_profile conserva su sobrecarga antigua de 7 argumentos. La version vigente solo se descubre leyendo el orden del changelog, los grants van por firma.
- **Cómo cerrarlo (M):** Dejar una definicion vigente por funcion en 06_functions (usando un changeset con runOnChange), eliminar las sobrecargas sin uso con DROP FUNCTION en una migracion nueva y documentar cual es la firma publica. Criterio: cada nombre de funcion tiene una sola firma salvo justificacion escrita.

### [Medio] H-34 · Los codigos de dispositivos preasignados son publicos y el vinculo por codigo no exige prueba de posesion
- **Repositorio:** `propietario/BD_HS`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia (inferida):** `02_dml/03_upserts/001_preassigned_esp32_device_codes.sql:10`
- **Por qué importa:** El repositorio publico trae tres codigos reclamables y fn_link_device_to_home (01_ddl/06_functions/053_fn_device_registration_and_linking.sql:82) vincula el dispositivo a cualquier hogar de un Owner que conozca el codigo, sin comprobar posesion fisica. El indice unico uq_home_device_one_active_device impide dos hogares activos, asi que quien llegue primero bloquea al dueno real (inferido por lectura, no ejercitado).
- **Cómo cerrarlo (M):** No sembrar codigos reales en el repositorio: generarlos al fabricar cada placa con un secreto de un solo uso, o exigir el hardwareId confirmado por BLE antes de aceptar el vinculo. Criterio: conocer el codigo publicado no basta para vincular el dispositivo.

### [Medio] H-35 · Seis listados paginan en memoria despues de traer todas las filas
- **Repositorio:** `propietario/BK_HS`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/shared/http.js:65`
- **Por qué importa:** paginate() recibe el arreglo completo y lo recorta: la usan HomeController (hogares, miembros y solicitudes), DeviceController.js:109, TicketController.js:6 (todos los tickets del sistema para un gestor), RecommendationController y ActuatorController. Con pocos datos funciona; con miles de tickets o lecturas el costo de red y memoria crece con la tabla. Telemetria, auditoria, privacidad y reportes si usan LIMIT y OFFSET en SQL (PostgresDeviceRepository.js:403).
- **Cómo cerrarlo (M):** Pasar page y pageSize al repositorio y paginar con LIMIT y OFFSET (o cursor) en la consulta, devolviendo el total con un conteo. Criterio: ninguna consulta de listado sin LIMIT.

### [Bajo] H-37 · Archivos locales y de generacion versionados en FT_HS
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `ATTRIBUTIONS.md:1; .claude/settings.json`
- **Por qué importa:** Se versionan .claude/settings.json (listado en el .gitignore) y un ATTRIBUTIONS.md duplicado; en PT_HS ademas hay dos gestores de paquetes (pnpm y npm). El .env.example de FT_HS empieza con BOM (no se afirma como lo trata cada herramienta).
- **Cómo cerrarlo (S):** Quitar .claude/settings.json del indice, conservar una sola atribucion y un solo gestor de paquetes.

### [Bajo] H-38 · El documento HTML declara lang en ingles con la interfaz en espanol
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A03 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `index.html:2`
- **Por qué importa:** Los lectores de pantalla pronunciaran el contenido con la voz equivocada; afecta la accesibilidad basica.
- **Cómo cerrarlo (S):** Poner el atributo lang al idioma activo del usuario (es por defecto) al cambiar el idioma en i18n.

### [Bajo] H-39 · Cuenta externa al equipo con commits de gran tamano en PT_HS (Integrante 4), sin confirmar relacion
- **Repositorio:** `EQUIPO`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `PT_HS:a613c82 (497 archivos, 16-sep, 'correcciones de la HU-07'); PT_HS:31e4ea9 (157 archivos, 4-sep)`
- **Por qué importa:** Dos commits de una cuenta que no figura entre los tres integrantes, incluyendo el renombre masivo de FT_HS/Web a frontend. Puede ser un exintegrante; no se sabe quien trabajo realmente esas partes ni si hay una segunda cuenta de alguno de los tres (sin confirmar, no cambia ningun porcentaje).
- **Cómo cerrarlo (S):** Aclarar la relacion en el README del repositorio (autoria y creditos) o rehacer la autoria con co-authored-by.

### [Bajo] H-40 · El cliente tipa casi todas las respuestas como unknown, sin contrato compartido con el backend
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A09 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/shared/http/apiClient.ts:433`
- **Por qué importa:** homesApi, devicesApi, alertsApi y otros devuelven data: unknown, de modo que un cambio de campo en el backend no rompe la compilacion de la web. Hoy no hay desajuste (se verifico), pero nada lo detectaria mañana, y no existe OpenAPI en main para generar tipos.
- **Cómo cerrarlo (M):** Generar los tipos del cliente desde el OpenAPI completo (H-A03) y compilar en CI. Criterio: cambiar un campo del backend rompe el build de la web.

### [Bajo] H-41 · Cambios de despliegue quedaron en ramas adelantadas sin fusionar a main
- **Repositorio:** `propietario/BK_HS`
- **Lente SDLC OS:** A00 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `README.md:9`
- **Por qué importa:** BK_HS hu-12-dev (+4 commits): docs/operacion-local.md, start-local.ps1 y simplificacion de src/infrastructure/db.js. BD_HS hu-21-main (+1): scripts/start-local.ps1 y 10 lineas de README para preparar la base local. FT_HS hu-13-dev (+27 commits): Vercel Analytics, instrucciones de despliegue y package-lock; difiere de main solo en 8 archivos, el resto es historial reescrito. Ninguna agrega funcionalidad, pero la guia de operacion local que enlaza el README de BK_HS solo esta en esas ramas.
- **Cómo cerrarlo (S):** Fusionar a main las ramas hu-12-dev y hu-21-main de BK_HS y BD_HS y cerrar las ramas duplicadas de FT_HS. Criterio: main contiene docs/operacion-local.md.

### [Bajo] H-42 · Comentarios con codificacion rota
- **Repositorio:** `propietario/BK_HS`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/api/controllers/DeviceController.js:247`
- **Por qué importa:** Comentarios como 'desvinculaciÃ³n' indican que el archivo se guardo con una codificacion distinta de UTF-8; dificulta la lectura y puede propagarse a otros archivos.
- **Cómo cerrarlo (S):** Guardar los archivos en UTF-8 y corregir los comentarios.

### [Bajo] H-43 · Codigo de sesion heredado y enganoso en el cliente HTTP
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A07A08 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/shared/http/apiClient.ts:44`
- **Por qué importa:** El objeto de sesion expone accessToken y refreshToken que devuelven el valor de la cookie CSRF, y sessionStorage.ts mantiene almacenes vacios: confunde a quien lea el codigo y sugiere que hay tokens accesibles desde JavaScript, cuando ya viven en cookies HttpOnly.
- **Cómo cerrarlo (S):** Eliminar los getters y el adaptador heredados una vez que ningun componente los use.

### [Bajo] H-44 · Brechas menores: GET /health publica datos internos y PATCH de recomendaciones solo exige permiso de lectura
- **Repositorio:** `propietario/BK_HS`
- **Lente SDLC OS:** A12 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/api/health.routes.js:25; src/api/recommendation.routes.js:27`
- **Por qué importa:** /health devuelve el nombre de la base y la hora del servidor sin autenticar; el PATCH de recomendaciones se protege con reports.read, un permiso de lectura, aunque modifica estado.
- **Cómo cerrarlo (S):** Dejar /health solo con estado ok y exigir un permiso de escritura en el PATCH.

### [Bajo] H-45 · Contenedor del frontend sin usuario no root, sin healthcheck y sin cabeceras de seguridad
- **Repositorio:** `propietario/FT_HS`
- **Lente SDLC OS:** A11 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `Dockerfile:16; nginx.conf:8`
- **Por qué importa:** La imagen final de nginx corre como root, no define HEALTHCHECK y nginx.conf no agrega CSP, X-Frame-Options ni X-Content-Type-Options.
- **Cómo cerrarlo (S):** Usar nginxinc/nginx-unprivileged, anadir HEALTHCHECK y cabeceras de seguridad.

### [Bajo] H-46 · Nombres de tablas y columnas mezclan espanol y plural con el resto del esquema
- **Repositorio:** `propietario/BD_HS`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/03_tables/006_Alerts_control.sql:94`
- **Por qué importa:** La tabla alert_rate.estratos (plural, y sus columnas numero_estrato, descripcion, valor_base_m3, subsidio_porcentaje, fecha_actualizacion, estado) y device.umbral_alerta (01_ddl/03_tables/004_Iot_devices.sql:16) rompen la convencion en ingles y singular que sigue el resto de las 54 tablas; ademas los archivos usan nombres como 005_Consuption_monitoring.sql.
- **Cómo cerrarlo (S):** Renombrar con una migracion expand-then-contract (columna nueva, el backend escribe en ambas, luego se retira la vieja) a stratum y threshold_alert, y corregir los nombres de archivo en el siguiente changeset. Criterio: ningun identificador fisico en espanol ni en plural.

### [Bajo] H-47 · 33 de 105 claves foraneas no declaran la politica ON DELETE
- **Repositorio:** `propietario/BD_HS`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `01_ddl/04_alter/001_fk_user_account.sql:1`
- **Por qué importa:** Por ejemplo las claves hacia user_account en 01_ddl/04_alter/001_fk_user_account.sql y los catalogos de preferencias usan el comportamiento por defecto del motor. Es probable que sea intencional para conservar historial, pero no esta escrito y cambia segun el motor.
- **Cómo cerrarlo (S):** Declarar ON DELETE RESTRICT o SET NULL de forma explicita en cada una y anotar la razon en un comentario. Criterio: ninguna clave foranea sin politica.

### [Bajo] H-48 · Dos archivos de trigger documentados como activos no se aplican
- **Repositorio:** `propietario/BD_HS`
- **Lente SDLC OS:** A13 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `docs/01_ddl.md:202`
- **Por qué importa:** docs/01_ddl.md:202 y :203 describen 004_trg_after_alert_insert.sql (todo el CREATE TRIGGER esta comentado, 01_ddl/08_triggers/004_trg_after_alert_insert.sql:31) y 005_trg_after_reading_update_mv.sql (tiene CREATE TRIGGER pero no aparece en 01_ddl/08_triggers/0000changelog.yaml). La documentacion promete un comportamiento que la base no tiene.
- **Cómo cerrarlo (S):** Eliminar los dos archivos o registrarlos en el changelog con su rollback, y corregir docs/01_ddl.md. Criterio: todo SQL de 08_triggers esta en el changelog o no existe.

### [Bajo] H-49 · Convenciones REST irregulares en nombres y verbos
- **Repositorio:** `propietario/BK_HS`
- **Lente SDLC OS:** A06 · **Verificación independiente:** no estuvo en la muestra verificada
- **Evidencia:** `src/api/device.routes.js:65`
- **Por qué importa:** Acciones como verbo en la ruta (/devices/:deviceId/claim-hardware, /deactivate), recursos en singular (/vacation, /privacy, /audit) junto a plurales, PUT y PATCH mezclados, /reports/consumption.pdf con extension y DELETE /devices/:deviceId/home/:homeId. Funciona, pero cada cliente nuevo tiene que adivinar la convencion.
- **Cómo cerrarlo (S):** Documentar la convencion en el OpenAPI y, en una version /api/v2 o al agregar rutas nuevas, usar sustantivos plurales y sub recursos (POST /devices/{id}/claims). Criterio: una guia de estilo de dos paginas y rutas nuevas que la cumplan.

## Puntaje por dimensión

| Dim. | Nombre | Puntaje |
|---|---|---|
| D1 | Entrega y estructura | 90.6 |
| D2 | Reproducibilidad | 71.2 |
| D3 | Arquitectura y congruencia | 75.0 |
| D4 | Calidad de código | 70.5 |
| D5 | Seguridad | 78.5 |
| D6 | Pruebas | 60.0 |
| D7 | DevOps y despliegue | 43.2 |
| D8 | Datos | 75.0 |
| D9 | API y contratos | 50.0 |
| D10 | Frontend y móvil | 58.3 |
| D11 | IoT y firmware | — |
| D12 | Documentación y trazabilidad | 25.0 |
| D13 | Proceso y colaboración | 50.0 |
| D14 | Extremo a extremo | 65.0 |

## Lo que está bien

- Migraciones de base de datos versionadas, con rollback y sin referencias rotas (`propietario/BD_HS:changelog-master.yaml y 01_ddl/04_alter/0000changelog.yaml: 26 changelogs, 454 referencias a archivos y ninguna inexistente; 194 scripts de rollback en 05_rollbacks`)
- Seguridad de datos en la base: roles de minimo privilegio, RLS y funciones SECURITY DEFINER (`propietario/BD_HS:03_dcl/00_roles/002_create_ingest_role.sql:3 (rol de ingesta con INSERT limitado) y 03_dcl/01_grants/047_device_provisioning.sql:11`)
- Tipos y restricciones cuidados: cero float o timestamp sin zona, EXCLUDE para tarifas, unas 130 sentencias CREATE INDEX (`propietario/BD_HS:01_ddl/03_tables/006_Alerts_control.sql:25 y 01_ddl/09_indexes/001_idx_user_account.sql:1; busqueda de float y timestamp sin zona en 03_tables y 04_alter sin resultados`)
- Arquitectura hexagonal real en el backend: dominio sin dependencias, casos de uso con puertos y repositorios PostgreSQL (`propietario/BK_HS:src/core/application/ports/repositories/AuthRepository.js y src/core/infrastructure/repositories/postgres/PostgresAuthRepository.js:5; git grep de require en src/core/domain sin resultados`)
- Contrato de error uniforme con identificador de correlacion y mapeo de errores de PostgreSQL a codigos HTTP (`propietario/BK_HS:src/shared/http.js:34`)
- Ingesta MQTT idempotente: mqttMessageId obligatorio, deduplicacion en la funcion SQL y ruta de compatibilidad para firmware anterior (`propietario/BK_HS:src/mqtt/handlers/reading.handler.js:11 y src/core/application/use-cases/telemetry/IngestReading.js:8`)
- Coherencia total de rutas entre cliente y backend: las 108 rutas coinciden con el catalogo OpenAPI de hu-11-dev y todas las llamadas del cliente tienen contraparte (`propietario/FT_HS:src/shared/http/apiClient.ts:178 y propietario/BK_HS:src/app.js:48 (comparacion automatica de 108 rutas contra 107 llamadas)`)
- Honestidad en la interfaz: la pantalla de recomendaciones declara que son consejos visuales y no datos generados (`propietario/FT_HS:src/features/recommendations/pages/RecommendationsPage.tsx:5`)
- Pruebas unitarias y de integracion del backend contra PostgreSQL y MQTT (`propietario/BK_HS:tests/integration/mqtt-postgres.test.js y tests/unit/ingest-reading.test.js (62 archivos de prueba)`)
- Autenticacion de servidor robusta en BK_HS (`propietario/BK_HS: src/api/middleware/auth.js:20; src/api/security/authCookies.js:61; src/api/middleware/authRateLimit.js:5`)
- Defensa en profundidad con RLS y RBAC en la base (`propietario/BD_HS: 02_dml/00_inserts/010_rbac_permissions.sql:15; propietario/BK_HS: src/infrastructure/db.js:41`)
- Configuracion que falla de forma cerrada en produccion (TLS y credenciales MQTT obligatorios, cookies seguras) (`propietario/BK_HS: src/config/mqtt.js:52`)
- Suite de pruebas del backend amplia y con integracion real contra Postgres y MQTT (`propietario/BK_HS: tests/integration/backend-postgres.test.js:1`)
- Honestidad documental: la guia de pruebas del frontend y la de produccion MQTT admiten sus limites (`propietario/FT_HS: docs/08_pruebas-frontend.md:5`)
- Plantillas de firmware sin credenciales y config.h ignorado y nunca comiteado (firmware en hu-15-dev de PT_HS) (`propietario/PT_HS: docker-compose.yml:57 (firmware solo en hu-15-dev)`)
- Backend con arquitectura por capas real y consistente (`BK_HS: src/core/application/use-cases/device/ListUserDevices.js; src/core/domain/entities/Device.js; src/api/controllers/DeviceController.js:1`)
- Manejo de errores centralizado con identificador de peticion y codigos uniformes (`BK_HS: src/shared/http.js:34`)
- Base de datos versionada con Liquibase, rollbacks por cambio, imagen y driver fijados (`BD_HS: changelog-master.yaml; docker/liquibase/Dockerfile:1`)
- Autenticacion web completa: cookies HttpOnly, CSRF, renovacion de sesion, rutas protegidas, recuperacion y verificacion de correo (`FT_HS: src/shared/http/apiClient.ts:101; src/app/App.tsx:54`)
- Interfaz responsive con navegacion inferior en movil, i18n es/en, permisos por rol y documentacion por capas (`FT_HS: docs/07_componentes-y-responsive.md; src/shared/i18n/config.js:40`)
- Docker bien armado en los tres repositorios separados (multi-etapa en el frontend, healthcheck en el backend) (`FT_HS: Dockerfile:1; BK_HS: docker-compose.yml:70`)
- Documentacion honesta sobre limites y pendientes (en la rama hu-15-dev) y plantillas .env.example sin secretos (`BD_HS: .env.example:1; BK_HS: .env.example:1; FT_HS: .env.example:1`)
- Mensajes de commit con Conventional Commits en los repositorios separados (88 % de los commits unicos) (`git log (BD_HS 79 de 80, BK_HS 38 de 40, FT_HS 30 de 33)`)

## Lo que no se pudo verificar

- Que la cadena de Liquibase levante una base vacia sin errores (R-8.5) — Exigiria ejecutar docker y Liquibase, prohibido por el briefing; solo se comprobo estaticamente que los changelogs referencian archivos existentes y el orden de capas.
- Cuerpo y comportamiento de las funciones PL/pgSQL, politicas RLS y grants por firma — Solo se leyeron firmas y grants; no se ejecuto ninguna consulta contra PostgreSQL.
- Firmware del ESP32 y aprovisionamiento por BLE (primer eslabon del flujo de telemetria) — No esta en ningun repo a los SHA evaluados; existe solo en la rama hu-15-dev de propietario/PT_HS (carpeta firmware), fuera de la evidencia aceptada.
- Despliegue en linea y cookies entre dominios (T-14.3) — El equipo no declara URL; pt-hs.pages.dev y pt-hs.onrender.com aparecen solo en hu-15-dev y no se hizo ninguna peticion de red.
- Documentacion en Google Drive — PROYECTOS-FICHA solo lista los 4 repositorios, sin carpeta de Drive; T-3.6 se evaluo solo contra lo que hay en los repos.
- Contenido de las ramas adelantadas hu-12-dev, hu-21-main, hu-13-dev y hu-15-dev — Solo se revisaron mensajes de commit y diff por archivo para decir que contienen; no se evaluo su codigo.
- La cuenta Integrante 4 reintrodujo los archivos de entorno en a613c82 (rama hu-08-dev de PT_HS) y no figura entre los integrantes declarados — Corresponde a D13 (especialista C); aqui solo importa porque determina quien tiene acceso de escritura a un repositorio con credenciales expuestas.
- URL del backend desplegado (Render) y estado real del flujo en linea — Ningun repositorio publica la URL; solo se permitio un GET a la URL declarada del frontend (200).
- Vulnerabilidades de dependencias (npm audit) — Exigiria instalar o consultar un servicio fuera de lo permitido.
- Si los valores de los archivos de entorno publicados siguen vigentes — Probarlos exigiria usarlos contra la base o el correo, fuera de la lectura permitida.
- Ejecucion de las pruebas y del compose — Prohibido ejecutar el codigo de los aprendices.
- Titular de la cuenta SMTP del archivo de entorno publicado y si es personal — No se contrasto con ninguna fuente.
- Ramas adelantadas de PT_HS, BK_HS y FT_HS: solo se leyeron CI, firmware y diferencias de contenido, no todo su codigo — Presupuesto de lectura; FT_HS hu-13-dev cambia 8 archivos frente a main (docs, Vercel Analytics) pese a +27 commits.
- Compilacion, typecheck, pruebas y arranque de Docker de los cuatro repositorios — El briefing prohibe ejecutar el codigo de los aprendices (npm, docker, mvn); R-10.1 se evaluo por configuracion y resolucion estatica de imports.
- Muestreo de D4: se leyeron en profundidad los dos componentes mas grandes del equipo por lineas de codigo (FT_HS, ~16 500 lineas en src, y BK_HS, ~10 000 lineas) — En FT_HS se leyeron la estructura y los indicadores (tamano, useState, estados) de DevicesPage.tsx, SettingsPage.tsx y apiClient.ts, no sus 1200/1193/963 lineas enteras, y se revisaron AlertsPage, GoalsPage, App.tsx y AuthProvider; en BK_HS PostgresDeviceRepository.js, DeviceController.js y http.js. El SQL de BD_HS (D8) es de otro especialista y el codigo de PT_HS dev es una copia anterior, no muestreado.
- Que las cookies HttpOnly y CSRF funcionen entre el frontend desplegado (Vercel) y la API — Exige ejecutar el sistema desplegado; el propio equipo lo lista como pendiente en la rama hu-15-dev.
- Colaboradores y permisos de los repositorios (T-13.6) — gh api repos/.../collaborators responde 403: se requiere acceso de escritura.
- Documentacion de Drive o tablero externo — El campo 'Link de evidencias' del equipo solo declara los cuatro repositorios; no se declaro Drive, por lo que la regla de Drive no se aplica.
- Contenido de ramas hu-NN-dev de PT_HS que no estan en hu-15-dev (hu-03, hu-08, hu-10, hu-11, hu-13) — Se identificaron por conteo de commits (1 a 6 por rama) y por mensaje, no se reviso su codigo.
- Repositorio propietario/BD_HS (padre del fork BD_HS) — No fue declarado por el equipo; no se evalua ni se construyen hallazgos sobre el.
- Quien escribio realmente los 24 commits de BD_HS con nombre Integrante 3 y correo de Integrante — Se unen a Integrante por la regla del correo; puede ser un git config compartido. No cambia ningun porcentaje.
- Pruebas del frontend (npm test ejecuta node --test sin ninguna prueba segun docs/08_pruebas-frontend.md) y CI inexistente en FT_HS — Corresponden a D6/D7 del especialista B; se pasan a el.
- Trato del BOM al inicio de FT_HS/.env.example por Vite/dotenv — Riesgo inferido, no probado.
