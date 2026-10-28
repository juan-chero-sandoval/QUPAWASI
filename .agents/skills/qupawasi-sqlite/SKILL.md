---
name: qupawasi-sqlite
description: Implementar o revisar CRUD, estadísticas, borradores y transacciones locales Drift SQLite de QUPAWASI, preservando durabilidad y consistencia de puntos simulados.
---

# Persistencia local y reglas de simulación

Lee [los contratos](../../../docs/CONTRATOS.md) y [los casos de aceptación](../../../docs/VALIDACION.md) antes de cambiar tablas/repositorios. Los registros locales son la entidad CRUD; no son movimientos de un saldo remoto verificado.

- Usa SQLite/Drift real, acceso asíncrono y repositorios. Prefs no sustituye datos estructurados. Cambios de esquema llevan migración; nunca borrar DB silenciosamente para solucionar incompatibilidades.
- Puntos/impacto/niveles se derivan de registros. Editar PET 2→3 produce 30 puntos demo, no 50. Eliminar no deja un contador huérfano.
- Canje valida saldo e inserta snapshot en una transacción. operationId único asegura reintentos idempotentes. Cancelación repetida no restituye dos veces.
- Rechaza editar/borrar si compromete saldo ya canjeado; la UI debe permitir cancelar primero el canje simulado. No ocultar negativos con un clamp.
- Semillas idempotentes, cero registros iniciales, datos de ejemplo sin identidad/coordenadas reales inventadas.
- Borrador conserva entrada incompleta, no crea un registro válido hasta confirmar. Serializa escrituras para no perder el último input al pausar.

Prueba CRUD, reapertura de archivo SQLite, rollback e idempotencia. Una prueba con DB en memoria o mocks no demuestra que los datos sobreviven al cierre. Si cambia schema, comprueba migración con datos anteriores. Ejecuta generación Drift y análisis/build antes del relevo.
