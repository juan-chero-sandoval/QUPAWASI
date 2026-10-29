---
name: qupawasi-ui
description: Crear o verificar pantallas Flutter de QUPAWASI a partir de sus capturas, con navegación por IDs, estado MVVM y accesibilidad offline.
---

# UI de Q'UPA WASI

Consulta [diseño y capturas](../../../docs/DISENO.md) y [rutas/contratos](../../../docs/CONTRATOS.md). No usar una captura entera como pantalla ni un WebView.

Mantén cinco pestañas, tarjetas verdes/claras y jerarquía de las referencias, adaptadas a SafeArea y teclado. Usa tokens/componentes compartidos, fuentes locales y scroll; prueba 320/360/412 dp y texto ampliado. No sacrificar controles de editar/eliminar para asemejar una imagen.

ViewModels consumen casos de uso y exponen loading/data/empty/error. No SQL ni cálculo de puntos en build(). Navegación pasa ID serializable y vuelve a consultar el repositorio; manejar entidad inexistente sin null crash. Liberar listeners al disponer.

Desde C01: aviso “EcoPuntos y canjes simulados” consistente; “Sin conexión”
solo en estado offline confirmado. Alta nueva mediante QR del tacho con datos
de solo lectura y nota local editable; formulario completo solo de históricos. Mapa geográfico con catálogo
SQLite y GPS opcional; sin coordenadas verificadas no inventar proximidad.
Sin accesos a Sugerencias en Inicio/Perfil. Consultar docs/QR_Y_UBICACIONES.md.

Verifica eventos, parámetros y reactividad, además de aspecto. Una captura bonita no demuestra CRUD ni persistencia. Documenta diferencias visuales aceptadas y registra pruebas Android reales.
