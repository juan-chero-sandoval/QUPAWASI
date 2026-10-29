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

## Preparación concreta F05 (sin video grabado)

Carla opera el APK normal 0.2.0+2, no el runner de integración. Comprobar modo avión y ocultar datos personales. Antes de grabar, dejar cero registros y cero canjes activos usando las acciones confirmadas de la app; no desinstalar entre la prueba de guardado y reapertura. Usar alias ficticio “QA Colibri”. Ensayar una vez antes de iniciar la grabación.

| Tiempo | Acción y frase de apoyo |
| --- | --- |
| 00:00–00:30 | Cristopher: “Prototipo offline de reciclaje UNP. Los puntos y canjes son simulados”. Mostrar modo avión, pestañas y tema. |
| 00:30–01:00 | Juan: crear PET 2 en Arquitectura, nota “prueba”. “SQLite guarda el registro; preferencias guarda configuración”. Mostrar 20 puntos. |
| 01:00–02:00 | Brianna: abrir detalle/UUID, forzar detención sin borrar datos, reabrir; editar a PET 3 y nota “editada”. Mostrar mismo UUID, una fila y 30 puntos. Eliminar y mostrar cero. |
| 02:00–02:40 | Brianna: nuevo formulario incompleto, esperar al menos un segundo, Home, detener/reabrir y continuar borrador. “Android puede terminar el proceso; recuperamos lo ya escrito en SQLite”. Descartar. |
| 02:40–03:40 | Adriana: mapa Biblioteca → registro PET 10; canje fotocopias 80. Mostrar saldo 20, borrar bloqueado, cancelar canje y saldo 100. “No se entrega dinero ni un premio real”. |
| 03:40–04:20 | Carla: alias/oscuro, detener/reabrir y verificar. Mostrar versión/paquete/hash del informe y resultados reales de tests, distinguiendo reapertura de conexión y proceso nuevo. |
| 04:20–04:50 | Cada autor identifica su commit. Carla: “Adaptamos la consigna MYPE al reciclaje UNP; la aceptación docente debe confirmarse. No hay backend ni publicación en tienda”. |

Duración objetivo: 4:50; cortar introducciones, nunca la edición/eliminación o reapertura. La sustentación usa el código del módulo de cada integrante y el diagrama de contratos. Carla explica además la regresión reproducida: ante fallo al descartar un borrador se conserva la oferta y se permite reintentar.

**Pendiente, equipo/Carla:** grabación real con narración, comprobar duración ≤5 minutos y enlace accesible al docente. No existe archivo final ni enlace en esta sesión. La subida a Drive/YouTube necesita autorización específica; no se realizó. U2-11 permanece pendiente.
