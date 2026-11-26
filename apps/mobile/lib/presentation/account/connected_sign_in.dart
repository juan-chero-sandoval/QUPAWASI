import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';

class ConnectedSignIn extends StatefulWidget {
  const ConnectedSignIn({super.key, required this.auth});

  final GoTrueClient auth;

  @override
  State<ConnectedSignIn> createState() => _ConnectedSignInState();
}

class _ConnectedSignInState extends State<ConnectedSignIn> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      await widget.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(
        () => _error = switch (error.code) {
          'invalid_credentials' => 'Revisa el correo y la contraseña.',
          'email_not_confirmed' => 'Confirma tu correo para iniciar sesión.',
          _ => 'No se pudo iniciar sesión. Reintenta.',
        },
      );
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo conectar. Reintenta.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Q’UPA WASI',
    simulated: false,
    children: [
      AppCard(
        child: Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                Text(
                  'Inicia sesión',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextFormField(
                  controller: _email,
                  enabled: !_busy,
                  decoration: const InputDecoration(
                    labelText: 'Correo institucional',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  validator: (value) => (value ?? '').trim().contains('@')
                      ? null
                      : 'Ingresa tu correo.',
                ),
                TextFormField(
                  controller: _password,
                  enabled: !_busy,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) =>
                      (value ?? '').isEmpty ? 'Ingresa tu contraseña.' : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_error case final error?)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(_busy ? 'Iniciando sesión…' : 'Ingresar'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
