import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/signup_view_model.dart';

class SignUpScreen extends StatelessWidget {
  final VoidCallback onNavigateToLogin;
  final Function(String, bool, String?, String) onSignupSuccess;

  const SignUpScreen({
    Key? key,
    required this.onNavigateToLogin,
    required this.onSignupSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpViewModel>(context);
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
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 180),
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create an account to join CampusStylist',
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
                    onChanged: viewModel.updateEmail,
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
                    onChanged: viewModel.updatePassword,
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
                  SizedBox(height: 16),
                  Text(
                    'Select Role',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
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
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Client',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => viewModel.setRole(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: viewModel.isHairdresser ? pinkColor : grayColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Hairdresser',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (viewModel.isLoading)
                    Center(child: CircularProgressIndicator(color: pinkColor))
                  else
                    ElevatedButton(
                      onPressed: viewModel.email.isNotEmpty && viewModel.password.isNotEmpty
                          ? () {
                        viewModel.signUp((isHairdresser, token) {
                          final role = isHairdresser ? 'HAIRDRESSER' : 'CLIENT';
                          onSignupSuccess(role, false, viewModel.userId, token);
                        });
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pinkColor,
                        disabledBackgroundColor: grayColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        minimumSize: Size(double.infinity, 56),
                      ),
                      child: Text(
                        'Sign Up',
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
                        'Already have an account? ',
                        style: TextStyle(color: grayColor, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: onNavigateToLogin,
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