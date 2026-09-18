import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';
import '../wardrobe/add_wardrobe_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedGender = 'female';
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final List<Map<String, dynamic>> _genderOptions = [
    {'value': 'female', 'label': 'Female', 'icon': Icons.female_rounded},
    {'value': 'male', 'label': 'Male', 'icon': Icons.male_rounded},
    {'value': 'other', 'label': 'Other', 'icon': Icons.person_outline_rounded},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double score = 0.0;
    if (password.length >= 6) score += 0.33;
    if (password.length >= 8 && RegExp(r'[A-Z]').hasMatch(password)) score += 0.33;
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>.]').hasMatch(password)) score += 0.34;
    return score.clamp(0.0, 1.0);
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.34) return const Color(0xFFEF4444);
    if (strength <= 0.67) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _getStrengthText(double strength) {
    if (strength == 0) return '';
    if (strength <= 0.34) return 'Weak password';
    if (strength <= 0.67) return 'Medium strength';
    return 'Strong password';
  }

  void _handleSaveAndRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawName = _nameController.text.trim();
      final sanitizedUsername = rawName.replaceAll(RegExp(r'\s+'), '_');

      final api = ref.read(authServiceProvider);
      await api.register(
        username: sanitizedUsername,
        password: _passwordController.text,
        gender: _selectedGender,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Details Saved! Now let\'s add your wardrobe items.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF6B21A8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AddWardrobeScreen()),
        );
      }
    } on DioException catch (e) {
      setState(() {
        final data = e.response?.data;
        if (data is Map) {
          final usernameErr = data['username'] is List ? data['username'][0] : data['username'];
          final passwordErr = data['password'] is List ? data['password'][0] : data['password'];
          final detailErr = data['detail'];
          final nonFieldErr = data['non_field_errors'] is List ? data['non_field_errors'][0] : null;
          
          _errorMessage = usernameErr?.toString() ??
              passwordErr?.toString() ??
              detailErr?.toString() ??
              nonFieldErr?.toString() ??
              'Registration failed. Please check your details.';
        } else {
          _errorMessage = 'Registration failed: ${e.message ?? "Connection error"}';
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Registration error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordStrength = _calculatePasswordStrength(_passwordController.text);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Purple Header Banner
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B0764),
                        Color(0xFF6B21A8),
                        Color(0xFF9333EA),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back Button
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),

                              // Step 1 Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.person_pin_rounded, color: Color(0xFFFDE047), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Step 1: Profile',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Create Account ✨',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 4),
                          Text(
                            'Fill in your details and tap Save to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                        ],
                      ),
                    ),
                  ),
                ),

                // Decorative Ambient Glow Orb
                Positioned(
                  right: -30,
                  top: -20,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Registration Form Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Transform.translate(
                offset: const Offset(0, -25),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B21A8).withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error Alert Banner
                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFF991B1B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().shake(),
                          const SizedBox(height: 18),
                        ],

                        // 1. Name Field
                        _buildLabel('Name'),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: _buildInputDecoration(
                            hint: 'Enter your full name',
                            icon: Icons.person_outline_rounded,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter your name';
                            if (val.trim().length < 2) return 'Name must be at least 2 characters';
                            return null;
                          },
                        ).animate().fadeIn(delay: 100.ms),

                        const SizedBox(height: 20),

                        // 2. Password Field
                        _buildLabel('Password'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.done,
                          decoration: _buildInputDecoration(
                            hint: 'Create a password',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: const Color(0xFF6B21A8),
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please enter a password';
                            if (val.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ).animate().fadeIn(delay: 150.ms),

                        // Password Strength Meter
                        if (_passwordController.text.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: passwordStrength,
                                    minHeight: 5,
                                    backgroundColor: const Color(0xFFE9D5FF),
                                    valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor(passwordStrength)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _getStrengthText(passwordStrength),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStrengthColor(passwordStrength),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(),
                        ],

                        const SizedBox(height: 22),

                        // 3. Gender Selection
                        _buildLabel('Gender'),
                        Row(
                          children: _genderOptions.map((option) {
                            final isSelected = _selectedGender == option['value'];
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: InkWell(
                                  onTap: () => setState(() => _selectedGender = option['value']),
                                  borderRadius: BorderRadius.circular(16),
                                  child: AnimatedContainer(
                                    duration: 200.ms,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF6B21A8) : const Color(0xFFFAF5FF),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF6B21A8) : const Color(0xFFE9D5FF),
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF6B21A8).withValues(alpha: 0.25),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          option['icon'] as IconData,
                                          size: 18,
                                          color: isSelected ? Colors.white : const Color(0xFF6B21A8),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          option['label'] as String,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white : const Color(0xFF3B0764),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 32),

                        // SAVE Button (Purple Gradient) -> Navigates to AddWardrobeScreen
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9333EA).withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSaveAndRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Save',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ).animate().fadeIn(delay: 250.ms).scale(begin: const Offset(0.95, 0.95)),

                        const SizedBox(height: 24),

                        // Back to Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: const Color(0xFF6B21A8).withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Color(0xFF9333EA),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF9333EA),
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3B0764),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF6B21A8).withValues(alpha: 0.4),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF6B21A8), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFAF5FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE9D5FF), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
      ),
    );
  }
}
