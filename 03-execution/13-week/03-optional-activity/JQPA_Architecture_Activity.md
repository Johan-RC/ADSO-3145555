# Arquitectura adaptada al proyecto JQPA

## 1) C4 - Nivel 1: Diagrama de contexto

### Objetivo
Yo lo uso para mostrar a JQPA como una caja negra y ubicar los actores externos y servicios de apoyo que interactúan con él.

### PlantUML adaptado
```plantuml
@startuml C4_Contexto_JQPA
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

LAYOUT_WITH_LEGEND()

title Diagrama de Contexto (Nivel 1) - JQPA\nJurídicos Quimbaya y Polania Asociados

Person(visitante, "Visitante", "Consulta información pública, servicios y contenido autorizado")
Person(abogado, "Abogado", "Gestiona clientes, casos, documentos, audiencias, actividades y cálculos")
Person(admin, "Administrador", "Administra usuarios, permisos, parámetros y supervisa el sistema")
Person(cliente, "Cliente", "Recibe la gestión jurídica y entrega información al equipo")

System(jqpa, "JQPA", "Plataforma jurídica web y móvil para gestionar operaciones internas del bufete, automatizar cálculos legales y centralizar la información del negocio")

System_Ext(email_service, "Servicio de correo", "Envía confirmaciones, notificaciones y recuperación de acceso")
System_Ext(official_sources, "Fuentes oficiales", "MinTrabajo, DANE, DIAN, Banco de la República, SuperFinanciera y otras fuentes normativas/económicas")

Rel(visitante, jqpa, "Consulta contenido público", "HTTPS")
Rel(abogado, jqpa, "Gestiona la operación jurídica", "HTTPS")
Rel(admin, jqpa, "Administra y supervisa", "HTTPS")
Rel(cliente, abogado, "Solicita servicios y entrega soporte documental", "Canal humano")

Rel(jqpa, email_service, "Envía correos transaccionales", "SMTP/API")
Rel(jqpa, official_sources, "Consulta índices, tasas y normatividad", "HTTPS/API")

SHOW_LEGEND()
@enduml
```

### Explicación
En JQPA, el sistema centraliza la operación jurídica del bufete. Yo identifiqué al abogado y al administrador como los actores principales. El cliente no siempre interactúa directo con la plataforma, pero sí hace parte del flujo del negocio. También dejé el consumo de correo y fuentes oficiales porque las calculadoras y las notificaciones dependen de datos externos.

---

## 2) C4 - Nivel 2: Diagrama de contenedores

### Objetivo
Aquí muestro los contenedores principales de la solución y cómo se comunican entre sí.

