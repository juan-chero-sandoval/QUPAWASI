# Matriz de requisitos y rúbrica de Unidad II

## Cambio C01 posterior a la entrega original

| Solicitud del owner | Implementación | Verificación |
| --- | --- | --- |
| Material/cantidad desde QR | Escáner, JSON v1, confirmación de solo lectura, snapshot UTC/coordenadas | Tests parser, VM/widgets y SQLite; integración nativa adaptada |
| No duplicar puntos por reescaneo | Recibo único permanente, transacción y registro QR inmutable | Reintentos concurrentes, reapertura, conflicto y eliminación |
| Mapa y tacho más cercano | Catálogo SQLite importable, GPS opcional, Haversine, mapa geográfico | Catálogo persistente/atómico y proximidad con coordenadas sintéticas |
| Quitar Sugerencias | Retirados botones Inicio/Perfil; datos históricos conservados | Regresión widgets en texto ampliado |
| Aviso según internet | Monitor de acceso a internet, unknown/online/offline y reconsulta al reanudar | Widget offline → online → offline y respuesta inicial tardía |

Los casos originales de alta manual M04/M09 se sustituyen por alta QR y
coincidencia de pointId; M06/M08 permanecen para registros manuales históricos.
El informe C01 registra resultados reales y pendientes de prueba física.

Fuente: `UNIDAD_2_Trabajo_Grupal_Moviles.pdf`, tres páginas, recibido el 28/10/2026. El documento pide un prototipo offline para una MYPE; aquí se adapta al proyecto Q'UPA WASI trabajado en Lab01, sin afirmar aprobación docente específica para esta adaptación.

La tabla combina evidencia prevista y verificaciones por fase. F01 está integrada y F02 aporta tests de persistencia/dominio; F05 completará evidencias Android/video sin sustituirlas por casillas.

| ID | Requisito comprobado en fuente | Implementación prevista | Fase | Prueba/evidencia prevista | Estado inicial |
| --- | --- | --- | --- | --- | --- |
| U2-01 | P1: al menos 3 pantallas; rúbrica excelente dice +3 | Cinco pestañas + listado/detalle/formulario | F01/F03/F04 | Rutas y prueba de navegación en Android | F01–F04 integradas: cinco pestañas y destinos adicionales; navegación Android F05 y widgets, informe F05 |
| U2-02 | P1: paso de parámetros | recordId en detalle/edición y pointId desde mapa | F01/F03/F04 | IDs correctos e inexistentes; captura de formulario preseleccionado | Rutas UUID, pointId Biblioteca y registro inexistente comprobados en integración Android; pointId inválido en VM/widgets |
| U2-03 | P1: guardar estado temporal en segundo plano | Borrador incremental y flush al pausar | F03 | Background, retorno y reinicio con texto sin guardar | Borrador real 1.5/nota/paso tras Home/force-stop/reabrir en APK; callbacks y reapertura nativa automatizados F05 |
| U2-04 | P1: árbol de widgets/vistas dinámicas | Componentes reutilizables, listas reactivas | F01/F04 | Datos visibles al crear/editar/eliminar; pantallas pequeñas | UI reactiva y layout 320/360/412 × texto1/1.3/2 en ambos temas; F05 corrige superposición detectada en APK |
| U2-05 | P1: gestión de estado y eventos | MVVM ChangeNotifier/Provider | F01/F03/F04 | Validación inputs, filtros, confirmaciones y navegación | Eventos MVVM, validación/cancelación/doble tap/reintento cubiertos; F05 añade regresiones de descarte/conversión fallida |
| U2-06 | P2: Shared Preferences para datos simples/config | Tema, onboarding y alias demo | F01 | Cambiar, cerrar proceso, reabrir y leer valores | Tema oscuro/alias/onboarding conservados tras reconstrucción nativa y force-stop real F05; pendientes de canje idempotentes |
| U2-07 | P2: CRUD completo SQLite | Registros locales: create/read/update/delete | F02/F03 | SQLite real, reapertura, video de editar/eliminar | CRUD Android y SQLite en archivo: PET2 → mismo UUID PET3, una fila/30 → eliminar/0 tras detener y reabrir; video pendiente |
| U2-08 | P2-3: asincronía y separación de lógica/vista | Drift asíncrono, repositorios/casos de uso | F02/F03 | Tests sin bloqueo, revisión de imports y lifecycle | Drift asíncrono en isolate, dominio puro, vistas sin SQL; streams/observadores dispuestos; errores y transacciones probados |
| U2-09 | P2: fuente y README con compilación/stack/roles | README definitivo y versiones fijadas | F05 | Clon limpio, comandos y enlaces a cinco contribuciones | README/lockfile/versiones/entorno actualizados F05; 117 tests/build local; CI desde checkout limpio configurada y resultado en PR #9 |
| U2-10 | P2: commits de todo el equipo | Cinco fases con autores reales | Todas | Git log y PR sin squash, al menos una contribución real por integrante | Cinco contribuciones de implementación preservadas: PR #2/#4/#6/#7/#9; Carla c367b2e y 1cb94a3; log/shortlog en evidencia F05 |
| U2-11 | P2: video máx. 5 min en YouTube/Drive | Guion y grabación real del equipo | F05 | Enlace accesible, duración y prueba SQLite al reabrir | Guion 4:50 preparado; video real, duración y enlace accesible siguen PENDIENTES del equipo; no se publicó |
| U2-12 | P2: ejecutar en emulador/dispositivo y explicar | APK instalado y sustentación repartida | F05/Todos | Android de prueba, versión, hash APK y explicación por autor | APK debug 0.2.0+2 instalado en Android17/API37, hash/certificado/procesos en F05; sustentación individual y teléfono físico/TalkBack pendientes |

