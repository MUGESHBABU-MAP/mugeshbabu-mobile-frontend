import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../services/api_service.dart';
import '../models/auth.dart';

enum AuthMode { login, register }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  AuthMode _authMode = AuthMode.login;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _skipLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('skip_login', true);
    
    if (mounted) {
      context.go('/home');
    }
  }

  Future<void> _quickLogin() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiServiceProvider.instance.quickLogin();
      
      if (response.isSuccess) {
        // Save user data and token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', response.token ?? '');
        await prefs.setString('user_id', response.user!.id);
        await prefs.setString('user_name', response.user!.name);
        await prefs.setString('user_email', response.user!.email);
        await prefs.setBool('is_logged_in', true);

        Fluttertoast.showToast(
          msg: "Quick login successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        
        if (mounted) {
          context.go('/home');
        }
      } else {
        Fluttertoast.showToast(
          msg: response.message.isNotEmpty ? response.message : "Quick login failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceAll('ApiException: ', ''),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      AuthResponse response;
      
      if (_authMode == AuthMode.login) {
        final loginRequest = LoginRequest(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        response = await ApiServiceProvider.instance.login(loginRequest);
      } else {
        final registerRequest = RegisterRequest(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          role: 'customer',
        );
        response = await ApiServiceProvider.instance.register(registerRequest);
      }
      
      if (response.isSuccess) {
        // Save user data and token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', response.token ?? '');
        await prefs.setString('user_id', response.user!.id);
        await prefs.setString('user_name', response.user!.name);
        await prefs.setString('user_email', response.user!.email);
        await prefs.setBool('is_logged_in', true);

        Fluttertoast.showToast(
          msg: _authMode == AuthMode.login ? "Login successful!" : "Registration successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        
        if (mounted) {
          context.go('/home');
        }
      } else {
        Fluttertoast.showToast(
          msg: response.message.isNotEmpty ? response.message : "Authentication failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceAll('ApiException: ', ''),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.register : AuthMode.login;
      // Clear form when switching modes
      _nameController.clear();
      _emailController.clear();
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                
                // App Logo/Title
                Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  _authMode == AuthMode.login ? 'Welcome Back!' : 'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _authMode == AuthMode.login 
                      ? 'Sign in to your account'
                      : 'Join ${AppConstants.appName} today',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Name Field (Register only)
                if (_authMode == AuthMode.register) ...[
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username';
                    }
                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (_authMode == AuthMode.register && value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_authMode == AuthMode.login ? 'Sign In' : 'Create Account'),
                ),
                const SizedBox(height: 16),

                // Toggle Auth Mode
                TextButton(
                  onPressed: _isLoading ? null : _toggleAuthMode,
                  child: Text(
                    _authMode == AuthMode.login
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Sign In",
                  ),
                ),

                // Development Options
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                Text(
                  'Development Options',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Quick Login Button (Development)
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _quickLogin,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Quick Login (Admin)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange[600],
                    side: BorderSide(color: Colors.orange[400]!),
                  ),
                ),
                const SizedBox(height: 8),

                // Skip Login Button
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _skipLogin,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip Login (Demo Mode)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),

                const SizedBox(height: 32),
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
