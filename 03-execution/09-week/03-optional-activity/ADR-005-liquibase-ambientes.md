# ADR 005 - Uso de Liquibase y ambientes

## Estado
Aceptado

## Contexto
El proyecto necesita manejar cambios de base de datos de forma ordenada y diferenciar ambientes como desarrollo, pruebas y producción.

## Decisión
Se usará Liquibase para gestionar cambios mediante changelogs. También se manejarán ramas/ambientes `dev`, `qa` y `main`.

## Alternativas consideradas
- Crear tablas manualmente.
- Usar Hibernate para generar tablas.
- Usar Liquibase con archivos versionados.
- Manejar una sola rama sin ambientes.

## Consecuencias
- Los cambios quedan documentados.
- Es más fácil replicar la estructura en diferentes ambientes.
- Se reduce el riesgo al pasar de desarrollo a pruebas y producción.
