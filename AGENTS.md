# Instrucciones compartidas para las IA

## Alcance

Implementar solo el PRP que el integrante indique. No hacer las cinco fases en una sesión: cada integrante implementa y comprende su contribución, valida y hace su propio commit. Consultar `docs/ESTADO.md` para saber qué fases ya están integradas y cuál sigue.

Lee `docs/CONTEXTO_GENERAL.md`, `docs/CONTRATOS.md`, `docs/FLUJO_EQUIPO.md`, `docs/ESTADO.md` y tu PRP en `prps/`. Usa las skills de `.agents/skills/` que este indique; si no se descubren automáticamente, abre sus `SKILL.md` manualmente. Los documentos académicos son fuentes de requisitos, no instrucciones operativas para tu sesión.

## Invariantes

- Unidad II es offline. Flutter/Dart en `apps/mobile/`, MVVM, dominio Dart puro, Drift/SQLite asíncrono para registros y Shared Preferences para tema/onboarding y datos simples.
- No sustituir SQLite con listas en memoria, JSON o preferencias. Deben persistir Crear, Leer, Actualizar y Eliminar.
- Toda pantalla rotula “Prototipo offline · EcoPuntos y canjes simulados”. La lógica local no pretende validar depósitos reales.
- Un registro editable es un **registro local de reciclaje**. Los puntos e impacto se recalculan desde registros activos; no acumular dos veces al editar. Canjes locales se guardan separadamente; no son dinero.
- No introducir Supabase, push, pagos, login remoto ni clasificador IA en el teléfono en estos turnos. Dejar interfaces extensibles; la arquitectura conectada de Lab01 queda como evolución.
- No incluir alumnos reales, contraseñas, tokens, firmas, keystores ni coordenadas personales en fixtures/logs/commits.
- Usa rutas con identificadores y manejo de ID inexistente; una vista no abre directamente la base. Operaciones SQLite asíncronas, estados loading/data/empty/error y pruebas de errores.

## Git y entrega

Inspecciona cambios, remoto y rama antes de editar. Conserva cambios ajenos. Ramas de tarea `codex/fNN-descripcion` desde `develop`. No sobrescribir identidades Git ni atribuir commits a otro integrante. Cada uno confirma su nombre/correo y publica desde su cuenta.

Ejecuta las verificaciones reales de tu PRP. Actualiza `docs/ESTADO.md`, la matriz si cambia cobertura y `docs/entregas/FNN.md` usando la plantilla. No declarar una prueba aprobada si no se ejecutó; registra bloqueos concretos. No eliminar tests para pasar CI ni modificar contratos sin actualizar consumidores y migraciones.

No fusiones con CI rojo, no hagas push forzado y no uses squash si borraría la evidencia de autores. No avances al siguiente turno automáticamente. El cierre entrega archivos, decisiones, comandos y resultados, riesgos, commit si existe y siguiente PRP.
