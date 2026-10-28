# Guía visual y de interacción

Las ocho imágenes en `docs/referencias/` son referencias de una web, no pantallas de una app Flutter existente. Conservar su jerarquía y personalidad; adaptar correctamente al área segura Android sin copiar el marco exterior verde como si fuera parte del contenido.

## Referencias

| Archivo | Pantalla y elementos a conservar |
| --- | --- |
| [01-bienvenida.png](referencias/01-bienvenida.png) | Fondo claro, mascota/recurso simple, título, tres pasos, Empezar y privacidad |
| [02-inicio.png](referencias/02-inicio.png) | Saludo, saldo destacado, nivel, CTA, ranking e impacto |
| [03-reciclar.png](referencias/03-reciclar.png) | Progreso Punto/Material/Confirmar, tarjeta central y alternativa manual |
| [04-mapa.png](referencias/04-mapa.png) | Encabezado, área de mapa, estado de ocupación, ficha y CTA |
| [05-premios.png](referencias/05-premios.png) | Saldo, aviso de simulación, filtros y tarjetas con costo/bloqueo |
| [06-perfil.png](referencias/06-perfil.png) | Avatar, nivel, progreso, racha, insignias y niveles |
| [07-perfil-historial.png](referencias/07-perfil-historial.png) | Historial vacío, sugerencias y sección inferior del perfil |
| [08-inicio-actividad.png](referencias/08-inicio-actividad.png) | Actividad vacía, CTA secundario y navegación inferior |

La captura original 8 duplica la 7 byte a byte; se conserva una sola copia. No hay referencia del formulario de edición ni de confirmación: diseñarlos con los mismos componentes, sin fingir que aparecían en las capturas.

## Tokens propuestos

Valores orientativos extraídos visualmente, no un sistema original facilitado: verde oscuro `#064E3B`, verde principal `#087F5B`, lima `#BDE85B`, fondo claro `#F1F6EF`, tarjetas `#FFFFFF`, texto `#16382E`, bordes `#D6E1D3`. Centralizarlos y ajustar contraste en pruebas. El modo oscuro requiere tokens semánticos, no invertir imágenes o fijar texto negro.

Radios aproximados 16 px en tarjetas y 24 px en botones grandes; márgenes laterales 16–20; espaciado base 8; botones táctiles mínimo 48 dp. Fuente del sistema inicialmente; una fuente condensada local con licencia puede mejorar títulos si hay tiempo. No depender de descargar Google Fonts en runtime. Una mascota simple original se puede construir con widgets/iconos; no recortar la captura completa como UI ni inventar derechos de una imagen.

## Comportamiento

- Barra inferior con cinco destinos y etiqueta; estados seleccionados reconocibles por texto/ícono además del color.
- Bienvenida con tres pasos y aviso local; no afirmar cuenta real. Un inicio vacío invita a crear el primer registro.
- Reciclar permite elegir punto manualmente, material PET/lata, cantidad y confirmar. Lista y detalle hacen visible editar/eliminar; no ocultar el CRUD tras gestos sin etiqueta.
- Mapa local esquemático con lista accesible; ficha muestra ocupación de demostración. CTA abre `/recycling/new` con `pointId`.
- Premios muestra exactamente cuándo faltan puntos, confirmación antes de canjear y aviso de no entrega comercial. Historial permite cancelar simulaciones para liberar saldo.
- Perfil usa alias de demo, no el nombre/código real de las capturas como dato fijo. Sugerencias avisa almacenamiento local sin envío.
- Textos de errores concretos, loading breve, estados vacíos y recuperación; evitar spinners infinitos y taps que no hacen nada.

## Accesibilidad y QA visual

Probar anchuras lógicas aproximadas 320, 360 y 412 dp, orientación soportada y texto 1.3x/2x. Tarjetas y títulos envuelven; listas y formularios tienen scroll, SafeArea y espacio para teclado/barra inferior. No forzar alturas de las capturas. Etiquetas semánticas de iconos, orden de foco lógico y errores asociados al campo. Los avisos de simulación y vacío no dependen solo del verde. Comparar capturas reales del APK contra estas referencias y registrar las diferencias aceptadas.
