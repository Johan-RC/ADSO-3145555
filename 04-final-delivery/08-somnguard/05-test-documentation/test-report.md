# SomnGuard — Informe de pruebas

**Fecha de ejecución:** 5 de noviembre (casos manuales) y 6 de noviembre de 2026 (suite automatizada)
**Revisión evaluada:** rama `develop`, HEAD `0681d32`; árbol de trabajo local con cambios sin confirmar.
**Alcance:** registro de usuario, asignación del rol predeterminado `user` y suite automatizada del API.

## 1. Resumen ejecutivo

Los tres casos manuales de registro documentados pasaron: registro correcto (**201 Created**) con vínculo al rol activo `user`, rechazo de correo duplicado (**409 Conflict**) y validación de datos inválidos (**400 Bad Request**). La consulta a PostgreSQL local confirmó que la cuenta sintética quedó asociada al rol.

La suite automatizada del API se volvió a ejecutar el 6 de noviembre con acceso de Testcontainers a Docker Desktop. **Pasaron las 162 pruebas; hubo 0 fallos, 0 errores y 0 pruebas omitidas.** `AuthPostgresIntegrationTest` levantó PostgreSQL 16.15 como contenedor temporal y completó la integración. La ejecución previa del 5 de noviembre, que no tenía acceso al daemon Docker, quedó superada.

## 2. Plan y entorno

**Objetivo:** comprobar el registro de una cuenta ficticia, la asignación del rol predeterminado activo y las respuestas de conflicto y validación. Además, ejecutar las pruebas automatizadas disponibles del API.

**Incluye:**

- Registro HTTP y persistencia de la relación entre usuario y rol.
- Rechazo de correo duplicado y datos inválidos.
- Suite de pruebas automatizadas del API con Java 21 y Maven 3.9.13.

**Fuera del alcance:** pruebas de rendimiento, E2E de frontend/móvil, despliegue en `qa` y validación de módulos ajenos al registro.

**Ejecución automatizada más reciente:** `mvn -B test` en la imagen local `somnguard-api-test-builder` (Maven 3.9.13 y Java 21.0.10). Se montaron `pom.xml`, `config/` y `src/` en solo lectura; Docker estuvo disponible para Testcontainers. PostgreSQL 16.15 se creó como contenedor temporal. La base de datos local de SomnGuard no se usó ni se modificó.

## 3. Casos de prueba manuales

| ID | Escenario y pasos | Resultado esperado | Resultado observado | Estado |
|---|---|---|---|---|
| TC-SEC-001 | Enviar `POST /api/v1/auth/register` con correo nuevo y datos válidos; consultar usuario y relación de roles en PostgreSQL. | HTTP 201; se crea el usuario y queda vinculado al rol activo `user`. | HTTP 201 con identificador y correo. La consulta encontró el usuario en estado `USER_PENDING_VERIFICATION`, el rol `user` activo y la asignación activa, sin borrado lógico. | **APROBADO** |
| TC-SEC-002 | Repetir el registro con el mismo correo de TC-SEC-001. | HTTP 409 por correo ya registrado. | HTTP 409 Conflict. | **APROBADO** |
| TC-SEC-003 | Enviar un correo con formato inválido, contraseña demasiado corta y nombres vacíos. | HTTP 400 por validación de entrada. | HTTP 400 Bad Request. | **APROBADO** |

### Evidencia de persistencia

La consulta local a PostgreSQL confirmó que la cuenta de prueba existe en estado `USER_PENDING_VERIFICATION`, que `role.code = user` y `role.is_active = true`, y que la asignación usuario–rol está activa y no tiene borrado lógico. Se usó una cuenta sintética con dominio reservado `example.com`; quedó pendiente de verificación de correo para conservar el rastro de la comprobación.

## 4. Suite automatizada del API

| Métrica | Resultado |
|---|---:|
| Pruebas ejecutadas | 162 |
| Pasaron | 162 |
| Fallos de aserción | 0 |
| Errores de entorno | 0 |
| Omitidas | 0 |

En la ejecución del 6 de noviembre, `AuthPostgresIntegrationTest` usó Testcontainers para iniciar PostgreSQL 16.15, ejecutar `postgres/init.sql` y completar el flujo de registro, verificación de correo, inicio de sesión y rotación del refresh token. La suite utilizó el par RSA exclusivo de `src/test/resources/keys/test/`. El contenedor temporal se cerró al finalizar; los seis contenedores locales de SomnGuard siguieron activos, sin detenerse.

