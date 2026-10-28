# F05 — Carla — QA, APK y evidencia de entrega

## Objetivo y prerrequisitos

Verificar el prototipo completo, corregir regresiones y entregar APK instalable con instrucciones y evidencia académica real. Responsable Carla, rama `codex/f05-qa-apk-entrega`, desde develop con F01–F04 integradas. No dar por verificada una función solo porque otro informe la declara lista.

Lee [contexto](../docs/CONTEXTO_GENERAL.md), [contratos](../docs/CONTRATOS.md), [trazabilidad](../docs/TRAZABILIDAD.md), [validación](../docs/VALIDACION.md), [entorno/APK](../docs/ENTORNO_Y_APK.md), [guion](../docs/VIDEO_Y_SUSTENTACION.md), [flujo](../docs/FLUJO_EQUIPO.md) y [estado](../docs/ESTADO.md). Skills fase, ui y sqlite en `../.agents/skills/`. Leer los cuatro handoffs previos.

## Alcance

Correcciones comprobables, pruebas de integración/QA, empaquetado, documentación y preparación de video/sustentación. Esta debe ser una contribución técnica real: automatización de integración y/o corrección de regresiones, no solo README. No reescribir la app ni ampliar a backend para llenar tiempo.

## Implementación por pasos

1. Actualizar develop y revisar que existen cuatro contribuciones reales previas y sus PR. No fabricar autores si falta una. Ejecutar baseline de scripts, registrar versiones y cualquier fallo antes de cambiar código.
2. Añadir/terminar integración completa: modo offline, crear PET2, leer detalle con ID, cerrar/reabrir repositorios o app según test, editar PET3, verificar una fila/30 puntos, borrar y verificar vacío. Compartir helpers de test sin reemplazar la DB por mocks en todo el recorrido.
3. Cubrir preferencias tras reconstrucción, borrador tras background/reinicio, ID inexistente, cantidad inválida, doble tap, canjes y cancelación. No depender solo de estado en memoria para simular un relanzamiento de app. Si integration_test no permite matar/reabrir el mismo proceso cómodamente, usar test en archivo para automatizar DB y completar el caso de proceso nuevo de forma manual en Android.
4. Ejecutar M01–M15 en dispositivo/emulador y registrar resultado individual. Corregir causas concretas sin alterar contratos innecesariamente. Cada corrección añade prueba de regresión cuando sea útil. No borrar tests ni ocultar un error con un catch vacío.
5. QA visual de pantallas principales a tamaños objetivo, tema oscuro, texto ampliado/teclado/back Android. Contrastar con referencias; corregir desbordamientos y controles inaccesibles. Registrar simplificaciones del mapa/mascota/QR sin afirmar fidelidad exacta si no existe.
6. Revisar CI desde clon limpio: generación Drift, formato/analyze/test y APK debug. Si se puede, añadir emulador para integración en Actions; si no, documentar prueba Android local con evidencia. Mantener permisos mínimos y claves fuera del repo.
7. Construir APK debug, instalar y ejecutar recorrido en modo avión; verificar nombre/versión/applicationId y persistencia al forzar detención sin desinstalar. Documentar ruta y hash, no añadir binario al commit.
8. Preparar release según guía de firma, con keystore fuera de repo. Si se configura, verificar certificado e instalar esa variante. Distinguir firma de pruebas y de producción; un build release firmado con debug no se presenta como producción. Si falta firma/entorno, entregar debug identificado y registrar la limitación sin inventar release.
9. README final: propósito, demo offline, stack y versiones exactas, SDK/Java/Android, pasos desde clon limpio, pub get/generación/tests/build/install, arquitectura, entidad CRUD, preferencias, autores/PR y límites. Completar trazabilidad con archivos/tests reales.
10. Preparar y ayudar a grabar video máximo cinco minutos según guion. La grabación necesita UI real; subirlo a Drive/YouTube únicamente cuando el owner lo autorice o lo haga el equipo. Guardar enlace accesible/duración si existe; de lo contrario dejar pendiente explícito con responsable. El guion no cumple por sí solo U2-11.
11. Cada integrante prepara su explicación; capturar Git log/shortlog de los cinco. Resolver diferencia entre caso genérico MYPE y proyecto UNP de forma transparente. Actualizar informe F05 y estado con qué se probó y qué falta.

## Aceptación final

- [ ] Formato/analyze/tests/build debug pasan desde checkout limpio.
- [ ] CRUD completo y asíncrono sobre SQLite se demuestra después de cerrar/abrir.
- [ ] Preferencias y borrador sobreviven; navegar con parámetros funciona.
- [ ] Puntos, edición/eliminación y canjes no generan duplicados ni saldo negativo.
- [ ] No hay dependencia de red para el flujo académico; no hay credenciales ni datos personales reales en repo.
- [ ] APK debug instalado, identificado por commit/version/hash y probado en Android.
- [ ] Variante release/firma claramente documentada si se produjo; no confundirla con debug.
- [ ] README reproducible, matriz cubierta y cinco autores reales evidenciados.
- [ ] Video real de hasta cinco minutos y enlace accesible completados por el equipo; si pendiente, entrega académica aún incompleta.
- [ ] Sustentación preparada y cada integrante puede explicar su código.

## Commit y entrega

Mensaje: `test: validar prototipo offline y preparar APK de entrega (F05)`. PR a develop con identidad de Carla. Adjuntar informe `docs/entregas/F05.md`, tests/correcciones y links reales. Owner revisa y realiza PR develop → main conservando los cinco commits. No publicar en tiendas ni fusionar automáticamente sin el flujo del equipo.

No declarar “todo listo” si todavía falta instalación, video, contribución de alguien o un criterio de la rúbrica. Puedes terminar trabajo de código con una lista de acciones externas pendientes y sus responsables, sin afirmar entrega académica completa.

## Prompt para la IA

> Soy Carla. Ejecuta solo prps/F05-CARLA.md en codex/f05-qa-apk-entrega desde develop actualizado. Lee handoffs y matriz de rúbrica. Añade integración real, prueba SQLite/prefs/CRUD/ciclo de vida, corrige regresiones y valida en Android. Compila e identifica el APK, actualiza README/versiones/trazabilidad y prepara evidencia y guion del video. No inventes instalación, firma, enlaces o tests ejecutados; indica lo pendiente. No publiques a Drive/YouTube ni a tiendas sin autorización. Prepara mi commit/PR con mi identidad existente y conserva los otros cuatro autores.
