import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_register ? 'Sign up' : 'Log in')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Log in to sync your watchlist across devices.\nMarket data works without an account.'),
            const SizedBox(height: 16),
            TextField(controller: _user, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            if (_register) ...[
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 12),
            ],
            TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            _busy
                ? const CircularProgressIndicator()
                : FilledButton(
                    onPressed: _submit,
                    child: Text(_register ? 'Create account' : 'Log in'),
                  ),
            TextButton(
              onPressed: () => setState(() {
                _register = !_register;
                _error = null;
              }),
              child: Text(_register ? 'Have an account? Log in' : 'New here? Create account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final auth = context.read<AuthStore>();
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = _register
        ? await auth.register(_user.text.trim(), _email.text.trim(), _pass.text)
        : await auth.login(_user.text.trim(), _pass.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
    // When opened as a pushed route (e.g. from Settings), go back on success.
    if (err == null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