## Rúbrica de 20 puntos

Actualización de cobertura F04 (validación local, no sustituye CI/video F05):

| Requisito/casos | Evidencia F04 ejecutada |
| --- | --- |
| U2-01/U2-02, M02/M09 | Cinco pestañas conservadas; mapa por UUID válido/inexistente; integración Android Biblioteca → formulario F03 |
| U2-04/U2-05, M11/M12 | Inicio/Perfil reactivos; filtros y confirmaciones; un canje ante doble tap/reintento; cancelación única y rechazo de CRUD con saldo comprometido; tests SQLite en archivo e integración Android |
| U2-06/U2-07, M03/M13 | Alias/tema/confirmación pendiente y canje/sugerencia recuperados al recrear dependencias nativas; canje y sugerencia comprobados también con force-stop sin reinstalar |
| U2-08 | Drift asíncrono en isolate, dominio puro, vistas sin SQL; streams/observadores dispuestos; errores y transacciones probados |
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

## Trazabilidad técnica añadida por F05

| Requisito | Fuente/test verificable | Alcance de la evidencia |
| --- | --- | --- |
| U2-02/U2-07 | `integration_test/crud_flow_test.dart` | UI por UUID, crear PET2, reapertura de archivo, editar PET3, una fila/puntos derivados y eliminar; baseline relativo evita ignorar duplicados |
| U2-03/U2-06 | `integration_test/lifecycle_flow_test.dart` | Plugins nativos: tema/alias/onboarding reconstruidos; entrada inválida y borrador tras callbacks lifecycle y nueva conexión; ejecución y límites en F05 |
| U2-05/U2-08 | `test/presentation/record_form_view_model_test.dart` | SQLite en archivo, error inyectado solo en clear: descartar/convertir no informa éxito falso; reintento confirma borrado tras reapertura |
| U2-04 | `test/presentation/layout_test.dart`, `experience_accessibility_test.dart` | UI reactiva y layout 320/360/412 × texto1/1.3/2 en ambos temas; F05 corrige superposición detectada en APK |
| U2-09 | README, `pubspec.yaml`, `pubspec.lock`, workflow mobile | README/lockfile/versiones/entorno actualizados F05; 117 tests/build local; CI desde checkout limpio configurada y resultado en PR #9 |
| U2-10 | Git log, PR #2/#4/#6/#7 y PR F05 | Cinco contribuciones de implementación preservadas: PR #2/#4/#6/#7/#9; Carla c367b2e y 1cb94a3; log/shortlog en evidencia F05 |
| U2-11 | `docs/VIDEO_Y_SUSTENTACION.md` | Guion 4:50 preparado; video real, duración y enlace accesible siguen PENDIENTES del equipo; no se publicó |
| U2-12 | `docs/entregas/F05.md` | APK debug 0.2.0+2 instalado en Android17/API37, hash/certificado/procesos en F05; sustentación individual y teléfono físico/TalkBack pendientes |

El informe [F05](entregas/F05.md) distingue automatización, callbacks inyectados, reapertura de repositorios y detención real del proceso. Ningún resultado de fases anteriores se convierte automáticamente en aprobación manual F05. La entrega académica sigue incompleta mientras falte el video y la sustentación.
