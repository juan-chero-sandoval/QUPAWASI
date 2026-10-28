# Guion del video y sustentación

## Video de máximo cinco minutos

Objetivo: demostrar funcionamiento real en Android sin internet y persistencia SQLite después de cerrar/abrir. Grabar la aplicación compilada, no un diseño navegable. Ocultar notificaciones y datos personales ajenos. No acelerar de forma que se pierdan las operaciones. El enlace debe permitir al docente verlo; publicar/subir requiere que el equipo lo haga o autorice ese servicio.

| Tiempo sugerido | Responsable | Demostración |
| --- | --- | --- |
| 00:00–00:35 | Cristhoper | Mostrar modo avión, bienvenida/inicio, cinco pestañas y cambiar tema |
| 00:35–01:10 | Juan | Explicar SQLite y preferencias con diagrama breve; crear PET 2 desde formulario |
| 01:10–02:25 | Brianna | Mostrar lista/detalle con ID, cerrar y reabrir, editar a PET 3, eliminar y confirmar que desaparece |
| 02:25–03:15 | Brianna | Borrador, segundo plano y retorno con estado conservado |
| 03:15–04:05 | Adriana | Seleccionar punto desde mapa, puntos/impacto y canje simulado; recalcar sin dinero real |
| 04:05–04:50 | Carla | Preferencias tras reinicio, APK/dispositivo, tests/commits de los cinco y cierre técnico |

El orden exacto puede variar; duración objetivo 4:50 para margen. Si una sola persona opera el teléfono, los demás pueden narrar sus módulos. Editar/eliminar no son opcionales: la rúbrica distingue CRUD completo de lectura/escritura básica.

## Preguntas que cada integrante debe poder responder

- Cristhoper: ¿cómo pasa `recordId` el router?, ¿qué persiste en Shared Preferences y por qué no es una DB de registros?, ¿cómo se construye el árbol de widgets?
- Juan: ¿dónde está SQLite?, ¿qué tablas/restricciones existen?, ¿cómo evita duplicar puntos al editar?, ¿qué prueba demuestra reapertura y qué hace una transacción?
- Brianna: ¿cómo se notifica un cambio a la UI?, ¿cómo recupera el borrador y qué pasa si Android mata el proceso?, ¿cómo se manejan errores y doble tap?
- Adriana: ¿cómo mapa/formulario comparten `pointId`?, ¿por qué los canjes están rotulados simulados?, ¿cómo se actualiza Inicio al eliminar sin sumar contadores manuales?
- Carla: ¿cómo se genera/instala el APK?, ¿qué prueba se ejecutó en Android y cuál solo en test?, ¿qué commits corresponden a cada integrante?, ¿cuáles son los límites frente al sistema conectado de Lab01?

No memorizar respuestas sin abrir el código propio. Preparar un diagrama breve View → ViewModel → caso de uso → repositorio → Drift/SQLite, y otro acceso de preferencias desde su repositorio. El equipo explica que adapta el caso genérico MYPE al proyecto UNP y que Supabase es evolución posterior, no dependencia de la demo.

## Registro final — F05 debe completar con hechos

Archivo de evidencia `docs/entregas/F05.md`: variante/versionCode, commit origen, ruta de artefacto, SHA-256, certificado/tipo de firma, Android/dispositivo, casos manuales, resultado tests y enlace/duración del video cuando se haya grabado/subido realmente. Un campo no realizado se marca pendiente con responsable; no inventar enlaces.
