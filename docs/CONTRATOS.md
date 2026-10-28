# Arquitectura y contratos comunes

Estado: F01 integrada; contratos F02 implementados en `apps/mobile/lib/domain/` y adaptadores en `data/`. La interfaz CRUD visible sigue asignada a F03. Si se ajustan nombres, actualizar este archivo y consumidores juntos.

## Dependencias y composición

```text
apps/mobile/lib/
  main.dart
  app/                 app.dart, router.dart, dependencies.dart
  core/                theme/, widgets/, errors/, clock/
  domain/
    entities/          recycling_record, recycling_point, reward, redemption, draft
    repositories/      contratos de persistencia y preferencias
    usecases/          CRUD, estadísticas, canjes y borradores
  data/
    local/             Drift, tablas, migraciones y seeds
    preferences/       Shared Preferences
    repositories/      implementaciones de contratos de dominio
  presentation/
    onboarding/ home/ recycling/ map/ rewards/ profile/ suggestions/
apps/mobile/test/       domain/, data/, presentation/
apps/mobile/integration_test/
supabase/              NO crear en Unidad II
```

Presentación → casos de uso/dominio. Datos → interfaces de dominio. El dominio no importa Flutter, Drift, Provider o plugins. La composición inyecta dependencias en el arranque; no usar singletons globales de DB desde widgets. Estado MVVM con ChangeNotifier/Provider y modelos de estado inmutables; no persistir ChangeNotifier ni objetos BuildContext.

SQLite mediante Drift sobre conexión asíncrona/isolate compatible con versión elegida. Shared Preferences para configuración simple; no sustituye la base. F02 crea la DB; F01 solo declara adaptadores de preferencias y deja el punto de composición.

## Rutas estables

| Ruta | Parámetros | Semántica |
| --- | --- | --- |
| `/welcome` | ninguno | Bienvenida; onboarding en preferencias |
| `/home` | ninguno | Inicio y datos locales |
| `/recycling` | filtro opcional | Lista de registros y acceso a crear |
| `/recycling/new?pointId=...` | `pointId` opcional | Nuevo registro con punto preseleccionado |
| `/recycling/:recordId` | ID obligatorio | Detalle; inexistente muestra mensaje y volver |
| `/recycling/:recordId/edit` | ID obligatorio | Formulario precargado; no crea otro al guardar |
| `/map` | `pointId` opcional | Esquema/lista local |
| `/rewards` | categoría opcional | Catálogo y canjes |
| `/profile` | ninguno | Perfil de demo, tema y niveles |
| `/ranking` | ninguno | Datos de demostración, no estudiantes reales |
| `/suggestions` | ninguno | Sugerencias locales |

Declarar `/new` antes de la ruta dinámica si el router lo requiere. Pasar IDs serializables; recargar entidad por repositorio. No depender únicamente de `extra` con objetos en memoria, pues se perderían al restaurar. Back de Android respeta pila; barra inferior mantiene pestaña coherente. Guardar destino de borrador solo si existe y es válido.

## Entidades y esquema SQLite

Todos los ID son texto UUID generados en la capa de aplicación/datos, nunca índice de lista. Fechas persistidas UTC; mostrar en hora local. Cantidades enteras 1..100 por registro (límite **propuesto para demo**, no medido en documentos). Texto nota máximo 200 caracteres y alias 2..40 tras trim. Material: `pet` o `aluminum`. Sin valores nulos que produzcan crashes; errores tipados con mensaje de usuario.

| Tabla | Campos mínimos | Restricciones |
| --- | --- | --- |
| `recycling_points` | id, name, description, occupancy, latitude?, longitude?, is_demo | Nombre no vacío; occupancy 0..100; coordenadas nulas si no verificadas |
| `recycling_records` | id, point_id, material, quantity, unit_points, occurred_at, note, created_at, updated_at | FK punto, cantidad entera 1..100, material permitido, fechas no futuras |
| `rewards` | id, title, category, cost_points, description, is_active | Costo entero positivo |
| `redemptions` | id, operation_id, reward_id, title_snapshot, cost_snapshot, created_at, canceled_at? | operation_id UNIQUE; snapshot de costo/título; activo si canceled_at null |
| `drafts` | key, record_id?, point_id?, material?, quantity_text, note, step, updated_at, occurred_at? | Una fila por formulario; conserva entrada inválida como texto de borrador; paso 0..2 |
| `suggestions` | id, message, created_at | Mensaje 5..500; local, no estado “enviado” |

