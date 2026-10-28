# Q'UPA WASI

Prototipo Android **offline** de reciclaje universitario para la UNP. Unidad II: Flutter/Dart, MVVM, Drift/SQLite con CRUD completo y Shared Preferences. Las capturas de la web son la referencia visual; el APK se construirá con widgets Flutter.

## Empezar

1. [Contexto general](docs/CONTEXTO_GENERAL.md).
2. [Plan detallado de las cinco fases](docs/PLAN_IMPLEMENTACION.md).
3. [Protocolo Git y contribuciones](docs/FLUJO_EQUIPO.md).
4. [PRP por integrante](prps/README.md).

**Turno actual: Juan, F02** (tras integrar F01). Informe de F01: [docs/entregas/F01.md](docs/entregas/F01.md).

## Estado real

Preparación del 28/10/2026 y F01: app Flutter en [`apps/mobile/`](apps/mobile/README.md) con navegación por IDs, tema/onboarding/alias en Shared Preferences, cinco pestañas base y CI móvil. Aún sin SQLite ni CRUD (F02/F03). Consulta [el estado](docs/ESTADO.md).

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
