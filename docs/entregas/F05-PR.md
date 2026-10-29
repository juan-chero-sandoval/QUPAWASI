## Problema y resultado

F05 de Carla añade integración nativa de preferencias, entradas inválidas y borrador al pausar/reconstruir, y refuerza CRUD con conteo de filas y puntos después de reaperturas. Corrige que descartar/convertir un borrador avanzaba aunque SQLite no hubiera podido borrarlo: ahora conserva la recuperación, muestra error y permite reintentar. Dos pruebas de regresión con archivo SQLite real.

Versión 0.2.0+2, README reproducible, CI Android en modo avión, APK/evidencias/trazabilidad y guion preparados. No hay cambio de esquema ni backend.

## Verificación real

Consultar [informe F05](https://github.com/juan-chero-sandoval/QUPAWASI/blob/codex/f05-qa-apk-entrega/docs/entregas/F05.md) y evidencias vinculadas: baseline 114 tests/análisis/build aprobados; regresión reproducida antes de corregir; resultados finales Android y build se registran en el informe. La integración recrea dependencias; el force-stop del APK normal es evidencia separada. No se declara CI aprobada hasta que finalice sobre el head publicado.

Revisión sugerida: primero control de descarte + regresiones, luego helpers/integraciones/CI, después identificación APK y documentación. Se mantiene la única rama F05 solicitada; documentación y evidencia pueden superar el presupuesto sugerido de 400 líneas. No se comprimieron pruebas ni se cambiaron los otros autores para reducir el diff.

## Entrega y relevo

Destino develop, sin merge automático. Se conservan las implementaciones de Cristopher 291881e (PR2), Juan 5ac9450 (PR4), Brianna 1088394 (PR6) y Adriana 79d4d4d (PR7). Autoría Carla Novillo y cuenta GitHub novillofebresarait-byte verificadas; no se modificó identidad.

Pendientes académicos: video real ≤5 minutos/enlace autorizado, sustentación individual y aceptación docente de adaptación MYPE→UNP. No se subió a Drive/YouTube ni tiendas. No hay firma de producción; release heredado usa clave debug. No se declara TalkBack, teléfono físico o iOS probado. El owner revisa y decide integración, conservando commits.

Rollback de F05: corrección de descarte, pruebas/helpers, versión/job Android y documentación/evidencia; sin borrar DB v1 ni revertir F01–F04.

- [x] F01–F04 integradas y PR verificados en GitHub.
- [x] Rama destino develop; sin squash, force-push o merge automático.
- [x] Sin APK, claves ni datos de estudiantes añadidos al commit.
- [ ] Verificar checks CI del head final antes de integrar.
- [ ] Completar video y sustentación; este PR no certifica entrega académica completa.