### PlantUML adaptado
```plantuml
@startuml C4_Contenedores_JQPA
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

LAYOUT_WITH_LEGEND()

title Diagrama de Contenedores (Nivel 2) - JQPA\nArquitectura propuesta por dominios

Person(abogado, "Abogado", "Profesional del derecho")
Person(admin, "Administrador", "Administrador del sistema")

System_Ext(email_service, "Servicio de correo", "SMTP / API")
System_Ext(official_sources, "Fuentes oficiales", "APIs y portales normativos")

System_Boundary(jqpa_system, "JQPA") {
    Container(web_app, "Aplicación Web", "React", "Portal público y panel interno para gestión jurídica")
    Container(mobile_app, "Aplicación Móvil", "React Native", "Consulta y operación básica para abogados")
    Container(api_gateway, "API Gateway / BFF", "Laravel + PHP", "Punto de entrada, autenticación, validación, orquestación y exposición de endpoints")

    Container(identity_service, "Servicio de Identidad", "Laravel / PHP", "Registro, autenticación, JWT, roles, permisos y recuperación de acceso")
    Container(client_service, "Servicio de Clientes", "Laravel / PHP", "Gestión de clientes, tipos, estados y documentación del cliente")
    Container(case_service, "Servicio de Casos", "Laravel / PHP", "Gestión de casos, áreas del derecho, prioridades, estados y asignaciones")
    Container(document_service, "Servicio de Documentos", "Laravel / PHP", "Carga, descarga, versionado y custodia de documentos")
    Container(hearing_service, "Servicio de Audiencias", "Laravel / PHP", "Agenda, tipos de audiencia, estados y participantes")
    Container(activity_service, "Servicio de Actividades", "Laravel / PHP", "Registro de tiempos, actividades facturables y trazabilidad")
    Container(calculation_service, "Servicio de Cálculos", "Laravel / PHP", "Cálculos laborales, civiles, comerciales, tributarios y administrativos")
    Container(normativity_service, "Servicio de Normatividad", "Laravel / PHP", "Referencias normativas, constantes legales, IPC, UVT y tasas")
    Container(report_service, "Servicio de Reportes", "Laravel / PHP", "Generación de PDF, Excel y reportes operativos")
    Container(notification_service, "Servicio de Notificaciones", "Laravel / PHP", "Correos y avisos del sistema")
    Container(content_service, "Servicio de Contenido", "Laravel / PHP", "Artículos, noticias y contenido público del portal")

    ContainerDb(main_db, "MySQL", "MySQL 8", "Persistencia de datos por esquemas o bases separadas por servicio")
    Container(file_storage, "Almacenamiento de archivos", "Filesystem / Object Storage", "Archivos, evidencias, plantillas y adjuntos")
}

Rel(abogado, web_app, "Usa", "HTTPS")
Rel(admin, web_app, "Usa", "HTTPS")
Rel(abogado, mobile_app, "Usa", "HTTPS")

Rel(web_app, api_gateway, "Consume la API", "JSON/HTTPS")
Rel(mobile_app, api_gateway, "Consume la API", "JSON/HTTPS")

Rel(api_gateway, identity_service, "Autenticación y permisos", "REST")
Rel(api_gateway, client_service, "Gestión de clientes", "REST")
Rel(api_gateway, case_service, "Gestión de casos", "REST")
Rel(api_gateway, document_service, "Gestión documental", "REST")
Rel(api_gateway, hearing_service, "Agenda de audiencias", "REST")
Rel(api_gateway, activity_service, "Registro de actividades", "REST")
Rel(api_gateway, calculation_service, "Ejecuta cálculos", "REST")
Rel(api_gateway, normativity_service, "Consulta normativa", "REST")
Rel(api_gateway, report_service, "Genera reportes", "REST")
Rel(api_gateway, notification_service, "Notificaciones", "REST")
Rel(api_gateway, content_service, "Publicación de contenido", "REST")

Rel(identity_service, main_db, "Lee/escribe", "SQL")
Rel(client_service, main_db, "Lee/escribe", "SQL")
Rel(case_service, main_db, "Lee/escribe", "SQL")
Rel(document_service, main_db, "Lee/escribe", "SQL")
Rel(hearing_service, main_db, "Lee/escribe", "SQL")
Rel(activity_service, main_db, "Lee/escribe", "SQL")
Rel(calculation_service, main_db, "Lee/escribe", "SQL")
Rel(normativity_service, main_db, "Lee/escribe", "SQL")
Rel(report_service, main_db, "Lee/escribe", "SQL")
Rel(notification_service, main_db, "Lee/escribe", "SQL")
Rel(content_service, main_db, "Lee/escribe", "SQL")

Rel(document_service, file_storage, "Guarda y recupera archivos", "Filesystem")
Rel(report_service, file_storage, "Genera y guarda exportaciones", "Filesystem")
Rel(notification_service, email_service, "Envía correos", "SMTP/API")
Rel(normativity_service, official_sources, "Consulta datos oficiales", "HTTPS/API")
Rel(calculation_service, official_sources, "Consume constantes legales", "HTTPS/API")

SHOW_LEGEND()
@enduml
```

### Explicación
Con esta versión yo convierto la arquitectura de JQPA en una solución preparada para crecer por dominios. El **API Gateway / BFF** concentra el punto de entrada y los microservicios se separan por responsabilidad de negocio. Para una sola persona o para un proyecto pequeño, yo lo implementaría de forma progresiva: primero como monolito modular y después como microservicios reales si el alcance lo exige.

---

## 3) C4 - Nivel 3: Diagrama de componentes

### Objetivo
Aquí describo la estructura interna de un microservicio representativo. Elegí el **Servicio de Identidad y Seguridad** porque es la base del acceso al sistema.

