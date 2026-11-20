# C05 · Registros y canjes en Supabase

Supabase será la fuente de registros confirmados, EcoPuntos y canjes en la
app conectada. Este PRP continúa la [lectura de C04](../docs/entregas/C04.md)
y conserva el historial local de la entrega académica como simulación.

## Esquema acordado con el export

El export incluye las funciones de captura, acreditación y canje. La migración
reutiliza los saldos y movimientos del proyecto, incluidos los históricos.

| Entidad | Cambio de C05 |
| --- | --- |
| `profiles` y Supabase Auth | `profiles.id = auth.users.id`. La cuenta autenticada determina el propietario. Las funciones actualizan `points` y `lifetime_points`. |
| `recycle_points`, `materials`, `categories`, `rewards` | Reutilizar el catálogo, los ID textuales, las tasas por material y el stock existente. Mantener premios con historial y desactivarlos cuando corresponda. |
| `device_captures` | La vigencia sale de `capture_expiry_minutes`. El QR transporta el UUID devuelto por el servidor al tacho y la app consulta una captura por vez. |
| `activity` | Mantener el movimiento original, su `items` JSON y los puntos acreditados. Agregar `point_id`, `capture_id` único y `note` de hasta 200 caracteres. |
| `redemptions` | Mantener el título y costo histórico. Agregar `operation_id` único por cuenta, `stock_reserved` y `canceled_at`. Los códigos nuevos son únicos y la entrega es incompatible con la cancelación. |

## Operaciones del servidor

- **Confirmar depósito.** La sesión identifica al usuario. El servidor lee una
  captura válida, comprueba su vigencia y propiedad si está reservada, calcula
  los puntos desde sus materiales y confirma registro, líneas, consumo de la
  captura y saldo en una transacción. Un reintento del mismo titular devuelve
  el registro confirmado. Otra cuenta no puede reclamar la misma captura.
- **Editar nota.** El propietario puede modificar la nota de su registro. Una
  corrección de cantidades o de puntos requiere una operación autorizada y
  auditada. El QR JSON simulado de [C01](../docs/QR_Y_UBICACIONES.md) permanece
  como evidencia de la entrega académica.
- **Canjear recompensa.** Una RPC toma `reward_id` y `operation_id`. Bloquea el
  saldo y el premio en un orden estable, valida saldo, vigencia y stock,
  registra el canje con código del servidor y actualiza movimiento y stock en
  la misma transacción. El mismo ID y premio devuelven el canje original. El
  mismo ID con otro premio devuelve conflicto.
- **Cancelar canje.** Solo procede para un canje propio y pendiente cuyo dato
  de reserva de stock haya quedado registrado. Restaura
  una sola vez el saldo y, si hay stock limitado, la unidad reservada. La
  entrega y la cancelación son estados incompatibles y se serializan.

Aplicar RLS al historial y a las operaciones que leen datos de cuenta.
Restringir los cambios de saldo y stock a las funciones autorizadas. Si una
función usa `SECURITY DEFINER`, fijar el `search_path`, calificar sus objetos
y conceder `EXECUTE` de forma explícita al rol previsto. La app usa una clave
publicable y la sesión de Supabase Auth. El backend del tacho registra las
capturas por un canal de confianza separado.

## Integración Flutter

1. Incorporar la sesión del proyecto y proteger rutas de historial, saldo y
   canjes. Cargar la cuenta por su UUID de Auth y limpiar los datos de la
   cuenta anterior al cerrar sesión o cambiar de usuario.
2. Conectar Reciclar, Inicio, Perfil y Premios a repositorios remotos,
   reutilizando la navegación por IDs y los estados de carga y error de la app.
   Refrescar historial y saldo tras cada operación confirmada.
3. Conservar borradores e historial simulado en la variante académica de SQLite.
   Asociar a
   la cuenta cualquier operación pendiente de reintento. Al perder red,
   preservar la intención y confirmar el resultado únicamente al responder el
   servidor. Los registros y canjes de simulación quedan fuera del saldo real.
4. Preparar la migración SQL versionada sobre la estructura vigente y
   comprobar los consumidores web de escritura manual y lectura de capturas
   pendientes antes de desplegar. Las funciones y permisos se aplican desde un
   acceso administrativo de Supabase. El modo conectado se compila cuando se
   despliega el contrato. [Procedimiento y resultados](../docs/entregas/C05.md)

## Aceptación

Ejecutar las pruebas y compilar el APK después de completar la implementación
de backend y Flutter. Verificar cuentas aisladas, captura repetida y concurrente,
premio agotado, dos intentos de canje con saldo para uno, devolución única,
reintento tras respuesta perdida y conservación del historial local. Probar el
flujo completo con un dispositivo y un entorno Supabase con datos de prueba
autorizados. Registrar la compilación y los resultados en la entrega C05.
