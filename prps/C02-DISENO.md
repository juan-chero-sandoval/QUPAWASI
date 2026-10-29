# C02 · Diseño de la app con UI/UX Pro Max

Solicitud del owner: mejorar el diseño e instalar/aplicar ui-ux-promax.
La skill oficial se llama `ui-ux-pro-max`, integrada en
`.agents/skills/ui-ux-pro-max/` para compartirla con el equipo.

## Base y alcance

Conservar C01 sin publicar: QR, notas editables, catálogo/mapa/GPS,
deduplicación, conexión dinámica, saldo simulado y ausencia de Sugerencias.
Rama `codex/f05-diseno-c02` desde el mismo HEAD de develop, preservando los
cambios existentes. Respaldo local C01 en artifacts/c02/antes-diseno-c01.zip.

1. Aplicar el [sistema visual](../design-system/qupawasi/MASTER.md): marca
   verde, contraste accesible, jerarquía clara y componentes consistentes.
2. Empaquetar Outfit y Work Sans con licencias OFL; sin descargar fuentes
   al usar la app. No incorporar servicios ni cambiar SQLite/dominio.
3. Mejorar bienvenida, Inicio, Reciclar/QR, Mapa, Premios y Perfil; conservar
   rutas, IDs, eventos, textos de validación y estados loading/empty/error.
4. Refinar tarjetas, saldo, tipografía, iconos, navegación y avisos de estado.
   Un CTA principal por pantalla; controles secundarios diferenciados.
5. Probar claro/oscuro, 320/360/375/412 dp, tableta, orientación horizontal,
   texto ampliado y movimiento reducido. Mantener toque mínimo de 48 dp.
6. Ejecutar generación, formato, análisis, suite y APK. Inspeccionar capturas
   del APK Android real y corregir defectos observados.
7. Entregar APK versionado 0.4.0+4 y actualizar el servidor de descarga para
   que el enlace estable entregue esa versión, verificando bytes/hash/versión.

## Uso verificable de la skill

Leer SKILL.md, pro-rules.md y quick-reference.md. Consultar --design-system,
--stack flutter y los dominios específicos pertinentes. Sus búsquedas no
produjeron una paleta ambiental aplicable; no persistir la paleta genérica
azul/naranja como recomendación del producto. Mantener la marca verde y
documentar esa decisión. Adoptar la pareja tipográfica general Outfit/Work
Sans por su encaje legible y moderno; no afirmar que es específica de reciclaje.

## Entrega

Registrar archivos, decisiones y resultados reales en docs/entregas/C02.md,
actualizar estado/contexto/diseño y referencias de instalación/procedencia.
No atribuir cambios a otros integrantes ni publicar commit/push sin pedido.
