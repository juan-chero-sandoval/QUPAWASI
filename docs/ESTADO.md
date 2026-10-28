# Estado y siguiente turno

Actualizado: 2026-10-28 tras validar F02. F01 integrada en `develop` por merge commit `2eac7c9`.

- Base remota inspeccionada: `95ac9db6112a4d9cb3d8bdfe141bb49d69c3b46c`, `main`, solo README.
- Cuenta conectada a GitHub: `juan-chero-sandoval`; permisos `admin`, lectura y escritura confirmados por conector.
- Preparación publicada e integrada; ya disponible para todos los colaboradores.
- F01: [PR #2](https://github.com/juan-chero-sandoval/QUPAWASI/pull/2) comprobado con CI de contexto/móvil aprobado y fusionado conservando el commit/autor de Cristopher. [Informe F01](entregas/F01.md).
- F02: commit de Juan `5ac9450`, dominio/casos de uso y persistencia Drift/SQLite; 70 tests aprobados. [CI móvil con APK y artefacto aprobado](https://github.com/juan-chero-sandoval/QUPAWASI/actions/runs/40772687468) y contexto aprobado. APK debug también compilado en Windows; ruta/hash en [informe y API F02](entregas/F02.md). [PR #4](https://github.com/juan-chero-sandoval/QUPAWASI/pull/4), listo para revisión/fusión hacia develop cuando sus checks finales estén verdes. No se declara instalación Android local: ADB unauthorized.
- Unidad II recibida y leída: alcance offline y rúbrica incorporados. No requiere Supabase para estas fases.
- Se debe explicar/confirmar con docente la adaptación de la consigna genérica de MYPE al proyecto UNP ya trabajado.
- Preparación validada: enlaces locales, tres skills con validador oficial, sintaxis YAML/PowerShell y comprobación de espacios. [Registro histórico](entregas/PREPARACION.md). Desde F02 el script móvil genera Drift antes de análisis/test/build.

| Fase | Responsable | Estado | Evidencia |
| --- | --- | --- | --- |
| F01 | Cristhoper | INTEGRADA en develop, CI aprobado | [F01](entregas/F01.md), PR #2 |
| F02 | Juan | IMPLEMENTADA Y VALIDADA; 70 tests y CI/APK aprobados; PR #4 pendiente de integrar | [F02](entregas/F02.md) |
| F03 | Brianna | SIGUIENTE tras integrar PR #4 con merge que preserve autores | [PRP F03](../prps/F03-BRIANNA.md) |
| F04 | Adriana | PENDIENTE F03 integrada | Pendiente |
| F05 | Carla | PENDIENTE F04 integrada | Pendiente |

Cada cierre actualiza esta tabla, añade el informe de fase en `docs/entregas/` y registra su commit y bloqueos reales. Tener permiso en el conector no demuestra las credenciales Git de cada compañero: cada uno las verifica al publicar su rama.
