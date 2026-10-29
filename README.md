# Q'UPA WASI

Prototipo Android offline de reciclaje universitario UNP para Unidad II. **EcoPuntos y canjes simulados**, sin dinero, depósito verificado, login remoto ni backend. Cinco pestañas, CRUD de registros locales, borradores, preferencias y sugerencias persistentes.

## Ejecutar desde un clon limpio

Instalar Flutter **3.47.8** (Dart **3.13.7**), Java 21 y Android SDK; configurar sus rutas según [entorno/APK](docs/ENTORNO_Y_APK.md). Desde la raíz:

```powershell
python scripts/validar_contexto.py
powershell -File scripts/validar_mobile.ps1
cd apps/mobile
flutter devices
flutter test integration_test -d emulator-5554 --no-pub
flutter build apk --debug
flutter install --debug -d emulator-5554
```

Sustituir `emulator-5554` por el ID disponible. El script ejecuta pub get, generación Drift, formato, análisis, tests y build. Manualmente: `flutter pub get --enforce-lockfile`, `dart run build_runner build`, `dart format --output=none --set-exit-if-changed lib test integration_test`, `flutter analyze`, `flutter test`. La compilación descarga dependencias; **el recorrido instalado funciona en modo avión**.

Las integraciones deben ejecutarse en un emulador dedicado **sin datos personales**: instalan su app de prueba y al terminar la desinstalan. Después instalar el APK normal y probar persistencia con forzar detención y reabrir, sin reinstalar ni borrar datos. [Casos M01–M15](docs/VALIDACION.md), [resultados F05](docs/entregas/F05.md).

## Versiones fijadas

| Componente | Versión |
| --- | --- |
| App / applicationId | 0.2.0+2 / `pe.edu.unp.qupawasi` |
| Flutter / Dart | 3.47.8 / 3.13.7 |
| Gradle / AGP / Kotlin | 9.3.1 / 9.1.0 / 2.4.0 |
| Android min / compile / target | 24 / 36 / 36 |
| Drift / sqlite3 | 2.35.3 / 3.8.0 |
| Shared Preferences / Provider / go_router | 2.5.6 / 6.1.5+1 / 18.1.1 |
| drift_dev / build_runner | 2.35.2 / 2.17.1 |

`apps/mobile/pubspec.lock` conserva todas las versiones y hashes. Java de CI: Temurin 21; el entorno local efectivo se registra en F05. APK debug: `apps/mobile/build/app/outputs/flutter-apk/app-debug.apk`; hash, certificado y prueba de instalación en F05. No se versionan binarios ni claves. La configuración release heredada usa firma debug; **no es firma de producción**.

## Arquitectura y datos

`apps/mobile/lib/app` compone dependencias y rutas por IDs; `presentation` contiene vistas y ViewModels (Provider/ChangeNotifier); `domain` contiene entidades, políticas y casos de uso Dart puros; `data` implementa repositorios. Las vistas no abren SQLite.

Drift abre `qupawasi.sqlite` en soporte interno mediante isolate. La entidad CRUD es el **registro local de reciclaje** (UUID, punto, PET/aluminio, cantidad 1..100, fecha y nota). PET 2 → editar PET 3 conserva una fila y cambia 20 → 30 puntos; eliminar devuelve cero sin canjes. Los canjes se guardan aparte, son idempotentes y bloquean borrar/editar si se compromete el saldo. Cancelarlos libera puntos una vez. Borradores y sugerencias también viven en SQLite. [Contratos](docs/CONTRATOS.md).

Shared Preferences guarda tema, alias, onboarding y confirmación pendiente de canje; el saldo y el historial permanecen en SQLite. El formulario guarda incrementalmente y al pausar; un cierre antes del debounce puede perder el último cambio aún no confirmado.

## Contribuciones verificables

| Fase | Autor de implementación | Evidencia |
| --- | --- | --- |
| F01 | Cristopher Carrasco (`CRISTOPHER`) | [PR #2](https://github.com/juan-chero-sandoval/QUPAWASI/pull/2), commit `291881e`, [informe](docs/entregas/F01.md) |
| F02 | Juan Chero | [PR #4](https://github.com/juan-chero-sandoval/QUPAWASI/pull/4), commit `5ac9450`, [informe](docs/entregas/F02.md) |
| F03 | Brianna Becerra | [PR #6](https://github.com/juan-chero-sandoval/QUPAWASI/pull/6), commit `1088394`, [informe](docs/entregas/F03.md) |
| F04 | Adriana Nizama | [PR #7](https://github.com/juan-chero-sandoval/QUPAWASI/pull/7), commit `79d4d4d`, [informe](docs/entregas/F04.md) |
| F05 | Carla Novillo | [informe y QA](docs/entregas/F05.md); commit/PR finales se registran en la descripción del PR |

Los commits se conservan sin squash ni atribuciones artificiales. Los dos commits documentales de cierre F04 firmados por Carla no sustituyen su contribución técnica F05.

## Entrega académica

[Estado](docs/ESTADO.md), [rúbrica y trazabilidad](docs/TRAZABILIDAD.md), [guion de hasta cinco minutos](docs/VIDEO_Y_SUSTENTACION.md). El video real y su enlace siguen pendientes; un guion no acredita U2-11. No se ha publicado en Drive, YouTube ni tiendas.

Mapa esquemático local sin coordenadas verificadas; mascota con widgets y selección manual de punto, sin lector QR real. Impacto sin factores validados: “Estimación no configurada”. Ranking ficticio. La consigna genérica MYPE se adapta al reciclaje UNP trabajado en Lab01; el equipo debe explicarlo y confirmar aceptación docente. No se declara iOS, TalkBack ni teléfono físico probado.
