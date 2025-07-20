import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../core/constants.dart';

class BillPaymentScreen extends ConsumerStatefulWidget {
  const BillPaymentScreen({super.key});

  @override
  ConsumerState<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends ConsumerState<BillPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedBillType = AppConstants.billTypes.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _payBill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    Fluttertoast.showToast(
      msg: "Payment successful! ₹${_amountController.text} paid for $_selectedBillType",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );

    // Clear form
    _accountNumberController.clear();
    _amountController.clear();
    setState(() => _selectedBillType = AppConstants.billTypes.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                color: Colors.green.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pay Your Bills',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quick and secure bill payments',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bill Type Selection
              Text(
                'Select Bill Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedBillType,
                decoration: const InputDecoration(
                  labelText: 'Bill Type',
                  prefixIcon: Icon(Icons.category),
                ),
                items: AppConstants.billTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedBillType = newValue);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a bill type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Account Number Field
              Text(
                'Account Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  hintText: 'Enter your account number',
                  prefixIcon: Icon(Icons.account_balance),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  if (value.length < 6) {
                    return 'Account number must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount to pay',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > 50000) {
                    return 'Amount cannot exceed ₹50,000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _payBill,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Pay Bill',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Payments Section
              Text(
                'Recent Payments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      _buildPaymentHistoryItem(
                        'Electricity',
                        'Account: ****5678',
                        '₹2,450',
                        '2 days ago',
                        Colors.yellow[700]!,
                        Icons.flash_on,
                      ),
                      const Divider(),
                      _buildPaymentHistoryItem(
                        'Water',
                        'Account: ****1234',
                        '₹850',
                        '1 week ago',
                        Colors.blue,
                        Icons.water_drop,
                      ),
                      const Divider(),
                      _buildPaymentHistoryItem(
                        'Gas',
                        'Account: ****9876',
                        '₹1,200',
                        '2 weeks ago',
                        Colors.orange,
                        Icons.local_fire_department,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Pay Options
              Text(
                'Quick Pay Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _buildQuickPayCard('Electricity', Icons.flash_on, Colors.yellow[700]!),
                  _buildQuickPayCard('Water', Icons.water_drop, Colors.blue),
                  _buildQuickPayCard('Gas', Icons.local_fire_department, Colors.orange),
                  _buildQuickPayCard('Internet', Icons.wifi, Colors.purple),
                ],
              ),
              const SizedBox(height: 24),

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
                            'Payment Help',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Having trouble with payments? Our support team is here to help.',
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
      ),
    );
  }

  Widget _buildPaymentHistoryItem(
    String title,
    String account,
    String amount,
    String date,
    Color color,
    IconData icon,
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
                  account,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPayCard(String title, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() => _selectedBillType = title);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title selected for quick payment')),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
