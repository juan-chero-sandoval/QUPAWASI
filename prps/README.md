# PRP ejecutables por integrante

PRP significa aquí especificación de implementación con contexto, alcance, secuencia y aceptación. No es una garantía automática de que el código no falle. La IA debe verificar comportamiento y registrar hechos; no se limita a generar archivos.

| Turno | Integrante | PRP | Dependencia |
| --- | --- | --- | --- |
| F01 | Cristhoper | [Base Flutter, rutas y preferencias](F01-CRISTHOPER.md) | Preparación publicada en develop |
| F02 | Juan | [Dominio y SQLite](F02-JUAN.md) | F01 integrada y validada |
| F03 | Brianna | [CRUD y ciclo de vida](F03-BRIANNA.md) | F02 integrada y validada |
| F04 | Adriana | [Experiencia de la app](F04-ADRIANA.md) | F03 integrada y validada |
| F05 | Carla | [QA, APK y entrega](F05-CARLA.md) | F04 integrada y validada |

Orden obligatorio F01 → F02 → F03 → F04 → F05. No empezar el turno siguiente con una rama antigua ni rehacer la fase anterior. Cada PRP incluye el mensaje que debe usar su integrante. Seguir [el protocolo Git](../docs/FLUJO_EQUIPO.md).
