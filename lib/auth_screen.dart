import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/home.dart';
import 'pages/admin_pages.dart';

const Color bgMain = Color(0xFFCEDAD2);
const Color cardBg = Color(0xFFFFFFFF);

const Color primary = Color(0xFF62B4CA);
const Color secondary = Color(0xFFB4D2D0);
const Color accent = Color(0xFF0784A5);

const Color textMain = Color(0xFF001936);
const Color textMuted = Color(0xFF4F6D7A);
const Color errorColor = Color(0xFFB84A4A);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool isPasswordHidden = true;
  String errorMessage = '';

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      UserCredential userCredential;

      if (isLogin) {
        userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text.trim(),
          'role': 'user',
          'createdAt': Timestamp.now(),
        });
      }

      final uid = userCredential.user!.uid;
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        await userRef.set({
          'email': _emailController.text.trim(),
          'role': 'user',
          'createdAt': Timestamp.now(),
        });
      }

      final role = userDoc.data()?['role'] ?? 'user';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => role == 'admin'
              ? const AdminPage()
              : const HomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = switch (e.code) {
          'user-not-found' => 'Email tidak terdaftar',
          'wrong-password' => 'Password salah',
          'invalid-email' => 'Format email tidak valid',
          'email-already-in-use' => 'Email sudah digunakan',
          'weak-password' => 'Password terlalu lemah (min. 6 karakter)',
          _ => 'Terjadi kesalahan. Silakan coba lagi.',
        };
      });
    } catch (_) {
      setState(() => errorMessage = 'Terjadi kesalahan sistem');
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textMuted),
      prefixIcon: Icon(icon, color: primary),
      filled: true,
      fillColor: secondary.withOpacity(0.3),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: secondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accent, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: secondary),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_movies_outlined,
                  size: 72,
                  color: primary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'CINELIST',
                  style: TextStyle(
                    color: textMain,
                    fontSize: 26,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isLogin
                      ? 'SIGN IN TO CONTINUE'
                      : 'CREATE YOUR ACCOUNT',
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: textMain),
                  decoration: _inputDecoration(
                    'Email Address',
                    Icons.alternate_email,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: isPasswordHidden,
                  style: const TextStyle(color: textMain),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: textMuted),
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: textMuted,
                      ),
                      onPressed: () => setState(
                        () => isPasswordHidden = !isPasswordHidden,
                      ),
                    ),
                    filled: true,
                    fillColor: secondary.withOpacity(0.3),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: secondary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: accent, width: 1.6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: errorColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: errorColor.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 18,
                          color: errorColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: errorColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                        : Text(
                            isLogin ? 'LOGIN' : 'REGISTER',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLogin = !isLogin;
                      errorMessage = '';
                    });
                  },
                  child: Text(
                    isLogin
                        ? 'CREATE NEW ACCOUNT'
                        : 'BACK TO LOGIN',
                    style: const TextStyle(
                      color: accent,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
