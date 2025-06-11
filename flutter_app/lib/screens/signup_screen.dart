import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusstylistflutter/models/auth_request.dart';
import 'package:campusstylistflutter/providers/auth_provider.dart'; // Adjust import path if needed

class SignUpScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToLogin;
  final Function(String, bool, String?, String) onSignupSuccess;

  const SignUpScreen({
    Key? key,
    required this.onNavigateToLogin,
    required this.onSignupSuccess,
  }) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(signUpViewModelProvider); // Watch the state for loading and error
    final viewModel = ref.read(signUpViewModelProvider.notifier); // Use notifier for isHairdresser and setRole

    final pinkColor = Color(0xFFE0136C);
    final darkColor = Color(0xFF222020);
    final grayColor = Color(0xFFA7A3A3);

    return Scaffold(
      backgroundColor: darkColor,
      body: Stack(
        children: [
          CustomPaint(
            size: Size(double.infinity, 250),
            painter: WavePainter(pinkColor),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 180),
                  const Text(
                    'Welcome!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account to join CampusStylist',
                    style: TextStyle(
                      color: grayColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Role',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => viewModel.setRole(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !viewModel.isHairdresser ? pinkColor : grayColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Client',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => viewModel.setRole(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: viewModel.isHairdresser ? pinkColor : grayColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Hairdresser',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (viewModelState.isLoading)
                    Center(child: CircularProgressIndicator(color: pinkColor))
                  else
                    ElevatedButton(
                      onPressed: emailController.text.isNotEmpty && passwordController.text.isNotEmpty
                          ? () async {
                        final request = AuthRequest(
                          email: emailController.text,
                          password: passwordController.text,
                          role: viewModel.isHairdresser ? 'HAIRDRESSER' : 'CLIENT',
                        );
                        await viewModel.signUp(request, (token, isHairdresser, userId) {
                          if (context.mounted) {
                            widget.onSignupSuccess(
                              viewModel.isHairdresser ? 'HAIRDRESSER' : 'CLIENT',
                              isHairdresser,
                              userId,
                              token,
                            );
                            context.go('/createProfile/${viewModel.isHairdresser}/$token');
                          }
                        });
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pinkColor,
                        disabledBackgroundColor: grayColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 32),
                  if (viewModelState.errorMessage != null)
                    Text(
                      viewModelState.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: grayColor, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: widget.onNavigateToLogin,
                        child: Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: pinkColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;

  WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.7)
      ..cubicTo(
        size.width * 0.75,
        size.height * 1.05,
        size.width * 0.25,
        size.height * 0.85,
        0,
        size.height * 0.95,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}