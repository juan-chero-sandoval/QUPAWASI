---
name: qupawasi-fase
description: Ejecutar un turno de implementación de QUPAWASI con su PRP, pruebas y relevo al siguiente integrante. Usar en cambios de código del equipo, no para hacer todos los turnos a la vez.
---

# Ejecutar una fase de Q'UPA WASI

Lee [el contexto](../../../docs/CONTEXTO_GENERAL.md), [contratos](../../../docs/CONTRATOS.md), [protocolo Git](../../../docs/FLUJO_EQUIPO.md), [estado](../../../docs/ESTADO.md) y únicamente el PRP asignado en `prps/`.

Antes de editar, verifica rama/remoto/estado, identidad existente del integrante y que la entrega anterior está integrada. Una IA con acceso de lectura a GitHub puede no tener terminal/Flutter: comprueba capacidades y no inventes ejecuciones.

Implementa el alcance de ese turno. Cambios en contratos requieren actualización compatible de consumidores y pruebas. Conserva arquitectura Flutter/MVVM, SQLite para registros y Shared Preferences para ajustes. No añadir backend al prototipo de Unidad II.

Ejecuta `python scripts/validar_contexto.py` y desde F01 `scripts/validar_mobile.ps1`, más pruebas específicas del PRP. Diferencia build, instalación y demostración manual: son evidencias distintas.

Crea `docs/entregas/FNN.md` desde la plantilla y actualiza el estado, con resultados reales, limitaciones y siguiente responsable. Prepara commit/PR con la identidad ya configurada y dentro de la autorización de la sesión. No modificar autor ni simular trabajo de otra persona. El owner integra en orden conservando commits.

No continúes el turno siguiente por iniciativa propia. Si una herramienta falla, registra el bloqueo concreto sin certificar la fase como validada.
