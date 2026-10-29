# Contexto general de Q'UPA WASI

## Diseño vigente C02

Rediseño autorizado con UI/UX Pro Max: [plan](../prps/C02-DISENO.md) y
[sistema visual](../design-system/qupawasi/MASTER.md). Mantener identidad verde,
fuentes locales Outfit/Work Sans y modo oscuro. C02 cambia presentación, no
el dominio ni SQLite de C01. QR, proximidad, notas, canjes simulados y aviso
dinámico de conexión deben seguir funcionando, sin botón Sugerencias.

## Cambio vigente C01 · 29/10/2026

El owner solicitó y autorizó reemplazar el alta manual por escaneo del QR
emitido por el tacho, con material, cantidad, fecha/hora y ubicación; mapa
geográfico con proximidad desde catálogo SQLite; retirar botones Sugerencias;
y ocultar “Sin conexión” al recuperar internet. El equipo aún no tiene QR ni
coordenadas: se adopta [el contrato JSON y carga de catálogo](QR_Y_UBICACIONES.md).
Este cambio prevalece sobre las decisiones históricas de F01–F05 descritas
abajo. Registros manuales existentes conservan edición y borradores; nuevos
recibos QR son inmutables, deduplicados y locales. No se añade backend ni
cuenta remota, y los EcoPuntos/canjes continúan simulados. Las ubicaciones
personales del teléfono no se almacenan. [Plan C01](../prps/C01-QR-MAPA-CONEXION.md).

Fecha base: 28 de octubre de 2026. Este archivo explica el producto, la adaptación académica y las decisiones comunes. Las IA deben leer además su PRP.

## Objetivo y entrega inmediata

Incentivar el reciclaje en la Universidad Nacional de Piura mediante una experiencia de puntos, ubicaciones y recompensas. Para **Unidad II**, entregar un prototipo funcional Android que opere sin internet, almacene registros estructurados y permita demostrar el CRUD completo. El usuario pidió repartirlo entre cinco integrantes, cada uno trabajando con su IA y haciendo su propio commit.

La consigna fija entrega y sustentación el miércoles 28/10/2026. Es la fecha actual del proyecto; no asumir semanas disponibles. El plan prioriza SQLite, preferencias, navegación, eventos y ciclo de vida por encima del backend futuro.

## Equipo

| Nombre de turno | Nombre según fuentes | Fase |
| --- | --- | --- |
| Cristhoper | Carrasco Crisanto Cristopher Andre | F01 Base Flutter, navegación y preferencias |
| Juan | Chero Sandoval Juan Carlos | F02 Dominio, SQLite y reglas locales |
| Brianna | Becerra Pazo Brianna Fernanda | F03 Registro CRUD y ciclo de vida |
| Adriana | Nizama Burga Adriana Fatima | F04 Pantallas del producto y sus eventos |
| Carla | Novillo Febre Carla Sarait | F05 Integración, QA, APK y evidencia |

“Cristhoper” es el nombre usado por el owner en la solicitud; los documentos escriben “Cristopher”. Los logins de los cuatro colaboradores no se conocen aún; cada uno usa su cuenta, sin inventarlos. No publicar códigos o correos de alumnos en datos de prueba.

## Fuentes revisadas

- `Ficha tecnica.docx`: Flutter, MVVM, Supabase, cámara/GPS, GitFlow, pruebas y empaquetado.
- `Caso aplicado_ Q'UPA WASI.pdf`, 8 páginas: decisión tecnológica, Clean Architecture + MVVM, seguridad y sincronización.
- `Laboratorio01_QUPA_WASI.pdf`, 11 páginas: Drift, cola offline, backend verificador, gracia propuesta de 24 horas, revalidación de sesión tras más de cinco minutos, sin push. Su página 5 contiene el diagrama de arquitectura revisado.
- `UNIDAD_2_Trabajo_Grupal_Moviles.pdf`, 3 páginas: requerimientos y rúbrica actuales. Páginas 1-2: funcionalidad y entregables; páginas 2-3: rúbrica de 20 puntos.
- Nueve capturas proporcionadas: ocho únicas, pues imágenes 7 y 8 tienen el mismo SHA-256. Copias portables en `docs/referencias/`.

