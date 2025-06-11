import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusstylistflutter/models/login_request.dart';
import 'package:campusstylistflutter/providers/auth_provider.dart'; // Adjust import path if needed

class LoginScreen extends ConsumerWidget {
  final VoidCallback onNavigateToSignUp;
  final Function(String, bool, String) onLoginSuccess;

  const LoginScreen({
    Key? key,
    required this.onNavigateToSignUp,
    required this.onLoginSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(loginViewModelProvider);
    final pinkColor = Color(0xFFE0136C);
    final darkColor = Color(0xFF222020);
    final grayColor = Color(0xFFA7A3A3);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

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
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 180),
                  Text(
                    'Welcome back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Login to CampusStylist',
                    style: TextStyle(
                      color: grayColor,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  SizedBox(height: 32),
                  if (viewModel.isLoading)
                    Center(child: CircularProgressIndicator(color: pinkColor))
                  else
                    ElevatedButton(
                      onPressed: () {
                        final request = LoginRequest(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        ref.read(loginViewModelProvider.notifier).login(request, (token, isHairdresser, userId) {
                          onLoginSuccess(token, isHairdresser, userId);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pinkColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        minimumSize: Size(double.infinity, 56),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  SizedBox(height: 32),
                  if (viewModel.errorMessage != null)
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: grayColor, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: onNavigateToSignUp,
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: pinkColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
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