No borrar puntos/recompensas referenciados al editar seeds. Sembrar solo si faltan: no duplicar al iniciar ni reactivar registros que el usuario eliminó. Punto demo “Arquitectura”, “Biblioteca” y “Comedor”; no afirmar horarios, disponibilidad o ubicación real. Iniciar sin registros, saldo cero. Catálogo de demostración: fotocopias 80, recarga simulada 100 y cafetería 150, según capturas; todos con aviso sin entrega comercial.

Perfil local (`alias`, facultad de demostración opcional), `themeMode` (`system/light/dark`) y `onboardingCompleted` en Shared Preferences con claves versionadas `qupawasi.v1.*`. No sesión remota ni password. Aplicar `system` en primera instalación; permitir tema explícito. Un perfil local no representa autenticación. Reiniciar configuración no borra registros salvo acción separada confirmada; no añadir reset destructivo por defecto.

## Contratos semánticos de repositorio

```text
RecordsRepository
  watchAll(filter?) -> Stream<List<RecyclingRecord>>
  getById(id) -> Future<RecyclingRecord?>
  create(input) -> Future<RecyclingRecord>
  update(id, input) -> Future<RecyclingRecord>
  delete(id) -> Future<void>
PointsRepository: watchPoints(), listPoints()
StatisticsRepository: watchStatistics()
RewardsRepository: watchCatalog(category?), watchRedemptions()
  redeem(rewardId, operationId) -> Future<Redemption>
  cancelRedemption(id) -> Future<void>
DraftRepository: load(key), save(draft), clear(key)
SuggestionsRepository: list(), create(message), delete(id)
PreferencesRepository: loadPreferences(), setTheme(mode), setAlias(alias), completeOnboarding()
```

Los casos de uso validan entradas antes de escribir y normalizan errores; repositorios validan invariantes también en la transacción. La vista no captura excepciones SQL sin traducir ni calcula estadísticas. `getById` devuelve null para inexistente; update/delete sobre inexistente tienen resultado tipado `notFound`. Cargar, guardar y eliminar tienen estados visibles y posibilidad de reintentar. Streams cancelados en dispose.

## Reglas de puntos y consistencia

Valores propuestos para simular: PET = 10 puntos/unidad; aluminio = 5. Guardar política en un único módulo `DemoScoringPolicy`, con pruebas. No se atribuyen estas tasas a las fuentes académicas. Unidades no son dinero y la equivalencia S/1.00 de la captura es solo referencial; preferible no mostrarla.

`earnedPoints = suma(quantity × tasa)` de registros activos. `spentPoints = suma(cost_snapshot)` de canjes no cancelados. `availablePoints = earnedPoints - spentPoints`. Niveles por **earnedPoints**, no saldo: Semilla 0, Brote 200, Árbol joven 500, Guardián del bosque 1000. El progreso nunca divide por cero y se acota entre 0 y 1.

Crear/editar/eliminar no incrementa un contador acumulado: recalcula desde los registros. Canjear valida saldo en la misma transacción que inserta el canje. `operationId` se genera al confirmar y se conserva en un reintento: el mismo ID devuelve el mismo canje, sin descontar dos veces. Si se repite con otro rewardId, devolver conflicto, no cambiar el canje original.

F02 guarda `unit_points` como snapshot de la política demo aplicada al crear/editar cada registro. El saldo consulta `sum(quantity * unit_points)`. Las tasas 10/5 existen solo en `DemoScoringPolicy`; los triggers SQLite protegen saldo sin duplicar esas tasas. Las fechas SQLite son enteros de milisegundos UTC. No existe tolerancia de fecha futura: `occurredAt <= clock()`.

Editar o eliminar un registro que dejaría `earnedPoints < spentPoints` se rechaza atómicamente con mensaje “Cancela primero un canje simulado para liberar puntos”. La UI de Premios permite cancelar el canje; no restituye dos veces. No ocultar un saldo negativo con `max(0, saldo)`; mantener el invariante en DB. El CRUD de evaluación se demuestra inicialmente sin canjes, y después se demuestra el bloqueo/cancelación.

