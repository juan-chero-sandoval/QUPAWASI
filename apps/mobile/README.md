# Q'UPA WASI — app móvil

Prototipo Flutter offline de Unidad II. Paquete Android `pe.edu.unp.qupawasi`.

Contexto, contratos y comandos del equipo: [docs/ENTORNO_Y_APK.md](../../docs/ENTORNO_Y_APK.md) y [docs/CONTRATOS.md](../../docs/CONTRATOS.md).

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Estructura: `lib/app` (composición y router), `lib/core` (tema y widgets comunes), `lib/domain` (entidades y contratos, Dart puro), `lib/data` (adaptadores), `lib/presentation` (vistas y ViewModels).
