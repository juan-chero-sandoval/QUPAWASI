# Plan de implementación por fases

## Resultado y prioridades

Construir un APK Flutter de Q'UPA WASI que funcione en modo avión y reproduzca la experiencia de las capturas, con CRUD real en SQLite y preferencias persistentes. La Unidad II asigna **6/20 puntos a persistencia**, 4 a navegación/UI, 4 a interactividad, 3 a ciclo de vida/arquitectura y 3 a colaboración/sustentación. Por ello la ruta crítica es base → SQLite → CRUD/ciclo de vida → pantallas integradas → APK/evidencia.

No se necesita Supabase para esta entrega. Los puntos y canjes son simulaciones locales expresamente rotuladas. La evolución conectada se describe al final, sin comprometer el trabajo obligatorio de hoy.

## Preparación del owner antes del primer turno

1. Revisar este paquete y ejecutar `python scripts/validar_contexto.py`.
2. Publicar la preparación siguiendo `docs/FLUJO_EQUIPO.md`. Esta sesión no la ha commiteado ni publicado.
3. Crear `develop` desde la preparación integrada en `main`. Cada colaborador clona/actualiza desde allí.
4. Confirmar a los cinco que tienen acceso con su propia cuenta y un entorno capaz de editar archivos y ejecutar Flutter. Una IA que solo propone texto o lee GitHub no puede compilar APK por sí sola.
5. Resolver en paralelo el entorno de la máquina de compilación: Flutter estable, SDK Android, licencias, emulador o teléfono. No esperar al quinto turno para descubrir que falta Android SDK.
6. Indicar a cada integrante su fase y el enlace al PRP. No enviar solo “haz mi parte”; usar el prompt preparado.

## Secuencia única de integración

| Orden | Responsable | Entrega observable | Rama | PRP |
| --- | --- | --- | --- | --- |
| 1 | Cristhoper | App abre, bienvenida, cinco pestañas, rutas/IDs y tema persistente | `codex/f01-base-flutter` | [F01](../prps/F01-CRISTHOPER.md) |
| 2 | Juan | SQLite relacional y repositorios, CRUD, cálculos/transacciones probados | `codex/f02-sqlite-dominio` | [F02](../prps/F02-JUAN.md) |
| 3 | Brianna | Registro completo, listado/detalle/edición/eliminación y borrador recuperable | `codex/f03-crud-ciclo-vida` | [F03](../prps/F03-BRIANNA.md) |
| 4 | Adriana | Inicio, mapa local, premios, perfil y sugerencias enlazados a datos | `codex/f04-experiencia-app` | [F04](../prps/F04-ADRIANA.md) |
| 5 | Carla | Regresiones resueltas, APK instalado, README y evidencia/video | `codex/f05-qa-apk-entrega` | [F05](../prps/F05-CARLA.md) |

Solo una rama modifica la app en cada turno. El siguiente empieza cuando el anterior está integrado en `develop`, sus pruebas pasan y existe handoff. Todos pueden preparar su entorno y leer su PRP mientras esperan. El owner revisa/fusiona cada PR sin squash para conservar la autoría. La última entrega pasa de `develop` a `main` con los cinco commits preservados.

## Fase 1 — Cristhoper: base que los demás no tengan que reconstruir

### Responsabilidades

- Crear `apps/mobile` con Flutter, nombre `qupa_wasi`, identificador propuesto `pe.edu.unp.qupawasi` y Android como objetivo obligatorio.
- Fijar versión real Flutter/Dart y lockfile. Añadir solo dependencias que usa: navegación, preferencias, estado y lints.
- Implementar composición `app/`, tema claro/oscuro y base visual reutilizable: superficies, tarjetas, encabezados, botones, insignias, campo, estados vacíos y barra inferior.
- Bienvenida de la captura 01 con “Empezar”; onboarding persistente. Ajustes de tema y alias local con Shared Preferences.
- Cinco pestañas navegables. Esqueleto visual accesible de Inicio y Perfil para que F04 conecte datos sin rehacer estilos. En pantallas todavía sin lógica mostrar honestamente “En preparación”, no controles que aparenten persistencia.
- Rutas de lista/formulario/detalle con parámetro ID y ruta desconocida segura. Añadir CI Flutter para formato/análisis/test/build debug desde esta fase.