Impacto: contar PET/latas exactamente; masa/CO₂ solo si se define una política de factores de demostración documentada y probada. Sin fuente validada usar “Estimación no configurada”, no números presentados como medidos. Racha calculada por días locales distintos con registros (no número de clics); probar días consecutivos y vacío. Insignias derivadas de datos: primer registro, cinco días, 25 PET, tres puntos distintos, primer canje activo, 30 días. Una edición/eliminación puede revocar una insignia en esta simulación.

## Borrador y ciclo de vida

Persistir borrador con debounce aproximado 400 ms tras inputs y un flush al pausar/inactive; serializar guardados para impedir que un evento viejo sobrescriba otro. Guardar de forma incremental es necesario porque Android puede matar el proceso sin enviar callback final. Una operación pendiente de debounce se confirma al pasar de paso o navegar atrás.

Restaurar borrador tras abrir proceso nuevo, usando recordId para verificar si aún existe. Si el registro fue eliminado, ofrecer convertir el borrador a nuevo o descartarlo, nunca sobreescribir otro ID. No limpiar borrador antes de que el registro se guarde exitosamente. Cerrar streams/observadores al desmontar y liberar sensores si se añaden. No persistir un flag `isSaving=true` que bloquee tras un reinicio.

## Extensibilidad posterior

No migrar registros demo a puntos verificados. Una futura integración añadirá identidad, outbox, estados pendientes/aceptados/rechazados y RPC atómica; necesitará migraciones nuevas. No añadir hoy firmas, tokens o columnas especulativas que retrasen el CRUD.

## API Dart disponible para F03 y F04

La composición de producción `AppDependencies.create()` abre SQLite en directorio de soporte interno, archivo `qupawasi.sqlite`, en un isolate nativo. `dependencies.local` expone:

| Acceso | Operaciones |
| --- | --- |
| `local.recycling` (`RecyclingUseCases`) | `watch({RecordsFilter? filter})`, `get(id)`, `create(RecordInput)`, `update(id, RecordInput)`, `delete(id)` |
| `local.overview` (`OverviewUseCases`) | `listPoints()`, `watchPoints()`, `getStatistics()`, `watchStatistics()` |
| `local.rewards` (`RewardsUseCases`) | `watchCatalog({RewardCategory? category})`, `watchRedemptions()`, `redeem(rewardId, operationId)`, `cancel(redemptionId)` |
| `local.drafts` (`DraftUseCases`) | `load(key)`, `save(RecyclingDraft)`, `clear(key)` |
| `local.suggestions` (`SuggestionsUseCases`) | `list()`, `create(message)`, `delete(id)` |

Estas fachadas están en dominio, no importan Flutter y se pueden inyectar a ViewModels sin exponer SQL. Los repositorios concretos se construyen en `LocalServices.withDatabase`; para tests abrir DB temporal, `await db.ensureReady()` y pasar reloj controlado. El propietario llama `await dependencies.close()`/`local.close()` al liberar el entorno; **no** cerrar la DB al pasar la app a segundo plano.

`LocalDataException.code` distingue `validation`, `notFound`, `insufficientPoints`, `committedPoints`, `conflict` y `storage`; `.message` es presentable. No mostrar errores SQL crudos. `get` de ID inexistente devuelve null; update/delete devuelven notFound. Listas/sets de salida son inmutables. `RecyclingMaterial` usa `pet`/`aluminum`; `RewardCategory` usa `photocopies`/`mobile`/`cafeteria`.

Los IDs de puntos/recompensas demo son UUID estables en `DemoSeed`; no usar los alias de preview F01 (`biblioteca`, `demo-0001`) para escribir registros. F03 reemplaza/adapta el preview al repositorio real y actualiza sus pruebas de navegación con IDs obtenidos de SQLite, conservando la cobertura de F01.

Para borradores, una escritura con `updatedAt` anterior a la ya guardada no la sobrescribe. En empate gana la última escritura recibida. F03 igualmente serializa debounce/flush y espera guardados pendientes antes de `clear`: una escritura que llegue **después** de borrar podría recrear el borrador si la UI no la cancela/espera. F02 persiste datos; F03 implementa callbacks y restauración de pantalla.

`watchStatistics` se invalida por cambios de registros/canjes. La racha se calcula por días locales distintos y se considera actual si hay registro hoy o ayer. Al reanudar/cambiar de día sin escrituras, el ViewModel debe volver a consultar/resuscribirse para actualizar la racha; F02 no instala un temporizador global.
