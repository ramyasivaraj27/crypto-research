import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../provider/provider_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/primitives.dart';
import 'login_screen.dart';

/// Settings tab: backend, data refresh, cache, account, about.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _note = '';
  bool _noteOk = false;

  void _say(String s, {bool ok = false}) {
    if (!mounted) return;
    setState(() {
      _note = s;
      _noteOk = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.authState;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const SectionTitle(text: 'Settings'),
            if (_note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(_note,
                        style: TextStyle(
                            color: _noteOk ? AppColors.gain : AppColors.muted)),
                  ),
                ),
              ),
            _tile(
              icon: Icons.cloud_sync_outlined,
              title: 'Refresh market data',
              subtitle: 'Throttled live sync from CoinGecko',
              onTap: () async {
                _say('Syncing…');
                try {
                  final res = await context.read<ApiClient>().refreshCoins();
                  _say(
                    res['synced'] == true
                        ? 'Live sync complete.'
                        : 'Sync skipped (throttled) - showing stored data.',
                    ok: res['synced'] == true,
                  );
                } catch (e) {
                  _say('Sync failed: $e');
                }
              },
            ),
            _tile(
              icon: Icons.delete_outline,
              title: 'Clear offline cache',
              subtitle: 'Remove all saved market data on this device',
              onTap: () async {
                final cache = context.read<CacheStore>();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Clear offline cache?',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    content: const Text(
                      'This removes all saved market data on this device. '
                      'The app will need the backend again to show data.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child:
                            const Text('Cancel', style: TextStyle(color: AppColors.muted)),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.loss,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
                await cache.clear();
                _say('Offline cache cleared.');
              },
            ),
            _tile(
              icon: Icons.link_outlined,
              title: 'Backend',
              subtitle: ApiClient.baseUrl,
              onTap: () {},
            ),
            if (auth.isLoggedIn)
              _tile(
                icon: Icons.person_outline,
                title: 'Signed in as ${auth.username ?? 'you'}',
                subtitle: 'Tap to log out',
                onTap: () => context.authViewModel.logout(),
              )
            else
              _tile(
                icon: Icons.login,
                title: 'Log in / Sign up',
                subtitle: 'Needed for your watchlist',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Crypto Research 1.0.0 • Powered by CoinGecko',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.muted),
          title: Text(title),
          subtitle: Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          onTap: onTap,
        ),
      ),
    );
  }
}