### Entrega a Juan

Rutas y dependencias documentadas, app ejecutable offline sin backend, comandos reproducibles y pruebas de preferencias/navegación. No implementar SQLite ni llenar Inicio con estadísticas que parezcan reales. F01 no cierra sin demostrar que el tema/onboarding sobreviven a reiniciar.

## Fase 2 — Juan: dominio y persistencia fiables

### Responsabilidades

- Implementar las entidades e interfaces de `docs/CONTRATOS.md`; dominio sin imports Flutter/Drift.
- Crear tablas Drift para puntos locales, registros, canjes, borrador y sugerencias; migración de versión y apertura asíncrona. Sembrar solo puntos/recompensas de muestra; cero registros iniciales.
- CRUD completo de registros con validación en dominio, consultas reactivas y errores tipados; ID, fecha de creación y actualización separados.
- Calcular saldo, impacto y nivel desde registros existentes y canjes activos. Transacción atómica de canje/cancelación; reglas de edición con saldo comprometido.
- Probar crear/listar/leer/editar/eliminar, cerrar/reabrir el archivo SQLite, rollback, aislamiento de base de tests y bloqueo de cantidades inválidas.

### Entrega a Brianna

Repositorios concretos conectados a la composición, fixtures reproducibles, migraciones, tests con SQLite real y acceso por casos de uso. La UI anterior sigue compilando. No conectar Supabase ni intentar credenciales. No usar pruebas exclusivamente de mocks como evidencia de persistencia SQLite.

## Fase 3 — Brianna: el flujo que demuestra la mayor parte de la rúbrica

### Responsabilidades

- Flujo Punto → Material → Confirmar con selección manual; formulario con cantidad, fecha/nota y validación.
- Listado persistente, detalle mediante `recordId`, edición precargada y eliminación con confirmación. Mostrar “Registro guardado” solo después de commit SQLite correcto.
- ViewModels con estados explícitos y suscripciones que se liberan. Prevenir doble envío sin bloquear toda la app.
- Guardar borrador al cambiar campos con debounce y al pausar. Recuperar tras reiniciar o volver del background; limpiar solo después de guardar o descartar explícitamente.
- Al navegar atrás con cambios ofrecer guardar borrador/descartar. No depender de que `dispose` o `paused` ocurra al cierre forzado.
- Probar errores de almacenamiento, ID inexistente y actualizaciones en lista tras editar/eliminar.

### Entrega a Adriana

Un recorrido que ya crea, consulta, modifica y elimina registros en modo avión. Evidencia de persistencia al cerrar/abrir y restauración de borrador. Las pestañas y preferencias de F01 siguen funcionando. Debe poder demostrarse el requisito central sin esperar al acabado visual de F04.

## Fase 4 — Adriana: experiencia completa basada en las capturas

### Responsabilidades

- Inicio con saldo simulado, progreso de nivel, impacto estimado y actividad. Actualiza desde streams de SQLite; no desde contadores duplicados.
- Mapa **esquemático local** con lista de puntos, ocupación, selección y CTA que envía `pointId` al formulario. Sin teselas ni GPS necesarios. Etiquetar datos de demostración.
- Premios con filtros, bloqueo por saldo, confirmación, historial y cancelación de canje local; todo persistente y con estados claros.
- Perfil con alias, tema, racha/niveles/insignias derivados, historial y sugerencias locales. No crear una cuenta remota ficticia ni solicitar notificaciones.
- Ranking optativo de muestra sin datos reales y navegación coherente; sugerencias guardadas en SQLite con aviso “Solo en este dispositivo; no se ha enviado”. No fingir respuestas de equipo.
- Verificación visual en tamaños pequeños, scroll, teclado, texto ampliado y estado vacío. Completar en tema oscuro sin romper contraste.

### Entrega a Carla

