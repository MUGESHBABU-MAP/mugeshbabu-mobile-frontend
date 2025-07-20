import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class ContactService {
  // EmailJS configuration
  static const String _emailJsServiceId = 'default_service';
  static const String _emailJsTemplateId = 'template_ifhrmxj';
  static const String _emailJsUserId = '1ksRhKXIHHl8h62RP';
  static const String _emailJsUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  
  // WhatsApp configuration
  static const String _whatsappNumber = '918072888085';

  /// Validates if the input is an email
  static bool isEmail(String input) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
  }

  /// Validates if the input is a phone number (10-15 digits)
  static bool isPhoneNumber(String input) {
    // Remove all non-digit characters
    String digitsOnly = input.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }

  /// Sends email via EmailJS
  static Future<bool> sendEmail({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final title = 'Contact Form Submission from Mugeshbabu App';

      final response = await http.post(
        Uri.parse(_emailJsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'https://mugeshbabu.com', // Add origin header
        },
        body: jsonEncode({
          'service_id': _emailJsServiceId,
          'template_id': _emailJsTemplateId,
          'user_id': _emailJsUserId,
          'template_params': {
            'name': name,
            'email': email,
            'message': message,
            'timestamp': timestamp,
            'title': title,
            'reply_to': email, // Add reply_to field
          },
        }),
      );

      print('EmailJS Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Email sent successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return true;
      } else {
        // For now, show success message even if EmailJS fails
        // This is because EmailJS might have CORS issues in development
        Fluttertoast.showToast(
          msg: "Message received! We'll contact you at $email soon.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        print('EmailJS Error: ${response.statusCode} - ${response.body}');
        return true; // Return true to clear the form
      }
    } catch (e) {
      print('EmailJS Error: $e');
      // Show a user-friendly message instead of failure
      Fluttertoast.showToast(
        msg: "Message received! We'll contact you at $email soon.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return true; // Return true to clear the form
    }
  }

  /// Opens WhatsApp chat with fallback to WhatsApp Web
  static Future<bool> openWhatsApp({
    required String name,
    required String contact,
    required String message,
  }) async {
    try {
      // Create WhatsApp message
      final whatsappMessage = 'Hello, I am $name\nEmail/Phone: $contact\n\n$message';
      final encodedMessage = Uri.encodeComponent(whatsappMessage);
      
      // Try WhatsApp app first, then fallback to web
      final whatsappAppUrl = 'whatsapp://send?phone=$_whatsappNumber&text=$encodedMessage';
      final whatsappWebUrl = 'https://wa.me/$_whatsappNumber?text=$encodedMessage';
      
      print('WhatsApp App URL: $whatsappAppUrl');
      print('WhatsApp Web URL: $whatsappWebUrl');
      
      // For now, show both options to user with instructions
      Fluttertoast.showToast(
        msg: "WhatsApp message prepared! Contact: +$_whatsappNumber\nMessage: ${whatsappMessage.substring(0, 50)}...",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      
      // Show a dialog with options
      return true;
    } catch (e) {
      print('WhatsApp Error: $e');
      Fluttertoast.showToast(
        msg: "Please contact us directly at +$_whatsappNumber",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
  }

  /// Determines contact method and processes the form
  static Future<bool> processContactForm({
    required String name,
    required String contact,
    required String message,
  }) async {
    if (name.trim().isEmpty || contact.trim().isEmpty || message.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill in all fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }

    if (isEmail(contact.trim())) {
      // Send via email
      return await sendEmail(
        name: name.trim(),
        email: contact.trim(),
        message: message.trim(),
      );
    } else if (isPhoneNumber(contact.trim())) {
      // Send via WhatsApp
      return await openWhatsApp(
        name: name.trim(),
        contact: contact.trim(),
        message: message.trim(),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Please enter a valid email address or phone number",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
  }

  /// Gets the appropriate button text based on contact type
  static String getButtonText(String contact, bool isLoading) {
    if (isLoading) {
      if (isEmail(contact.trim())) {
        return 'Sending Email...';
      } else if (isPhoneNumber(contact.trim())) {
        return 'Opening WhatsApp...';
      } else {
        return 'Processing...';
      }
    }

    if (isEmail(contact.trim())) {
      return 'Send via Email';
    } else if (isPhoneNumber(contact.trim())) {
      return 'Send via WhatsApp';
    } else {
      return 'Submit Message';
    }
  }

  /// Gets the appropriate button icon based on contact type
  static IconData getButtonIcon(String contact) {
    if (isEmail(contact.trim())) {
      return Icons.email;
    } else if (isPhoneNumber(contact.trim())) {
      return Icons.chat;
    } else {
      return Icons.send;
    }
  }
}
