# Primer turno de Cristhoper

Antes de empezar, el owner debe publicar esta preparación y crear `develop`; ver `docs/FLUJO_EQUIPO.md`. No puede obtenerse por `git pull` un documento que aún no se publicó.

## Tu objetivo

Crear una base Flutter limpia, navegable y con preferencias persistentes, para que Juan pueda implementar SQLite sobre ella. Tu contribución será código real, pruebas y CI. No debes desarrollar las cinco partes.

## Lo que haces tú

1. Clona o actualiza el repo con tu cuenta de colaborador.
2. Comprueba tu nombre/correo Git y que tienes terminal Flutter/Android SDK disponible. Si tu IA solo accede a GitHub, usa un entorno con terminal para compilar y validar; no afirmes que se ejecutó lo que no puede ejecutar.
3. Crea `codex/f01-base-flutter` desde `develop` actualizado.
4. Pega el siguiente mensaje a tu IA.
5. Ejecuta el APK, comprueba el tema tras cerrar/abrir y revisa los cambios; entiende navegación, estado y preferencias.
6. Haz tu commit y push, abre PR hacia `develop` y pasa el turno a Juan cuando se fusione.

## Mensaje listo para pegar

```text
Soy Cristhoper (Cristopher Carrasco), integrante de Q'UPA WASI.
Repo: https://github.com/juan-chero-sandoval/QUPAWASI
Trabaja en el clon y comprueba origin/develop y mi identidad Git existente.
Lee AGENTS.md; docs/CONTEXTO_GENERAL.md; docs/CONTRATOS.md;
docs/FLUJO_EQUIPO.md; docs/ESTADO.md; docs/DISENO.md;
docs/ENTORNO_Y_APK.md y prps/F01-CRISTHOPER.md.
Lee las skills que indique el PRP.
Ejecuta solamente F01 en codex/f01-base-flutter.
Crea la aplicación Flutter en apps/mobile con navegación por IDs,
tema y onboarding persistentes en Shared Preferences, componentes visuales
basados en las capturas, esqueleto de las cinco pestañas y CI Flutter.
No implementes todavía SQLite, backend ni la parte de los otros integrantes.
No cambies los contratos compartidos sin actualizar referencias compatibles.
Ejecuta todas las validaciones y registra resultados reales en
docs/entregas/F01.md y docs/ESTADO.md. Si falta SDK o dispositivo,
resuelve lo posible y reporta el bloqueo, sin decir que el APK fue probado.
Después de revisar las pruebas, crea el commit con mi identidad Git existente,
sin modificar autor ni credenciales, y publica mi rama. No fusiones el PR.
Mensaje de commit: feat: crear base Flutter navegacion y preferencias (F01)
Abre o déjame el enlace para abrir PR hacia develop y entrega el relevo de Juan.
No continúes con F02.
```

Este mensaje es para que Cristhoper lo use en su propia sesión. No autoriza a la sesión del owner a suplantar su cuenta o crear aquí su contribución.
