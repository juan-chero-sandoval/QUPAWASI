# Registro de la preparación del repositorio

Fecha: 2026-10-28. Rama: `codex/plan-equipo-unidad-2`. Este registro corresponde al trabajo de planificación del owner; no sustituye ninguna contribución de implementación de los cinco integrantes.

## Acceso y base comprobados

- Remoto `https://github.com/juan-chero-sandoval/QUPAWASI`, rama principal `main`.
- HEAD inicial y remoto consultado: `95ac9db6112a4d9cb3d8bdfe141bb49d69c3b46c`.
- Conector GitHub autenticado como `juan-chero-sandoval`, admin y push confirmados por consultas de metadata y permiso de colaborador.
- `git fetch origin` completado. Edición local realizada; no se creó commit ni push de esta preparación. No se probó un push real ni la autenticación de los otros colaboradores.

## Material revisado

Se extrajo texto de ficha técnica, caso aplicado, Lab01 y Unidad II. Se revisó visualmente el diagrama de arquitectura de Lab01 y las tres páginas de Unidad II. Las capturas facilitadas se conservaron como ocho archivos únicos; la repetición de las capturas 7/8 se confirmó por SHA-256.

## Verificaciones de los archivos preparados

| Verificación | Resultado |
| --- | --- |
| `python scripts/validar_contexto.py` | Aprobada: archivos requeridos, enlaces relativos, cinco PRP y tres skills |
| Validador oficial `skill-creator/scripts/quick_validate.py` | Aprobadas las tres skills; PyYAML se instaló solo en una carpeta temporal externa para ejecutar esta herramienta |
| Parser PowerShell de `scripts/validar_mobile.ps1` | Sin errores de sintaxis |
| Ejecución del script sin app | Falla de forma esperada y explica que hay que ejecutar F01; no produce éxito falso |
| Parseo YAML del workflow documental | Sintaxis válida y job presente |
| `git diff --check` y revisión de espacios en archivos nuevos | Sin errores |

Las validaciones anteriores comprueban la preparación, no el funcionamiento de una app. No se ejecutó Flutter, no se creó SQLite de producción, no se compiló APK, no se instaló en Android y no se grabó/subió un video. Esas actividades están asignadas a los PRP.

## Relevo

Owner: revisar y publicar esta preparación según el protocolo Git. Después Cristhoper ejecuta F01 con su cuenta e identidad, usando el mensaje de arranque. El contexto completo está dentro del clon y no depende de la carpeta Descargas del owner.
