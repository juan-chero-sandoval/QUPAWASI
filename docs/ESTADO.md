# Estado y siguiente turno

## Diseño C02

En trabajo local en `codex/f05-diseno-c02`, conservando C01 sin commit/push.
Skill UI/UX Pro Max instalada y aplicada desde `.agents/skills/ui-ux-pro-max/`.
[Plan C02](../prps/C02-DISENO.md), [sistema visual](../design-system/qupawasi/MASTER.md).
Rediseño de las cinco secciones, bienvenida, componentes y fuentes locales.
Validación de layout y accesibilidad en curso; no declarar APK/Android aún.

## Corrección C01 posterior a F05

Implementada localmente en `codex/f05-qr-mapa-conexion`: QR del tacho,
catálogo SQLite con mapa/proximidad, retiro de botones Sugerencias y conexión
dinámica. [Plan](../prps/C01-QR-MAPA-CONEXION.md),
[contrato QR/catálogo](QR_Y_UBICACIONES.md), [entrega](entregas/C01.md).
La solicitud del owner sustituye el alta manual y el aviso offline fijo de
las fases originales. 150 tests/análisis/build debug y cuatro integraciones
Android offline aprobados, con resultados reales en la entrega;
no confundir este trabajo local con una integración publicada en GitHub.

Actualizado el 29/10/2026 tras verificar e integrar las cinco fases. F05 de Carla, [PR #9](https://github.com/juan-chero-sandoval/QUPAWASI/pull/9), integrada en develop por merge `20fbc52b8a7f00718448b20b31cb817990f02014`, conservando sus commits. Código `c367b2e` y corrección visual `1cb94a3`; 117 tests/análisis/build y [CI móvil con tres integraciones Android aprobados](https://github.com/juan-chero-sandoval/QUPAWASI/actions/runs/40823391705) sobre head `a4cfe5f`. [Informe F05](entregas/F05.md) distingue automatización y manuales. El código queda preparado para integrar develop en main; video real y sustentación siguen pendientes.

- Base remota inspeccionada: `95ac9db6112a4d9cb3d8bdfe141bb49d69c3b46c`, `main`, solo README.
- Cuenta conectada a GitHub: `juan-chero-sandoval`; permisos `admin`, lectura y escritura confirmados por conector.
- Preparación publicada e integrada; ya disponible para todos los colaboradores.
- F01: [PR #2](https://github.com/juan-chero-sandoval/QUPAWASI/pull/2) comprobado con CI de contexto/móvil aprobado y fusionado conservando el commit/autor de Cristopher. [Informe F01](entregas/F01.md).
- F02: commit de Juan `5ac9450`, dominio/casos de uso y persistencia Drift/SQLite; 70 tests aprobados. [CI móvil con APK y artefacto aprobado](https://github.com/juan-chero-sandoval/QUPAWASI/actions/runs/40772687468) y contexto aprobado. APK debug también compilado en Windows; ruta/hash en [informe y API F02](entregas/F02.md). [PR #4](https://github.com/juan-chero-sandoval/QUPAWASI/pull/4) fusionado en `develop` (`ebe30f7`) con CI de develop aprobado. No se declara instalación Android local de F02: ADB unauthorized.
- F03: CRUD visible (lista, detalle, crear/editar en 3 pasos, eliminar con confirmación) sobre SQLite, borrador con debounce/flush en lifecycle y restauración. 99 tests, `validar_mobile.ps1` e `integration_test` en emulador API 37 aprobados; M04, M05, M07, M08 y M10 manuales en el emulador. [Informe F03](entregas/F03.md).
- F04: Inicio/Perfil reactivos, esquema local por UUID, catálogo/canjes/cancelación con recuperación idempotente, ranking ficticio y sugerencias SQLite. Validación local: 114 tests, análisis/build debug, integración Android F03 y F04, layout con scroll/texto 2× y accesibilidad automática. Canje/sugerencia comprobados con force-stop en modo avión. [Informe F04](entregas/F04.md), [descripción preparada del PR](entregas/F04-PR.md). [PR #7](https://github.com/juan-chero-sandoval/QUPAWASI/pull/7), implementación `79d4d4d` de Adriana; [CI móvil con APK aprobada](https://github.com/juan-chero-sandoval/QUPAWASI/actions/runs/40790805913) y contexto aprobado sobre la implementación. Integrada mediante merge `f18b8dc`; este cierre solo completa documentación.
- Unidad II recibida y leída: alcance offline y rúbrica incorporados. No requiere Supabase para estas fases.
- Se debe explicar/confirmar con docente la adaptación de la consigna genérica de MYPE al proyecto UNP ya trabajado.
- Preparación validada: enlaces locales, tres skills con validador oficial, sintaxis YAML/PowerShell y comprobación de espacios. [Registro histórico](entregas/PREPARACION.md). Desde F02 el script móvil genera Drift antes de análisis/test/build.

| Fase | Responsable | Estado | Evidencia |
| --- | --- | --- | --- |
| F01 | Cristhoper | INTEGRADA en develop, CI aprobado | [F01](entregas/F01.md), PR #2 |
| F02 | Juan | INTEGRADA en develop (`ebe30f7`), CI aprobado | [F02](entregas/F02.md), PR #4 |
| F03 | Brianna | INTEGRADA en develop (`1fed2b2`), PR #6 | [F03](entregas/F03.md), commit `1088394` |
| F04 | Adriana | INTEGRADA en develop (`f18b8dc`), PR #7; implementación `79d4d4d`, CI aprobada | [F04](entregas/F04.md) |
| F05 | Carla | INTEGRADA en develop (`20fbc52`), PR #9; contexto, APK e integración Android aprobados | [F05](entregas/F05.md) |

Cada cierre actualiza esta tabla, añade el informe de fase en `docs/entregas/` y registra su commit y bloqueos reales. Tener permiso en el conector no demuestra las credenciales Git de cada compañero: cada uno las verifica al publicar su rama.


El cierre original F05 se integró en main por [PR #10](https://github.com/juan-chero-sandoval/QUPAWASI/pull/10), merge `4494e7ac8cf44b9c4223794eec860138f79318f9`, conservando autores. El siguiente trabajo de repositorio es revisar y publicar C01 desde su rama hacia develop, cuando el owner lo indique. Carla/equipo aún completan video ≤5 minutos/enlace autorizado y sustentación. No hay F06 ni publicación externa automática. El APK histórico local 0.2.0+2 tenía SHA-256 `ed1cb2e0735af9853bb8c3c341e1b375e8fb2de33ab1cc24fd53e0b4a9e76a92`; el nuevo APK y su firma están en la entrega C01. La integración del código no certifica la entrega académica completa ni una firma de producción.
