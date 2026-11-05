
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
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

  // Cria uma conta no Firebase
  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmController.text;

    // Verifica campos vazios
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showAlert('Preencha todos os campos.');
      return;
    }

    // Verifica se as senhas são iguais
    if (password != confirmPassword) {
      showAlert('As senhas não conferem!');
      return;
    }

    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Envia os dados para o Firebase
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Fecha a tela de cadastro
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final mensagem = switch (e.code) {
        'email-already-in-use' =>
          'Já existe uma conta com esse email.',
        'weak-password' =>
          'Escolha uma senha mais forte.',
        'invalid-email' =>
          'Digite um email válido.',
        'operation-not-allowed' =>
          'Cadastro por email e senha não está habilitado.',
        'network-request-failed' =>
          'Verifique sua conexão com a internet.',
        _ => 'Não foi possível criar sua conta.',
      };

      showAlert(mensagem);

    } catch (e) {
      if (!mounted) return;

      showAlert('Ocorreu um erro inesperado.');

    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 90,
                  color: Color(0xFF6C63FF),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Criar uma conta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Preencha os dados para se cadastrar',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),

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

                const SizedBox(height: 15),

                // Confirmar senha
                MyTextField(
                  controller: confirmController,
                  hintText: 'Confirmar senha',
                  icon: Icons.lock_reset,
                  isPassword: true,
                ),

                const SizedBox(height: 25),

                // Botão de cadastro
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  MyButton(
                    onTap: register,
                    text: 'Criar conta',
                    icon: Icons.person_add,
                  ),

                const SizedBox(height: 20),

                // Voltar para login
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Já tem uma conta? Faça login',
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
