# Entorno de desarrollo y compilación del APK

## Antes de F01

En la máquina revisada no se detectaron `flutter` ni `dart` en PATH. No se descargó un SDK durante la preparación. Cada IA debe verificar su entorno real; no copiar versiones supuestas.

Instalar Flutter estable y su SDK Dart, Android Studio/Android SDK, herramientas de plataforma y un emulador o teléfono con depuración USB. La documentación oficial explica [la preparación Android](https://docs.flutter.dev/platform-integration/android/setup). Instalar únicamente el plugin de Flutter de Android Studio no instala el SDK Flutter.

Ejecutar:

```powershell
flutter --version
flutter doctor -v
flutter doctor --android-licenses
flutter devices
```

Resolver lo que impida Android; no hace falta toolchain Windows desktop para construir el APK. F01 registra versiones efectivas Flutter, Dart, Java, Gradle/AGP, compileSdk/minSdk y Android de prueba en su entrega, y fija la versión Flutter del workflow. No usar `latest` diferente en cada equipo. El lockfile y el template generado por ese SDK ayudan a mantener compatibilidad.

## Crear el proyecto — solo F01

Desde raíz, sin recrear encima de una app existente:

```powershell
flutter create --platforms=android --org pe.edu.unp --project-name qupa_wasi apps/mobile
cd apps/mobile
flutter pub get
flutter run
```

La combinación inicial de org/nombre puede generar un applicationId distinto; F01 fija y documenta el propuesto `pe.edu.unp.qupawasi`, ajustando namespace y MainActivity coherentemente. No cambiarlo en fases posteriores sin necesidad. Si iOS se añade, debe hacerse explícitamente y sin afirmar compilación probada desde Windows.

F01 añade Provider, go_router y shared_preferences en versiones compatibles consultando sus fuentes oficiales. F02 añade Drift, sqlite3 y generadores/runner necesarios según la versión fijada. No instalar plugins QR/GPS ni Supabase que no usará la unidad. Guardar `pubspec.lock`.

## Verificación desde el clon

```powershell
python scripts/validar_contexto.py
powershell -File scripts/validar_mobile.ps1
```

El segundo comando falla deliberadamente si no existe app o Flutter, y ejecuta dependencias, formato en modo comprobación, análisis, tests y build debug. Tras F02, generar Drift antes de la comprobación si hay cambios de tablas:

```powershell
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs
dart format lib test integration_test
flutter analyze
flutter test
flutter test integration_test -d ID_DEL_DISPOSITIVO
```

La carpeta `integration_test` y sus pruebas se crean en F03/F05; no ejecutar ese comando antes de que existan. Sustituir el ID por uno de `flutter devices`, no copiar literalmente. Formatear cambia archivos: revisar el diff antes del commit. El script de validación solo verifica formato.

## APK de prueba

Desde `apps/mobile`:

```powershell
flutter build apk --debug
flutter install --debug -d ID_DEL_DISPOSITIVO
```

Salida esperada: `apps/mobile/build/app/outputs/flutter-apk/app-debug.apk` desde la raíz del repo. Es un instalable de prueba con firma debug, no un release de producción. Probar modo avión, reinicio y persistencia con ese mismo paquete; reinstalar con limpieza o borrar datos elimina la base y no sirve como prueba de supervivencia.

## APK release — F05

Seguir [la guía oficial de empaquetado y firma Android](https://docs.flutter.dev/deployment/android). Crear keystore **fuera del repo** y configurar `key.properties` ignorado o variables/secretos CI. No imprimir claves. Verificar que el build release no esté usando accidentalmente el certificado debug si se presenta como release firmado de entrega.

```powershell
flutter build apk --release
```

Salida esperada: `apps/mobile/build/app/outputs/flutter-apk/app-release.apk`. Verificar certificado con `apksigner verify --print-certs RUTA_APK` desde las build-tools del Android SDK instalado y SHA-256 con `Get-FileHash -Algorithm SHA256 RUTA_APK`. Instalar la variante generada y repetir smoke test. Un cambio de certificado puede impedir actualizar sobre debug; si es preciso desinstalar para probar release, hacer antes la prueba de persistencia sin desinstalar y documentarlo.

No añadir APK, keystore o build al commit. La entrega puede usar artefactos de Actions o carpeta externa elegida por el equipo. No se requiere Play Store. Si no se configuró firma release, entregar debug claramente identificado y registrar la limitación; no afirmar que está firmado para producción.

## CI

La CI actual verifica el paquete documental. F01 crea el workflow móvil con checkout, Flutter fijo, caché, pub get, formato/analyze/test/build debug y subida del APK como artefacto de ensayo. F02 incorpora generación Drift; F05 añade integración en emulador si el entorno lo permite. Permisos mínimos `contents: read`; los PR no necesitan secretos. Un workflow verde solo demuestra los pasos que ejecutó; no sustituye prueba de dispositivo ni video real.
