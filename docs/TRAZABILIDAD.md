# Matriz de requisitos y rúbrica de Unidad II

Fuente: `UNIDAD_2_Trabajo_Grupal_Moviles.pdf`, tres páginas, recibido el 28/10/2026. El documento pide un prototipo offline para una MYPE; aquí se adapta al proyecto Q'UPA WASI trabajado en Lab01, sin afirmar aprobación docente específica para esta adaptación.

La tabla combina evidencia prevista y verificaciones por fase. F01 está integrada y F02 aporta tests de persistencia/dominio; F05 completará evidencias Android/video sin sustituirlas por casillas.

| ID | Requisito comprobado en fuente | Implementación prevista | Fase | Prueba/evidencia prevista | Estado inicial |
| --- | --- | --- | --- | --- | --- |
| U2-01 | P1: al menos 3 pantallas; rúbrica excelente dice +3 | Cinco pestañas + listado/detalle/formulario | F01/F03/F04 | Rutas y prueba de navegación en Android | F01: 5 pestañas + detalle/formulario/ranking/sugerencias; tests y M02 en emulador. Pantallas funcionales en F03/F04 |
| U2-02 | P1: paso de parámetros | recordId en detalle/edición y pointId desde mapa | F01/F03/F04 | IDs correctos e inexistentes; captura de formulario preseleccionado | F01: rutas, ID inexistente y ruta desconocida. F03: detalle/edición por UUID desde SQLite, pointId válido preselecciona e inválido no guarda contra otro punto; recorrido desde Mapa pendiente F04 |
| U2-03 | P1: guardar estado temporal en segundo plano | Borrador incremental y flush al pausar | F03 | Background, retorno y reinicio con texto sin guardar | F03: debounce serializado, flush en paso/atrás/inactive/paused, oferta continuar/descartar; tests y M08 en emulador con force-stop |
| U2-04 | P1: árbol de widgets/vistas dinámicas | Componentes reutilizables, listas reactivas | F01/F04 | Datos visibles al crear/editar/eliminar; pantallas pequeñas | F01: componentes comunes y layout 320/360/412 dp × texto 2x probado; listas reactivas pendientes |
| U2-05 | P1: gestión de estado y eventos | MVVM ChangeNotifier/Provider | F01/F03/F04 | Validación inputs, filtros, confirmaciones y navegación | F01: preferencias y alias. F03: ViewModels de lista/detalle/formulario con estados loading/empty/data/error/saving, validación junto al campo, doble tap y confirmaciones; resto F04 |
| U2-06 | P2: Shared Preferences para datos simples/config | Tema, onboarding y alias demo | F01 | Cambiar, cerrar proceso, reabrir y leer valores | F01: implementado; tests con repositorio reconstruido y M03 en emulador (force-stop) |
| U2-07 | P2: CRUD completo SQLite | Registros locales: create/read/update/delete | F02/F03 | SQLite real, reapertura, video de editar/eliminar | F02: repositorios y tests SQLite. F03: CRUD visible; integration_test en emulador (crear, reabrir, editar mismo ID, eliminar) y M04/M05/M07 manuales; video pendiente F05 |
| U2-08 | P2-3: asincronía y separación de lógica/vista | Drift asíncrono, repositorios/casos de uso | F02/F03 | Tests sin bloqueo, revisión de imports y lifecycle | F02: Drift en isolate y streams. F03: vistas sin SQL, AppLifecycleListener, suscripciones canceladas en dispose y test de que no se multiplican |
| U2-09 | P2: fuente y README con compilación/stack/roles | README definitivo y versiones fijadas | F05 | Clon limpio, comandos y enlaces a cinco contribuciones | Planificado |
| U2-10 | P2: commits de todo el equipo | Cinco fases con autores reales | Todas | Git log y PR sin squash, al menos una contribución real por integrante | Planificado |
| U2-11 | P2: video máx. 5 min en YouTube/Drive | Guion y grabación real del equipo | F05 | Enlace accesible, duración y prueba SQLite al reabrir | Planificado |
| U2-12 | P2: ejecutar en emulador/dispositivo y explicar | APK instalado y sustentación repartida | F05/Todos | Android de prueba, versión, hash APK y explicación por autor | Planificado |

## Rúbrica de 20 puntos

Actualización de cobertura F04 (validación local, no sustituye CI/video F05):

| Requisito/casos | Evidencia F04 ejecutada |
| --- | --- |
| U2-01/U2-02, M02/M09 | Cinco pestañas conservadas; mapa por UUID válido/inexistente; integración Android Biblioteca → formulario F03 |
| U2-04/U2-05, M11/M12 | Inicio/Perfil reactivos; filtros y confirmaciones; un canje ante doble tap/reintento; cancelación única y rechazo de CRUD con saldo comprometido; tests SQLite en archivo e integración Android |
| U2-06/U2-07, M03/M13 | Alias/tema/confirmación pendiente y canje/sugerencia recuperados al recrear dependencias nativas; canje y sugerencia comprobados también con force-stop sin reinstalar |
| U2-08 | Streams/observador/timer dispuestos; racha reconsultada al reanudar tras días sin escrituras; errores de almacenamiento con reintento |
| M04–M07 | Regresión de widgets y recorrido Android F03 aprobados; CRUD SQLite no modificado |
| M14 | Layout con scroll a 320/360/412 dp, texto 1/1.3/2, ambos temas y ocho destinos; controles etiquetados/tamaño táctil/contraste comprobados en cinco destinos; sugerencia manual con teclado |

Resultados, capturas y límites de TalkBack/teléfono físico: [informe F04](entregas/F04.md). U2-09–U2-12 y video final siguen pendientes del equipo/F05.

| Criterio textual abreviado | Puntos | Condición para apuntar a excelente |
| --- | --- | --- |
| Navegación y UI Dinámica | 4 | Más de tres pantallas, argumentos, widgets reutilizables y adaptables |
| Interactividad y Gestión de Estado | 4 | Eventos/validaciones, actualización reactiva y lógica separada de vista |
| Persistencia Local (SQLite y Prefs) | 6 | CRUD completo funcional y asíncrono, preferencias efectivas |
| Ciclo de Vida y Arquitectura | 3 | Estado temporal guardado, modularidad y UI sin bloqueo |
| Trabajo Colaborativo y Sustentación | 3 | Commits de todo el equipo y explicación técnica clara |

## Lo que no exige expresamente Unidad II

La consigna no exige Supabase, IA, QR real, GPS, push, pagos, publicación en tienda ni firma de producción. El APK es parte de la solicitud del owner y sirve para ejecutar la app; el documento pide código, video y sustentación. Esas extensiones no reemplazan CRUD ni preferencias y quedan fuera del camino crítico.

La ficha técnica y Lab01 sí plantean backend/cámara/GPS y arquitectura conectada; esta etapa mantiene separación de capas para implementarlos después. Registrar en README que el prototipo local no acredita reciclaje real.