Cinco pestañas completas y conectadas; cambios CRUD visibles en inicio/perfil, canjes consistentes tras reinicio y datos de ejemplo identificados. Comparación visual con ocho referencias, registrando simplificaciones (mascota, fuente, mapa y cámara manual). Si sobra tiempo, QR/GPS solo como mejora opcional con alternativa manual; nunca sustituye un requisito sin acabar.

## Fase 5 — Carla: validar y entregar el APK

### Responsabilidades

- Ejecutar la matriz completa de `docs/VALIDACION.md`, resolver regresiones y verificar el dominio/arquitectura sin reescribir módulos sanos.
- Completar pruebas de integración del CRUD, prefs, ciclo de vida, canjes y navegación. Una base en memoria no demuestra supervivencia a reinicio: incluir un test en archivo y evidencia en Android.
- Generar APK debug de ensayo, instalarlo en Android/emulador y ejecutar el guion en modo avión. Para APK release configurar firma y claves fuera del repo, verificar certificado y documentar si la firma es solo de pruebas.
- README definitivo con versiones, requisitos, comandos desde clon limpio, arquitectura, roles, límites y enlace real al video cuando exista.
- Capturar video de hasta cinco minutos o preparar la grabación con el equipo; no dar por subido un guion. No publicar a YouTube/Drive sin autorización explícita del owner.
- Preparar intervención técnica de cada integrante y registro Git con sus autores. Comprobar artefacto, hash SHA-256, versión y commit de origen.

### Salida

App instalable, evidencia verificable y todos los criterios trazados. Si no se pudo grabar, publicar, instalar o firmar, consignar exactamente qué falta y por qué; no marcar entrega completa hasta completar esas tareas con el equipo.

## Estimación y estrategia para hoy

Estos tiempos son estimaciones de trabajo supervisado con IA, no promesas: F01 45–90 min; F02 60–120 min; F03 60–100 min; F04 90–150 min; F05 45–90 min. Ruta secuencial aproximada: **5–9 horas**, más descarga de SDK, revisiones, grabación y fallos de entorno. Si quedan menos horas, el equipo debe conocerlo; usar IA no elimina compilación ni verificación.

Orden de recorte si el tiempo aprieta: eliminar ranking elaborado, sugerencias con detalle, mascota original, escáner real/GPS y animaciones. Mantener cinco pestañas sencillas, CRUD completo, preferencias, recuperación de borrador, parámetros, tests esenciales y APK. No recortar Actualizar/Eliminar: son parte explícita del criterio de 6 puntos. No afirmar fidelidad exacta si se aplica este recorte.

Presupuesto mínimo de revisión por relevo: 5–10 min de prueba del flujo anterior, CI y lectura del handoff. Si un entorno nuevo no compila, resolverlo antes de editar. El primer integrante no consume el turno de los demás implementándolo todo.

## Reglas para evitar roturas

- Contratos en `docs/CONTRATOS.md` son compartidos; se puede elegir implementación sencilla compatible. Nada de cinco sistemas de estado distintos: ChangeNotifier + Provider para presentación, repositorios inyectados.
- Versionar `pubspec.lock`, generados Drift necesarios y migraciones según la convención acordada en F02. No versionar builds, SDK o claves.
- Antes de integrar: validar documentos, formato, análisis, tests y APK debug. Los cambios de DB añaden pruebas de migración y reapertura.
- Los tests fallidos bloquean el relevo; corregir en la misma rama. No enviar al próximo compañero un contrato distinto sin documentar.
- Cada fase termina con informe y commit propio. El owner no simula cinco autores desde su máquina.

## Evolución posterior a Unidad II

En un sprint posterior: sesión Supabase con almacenamiento seguro, RLS por usuario, QR de evento firmado emitido por módulo de confianza, GPS con permisos, cola offline persistente, idempotencia y transacciones de servidor; canjes solo en línea y sin datos simulados mezclados con saldos verificados. La presencia de un token no valida por sí sola una sesión sin red. Un QR estático solo identifica un punto, nunca un depósito único.

Esta evolución requiere nuevos PRP y pruebas de backend; no está autorizada como trabajo automático de las cinco fases actuales ni se usa para declarar terminado el APK académico.
