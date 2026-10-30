# QR del tacho y catálogo de ubicaciones · v1

Contrato acordado el 29/10/2026 mientras el equipo aún no dispone de hardware
ni coordenadas. El tacho debe generar **un recibo por depósito**, con ID global
único (UUID recomendado); un QR fijo que solo identifica el tacho no es válido.

## Contenido del QR

```json
{
  "type": "qupawasi.deposit",
  "version": 1,
  "depositId": "demo-deposito-001",
  "pointId": "00000000-0000-4000-8000-000000000001",
  "material": "pet",
  "quantity": 2,
  "occurredAt": "2026-10-28T10:00:00-05:00",
  "latitude": 0.0,
  "longitude": 0.0
}
```

**Ejemplo sintético:** 0,0 no representa ningún tacho de la UNP. El pointId es
el punto de demostración Arquitectura que existe en la instalación inicial.
Para probar la cámara, convertir literalmente este JSON a QR y mostrarlo en
otra pantalla. Cada depósito nuevo necesita un depositId diferente.

Hay un [QR sintético listo para escanear](../apps/mobile/assets/demo/deposit-qr.png)
y su [JSON](../apps/mobile/assets/demo/deposit-qr.json), usado en la prueba del
decodificador nativo. Generar otro con `pip install 'qrcode[pil]'` y
`python scripts/generar_qr_demo.py --deposit-id demo-002`. La salida por defecto
queda en artifacts/qr-demo.png y no se versiona. No son depósitos reales.

- Material `pet` o `aluminum`; cantidad entera 1..100. Tasas de demostración:
  PET 10/unidad, aluminio 5/unidad. La app ignora cualquier campo `points`.
- Fecha ISO 8601 con segundos y `Z` o zona `±HH:mm`. No admitir fechas futuras,
  días inexistentes o fecha sin zona. Se persiste UTC y se muestra hora local.
- Coordenadas numéricas finitas en [-90,90] / [-180,180]. Ubicación es la del
  depósito/tacho, no el GPS del teléfono. Si el catálogo tiene coordenadas,
  deben coincidir con tolerancia de 0.00001 grados en cada eje.
- El tacho debe existir en SQLite. Un QR no puede crear ni mover un tacho.
- Vista previa de solo lectura; confirmar crea registro + recibo de forma
  atómica. Reintento devuelve el mismo registro. Mismo ID con otros datos es
  conflicto. El recibo sobrevive a la eliminación para impedir reacreditación.
- En registros QR solo se edita la nota local; material, cantidad, fecha,
  ubicación e ID del recibo son inmutables. Así se conserva CRUD sin alterar
  datos emitidos por el tacho. Históricos manuales conservan edición y borrador.
  Eliminar sigue bloqueado si compromete puntos de canjes activos.

## Catálogo SQLite

En Mapa → **Cargar catálogo de tachos**, pegar JSON de esta forma:

```json
{
  "version": 1,
  "points": [
    {
      "id": "tacho-demo-ubicado",
      "name": "Tacho de prueba sintético",
      "description": "No representa una ubicación real",
      "latitude": 0.0,
      "longitude": 0.0,
      "occupancy": 0,
      "isDemo": true
    }
  ]
}
```

Reemplazar por IDs y coordenadas verificadas del equipo; marcar `isDemo:false`
solo para ubicaciones reales suministradas. Hasta entonces no hay un tacho
real más cercano. No inventar coordenadas ni publicar posiciones personales.
Se actualizan/agregan IDs sin borrar registros ni tachos ausentes del archivo.
Catálogo de hasta 200 puntos, 100000 caracteres, IDs distintos; toda la carga
se valida antes de persistir y se aplica en una transacción.

**Usar mi ubicación** solicita permiso solo si hay tachos reales ubicados.
Sin GPS, permiso o respuesta en 15 segundos, muestra error recuperable y
conserva lista/mapa. Calcula Haversine con coordenadas SQLite; excluye demos y
coordenadas ausentes/inválidas. Distancia en línea recta, no ruta peatonal.
La posición del teléfono vive solo en memoria, no en fixtures/logs/SQLite.

El mapa muestra marcadores del catálogo y de la ubicación solicitada. Con
internet comprobado carga teselas OpenStreetMap; sin internet conserva
marcadores y distancias, sin depender de descargar el mapa base.

## Red y límites

El aviso muestra “Sin conexión” solo al detectar ausencia de internet; al
recuperarlo desaparece ese texto. Estado inicialmente desconocido no afirma
ausencia de red. Se conserva “EcoPuntos y canjes simulados” en cualquier red.
La comprobación usa endpoints públicos del adaptador de conexión y no envía
depósitos, saldo ni ubicación. Tener internet no crea una cuenta remota.

Escáner real: [mobile_scanner](https://pub.dev/packages/mobile_scanner).
Ubicación: [geolocator](https://pub.dev/packages/geolocator).
Mapa: [flutter_map](https://pub.dev/packages/flutter_map).
Conexión: [internet_connection_checker_plus](https://pub.dev/packages/internet_connection_checker_plus).

El QR JSON aún **no está firmado**: validarlo no autentica un depósito físico.
La deduplicación es por instalación SQLite, no entre teléfonos. Acreditación
en cuentas reales requiere identidad, firma de hardware, backend y operación
atómica remota; no reutilizar saldos simulados como saldo real.
