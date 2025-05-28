import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin/admin_page.dart';
import 'teacher/teacher_page.dart';
import 'cashier/cashier_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vgivgerjkaejnjzahxzi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZnaXZnZXJqa2Flam5qemFoeHppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4MzE2ODgsImV4cCI6MjA2MzQwNzY4OH0.-5UEK5LUs78EpBJi4tC2mIhF4dYmrUe1cPr-14OUbcA',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    final supabase = Supabase.instance.client;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      // Hardcoded admin shortcut
      if (email == 'admin' && password == 'admin') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminPage()),
        );
        return;
      }

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('User not found');

      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = userData?['role'] ?? '';

      if (!mounted) return;

      switch (role) {
        case 'admin':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminPage()));
          break;
        case 'teacher':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TeacherPage()));
          break;
        case 'cashier':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CashierPage()));
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unknown role: $role")),
          );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/school_picture.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 800,
              height: 450,
              child: Stack(
                children: [
                  Container(
                    width: 900,
                    height: 500,
                    color: Color(0xFF1F2C91),
                  ),
                  ClipPath(
                    clipper: SlantClipper(),
                    child: Container(
                      width: 600,
                      height: 500,
                      color: Colors.white,
                      child: Align(
                        alignment: Alignment(-0.6, 0),
                        child: Image.asset(
                          'assets/logo.jpg',
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 100,
                    top: 30,
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACLC PORTAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 32),
                          Text(
                            'Sign in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[300],
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[300],
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                await loginUser(context);
                              },
                              child: Text('Log in'),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'By using this service, you understood and agree to the ACLC Online Services Terms of Use and Privacy Statement',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SlantClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width * 0.6, 0);
    path.lineTo(size.width * 0.4, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
