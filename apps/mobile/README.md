# Q'UPA WASI — app móvil

Prototipo Flutter offline de Unidad II. Paquete Android `pe.edu.unp.qupawasi`.

Contexto, contratos y comandos del equipo: [docs/ENTORNO_Y_APK.md](../../docs/ENTORNO_Y_APK.md) y [docs/CONTRATOS.md](../../docs/CONTRATOS.md).

```powershell
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug
```

Estructura: `lib/app` (composición y router), `lib/core` (tema y widgets comunes), `lib/domain` (entidades y contratos, Dart puro), `lib/data` (adaptadores), `lib/presentation` (vistas y ViewModels).

F02: SQLite/Drift en archivo interno `qupawasi.sqlite`, abierto en isolate nativo. CRUD por `AppDependencies.local.recycling`, estadísticas, premios/canjes locales, borradores y sugerencias. Preferencias de F01 conservadas. La interfaz CRUD visible corresponde a F03: los ejemplos de navegación F01 siguen rotulados como preview, no filas guardadas.

Esquema inicial y triggers en `lib/data/local/schema.drift`; generado `.g.dart` y snapshot `drift_schemas/drift_schema_v1.json` versionados. Si cambia el esquema después de instalar, incrementar versión e implementar/probar migración sin borrar datos.

Para exportar un snapshot tras revisar el esquema:

```powershell
dart run drift_dev schema dump lib/data/local/app_database.dart drift_schemas
```

Pruebas: `flutter test` incluye SQLite real en archivos temporales con reapertura, no solo mocks. Flutter fijo 3.47.8/Dart 3.13.7; dependencias exactas en `pubspec.lock`. APK debug en `build/app/outputs/flutter-apk/app-debug.apk`; no es release firmado de producción.

F03: CRUD visible en `lib/presentation/recycling/` (ViewModels de lista, detalle y formulario con borrador). Prueba de integración en dispositivo:

```powershell
flutter test integration_test -d ID_DEL_DISPOSITIVO
```

Al terminar, `flutter test integration_test` desinstala la app y borra sus datos.
