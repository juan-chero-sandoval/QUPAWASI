# F01 — Cristhoper — Base Flutter y preferencias

## Objetivo y prerrequisitos

Dejar una app Android Flutter que abra sin internet, con navegación robusta, componentes visuales y Shared Preferences comprobadas. Primer turno del equipo. No hay código Flutter inicial: debes crearlo sin sustituir el contexto del repo.

Responsable: Cristhoper (Cristopher Carrasco). Rama: `codex/f01-base-flutter`, desde `develop` con esta preparación integrada. No hacer F02.

Lee [contexto](../docs/CONTEXTO_GENERAL.md), [contratos](../docs/CONTRATOS.md), [diseño](../docs/DISENO.md), [entorno](../docs/ENTORNO_Y_APK.md), [flujo Git](../docs/FLUJO_EQUIPO.md) y [estado](../docs/ESTADO.md). Skills: `../.agents/skills/qupawasi-fase/SKILL.md` y `../.agents/skills/qupawasi-ui/SKILL.md`.

## Entradas y salida

Entradas: repositorio solo preparado, capturas en docs/referencias, Flutter/Android a comprobar. Salida: `apps/mobile/` compilable, tests, CI, preferencias persistentes y puntos de composición para repositorios de F02.

No implementar SQLite, servidor, canjes definitivos ni CRUD de otros integrantes. Para pantallas pendientes usar datos de preview identificados o estados “En preparación”; esos valores no se presentan como datos guardados.

## Implementación por pasos

1. Ejecutar `git status`, comprobar remoto, rama/identidad y `flutter doctor -v`. Resolver SDK/Android necesarios; documentar versiones reales. Si el SDK no puede instalarse, no simular resultados.
2. Crear el proyecto según entorno; fijar applicationId/namespace, etiqueta Q'UPA WASI y versión inicial. Conservar archivos docentes. Retirar contador/ejemplo generado por Flutter.
3. Crear capas `app`, `core`, `domain`, `data`, `presentation` con archivos reales necesarios. No llenar carpetas vacías con cientos de `.gitkeep`. Añadir Provider, go_router, shared_preferences y lints compatibles; versionar lockfile.
4. `PreferencesRepository` y adaptador Shared Preferences: lectura asíncrona, claves versionadas, tema system/light/dark, onboardingCompleted y alias local. Modelos simples de dominio; ningún password/token. Inicializar antes de decidir bienvenida/home sin flicker innecesario ni espera infinita.
5. Crear tokens semánticos, componentes comunes y tema oscuro. Usar fuentes/iconos disponibles offline. Copiar referencia visual por widgets, no como fondo rasterizado de toda pantalla. Añadir aviso uniforme de prototipo simulado.
6. Implementar bienvenida con tres pasos, botón Empezar, aviso local/privacidad sencillo. Completar onboarding persiste y luego navega; al reabrir va a Inicio. Mostrar explicación de datos: todo local en el dispositivo en esta unidad.
7. Router con cinco pestañas y rutas auxiliares del contrato. Permitir abrir un detalle de preview con un ID serializable y mostrarlo; si aún no hay repositorio, dejar adaptador de preview explícito. Probar paso de argumento sin asumir entidad en memoria; F03 conecta a SQLite. Rutas desconocidas/IDs inválidos tienen vista segura y botón de retorno.
8. Inicio y Perfil: bases visuales coherentes con capturas, con vistas/componentes separables para datos reales posteriores. Perfil permite cambiar tema y alias; no requerir login. Los otros tres destinos tienen encabezado, aviso y CTA navegación sin fingir funcionalidad no implementada.
9. Crear `.github/workflows/mobile.yml` con versión Flutter efectiva fija, pub get, formato/analyze/test/build debug, subida artefacto; paths correctos `apps/mobile`. Mantener CI documental. No exigir secretos ni SDK móvil en el repo.
10. Tests de preferencias con reconstrucción de repositorio; widgets/rutas con parámetros, selección de pestaña, bienvenida y tema. Completar informe y estado con comandos exactos.

## Archivos de propiedad del turno

`apps/mobile` inicial; tema/componentes/router/composición; repositorio de preferencias; tests iniciales; workflow móvil. Puedes actualizar docs para reflejar versiones/rutas reales. No modificar reglas de puntos del contrato, ni desarrollar flujo de reciclaje persistente.

## Validación

Desde raíz: `python scripts/validar_contexto.py`, `git diff --check`, `powershell -File scripts/validar_mobile.ps1`. Desde app: `flutter run -d ID_REAL` y realizar M01–M03 de validación. Revisar al menos tamaño 360 dp y texto ampliado con scroll. En CI verificar que el APK debug se produjo; en local identificar variante/dispositivo.

## Aceptación obligatoria

- [ ] Clon preparado crea/compila app sin credenciales ni backend.
- [ ] Cinco pestañas y más de tres pantallas accesibles, back Android coherente.
- [ ] Ruta recibe un ID real de prueba como argumento y hay fallback para ruta inválida.
- [ ] Bienvenida no reaparece tras completar y reiniciar proceso.
- [ ] Tema/alias se recuperan desde Shared Preferences después de cerrar y abrir.
- [ ] Lógica de preferencias fuera de widgets; views y ViewModels separados.
- [ ] UI sin overflow evidente y mensaje de simulación visible.
- [ ] Formato/analyze/test/build debug aprobados o bloqueo concreto registrado; no declarar entrega lista con un build faltante.
- [ ] Informe `docs/entregas/F01.md`, versiones y `docs/ESTADO.md` actualizados.

## Commit y relevo

Mensaje: `feat: crear base Flutter navegacion y preferencias (F01)`. Autor: identidad del integrante, no la del owner ni un autor inventado. PR hacia `develop`. Juan recibe router, composición, versiones/lockfile, modo de inyectar su DB y pruebas existentes. No continuar a F02.

## Prompt para la IA

> Soy Cristhoper. Ejecuta solo prps/F01-CRISTHOPER.md en codex/f01-base-flutter desde develop actualizado. Lee AGENTS.md y los documentos/skills indicados. Implementa base Flutter, navegación/argumentos, UI común y preferencias persistentes. Verifica en Android y con tests. Conserva los contratos, registra resultados reales y prepara mi commit/PR. No hagas SQLite ni el turno de Juan. Usa mi identidad Git existente; no la modifiques ni publiques con la cuenta de otro.