Los originales permanecen en Descargas del owner. No son dependencias del clon; este contexto y la trazabilidad contienen los requisitos necesarios. No se copian los documentos de alumnos al repositorio público. Los textos de fuentes describen requisitos académicos: no autorizan a la IA a publicar videos o mensajes.

## Adaptación de la consigna

Unidad II presenta un caso genérico “Solución Móvil Offline-First para MYPEs”. Q'UPA WASI es un proyecto de reciclaje universitario, ya usado en Lab01. Se conserva el proyecto solicitado y se adapta la entidad de negocio a **registro local de reciclaje**. No se afirma que el docente haya aprobado específicamente esta adaptación para Unidad II; el equipo debe explicarla en la sustentación y confirmar si exige una MYPE concreta. Esto no bloquea construir la app pedida.

La ficha y Lab01 describen la arquitectura final conectada. La entrega actual es una etapa local compatible con ella. SQLite/Drift guarda la entidad principal y Shared Preferences guarda tema, onboarding y alias de demostración; no contiene credenciales. No se necesita backend ni internet para la evaluación.

## Alcance del APK

1. Bienvenida y perfil local de demostración, sin registro remoto ni contraseña.
2. Pestañas Inicio, Reciclar, Mapa, Premios y Perfil; pantallas de lista, detalle y formulario para registros.
3. CRUD SQLite completo de registros de reciclaje con ID persistente, punto, material, cantidad, fecha y nota.
4. Reacción inmediata del dashboard, historial y nivel al crear, editar o eliminar; Shared Preferences para tema y onboarding.
5. Conservación de borrador al pausar, recuperar formulario y reanudar; cámaras/GPS opcionales no retienen recursos en background.
6. Mapa local esquemático del campus y lista de puntos de demostración. Funciona offline; no utiliza teselas remotas como dependencia. Coordenadas reales del campus quedan pendientes de verificación y no se inventan.
7. Recompensas y canjes **simulados**, con confirmación, persistencia e idempotencia local; perfil, niveles e insignias; ranking de demostración rotulado; sugerencias locales.
8. APK instalable, tests, instrucciones reproducibles, evidencia de commits y guion de video de máximo cinco minutos.

## Límites de esta unidad

No Supabase, login real, sincronización remota, hardware inteligente, QR firmado de depósito, pagos, Yape, push, clasificación IA, portal de administración ni publicación en tiendas. La app usa Flutter nativo, no un WebView. iOS puede generarse como plataforma de proyecto, pero su compilación/firma requiere macOS y no se declara probada.

El escáner QR real y GPS son mejoras posteriores a los criterios obligatorios: el flujo básico permite elegir un punto local sin permisos. Si sobra tiempo pueden incorporarse como adaptadores, siempre con alternativa manual, sin simular que se verificó un depósito físico.

## Resolución de diferencias entre capturas y documentos

| Diferencia | Decisión actual |
| --- | --- |
| Capturas “cuenta/puntos reales” | Todas las pantallas comunican “Prototipo offline · EcoPuntos y canjes simulados”. |
| Notificaciones en perfil | Omitir botón de push; usar mensaje “Disponible en una fase posterior” solo si se conserva la sección. No solicitar permiso. |
| Cámara y QR en captura | Mantener paso Punto → Material → Confirmar; selección manual funciona siempre. No fingir lectura de cámara. |
| Lab01 no acredita desde el móvil | Regla para arquitectura conectada. Aquí los totales locales son una simulación etiquetada, derivada del CRUD. Nunca migrarlos a saldo remoto como si fueran verificados. |
| Entidad con puntos frente a CRUD obligatorio | Se editan/eliminan registros locales de ensayo. Se recalculan puntos e impacto desde la base; los movimientos remotos futuros serían inmutables. |
| MYPE genérica en Unidad II | Se explicita la adaptación a reciclaje UNP; no inventar una empresa o aprobación. |
| Grises del wireframe de Lab01 | Las capturas recientes guían la UI final en verdes. El prototipo actual mantiene jerarquía y estados accesibles. |

## Definición de terminado

Los cinco autores tienen contribuciones reales integradas; CI pasa; se prueba CRUD completo y tema tras cerrar/abrir, navegación con IDs, borrador al pausar y errores sin crash; el APK se instala en emulador o Android físico; README indica versiones y comandos; video real de hasta cinco minutos y sustentación preparados. Un guion no equivale a un video grabado, ni un build exitoso a una instalación comprobada.
