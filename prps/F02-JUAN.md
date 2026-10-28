# F02 — Juan — Dominio y SQLite

## Objetivo y prerrequisitos

Dar a la app una fuente de verdad local con CRUD completo y transacciones. Responsable: Juan. Rama `codex/f02-sqlite-dominio`. Requiere F01 integrada en `develop`, CI móvil verde y handoff de entorno leído. No recrear la aplicación.

Lee [contexto](../docs/CONTEXTO_GENERAL.md), [contratos](../docs/CONTRATOS.md), [validación](../docs/VALIDACION.md), [flujo](../docs/FLUJO_EQUIPO.md) y [estado](../docs/ESTADO.md). Skills: `../.agents/skills/qupawasi-fase/SKILL.md` y `../.agents/skills/qupawasi-sqlite/SKILL.md`. Leer el informe F01 que existirá al iniciar este turno.

## Alcance

Entidades/casos de uso/repository contracts, DB Drift, seeds, implementaciones y pruebas de datos. Conectar composición para que F03 construya UI sin acceder a SQL. No implementar backend, credenciales ni pantallas del siguiente turno. Preservar preferencias/navegación existentes.

## Implementación por pasos

1. Actualizar desde develop, comprobar base limpia y repetir tests existentes. Revisar versión SDK y dependencias antes de elegir Drift/sqlite3/build_runner. Usar combinación compatible documentada; no forzar downgrade de Flutter sin resolver con todos.
2. Definir entidades inmutables y errores tipados; validar material, cantidad, IDs, notas/fechas según contrato. Inyectar reloj para pruebas de fechas/rachas. Repositorios y casos de uso en Dart puro.
3. Implementar SQLite asíncrono con Drift y generados necesarios. Tablas y restricciones del contrato, FK activas, schemaVersion y semillas idempotentes. Separar DB de producción de bases temporales de tests. Nunca `deleteDatabase` al abrir para evitar migraciones.
4. Registrar puntos demo sin coordenadas inventadas y tres recompensas con precios de referencia; cero registros al iniciar. Todos los datos de demo identificados. No insertar el nombre/código real de las capturas.
5. CRUD: `create` crea UUID estable; `update` conserva ID y createdAt; `delete` realmente borra el registro objetivo y no toda la tabla; `getById` maneja ausente; watchAll emite lista ordenada de forma determinista. Añadir filtros de punto/material si facilitan la UI.
6. Estadísticas derivadas en un único módulo, tasas PET10/lata5 y niveles por puntos ganados. Al editar 2→3 PET el total pasa 20→30; al borrar vuelve a cero. No registrar contadores duplicados que se desincronicen.
7. Repositorio de premios: canje atómico con saldo suficiente y operationId único; snapshots de costo/título. Cancelación idempotente y regla de edición/eliminación que impediría saldo negativo. Serializar transacciones SQLite; pruebas de llamadas simultáneas, no solo double tap UI.
8. Implementar DraftRepository y SuggestionsRepository conforme al contrato para que F03/F04 solo consuman API. Guardar texto de cantidad incompleta en borrador sin exigir que sea un registro válido.
9. Conectar repositorios en composición sin imports Drift en widgets. Ajustar workflow a generación Drift antes de análisis si se requiere. Versionar schema/migraciones y generados según convención explicada; verificar clon limpio.
10. Registrar firmas definitivas, ejemplos de uso y errores en informe F02. Si un cambio compatible de contrato resulta necesario, actualizar este documento y tests; no dejar a F03 adivinando retornos.

## Pruebas exigidas

- Crear/leer/actualizar/eliminar en SQLite real y verificar contenido, ID/fechas y ausencia tras borrar.
- Guardar en archivo temporal, cerrar conexión y reabrir nueva conexión; datos permanecen. No basta `NativeDatabase.memory()`.
- Quantity inválida, material inválido, FK inexistente y ID inexistente producen error sin escritura parcial.
- Semillas no se duplican al abrir dos veces; la base inicia saldo cero.
- Editar/borrar recalcula saldo/nivel; tasas en un módulo; racha con días distintos y vacíos.
- Canjes: insuficiente, doble operación misma clave, clave con otra recompensa, concurrencia, cancelación repetida e intento de editar registro que financia canje. Verificar rollback.
- Borrador/sugerencias sobreviven a reapertura; error DB no se transforma en éxito falso.
- Si existe migración, fixture de versión anterior conserva datos tras migrar.

## Validación y aceptación

Ejecutar generación Drift, formato y `scripts/validar_mobile.ps1`; validar contexto y diff. La app anterior sigue abriendo y tema/nav funcionan. No dar por cumplido el CRUD visual: eso se implementa en F03, pero toda API de persistencia debe estar funcional ahora.

- [ ] DB SQLite persistente y asíncrona, con esquema/semillas versionados.
- [ ] CRUD completo y validación consistente fuera de widgets.
- [ ] Reapertura en archivo probada, operaciones de update/delete verificadas.
- [ ] Puntos editables de demo consistentes y sin saldo negativo tras canjes.
- [ ] Repositorios disponibles desde composición; dominio sin plugins.
- [ ] CI/tests/build debug anteriores pasan sin borrar pruebas.
- [ ] `docs/entregas/F02.md` y estado listos con resultados y ejemplo de consumo para Brianna.

## Commit y relevo

Mensaje: `feat: implementar dominio y persistencia SQLite (F02)`. PR a develop preservando autoría de Juan. Entregar a Brianna casos de uso de registros/borrador, esquema, errores, streams y comandos de generación. No desarrollar F03.

## Prompt para la IA

> Soy Juan. Actualiza develop y ejecuta únicamente prps/F02-JUAN.md en codex/f02-sqlite-dominio. Implementa dominio, Drift/SQLite, CRUD, borradores, estadísticas y transacciones de canjes con los contratos compartidos. Prueba DB real en archivo y reapertura, no solo mocks. Mantén F01 funcionando, actualiza handoff/estado y prepara mi commit y PR. No conectes Supabase ni desarrolles el formulario de Brianna. No modifiques identidad Git ni inventes resultados.