### PlantUML adaptado
```plantuml
@startuml C4_Componentes_Identidad_JQPA
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Component.puml

LAYOUT_WITH_LEGEND()

title Diagrama de Componentes (Nivel 3) - Servicio de Identidad y Seguridad\nJQPA

Container(api_gateway, "API Gateway / BFF", "Laravel", "Entrada única de la plataforma")
ContainerDb(identity_db, "Base de datos de identidad", "MySQL", "Usuarios, roles, permisos y sesiones")
System_Ext(email_service, "Servicio de correo", "SMTP / API")

Container_Boundary(identity_service, "Servicio de Identidad y Seguridad") {
    Component(identity_controller, "IdentityController", "Laravel Controller", "Expone endpoints de registro, login, logout, recuperación y cambio de contraseña")
    Component(user_controller, "UserController", "Laravel Controller", "CRUD de usuarios, roles y especialidades")
    Component(auth_application_service, "AuthApplicationService", "Application Service", "Coordina el flujo de autenticación y autorización")
    Component(user_application_service, "UserApplicationService", "Application Service", "Coordina altas, ediciones y administración de usuarios")
    Component(validation_service, "ValidationService", "Domain/Application Service", "Valida datos de entrada y reglas de negocio")
    Component(jwt_service, "JwtService", "Infrastructure Service", "Genera y valida tokens JWT")
    Component(password_hasher, "PasswordHasher", "Infrastructure Service", "Hash y verificación de contraseñas")
    Component(user_repository, "UserRepository", "Repository", "Acceso a usuarios")
    Component(role_repository, "RoleRepository", "Repository", "Acceso a roles y permisos")
    Component(session_repository, "SessionRepository", "Repository", "Persistencia de sesiones y tokens")
    Component(email_adapter, "EmailAdapter", "Integration Adapter", "Envío de correos de confirmación y recuperación")
}

Rel(api_gateway, identity_controller, "Invoca endpoints", "REST/JSON")

Rel(identity_controller, auth_application_service, "Usa")
Rel(identity_controller, user_application_service, "Usa")
Rel(identity_controller, validation_service, "Usa")
Rel(user_controller, user_application_service, "Usa")
Rel(user_controller, validation_service, "Usa")

Rel(auth_application_service, jwt_service, "Genera/valida tokens")
Rel(auth_application_service, password_hasher, "Hashea contraseñas")
Rel(auth_application_service, user_repository, "Consulta usuarios")
Rel(auth_application_service, session_repository, "Registra sesiones")
Rel(auth_application_service, email_adapter, "Solicita envío de correo")

Rel(user_application_service, user_repository, "CRUD de usuarios")
Rel(user_application_service, role_repository, "CRUD de roles")
Rel(user_application_service, validation_service, "Valida reglas")

Rel(user_repository, identity_db, "Lee/escribe", "SQL")
Rel(role_repository, identity_db, "Lee/escribe", "SQL")
Rel(session_repository, identity_db, "Lee/escribe", "SQL")
Rel(email_adapter, email_service, "Envía correos", "SMTP/API")

SHOW_LEGEND()
@enduml
```

### Explicación
Con este componente yo muestro cómo se organiza internamente uno de los servicios más importantes. La misma lógica se puede repetir en los demás microservicios: controlador, capa de aplicación, validación, repositorio e integración externa. Así la solución mantiene coherencia y evita mezclar responsabilidades.

---

## 4) C3 - Mapeo estructural: enfoque AllProject

### Objetivo
Aquí organizo todo el backend por capas técnicas globales, sin separar demasiado por dominio.

