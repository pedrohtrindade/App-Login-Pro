import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/social_button.dart';
import 'register_page.dart';

import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Mostra mensagens ao usuário
  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Envia email para recuperar a senha
  Future<void> forgotPassword() async {
    if (emailController.text.trim().isEmpty) {
      showAlert('Digite seu email primeiro.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      showAlert('Enviamos um link para seu email!');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final mensagem = switch (e.code) {
        'invalid-email' => 'Digite um email válido.',
        'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
        _ => 'Não foi possível enviar o email.',
      };

      showAlert(mensagem);
    }
  }

  // Realiza o login usando Firebase
  Future<void> signIn() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showAlert('Preencha email e senha.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      final mensagem = switch (e.code) {
        'invalid-credential' => 'Email ou senha incorretos.',
        'user-not-found' => 'Usuário não encontrado.',
        'wrong-password' => 'Senha incorreta.',
        'invalid-email' => 'Email inválido.',
        'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
        _ => 'Não foi possível entrar. Tente novamente.',
      };

      showAlert(mensagem);
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);
      showAlert('Ocorreu um erro inesperado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Lottie.asset(
                  'assets/animations/login.json',
                  height: 150,
                  repeat: true,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Bem-vindo de volta!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                // Campo de email
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 15),

                // Campo de senha
                MyTextField(
                  controller: passwordController,
                  hintText: 'Senha',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                // Recuperar senha
                TextButton(
                  onPressed: forgotPassword,
                  child: const Text('Esqueceu a senha?'),
                ),

                const SizedBox(height: 10),

                // Botão de login
                MyButton(onTap: signIn, text: 'Entrar', icon: Icons.login),

                const SizedBox(height: 25),

                const Text('ou continue com'),

                const SizedBox(height: 15),

                // Botões sociais (apenas visuais)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      SocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onTap: () {},
                      ),

                      const SizedBox(width: 12),

                      SocialButton(
                        icon: Icons.apple,
                        label: 'Apple',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // Navegação para cadastro
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text('Registre-se agora'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
