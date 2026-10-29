# C01 · Correcciones posteriores a F05

Solicitud del owner: reemplazar alta manual por QR del tacho, localizar el tacho
más cercano desde catálogo SQLite, retirar Sugerencias y adaptar aviso de red.
Esta solicitud prevalece sobre el alcance anterior de F01–F05. No añade backend.

## Orden y protección de datos

1. Mantener registros existentes y tasas centralizadas PET 10 / aluminio 5.
2. QR JSON v1 estricto: tipo, versión, depositId, pointId, material, quantity,
   occurredAt con zona horaria, latitude, longitude. No aceptar puntos del QR.
3. Migrar SQLite v1 → v2 sin borrar datos. Guardar recibo QR y registro en una
   transacción. El recibo conserva depositId incluso si se elimina el registro.
   Un reintento devuelve el registro existente; nunca acredita dos veces.
   Los datos capturados por QR son inmutables; la nota local puede editarse
   sin alterar puntos (CRUD). Los históricos manuales conservan
   su edición. Eliminar sigue sujeto al saldo comprometido en canjes.
4. Escáner de cámara con permiso, reintento y liberación en segundo plano.
   Confirmación de datos de solo lectura antes de guardar. Manejar QR inválido,
   punto desconocido, ID duplicado con contenido distinto y error SQLite.
5. Catálogo de tachos en SQLite, carga JSON explícita validada y atómica.
   Coordenadas desconocidas no se inventan ni participan de proximidad.
   Ubicación del teléfono transitoria, permiso solo al solicitar proximidad.
   Distancias geodésicas y mapa geográfico cuando hay coordenadas.
6. Quitar accesos a sugerencias sin borrar sus datos históricos.
7. Distinguir conexión a internet de almacenamiento local. Eliminar la palabra
   offline al verificar internet; conservar aviso de puntos/canjes simulados.

## Validación

- Migración v1 con datos; reapertura del archivo SQLite.
- QR válido, campos incompletos, límites, fecha futura y zona horaria.
- Reescaneo concurrente, reinicio, conflicto y reescaneo tras eliminación.
- Puntos derivados y restricciones de saldo; regresión de la suite existente.
- Proximidad, ausencia de coordenadas, permisos y errores de ubicación.
- Banner offline/online/estado desconocido y retiro de Sugerencias.
- Formato, generación Drift, análisis, tests, compilación APK.
- Registrar por separado pruebas nativas ejecutadas y pendientes.

## Límites y entrega

QR sin firma no autentica hardware ni impide fraude entre teléfonos. El saldo
es del perfil local; cuentas remotas/sincronización requieren backend posterior.
Sin coordenadas suministradas no se presenta un tacho real como el más cercano.
Documentar contrato/carga de catálogo, pruebas reales y limitaciones en entrega
C01, actualizar contratos/contexto/estado. No publicar ni fusionar por defecto.
