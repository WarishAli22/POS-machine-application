import 'package:flutter/material.dart';
import 'package:my_pos/pages/receipts_page.dart';

class MainNavDrawer extends StatelessWidget {
  const MainNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header (green) like the screenshot
            Container(
              color: const Color(0xFF2E7D32), // a pleasant green
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 8),
                  Text('Owner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(height: 6),
                  Text('Pos 1',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 2),
                  Text('Side Kitchen',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 8),
                ],
              ),
            ),

            // Menu items
            _DrawerTile(
              icon: Icons.sell_outlined,
              label: 'Sales',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerTile(
              icon: Icons.receipt_long,
              label: 'Receipts',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context){
                      return ReceiptsPage();
                    })
                );
              },
            ),
            _DrawerTile(
              icon: Icons.inventory_2_outlined,
              label: 'Items',
              onTap: () => Navigator.pop(context),
            ),

            // Divider visually placed right beneath Settings in screenshot
            _DrawerTile(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () => Navigator.pop(context),
              trailing: const SizedBox.shrink(),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Divider(height: 1),
            ),

            _DrawerTile(
              icon: Icons.bar_chart,
              label: 'Back office',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerTile(
              icon: Icons.apps,
              label: 'Apps',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerTile(
              icon: Icons.help_outline,
              label: 'Support',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// Small helper for uniform tiles
class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: trailing ??
          const Icon(Icons.chevron_right, size: 20, color: Colors.black45),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
