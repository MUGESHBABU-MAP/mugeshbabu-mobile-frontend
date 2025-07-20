import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../core/constants.dart';

class InternetScreen extends ConsumerStatefulWidget {
  const InternetScreen({super.key});

  @override
  ConsumerState<InternetScreen> createState() => _InternetScreenState();
}

class _InternetScreenState extends ConsumerState<InternetScreen> {
  bool _isLoading = false;

  // Mock current plan data
  final Map<String, dynamic> _currentPlan = {
    'name': 'Premium Plan',
    'speed': '100 Mbps',
    'data': 'Unlimited',
    'price': 1299,
    'expiryDate': '2025-08-20',
    'daysLeft': 30,
    'status': 'Active',
    'dataUsed': 450, // GB
    'dataLimit': 0, // 0 means unlimited
  };

  Future<void> _renewPlan(Map<String, dynamic> plan) async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    Fluttertoast.showToast(
      msg: "Plan renewed successfully! ${plan['name']} activated.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.wifi,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current Plan',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Plan Name', _currentPlan['name']),
                    _buildInfoRow('Speed', _currentPlan['speed']),
                    _buildInfoRow('Data Limit', _currentPlan['data']),
                    _buildInfoRow('Monthly Price', '₹${_currentPlan['price']}'),
                    _buildInfoRow('Expiry Date', _currentPlan['expiryDate']),
                    _buildInfoRow('Days Left', '${_currentPlan['daysLeft']} days'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentPlan['status'],
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Data Usage Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.data_usage,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Data Usage',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_currentPlan['dataLimit'] == 0) ...[
                      Text(
                        'Unlimited Plan',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Data Used: ${_currentPlan['dataUsed']} GB this month',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ] else ...[
                      // For limited plans, show progress bar
                      LinearProgressIndicator(
                        value: _currentPlan['dataUsed'] / _currentPlan['dataLimit'],
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_currentPlan['dataUsed']} GB / ${_currentPlan['dataLimit']} GB used',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Available Plans Section
            Text(
              'Available Plans',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Plan Cards
            ...AppConstants.internetPlans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan['name'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '₹${plan['price']}',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plan['description'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildFeatureChip('${plan['speed']}'),
                          const SizedBox(width: 8),
                          _buildFeatureChip('${plan['data']}'),
                          const SizedBox(width: 8),
                          _buildFeatureChip('${plan['validity']} Days'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _showRenewDialog(plan),
                          child: Text('Renew Plan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )).toList(),

            const SizedBox(height: 24),

            // Speed Test Section
            Card(
              color: Colors.green.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.speed, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Speed Test',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Test your internet speed to ensure optimal performance.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Speed Test coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.speed),
                      label: const Text('Run Speed Test'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Help Section
            Card(
              color: Colors.blue.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Need Help?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contact our support team for any issues with your Internet service.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/support'),
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Contact Support'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showRenewDialog(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Plan Renewal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan: ${plan['name']}'),
            Text('Speed: ${plan['speed']}'),
            Text('Data: ${plan['data']}'),
            Text('Price: ₹${plan['price']}'),
            Text('Validity: ${plan['validity']} days'),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to renew with this plan?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.of(context).pop();
                    _renewPlan(plan);
                  },
            child: _isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
