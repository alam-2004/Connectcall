import 'package:connectcall/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _phoneController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  String _countryCode = '+91';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');

    final fullPhone = '$_countryCode$phone';

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      name: _nameController.text.trim(),

      phone: fullPhone,

      email: _emailController.text.trim(),

      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.dangerColor,

          content: Text(authProvider.error ?? 'Registration failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                const SizedBox(height: 20),

                // ===============================
                // ICON
                // ===============================
                Container(
                  width: 90,
                  height: 90,

                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),

                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: const Icon(
                    Icons.person_add_alt_1,
                    size: 45,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 30),

                // ===============================
                // NAME
                // ===============================
                TextFormField(
                  controller: _nameController,

                  textCapitalization: TextCapitalization.words,

                  decoration: const InputDecoration(
                    labelText: 'Full Name',

                    prefixIcon: Icon(Icons.person_outline),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }

                    if (value.trim().length < 2) {
                      return 'Name is too short';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ===============================
                // PHONE NUMBER
                // ===============================
                Row(
                  children: [
                    SizedBox(
                      width: 100,

                      child: DropdownButtonFormField<String>(
                        value: _countryCode,

                        decoration: const InputDecoration(labelText: 'Code'),

                        items: const [
                          DropdownMenuItem(
                            value: '+91',
                            child: Text('🇮🇳 +91'),
                          ),

                          DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),

                          DropdownMenuItem(
                            value: '+44',
                            child: Text('🇬🇧 +44'),
                          ),

                          DropdownMenuItem(
                            value: '+971',
                            child: Text('🇦🇪 +971'),
                          ),
                        ],

                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _countryCode = value;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,

                        keyboardType: TextInputType.phone,

                        maxLength: _countryCode == '+91' ? 10 : null,

                        decoration: const InputDecoration(
                          labelText: 'Phone Number',

                          hintText: '9634XXXXXX',

                          prefixIcon: Icon(Icons.phone_outlined),

                          counterText: '',
                        ),

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }

                          final phone = value.trim().replaceAll(
                            RegExp(r'\s+'),
                            '',
                          );

                          if (_countryCode == '+91' && phone.length != 10) {
                            return 'Enter valid 10 digit number';
                          }

                          if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
                            return 'Enter numbers only';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ===============================
                // EMAIL
                // ===============================
                TextFormField(
                  controller: _emailController,

                  keyboardType: TextInputType.emailAddress,

                  decoration: const InputDecoration(
                    labelText: 'Email',

                    prefixIcon: Icon(Icons.email_outlined),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email';
                    }

                    if (!value.contains('@')) {
                      return 'Enter valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ===============================
                // PASSWORD
                // ===============================
                TextFormField(
                  controller: _passwordController,

                  obscureText: _obscurePassword,

                  decoration: InputDecoration(
                    labelText: 'Password',

                    prefixIcon: const Icon(Icons.lock_outline),

                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),

                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ===============================
                // CONFIRM PASSWORD
                // ===============================
                TextFormField(
                  controller: _confirmPasswordController,

                  obscureText: _obscurePassword,

                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',

                    prefixIcon: Icon(Icons.lock_outline),
                  ),

                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // ===============================
                // REGISTER BUTTON
                // ===============================
                CommonButton(
                  text: 'Create Account',

                  icon: Icons.person_add,

                  isLoading: authProvider.isLoading,

                  onPressed: _register,
                ),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
