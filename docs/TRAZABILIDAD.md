# Matriz de requisitos y rúbrica de Unidad II

Fuente: `UNIDAD_2_Trabajo_Grupal_Moviles.pdf`, tres páginas, recibido el 28/10/2026. El documento pide un prototipo offline para una MYPE; aquí se adapta al proyecto Q'UPA WASI trabajado en Lab01, sin afirmar aprobación docente específica para esta adaptación.

La tabla asigna responsabilidades y evidencia **prevista**. En la preparación ninguna implementación está verificada; F05 completa resultado y vínculo real a pruebas/código/video, no solo marca casillas.

| ID | Requisito comprobado en fuente | Implementación prevista | Fase | Prueba/evidencia prevista | Estado inicial |
| --- | --- | --- | --- | --- | --- |
| U2-01 | P1: al menos 3 pantallas; rúbrica excelente dice +3 | Cinco pestañas + listado/detalle/formulario | F01/F03/F04 | Rutas y prueba de navegación en Android | Planificado |
| U2-02 | P1: paso de parámetros | recordId en detalle/edición y pointId desde mapa | F01/F03/F04 | IDs correctos e inexistentes; captura de formulario preseleccionado | Planificado |
| U2-03 | P1: guardar estado temporal en segundo plano | Borrador incremental y flush al pausar | F03 | Background, retorno y reinicio con texto sin guardar | Planificado |
| U2-04 | P1: árbol de widgets/vistas dinámicas | Componentes reutilizables, listas reactivas | F01/F04 | Datos visibles al crear/editar/eliminar; pantallas pequeñas | Planificado |
| U2-05 | P1: gestión de estado y eventos | MVVM ChangeNotifier/Provider | F01/F03/F04 | Validación inputs, filtros, confirmaciones y navegación | Planificado |
| U2-06 | P2: Shared Preferences para datos simples/config | Tema, onboarding y alias demo | F01 | Cambiar, cerrar proceso, reabrir y leer valores | Planificado |
| U2-07 | P2: CRUD completo SQLite | Registros locales: create/read/update/delete | F02/F03 | SQLite real, reapertura, video de editar/eliminar | Planificado |
| U2-08 | P2-3: asincronía y separación de lógica/vista | Drift asíncrono, repositorios/casos de uso | F02/F03 | Tests sin bloqueo, revisión de imports y lifecycle | Planificado |
| U2-09 | P2: fuente y README con compilación/stack/roles | README definitivo y versiones fijadas | F05 | Clon limpio, comandos y enlaces a cinco contribuciones | Planificado |
| U2-10 | P2: commits de todo el equipo | Cinco fases con autores reales | Todas | Git log y PR sin squash, al menos una contribución real por integrante | Planificado |
| U2-11 | P2: video máx. 5 min en YouTube/Drive | Guion y grabación real del equipo | F05 | Enlace accesible, duración y prueba SQLite al reabrir | Planificado |
| U2-12 | P2: ejecutar en emulador/dispositivo y explicar | APK instalado y sustentación repartida | F05/Todos | Android de prueba, versión, hash APK y explicación por autor | Planificado |

## Rúbrica de 20 puntos

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
