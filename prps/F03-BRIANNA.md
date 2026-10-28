# F03 — Brianna — CRUD visible y ciclo de vida

## Objetivo y prerrequisitos

Que el docente pueda crear, listar, consultar, editar y eliminar un registro sin internet, y comprobar borradores al pasar a segundo plano. Responsable Brianna, rama `codex/f03-crud-ciclo-vida`. Requiere F02 integrada, repositorios funcionales, tests de reapertura y contrato definitivo en handoff.

Lee [contexto](../docs/CONTEXTO_GENERAL.md), [contratos](../docs/CONTRATOS.md), [diseño](../docs/DISENO.md), [validación](../docs/VALIDACION.md), [flujo](../docs/FLUJO_EQUIPO.md) y [estado](../docs/ESTADO.md). Skills: fase, sqlite y ui en `../.agents/skills/`. Leer entregas F01/F02 existentes al iniciar.

## Alcance y límites

Pantallas de reciclaje/lista/detalle/crear/editar y ViewModels; estado temporal y lifecycle. Consumir casos de uso; no abrir DB desde la vista. No agregar API remota ni falsificar escaneo de cámara. Selección manual siempre disponible, funciona en modo avión y es suficiente para Unidad II.

## Implementación por pasos

1. Actualizar base, correr validación anterior y revisar firmas. Inyectar casos de uso en ViewModels para lista, formulario y detalle. Modelar loading/empty/data/error y saving/deleting con protección contra doble envío.
2. Pantalla `/recycling`: lista reactiva de registros con punto, material, cantidad y fecha; vacío con CTA; botón visible nuevo. Abrir detalle pasando el UUID y recuperando de DB. Error/ID inexistente ofrece volver a lista, no null crash.
3. Formulario nuevo con tres pasos como referencia: Punto, Material, Confirmar. El punto puede venir por query param; validar existencia, permitir cambiarlo. Cantidad numérica entera, nota opcional y resumen final; errores junto a campo. Validar nuevamente antes de guardar.
4. Crear solo después de confirmación; esperar escritura correcta antes de éxito/navegación. Si falla, conservar datos y permitir reintento. Doble tap no crea dos registros. Emitir cambios a lista mediante stream, no agregar manualmente otra copia.
5. Detalle muestra el mismo ID/datos persistidos y botones Editar/Eliminar. Editar precarga entidad, conserva identidad/createdAt y hace update. Eliminar requiere diálogo con nombre/resumen de lo que se borrará; cancelar no modifica nada. Manejar error de saldo comprometido por canje con instrucción de cancelarlo en Premios.
6. Borrador persistente por formulario: guardar incremental con debounce y secuenciar escrituras. Guardar al cambiar de paso y antes de navegar atrás; al pausar/inactive hacer flush. Restaurar al abrir app y ofrecer continuar/descartar de forma clara. No crear un registro por el mero hecho de guardar borrador.
7. Si se editaba un ID que ya no existe, manejarlo explícitamente sin sobrescribir otro; solo permitir convertir en nuevo tras elección. Limpiar borrador únicamente tras guardar exitosamente o confirmar descarte.
8. Usar observador lifecycle según API de Flutter fijada; retirar listener/streams al disponer, no llamar notifyListeners después de dispose. No depender exclusivamente del callback de cierre forzado. Al reanudar, reconsultar estado si procede sin duplicar suscripciones ni guardar un valor viejo.
9. Teclado, scroll, SafeArea, validaciones y atrás Android accesibles; aviso de simulación. El selector QR opcional aparece como futura función o se reemplaza por selección manual explicada; no botón “Activar cámara” que mienta sobre su funcionamiento.
10. Añadir integration_test del recorrido CRUD y widget tests de validación/errores/borrador. Registrar prueba manual de cerrar/reabrir en Android y estado de cada requisito.

## Pruebas de aceptación específicas

- Lista vacía → crear PET2 → detalle correcto → cerrar/abrir → mismo registro.
- Editar a PET3 y nota nueva → mismo ID, una sola fila, 30 puntos por repositorio; borrar → ausencia después de reiniciar.
- Campos vacíos/negativos/decimales/fuera de rango; cambiar de pasos no pierde datos.
- Parámetro pointId válido precarga; inválido no guarda silenciosamente contra otro punto.
- Dos taps en Guardar → una operación; excepción DB → no éxito y borrador intacto.
- Formulario incompleto → background/retorno y reinicio → se restaura el valor más reciente; descartar lo limpia.
- Cambiar rápidamente inputs y pausar no permite que un debounce viejo pise al último valor.
- Verificar que navegar muchas veces no multiplica listeners ni emisiones.

## Validación y cierre

Validar contexto/diff, formato/analyze/test/build debug y ejecutar integration_test en dispositivo. Recorrido manual M04–M10. Si no hay Android, registrar lo que sí se probó y bloquear evidencia de instalación; no sustituirla con una captura de widget test.

- [ ] Cuatro operaciones CRUD visibles y persistentes, incluida actualización/eliminación.
- [ ] Paso de IDs y fallback de inexistentes.
- [ ] Estado reactivo separado de vista y errores claros.
- [ ] Borrador durable, lifecycle y descarte implementados/probados.
- [ ] F01/F02 sin regresión y tests/CI pasan.
- [ ] Entrega `docs/entregas/F03.md` y estado actualizados para Adriana.

Commit: `feat: completar CRUD de reciclaje y restaurar borradores (F03)`. PR a develop con identidad de Brianna. Entregar rutas/casos de uso, ejemplos de IDs, observación de streams y limitaciones para que F04 conecte Inicio/Mapa. No implementar F04 automáticamente.

## Prompt para la IA

> Soy Brianna. Ejecuta solo prps/F03-BRIANNA.md en codex/f03-crud-ciclo-vida desde develop actualizado. Lee los contratos y handoff F02. Implementa listado/detalle/formulario, CRUD SQLite por casos de uso, argumentos y borrador persistente al pausar/reabrir. Prueba crear/editar/eliminar y reinicio en Android. Mantén el tema y repositorios existentes; registra resultados y prepara mi commit/PR. No hagas backend ni las pantallas asignadas a Adriana; no cambies mi identidad Git.
