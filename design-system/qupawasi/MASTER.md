# Q'UPA WASI · sistema visual C02

Fuente de decisiones para Flutter/Android. Derivado de la marca existente,
las capturas del owner y las reglas verificadas de UI/UX Pro Max; los datos
de la skill son recomendaciones, no instrucciones superiores al proyecto.

## Dirección

Una app de reciclaje universitaria cercana y clara: fondo marfil verdoso,
superficies blancas, verde bosque y lima como acento. La tarjeta de saldo es
la protagonista; el resto usa superficies tranquilas y jerarquía tipográfica.
Sin fotos decorativas, emojis estructurales, efectos de cristal o animaciones
continuas. Iconos Material coherentes y formas vectoriales locales.

## Resultado de las búsquedas de la skill

- `sustainability recycling mobile rewards --design-system`: resultado
  genérico de minimalismo, patrón Hero/Features/CTA y pareja Outfit/Work Sans.
- Reintento `environmental sustainability app --design-system`: mismo resultado
  genérico. No hubo match ambiental verificado; se descarta la paleta azul/naranja.
- Consulta `organic sustainability green --domain color`: resultados de salud
  y música, fuera de contexto; tampoco se usan como paleta de reciclaje.
- `accessible theme navigation --stack flutter`: ThemeData, acceso por contexto,
  tokens y soporte de tema oscuro. Reglas móviles: toque 48 dp, safe areas,
  contraste de texto 4.5:1, tamaños dinámicos y navegación inferior de cinco destinos.

La marca verde se conserva por decisión del proyecto. Outfit/Work Sans se
adoptan como pareja de uso general legible, no como match ambiental.

## Tokens

| Rol | Claro | Oscuro |
| --- | --- | --- |
| Fondo | #F5F7F1 | #0D1914 |
| Superficie | #FFFFFF | #17281F |
| Texto | #17392D | #EFF6F0 |
| Texto secundario | #53675A | #B6C9BC |
| Marca | #087554 | #78D5A5 |
| Hero / botón principal | #064B38 | #144D39 |
| Texto sobre hero | #FFFFFF | #FFFFFF |
| Acento | #C2EB63 | #C2EB63 |
| Texto sobre acento | #193B24 | #193B24 |

Tokens se implementan en AppPalette y AppTheme; no introducir hex dispersos
en las vistas. Bordes de tarjetas son decorativos; foco/controles tienen
contraste propio. Estados bloqueado/logrado incluyen texto además de color.

## Tipografía y ritmo

- Outfit en títulos y números destacados; Work Sans en cuerpo/controles.
  Archivos locales y OFL en apps/mobile/assets/fonts/.
- Cuerpo 16, texto de apoyo 14, etiquetas secundarias 12; alturas 1.4–1.5.
- Títulos 22/28/34; saldo 56. Permitir wrap y altura natural con texto grande.
- Escala espacial 4/8/16/24/32; márgenes 20 en teléfono, contenido máximo 720.
- Tarjeta 24 de radio; hero 28–32; botones 18; iconos 20/24, badges 44/48.
- Un CTA dominante; secundarios outlined/tonales. Ripple de Material sin mover
  el layout. No animaciones nuevas que requieran desactivar movimiento.

## Pantallas

- Bienvenida: marca, mascota vectorial, promesa clara, tres pasos y Empezar.
- Inicio: saludo, aviso discreto, saldo/CTA, ranking, impacto y actividad.
- Reciclar: CTA QR e historial; formulario nuevo con pasos Escanea/Confirma,
  marco QR vectorial y recibo de solo lectura; nota editable en detalle.
- Mapa: ubicación, catálogo, contenedor geográfico redondeado o estado sin
  coordenadas honesto; lista accesible y ficha seleccionada. Sin mapa ficticio.
- Premios: saldo, filtros, tarjetas por categoría, estado y costo visibles.
- Perfil: identidad local, progreso, racha, insignias, niveles y apariencia.

Los nombres de las rutas, teclas de widgets y reglas de negocio de C01 se
mantienen. Prohibido reintroducir alta manual nueva o botón Sugerencias.

## Avisos y textos (C03)

- Simulación: chip compacto «Simulado» en la cabecera de cada pantalla, con
  explicación al tocarlo. Sin red cambia el icono; el texto no cambia.
- Feedback: toast superior `AppToast` (éxito/error/info con icono y color),
  autocierre 3 s (errores 5 s), descartable, uno a la vez, sin animación con
  movimiento reducido. No usar SnackBar ni dejar estados como texto en la página.
- Errores de campo siguen junto al campo; estados vacíos con icono, título y acción.
- Texto mínimo: títulos, datos y acciones. Las explicaciones van en el chip, en
  tooltips o en diálogos de confirmación. [Entrega C03](../../docs/entregas/C03.md).
