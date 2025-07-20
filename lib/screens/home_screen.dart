import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../widgets/service_card.dart';
import '../widgets/quick_action_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _userName = 'Mugesh';
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Mugesh';
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $_userName!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/home/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage all your services in one place',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Services Section
            Text(
              'Services',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                ServiceCard(
                  title: 'Cable TV',
                  subtitle: 'Manage & Recharge',
                  icon: Icons.tv,
                  color: Colors.purple,
                  onTap: () => context.go('/home/cable-tv'),
                ),
                ServiceCard(
                  title: 'Internet',
                  subtitle: 'View & Renew Plans',
                  icon: Icons.wifi,
                  color: Colors.blue,
                  onTap: () => context.go('/home/internet'),
                ),
                ServiceCard(
                  title: 'Bill Payment',
                  subtitle: 'Pay Utility Bills',
                  icon: Icons.receipt_long,
                  color: Colors.green,
                  onTap: () => context.go('/home/bill-payment'),
                ),
                ServiceCard(
                  title: 'Support',
                  subtitle: 'Raise & Track Tickets',
                  icon: Icons.support_agent,
                  color: Colors.orange,
                  onTap: () => context.go('/home/support'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ServiceCard(
              title: 'All Services',
              subtitle: 'Browse Available Services',
              icon: Icons.apps,
              color: Colors.indigo,
                  onTap: () => context.go('/home/services'),
            ),
            const SizedBox(height: 24),

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                QuickActionTile(
                  title: 'Quick Recharge',
                  subtitle: 'Recharge your services instantly',
                  icon: Icons.flash_on,
                  onTap: () {
                    // TODO: Implement quick recharge
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quick Recharge coming soon!')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                QuickActionTile(
                  title: 'Service Status',
                  subtitle: 'Check all service statuses',
                  icon: Icons.info_outline,
                  onTap: () {
                    // TODO: Implement service status
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Service Status coming soon!')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                QuickActionTile(
                  title: 'Payment History',
                  subtitle: 'View your transaction history',
                  icon: Icons.history,
                  onTap: () {
                    // TODO: Implement payment history
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment History coming soon!')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity Section
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    _buildActivityItem(
                      context,
                      'Cable TV Recharged',
                      'Premium Package - ₹599',
                      '2 hours ago',
                      Icons.tv,
                      Colors.purple,
                    ),
                    const Divider(),
                    _buildActivityItem(
                      context,
                      'Internet Bill Paid',
                      'Monthly Plan - ₹1299',
                      '1 day ago',
                      Icons.wifi,
                      Colors.blue,
                    ),
                    const Divider(),
                    _buildActivityItem(
                      context,
                      'Support Ticket Resolved',
                      'Technical Issue #12345',
                      '3 days ago',
                      Icons.support_agent,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
