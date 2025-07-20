import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

enum LegalType { privacy, terms }

class LegalScreen extends StatefulWidget {
  final LegalType initialType;
  
  const LegalScreen({
    super.key,
    this.initialType = LegalType.privacy,
  });

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LegalType _currentType;

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _currentType == LegalType.privacy ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          // labelColor: Theme.of(context).primaryColor,
          labelColor: Colors.white,
          // unselectedLabelColor: Colors.grey[600],
          unselectedLabelColor: Colors.white70,
          // indicatorColor: Theme.of(context).primaryColor,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.privacy_tip_outlined),
              text: 'Privacy Policy',
            ),
            Tab(
              icon: Icon(Icons.description_outlined),
              text: 'Terms & Conditions',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrivacyPolicy(),
          _buildTermsAndConditions(),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Clarification Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"Mugeshbabu" refers to this mobile application and its owners/operators',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Introduction
          _buildSectionText(
            'Mugeshbabu is committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our multi-service platform.',
          ),
          const SizedBox(height: 24),

          // Section 1: Data Collection
          _buildSectionTitle('1. Data Collection'),
          _buildSectionText(
            'We collect minimal data necessary to provide our services effectively:\n\n'
            '• Personal Information: Name, mobile number, and email address for account creation and communication\n'
            '• Transaction Information: Payment details, service subscriptions, and billing history to process your requests\n'
            '• Usage Data: App usage patterns and preferences to improve our services\n'
            '• Device Information: Basic device details for technical support and security purposes',
          ),
          const SizedBox(height: 20),

          // Section 2: Usage of Data
          _buildSectionTitle('2. Usage of Data'),
          _buildSectionText(
            'Your data is used exclusively for legitimate business purposes:\n\n'
            '• Service Delivery: To process payments, manage subscriptions, and provide customer support\n'
            '• Communication: To send service updates, payment confirmations, and important notifications\n'
            '• Service Improvement: To enhance app functionality and user experience\n'
            '• Legal Compliance: To meet regulatory requirements and prevent fraud\n\n'
            'We never sell, rent, or share your personal data with third parties for marketing purposes.',
          ),
          const SizedBox(height: 20),

          // Section 3: Storage and Security
          _buildSectionTitle('3. Storage and Security'),
          _buildSectionText(
            'We implement industry-standard security measures to protect your data:\n\n'
            '• Encryption: All sensitive data is encrypted during transmission and storage\n'
            '• Access Control: Limited access to personal data on a need-to-know basis\n'
            '• Regular Audits: Periodic security assessments and updates\n'
            '• Secure Infrastructure: Data stored on secure, monitored servers\n\n'
            'While we strive to protect your information, no method of transmission over the internet is 100% secure.',
          ),
          const SizedBox(height: 20),

          // Section 4: Notification Permissions
          _buildSectionTitle('4. Notification Permissions'),
          _buildSectionText(
            'We use push notifications to enhance your experience:\n\n'
            '• Service Reminders: Bill due dates and subscription renewals\n'
            '• Transaction Updates: Payment confirmations and service status\n'
            '• Important Alerts: Service disruptions and security notifications\n\n'
            'You can opt-out of notifications at any time through your device settings or app preferences.',
          ),
          const SizedBox(height: 20),

          // Section 5: User Rights
          _buildSectionTitle('5. User Rights'),
          _buildSectionText(
            'You have the following rights regarding your personal data:\n\n'
            '• Access: Request information about data we hold about you\n'
            '• Correction: Update or correct inaccurate personal information\n'
            '• Deletion: Request deletion of your personal data (subject to legal requirements)\n'
            '• Portability: Request a copy of your data in a structured format\n\n'
            'To exercise these rights or ask questions about your data, please contact our support team through the app.',
          ),
          const SizedBox(height: 20),

          // Section 6: Changes to Policy
          _buildSectionTitle('6. Changes to Policy'),
          _buildSectionText(
            'We may update this Privacy Policy from time to time to reflect changes in our practices or legal requirements. When we make significant changes:\n\n'
            '• We will notify you through the app or email\n'
            '• The updated policy will be posted with a new effective date\n'
            '• Continued use of the app constitutes acceptance of the updated policy',
          ),
          const SizedBox(height: 32),

          // Agreement
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              'By continuing to use the Mugeshbabu app, you agree to this Privacy Policy.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Terms and Conditions',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Clarification Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"Mugeshbabu" refers to this mobile application and its owners/operators',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Introduction
          _buildSectionText(
            'Welcome to Mugeshbabu. These Terms and Conditions govern your use of our multi-utility service platform. Please read them carefully before using our services.',
          ),
          const SizedBox(height: 24),

          // Section 1: Acceptance
          _buildSectionTitle('1. Acceptance'),
          _buildSectionText(
            'By downloading, installing, or using the Mugeshbabu app, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you must not use our services.\n\n'
            'These terms constitute a legally binding agreement between you and Mugeshbabu.',
          ),
          const SizedBox(height: 20),

          // Section 2: Services Offered
          _buildSectionTitle('2. Services Offered'),
          _buildSectionText(
            'Mugeshbabu provides a comprehensive platform for managing various utility services:\n\n'
            '• Cable TV: Subscription management, recharge, and plan upgrades\n'
            '• Internet Services: Broadband plan management and renewals\n'
            '• Utility Bill Payments: Internet, cable, and other utility bill processing\n'
            '• Customer Support: Technical assistance and service-related queries\n\n'
            'We act as an intermediary between you and service providers, facilitating transactions and communications.',
          ),
          const SizedBox(height: 20),

          // Section 3: User Responsibilities
          _buildSectionTitle('3. User Responsibilities'),
          _buildSectionText(
            'As a user of Mugeshbabu, you agree to:\n\n'
            '• Provide accurate and complete information during registration and transactions\n'
            '• Make timely payments for all services and subscriptions\n'
            '• Use the app only for lawful purposes and in accordance with these terms\n'
            '• Maintain the confidentiality of your account credentials\n'
            '• Notify us immediately of any unauthorized use of your account\n'
            '• Comply with all applicable laws and regulations',
          ),
          const SizedBox(height: 20),

          // Section 4: Payment & Refunds
          _buildSectionTitle('4. Payment & Refunds'),
          _buildSectionText(
            'Payment terms and refund policy:\n\n'
            '• All payments made through the app are final and non-refundable under normal circumstances\n'
            '• Refunds will only be considered if a technical issue on our platform is proven to have caused service failure\n'
            '• Refund requests must be submitted within 7 days of the transaction\n'
            '• Processing fees and third-party charges are non-refundable\n'
            '• Refunds, if approved, will be processed within 7-10 business days\n\n'
            'Payment disputes should be reported immediately through our support channels.',
          ),
          const SizedBox(height: 20),

          // Section 5: Service Disruptions
          _buildSectionTitle('5. Service Disruptions'),
          _buildSectionText(
            'Service availability and limitations:\n\n'
            '• Mugeshbabu is not responsible for service downtime or disruptions caused by third-party service providers\n'
            '• We do not guarantee uninterrupted access to our platform or services\n'
            '• Scheduled maintenance may temporarily affect app functionality\n'
            '• Force majeure events may impact service delivery\n\n'
            'We will make reasonable efforts to notify users of planned maintenance and service disruptions.',
          ),
          const SizedBox(height: 20),

          // Section 6: Termination
          _buildSectionTitle('6. Termination'),
          _buildSectionText(
            'Account termination conditions:\n\n'
            '• You may terminate your account at any time by contacting our support team\n'
            '• We reserve the right to suspend or terminate accounts for:\n'
            '  - Violation of these terms and conditions\n'
            '  - Fraudulent or suspicious activity\n'
            '  - Non-payment of dues\n'
            '  - Misuse of the platform\n\n'
            'Upon termination, your access to services will be discontinued, but payment obligations remain.',
          ),
          const SizedBox(height: 20),

          // Section 7: Updates to Terms
          _buildSectionTitle('7. Updates to Terms'),
          _buildSectionText(
            'These Terms and Conditions may be updated periodically:\n\n'
            '• Users will be notified of significant changes through the app or email\n'
            '• Updated terms will be posted with a new effective date\n'
            '• Continued use of the app after changes constitutes acceptance\n'
            '• Users who disagree with updated terms should discontinue use of the service',
          ),
          const SizedBox(height: 32),

          // Final Authority Clause
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.gavel,
                  color: Colors.red[700],
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Final Authority Clause',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'In case of any dispute or conflict, the interpretation and decision of the Mugeshbabu app owner shall be considered final and binding.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        height: 1.6,
        color: Colors.grey[800],
      ),
    );
  }
}
