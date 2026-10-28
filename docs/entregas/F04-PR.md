Completa la experiencia offline sobre los repositorios F02/F03: Inicio y Perfil reaccionan a CRUD/canjes; el esquema local pasa UUID al formulario; Premios filtra, confirma y cancela con saldo consistente; Ranking usa aliases ficticios y Sugerencias persiste solo en el dispositivo.

El identificador de confirmación se guarda antes de la transacción SQLite y se recupera para reintentos tras reiniciar. Canjes y saldo permanecen en SQLite. No cambian esquema, política de puntos, dependencias ni CRUD. No se añaden servicios de red, pagos ni depósitos verificados.

Validación local: script móvil (generación Drift, formato, análisis, 114 tests y APK debug), regresión Android F03 y recorrido Android F04 con SQLite/preferencias reales. Layout con scroll a 320/360/412 dp y texto hasta 2×; etiquetas, tamaño táctil y contraste en ambos temas. Force-stop manual conserva canje, cancelación, sugerencia, alias y tema en modo avión. Resultados exactos y límites en `docs/entregas/F04.md`.

Revisar por áreas: estadísticas/mapa, recuperación/cancelación de canjes y sugerencias/pruebas. Cambio de 2004 líneas de texto y 16 PNG (supera el presupuesto de 400 líneas) por el alcance completo F04 en la rama solicitada. Requiere revisión y CI verde antes de integrar. No incluye F05 de Carla ni declara pruebas de TalkBack/teléfono físico.
