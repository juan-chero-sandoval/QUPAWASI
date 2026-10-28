# F04 — Adriana — Experiencia de Q'UPA WASI

## Objetivo y prerrequisitos

Completar las pantallas de las referencias usando los datos locales de F02/F03, conservando CRUD y estado. Responsable Adriana, rama `codex/f04-experiencia-app`. F03 debe estar integrada y el recorrido CRUD funcionar antes de empezar. Este turno tiene más UI; reutiliza componentes de F01 y no rediseñes desde cero.

Lee [contexto](../docs/CONTEXTO_GENERAL.md), [contratos](../docs/CONTRATOS.md), [diseño/capturas](../docs/DISENO.md), [validación](../docs/VALIDACION.md), [flujo](../docs/FLUJO_EQUIPO.md) y [estado](../docs/ESTADO.md). Skills: `../.agents/skills/qupawasi-fase/SKILL.md`, `../.agents/skills/qupawasi-ui/SKILL.md` y `../.agents/skills/qupawasi-sqlite/SKILL.md` para canjes. Lee el handoff F03.

## Alcance

Inicio, mapa esquemático, premios/canjes, perfil, ranking de muestra y sugerencias locales. No reemplazar SQLite por modelos en memoria para lograr el acabado visual. Sin mapas de red, push, pagos ni autenticación remota.

## Implementación por pasos

1. Ejecutar baseline y revisar rutas/componentes. Crear ViewModels con streams/casos de uso; cada suscripción se dispone. Reemplazar previews de Inicio/Perfil por estado local real, manteniendo aviso de simulación.
2. Inicio: saludo alias, puntos disponibles, total ganado, nivel/progreso, CTA registrar, impacto y actividad reciente. Usar estadísticas de repositorio, no contar por cuenta propia en el widget. Crear/editar/eliminar se refleja sin relanzar app ni requerir tap de actualización.
3. Impacto: mostrar conteos exactos PET/latas; para kg/CO₂, usar únicamente factores de demo documentados o “Estimación no configurada”. No afirmar mediciones físicas ni equivalencias monetarias reales. Vacío con CTA como referencia 08.
4. Mapa: esquema vectorial/widget local del campus con puntos de demostración y lista accesible equivalente. No usar coordenadas falsas sobre un mapa geográfico real. Selección refleja ficha/ocupación y CTA pasa el pointId al formulario existente. Etiquetar esquema y ocupación de ejemplo; el usuario no debe confundirlos con disponibilidad real.
5. Premios: saldo, aviso sin transferencia de dinero, filtros Todas/Fotocopias/Saldo móvil/Cafetería, tarjetas según captura y costo del catálogo. Cuando no alcanza, explicar cuánto falta. Alcanza → confirmar canje → usar operationId único persistente para reintentos → mostrar resultado; doble tap o volver atrás no descuenta otra vez.
6. Historial de canjes locales y acción Cancelar con confirmación; repositorio devuelve estado consistente y recalcula saldo. Tras reinicio conservar canje/cancelación; no reactivar cancelados al cargar catálogo. No mostrar código válido en comercio real.
7. Perfil: avatar por iniciales, alias editable, tema, nivel/progreso, racha e insignias desde datos. Historial puede reutilizar lista/fragmento de F03. El alias debe sobrevivir al reinicio. No copiar código/nombre de alumno real ni incluir botón de notificaciones que solicite permisos.
8. Ranking: modal/pantalla rotulada “Ejemplo de ranking · datos simulados”; aliases ficticios. Participación local optativa si se muestra al usuario. No inventar otros alumnos del equipo como usuarios ni afirmar ranking en vivo.
9. Sugerencias: mensaje validado, guardar/listar/eliminar localmente con confirmación; aviso “Solo en este dispositivo; no se ha enviado”. Si no existe servidor, no mostrar “respuesta del equipo” ni éxito de envío.
10. Comprobar navegación de los cinco destinos, teclado, scroll, SafeArea y fuentes offline. Tema oscuro y texto ampliado. Hacer comparación visual con referencias y documentar diferencias aceptadas; corregir overflow sin ocultar controles.

## Validación y aceptación

Automatizado: filtros, alias/tema, streams de dashboard tras CRUD, confirmación/cancelación e idempotencia de canje, saldo insuficiente, ruta pointId y sugerencia local. Usar repositorios reales en al menos un recorrido integral. Ejecutar scripts compartidos y M09–M14, además de smoke CRUD M04–M07.

- [ ] Cinco pestañas completas, sin botones principales que aparenten acciones inexistentes.
- [ ] Inicio/perfil reaccionan a CRUD sin duplicar cálculos.
- [ ] Mapa local funciona en modo avión y pasa pointId correctamente.
- [ ] Premios filtra, confirma y guarda un solo canje; cancelación libera saldo una vez.
- [ ] Canjes/alias/tema/sugerencias siguen tras cerrar y abrir.
- [ ] Prototipo, ranking, mapa y canjes se distinguen de servicios reales.
- [ ] Sin overflow en tamaños objetivo y fuentes no dependen de internet.
- [ ] Pruebas anteriores/CI pasan; informe F04 y estado disponibles para Carla.

## Commit y relevo

Mensaje: `feat: integrar inicio mapa premios y perfil offline (F04)`. PR a develop con identidad de Adriana. Informe `docs/entregas/F04.md`: pantallas, comparación visual, datos de muestra, pruebas, limitaciones y ruta para video de Carla. No incorporar QR/GPS reales si retrasa criterios de Unidad II; cualquier mejora debe mantener el flujo manual.

## Prompt para la IA

> Soy Adriana. Ejecuta únicamente prps/F04-ADRIANA.md en codex/f04-experiencia-app. Actualiza develop y lee contratos y handoff F03. Completa Inicio, mapa esquemático offline, Premios, Perfil, ranking demo y sugerencias locales con los componentes y repositorios existentes. Prueba reactividad, canjes idempotentes, reinicio y accesibilidad, sin romper CRUD. No uses APIs de red ni finjas depósitos/pagos reales. Registra resultados y prepara mi commit/PR con mi identidad existente. No hagas la fase de Carla.
