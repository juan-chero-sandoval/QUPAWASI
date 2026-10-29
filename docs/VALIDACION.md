# Pruebas y evidencia de aceptación

Ejecutar las pruebas aplicables en cada fase y registrar resultados reales en su entrega. Nunca marcar una prueba manual como aprobada por haber escrito su caso. F05 registra dispositivo, versión Android, commit, variante APK y fecha.

## Comprobaciones automatizadas

| Prueba | Resultado esperado | Responsable inicial |
| --- | --- | --- |
| Onboarding/tema en preferencias | Reconstruir repositorio conserva valores, sin contraseña | F01 |
| Enrutamiento con ID y ruta inválida | Detalle correcto o pantalla segura, sin excepción | F01/F03 |
| CRUD en DB real | Crear → consultar → editar mismo ID → eliminar → ausente | F02 |
| Reabrir archivo SQLite | Mismos datos tras cerrar conexión y abrir una nueva | F02 |
| Validación de entradas | 0, negativos, >100, decimales, vacío/material inválido rechazados | F02/F03 |
| Editar puntos | PET 2→3 cambia 20→30, no produce 50 | F02 |
| Eliminar puntos | Sin canjes, borrar único registro devuelve saldo cero | F02 |
| Canje idempotente | 1 operationId y doble tap/reintento producen un canje | F02/F04 |
| Invariante de saldo | Edición que compromete canje se rechaza sin escritura parcial | F02 |
| Cancelación de canje | Cancela una vez, saldo vuelve; segunda cancelación no suma otra vez | F02/F04 |
| Estado MVVM/streams | UI actualiza sin refresco manual; se cancelan listeners al desmontar | F03/F04 |
| Borrador con guardados concurrentes | Valor más reciente sobrevive, no lo sobreescribe un debounce anterior | F03 |
| Restaurar borrador | Texto/paso/punto recuperados tras recrear app | F03 |
| Error de almacenamiento | Mensaje/reintento; borrador intacto, sin éxito falso | F03 |
| Canjes y preferencias al reabrir | DB conserva canjes; prefs conserva tema/alias | F04/F05 |
| Migración | Datos de versión anterior conservados si cambia esquema | F02 y quien cambie DB |

Tests unitarios de dominio no importan plugins. Tests de datos usan SQLite en archivo temporal y limpian solo su propio directorio. Tests de widgets usan dependencias controladas; al menos la integración usa persistencia real. No escribir un test que solo repite la fórmula de producción: comprobar ejemplos de negocio y efectos de edición/eliminación/transacción.

## Recorrido manual obligatorio en Android

| Caso | Pasos | Aceptación |
| --- | --- | --- |
| M01 Primera apertura | Instalar, modo avión, iniciar | Bienvenida legible; empezar abre Inicio, saldo 0 y sin excepción de red |
| M02 Navegación | Abrir cinco pestañas, lista, detalle y volver Android | Pila coherente; pestaña seleccionada correcta; más de tres pantallas |
| M03 Preferencias | Cambiar tema/alias; cerrar proceso desde recientes y reabrir | Tema/alias permanecen; no vuelve bienvenida completada |
| M04 Crear | PET 2, punto Arquitectura, nota “prueba” | Un registro en lista, 20 puntos demo, detalle con mismo ID |
| M05 Persistir | Cerrar app y reabrir sin borrar datos/reinstalar | Registro y nota siguen en SQLite |
| M06 Actualizar | Editar mismo registro a PET 3 y nota “editada” | Misma identidad, 30 puntos, nota actual; no registro duplicado |
| M07 Eliminar | Confirmar eliminar, cerrar y reabrir | No hay registro ni puntos; eliminar cancelado no cambia nada |
| M08 Borrador | Formulario a medias, ir a segundo plano, volver y matar/reabrir | Campos/paso recuperados; descartar explícito lo limpia |
| M09 Parámetros | Mapa: elegir Biblioteca → registrar | Formulario preseleccionado; ID inválido muestra error recuperable |
| M10 Validaciones | Cantidad vacía, 0, -1, 101, 1.5; cancelar diálogo | Mensaje junto al campo; no escribe registros; UI no crashea |
| M11 Canje | Crear 10 PET (100), canjear 80, doble tap, reabrir | Un solo canje, saldo 20; aviso de simulación visible |
| M12 Consistencia | Intentar borrar lo que financia el canje; cancelarlo y repetir | Primer borrado rechazado; cancelar libera saldo y permite borrar |
| M13 Sugerencias | Escribir sin conexión, guardar y reabrir | Persistente y rotulado local, sin mensaje “enviado al equipo” |
| M14 Visual | 320/360/412 dp, texto 1.3x/2x, teclado | Sin overflow; campos/CTA alcanzables con scroll y SafeArea |
| M15 Recuperación | Entrada inexistente, error DB simulado en test, vuelta a app | Estados vacíos/errores claros; sin spinner eterno ni bloqueo |

No probar persistencia desinstalando o limpiando datos: eso elimina SQLite deliberadamente. Se puede usar “Forzar detención” y reabrir para verificar durabilidad de operaciones ya confirmadas. Para borrador, esperar al menos el debounce antes de matar el proceso; documentar la ventana que aún no pudo persistirse.

## Puerta de integración por fase

1. `python scripts/validar_contexto.py` y `git diff --check`.
2. `scripts/validar_mobile.ps1` desde F01: pub get, formato, análisis, tests, APK debug.
3. Pruebas específicas del PRP y smoke test del flujo anterior.
4. Informe con resultados y limitaciones; PR revisado e integrado conservando autoría.

F05 añade instalación y recorrido completo, release según entorno, video real y cinco contribuciones. Si no hay dispositivo o Android SDK, registrar el bloqueo; un archivo `.apk` sin prueba de instalación no cubre por sí solo M01–M15.

## Resultados de cierre F05

[Informe F05](entregas/F05.md): 117 tests locales/análisis/build, tres recorridos de integración Android antes de la última corrección visual y prueba manual del APK con SQLite/prefs/force-stop. M01–M15 se registran individualmente, distinguiendo automatización y manual. No se certifica un recorrido manual separado completo ni video/TalkBack/teléfono físico. El PR #9 contiene la CI de checkout limpio y emulador.
