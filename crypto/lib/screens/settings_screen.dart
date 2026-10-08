import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/auth_store.dart';
import '../core/cache_store.dart';
import '../theme/app_theme.dart';

/// Settings tab: backend, data refresh, cache, account, about.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _note = '';

  void _say(String s) {
    if (!mounted) return;
    setState(() => _note = s);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
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
                    child: Text(_note, style: const TextStyle(color: AppColors.muted)),
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
                  _say(res['synced'] == true
                      ? 'Live sync complete.'
                      : 'Sync skipped (throttled) — showing stored data.');
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
                await context.read<CacheStore>().clear();
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
                icon: Icons.logout,
                title: 'Log out',
                subtitle: 'Signed in — tap to sign out',
                onTap: () => auth.logout(),
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