### Estructura adaptada a JQPA
```text
JQPA-Backend/
├── Entity/
│   ├── Security/
│   ├── Users/
│   ├── Clients/
│   ├── Cases/
│   ├── Documents/
│   ├── Hearings/
│   ├── Activities/
│   ├── Calculations/
│   ├── Normativity/
│   └── Reports/
├── IRepository/
│   ├── Security/
│   ├── Users/
│   ├── Clients/
│   ├── Cases/
│   ├── Documents/
│   ├── Hearings/
│   ├── Activities/
│   ├── Calculations/
│   ├── Normativity/
│   └── Reports/
├── IServices/
│   ├── Security/
│   ├── Users/
│   ├── Clients/
│   ├── Cases/
│   ├── Documents/
│   ├── Hearings/
│   ├── Activities/
│   ├── Calculations/
│   ├── Normativity/
│   └── Reports/
├── Services/
│   ├── Security/
│   ├── Users/
│   ├── Clients/
│   ├── Cases/
│   ├── Documents/
│   ├── Hearings/
│   ├── Activities/
│   ├── Calculations/
│   ├── Normativity/
│   └── Reports/
├── Controller/
│   ├── Security/
│   ├── Users/
│   ├── Clients/
│   ├── Cases/
│   ├── Documents/
│   ├── Hearings/
│   ├── Activities/
│   ├── Calculations/
│   ├── Normativity/
│   └── Reports/
├── Dto/
│   ├── Security/
│   ├── Users/
│   ├── Clients/
│   ├── Cases/
│   ├── Documents/
│   ├── Hearings/
│   ├── Activities/
│   ├── Calculations/
│   ├── Normativity/
│   └── Reports/
├── IDto/
│   ├── Security/
│   ├── Users/
│   ├── Clients/
│   ├── Cases/
│   ├── Documents/
│   ├── Hearings/
│   ├── Activities/
│   ├── Calculations/
│   ├── Normativity/
│   └── Reports/
└── Utils/
    ├── JWT/
    ├── Files/
    ├── PdfExcel/
    └── Rules/
```

### Comentario
Yo veo este enfoque como una base fácil de entender al inicio, pero en JQPA puede crecer desordenado porque mezcla todos los dominios dentro de las mismas capas. Me sirve como base simple, aunque no sería mi opción principal si el objetivo real es microservicios.

---

## 5) C3 - Mapeo estructural: enfoque ByModel

### Objetivo
Aquí separo el sistema por módulos funcionales o dominios de negocio.

### Estructura adaptada a JQPA
```text
JQPA-Backend/
├── Identity/
│   ├── Controller/
│   ├── Dto/
│   ├── Entity/
│   ├── IDto/
│   ├── IRepository/
│   ├── IServices/
│   ├── Services/
│   └── Utils/
│       └── JWT/
├── Users/
│   ├── Controller/
│   ├── Dto/
│   ├── Entity/
│   ├── IDto/
│   ├── IRepository/
│   ├── IServices/
│   ├── Services/
│   └── Utils/
├── Clients/
│   ├── Controller/
│   ├── Dto/
│   ├── Entity/
│   ├── IDto/
│   ├── IRepository/
│   ├── IServices/
│   ├── Services/
│   └── Utils/
├── Cases/
│   ├── Controller/
│   ├── Dto/
│   ├── Entity/
│   ├── IDto/
│   ├── IRepository/
│   ├── IServices/
│   ├── Services/
│   └── Utils/
├── Documents/
│   ├── Controller/
│   ├── Dto/
│   ├── Entity/
│   ├── IDto/
│   ├── IRepository/
│   ├── IServices/
│   ├── Services/
│   └── Utils/
├── Hearings/
│   ├── Controller/
│   ├── Dto/
│   ├── Entity/
│   ├── IDto/
│   ├── IRepository/
│   ├── IServices/
│   ├── Services/
│   └── Utils/
├── Activities/
├── Calculations/
├── Normativity/
├── Reports/
├── Notifications/
└── Content/
```

### Comentario
Este es el enfoque que más me encaja con JQPA, porque cada módulo de negocio queda bien encapsulado. Si más adelante quiero extraer microservicios, la migración será más fácil porque los límites ya quedan claros. Para un equipo pequeño, o para mí trabajando solo, esta es la opción más sana.

---

## 6) C3 - Mapeo estructural: enfoque DDD

### Objetivo
Aquí organizo el backend por capas limpias: dominio, aplicación, infraestructura y API.