**Límite de esta integración:** la configuración de prueba usa `spring.liquibase.enabled=false` y `spring.jpa.hibernate.ddl-auto=create-drop`. Además, `ensureDefaultRoleExists()` en `@BeforeEach` inserta manualmente el rol activo `user`. Por tanto, esta ejecución verifica el flujo y la asignación de rol sobre PostgreSQL, pero no demuestra que Liquibase aprovisione el rol en una base limpia. Esa verificación sigue abierta en AP-003.

## 5. Acción recomendada y conclusión

No queda pendiente repetir la integración con PostgreSQL: la suite completa pasó en el contenedor Maven con Docker Desktop. Mantener el par RSA exclusivamente en el perfil de pruebas; nunca usarlo en desarrollo o producción. Después del resumen de pruebas, Maven imprimió un mensaje de espera de 30 segundos de Surefire y advertencias de cierre de conexiones de Hikari; el proceso terminó con código 0 y `BUILD SUCCESS`. Revisar este cierre si vuelve a ocurrir, aunque no cambió el resultado de las pruebas.

**Conclusión manual:** el registro crea la cuenta y asigna el rol activo `user` en el entorno local probado.
**Conclusión automatizada:** las 162 de 162 pruebas pasaron, con 0 fallos, errores u omisiones; incluye la integración PostgreSQL/Testcontainers.

---

El informe omite contraseñas, tokens, claves y datos de personas reales.

## 6. Evidencia complementaria de CI de los tags

Además de la ejecución local de la sección 4, se revisaron ejecuciones de GitHub Actions asociadas a los commits exactos de los tags final-delivery-2026 en main. Consulta de la evidencia de CI: 6 de noviembre de 2026. Estos resultados corresponden a esas revisiones etiquetadas de main y son independientes de la ejecución local en develop del 6 de noviembre de 2026.

| Evidencia | Fecha | Commit del tag | Resultado | Ejecución |
|---|---|---|---|---|
| CI del API | 2026-10-29 | [903d3c2](https://github.com/SomnGuard/somnguard-api/commit/903d3c275bf016a13c7e462a7f062fc7c84659fc) | Compilación, suite de pruebas, Checkstyle y construcción de imagen Docker completadas correctamente. | [Abrir GitHub Actions](https://github.com/SomnGuard/somnguard-api/actions/runs/40892474337) |
| Validación de Liquibase | 2026-10-25 | [e1af032](https://github.com/SomnGuard/somnguard-db/commit/e1af032352d114181392583a458a672585a5b127) | Validación de Liquibase y verificación de rollback completadas correctamente. | [Abrir GitHub Actions](https://github.com/SomnGuard/somnguard-db/actions/runs/40241563463) |
| Despliegue del API | 2026-10-29 | [903d3c2](https://github.com/SomnGuard/somnguard-api/commit/903d3c275bf016a13c7e462a7f062fc7c84659fc) | Despliegue al VPS completado correctamente. | [Abrir GitHub Actions](https://github.com/SomnGuard/somnguard-api/actions/runs/40892894874) |
| Despliegue de base de datos | 2026-10-25 | [e1af032](https://github.com/SomnGuard/somnguard-db/commit/e1af032352d114181392583a458a672585a5b127) | Despliegue de Liquibase a producción completado correctamente. | [Abrir GitHub Actions](https://github.com/SomnGuard/somnguard-db/actions/runs/40241650090) |
| Aplicación Android | 2026-10-30 | [135c24e](https://github.com/SomnGuard/somnguard-app/commit/135c24e82001578911529a70a4a4afabaf5eeec7) | Compilación del APK firmado, carga del artefacto, despliegue al VPS y comprobación de descarga pública completados correctamente. | [Abrir GitHub Actions](https://github.com/SomnGuard/somnguard-app/actions/runs/41072463820) |

**Alcance de esta evidencia:** los resultados de CI corresponden a commits etiquetados de main y complementan la suite local de develop, ejecutada el 6 de noviembre sobre el árbol de trabajo con cambios sin confirmar. La suite local pasó 162/162 pruebas, incluida `AuthPostgresIntegrationTest` con PostgreSQL temporal. La ejecución parcial del 5 de noviembre (161/162, sin Docker) quedó superada. Estos resultados no reemplazan las capturas operativas pendientes del procedimiento de implementación.
