import 'package:flutter/material.dart';

import '../../core/widgets/app_toast.dart';
import '../../data/remote/supabase_data_source.dart';

class SupabaseConnectionTile extends StatefulWidget {
  const SupabaseConnectionTile({super.key, required this.checkConnection});

  final Future<void> Function() checkConnection;

  @override
  State<SupabaseConnectionTile> createState() => _SupabaseConnectionTileState();
}

class _SupabaseConnectionTileState extends State<SupabaseConnectionTile> {
  bool _checking = false;

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      await widget.checkConnection();
      if (mounted) {
        AppToast.success(context, 'Conexión con Supabase verificada');
      }
    } on SupabaseReadException catch (error) {
      if (!mounted) return;
      AppToast.error(context, switch (error.failure) {
        SupabaseReadFailure.configuration => 'Revisa la URL y la clave pública',
        SupabaseReadFailure.timeout => 'Supabase tardó demasiado en responder',
        SupabaseReadFailure.network => 'No se pudo conectar con Supabase',
        SupabaseReadFailure.unauthorized => 'Supabase no autorizó la consulta',
        SupabaseReadFailure.forbidden => 'Falta permiso para leer categorías',
        SupabaseReadFailure.unavailable => 'La consulta a categorías falló',
        SupabaseReadFailure.invalidResponse => 'Respuesta de Supabase inválida',
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.cloud_outlined),
      title: Semantics(
        liveRegion: _checking,
        child: Text(_checking ? 'Comprobando conexión…' : 'Probar conexión'),
      ),
      onTap: _checking ? null : _check,
    );
  }
}
