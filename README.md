# Q'UPA WASI

Prototipo Android **offline** de reciclaje universitario para la UNP. Unidad II: Flutter/Dart, MVVM, Drift/SQLite con CRUD completo y Shared Preferences. Las capturas de la web son la referencia visual; el APK se construirá con widgets Flutter.

## Empezar

1. [Contexto general](docs/CONTEXTO_GENERAL.md).
2. [Plan detallado de las cinco fases](docs/PLAN_IMPLEMENTACION.md).
3. [Protocolo Git y contribuciones](docs/FLUJO_EQUIPO.md).
4. [PRP por integrante](prps/README.md).

**F03: Brianna**, CRUD visible y borradores. El siguiente turno será **Adriana, F04**, cuando F03 esté integrada en `develop`. Informes: [F01](docs/entregas/F01.md), [F02](docs/entregas/F02.md), [F03](docs/entregas/F03.md).

## Estado real

App Flutter en [`apps/mobile/`](apps/mobile/README.md) con navegación por IDs, tema/onboarding/alias en Shared Preferences y cinco pestañas base. F02 añade Drift/SQLite real en archivo, CRUD mediante casos de uso, estadísticas, borradores, sugerencias y canjes simulados atómicos. F03 añade el CRUD visible en Reciclar (lista, detalle, crear/editar en tres pasos y eliminar con confirmación) y borradores que sobreviven al cierre de la app. Inicio, Mapa, Premios, Ranking y Sugerencias quedan para F04. Consulta [el estado](docs/ESTADO.md).

Unidad 2 fue revisada: al menos tres pantallas, parámetros, eventos, estado, ciclo de vida, Shared Preferences, CRUD SQLite, commits de los cinco, video de máximo cinco minutos y sustentación. [Cobertura de rúbrica](docs/TRAZABILIDAD.md).

## Estructura

| Ruta | Contenido |
| --- | --- |
| `AGENTS.md` | Instrucciones para cualquier IA del equipo |
| `docs/` | Contexto, plan, contratos, diseño, QA y entregas |
| `prps/` | Especificaciones ejecutables F01 a F05 |
| `.agents/skills/` | Skills compartidas; lectura manual si la IA no las descubre |
| `docs/referencias/` | Ocho capturas únicas recibidas |
| `scripts/` | Validaciones documentales y móviles |
| `.github/` | CI de preparación y plantilla de PR |

Validación de esta preparación: `python scripts/validar_contexto.py`.

Después de F01, desde la raíz: `pwsh -File scripts/validar_mobile.ps1` o `powershell -File scripts/validar_mobile.ps1`.

Los comandos finales de instalación y compilación están en [entorno](docs/ENTORNO_Y_APK.md); deben actualizarse con las versiones realmente usadas. Los puntos y canjes son simulados en este prototipo. No se integra Supabase, pagos ni push para Unidad II.