### Estructura adaptada a JQPA
```text
JQPA/
├── Domain/
│   ├── Entities/
│   │   ├── Security/
│   │   ├── Users/
│   │   ├── Clients/
│   │   ├── Cases/
│   │   ├── Documents/
│   │   ├── Hearings/
│   │   ├── Activities/
│   │   ├── Calculations/
│   │   ├── Normativity/
│   │   └── Reports/
│   ├── Repositories/
│   │   ├── ISecurityRepository/
│   │   ├── IClientRepository/
│   │   ├── ICaseRepository/
│   │   └── ...
│   └── Services/
│       ├── IAuthService/
│       ├── ICalculationService/
│       ├── INormativityService/
│       └── IReportService/
├── Application/
│   ├── DTOs/
│   │   ├── Security/
│   │   ├── Clients/
│   │   ├── Cases/
│   │   ├── Documents/
│   │   ├── Hearings/
│   │   ├── Activities/
│   │   ├── Calculations/
│   │   ├── Normativity/
│   │   └── Reports/
│   ├── IDTOs/
│   └── UseCases/
│       ├── Security/
│       ├── Clients/
│       ├── Cases/
│       ├── Documents/
│       ├── Hearings/
│       ├── Activities/
│       ├── Calculations/
│       ├── Normativity/
│       └── Reports/
├── Infrastructure/
│   ├── Repositories/
│   ├── Services/
│   ├── Integrations/
│   │   ├── Email/
│   │   └── OfficialSources/
│   └── Utils/
│       ├── JWT/
│       ├── PdfExcel/
│       └── Files/
└── API/
    ├── Controllers/
    │   ├── Security/
    │   ├── Clients/
    │   ├── Cases/
    │   ├── Documents/
    │   ├── Hearings/
    │   ├── Activities/
    │   ├── Calculations/
    │   ├── Normativity/
    │   └── Reports/
    └── Middlewares/
```

### Comentario
Yo veo DDD como una opción muy útil para JQPA porque el dominio jurídico tiene varias reglas de negocio y no conviene mezclar todo. Además, cada microservicio puede usar esta estructura por dentro, así que combina muy bien con una arquitectura distribuida.

---

## 7) C3 - Mapeo estructural: enfoque MVC

### Objetivo
Aquí uso la arquitectura clásica Modelo-Vista-Controlador.

### Estructura adaptada a JQPA
```text
JQPA/
├── Model/
│   ├── Security/
│   ├── Users/
│   ├── Clients/
│   ├── Cases/
│   ├── Documents/
│   ├── Hearings/
│   ├── Activities/
│   ├── Calculations/
│   ├── Normativity/
│   └── Reports/
├── View/
│   ├── JSON/
│   └── Templates/
└── Controller/
    ├── Security/
    ├── Users/
    ├── Clients/
    ├── Cases/
    ├── Documents/
    ├── Hearings/
    ├── Activities/
    ├── Calculations/
    ├── Normativity/
    └── Reports/
```

### Comentario
MVC me funciona bien para algo pequeño, pero para JQPA se queda corto si el sistema crece. Yo lo vería más como un punto de partida o como la estructura de un microservicio aislado, pero no como la mejor arquitectura para toda la solución.

---

## 8) Estructura recomendada final para JQPA

Si mi objetivo es mantener el proyecto ordenado y listo para crecer, yo elegiría esta estructura:

```text
JQPA/
├── api-gateway/
├── services/
│   ├── identity-service/
│   ├── users-service/
│   ├── clients-service/
│   ├── cases-service/
│   ├── documents-service/
│   ├── hearings-service/
│   ├── activities-service/
│   ├── calculations-service/
│   ├── normativity-service/
│   ├── reports-service/
│   ├── notifications-service/
│   └── content-service/
├── shared/
│   ├── contracts/
│   ├── dto/
│   ├── exceptions/
│   └── utils/
├── frontend/
│   ├── web/
│   └── mobile/
└── infrastructure/
    ├── docker/
    ├── scripts/
    └── observability/
```
## 9) Conclusión

En resumen, yo lo veo así:
- **AllProject** me sirve para arrancar rápido.
- **ByModel** es la mejor base práctica para JQPA.
- **DDD** es la opción más sólida si quiero orden y crecimiento.
- **MVC** solo me conviene para una versión pequeña o para un servicio aislado.
