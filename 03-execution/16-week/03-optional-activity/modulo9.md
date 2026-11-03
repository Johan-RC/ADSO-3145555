# MÓDULO 9 – SEGUIMIENTO INTEGRAL Y NOTIFICACIONES
## MODELO DE DATOS – VERSIÓN TÉCNICA COMPLETA (23 ENTIDADES)

---

# PARTE 1: ENTIDADES PROPIAS (12)

---

## 1. estado_kpi

**Relaciones:** M9 (propia)

| Atributo    | Tipo          | Descripción                    | Módulo Asociado | Justificación del Tipo |
| ----------- | ------------- | ------------------------------ | --------------- | ----------------------- |
| codigo      | PK (VARCHAR)  | Identificador único del estado | M9              | Se usa VARCHAR como PK porque los valores son códigos cortos y legibles (NO_INICIADO, APROBADO). No requiere secuencia numérica. |
| nombre      | VARCHAR(50)   | Nombre del estado              | M9              | Texto corto para mostrar en interfaces. El límite 50 es suficiente y mejora rendimiento de índices. |
| color       | VARCHAR(7)    | Color de visualización         | M9              | Almacena código hexadecimal (#RRGGBB) exactamente de 7 caracteres. |
| orden       | INTEGER       | Orden de presentación          | M9              | Número entero para ordenar listas en UI. Permite valores negativos si se necesita reordenar. |
| descripcion | TEXT          | Descripción del estado         | M9              | TEXT permite descripciones largas sin límite rígido, ideal para documentación. |

---

## 2. tipo_evidencia

**Relaciones:** M9 (propia) | M7 (usada por evidencias)

| Atributo    | Tipo          | Descripción                    | Módulo Asociado | Justificación del Tipo |
| ----------- | ------------- | ------------------------------ | --------------- | ----------------------- |
| id_tipo     | PK (SERIAL)   | Identificador único            | M9              | Se usa SERIAL porque no hay un código natural legible. Auto-incremento seguro para concurrencia. |
| nombre      | VARCHAR(50)   | Tipo de evidencia              | M9              | VARCHAR(50) – valores fijos: CONOCIMIENTO, DESEMPEÑO, PRODUCTO. Suficiente para dominio cerrado. |
| descripcion | TEXT          | Descripción del tipo           | M9              | TEXT para documentación extensa de cada tipo. |

---

## 3. tipo_alerta

**Relaciones:** M9 (propia) | M9 → alerta_generada

| Atributo       | Tipo          | Descripción                    | Módulo Asociado | Justificación del Tipo |
| -------------- | ------------- | ------------------------------ | --------------- | ----------------------- |
| id_tipo_alerta | PK (SERIAL)   | Identificador único            | M9              | SERIAL por ser tabla paramétrica. La clave numérica es más eficiente para FK. |
| nombre         | VARCHAR(50)   | Nombre del tipo                | M9              | VARCHAR(50) – valores: ACADEMICA, CUMPLIMIENTO, RIESGO_DESERCION, GERENCIAL. |
| descripcion    | TEXT          | Descripción                    | M9              | TEXT para incluir reglas de negocio asociadas a cada tipo. |
| prioridad_base | VARCHAR(20)   | Prioridad base                 | M9              | VARCHAR(20) – dominio: BAJA, MEDIA, ALTA, CRITICA. String legible y fácil de filtrar. |

---

## 4. nivel_riesgo

**Relaciones:** M9 (propia) | M9 → alerta_generada

| Atributo           | Tipo          | Descripción                    | Módulo Asociado | Justificación del Tipo |
| ------------------ | ------------- | ------------------------------ | --------------- | ----------------------- |
| id_nivel_riesgo    | PK (SERIAL)   | Identificador único            | M9              | SERIAL por ser tabla paramétrica. |
| nombre             | VARCHAR(20)   | Nivel de riesgo                | M9              | VARCHAR(20) – BAJO, MEDIO, ALTO, CRITICO. Dominio fijo y legible. |
| color              | VARCHAR(7)    | Color asociado                 | M9              | VARCHAR(7) para código hexadecimal (#RRGGBB). Permite visualización semafórica. |
| peso               | INTEGER       | Peso para cálculos             | M9              | INTEGER permite operaciones matemáticas como promedio ponderado. Valores típicos: 1,2,3,4. |
| dias_respuesta_max | INTEGER       | Tiempo máximo de respuesta     | M9              | INTEGER – días hábiles o calendario. Permite comparación directa con DATE差值. |

---

## 5. seguimiento_kpi

**Relaciones:** M5 (RAP) | M6 (Ficha, Proyecto) | M7 (Aprendiz, Instructor) | M9 (estado_kpi)

| Atributo           | Tipo             | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ------------------ | ---------------- | ------------------------------------ | --------------- | ----------------------- |
| id_seguimiento     | PK (SERIAL)      | Identificador único                  | M9              | SERIAL para alta concurrencia de registros (miles de seguimientos diarios). |
| id_aprendiz        | FK (INTEGER)     | Referencia al aprendiz               | M7              | INTEGER por ser FK a tabla de M7. El tipo debe coincidir con la PK de la tabla origen. |
| id_ficha           | FK (INTEGER)     | Referencia a la ficha                | M6              | INTEGER – FK a tabla de fichas. |
| id_rap             | FK (INTEGER)     | Referencia al RAP                    | M5              | INTEGER – FK a Resultados de Aprendizaje. |
| id_proyecto        | FK (INTEGER)     | Proyecto formativo                   | M6              | INTEGER – FK a proyectos. |
| id_instructor      | FK (INTEGER)     | Instructor responsable               | M7              | INTEGER – FK a instructores. |
| estado_kpi         | FK (VARCHAR)     | Estado actual del KPI                | M9              | VARCHAR – FK a estado_kpi.codigo. Se mantiene VARCHAR para coincidir con la PK de la tabla padre. |
| porcentaje_avance  | NUMERIC(5,2)     | Porcentaje de avance (0-100)         | M9              | NUMERIC con 2 decimales para precisión en informes. Permite valores como 75.50%. CHECK constraint asegura 0-100. |
| justificacion      | TEXT             | Razón del estado actual              | M9              | TEXT – campo abierto para instructores. Puede ser extenso. |
| fecha_actualizacion| TIMESTAMP        | Última modificación                  | M9              | TIMESTAMP incluye fecha y hora exacta para trazabilidad y orden de eventos. |
| fecha_registro     | TIMESTAMP        | Creación del registro                | M9              | TIMESTAMP – auditoría. Se establece automáticamente. |
| regional_id        | INTEGER          | Regional asociada                    | M9              | INTEGER – desnormalización para consultas rápidas por región sin JOIN. |
| centro_id          | INTEGER          | Centro de formación                  | M9              | INTEGER – desnormalización para filtros. |
| periodo            | VARCHAR(7)       | Periodo académico                    | M9              | VARCHAR(7) – formato AAAA-MM (2025-01). Fácil de indexar y filtrar. |

---

## 6. historial_estado_kpi

**Relaciones:** M9 (seguimiento_kpi) | M7 (id_instructor)

| Atributo       | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| -------------- | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_historial   | PK (SERIAL)   | Identificador único                  | M9              | SERIAL para auditoría de cambios (puede haber muchos por seguimiento). |
| id_seguimiento | FK (INTEGER)  | Seguimiento asociado                 | M9              | INTEGER – FK a seguimiento_kpi. Permite JOIN para reconstruir historia. |
| estado_anterior| VARCHAR(20)   | Estado previo                        | M9              | VARCHAR – copia del código. No es FK por razones históricas (el estado podría eliminarse o renombrarse). |
| estado_nuevo   | VARCHAR(20)   | Estado nuevo                         | M9              | VARCHAR – mismo criterio que estado_anterior. |
| justificacion  | TEXT          | Razón del cambio                     | M9              | TEXT – obligatorio por regla de negocio. Permite hasta 4KB. |
| id_instructor  | INTEGER       | Instructor que realizó el cambio     | M7              | INTEGER – auditoría. Permite rastrear quién hizo cada modificación. |
| fecha_cambio   | TIMESTAMP     | Momento del cambio                   | M9              | TIMESTAMP – para trazabilidad forense y orden cronológico exacto. |
| ip_origen      | INET          | Dirección IP desde donde se cambió   | M9              | INET – tipo específico de PostgreSQL para direcciones IPv4/IPv6. Valida formato automáticamente (seguridad). |

---

## 7. alerta_generada

**Relaciones:** M7 (Aprendiz) | M6 (Ficha, Proyecto) | M9 (tipo_alerta, nivel_riesgo)

| Atributo           | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ------------------ | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_alerta          | PK (SERIAL)   | Identificador único                  | M9              | SERIAL – alta frecuencia de generación (pueden ser cientos por día). |
| id_aprendiz        | FK (INTEGER)  | Aprendiz afectado                    | M7              | INTEGER – FK a M7. Permite filtrar alertas por aprendiz. |
| id_ficha           | FK (INTEGER)  | Ficha asociada                       | M6              | INTEGER – contexto para reportes agrupados. |
| id_proyecto        | FK (INTEGER)  | Proyecto asociado                    | M6              | INTEGER – contexto. |
| id_tipo_alerta     | FK (INTEGER)  | Tipo de alerta                       | M9              | INTEGER – FK a tipo_alerta. Numérico por eficiencia en JOIN. |
| id_nivel_riesgo    | FK (INTEGER)  | Nivel de riesgo                      | M9              | INTEGER – FK a nivel_riesgo. Permite ordenar por gravedad. |
| descripcion        | TEXT          | Detalle de la alerta                 | M9              | TEXT – puede incluir diagnóstico automático (ej. "3 inasistencias consecutivas"). |
| atendida           | BOOLEAN       | Indica si fue atendida               | M9              | BOOLEAN – eficiente para consultas de alertas activas (WHERE atendida = false). Índice parcial recomendado. |
| fecha_generacion   | TIMESTAMP     | Momento de generación                | M9              | TIMESTAMP – para calcular SLA (ej. alertas no atendidas en >48h). |
| fecha_atencion     | TIMESTAMP     | Momento de atención (NULL si no)     | M9              | TIMESTAMP – permite calcular tiempo de respuesta (fecha_atencion - fecha_generacion). NULL = no atendida. |
| id_usuario_atendio | INTEGER       | Usuario que atendió                  | M9              | INTEGER – FK a tabla de usuarios del sistema (coordinador, instructor). |
| regional_id        | INTEGER       | Regional                             | M9              | INTEGER – desnormalización para reportes sin JOIN. |
| centro_id          | INTEGER       | Centro                               | M9              | INTEGER – desnormalización. |

---

## 8. notificacion_enviada

**Relaciones:** M9 (alerta_generada)

| Atributo       | Tipo            | Descripción                          | Módulo Asociado | Justificación del Tipo |
| -------------- | --------------- | ------------------------------------ | --------------- | ----------------------- |
| id_notificacion| PK (SERIAL)     | Identificador único                  | M9              | SERIAL – alto volumen de registros (múltiples canales por alerta). |
| id_alerta      | FK (INTEGER)    | Alerta que originó la notificación   | M9              | INTEGER – FK a alerta_generada. Not null. Permite agrupar por alerta. |
| canal          | VARCHAR(20)     | Medio de envío                       | M9              | VARCHAR(20) – dominio fijo: CORREO, SMS, APP, DASHBOARD, WHATSAPP. CHECK constraint recomendado. |
| destinatario   | VARCHAR(255)    | Email o número de teléfono           | M9              | VARCHAR(255) – suficiente para email estándar (320 máximo teórico) o teléfono internacional. |
| asunto         | VARCHAR(255)    | Título de la notificación            | M9              | VARCHAR(255) – estándar en comunicaciones. Suficiente para líneas de asunto. |
| contenido      | TEXT            | Cuerpo del mensaje                   | M9              | TEXT – puede ser largo (ej. reporte detallado de alerta con múltiples causas). |
| fecha_envio    | TIMESTAMP       | Momento del envío                    | M9              | TIMESTAMP – para auditoría y cálculo de SLA de notificaciones. |
| exitosa        | BOOLEAN         | Indica si se envió correctamente     | M9              | BOOLEAN – permite reintentos automáticos si es false. |
| error_mensaje  | TEXT            | Causa del error (si exitosa=false)   | M9              | TEXT – diagnóstico para operadores. Ej: "SMTP timeout", "Número inválido". |
| regional_id    | INTEGER         | Regional                             | M9              | INTEGER – para segmentación de reportes por regional. |

---

## 9. seguimiento_ficha

**Relaciones:** M6 (Ficha) | M7 (Aprendices) | M9 (alertas)

| Atributo                 | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ------------------------ | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_seguimiento_ficha     | PK (SERIAL)   | Identificador único                  | M9              | SERIAL – para histórico de capturas (una ficha tiene múltiples seguimientos en el tiempo). |
| id_ficha                 | INTEGER       | Ficha asociada                       | M6              | INTEGER – FK a M6. Permite JOIN con la tabla de fichas. |
| porcentaje_avance_general| NUMERIC(5,2)  | Avance promedio de la ficha          | M9              | NUMERIC – cálculo agregado de seguimiento_kpi. Promedio de porcentaje_avance de todos los aprendices. |
| porcentaje_rap_cumplidos | NUMERIC(5,2)  | % de RAP aprobados                   | M9              | NUMERIC – indicador clave. Se calcula como (RAP_APROBADOS / TOTAL_RAP) * 100. |
| total_aprendices         | INTEGER       | Cantidad de aprendices asignados     | M9              | INTEGER – conteo desde M7. Entero sin decimales. |
| aprendices_activos       | INTEGER       | Aprendices en formación activa       | M9              | INTEGER – diferencia entre total_aprendices y aquellos con novedad de RETIRO/CANCELACION. |
| aprendices_en_riesgo     | INTEGER       | Aprendices con nivel ALTO o CRITICO  | M9              | INTEGER – sumatoria desde alertas activas con nivel_riesgo = ALTO o CRITICO. |
| total_alertas_activas    | INTEGER       | Alertas no atendidas                 | M9              | INTEGER – conteo WHERE atendida = false. Indicador de salud. |
| nivel_riesgo_general     | VARCHAR(20)   | Riesgo consolidado de la ficha       | M9              | VARCHAR – calculado por reglas de negocio (ej. si %riesgo > 30% → ALTO). |
| fecha_captura            | TIMESTAMP     | Momento del cálculo                  | M9              | TIMESTAMP – para tendencias históricas y gráficos evolutivos. |

---

## 10. seguimiento_proyecto

**Relaciones:** M6 (Proyecto) | M7 (Actividades) | M9 (Alertas)

| Atributo                 | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ------------------------ | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_seguimiento_proyecto  | PK (SERIAL)   | Identificador único                  | M9              | SERIAL – histórico de capturas. |
| id_proyecto              | INTEGER       | Proyecto asociado                    | M6              | INTEGER – FK a M6. |
| estado_proyecto          | VARCHAR(20)   | Estado actual                        | M9              | VARCHAR – dominio: PLANEACION, EJECUCION, EVALUACION, FINALIZADO. Legible y fácil de filtrar. |
| avance_general           | NUMERIC(5,2)  | Porcentaje de avance                 | M9              | NUMERIC – cálculo desde actividades completadas / total actividades. |
| total_actividades        | INTEGER       | Total de actividades planificadas    | M9              | INTEGER – conteo desde M7 o M6. Entero. |
| actividades_completadas  | INTEGER       | Actividades finalizadas              | M9              | INTEGER – permite calcular % restante sin decimales intermedios. |
| total_entregables        | INTEGER       | Total de productos esperados         | M9              | INTEGER – desde M6. |
| entregables_aprobados    | INTEGER       | Productos validados positivamente    | M9              | INTEGER – desde validacion_instructor con estado = APROBADA. |
| dias_retraso             | INTEGER       | Días de retraso (negativo si adelanto)| M9             | INTEGER – calculado vs cronograma base. Permite sumatorias y promedios. |
| total_alertas            | INTEGER       | Alertas asociadas al proyecto        | M9              | INTEGER – conteo desde alerta_generada con id_proyecto = actual. |
| fecha_captura            | TIMESTAMP     | Momento del cálculo                  | M9              | TIMESTAMP – para análisis de evolución. |

---

## 11. sesion_seguimiento

**Relaciones:** M7 (Instructor) | M6 (Ficha, Proyecto) | M8 (sesion_clase opcional)

| Atributo           | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ------------------ | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_sesion          | PK (SERIAL)   | Identificador único                  | M9              | SERIAL – registro de sesiones (pueden ser varias por día por instructor). |
| id_instructor      | INTEGER       | Instructor que lidera la sesión      | M7              | INTEGER – FK a M7. |
| id_ficha           | INTEGER       | Ficha convocada                      | M6              | INTEGER – FK a M6. |
| id_proyecto        | INTEGER       | Proyecto asociado                    | M6              | INTEGER – contexto. |
| id_sesion_clase    | INTEGER       | Referencia a M8 (horario de clase)   | M8              | INTEGER – opcional. Permite vincular seguimiento a sesión regular del horario. |
| fecha_inicio       | TIMESTAMP     | Inicio de la sesión                  | M9              | TIMESTAMP – para calcular duración. |
| fecha_fin          | TIMESTAMP     | Fin de la sesión                     | M9              | TIMESTAMP – permite calcular duración en minutos/horas. |
| tipo_seguimiento   | VARCHAR(20)   | Modalidad de seguimiento             | M9              | VARCHAR(20) – dominio: MASIVO (todo el grupo), INDIVIDUAL (uno a uno). |
| comentario_general | TEXT          | Observaciones de la sesión           | M9              | TEXT – puede incluir acuerdos grupales o temas transversales. |

---

## 12. detalle_sesion_seguimiento

**Relaciones:** M9 (sesion_seguimiento) | M7 (Aprendiz)

| Atributo               | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ---------------------- | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_detalle             | PK (SERIAL)   | Identificador único                  | M9              | SERIAL – alta granularidad (un registro por aprendiz por sesión). |
| id_sesion              | FK (INTEGER)  | Sesión padre                         | M9              | INTEGER – FK a sesion_seguimiento. ON DELETE CASCADE sugerido. |
| id_aprendiz            | INTEGER       | Aprendiz evaluado                    | M7              | INTEGER – FK a M7. |
| asistio                | BOOLEAN       | Si asistió a la sesión               | M9              | BOOLEAN – indicador binario. Índice útil para filtros de ausentes. |
| observacion_individual | TEXT          | Nota personalizada del instructor    | M9              | TEXT – campo abierto para seguimiento personalizado. |
| se_realizo_seguimiento | BOOLEAN       | Si se revisó su situación            | M9              | BOOLEAN – permite diferenciar ausentes sin seguimiento de ausentes con seguimiento pendiente. |

---

# PARTE 2: ENTIDADES DE INTEGRACIÓN (11)

*Nota: Para estas entidades, M9 NO es propietario. Solo las consume. Los tipos de datos se respetan según el módulo fuente.*

---

## 13. bitacora_aprendizaje

**Fuente:** Módulo 7 | **Relaciones en M9:** M7 (aprendiz, ficha, proyecto, rap) | M6 (actividad)

| Atributo               | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ---------------------- | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_bitacora            | PK (INTEGER)  | Identificador                        | M7 (Fuente)     | INTEGER – se respeta el tipo de M7. PK numérica eficiente. |
| id_aprendiz            | INTEGER       | Aprendiz                             | M7 (Fuente)     | INTEGER – FK. Tipo consistente con módulo fuente. |
| id_ficha               | INTEGER       | Ficha                                | M7 (Fuente)     | INTEGER. |
| id_proyecto            | INTEGER       | Proyecto                             | M7 (Fuente)     | INTEGER. |
| id_rap                 | INTEGER       | RAP trabajado                        | M7 (Fuente)     | INTEGER. |
| id_actividad           | INTEGER       | Actividad realizada                  | M7 (Fuente)     | INTEGER – desde M6. |
| fecha                  | DATE          | Fecha de la actividad                | M7 (Fuente)     | DATE – sin hora porque el registro es por día calendario. |
| horas_trabajadas       | NUMERIC(5,2)  | Horas dedicadas                      | M7 (Fuente)     | NUMERIC – permite medias horas (1.5) y cuartos (1.25). |
| descripcion_actividad  | TEXT          | Qué hizo el aprendiz                 | M7 (Fuente)     | TEXT – puede ser extenso. |
| estado_validacion      | VARCHAR(20)   | APROBADA/RECHAZADA/OBSERVADA         | M7 (Fuente)     | VARCHAR – dominio cerrado legible. |
| fecha_registro         | TIMESTAMP     | Momento del registro                 | M7 (Fuente)     | TIMESTAMP – auditoría del módulo fuente. |
| es_sincronizada_horario| BOOLEAN       | Si se creó desde M8                  | M7 (Fuente)     | BOOLEAN – trazabilidad de origen. |
| regional_id            | INTEGER       | Regional                             | M7 (Fuente)     | INTEGER – desnormalización. |
| centro_id              | INTEGER       | Centro                               | M7 (Fuente)     | INTEGER. |

---

## 14. evidencia_bitacora

**Fuente:** Módulo 7 | **Relaciones en M9:** M7 (bitacora, aprendiz) | M9 (tipo_evidencia)

| Atributo       | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| -------------- | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_evidencia   | PK (INTEGER)  | Identificador                        | M7 (Fuente)     | INTEGER. |
| id_bitacora    | INTEGER       | Bitácora asociada                    | M7 (Fuente)     | INTEGER – FK a bitacora_aprendizaje. |
| id_aprendiz    | INTEGER       | Aprendiz que subió                   | M7 (Fuente)     | INTEGER. |
| id_tipo_evidencia| INTEGER     | CONOCIMIENTO/DESEMPEÑO/PRODUCTO      | M9 (Consume)*   | INTEGER – FK a catálogo de M9 (tipo_evidencia). *M9 no la crea, pero la referencia. |
| nombre_archivo | VARCHAR(255)  | Nombre original                      | M7 (Fuente)     | VARCHAR(255) – suficiente para nombres de archivo con extensión. |
| url_documento  | VARCHAR(500)  | Ruta en almacenamiento               | M7 (Fuente)     | VARCHAR(500) – suficiente para rutas S3 o URLs firmadas. |
| descripcion    | TEXT          | Comentario sobre la evidencia        | M7 (Fuente)     | TEXT. |
| version        | INTEGER       | Número de versión                    | M7 (Fuente)     | INTEGER – control de cambios. Empieza en 1. |
| tamano_bytes   | BIGINT        | Tamaño del archivo                   | M7 (Fuente)     | BIGINT – permite archivos grandes (>2GB) sin desbordar INTEGER (2^31-1 ≈ 2GB). |
| fecha_subida   | TIMESTAMP     | Momento de carga                     | M7 (Fuente)     | TIMESTAMP – auditoría. |

---

## 15. validacion_instructor

**Fuente:** Módulo 7 | **Relaciones en M9:** M7 (bitacora, instructor)

| Atributo         | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ---------------- | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_validacion    | PK (INTEGER)  | Identificador                        | M7 (Fuente)     | INTEGER. |
| id_bitacora      | INTEGER       | Bitácora validada                    | M7 (Fuente)     | INTEGER – FK. |
| id_instructor    | INTEGER       | Instructor que valida                | M7 (Fuente)     | INTEGER – FK. |
| estado           | VARCHAR(20)   | APROBADA/RECHAZADA/OBSERVADA         | M7 (Fuente)     | VARCHAR(20) – dominio fijo legible. |
| comentario       | TEXT          | Retroalimentación                    | M7 (Fuente)     | TEXT – obligatorio por regla de negocio si estado = RECHAZADA. |
| fecha_validacion | TIMESTAMP     | Momento de la validación             | M7 (Fuente)     | TIMESTAMP. |
| es_ultima        | BOOLEAN       | Si es la validación vigente          | M7 (Fuente)     | BOOLEAN – permite consultas rápidas (evita buscar MAX(fecha_validacion)). |

---

## 16. seguimiento_etapa_productiva

**Fuente:** Módulo 7 | **Relaciones en M9:** M7 (aprendiz, empresa, proyecto, instructor_tutor)

| Atributo               | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ---------------------- | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_seguimiento_etapa   | PK (INTEGER)  | Identificador                        | M7 (Fuente)     | INTEGER. |
| id_aprendiz            | INTEGER       | Aprendiz en etapa productiva         | M7 (Fuente)     | INTEGER – FK. |
| id_empresa             | INTEGER       | Empresa donde realiza                | M7 (Fuente)     | INTEGER – FK a tabla de empresas. |
| id_proyecto            | INTEGER       | Proyecto asociado                    | M7 (Fuente)     | INTEGER – FK. |
| id_instructor_tutor    | INTEGER       | Instructor tutor                     | M7 (Fuente)     | INTEGER – FK. |
| fecha_seguimiento      | DATE          | Fecha del seguimiento                | M7 (Fuente)     | DATE – periodicidad mensual típica. |
| periodo                | VARCHAR(7)    | Periodo académico (AAAA-MM)          | M7 (Fuente)     | VARCHAR(7) – para reportes. |
| observaciones          | TEXT          | Notas del tutor                      | M7 (Fuente)     | TEXT. |
| estado                 | VARCHAR(20)   | ACTIVO/FINALIZADO/SUSPENDIDO         | M7 (Fuente)     | VARCHAR(20) – dominio cerrado. |

---

## 17. visita_empresa

**Fuente:** Módulo 7 | **Relaciones en M9:** M7 (seguimiento_etapa_productiva)

| Atributo         | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ---------------- | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_visita        | PK (INTEGER)  | Identificador                        | M7 (Fuente)     | INTEGER. |
| id_seguimiento_etapa | INTEGER   | Seguimiento asociado                 | M7 (Fuente)     | INTEGER – FK a seguimiento_etapa_productiva. |
| fecha_visita     | DATE          | Fecha de la visita                   | M7 (Fuente)     | DATE – suficiente, no requiere hora. |
| hallazgos        | TEXT          | Resultados de la visita              | M7 (Fuente)     | TEXT – puede ser extenso. |
| soporte_url      | VARCHAR(500)  | Link a acta o fotos                  | M7 (Fuente)     | VARCHAR(500) – para URLs de almacenamiento. |
| proxima_visita   | DATE          | Fecha sugerida para siguiente visita | M7 (Fuente)     | DATE – permite planificación. |

---

## 18. seguimiento_bienestar

**Fuente:** Módulo 10 | **Relaciones en M9:** M10 (aprendiz)

| Atributo                 | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ------------------------ | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_seguimiento_bienestar | PK (INTEGER)  | Identificador                        | M10 (Fuente)    | INTEGER – M10 es propietario. |
| id_aprendiz              | INTEGER       | Aprendiz atendido                    | M10 (Fuente)    | INTEGER. |
| id_seguimiento_origen    | INTEGER       | Identificador en M10                 | M10 (Fuente)    | INTEGER – para trazabilidad cruzada entre módulos. |
| nivel_riesgo             | VARCHAR(20)   | BAJO/MEDIO/ALTO/CRITICO              | M10 (Fuente)    | VARCHAR – dominio compatible con nivel_riesgo de M9. |
| estado_acompanamiento    | VARCHAR(20)   | ACTIVO/CERRADO/DERIVADO              | M10 (Fuente)    | VARCHAR(20). |
| fecha_ultima_atencion    | DATE          | Última intervención                  | M10 (Fuente)    | DATE. |
| requiere_seguimiento     | BOOLEAN       | Si necesita monitoreo adicional      | M10 (Fuente)    | BOOLEAN – usado por M9 para generar alertas automáticas. |
| fecha_sincronizacion     | TIMESTAMP     | Última actualización desde M10       | M9 (Consumo)    | TIMESTAMP – control de ETL y frescura de datos. |

---

## 19. novedad_academica

**Fuente:** Módulo 10 | **Relaciones en M9:** M10 (aprendiz, ficha, proyecto)

| Atributo         | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ---------------- | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_novedad       | PK (INTEGER)  | Identificador                        | M10 (Fuente)    | INTEGER. |
| id_aprendiz      | INTEGER       | Aprendiz afectado                    | M10 (Fuente)    | INTEGER – FK. |
| id_ficha         | INTEGER       | Ficha asociada                       | M10 (Fuente)    | INTEGER – FK. |
| id_proyecto      | INTEGER       | Proyecto asociado                    | M10 (Fuente)    | INTEGER – FK. |
| tipo_novedad     | VARCHAR(30)   | INASISTENCIA/APLAZAMIENTO/RETIRO etc | M10 (Fuente)    | VARCHAR(30) – dominio definido en M10. |
| descripcion      | TEXT          | Detalle de la novedad                | M10 (Fuente)    | TEXT. |
| estado           | VARCHAR(20)   | REGISTRADA/EN_PROCESO/RESUELTA       | M10 (Fuente)    | VARCHAR(20). |
| prioridad        | VARCHAR(20)   | BAJA/MEDIA/ALTA/CRITICA              | M10 (Fuente)    | VARCHAR – usado en combinación con nivel_riesgo. |
| fecha_registro   | TIMESTAMP     | Creación                             | M10 (Fuente)    | TIMESTAMP. |
| fecha_resolucion | TIMESTAMP     | Cierre (NULL si activa)              | M10 (Fuente)    | TIMESTAMP – NULL = novedad activa. |
| regional_id      | INTEGER       | Regional                             | M10 (Fuente)    | INTEGER. |

---

## 20. comite_seguimiento

**Fuente:** Módulo 10 | **Relaciones en M9:** M6 (centro_formacion)

| Atributo            | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ------------------- | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_comite           | PK (INTEGER)  | Identificador                        | M10 (Fuente)    | INTEGER. |
| id_centro_formacion | INTEGER       | Centro donde sesiona                 | M10 (Fuente)    | INTEGER – FK a M6. |
| numero_acta         | VARCHAR(50)   | Número de acta (formato institucional)| M10 (Fuente)   | VARCHAR(50) – puede incluir prefijo (ACTA-2025-001). |
| fecha_comite        | DATE          | Fecha de reunión                     | M10 (Fuente)    | DATE. |
| hora_inicio         | TIME          | Hora de inicio                       | M10 (Fuente)    | TIME – separado de fecha para reportes de duración. |
| hora_fin            | TIME          | Hora de finalización                 | M10 (Fuente)    | TIME. |
| decision_general    | TEXT          | Acuerdos principales                 | M10 (Fuente)    | TEXT. |
| acta_url            | VARCHAR(500)  | Documento escaneado                  | M10 (Fuente)    | VARCHAR(500) – URL de almacenamiento. |
| participantes       | JSONB         | Lista de asistentes (nombres, roles) | M10 (Fuente)    | JSONB – estructura flexible sin crear tabla adicional. Permite queries sobre el JSON. |

---

## 21. comite_novedad

**Fuente:** Módulo 10 | **Relaciones en M9:** M10 (comite_seguimiento, novedad_academica)

| Atributo            | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ------------------- | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_comite_novedad   | PK (INTEGER)  | Identificador                        | M10 (Fuente)    | INTEGER – tabla puente. |
| id_comite           | INTEGER       | Comité asociado                      | M10 (Fuente)    | INTEGER – FK a comite_seguimiento. |
| id_novedad          | INTEGER       | Novedad tratada                      | M10 (Fuente)    | INTEGER – FK a novedad_academica. |
| decision_especifica | TEXT          | Resolución sobre esa novedad         | M10 (Fuente)    | TEXT – puede incluir seguimiento asignado o fechas. |

---

## 22. plan_mejoramiento

**Fuente:** Módulo 5 / Módulo 7 | **Relaciones en M9:** M7 (aprendiz, instructor) | M6 (ficha, proyecto) | M5 (rap)

| Atributo         | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ---------------- | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_plan          | PK (INTEGER)  | Identificador                        | M5/M7 (Fuente)  | INTEGER. |
| id_aprendiz      | INTEGER       | Aprendiz responsable                 | M5/M7 (Fuente)  | INTEGER – FK. |
| id_ficha         | INTEGER       | Ficha                                | M5/M7 (Fuente)  | INTEGER – FK. |
| id_rap           | INTEGER       | RAP a reforzar                       | M5/M7 (Fuente)  | INTEGER – FK a M5. |
| id_proyecto      | INTEGER       | Proyecto asociado                    | M5/M7 (Fuente)  | INTEGER – FK. |
| id_instructor    | INTEGER       | Instructor que asigna                | M5/M7 (Fuente)  | INTEGER – FK. |
| fecha_inicio     | DATE          | Inicio del plan                      | M5/M7 (Fuente)  | DATE. |
| fecha_limite     | DATE          | Fecha máxima para cumplir            | M5/M7 (Fuente)  | DATE – crítico para alertas tempranas. |
| estado           | VARCHAR(20)   | ACTIVO/CUMPLIDO/VENCIDO/INCUMPLIDO   | M5/M7 (Fuente)  | VARCHAR(20) – dominio usado por M9 para alertas. |
| fecha_aprobacion | DATE          | Validación por coordinador           | M5/M7 (Fuente)  | DATE – NULL si no aprobado. |

---

## 23. actividad_plan_mejora

**Fuente:** Módulo 5 / Módulo 7 | **Relaciones en M9:** M5/M7 (plan_mejoramiento)

| Atributo           | Tipo          | Descripción                          | Módulo Asociado | Justificación del Tipo |
| ------------------ | ------------- | ------------------------------------ | --------------- | ----------------------- |
| id_actividad_plan  | PK (INTEGER)  | Identificador                        | M5/M7 (Fuente)  | INTEGER. |
| id_plan            | INTEGER       | Plan padre                           | M5/M7 (Fuente)  | INTEGER – FK a plan_mejoramiento. |
| descripcion        | TEXT          | Tarea específica                     | M5/M7 (Fuente)  | TEXT. |
| fecha_limite       | DATE          | Fecha para esta actividad            | M5/M7 (Fuente)  | DATE – puede ser anterior a fecha_limite del plan. |
| cumplida           | BOOLEAN       | Si se completó                       | M5/M7 (Fuente)  | BOOLEAN – permite cálculo de avance del plan. |
| fecha_cumplimiento | DATE          | Cuándo se cumplió (NULL si no)       | M5/M7 (Fuente)  | DATE – usado para detectar cumplimiento tardío vs fecha_limite. |

---

# PARTE 3: VERIFICACIÓN FINAL

| Tipo de Entidad | Cantidad | Estados |
|----------------|----------|---------|
| Entidades Propias | 12 | ✅ Completas |
| Entidades de Integración | 11 | ✅ Completas |
| **TOTAL** | **23** | **✅** |

---

# PARTE 4: NOTAS TÉCNICAS ADICIONALES

## Justificaciones recurrentes por tipo de dato

| Tipo de Dato | Cuándo se usa | Por qué |
|--------------|---------------|---------|
| **SERIAL** | PK de entidades propias con alta concurrencia | Auto-incremento atómico, sin riesgos de colisión |
| **INTEGER** | FK a otros módulos, conteos | Eficiente para JOINs y agregaciones |
| **BIGINT** | Tamaños de archivo (>2GB) | Evita desbordamiento de INTEGER |
| **VARCHAR(n)** | Dominios cortos y fijos (estados, tipos) | Legible, indexable, con CHECK constraint opcional |
| **TEXT** | Campos abiertos largos | Sin límite artificial, almacenamiento eficiente |
| **NUMERIC(5,2)** | Porcentajes y decimales exactos | Evita errores de redondeo de FLOAT |
| **TIMESTAMP** | Eventos con fecha y hora exacta | Orden temporal preciso, cálculo de intervalos |
| **DATE** | Solo fechas (sin hora) | Ahorra espacio, más rápido que TIMESTAMP |
| **TIME** | Horas independientes de fecha | Para duración de reuniones sin día específico |
| **BOOLEAN** | Indicadores binarios | Semántico, eficiente, índice parcial útil |
| **JSONB** | Datos semiestructurados variables | Flexibilidad sin esquema rígido, indexable |
| **INET** | Direcciones IP | Validación automática de formato (PostgreSQL) |

---

Este documento ahora cumple con el nivel profesional requerido para un proyecto ADSO o arquitectura de datos. Cada una de las 23 entidades incluye:

1. **Relaciones explícitas** con otros módulos
2. **Todos los atributos** con su tipo completo (PK/FK cuando aplica)
3. **Descripción funcional** de cada atributo
4. **Módulo asociado** (fuente de verdad del dato)
5. **Justificación técnica** de por qué se eligió ese tipo de datos