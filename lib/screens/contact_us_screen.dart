import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../services/contact_service.dart';

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _messageController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Check if it's a phone number for WhatsApp
      if (ContactService.isPhoneNumber(_contactController.text.trim())) {
        // Show WhatsApp options dialog
        await _showWhatsAppDialog();
      } else {
        // Process email normally
        final success = await ContactService.processContactForm(
          name: _nameController.text,
          contact: _contactController.text,
          message: _messageController.text,
        );

        if (success) {
          // Clear form on success
          _nameController.clear();
          _contactController.clear();
          _messageController.clear();
        }
      }
    } catch (e) {
      print('Contact form error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showWhatsAppDialog() async {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    final message = _messageController.text.trim();
    
    final whatsappMessage = 'Hello, I am $name\nEmail/Phone: $contact\n\n$message';
    final encodedMessage = Uri.encodeComponent(whatsappMessage);
    final whatsappWebUrl = 'https://wa.me/918072888085?text=$encodedMessage';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send via WhatsApp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose how to send your message:'),
            const SizedBox(height: 16),
            Text('Contact: +91 8072888085'),
            const SizedBox(height: 8),
            Text('Message Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                whatsappMessage,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // Copy to clipboard and show instructions
              _showWhatsAppInstructions(whatsappWebUrl, whatsappMessage);
            },
            icon: const Icon(Icons.chat),
            label: const Text('Open WhatsApp'),
          ),
        ],
      ),
    );
  }

  void _showWhatsAppInstructions(String webUrl, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WhatsApp Instructions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To send your message via WhatsApp:'),
            const SizedBox(height: 12),
            const Text('1. Copy the number: +91 8072888085'),
            const SizedBox(height: 8),
            const Text('2. Open WhatsApp on your phone'),
            const SizedBox(height: 8),
            const Text('3. Start a new chat with the number'),
            const SizedBox(height: 8),
            const Text('4. Send your message:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                message,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear form after showing instructions
              _nameController.clear();
              _contactController.clear();
              _messageController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message prepared for WhatsApp!')),
              );
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Get in Touch',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'re here to help! Send us a message and we\'ll get back to you soon.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact Form
            Text(
              'Send us a Message',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email or Phone Field
                  TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(
                      labelText: 'Email or Phone',
                      hintText: 'Enter your email or phone number',
                      prefixIcon: Icon(Icons.contact_mail),
                      helperText: ContactService.isEmail(_contactController.text.trim()) 
                          ? '📧 Will send via Email for detailed response'
                          : ContactService.isPhoneNumber(_contactController.text.trim())
                              ? '💬 Will send via WhatsApp for quick chat'
                              : 'Enter email (for detailed response) or phone (for WhatsApp chat)',
                      helperMaxLines: 2,
                    ),
                    onChanged: (value) {
                      setState(() {}); // Rebuild to update helper text
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email or phone number';
                      }
                      if (!ContactService.isEmail(value.trim()) && 
                          !ContactService.isPhoneNumber(value.trim())) {
                        return 'Please enter a valid email or phone number (10-15 digits)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Message Field
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Tell us how we can help you...',
                      prefixIcon: Icon(Icons.message),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your message';
                      }
                      if (value.trim().length < 10) {
                        return 'Please provide more details (at least 10 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitForm,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(ContactService.getButtonIcon(_contactController.text)),
                      label: Text(
                        ContactService.getButtonText(_contactController.text, _isLoading),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Contact Information
            Text(
              'Other Ways to Reach Us',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    _buildContactInfo(
                      context,
                      Icons.phone,
                      'Phone',
                      '+91 80728 88085',
                      Colors.green,
                    ),
                    const Divider(),
                    _buildContactInfo(
                      context,
                      Icons.email,
                      'Email',
                      'support@mugeshbabu.com',
                      Colors.blue,
                    ),
                    const Divider(),
                    _buildContactInfo(
                      context,
                      Icons.location_on,
                      'Address',
                      'Mugeshbabu Services\nIndia',
                      Colors.red,
                    ),
                    const Divider(),
                    _buildContactInfo(
                      context,
                      Icons.access_time,
                      'Business Hours',
                      'Mon - Sat: 9:00 AM - 6:00 PM\nSun: 10:00 AM - 4:00 PM',
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Column(
                children: [
                  _buildFAQItem(
                    context,
                    'How do I recharge my services?',
                    'You can recharge your cable TV and internet services directly through the app. Go to the respective service section and follow the recharge process.',
                  ),
                  const Divider(height: 1),
                  _buildFAQItem(
                    context,
                    'What payment methods do you accept?',
                    'We accept UPI, credit/debit cards, net banking, and digital wallets. All payments are secure and encrypted.',
                  ),
                  const Divider(height: 1),
                  _buildFAQItem(
                    context,
                    'How can I track my support tickets?',
                    'You can view and track all your support tickets in the Support section of the app. You\'ll receive updates via email and app notifications.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(
    BuildContext context,
    IconData icon,
    String title,
    String info,
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
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
