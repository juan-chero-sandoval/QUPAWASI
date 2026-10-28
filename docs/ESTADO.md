# Estado y siguiente turno

Actualizado: 2026-10-28 tras F03 (rama `codex/f03-crud-ciclo-vida`). F01 integrada por `2eac7c9` y F02 por `ebe30f7` en `develop`.

- Base remota inspeccionada: `95ac9db6112a4d9cb3d8bdfe141bb49d69c3b46c`, `main`, solo README.
- Cuenta conectada a GitHub: `juan-chero-sandoval`; permisos `admin`, lectura y escritura confirmados por conector.
- Preparación publicada e integrada; ya disponible para todos los colaboradores.
- F01: [PR #2](https://github.com/juan-chero-sandoval/QUPAWASI/pull/2) comprobado con CI de contexto/móvil aprobado y fusionado conservando el commit/autor de Cristopher. [Informe F01](entregas/F01.md).
- F02: commit de Juan `5ac9450`, dominio/casos de uso y persistencia Drift/SQLite; 70 tests aprobados. [CI móvil con APK y artefacto aprobado](https://github.com/juan-chero-sandoval/QUPAWASI/actions/runs/40772687468) y contexto aprobado. APK debug también compilado en Windows; ruta/hash en [informe y API F02](entregas/F02.md). [PR #4](https://github.com/juan-chero-sandoval/QUPAWASI/pull/4) fusionado en `develop` (`ebe30f7`) con CI de develop aprobado. No se declara instalación Android local de F02: ADB unauthorized.
- F03: CRUD visible (lista, detalle, crear/editar en 3 pasos, eliminar con confirmación) sobre SQLite, borrador con debounce/flush en lifecycle y restauración. 99 tests, `validar_mobile.ps1` e `integration_test` en emulador API 37 aprobados; M04, M05, M07, M08 y M10 manuales en el emulador. [Informe F03](entregas/F03.md).
- Unidad II recibida y leída: alcance offline y rúbrica incorporados. No requiere Supabase para estas fases.
- Se debe explicar/confirmar con docente la adaptación de la consigna genérica de MYPE al proyecto UNP ya trabajado.
- Preparación validada: enlaces locales, tres skills con validador oficial, sintaxis YAML/PowerShell y comprobación de espacios. [Registro histórico](entregas/PREPARACION.md). Desde F02 el script móvil genera Drift antes de análisis/test/build.

| Fase | Responsable | Estado | Evidencia |
| --- | --- | --- | --- |
| F01 | Cristhoper | INTEGRADA en develop, CI aprobado | [F01](entregas/F01.md), PR #2 |
| F02 | Juan | INTEGRADA en develop (`ebe30f7`), CI aprobado | [F02](entregas/F02.md), PR #4 |
| F03 | Brianna | ENTREGADA en PR hacia `develop`; pendiente de CI y revisión del owner | [F03](entregas/F03.md) |
| F04 | Adriana | SIGUIENTE, cuando F03 esté integrada con CI verde | [PRP F04](../prps/F04-ADRIANA.md) |
| F05 | Carla | PENDIENTE F04 integrada | Pendiente |

Cada cierre actualiza esta tabla, añade el informe de fase en `docs/entregas/` y registra su commit y bloqueos reales. Tener permiso en el conector no demuestra las credenciales Git de cada compañero: cada uno las verifica al publicar su rama.
